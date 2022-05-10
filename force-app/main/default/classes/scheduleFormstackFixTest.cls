/*
 * @description: test class scheduleFormstackFix
 * @author: Audrey Carson
*/
@isTest
private class scheduleFormstackFixTest {
	
	@isTest static void testFormStackURLFix() {
		Application_Requirement__c appReq = new Application_Requirement__c();
		appReq.Name = 'test app req';
		appReq.Form_Template_ID__c = 'a03500000000ate5WA';
		appReq.RecordTypeId = Schema.SObjectType.Application_Requirement__c.getRecordTypeInfosByName().get('Signature').getRecordTypeId();

		insert appReq;

		Contact teststudent = new Contact();
		teststudent.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
		teststudent.FirstName = 'testmy';
		teststudent.LastName = 'student';
		insert teststudent;

		Application__c app = new Application__c();
		app.Applicant__c = teststudent.Id;
		app.Name = 'testthis';
		insert app;

		User guestUser = [SELECT Id FROM User WHERE Name = 'Student Portal Site Guest User' LIMIT 1];
		Test.startTest();
		
		Application_Item__c appItem = new Application_Item__c();
		appItem.RecordTypeId = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Signature').getRecordTypeId();
		appItem.Application_Requirement__c = appReq.Id;
		appItem.Name = 'test';
		appItem.Application__c = app.Id;
		insert appItem;
		
		Datetime d = Datetime.now();
		String jobId = System.schedule('testScheduleFormstackFix' + d.format(), '0 0 13 * * ?', new scheduleFormstackFix());

		Test.stopTest();
	}	
}