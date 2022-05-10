@isTest
public class taskTriggerTest 
{
	static testMethod void testTriggerApproved() 
	{
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
		Application__c app = (Application__c) testData.get('studentApplication');
		User studentUser = (User) testData.get('studentUser');
		
		Travel_PLan__c travelPlan = new Travel_Plan__c();
		travelPlan.Status__c = 'Submitted For Approval';
		travelPlan.Travel_Plan_Information__c = 'Unit Test Data';

		app.Travel_Plan__c = travelPlan.Id;
		test.startTest();
		system.runAs(studentUser)
        {
			database.insert(travelPlan);
		}
		// Test Approved Travel Plan
		travelPlan = (Travel_Plan__c) apexQueryUtility.selectAllFrom('Travel_Plan__c', 'Travel_Plan_Information__c = \'' + travelPlan.Travel_Plan_Information__c + '\'').get(0);
		Task travelTask = new Task();
		travelTask.description = travelPlan.Travel_Plan_Information__c;
		travelTask.Priority = 'Normal';
		travelTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Travel Plan').getRecordTypeId();
		travelTask.Status = 'Not Started';
		travelTask.Subject = 'Student Travel Plan needs approval';
		travelTask.WhatId = travelPlan.Id;
		travelTask.WhoId = app.Applicant__c;
		system.runAs(studentUser)
		{
			database.insert(travelTask);
		}

		travelTask.Travel_Plan_Approved__c = true;
		database.update(travelTask);

		travelTask = [SELECT Id, Status, WhatId FROM Task WHERE Id =: travelTask.Id].get(0);
		travelPlan = [SELECT Id, Status__c, Travel_Plan_Information__c FROM Travel_PLan__c WHERE Id =: travelTask.WhatId].get(0);

		system.assertEquals('Completed', travelTask.Status, 'Task has not been marked "Completed"');
		system.assertEquals('Approved', travelPlan.Status__c, 'Travel Plan has not been marked "Approved"');

		test.stopTest();
	}

	static testMethod void testTriggerDenied() 
	{
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
		Application__c app = (Application__c) testData.get('studentApplication');
		User studentUser = (User) testData.get('studentUser');
		
		Travel_PLan__c travelPlan = new Travel_Plan__c();
		travelPlan.Status__c = 'Submitted For Approval';
		travelPlan.Travel_Plan_Information__c = 'Unit Test Data';

		app.Travel_Plan__c = travelPlan.Id;
		test.startTest();
		system.runAs(studentUser)
        {
			database.insert(travelPlan);
		}
		// Test Approved Travel Plan
		travelPlan = (Travel_Plan__c) apexQueryUtility.selectAllFrom('Travel_Plan__c', 'Travel_Plan_Information__c = \'' + travelPlan.Travel_Plan_Information__c + '\'').get(0);
		Task travelTask = new Task();
		travelTask.description = travelPlan.Travel_Plan_Information__c;
		travelTask.Priority = 'Normal';
		travelTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Travel Plan').getRecordTypeId();
		travelTask.Status = 'Not Started';
		travelTask.Subject = 'Student Travel Plan needs approval';
		travelTask.WhatId = travelPlan.Id;
		travelTask.WhoId = app.Applicant__c;
		system.runAs(studentUser)
		{
			database.insert(travelTask);
		}
		
		// Test Denied Travel Plan
		travelTask.Travel_Plan_Approved__c = false;
		travelTask.Status = 'Completed';
		database.update(travelTask);

		travelTask = [SELECT Id, Status, WhatId FROM Task WHERE Id =: travelTask.Id].get(0);
		travelPlan = [SELECT Id, Status__c, Travel_Plan_Information__c FROM Travel_PLan__c WHERE Id =: travelTask.WhatId].get(0);

		System.debug('Task: ' + travelTask);
		System.debug('Plan: ' + travelPlan);

		system.assertEquals('Completed', travelTask.Status, 'Task has not been marked "Completed"');
		system.assertEquals('Denied', travelPlan.Status__c, 'Travel Plan has not been marked "Denied"');
		test.stopTest();
	}
}