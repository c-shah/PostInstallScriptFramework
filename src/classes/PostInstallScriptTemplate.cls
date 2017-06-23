/**
 * Created by cshah on 5/29/2017.
 */

/**
 * Post install script could potentiall touch multiple records that user doens't have access
 * it needs full system context
 */
public without sharing abstract class PostInstallScriptTemplate implements IPostInstallScript, Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    private static void debug(String input) {
        System.debug( LoggingLevel.DEBUG, input );
    }

    private static void error(String input) {
        System.debug( LoggingLevel.ERROR, input );
    }

    private boolean errored = false;
    private String errorStackTrace = null;

    public Database.QueryLocator start(Database.BatchableContext bc){
        debug(' PostInstallScriptTemplate : start : calling startScript of impl. ');
        try {
            return startScript(bc);
        } catch(Exception e) {
            error( e.getStackTraceString());
            errored = true;
            errorStackTrace = e.getMessage()  + '\n' + e.getStackTraceString();
            return Database.getQueryLocator('select name from apexClass where name = \'PostInstallScriptTemplate\' limit 0');
        }
    }

    public void execute(Database.BatchableContext bc, List<sObject> sObjects){
        debug(' PostInstallScriptTemplate : execute : start  ');
        if( errored == false ) {
            try {
                debug(' PostInstallScriptTemplate : execute : calling execute of impl  ');
                executeScript(bc, sObjects);
            } catch(Exception e) {
                error(' PostInstallScriptTemplate : execute : errored out  ');
                debug( e.getStackTraceString());
                errored = true;
                errorStackTrace = e.getMessage()  + '\n' + e.getStackTraceString();
            }
        }
    }

    public void finish(Database.BatchableContext bc){
        debug(' PostInstallScriptTemplate : finish : start  ');
        if( errored == false ) {
            try {
                debug(' PostInstallScriptTemplate : finish : calling finish of impl  ');
                finishScript(bc);
            } catch(Exception e) {
                error( e.getStackTraceString() );
                errored = true;
                errorStackTrace = e.getMessage()  + '\n' + e.getStackTraceString();
            }
        }
        try {
            if( errored == false ) {
                updateStateAndLog( getSequenceNumber(), PostInstallService.PostInstallScriptStatus.Completed, getExecutionLog() );
                ServiceFactory.getInstance().getPostInstallService().executeNextScript();
            } else {
                updateStateAndLog( getSequenceNumber(), PostInstallService.PostInstallScriptStatus.Errored, errorStackTrace );
                ServiceFactory.getInstance().getPostInstallService().finishService();
            }
        } catch(Exception e) {
            errored = true;
            errorStackTrace = e.getMessage()  + '\n' + e.getStackTraceString();
            updateStateAndLog( getSequenceNumber(), PostInstallService.PostInstallScriptStatus.Errored, errorStackTrace );
            ServiceFactory.getInstance().getPostInstallService().finishService();
        }
    }

    @TestVisible
    private void updateStateAndLog(Integer sequenceNumber, PostInstallService.PostInstallScriptStatus status, String executionLog) {
        PostInstallScript__C postInstallScript = [select status__c, ExecutionLog__c, ExecutionTime__c from PostInstallScript__C where SequenceNumber__c = :sequenceNumber ];
        postInstallScript.status__c = String.valueOf(status);
        postInstallScript.ExecutionLog__c = executionLog;
        postInstallScript.ExecutionTime__c = System.now();
        update postInstallScript;
    }

    /**
     * optional implementation
     */

    public virtual Database.QueryLocator startScript(Database.BatchableContext bc) {
        // this ensures it will be called once
        debug(' PostInstallScriptTemplate : startScript : impl has not implemented ');
        return Database.getQueryLocator('select name from apexClass where name = \'PostInstallScriptTemplate\' limit 1');
    }

    public virtual void finishScript(Database.BatchableContext bc) {
        // do nothing, it is just template method
        debug(' PostInstallScriptTemplate : finishScript : impl has not implemented ');
    }

    public virtual Integer getBatchSize() {
        debug(' PostInstallScriptTemplate : batchSize : impl has not implemented returning default size ');
        return 1;
    }

    /**
     * below must be implemented by implementation
     */
    /** throw exception if you error our **/
    public abstract void executeScript(Database.BatchableContext bc, List<SObject> sObjects);
    public abstract Integer getSequenceNumber();
    public abstract String getExecutionLog();
    public abstract String getDescription();
}