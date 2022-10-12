/**
 * Unit tests for <<flightTriggerHandler>>, <<flightAndTravelService>>, <<scheduledContactTravelingUpdate>>
 */
// ApexDoc updated 2/8/2021 Brock Barlow
@isTest
private class flightAndTravelServiceTest 
{	
    @isTest
	static void flightTriggerTest() 
	{
        // added by powerfluence based on Clayton req 03/29/2022 starts
        BaseTriggerHandler.bypass('applicationItemTriggerHandler');
        BaseTriggerHandler.bypass('programTriggerHandler');
        BaseTriggerHandler.bypass('contactTriggerHandler');
        BaseTriggerHandler.bypass('billingArrangementTriggerHandler');
        BaseTriggerHandler.bypass('accountTriggerHandler');
        // added by powerfluence based on Clayton req 03/29/2022 ends
        Map<String, SObject> testData = init();
		Travel_Plan__c tp = new Travel_Plan__c();
		tp.Name = 'Test Travel Plan';
		tp.Flag__c = 'Group';

		Database.Insert(tp);
		Datetime yesterday = Datetime.now().addDays(-2);
		Datetime tomorrow = Datetime.now().addDays(2);
		Flight__c f1 = new Flight__c();
		Flight__c f2 = new Flight__c();
		f1.Name = 'Test 001';
		f1.Airline__c = 'Test';
		f1.Flight_Number__c = '001';
		f1.Travel_Plan__c = tp.id;		
		f1.Departure_Airport_Code__c = 'IND';
		f1.Departure_Year__c = yesterday.Year();
        f1.Departure_Month__c = yesterday.Month();
        f1.Departure_Day__c = yesterday.Day();
        f1.Departure_Hour__c = yesterday.Hour();
        f1.Departure_Minute__c = yesterday.Minute();
        f1.Arrival_Airport_Code__c = 'SFO';	        
        f1.Arrival_Year__c = yesterday.Year();
        f1.Arrival_Month__c = yesterday.Month();
        f1.Arrival_Day__c = yesterday.Day();
        f1.Arrival_Hour__c = yesterday.Hour() + 1;
        f1.Arrival_Minute__c = yesterday.Minute();
        f2.Name = 'Test 001';
		f2.Airline__c = 'Test';
		f2.Flight_Number__c = '001';
		f2.Travel_Plan__c = tp.id;		
		f2.Departure_Airport_Code__c = 'SFO';		
		f2.Departure_Year__c = tomorrow.Year();
        f2.Departure_Month__c = tomorrow.Month();
        f2.Departure_Day__c = tomorrow.Day();
        f2.Departure_Hour__c = tomorrow.Hour();
        f2.Departure_Minute__c = tomorrow.Minute();
        f2.Arrival_Airport_Code__c = 'IND';	        
        f2.Arrival_Year__c = tomorrow.Year();
        f2.Arrival_Month__c = tomorrow.Month();
        f2.Arrival_Day__c = tomorrow.Day();
        f2.Arrival_Hour__c = tomorrow.Hour() + 1;
        f2.Arrival_Minute__c = tomorrow.Minute();

        Test.startTest();
        Database.Insert(new List<Flight__c>{f1, f2});
        Application__c app = (Application__c) testData.get('studentApplication');
        app.Status__c = 'Accepted';
        app.Program_Approval_Completed_By__c = testData.get('advisorContact1').Id;
        app.Travel_Plan__c = tp.Id;
        Program_Term__c pt = (Program_Term__c) testData.get('programTerm');
        //modified by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
        // pt.Start_Date__c = Date.today();
        // Database.Update(new List<SObject>{app, pt});
       
        app = [SELECT Id, Status__c, Applicant__c, Program_Term_Start_Date__c, Program_Term_End_Date__c, Applicant__r.Created_For_Custom__c, Applicant__r.Id, Applicant__r.Personal_Email__c
        FROM Application__c 
        WHERE Id =: app.Id];
        pt.Start_Date__c = Date.today().addDays(-2);
        app.Applicant__r.Created_For_Custom__c = true;
        app.Applicant__r.Personal_Email__c = null;
        System.debug('Debug application '+app);
        // Database.update(app);
        Database.SaveResult appRes = Database.update(app);
        Database.SaveResult ptRes = Database.update(pt);
        // Database.update(pt);
        //modified by PowerFluence req_dt:03/29/2022 ref email from Clayton ends

        scheduledContactTravelingUpdate.updateTravelingStatusOnContacts();
        f2.Arrival_Year__c = yesterday.Year();
        f2.Arrival_Month__c = yesterday.Month();
        f2.Arrival_Day__c = yesterday.Day() -1;
        f2.Arrival_Hour__c = yesterday.Hour() + 1;
        f2.Arrival_Minute__c = yesterday.Minute();
        Database.Update(f2);

        scheduledContactTravelingUpdate.updateTravelingStatusOnContacts();

        Database.Delete(f2);

        String jobId = System.schedule('scheduledContactTravelingUpdate',
            '0 0 0 * * ? *', new scheduledContactTravelingUpdate());

        //added by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
        //added by PowerFluence for updateEmailAddresses test
        // app = [SELECT Id, Status__c, Applicant__c, Program_Term_Start_Date__c, Program_Term_End_Date__c, Applicant__r.Created_For_Custom__c, Applicant__r.Id, Applicant__r.Personal_Email__c
        //         FROM Application__c 
        //         WHERE Id =: appRes.getId()];
        Contact ctct = [SELECT Id, Name, Personal_Email__c FROM Contact WHERE Id =: app.Applicant__c];
        ctct.Personal_Email__c = 'test1@ifsa.test';
        pt.Start_Date__c = Date.today().addDays(-2);
        app.Applicant__r.Created_For_Custom__c = true;
        Database.update(app);
        Database.update(pt);
        Database.Update(ctct);
        scheduledContactTravelingUpdate.updateEmailAddresses(new List<Id>{app.Applicant__c});
        BaseTriggerHandler.clearBypass('applicationItemTriggerHandler');
        BaseTriggerHandler.clearBypass('programTriggerHandler');
        BaseTriggerHandler.clearBypass('contactTriggerHandler');
        BaseTriggerHandler.clearBypass('accountTriggerHandler');
        BaseTriggerHandler.clearBypass('billingArrangementTriggerHandler');
        //added by PowerFluence req_dt:03/29/2022 ref email from Clayton ends

        Test.stopTest();
	}

