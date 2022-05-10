/**
 * Test class for <<contactSupportPersonnelService>>
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
private class contactSupportPersonnelServiceTest {
	@TestSetup
    static void makeData(){
        Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'Support_Personnel'});
    }
	@isTest static void testPurgeCSP() {
		List<Application__c> apps = [SELECT Id FROM Application__c];
		for(Application__c app: apps)
		{
			app.Status_Program_Completed__c = Datetime.now().addYears(-1);
			app.Status_Program_Completed__c = app.Status_Program_Completed__c.addDays(-10);
		}
		Integer startingCSPCount = [SELECT Count() FROM Contact_Support_Personnel__c];
		Database.update(apps);
		Test.startTest();
		contactSupportPersonnelService.purgeCSP();
		Test.stopTest();

		Integer endingCSPCount = [SELECT Count() FROM Contact_Support_Personnel__c];
		system.assertNotEquals(startingCSPCount, endingCSPCount);
	}

	@isTest static void testDuplicatePurge() {
		Map<Id, Contact> contacts = new Map<Id,Contact>([SELECT Id FROM Contact]);
		Test.startTest();
		system.enqueueJob(new contactSupportPersonnelService(contacts.keySet()));
		Test.stopTest();
	}
}