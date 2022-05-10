@isTest
public with sharing class studentRecommendationControllerTest
{
	public static testMethod void testInstance()
	{
		Account acct = new Account();
		acct.Name = 'testAccount';
		Database.insert(acct);
		
		Contact ctc = new Contact();
		ctc.LastName = 'TEst';
		ctc.Email = 'asdf@asdf.com';
		ctc.AccountId = acct.Id;
		Database.insert(ctc);

		Integer rand = Math.round(Math.random()*999);

	    User testUser = new User();
	    testUser.FirstName = 'Unit';
	    testUser.LastName = 'Test';
	    testUser.Alias = rand + 'utest';
	    testUser.CommunityNickname = rand + 'utest';
	    testUser.Email = rand + 'utest@utest.test';
	    testUser.Username = rand + 'utest@utest.test.ifsa';
	    testUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: 'IFSA Student User'].Id;
	    testUser.contactId = ctc.Id;
	    testUser.TimeZoneSidKey = 'GMT';
	    testUser.LocaleSidKey = 'en_US';
	    testUser.EmailEncodingKey = 'ISO-8859-1';
	    testUser.LanguageLocaleKey = 'en_US';
	    testUser.UserPermissionsMobileUser = false;
		
		Application__c application = apexMockDataUtility.createApplication(ctc.Id);
		Application_Item__c appItem = apexMockDataUtility.createApplicationItem(application.ID);
		Recommendation__c rec = new Recommendation__c();

		rec.Name = 'Test';
		rec.Email_Address__c = 'Test@test.net';
		rec.Recommender_Name__c = 'test';
		rec.Application_Item__c = appItem.Id;
		Database.insert(rec);
		
		Test.setCurrentPageReference(new PageReference('SP_Recommendation'));
		System.currentPageReference().getParameters().put('recommender', rec.Id);
		System.currentPageReference().getParameters().put('app', appItem.Id);
		
		System.runAs(testUser)
		{
			studentRecommendationController controller = new studentRecommendationController();
			controller.viewModel.content = 'asdfasdf';
			controller.viewModel.university = 'asdf u';
			controller.viewModel.phone = '1111111111';
			controller.viewModel.recommendationDepartment = 'asdf';
			controller.viewModel.recommendationTitle = 'asdf';
			controller.validateAccess();
			controller.submitRecommendation();
			//added by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
			String testSubmit = studentRecommendationController.submitRecommendation(JSON.serialize(controller.viewModel));
			testSubmit = studentRecommendationController.submitRecommendation(null);
			studentRecommendationViewModel recommendationViewModel = new studentRecommendationViewModel();
			String testVM1 = recommendationViewModel.getSerializedViewModel();
			String testVM2 = recommendationViewModel.getEscapedSerializedViewModel();
			//added by PowerFluence req_dt:03/29/2022 ref email from Clayton ends
		}
	}
}