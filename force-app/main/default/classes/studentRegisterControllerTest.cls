/**
 * Tests for studentRegisterController
 * Created by Brock Barlow
 */
 @isTest
public without sharing class studentRegisterControllerTest
{
	@TestSetup
	static void makeData(){
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection(new Set<String>());
	}

	public static testMethod void testInstanceProgramSelected()
	{
		Application__c studentApp = [SELECT Id, Status__c, Applicant__c FROM Application__c LIMIT 1];
		User studentUser = [SELECT Id, ContactId FROM User WHERE ContactId =: studentApp.Applicant__c LIMIT 1];
		Apex_String_Constant__mdt taskName = [SELECT Value__c FROM Apex_String_Constant__mdt WHERE DeveloperName = 'Welcome_Task'].get(0);
		Id taskRTId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Simple Task').getRecordTypeId();
		Task t = new Task(Subject = taskName.Value__c, Description = '', RecordTypeId = taskRTId, WhoId = studentApp.Applicant__c, WhatId = studentApp.Id, ActivityDate = Date.today().addDays(2), OwnerId = UserInfo.getUserId());
		Database.insert(t);
		List<Task> tasks = [SELECT Id, Description, Subject, ActivityDate, WhoId, WhatId, OwnerId FROM Task WHERE Subject =: taskName.Value__c AND WhoId =: studentApp.Applicant__c AND WhatId =: studentApp.Id];
		system.assertEquals(false, tasks.isEmpty());
		System.debug(tasks[0]);
		
		Test.startTest();
		System.runAs(studentUser)
		{
			// Test saving registration data
			studentRegisterViewModel viewModel = portalRemotingMethods.getRegistrationViewModel();
			viewModel.studentLastName = 'asdf';
			viewModel.GuardianLastName = 'asdfa';
			viewModel.TravelConcerns = 'Lorem ipsum...';
			Boolean isSuccess = portalRemotingMethods.saveRegistrationData(JSON.serialize(viewModel), true);
			System.assertEquals(true, isSuccess);		
		}
		// Now that we're using an async method we need to call stopTest to force it to execute
		Test.stopTest();	
	}	
}