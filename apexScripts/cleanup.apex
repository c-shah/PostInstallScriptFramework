List<PostInstallScript__c> scripts = [ select id from PostInstallScript__c limit 100 ];
delete scripts;