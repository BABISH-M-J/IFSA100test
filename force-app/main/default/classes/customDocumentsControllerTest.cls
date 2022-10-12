/**
 * Test class for the custom documents controller
 * THE CUSTOM PORTAL IS POWERD BY THE CATALOG STUDENT PORTAL SO THAT EFFORTS ARE NOT DUPLICATED AS OF SUMMER 2020.
 * @author Cameron Ames
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
public without sharing class customDocumentsControllerTest
{
	/**
	 * @description Test the instance methods
	 */
	public static testMethod void testInstance()
	{
		try
		{
			Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
			User studentUser = (User) testInfo.get('studentUser');
			Program__c program = (Program__c) testInfo.get('program');
			program.Category__c = 'Custom';
			program.Custom_Program_Home_Instituiton_Account__c = testInfo.get('institutionAccount1').Id;
			test.startTest();
			database.update(program);
			
			System.runAs(studentUser)
			{
				
				customDocumentsController controller = new customDocumentsController();
				PageReference reference = controller.validateAccess();
				System.assertEquals(null, reference, 'The PageReference should have been null.');
				
			}
			test.stopTest();
		}
		catch(Exception e)
		{
			apexErrorUtility.debug(LoggingLevel.ERROR, e.getMessage());
			System.assert(false, 'An Exception was thrown.');
		}
	}
	// TEST NOT NEEDED
	/*
	public static testMethod void testGetSubmitApplicationItemDetails()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		User studentUser = (User) testInfo.get('studentUser');
		Application_Item__c appItem = (Application_Item__c) testInfo.get('applicationItem');
		test.startTest();
		studentApplyItemDetailsViewModel viewModel = portalRemotingMethods.getApplicationItemDetails(appItem.Id);

		String jsonData = JSON.serialize(viewModel);

		Boolean didRun = customDocumentsController.submitApplicationItem(jsonData, '', '', '');
		System.assertEquals(true, didRun);
		test.stopTest();
	}
	// TEST NOT NEEDED
	public static testMethod void testSubmitRecommender()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		User studentUser = (User) testInfo.get('studentUser');
		Application_Item__c appItem = (Application_Item__c) testInfo.get('applicationItem');
		test.startTest();
		Boolean isSuccess = customDocumentsController.submitRecommender('test', 'test@test.com', appItem.Id);
		System.assertEquals(true, isSuccess);
		test.stopTest();
	}
	// TEST NOT NEEDED
	public static testMethod void testGetTravelDetails()
	{
		List<Flight__c> testList = customDocumentsController.getTravelDetails('asdf');
	}
	*/
	public static testMethod void testCloseCompletionNotification()
	{		
		Application__c application = (Application__c) apexMockDataUtility.createIfsaDataCollection().get('studentApplication');
		test.startTest();
		customDocumentsController.closeCompletionNotification(String.valueOf(application.Id));
		test.stopTest();
	}
}