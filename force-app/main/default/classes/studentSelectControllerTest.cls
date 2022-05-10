/**
 * Tests for studentSelectController
 *
 * Created by Brock Barlow
 */
@isTest
public without sharing class studentSelectControllerTest
{	
	@TestSetup
	static void makeData(){
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'Program_Auths'});
	}

	public static testMethod void testInstanceAndSearch()
	{
    	Contact studentContact = [SELECT Id, (SELECT Id, Program_Term__c FROM Applications__r) FROM Contact WHERE RecordType.Name = 'Student' LIMIT 1].get(0);
		User studentUser = [SELECT Id FROM User WHERE ContactId =: studentContact.Id LIMIT 1].get(0);
		Application__c app = studentContact.Applications__r.get(0);
		Test.startTest();
		system.debug(studentUser);
		System.runAs(studentUser)
		{
			studentSelectController controller = new studentSelectController();
			String serializedViewModel = controller.viewModel.getSerializedViewModel();
			//PageReference reference = controller.validateAccess();

			List<String> countryList = portalRemotingMethods.searchByCountry('England');
			List<Program_Term__c> termList = portalRemotingMethods.searchByTerm('England', 'Spring ' + Date.today().year());
		}
		Test.stopTest();
	}
	
	public static testMethod void testGetProgramTermAndProgramOptionInfo()
	{
    	Test.startTest();
    	Program_Term__c programTerm = [SELECT Id, Name, Display_Name__c FROM Program_Term__c LIMIT 1];
    	system.debug(programTerm.name);    	    	
		Map<String, String> data = portalRemotingMethods.getProgramTermInfo(programTerm.Id);
		List<Program_Term__c> data1 = portalRemotingMethods.getProgramOptions(programTerm.Id);
		Test.stopTest();
	}

	public static testMethod void testSelectProgramTerm()
	{
    	Test.startTest();
		Contact studentContact = [SELECT Id, Home_Institution__c, (SELECT Id, Program_Term__c FROM Applications__r) FROM Contact WHERE RecordType.Name = 'Student' LIMIT 1].get(0);
		User studentUser = [SELECT Id FROM User WHERE ContactId =: studentContact.Id LIMIT 1].get(0);
		Application__c app = studentContact.Applications__r.get(0);
		studentContact.Classes_Required__c = 'Yes';
		studentContact.Travel_Concerns__c = 'How do I get there?';
		studentContact.Travel_Topics__c = 'Scholarships;STEM';
		studentContact.Active_Application__c = app.Id;
		update studentContact;
		system.debug(studentContact.Active_Application__c);	
		Program_Term__c programTerm = [SELECT Id, Program__c FROM Program_Term__c LIMIT 1];
		//programTerm = (Program_Term__c) apexQueryUtility.selectAllFrom('Program_Term__c', 'Id = \'' + programTerm.Id + '\'').get(0);
		Program_Authorization__c pa = [SELECT Id, Term__c FROM Program_Authorization__c WHERE Program__c =: programTerm.Program__c AND Account__r.Institution__c =: studentContact.Home_Institution__c].get(0);
		pa.Term__c = 'Not Approved';
		database.update(pa);
		System.runAs(studentUser)
		{
			Boolean isSuccessful = portalRemotingMethods.selectProgramTerm(programTerm.Id);
			System.assertEquals(true, isSuccessful);
		}
		Test.stopTest();
		List<Task> tasks = [SELECT Id FROM Task WHERE RecordType.Name = 'Simple Task' AND WhoId =: studentContact.Id AND WhatId =: studentContact.Active_Application__c];
		system.assertEquals(false, tasks.isEmpty());

	}
	//ACARSON
	public static testMethod void testLockdown()
	{
    	Test.startTest();
		Contact studentContact = [SELECT Id, (SELECT Id, Program_Term__c FROM Applications__r) FROM Contact WHERE RecordType.Name = 'Student' LIMIT 1].get(0);
		User studentUser = [SELECT Id FROM User WHERE ContactId =: studentContact.Id LIMIT 1].get(0);
		Application__c app = studentContact.Applications__r.get(0);
		system.debug(studentUser);
		System.runAs(studentUser)
		{
			studentSelectController controller = new studentSelectController();
			controller.viewModel.isLockdownActive = true;
			String serializedViewModel = controller.viewModel.getSerializedViewModel();
			/* PageReference reference = controller.validateAccess();

			controller.viewModel.isLockdownActive = false;
			controller.viewModel.isRegistered = true;
			reference = controller.validateAccess(); */
		}		

	}
	public static testmethod void testDivertedAppsSearchByCountry()
	{
		Contact studentContact = [SELECT Id, (SELECT Id, Program_Term__c FROM Applications__r) FROM Contact WHERE RecordType.Name = 'Student' LIMIT 1].get(0);
		User studentUser = [SELECT Id FROM User WHERE ContactId =: studentContact.Id LIMIT 1].get(0);
		Application__c app = studentContact.Applications__r.get(0);
		Program_Term__c programTerm = [SELECT Id FROM Program_Term__c LIMIT 1];
		Application__c divertedApp =  new Application__c();
		applicationTriggerHandler.bypassTrigger = true;
		contactTriggerHandler.bypassTrigger = true;
		divertedApp.Program_Term__c = programTerm.Id;
		divertedApp.Applicant__c = studentContact.Id;
		divertedApp.Status__c = 'Diverted';
		insert divertedApp;
		Application__c divertedApp2 =  new Application__c();
		divertedApp2.Program_Term__c = programTerm.Id;
		divertedApp2.Applicant__c = studentContact.Id;
		divertedApp2.Status__c = 'Diverted';
		insert divertedApp2;
		applicationTriggerHandler.bypassTrigger = false;
		contactTriggerHandler.bypassTrigger = false;
		Test.startTest();
		System.runAs(studentUser)
		{
			studentSelectController controller = new studentSelectController();
			List<String> countries = portalRemotingMethods.searchByCountry('England');
		}
		Test.stopTest();


	}

	//ACARSON
	public static testMethod void testNonUSstudent()
	{
    	Test.startTest();
		Contact studentContact = [SELECT Id, (SELECT Id, Program_Term__c FROM Applications__r) FROM Contact WHERE RecordType.Name = 'Student' LIMIT 1].get(0);
		User studentUser = [SELECT Id FROM User WHERE ContactId =: studentContact.Id LIMIT 1].get(0);
		Application__c app = studentContact.Applications__r.get(0);
		Program_Term__c programTerm = [SELECT Id FROM Program_Term__c LIMIT 1];
		studentContact.Citizenship__c = 'Non-U.S. Citizen';
		studentContact.Non_US_Citizenship__c = 'Belize';
		update studentContact;
		Application__c testApp =  new Application__c();
		testApp.Program_Term__c = programTerm.Id;
		testApp.Applicant__c = studentContact.Id;
		insert testApp;

		System.runAs(studentUser){
			portalRemotingMethods.searchByTerm('England', 'Spring ' + Date.today().year());
			portalRemotingMethods.searchByCountry('England');
			portalRemotingMethods.selectProgramTerm(programTerm.Id);
		}

		test.stopTest();

	}
}