	private static Map<String, SObject> init()
	{
		return apexMockDataUtility.createIfsaDataCollection();
	}	
    // added by powerfluence based on Clayton req 03/29/2022 starts
    @isTest
	static void sObjectBatchUpdaterWithErrorTest(){
        Course__c cr1 = new Course__c(
                Expiration_Reason__c = 'others',
                Expiration_Reason_Other__c = null,
                RecordTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Host Institution').getRecordTypeId()
            );
            Course__c cr2 = new Course__c(
                Expiration_Reason__c = 'others',
                Expiration_Reason_Other__c = null,
                RecordTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Host Institution').getRecordTypeId()
            );
        User user = [SELECT Id FROM User WHERE UserType = 'Standard' AND IsActive = true LIMIT 1];
        System.runAs(user){
        sObjectBatchUpdater.batchUpdate(new List<SObject>{cr1,cr2},25);
        sObjectBatchUpdater.batchUpdate(new List<SObject>{cr1,cr2},25,sObjectBatchUpdater.dmlTypes.dmlInsert);
        sObjectBatchUpdater.batchUpdate(new List<SObject>{cr1,cr2},25,sObjectBatchUpdater.dmlTypes.dmlUpsert);
        // sObjectBatchUpdater.batchUpdate(new List<SObject>{cr1,cr2},25,sObjectBatchUpdater.dmlTypes.dmlUpsert,new List<Id>{cr1.Id});
        }
    }
    // added by powerfluence based on Clayton req 03/29/2022 ends

}