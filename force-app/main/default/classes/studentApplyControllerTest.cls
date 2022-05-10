@isTest
public without sharing class studentApplyControllerTest
{	
	/* @TestSetup
	static void makeData(){
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
	}

	public static testMethod void testInstance()
	{
		contactTriggerHandler.bypassTrigger = false;
		applicationTriggerHandler.bypassTrigger = false;
		BaseTriggerHandler.bypass('applicationItemTriggerHandler');
		BaseTriggerHandler.bypass('applicationRequirementTriggerHandler');

		List<Home_Institution__c> homeInstitutions = [SELECT Id FROM Home_Institution__c LIMIT 1];
		List<Account> accounts = apexMockDataUtility.createAccounts('newTest', 1);
		List<Contact> studentContacts = apexMockDataUtility.createContacts('newContacts', accounts, homeInstitutions);
		User studentUser = apexMockDataUtility.createUser(studentContacts[0].Id);
		Application__c app = apexMockDataUtility.createApplication(studentContacts[0].Id);
		Id progamOptionRTId = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option without Dates').getRecordTypeId();
		//Id studentUserProfileId = [SELECT Id FROM Profile WHERE Name =: 'IFSA Student User'].get(0).Id;
		//User studentUser = [SELECT Id FROM User WHERE profileId = :studentUserProfileId and isActive = true LIMIT 1];
		//Application__c app = [SELECT Id, Status__c, Program_Term__c FROM Application__c LIMIT 1];
		Program_Term__c programTerm = [SELECT Id FROM Program_Term__c WHERE RecordTypeId = :progamOptionRTId LIMIT 1];
        Test.startTest();
        system.runAs(studentUser)
        {
			// Test Instance
        	app.Status__c = 'Program Selected';
			app.Program_Term__c = programTerm.Id;
        	database.update(app);
        	
        	studentApplyController controller = new studentApplyController();
			PageReference reference = controller.validateAccess();

			app.Program_Term__c = programTerm.Id;
			database.update(app);

			Application_Item__c appItem = new Application_Item__c(
				Name = 'Scholarship',
				Phase__c = 'Optional',
				Status__c = 'Started', 
				Application__c = app.Id, 
				RecordTypeId = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Download-Upload').getRecordTypeId(),
				Content_Link_Old__c = [SELECT URL__c FROM Static_Link_URL__mdt WHERE DeveloperName = 'Scholarship_Link'].get(0).URL__c
			);

			database.insert(appItem);
		}
        Test.stopTest();
	}
	public static testMethod void testInstance2()
	{
		contactTriggerHandler.bypassTrigger = false;
		applicationTriggerHandler.bypassTrigger = false;
		BaseTriggerHandler.bypass('applicationItemTriggerHandler');
		BaseTriggerHandler.bypass('applicationRequirementTriggerHandler');
		
		//Id studentRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
		//Id studentUserProfileId = [SELECT Id FROM Profile WHERE Name =: 'IFSA Student User'].get(0).Id;
		//User studentUser = [SELECT Id FROM User WHERE profileId = :studentUserProfileId and isActive = true LIMIT 1];
		//Application__c app = [SELECT Id, Status__c, Program_Term__c FROM Application__c LIMIT 1];
		//Contact studentContact = [SELECT Id, Active_Application__c FROM Contact WHERE recordTypeId = :studentRecordType LIMIT 1];
        List<Home_Institution__c> homeInstitutions = [SELECT Id FROM Home_Institution__c LIMIT 1];
		List<Account> accounts = apexMockDataUtility.createAccounts('newTest', 1);
		List<Contact> studentContacts = apexMockDataUtility.createContacts('newContacts', accounts, homeInstitutions);
		Contact studentContact = studentContacts[0];
		User studentUser = apexMockDataUtility.createUser(studentContact.Id);
		Application__c app = [SELECT Id FROM Application__c].get(0);
        app.Applicant__c = studentContact.Id;
    	database.update(app);

		studentContact.Active_Application__c = app.Id;
		Test.startTest();
		database.update(studentContact);		
        system.runAs(studentUser)
        {

			studentApplyController controller = new studentApplyController();
			PageReference reference = controller.validateAccess();
			// Test with no active application
			studentContact.Active_Application__c = null;
        	database.update(studentContact);

        	controller = new studentApplyController();
			reference = controller.validateAccess();
			// Test with null program term
			studentContact.Active_Application__c = app.Id;
			app.Status__c = 'Registered';
			app.Program_Term__c = null;
			database.update(new list<SObject>{app, studentContact});

			controller = new studentApplyController();
			reference = controller.validateAccess();
        }
        Test.stopTest();
	}
	public static testMethod void testInstanceDroppedAndRejectedApp()
	{
		contactTriggerHandler.bypassTrigger = false;
		applicationTriggerHandler.bypassTrigger = false;
		BaseTriggerHandler.bypass('applicationItemTriggerHandler');
		BaseTriggerHandler.bypass('applicationRequirementTriggerHandler');
		
		List<Home_Institution__c> homeInstitutions = [SELECT Id FROM Home_Institution__c LIMIT 1];
		List<Account> accounts = apexMockDataUtility.createAccounts('newTest', 1);
		List<Contact> studentContacts = apexMockDataUtility.createContacts('newContacts', accounts, homeInstitutions);
		Contact studentContact = studentContacts[0];
		User studentUser = apexMockDataUtility.createUser(studentContact.Id);
		Application__c app = apexMockDataUtility.createApplication(studentContact.Id);
		Id progamOptionRTId = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option without Dates').getRecordTypeId();
		Program_Term__c programTerm = [SELECT Id FROM Program_Term__c WHERE RecordTypeId = :progamOptionRTId LIMIT 1];
        app.Program_Term__c = programTerm.Id;
    	
		Test.startTest();
		database.update(app);

		studentContact.Active_Application__c = app.Id;
		database.update(studentContact);
        system.runAs(studentUser)
        {
        	app.Status__c = 'Rejected';
        	database.update(app);
        	
        	studentApplyController controller = new studentApplyController();
			PageReference reference = controller.validateAccess();

			app.Status__c = 'Dropped';
        	database.update(app);
        	
        	controller = new studentApplyController();
			reference = controller.validateAccess();
        }
        Test.stopTest();
	}
	public static testMethod void testCloseCompletionNotification()
	{
		contactTriggerHandler.bypassTrigger = false;
		applicationTriggerHandler.bypassTrigger = false;
		BaseTriggerHandler.bypass('applicationItemTriggerHandler');
		BaseTriggerHandler.bypass('applicationRequirementTriggerHandler');
		
		Application__c application = [SELECT Id, Status__c, Program_Term__c FROM Application__c LIMIT 1];
		test.startTest();
		studentApplyController.closeCompletionNotification(String.valueOf(application.Id));
		test.stopTest();
	} */	
}