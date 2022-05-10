/**
 * Test class for the application item wrapper class
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public with sharing class ifsaApplicationItemWrapperTest
{
	/**
	 * @description Test the instance methods of the class
	 */
	public static testMethod void testInstance()
	{
		Map<String, sObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		
		ifsaApplicationWrapper appWrapper = new ifsaApplicationWrapper((Application__c) testInfo.get('studentApplication'));
		test.startTest();
		List<Application_Item__c> appItems = appWrapper.populateApplicationItems();
		
		//Test constructor with instance
		ifsaApplicationItemWrapper appItemWrapper = new ifsaApplicationItemWrapper(appItems.get(0));
		
		//Test constructor with Id
		appItemWrapper = new ifsaApplicationItemWrapper(appItems.get(0).Id);
		
		studentApplyItemViewModel viewModel = appItemWrapper.populateViewModel(new studentApplyItemViewModel());
		System.assertEquals('Incomplete', viewModel.status, 'The application item should have passed the value incomplete to the view model status.');
		
		customDocumentsViewModel viewModel2 = appItemWrapper.populateViewModel(new customDocumentsViewModel());
		System.assertNotEquals(null, viewModel2.appItems, 'The application Item LIST should not be null.');
		
		studentApplyItemDetailsViewModel detailedViewModel = appItemWrapper.populateViewModel(new studentApplyItemDetailsViewModel());
		System.assertEquals('Incomplete', viewModel.status, 'The application item should have passed the value incomplete to the detailed view model status.');
		
		//Test the getters and setters
		Id testId = appItemWrapper.getId();
		testId = appItemWrapper.getHousingOptionId();
		testId = appItemWrapper.getProgramTermId();
		testId = appItemWrapper.getApplicantId();
		testId = appItemWrapper.getApplicationId();
		
		String testString = appItemWrapper.getRecordTypeName();
		
		System.assert(appItemWrapper.saveInformation(detailedViewModel), 'The viewModel information failed to save.');
		test.stopTest();
	}
}