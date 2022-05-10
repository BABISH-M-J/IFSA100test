/**
 * Test class to test <<applicationItemTrigger>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
@isTest
private class applicationItemTriggerTest {
	/**
	 * Test data setup
	 */
	@TestSetup
    static void makeData(){
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection();
    }
	
	/**
	 * Tests app item marked as imcomplete And complete. 
	 * Incomplete items should have null values for Completed_By_User__c And Completed_Date__c
	 * Complete items should be returned with values in Completed_By_User__c And Completed_Date__c
	 */
	static testMethod void testNotCompletedAndCompletedAppItem() {
		Test.startTest();
		
		Application_Item__c appItem = [SELECT Id, Status__c, Completed_By_User__c, Completed_Date__c FROM Application_Item__c LIMIT 1];
		appItem.Status__c = 'Complete';
		system.debug(appItem.Status__c);
		database.update(appItem);

		Test.stopTest();
		appItem = [SELECT Id, Completed_By_User__c, Completed_Date__c FROM Application_Item__c WHERE Id =: appItem.Id];
		system.assertNotEquals(null, appItem.Completed_By_User__c);
		system.assertNotEquals(null, appItem.Completed_Date__c);

		database.delete(appItem);
	}
	/*
	//Tests a completed passport item
	static testMethod void testPassportMethod() {
		initTestData();
		Term__c term = (Term__c) testData.Get('springTerm');
		term.Year__c = Date.today().year() + 1;
		database.update(term);
		Application_Item__c appItem = (Application_Item__c) testData.Get('applicationItem');

		appItem.RecordTypeId = 	Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Passport Copy').getRecordTypeId();
		appItem.Passport_Country_of_Issuance__c = 'USA (United States)';
		appItem.Passport_Expiration_Date__c = Date.today().addMonths(11);
		appItem.Passport_Number__c = '34292748923';
		appItem.Status__c = 'Complete';

		Test.startTest();
		Database.update(appItem);
		Test.stopTest();
		// We are Not using this portion right now but could in the future
		// Test to see if contact has been updated with passport info
		// Contact c = [SELECT Id, Passport_Country_of_Issuance__c, Passport_Expiration_Date__c, Passport_Number__c FROM Contact WHERE Id =: testData.get('studentContact').Id];
		// system.assertEquals(appItem.Passport_Country_of_Issuance__c, c.Passport_Country_of_Issuance__c, 'Country of Issuance does not match');
		// system.assertEquals(appItem.Passport_Expiration_Date__c, c.Passport_Expiration_Date__c, 'Expiration Date does not match');
		// system.assertEquals(appItem.Passport_Number__c, c.Passport_Number__c, 'Passport Number does not match');
		
		//
		Try
		{
			Task passportTask = [SELECT Id FROM Task WHERE WhatId =: appItem.Id].get(0);
		}
		Catch(Exception e)
		{
			system.debug('A task with that application item id could not be found');
			system.debug(e.getMessage());
			Throw e;
		}
	}
	*/

	/**
	 * Tests FastForm (FormStack) App Item template linking
	 */
	@isTest
	static void testFastFormsAppItem() {
		VisualAntidote__Previous_Form__c vapf = new VisualAntidote__Previous_Form__c(Name='Sample Web-To-Lead Form', VisualAntidote__Active__c = true);
		insert vapf;
		Application_Requirement__c appReq = [SELECT Id, Form_Template_ID__c FROM Application_Requirement__c LIMIT 1];
		//appReq.Form_Template_ID__c = [SELECT Id FROM VisualAntidote__Previous_Form__c WHERE Name = 'Sample Web-To-Lead Form' AND VisualAntidote__Active__c = TRUE].get(0).Id;
		appReq.Form_Template_ID__c = vapf.Id;

		update(appReq);

		Test.startTest();
		Application_Item__c appItem = New Application_Item__c();
		appItem.Application_Requirement__c = appReq.Id;
		appItem.Directions__c = 'Test Directions';
		appItem.Phase__c = 'Pre-Admit';
		appItem.Status__c = 'Incomplete';
		appItem.Application__c = [SELECT Id FROM Application__c LIMIT 1].Id;

		insert(appItem);
		System.assert(Limits.getFutureCalls()>0);
		Test.stopTest();
	}
	
	/**
	 * Tests to ensure that when Student Acceptance Agreement Is completed that the time stamp on the application Is filled in.
	 */
	static testMethod void testsetContractSignedTimeStamp() {

		Test.startTest();
		Application_Item__c appItem = New Application_Item__c();
		appItem.Application_Requirement__c = [SELECT Id FROM Application_Requirement__c LIMIT 1].Id;
		//appItem.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Application_Item__c' AND Name = 'Signature'].get(0).Id;
		appItem.RecordTypeId = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Signature').getRecordTypeId();
		appItem.Name = 'IFSA-Butler Student Acceptance Agreement';
		appItem.Phase__c = 'Post-Acceptance';
		appItem.Status__c = 'Incomplete';
		appItem.Application__c = [SELECT Id FROM Application__c LIMIT 1].Id;

		insert(appItem);

		appItem.Status__c = 'Complete';
		update(appItem);
 		
 		Test.stopTest();
 		appItem = [SELECT Id, Application__c, Completed_Date__c FROM Application_Item__c WHERE Id =: appItem.Id];
		Application__c app = [SELECT Id, Status_Contract_Signed__c FROM Application__c WHERE Id =: appItem.Application__c];
		system.assertNotEquals(null, app.Status_Contract_Signed__c);
		system.assertEquals(appItem.Completed_Date__c, app.Status_Contract_Signed__c);
	}

	/**
	 * Test Create, Send, Complete Offer Reply Form
	 */
	public static testmethod void testCreateSendOfferReply(){

		Test.startTest();
		List<Application_Item__c> appItemList = new List<Application_Item__c>();
		Id appId = [SELECT Id FROM Application__c LIMIT 1].Id;
		Application_Item__c appItem = New Application_Item__c();
		appItem.RecordTypeId = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Download-Upload').getRecordTypeId();
		appItem.Name = 'Offer Reply Form';
		appItem.Status__c = 'Incomplete';
		appItem.Application__c = appId;

		//insert appItem;
		appItemList.add(appItem);

		Application_Item__c appItem2 = New Application_Item__c();
		appItem2.RecordTypeId = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Travel Plan').getRecordTypeId();
		appItem2.Name = 'Test app item';
		appItem2.Status__c = 'Incomplete';
		appItem2.Receive_Task_When_Completed__c = true;
		appItem2.Application__c = appId;
		appItemList.add(appItem2);

		insert appItemList;

		for(Application_Item__c ai : appItemList){
			ai.Status__c = 'Complete';
		}

		//.Status__c = 'Complete';
		//update appItem;
		
		System.runAs(new User(Id = UserInfo.getUserId())){
			update appItemList;
		}		

		Application__c app = [SELECT Id, OwnerId, Status_Contract_Signed__c, Applicant__c FROM Application__c WHERE Id =: appItem.Application__c];
		List<Task> sendOfferReply = [SELECT Id, Subject, WhoId, OwnerId FROM Task WHERE WhatId =: appItem.Id OR WhatId =: appItem2.Id];


		System.assertNotEquals(sendOfferReply.size(), 0);

		Test.stopTest();

	}
}