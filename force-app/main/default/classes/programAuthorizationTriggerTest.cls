@isTest
public with sharing class programAuthorizationTriggerTest {
	@TestSetup
    static void makeData(){
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'CMS'});
    }
	public static testMethod void testUpdate()
	{	
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();

		Program_Authorization__c pa = (Program_Authorization__c) testData.get('programAuthorization1');
		Test.setCreatedDate(pa.Id, DateTime.now().addDays(-8));
		pa.Term__c = 'Spring; Calendar Year; Academic Year;';
		Test.startTest();
		database.update(pa);
		pa = [SELECT Id, Previous__c, Next__c FROM Program_Authorization__c WHERE Previous__c =: pa.Id].get(0);
		pa.Term__c = 'Spring; Fall; Calendar Year;';
		database.update(pa);
		pa.Term__c = 'Spring; Calendar Year; Academic Year;';
		database.update(pa);
		Test.stopTest();
	}
	public static testMethod void testNotApproved()
	{	
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();

		Program_Authorization__c pa = (Program_Authorization__c) testData.get('programAuthorization1');
		Test.setCreatedDate(pa.Id, DateTime.now().addDays(-8));
		pa.Term__c = 'Not Approved';
		Test.startTest();
		database.update(pa);
		pa = [SELECT Id, Previous__c, Next__c FROM Program_Authorization__c WHERE Previous__c =: pa.Id].get(0);
		pa.Show_Unauthorized_Program_In_CHART__c = true;
		database.update(pa);

		Integer paCount = [SELECT Count() FROM Program_Authorization__c WHERE Account__c =: pa.Account__c];

		System.debug(paCount);

		Test.stopTest();
	}

	public static testMethod void testException()
	{	
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();

		Program_Authorization__c pa = (Program_Authorization__c) testData.get('programAuthorization1');
		Test.setCreatedDate(pa.Id, DateTime.now().addDays(-4));
		
		pa.Id = null;
		//Id accountId = pa.Account__c;
		//Id programId = pa.Program__c;
		//pa.Account__c = accountId;
		//pa.Program__c = programId;
		Test.startTest();
		try
		{
			database.insert(pa);
		}
		catch(Exception e)
		{
			System.debug(e.getMessage());
			system.assertEquals(true, e.getMessage().contains('caused by: programAuthorizationService.programAuthorizationServiceException:'));
		}
		Test.stopTest();
	}

	public static testMethod void testAuthorizations()
	{
		Id HIAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId();
		Account testAccount = [SELECT Id, Name, Approves_All_Calendar_Programs__c, Approves_All_Summer_Programs__c, Approves_All_Winter_Programs__c FROM Account WHERE RecordTypeId =: HIAccount].get(0);	
		//List<Program_Authorization__c> PAList = [SELECT Id, Name, Term__c FROM Program_Authorization__c WHERE Account__c =: testAccount.Id].get(0);	
		system.debug(LoggingLevel.ERROR, testAccount);
		
		if(testAccount.Approves_All_Calendar_Programs__c == false){
			testAccount.Approves_All_Calendar_Programs__c = true;
		}
		else if(testAccount.Approves_All_Calendar_Programs__c == true){
			testAccount.Approves_All_Calendar_Programs__c = false;
		}
		testAccount.BillingStreet = 'Some Place\r\nBeside the other place\r\nAround the corner from a third place';
		Database.SaveResult upres = Database.update(testAccount);
		System.debug(LoggingLevel.ERROR, 'RESULT ' + upres);

		if(testAccount.Approves_All_Winter_Programs__c == false){
			testAccount.Approves_All_Winter_Programs__c = true;
		}
		else if(testAccount.Approves_All_Winter_Programs__c == true){
			testAccount.Approves_All_Winter_Programs__c = false;
		}
		upres = Database.update(testAccount);
		system.debug(LoggingLevel.ERROR, 'RESULT ' + upres);

		if(testAccount.Approves_All_Summer_Programs__c == false){
			testAccount.Approves_All_Summer_Programs__c = true;
		}
		else if(testAccount.Approves_All_Summer_Programs__c == true){
			testAccount.Approves_All_Summer_Programs__c = false;
		}
		upres = Database.update(testAccount);
		system.debug(LoggingLevel.ERROR, 'RESULT ' + upres);

		//Database.update(testAccount);
	}

}