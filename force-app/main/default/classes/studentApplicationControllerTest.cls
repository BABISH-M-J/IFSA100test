@isTest
public with sharing class studentApplicationControllerTest 
{
    @TestSetup
	static void makeData(){
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
	}

	public static testMethod void testInstance()
	{
		contactTriggerHandler.bypassTrigger = false;
		applicationTriggerHandler.bypassTrigger = false;
		BaseTriggerHandler.bypass('applicationItemTriggerHandler');
		BaseTriggerHandler.bypass('applicationRequirementTriggerHandler');

		Contact studentContact = [SELECT Id, (SELECT Id, Program_Term__c FROM Applications__r) FROM Contact WHERE RecordType.Name = 'Student' LIMIT 1].get(0);
		User studentUser = [SELECT Id FROM User WHERE ContactId =: studentContact.Id LIMIT 1].get(0);
		Application__c app = studentContact.Applications__r.get(0);
        Test.startTest();
        system.runAs(studentUser)
        {
			// Test Instance
        	app.Status__c = 'Program Selected';
        	database.update(app);
        	
        	studentApplicationController controller = new studentApplicationController();
			PageReference reference = controller.validateAccess();

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
			//added by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
        	studentApplyItemViewModel controller1 = new studentApplyItemViewModel(appItem);
			//added by PowerFluence req_dt:03/29/2022 ref email from Clayton ends
		}
        Test.stopTest();
	}
	public static testMethod void testInstance2()
	{
		contactTriggerHandler.bypassTrigger = false;
		applicationTriggerHandler.bypassTrigger = false;
		BaseTriggerHandler.bypass('applicationItemTriggerHandler');
		BaseTriggerHandler.bypass('applicationRequirementTriggerHandler');
		
		Contact studentContact = [SELECT Id, (SELECT Id, Program_Term__c FROM Applications__r) FROM Contact WHERE RecordType.Name = 'Student' LIMIT 1].get(0);
		User studentUser = [SELECT Id FROM User WHERE ContactId =: studentContact.Id LIMIT 1].get(0);
		Application__c app = studentContact.Applications__r.get(0);

		Test.startTest();
		studentApplicationController controller;
		PageReference reference;
        system.runAs(studentUser)
        {

			controller = new studentApplicationController();
			reference = controller.validateAccess();
			// Test with no active application
		}
			studentContact.Active_Application__c = null;
        	database.update(studentContact);
		system.runAs(studentUser)
		{
        	controller = new studentApplicationController();
			reference = controller.validateAccess();
		}
			// Test with null program term
			studentContact.Active_Application__c = app.Id;
			app.Status__c = 'Registered';
			app.Program_Term__c = null;
			database.update(new list<SObject>{app, studentContact});
		system.runAs(studentUser)
		{
			controller = new studentApplicationController();
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

		Contact studentContact = [SELECT Id, (SELECT Id, Program_Term__c FROM Applications__r) FROM Contact WHERE RecordType.Name = 'Student' LIMIT 1].get(0);
		User studentUser = [SELECT Id FROM User WHERE ContactId =: studentContact.Id LIMIT 1].get(0);
		Application__c app = studentContact.Applications__r.get(0);

		Test.startTest();
		system.runAs(studentUser)
        {
        	app.Status__c = 'Rejected';
        	database.update(app);
        	
        	studentApplicationController controller = new studentApplicationController();
			PageReference reference = controller.validateAccess();

			app.Status__c = 'Dropped';
        	database.update(app);
        	
        	controller = new studentApplicationController();
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
		studentApplicationController.closeCompletionNotification(String.valueOf(application.Id));
		test.stopTest();
	}
}