@isTest
public without sharing class portalRemotingMethodsMinTestData 
{
    @TestSetup
    static void makeData(){
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection(new List<String>{'accountTriggerHandler'}, new Set<String>());
    }
    
	public static testMethod void testCheckForNewApplicationReqs()
	{
		
		Program_Term__c pt = [SELECT Id, Country__c, Program__c, Term__c FROM Program_Term__c LIMIT 1].get(0);
		Term__c t = [SELECT Id FROM Term__c WHERE Id !=: pt.Term__c LIMIT 1].get(0);
		Program_Term__c newPT = pt.clone(false, false, false, false);
		newPT.Id = null;
		newPT.Term__c = t.Id;
		database.insert(newPT);
		Contact c = [SELECT Id FROM Contact WHERE RecordType.Name = 'Student' LIMIT 1];
		Application__c app = new Application__c(Applicant__c = c.Id, Program_Term__c = newPT.Id, Name = 'Test', Status__c = 'Program Selected');
		applicationTriggerHandler.bypassTrigger = true;
		database.insert(app);		
		applicationTriggerHandler.bypassTrigger = false;

		String result = portalRemotingMethods.checkForNewApplicationReqs(app.Id);
        System.assertEquals('NONE_MISSING', result);
        Application_Requirement__c newReq = new Application_Requirement__c();
		newReq.RecordTypeId = Schema.SObjectType.Application_Requirement__c.getRecordTypeInfosByName().get('Signature').getRecordTypeId();
		newReq.Name = 'Test Signature';
		newReq.Phase__c = 'Pre-Admit';
        newReq.Program_Term__c = app.Program_Term__c;
		Test.startTest();
		baseTriggerHandler.bypass('ApplicationRequirementTriggerHandler');
		database.insert(newReq);
		baseTriggerHandler.clearBypass('ApplicationRequirementTriggerHandler');

		result = portalRemotingMethods.checkForNewApplicationReqs(app.Id);
		Test.stopTest();
        System.assertEquals('MISSING_BUT_CREATED', result);
        Integer oldCount = app.Application_Items__r.size();
		Integer newCount = [SELECT Id FROM Application_Item__c WHERE Application__c =: app.Id].size();
        System.debug(result);		
		System.assertNotEquals(oldCount, newCount);
	}
	/**
	 * @description test method for cloningApplicationItems
	 */
	public static testMethod void testCloneApplicationItems()
	{
		Id addressID = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Addresses').getRecordTypeId();
		Id noActionID = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('No Action').getRecordTypeId();
		Id recID = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Recommendation').getRecordTypeId();
		Contact c = [SELECT Id FROM Contact LIMIT 1];
		List<Application__c> appList = [SELECT Id FROM Application__c];		
		Application__c oldApplication = appList[0];
		Application__c activeApplication = appList[1];
		Application_Item__c oldAppItem1 = new Application_Item__c();
		oldAppItem1.Name = 'Addresses';
		oldAppItem1.Status__c = 'Complete';
		oldAppItem1.Phase__c = 'Pre-Admit';
		oldAppItem1.Directions__c = 'Lorem Ipsum';
		oldAppItem1.Application__c = oldApplication.Id;		
		oldAppItem1.RecordTypeId = addressID;
		Application_Item__c oldAppItem2 = new Application_Item__c();
		oldAppItem2.Name = 'Transcript';
		oldAppItem2.Status__c = 'Complete';
		oldAppItem2.Phase__c = 'Pre-Admit';
		oldAppItem2.Directions__c = 'Lorem Ipsum';
		oldAppItem2.Application__c = oldApplication.Id;		
		oldAppItem2.RecordTypeId = noActionID;
		Application_Item__c oldAppItem3 = new Application_Item__c();
		oldAppItem3.Name = 'Offer Reply Form';
		oldAppItem3.Status__c = 'Complete';
		oldAppItem3.Phase__c = 'Post-Acceptance';
		oldAppItem3.Directions__c = 'Lorem Ipsum';
		oldAppItem3.Application__c = oldApplication.Id;		
		oldAppItem3.RecordTypeId = noActionID;
		Application_Item__c oldAppItem4 = new Application_Item__c();
		oldAppItem4.Name = 'Recommendation';
		oldAppItem4.Status__c = 'Complete';
		oldAppItem4.Phase__c = 'Pre-Admit';
		oldAppItem4.Directions__c = 'Lorem Ipsum';
		oldAppItem4.Application__c = oldApplication.Id;		
		oldAppItem4.RecordTypeId = recID;
		Application_Item__c newAppItem1 = new Application_Item__c();
		newAppItem1.Name = 'Addresses';
		newAppItem1.Status__c = 'Incomplete';
		newAppItem1.Phase__c = 'Pre-Admit';
		newAppItem1.Directions__c = 'Lorem Ipsum';
		newAppItem1.Application__c = activeApplication.Id;		
		newAppItem1.RecordTypeId = addressID;
		Application_Item__c newAppItem2 = new Application_Item__c();
		newAppItem2.Name = 'Transcript';
		newAppItem2.Status__c = 'Incomplete';
		newAppItem2.Phase__c = 'Pre-Admit';
		newAppItem2.Directions__c = 'Lorem Ipsum';
		newAppItem2.Application__c = activeApplication.Id;		
		newAppItem2.RecordTypeId = noActionID;
		Application_Item__c newAppItem3 = new Application_Item__c();
		newAppItem3.Name = 'Offer Reply Form';
		newAppItem3.Status__c = 'Incomplete';
		newAppItem3.Phase__c = 'Not Visible';
		newAppItem3.Directions__c = 'Lorem Ipsum';
		newAppItem3.Application__c = activeApplication.Id;		
		newAppItem3.RecordTypeId = noActionID;
		Application_Item__c newAppItem4 = new Application_Item__c();
		newAppItem4.Name = 'Recommendation';
		newAppItem4.Status__c = 'Complete';
		newAppItem4.Phase__c = 'Pre-Admit';
		newAppItem4.Directions__c = 'Lorem Ipsum';
		newAppItem4.Application__c = activeApplication.Id;		
		newAppItem4.RecordTypeId = recID;
		
		database.insert(new List<SObject>{oldAppItem1, oldAppItem2, oldAppItem3, oldAppItem4, newAppItem1, newAppItem2, newAppItem3, newAppItem4});

		Recommendation__c rec = new Recommendation__c(
			Application_Item__c = oldAppItem4.Id, 
			Email_Address__c = 'test@test.test', 
			Name = 'Test Tester Recommendation',
			Phone_Number__c = '5555555555', 
			Recommendation__c = 'Here is the my recommendation for the student. They are great', 
			Recommender_Name__c = 'Test Tester',
			Status__c = 'Complete',
			Title__c = 'Sr. Professor',
			University__c = 'Test Uni'
		);

		Database.insert(rec);


		Attachment recPDF = new Attachment(ParentId = oldAppItem4.Id, Name = 'Recommendation', ContentType = 'text/plain', Body = Blob.valueOf(rec.Recommendation__c));
		Attachment transcript = new Attachment(ParentId = oldAppItem2.Id, Name = 'Transcript', ContentType = 'text/plain', Body = Blob.valueOf('This is the student\'s Transcript. They got good grades in all of their classes'));
		database.insert(new List<Attachment>{transcript, recPDF});

		Test.startTest();
		portalRemotingMethods.cloneApplicationItems(oldApplication.Id, activeApplication);
		Integer completeCounter = 0;
		List<Application_Item__c> newAppItems = [SELECT Id, Name, Status__c, Phase__c FROM Application_Item__c WHERE Application__c =: activeApplication.Id];
		for(Application_Item__c appItem: newAppItems)
		{
			completeCounter = appItem.Status__c == 'Complete' ? ++completeCounter : completeCounter;
			if(appItem.Status__c != 'Complete')
			{
				system.assertEquals('Offer Reply Form', appItem.Name);
			}
		}
		system.debug(newAppItems.size());
		system.assertEquals(3, completeCounter);
		List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId IN: new List<Id>{recPDF.ParentId, transcript.ParentId}];
		system.assertEquals(2, attachments.size());

		Test.stopTest();
	}
}