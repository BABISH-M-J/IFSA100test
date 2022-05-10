/**
 * Unit tests for <<housingAssignmentControllerExtension>>
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
private class housingAssignmentControllerExtensionTest {
	
	@isTest static void testInstance() {
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		
        Application__c studentApplication = (Application__c) testInfo.get('studentApplication');        
        Housing_Assignment__c housingAssignment = (Housing_Assignment__c) testInfo.get('housingAssignment');
        
        Test.startTest();
        
			ApexPages.StandardController sc = new ApexPages.StandardController(housingAssignment);
			housingAssignmentControllerExtension controller = new housingAssignmentControllerExtension(sc);	

		Test.stopTest();
	}
}