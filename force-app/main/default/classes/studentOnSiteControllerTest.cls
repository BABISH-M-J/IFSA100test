/**
 * @description Test class for studentOnSiteController class for the on 
 * site page of the student portal
 * @author Brock Barlow
 */
@isTest
public without sharing class studentOnSiteControllerTest 
{
	private static Map<String, SObject> testInfo = new Map<String, SObject>();			
    
	public static testMethod void testInstance()
	{
		if(testInfo == new Map<String, SObject>())
    	{
    		testInfo = apexMockDataUtility.createIfsaDataCollection();	
    	}
    	Test.startTest();
		User studentUser = (User) testInfo.get('studentUser');		
		System.runAs(studentUser)
		{			
			studentOnSiteController controller = new studentOnSiteController();
			PageReference reference = controller.validateAccess();

			Application__c studentApplication = (Application__c) testInfo.get('studentApplication');        
			Housing_Assignment__c housingAssignment = (Housing_Assignment__c) testInfo.get('housingAssignment');
			Housing_Option__c housingOption = (Housing_Option__c) testInfo.get('housingOption');
			
			studentApplication.Housing_Assignment__c = housingAssignment.Id;
			studentApplication.Status__c = 'Contract Signed';
			Database.update(studentApplication);

			controller = new studentOnSiteController();
			reference = controller.validateAccess();

			housingAssignment.Street_2__c = 'Apt A';
			Database.update(housingAssignment);

			controller = new studentOnSiteController();
			reference = controller.validateAccess();
		}
		Test.stopTest();
	}
}