/**
 * Unit tests for <<divertAppExtension>>
 * @author Brock Barlow
 */
// ApexDoc updated 2/1/2021 Brock Barlow
@isTest
private class divertAppExtensionTest {
	
	@isTest static void testInstanceAndSave() {
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection(new Set<String>());

		Application__c app = (Application__c) testInfo.get('studentApplication');
        Test.startTest();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(app);
		divertAppExtension controller = new divertAppExtension(sc);

		Application__c newApp = controller.newApp;
		Application__c oldApp = [SELECT Id, Program_Term__c FROM Application__c WHERE Id =: controller.oldApp.Id];
		newApp.Program_Term__c = [SELECT Id FROM Program_Term__c WHERE Id !=: oldApp.Program_Term__c].get(0).Id;
		controller.newApp = newApp;
		controller.saveNewApp();

        Test.stopTest();
	}
	
}