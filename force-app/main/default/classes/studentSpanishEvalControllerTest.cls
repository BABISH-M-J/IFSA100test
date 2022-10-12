@isTest
public with sharing class studentSpanishEvalControllerTest
{
	public static testMethod void testInstance()
	{
		// added by powerfluence based on Clayton req 03/29/2022 starts
		Test.startTest();
		UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'President' Limit 1];
		User adminUser = [Select Id, UserRoleId From User Where Profile.Name = 'System Administrator' AND IsActive = true Limit 1];
		adminUser.UserRoleId = userRole.Id;
		update adminUser;
		System.runAs(adminUser){
			Account a = new Account(Name='Test Account Name');
			insert a;
		// added by powerfluence based on Clayton req 03/29/2022 starts
		// modified by powerfluence based on Clayton req 03/29/2022 starts
			Contact ctc = new Contact();
			ctc.LastName = 'TEst';
			ctc.Email = 'asdf@asdf.com';
			ctc.AccountId = a.id;
			Database.insert(ctc);
			User studUser = apexMockDataUtility.createUser(ctc.Id);
			Database.insert(studUser);
			Application__c application = apexMockDataUtility.createApplication(ctc.Id);
			Application_Item__c appItem = apexMockDataUtility.createApplicationItem(application.ID);
			
			Test.setCurrentPageReference(new PageReference('SP_SpanishEvaluation'));
			System.currentPageReference().getParameters().put('appItem', appItem.Id);
			System.currentPageReference().getParameters().put('app', application.Id);
			
			studentSpanishEvalController controller = new studentSpanishEvalController();
			Pagereference testSubmitRef = controller.submitEvaluation();
			Pagereference testAuthRef = controller.authorize();
			Test.stopTest();
			// modified by powerfluence based on Clayton req 03/29/2022 ends
		}
	}
}