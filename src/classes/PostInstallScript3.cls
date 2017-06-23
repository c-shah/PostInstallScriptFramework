/**
 * Created by cshah on 5/30/2017.
 */

public without sharing class PostInstallScript3 extends PostInstallScriptTemplate {

    private String executionLog;
    private Integer processedCount = 0;

    public override void executeScript(Database.BatchableContext bc, List<SObject> sObjects) {
        System.debug('PostInstallScript3 : execute : hoping to get executed only once ');
        executionLog  = 'script 3 done. ';
        processedCount += sObjects.size();
    }

    public override Integer getSequenceNumber() {
        System.debug('PostInstallScript3 : getSequenceNumber ');
        return 3;
    }

    public override String getExecutionLog() {
        System.debug('PostInstallScript3 : getExecutionLog ');
        executionLog = ' Processed ' + processedCount + ' records ';
        return executionLog;
    }

    public override String getDescription() {
        System.debug('PostInstallScript3 : getDescription ');
        return 'Script 3 Description ';
    }

    public override Integer getBatchSize() {
        System.debug('PostInstallScript3 : getBatchSize ');
        return 1;
    }

    public override Database.QueryLocator startScript(Database.BatchableContext bc) {
        System.debug('PostInstallScript3 : startScript ');
        return Database.getQueryLocator('select id, name from account limit 201');
    }

    public override void  finishScript(Database.BatchableContext bc) {
        System.debug('PostInstallScript3 : finishScript ');
    }

}