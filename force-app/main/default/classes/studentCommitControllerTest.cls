@isTest
public without sharing class studentCommitControllerTest
{
	/* public static testMethod void testInstance()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		User studentUser = (User) testInfo.get('studentUser');
		Application__c app = (Application__c) testInfo.get('studentApplication');
		Contact studentContact = (Contact) testInfo.get('studentContact');
        Test.startTest();
        system.runAs(studentUser)
        {
			// Test Ready to Submit
        	app.Status__c = 'Ready To Submit';
        	database.update(app);
        	
			studentCommitController controller = new studentCommitController();
			PageReference reference = controller.validateAccess();

			app.Program_Term__c = testInfo.get('programOption1').Id;
			database.update(app);

			Boolean hasPostAcceptance = false;
			for(studentApplyItemViewModel appItem: controller.viewModel.appItems)
			{
				if(appItem.phase == 'Post-Acceptance')
				{
					hasPostAcceptance = true;
				}
			}
			
			system.assert(hasPostAcceptance == false, '"Ready to Submit" applications should not see "Post-Acceptance" items');

			app.Program_Term__c = testInfo.get('programOption1').Id;
			app.Status_Contract_Signed__c = Datetime.Now();
			database.update(app);
			Application_Item__c ai = new Application_Item__c(
				Name = 'Scholarship',
				Phase__c = 'Optional',
				Status__c = 'Started', 
				Application__c = app.Id, 
				RecordTypeId = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Download-Upload').getRecordTypeId(),
				Content_Link_Old__c = [SELECT URL__c FROM Static_Link_URL__mdt WHERE DeveloperName = 'Scholarship_Link'].get(0).URL__c
			);
			database.insert(ai);

			controller = new studentCommitController();
			reference = controller.validateAccess();
		}
		Test.stopTest();
	}
	public static testMethod void testInstance2()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		User studentUser = (User) testInfo.get('studentUser');
		Application__c app = (Application__c) testInfo.get('studentApplication');
		Contact studentContact = (Contact) testInfo.get('studentContact');
        Test.startTest();
        system.runAs(studentUser)
        {
			studentCommitController controller = new studentCommitController();
			PageReference reference = controller.validateAccess();
			// Test Submited
			app.Status__c = 'Submitted';
        	database.update(app);
        	
        	controller = new studentCommitController();
			reference = controller.validateAccess();
			

			Boolean hasPostAcceptance = false;
			for(studentApplyItemViewModel appItem: controller.viewModel.appItems)
			{
				if(appItem.phase == 'Post-Acceptance')
				{
					hasPostAcceptance = true;
				}
			}
			system.assert(hasPostAcceptance == false, '"Submitted" applications should not see "Post-Acceptance" items');
		}
	}
	public static testMethod void testInstance3()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		User studentUser = (User) testInfo.get('studentUser');
		Application__c app = (Application__c) testInfo.get('studentApplication');
		Contact studentContact = (Contact) testInfo.get('studentContact');
        Test.startTest();
        system.runAs(studentUser)
        {
			// Test Accepted
			app.Status__c = 'Accepted';
			app.Program_Approval_Completed_By__c = testInfo.get('advisorContact1').Id;
        	database.update(app);

        	studentCommitController controller = new studentCommitController();
			PageReference reference = controller.validateAccess();

			Boolean hasPostAcceptance = false;
			for(studentApplyItemViewModel appItem: controller.viewModel.appItems)
			{
				if(appItem.phase == 'Post-Acceptance')
				{
					hasPostAcceptance = true;
				}
			}			
			system.assert(hasPostAcceptance == true, '"Accepted" applications should see "Post-Acceptance" items');
			studentContact.Active_Application__c = null;
        	database.update(studentContact);

        	controller = new studentCommitController();
			reference = controller.validateAccess();
        }
        Test.stopTest();
	}
	
	public static testMethod void testInstanceDroppedAndRejectedApp()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		Test.startTest();
		User studentUser = (User) testInfo.get('studentUser');
		Contact studentContact = (Contact) testInfo.get('studentContact');
		Application__c app = (Application__c) testInfo.get('studentApplication');
        system.runAs(studentUser)
        {
        	app.Status__c = 'Rejected';
        	database.update(app);
        	
        	studentCommitController controller = new studentCommitController();
			PageReference reference = controller.validateAccess();

			app.Status__c = 'Dropped';
        	database.update(app);
        	
        	controller = new studentCommitController();
			reference = controller.validateAccess();

			// Test with null program term
			studentContact.Active_Application__c = app.Id;
			app.Status__c = 'Registered';
			app.Program_Term__c = null;
			database.update(new list<SObject>{app, studentContact});

			controller = new studentCommitController();
			reference = controller.validateAccess();
        }
        Test.stopTest();
	}	
	public static testMethod void testCloseCompletionNotification()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		User studentUser = (User) testInfo.get('studentUser');
		Application__c application = (Application__c) testInfo.get('studentApplication');
		Application_Item__c appItem = (Application_Item__c) testInfo.get('applicationItem');
		test.startTest();
		studentCommitController.closeCompletionNotification(String.valueOf(application.Id));
		test.stopTest();
	} */
}