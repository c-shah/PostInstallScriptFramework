/**
 * Created by cshah on 5/30/2017.
 */

public without sharing class PostInstallScript2 extends PostInstallScriptTemplate {

    private String executionLog;

    public override void executeScript(Database.BatchableContext bc, List<SObject> sObjects) {
        System.debug('PostInstallScript2 : execute : hoping to get executed only once ');
        executionLog  = 'script 1 done. ';
    }

    public override Integer getSequenceNumber() {
        System.debug('PostInstallScript2 : getSequenceNumber ');
        return 2;
    }

    public override String getExecutionLog() {
        System.debug('PostInstallScript2 : getExecutionLog ');
        return executionLog;
    }

    public override String getDescription() {
        System.debug('PostInstallScript2 : getDescription ');
        return 'Script 1 Description ';
    }
}