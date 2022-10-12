/**
 * Unit Tests for <<customAccountController>>
 * THE CUSTOM PORTAL IS POWERD BY THE CATALOG STUDENT PORTAL SO THAT EFFORTS ARE NOT DUPLICATED AS OF SUMMER 2020.
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
public without sharing class customAccountControllerTest 
{
	public static testMethod void testInstance()
  	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		Application__c application = (Application__c) testInfo.get('studentApplication');
		Program__c program = (Program__c) testInfo.get('program');
		program.Category__c = 'Custom';
		program.Custom_Program_Home_Instituiton_Account__c = testInfo.get('institutionAccount1').Id;
		database.update(program);
		User studentUser = (User) testInfo.get('studentUser');
		
		test.startTest();
		System.runAs(studentUser)
		{
			customAccountController controller = new customAccountController();
			controller.viewModel.paymentAmount ='6';
			//controller.doDML = true;
			PageReference reference = controller.validateAccess();
			reference = controller.payNow();
		}

		List<studentAccountAppLineItemViewModel> listVM2 = new List<studentAccountAppLineItemViewModel>();
		studentAccountAppLineItemViewModel vm2 = new studentAccountAppLineItemViewModel();
		vm2.amount = 100;
		vm2.description = ' ';
		vm2.notes = ' ';
		vm2.type = ' ';
		listVM2.add(vm2);
		studentAccountAppViewModel vm1 = new studentAccountAppViewModel();
		vm1.applicationBalance = 100;
		vm1.applicationName = 'test vm';
		vm1.lineItems = listVM2;
		test.stopTest();
  }
}