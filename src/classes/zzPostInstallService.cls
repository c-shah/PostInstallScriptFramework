/**
 * Created by cshah on 6/5/2017.
 */

@isTest
public class zzPostInstallService {

    @testSetup
    public static void testSetup() {
    }


    @isTest
    public static void testInstance() {
        PostInstallService postInstallServiceInstance = PostInstallService.getInstance();
        System.assertNotEquals(postInstallServiceInstance, null, 'Post Install Instance is null');
    }

    @isTest
    public static void testDebug() {
        PostInstallService.debug('test');
        /** Hard to do System assert on debug statement **/
    }

    @isTest
    public static void testError() {
        PostInstallService.error('test');
        /** Hard to do System assert on debug statement **/
    }

    @isTest
    public static void testStartService() {
        PostInstallService postInstallServiceInstance = PostInstallService.getInstance();
        Test.startTest();
        postInstallServiceInstance.startService();
        Test.stopTest();
        Integer postInstallCount = [select count() from PostInstallScript__c limit 1];
        System.assertEquals(postInstallCount, 1,'Post Install Script not inserted.');
        PostInstallScript__c postInstallScript = [ select status__c from PostInstallScript__c where className__c = 'PostInstallScript1' ];
        System.assertEquals( postInstallScript.status__c, String.valueOf( PostInstallService.PostInstallScriptStatus.Completed ) );
    }

    @isTest
    public static void testRetryService() {
        PostInstallService postInstallServiceInstance = PostInstallService.getInstance();
        postInstallServiceInstance.startService();
        PostInstallScript__c postInstallScript = [ select status__c from PostInstallScript__c where className__c = 'PostInstallScript1' ];
        postInstallScript.status__c = String.valueOf( PostInstallService.PostInstallScriptStatus.Errored );
        update postInstallScript;
        Test.startTest();
        postInstallServiceInstance.retry();
        Test.stopTest();
        postInstallScript = [ select status__c from PostInstallScript__c where className__c = 'PostInstallScript1' ];
        System.assertEquals( postInstallScript.status__c, String.valueOf( PostInstallService.PostInstallScriptStatus.Completed ) );
    }

    @isTest
    public static void testErrorEmail() {
        List<PostInstallScript__c> postInstallScripts = [ select status__c from PostInstallScript__c limit 2 ];
        PostInstallService.sendErrorEmail(postInstallScripts);
    }

}