/**
 * this class handles the post installation routine
 */

global class PostInstallHandler implements InstallHandler {

    private static void debug(String input) {
        System.debug( LoggingLevel.DEBUG, input );
    }

    private static void error(String input) {
        System.debug( LoggingLevel.ERROR, input );
    }

    private static void info(String input) {
        System.debug( LoggingLevel.INFO, input );
    }

    global void onInstall(InstallContext context) {
        try {
            ServiceFactory.getInstance().getPostInstallService().startService();
        } catch(Exception e) {
            error(' PostInstallHandler : Exception ' + e );
            sendMail('Post Install Script Error ', e.getMessage() + '\n' + e.getStackTraceString() , getNotificationEmailAddress() );
        }
    }

    public static List<String> getNotificationEmailAddress() {
        List<String> toAddresses = new List<String>();
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        List<User> sysAdmins = [SELECT id, Email FROM User WHERE ProfileId = :sysAdminProfile.id];
        for( User sysAdmin : sysAdmins ) {
            toAddresses.add ( sysAdmin.Email );
        }
        return toAddresses;
    }

    public static void sendGenericErrorEmail(String errorMessage) {
        sendMail('Post Install Script Failure Email', errorMessage, getNotificationEmailAddress() );
    }

    public static void sendMail(String subject, String body, List<String> recipients) {
        try {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = recipients;
            message.optOutPolicy = 'FILTER';
            message.subject = subject;
            message.plainTextBody = body;
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                debug('The email was sent successfully . to ' + recipients + ' subject ' + subject );
            } else {
                debug('The email failed to send: ' + results[0].errors[0].message + ' to ' + recipients + ' subject ' + subject  );
            }
        } catch(Exception e) {
            error('The email failed to send: ' + ' to ' + recipients + ' subject ' + subject + ' body ' + body );
            String errorStackTrace = e.getMessage()  + '\n' + e.getStackTraceString();
            error( errorStackTrace );
        }
    }

}