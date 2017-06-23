/**
 * Created by cshah on 6/3/2017.
 */

public with sharing class vfPostInstallController {

    public List<PostInstallScript__c> postInstallScripts { get; set; }
    public Boolean displayLogMessage { get; set; }
    public Boolean retrySubmitted { get; set; }
    public PostInstallScript__c currentPostInstallScript { get; set; }

    public vfPostInstallController() {
        System.debug(' vfPostInstallController ');
        postInstallScripts = [ select ClassName__c, Description__c, ExecutionLog__c, ExecutionTime__c, NotificationSentFlag__c, SequenceNumber__c, Status__c, createddate from PostInstallScript__c order by SequenceNumber__c desc limit 20 ];
    }

    public boolean getRetryEnabled() {
        System.debug(' getRetryEnabled ');
        Integer count = [ select count() from PostInstallScript__c where Status__c != 'Completed' ];
        System.debug(' count ' + count );
        if( count > 0 ) {
            return true;
        } else {
            count = [ select count() from PostInstallScript__c ];
            if( count == 0 ) {
                return true;
            } else {
                return false;
            }
        }
    }

    public PageReference closePopup() {
        displayLogMessage = false;
        return null;
    }

    public PageReference retry() {
        ServiceFactory.getInstance().getPostInstallService().startService();
        try {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info, 'Retry Submitted.' ));
            retrySubmitted = true;
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage() ));
        }
        return null;
    }

    public PageReference displayLogMessagedDetail() {
        String id = Apexpages.currentPage().getParameters().get('id');
        try {
            currentPostInstallScript = [ select ClassName__c, Description__c, ExecutionLog__c, ExecutionTime__c, NotificationSentFlag__c, SequenceNumber__c, Status__c, createddate from PostInstallScript__c where id = :id ];
            displayLogMessage = true;
            System.debug(' displayLogMessage ' + displayLogMessage + ' currentPostInstallScript ' + currentPostInstallScript );
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage() ));
        }
        return null;
    }

}