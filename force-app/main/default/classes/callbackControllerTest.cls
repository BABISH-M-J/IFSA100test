/**
 * Unit tests for <<callbackController>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
public with sharing class callbackControllerTest
{

	// public static testMethod void testInstance()
	// {
	// 	try
	// 	{
	// 		Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection();

	// 		Home_Institution__c homeInstitution = (Home_Institution__c) testData.get('homeInstitution1');

	// 		Account studentAcct = apexMockDataUtility.createAccount('Test2');
	// 		Contact studentCtc = apexMockDataUtility.createContact('Test4', studentAcct.Id);
	// 		studentCtc.Home_Institution__c = homeInstitution.Id;
	// 		Test.startTest();
	// 		Database.update(studentCtc);
	// 		User studentUsr = apexMockDataUtility.createUser(studentCtc.Id);
			
	// 		Application__c studentApplication = apexMockDataUtility.createApplication(studentCtc.Id);
	// 		Database.update(studentApplication);
			
	// 		studentCtc.Active_Application__c = studentApplication.Id;
	// 		Database.update(studentCtc);
			
	// 		Application_Item__c appItem = apexMockDataUtility.createApplicationItem(studentApplication.Id);
	// 		Application_Line_Item__c appLineItem = apexMockDataUtility.createApplicationLineItem(studentApplication.Id);
			
	// 		System.runAs(studentUsr)
	// 		{
	// 		callbackController controller = new callbackController();
			
	// 		}
	// 		Test.stopTest();
	// 	}
	// 	catch(Exception e)
	// 	{}
	// }
	//// added by powerfluence based on Clayton req 03/29/2022 starts
	
	@isTest 

 static void salesInvoiceTest() 
 {
	 try{
	
	Test.startTest();
	
	Account studentAcct = apexMockDataUtility.createAccount('Test2'/*,homeInstitution.Id*/);
	Contact studentCtc = apexMockDataUtility.createContact('Test4', studentAcct.Id);
	system.debug(studentCtc.Id);
	User studentUsr = apexMockDataUtility.createUser(studentCtc.Id);
	system.runAs(new User(Id = UserInfo.getUserId()))
	{
		
		Database.Upsert(studentUsr);
	}
	Application__c studentApplication = apexMockDataUtility.createApplication(studentCtc.Id);
	
	System.runAs(studentUsr)
	{
		callbackController controller = new callbackController();
		controller.createCashEntry();
	}
		Test.stopTest();
	}
	catch(DmlException e){}


	         
	}  

}
// added by powerfluence based on Clayton req 03/29/2022 ends