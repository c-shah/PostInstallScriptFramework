@isTest
public with sharing class zzPostInstallHandler {
	@isTest
	public static void testPostInstaller() {
		PostInstallHandler postInstallHandler = new PostInstallHandler();
		Test.testInstall(postInstallHandler, null);		
		Test.testInstall(postInstallHandler, new Version(1, 0), true);
	}
}