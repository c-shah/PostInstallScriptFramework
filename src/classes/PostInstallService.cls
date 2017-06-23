/**
 * Created by cshah on 5/22/2017.
 */

/**
 * this class is using without stharing to get access to all users for emails as well as able to access class to start job
 */

public without sharing class PostInstallService implements IPostInstallService {

    public enum PostInstallScriptStatus {Completed, Errored, Pending }

    private static PostInstallService instance;

    /** singleton **/
    @TestVisible
    private PostInstallService() {

    }

    public static PostInstallService getInstance() {
        if( instance == null ) {
            instance = new PostInstallService();
        }
        return instance;
    }

    @TestVisible
    private static void debug(String input) {
        System.debug( LoggingLevel.DEBUG, input );
    }

    @TestVisible
    private static void error(String input) {
        System.debug( LoggingLevel.ERROR, input );
    }

    /**
     * this is start method which will be called from post install script
     */
    public void startService() {
        boolean startScriptError = false;
        debug(' startService: inside start service ');
        List<PostInstallScript__c> postInstallScripts = [ select sequenceNumber__c, description__c, className__c, status__c from PostInstallScript__c limit 200 ];
        String namespacePrefix = Utilities.getNamespace();
        List<ApexClass> apexClasses = null;
        if( namespacePrefix != null ) {
            apexClasses = [SELECT id, name, IsValid, Status, Body, namespacePrefix from ApexClass where namespacePrefix = :namespacePrefix and name like '%PostInstall%' and name != 'PostInstallScriptTemplate'  ];
        } else {
            apexClasses = [SELECT id, name, IsValid, Status, Body, namespacePrefix from ApexClass where name like '%PostInstall%'  and name != 'PostInstallScriptTemplate' ];
        }
        List<PostInstallScript__c> postInstallScriptsAddition = new List<PostInstallScript__c>();
        for(ApexClass apexClass : apexClasses ) {
            try {
                if( apexClass.IsValid && apexClass.Status == 'Active' ) {
                    Type classType = Type.forName(apexClass.name);
                    Object sObjectInstance = classType.newInstance();
                    Boolean isPostInstallScript = sObjectInstance instanceof IPostInstallScript;
                    if( isPostInstallScript == true ) {
                        IPostInstallScript postInstallScriptInstance = (IPostInstallScript) sObjectInstance;
                        String className = apexClass.name;
                        Integer sequenceNumber = postInstallScriptInstance.getSequenceNumber();
                        Boolean postInstallScriptExists = false;
                        for(PostInstallScript__c postInstallScript : postInstallScripts ) {
                            if( postInstallScript.sequenceNumber__c ==  sequenceNumber ) {
                                postInstallScriptExists = true;
                            }
                        }
                        if( postInstallScriptExists == false ) {
                            PostInstallScript__c postInstallScript = new PostInstallScript__c();
                            postInstallScript.sequenceNumber__c = sequenceNumber;
                            postInstallScript.description__c = postInstallScriptInstance.getDescription();
                            postInstallScript.className__c = className;
                            postInstallScriptsAddition.add( postInstallScript );
                            debug('startService: adding new class ' + className + ' sequenceNumber ' + sequenceNumber );
                        }
                    }
                } else {
                    if( apexClass.body.contains('extends PostInstallScriptTemplate') ) {
                        debug( ' startService : apexClass ' + apexClass.name + '  valid: ' + apexClass.isValid + ' status ' + apexClass.status  );
                        PostInstallHandler.sendGenericErrorEmail('Please compile all classes and re-execute xECM post install scripts ');
                        startScriptError = true;
                        break;
                    }
                }
            } catch(Exception e ) {}
        }
        if( startScriptError == false ) {
            if( postInstallScriptsAddition.size() > 0) {
                insert postInstallScriptsAddition;
            } else {
                debug('startService: no new post install script to be added. ');
            }
            debug('startService : calling executeNextScript');
            executeNextScript();
        }
    }

    public void executeNextScript() {
        try {
            debug('executeNextScript : start ');
            Integer pendingErrorCount = [ select count() from PostInstallScript__c where ( status__c = 'Errored' or status__c = 'Pending' ) ];
            if( pendingErrorCount > 0 ) {
                PostInstallHandler.sendGenericErrorEmail('Unable to execute xECM post install script as there are pending/errored scripts');
            } else {
                List<PostInstallScript__c> postInstallScripts = [select sequenceNumber__c, description__c, className__c, status__c, ExecutionTime__c from PostInstallScript__c where status__c = null order by sequenceNumber__c asc];
                if (postInstallScripts != null && postInstallScripts.size() > 0) {
                    PostInstallScript__c nextPostInstallScript = postInstallScripts[0];
                    nextPostInstallScript.status__c = String.valueOf(PostInstallScriptStatus.Pending);
                    update nextPostInstallScript;
                    Type classType = Type.forName(nextPostInstallScript.className__c);
                    PostInstallScriptTemplate sObjectInstance = (PostInstallScriptTemplate) classType.newInstance();
                    debug('executeNextScript : scheduling ' + nextPostInstallScript.className__c + '  sequence ' + nextPostInstallScript.sequenceNumber__c);
                    Database.executeBatch(sObjectInstance, sObjectInstance.getBatchSize());
                } else {
                    debug('executeNextScript : nothing left to process. calling finish');
                    finishService();
                }
            }
        } catch(Exception e) {
            error('Error executing next script ');
            String errorStackTrace = e.getMessage()  + '\n' + e.getStackTraceString();
            PostInstallHandler.sendGenericErrorEmail(errorStackTrace);
        }
    }

    /**
     * this method will be called from framework (executeNext)
     * after all the scripts are executed
     */
    public void finishService() {
        debug('finishService : start ');
        List<PostInstallScript__c> postInstallScripts = [select sequenceNumber__c, description__c, className__c, status__c, ExecutionLog__c, ExecutionTime__c, NotificationSentFlag__c from PostInstallScript__c where NotificationSentFlag__c = false and  status__c != null order by sequenceNumber__c desc limit 200 ];
        if( postInstallScripts != null && postInstallScripts.size() > 0 ) {
            boolean hasError = false;
            for(PostInstallScript__c postInstallScript : postInstallScripts) {
                if( postInstallScript.status__c == String.valueOf(PostInstallScriptStatus.Errored) || postInstallScript.status__c == String.valueOf(PostInstallScriptStatus.Pending)  ) {
                    hasError = true;
                }
            }
            try {
                if( hasError == true ) {
                    debug('finishService : sending error email ');
                    sendErrorEmail(postInstallScripts);
                } else {
                    debug('finishService : sending success email ');
                    sendSuccessEmail(postInstallScripts);
                }
            } catch(Exception e) {
                // don't stop processing if email can't be sent.
                error('Error sending email ' + e.getStackTraceString() );
            }
        }
        for(PostInstallScript__c postInstallScript : postInstallScripts) {
            postInstallScript.NotificationSentFlag__c = true;
        }
        debug('finishService : setting post installs script notification flag - and exiting ');
        update postInstallScripts;
    }

    public void retry() {
        List<PostInstallScript__c> pendingErroredTrackings = [ select sequenceNumber__c, description__c, className__c, status__c, ExecutionLog__c, ExecutionTime__c, NotificationSentFlag__c from PostInstallScript__c where ( status__c = 'Errored' or status__c = 'Pending' ) order by sequenceNumber__c asc ];
        if( pendingErroredTrackings.size() > 0 ) {
            PostInstallScript__c firstInList = pendingErroredTrackings[0];
            firstInList.status__c = null;
            firstInList.ExecutionLog__c = null;
            firstInList.NotificationSentFlag__c = false;
            update firstInList;
            debug(' retry : updating ' + firstInList.className__c + ' sequenceNumber: ' + firstInList.sequenceNumber__c + ' status back to null for reprocessing' );
        }
        executeNextScript();
    }

    @TestVisible
    public static String generateMessage(List<PostInstallScript__c> postInstallScripts) {
        String output = '';
        for(PostInstallScript__c postInstallScript : postInstallScripts ) {
            if( postInstallScript.status__c == String.valueOf(PostInstallScriptStatus.Errored) ) {
                output += 'Script ' + postInstallScript.sequenceNumber__c + '(' +  postInstallScript.description__c + ') failed @ ' + postInstallScript.ExecutionTime__c ;
            } else {
                output += 'Script ' + postInstallScript.sequenceNumber__c + '(' +  postInstallScript.description__c + ') executed @ ' + postInstallScript.ExecutionTime__c ;
            }
            output += '\n' + postInstallScript.ExecutionLog__c + '\n\n\n-----------------------------\n\n\n';
        }
        return output;
    }

    @TestVisible
    private static void sendSuccessEmail(List<PostInstallScript__c> postInstallScripts) {
        PostInstallHandler.sendMail('Post Install Script Success Email', generateMessage(postInstallScripts), PostInstallHandler.getNotificationEmailAddress() );
    }

    @TestVisible
    private static void sendErrorEmail(List<PostInstallScript__c> postInstallScripts) {
        PostInstallHandler.sendMail('Post Install Script Failure Email', generateMessage(postInstallScripts), PostInstallHandler.getNotificationEmailAddress() );
    }

}