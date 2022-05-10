/**
 * Test class for the advisor register controller.
 * @author Cameron Ames
 */
// ApexDoc updated 1/23/2021 Brock Barlow
@isTest
public with sharing class advisorRegisterControllerTest
{
	/**
	 * Test instance methods
	 */
	public static testMethod void testInstance()
	{
		Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection();

		Home_Institution__c homeInstitution = (Home_Institution__c) testData.get('homeInstitution1');
		Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		
		advisorRegisterController controller = new advisorRegisterController();
//modified by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
		// controller.viewModel.password = 'asdfasdf1';
		// controller.viewModel.confirmPassword = 'asdfasf1';
		controller.viewModel.password = 'Adfasdf@1';
		controller.viewModel.confirmPassword = 'Adfasdf@1';
//modified by PowerFluence req_dt:03/29/2022 ref email from Clayton ends
		controller.viewModel.email = 'dev@ifsa-butler.org.test';
		controller.viewModel.firstName = 'Unit';
		controller.viewModel.lastName = 'Test';
//added by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
		controller.viewModel.title = 'Test';
		controller.viewModel.homeInstitutionName = homeInstitution.name;
		controller.viewModel.customMessages = 'Test123';
		
//added by PowerFluence req_dt:03/29/2022 ref email from Clayton ends

		controller.viewModel.institutionId = homeInstitution.Id;
		
		//advisorRegisterController arc = new advisorRegisterController();
		String result = advisorRegisterController.register(JSON.serialize(controller.viewModel));

		//PageReference ref =arc.validateAccess();
		//PageReference ref1 =arc.registerUser();
		
		String error = 'ERROR: Sorry, ';
		system.assertEquals(true, result.startsWith(error));
	
	}

	/**
	 * test static method search home institution
	 */
	public static testMethod void testSearchHomeInstitution()
	{
		List<Home_Institution__c> his = advisorRegisterController.searchHomeInstitution('Butler University');
	}

}