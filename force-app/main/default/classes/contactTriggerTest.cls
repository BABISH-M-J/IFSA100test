/**
 * Unit tests for Contact trigger, <<contactTriggerHandler>>, <<contactTriggerContextUtility>>, and <<contactService>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
private class contactTriggerTest {
	
	@TestSetup
    static void makeData(){
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'Support_Personnel'});
    }
	@isTest 
	static void testInsertAndUpdate() {
		contactTriggerHandler.bypassTrigger = false;
		applicationTriggerHandler.bypassTrigger = false;
		BaseTriggerHandler.bypass('applicationItemTriggerHandler');
		BaseTriggerHandler.bypass('applicationRequirementTriggerHandler');

		
		Contact testContact = [SELECT Id, 
							   Active_Application__c, 
							   firstName, 
							   lastName, 
							   Phone, 
							   Email, 
							   GPA__c, 
							   Appreciative_Advising_Call_Completed__c 
							   FROM Contact LIMIT 1];

		Program_Term__c testProgramTerm = [SELECT Id,Required_GPA__c FROM Program_Term__c LIMIT 1];
		testProgramTerm.Required_GPA__c = 3.5;
		Database.update(testProgramTerm);
		
		
		Test.startTest();
		testContact.Active_Application__c = null;
		testContact.id = null;
		testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
		testContact.firstName = 'New';
		testContact.lastName = 'O&amp;#39;Contact';
		testContact.Phone = '19876543210';
		testContact.Email = 'newcontact'+ Date.today().day() + Date.today().month() + '@email.test';
		insert(testContact);
		Application__c testApp = new Application__c(
			Applicant__c = testContact.Id,
			Status__c = 'Program Selected',
			Program_Term__c = testProgramTerm.Id
		);
		Database.insert(testApp);
		Application_Item__c advisingCall = new Application_Item__c(
			RecordTypeId = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('No Action').getRecordTypeId(),
			Name = 'Advising Call',
			Phase__c = 'Optional',
			Status__c = 'Incomplete',
			Application__c = testApp.Id
		);
		Database.insert(advisingCall);
		testContact = [SELECT Id, FirstName, LastName, Phone FROM Contact WHERE Id =: testContact.Id].get(0);
		System.assertEquals('(987) 654-3210', testContact.Phone);
		testContact.FirstName = 'Name';
		testContact.LastName = 'Changed';
		testContact.Active_Application__c = testApp.Id;
		testContact.GPA__c = 3.4;
		testContact.Phone = contactService.stripPhoneFormating(testContact.Phone);
		testContact.Appreciative_Advising_Call_Completed__c = true;
		System.debug(testContact.Home_Institution__c);
		update(New List<SObject>{testApp, testContact});
		Task t = [SELECT Id, Subject FROM Task WHERE WhatId =: testApp.Id And Subject = 'Student GPA does not meet program GPA requirement'];
		System.assertNotEquals(null, t);
		update(testContact);
		List<Task> tasks = [SELECT Id, Subject FROM Task WHERE WhatId =: testApp.Id And Subject = 'Student GPA does not meet program GPA requirement'];
		System.assertEquals(1, tasks.size());
		advisingCall = [SELECT Id, Status__c FROM Application_Item__c WHERE Id =: advisingCall.Id];
		System.assertEquals('Complete', advisingCall.Status__c);		
		Test.stopTest();
	}
	@isTest
	static void testInsertDelete() {
		contactTriggerHandler.bypassTrigger = false;
		applicationTriggerHandler.bypassTrigger = false;
		BaseTriggerHandler.bypass('applicationItemTriggerHandler');
		BaseTriggerHandler.bypass('applicationRequirementTriggerHandler');

		Contact testContact = apexMockDataUtility.createContact('test', null);

		delete testContact;
	}

	@isTest
	static void testUpdateIfsaButlerNetEmailService() {
		contactTriggerHandler.bypassTrigger = false;
		applicationTriggerHandler.bypassTrigger = false;
		BaseTriggerHandler.bypass('applicationItemTriggerHandler');
		BaseTriggerHandler.bypass('applicationRequirementTriggerHandler');

		Test.setMock(WebServiceMock.class, new ifsaButlerNetEmailServiceMock());
		Test.startTest();
		Contact testContact = [SELECT Id, IFSA_Butler_NET_Forwarding_Address__c FROM Contact LIMIT 1];
		testContact.IFSA_Butler_NET_Forwarding_Address__c = 'test@test.test';
		database.update(testContact);
		testContact.IFSA_Butler_NET_Email_Delete__c = true;
		database.update(testContact);
		Test.stopTest();
	}

	//START AUCARSON
	@isTest
	public static void	testCreateDeleteSPs(){
		contactTriggerHandler.bypassTrigger = false;
		applicationTriggerHandler.bypassTrigger = false;
		BaseTriggerHandler.bypass('applicationItemTriggerHandler');
		BaseTriggerHandler.bypass('applicationRequirementTriggerHandler');

		Id guardianContRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Other').getRecordTypeId();
        Id studentConRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id advisorConRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        Id homeInstAccRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId();

		World__c earth = New World__c(Name ='Global');
        insert earth;

		Region__c localSupport = New Region__c(Name = 'Local Support', World__c = earth.ID);
        insert localSupport;

		Country__c usa = New Country__c(Name = 'United States', Region__c = localSupport.Id, Active__c = true);
        insert usa;

		Home_Institution__c hi = New Home_Institution__c(Name ='Test University', Country__c = usa.Id);
        insert hi;

		Account a = New Account(Name = 'Test University', RecordtypeId = homeInstAccRT, Institution__c = hi.Id);
        insert a;

		hi.Account__c = a.Id;
		update hi;

		Contact student = New Contact(FirstName = 'John', LastName = 'Cleese', Citizenship__c = 'US Citizen', Home_Institution__c = hi.Id);
        insert student;

		Test.startTest();
		List<Contact> contactList = New List<Contact>();
		contactList.add(New Contact(FirstName = 'Graham', LastName='Chapman', RecordtypeId = guardianContRT, Emergency_Contact__c = true));
		contactList.add(New Contact(FirstName = 'Eric', LastName='Idle', RecordtypeId = guardianContRT, Emergency_Contact__c = false));
		contactList.add(New Contact(FirstName = 'Terry', LastName='Jones', RecordtypeId = guardianContRT, Emergency_Contact__c = false, Send_Marketing_Materials__c = true));
		Contact testLater = New Contact(FirstName = 'Terry', LastName='Gilliam', RecordtypeId = advisorConRT, Emergency_Contact__c = true);
        contactList.add(testLater);
		contactList.add(New Contact(FirstName = 'Michael', LastName = 'Palin', RecordtypeId = advisorConRT, Emergency_Contact__c = false));

		insert contactList;

		List<Support_Personnel__c> sps = [SELECT Id, Non_IFSA_Staff__c FROM Support_Personnel__c];
		System.assertEquals(5, sps.size());

		testLater.Do_Not_Contact__c = true;
		update testLater;

		sps = [SELECT Id, Non_IFSA_Staff__c FROM Support_Personnel__c];
		System.assertEquals(4, sps.size());	

	}
	public testMethod static void testCreateDeleteSPs2(){
		
		Test.startTest();
		Boolean re = contactTriggerContextUtility.isFirstRun();
		contactTriggerContextUtility.setIsAfterTrue();
		Test.stopTest();
		
	}
	//END AUCARSON
}