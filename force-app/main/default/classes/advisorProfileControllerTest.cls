/**
 * @description Test class for the advisor profile controller.
 * @author Cameron Ames
 */
// ApexDoc updated 1/22/2021 Brock Barlow
@isTest
public without sharing class advisorProfileControllerTest
{
	/**
	 * @description Test the instance methods.
	 */
	/*
	public static testMethod void testInstance()
	{
		Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection();

		Home_Institution__c homeInstitution = (Home_Institution__c) testData.get('homeInstitution1');
		Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);
		User advisorUser = apexMockDataUtility.createAdvisor(ctc.Id);

		System.runAs(advisorUser)
		{
			advisorProfileController controller = new advisorProfileController();
			PageReference reference = controller.validateAccess();

			controller.viewModel.advisorEmail = 'test@test.net';
			String jsonObject = controller.viewModel.getSerializedViewModel();
			System.assert(advisorProfileController.saveData(jsonObject), 'The controller failed to save the data.');
			System.assert(!advisorProfileController.saveData(null), 'The controller successfully saved a null String.');
			
			try
			{
				advisorProfileController.saveData('{asdf}');
				System.assert(false, 'There should have been an Exception thrown for an invalid JSON String.');
			}
			catch(Exception e)
			{
				System.assert(true, 'We are expecting an Exception because of an invalid JSON String.');
			}
		}
	}
	*/
}