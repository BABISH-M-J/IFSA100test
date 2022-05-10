/**
 * Unit tests for <<applicationLogACallController>>
 */
// ApexDoc updated 1/25/2021 Brock Barlow
@isTest
private class applicationLogACallControllerTest {
	/**
	 * Tests an instance of <<applicationLogACallController>> using all of the test applications and creates a Task and TaskRelation records
	 */
	@isTest static void testInstanceAndSave() 
	{
		Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection();

		List<Application__c> apps = [SELECT Id, Applicant__c FROM Application__c];

		Test.startTest();
		
		// Instantiate controller
		ApexPages.StandardSetController std = new ApexPages.StandardSetController(apps);
		std.setSelected(apps);
		applicationLogACallController ext = new applicationLogACallController(std);

		ext.t.Description = 'Unit Test Task';
		// Run save method
		ext.save();

		Test.stopTest();
		List<TaskRelation> results = [SELECT Id, RelationId, TaskId FROM TaskRelation WHERE TaskId =: ext.t.Id];
		// There are three applications generate by apexMockDataUtility but two are for the same applicant.
		// So we are only expecting two task to be created
		system.assertEquals(apps.size()-1, results.size());
	}
	
}