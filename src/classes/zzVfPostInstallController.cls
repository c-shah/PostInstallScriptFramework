/**
 * Created by cshah on 6/5/2017.
 */

@isTest
public class zzVfPostInstallController {

    @testSetup
    public static void testSetup() {
    }

    @isTest
    public static void testVfPostInstallController() {
        vfPostInstallController vfPostInstallControllerInstance = new vfPostInstallController();
    }

    @isTest
    public static void testRetryEnabledTrue() {
        vfPostInstallController vfPostInstallControllerInstance = new vfPostInstallController();
        PostInstallService postInstallServiceInstance = PostInstallService.getInstance();
        postInstallServiceInstance.startService();
        PostInstallScript__c postInstallScript = [ select status__c from PostInstallScript__c where className__c = 'PostInstallScript1' ];
        postInstallScript.status__c = String.valueOf( PostInstallService.PostInstallScriptStatus.Errored );
        update postInstallScript;
        Test.startTest();
        boolean retryEnabled = vfPostInstallControllerInstance.getRetryEnabled();
        Test.stopTest();
        System.assertEquals( retryEnabled, true );
    }

    @isTest
    public static void testRetryEnabledFalse() {
        Test.startTest();
        vfPostInstallController vfPostInstallControllerInstance = new vfPostInstallController();
        PostInstallService postInstallServiceInstance = PostInstallService.getInstance();
        postInstallServiceInstance.startService();
        Test.stopTest();
        boolean retryEnabled = vfPostInstallControllerInstance.getRetryEnabled();
        System.assertEquals( retryEnabled, false );
    }

    @isTest
    public static void testRetry() {
        Test.startTest();
        vfPostInstallController vfPostInstallControllerInstance = new vfPostInstallController();
        PostInstallService postInstallServiceInstance = PostInstallService.getInstance();
        postInstallServiceInstance.startService();
        PostInstallScript__c postInstallScript = [ select status__c from PostInstallScript__c where className__c = 'PostInstallScript1' ];
        postInstallScript.status__c = String.valueOf( PostInstallService.PostInstallScriptStatus.Errored );
        update postInstallScript;
        vfPostInstallControllerInstance.retry();
        Test.stopTest();
        postInstallScript = [ select status__c from PostInstallScript__c where className__c = 'PostInstallScript1' ];
        System.assertEquals( postInstallScript.status__c, String.valueOf( PostInstallService.PostInstallScriptStatus.Completed ) );
    }

    @isTest
    public static void testDisplayLogMessagedDetail() {
        vfPostInstallController vfPostInstallControllerInstance = new vfPostInstallController();
        PostInstallService postInstallServiceInstance = PostInstallService.getInstance();
        Test.startTest();
        postInstallServiceInstance.startService();
        Test.stopTest();
        PostInstallScript__c postInstallScript = [ select status__c from PostInstallScript__c where className__c = 'PostInstallScript1' ];
        System.currentPageReference().getParameters().put('id', postInstallScript.id );
        vfPostInstallControllerInstance.displayLogMessagedDetail();
        vfPostInstallControllerInstance.closePopup();
        System.assertEquals( vfPostInstallControllerInstance.currentPostInstallScript.id, postInstallScript.id );
    }

}