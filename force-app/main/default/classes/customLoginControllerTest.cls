/**
 * @description Test Class for the custom login controller.
 * @author Cameron Ames
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
public without sharing class customLoginControllerTest
{
	/**
	 * @description Test the instance methods of this class
	 */
	public static testMethod void testInstance()
	{
		Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection();

		Home_Institution__c homeInstitution = (Home_Institution__c) testData.get('homeInstitution1');
		Account homeInstitutionAccount = apexMockDataUtility.createAccount('Test', homeInstitution.Id);
		
		Test.setCurrentPageReference(new PageReference('Page.CP_Splash'));
		System.currentPageReference().getParameters().put('id', null);
		customLoginController controller = new customLoginController();

		System.currentPageReference().getParameters().put('id', homeInstitution.Id);
		controller = new customLoginController();

		controller.login();
	}
}