@isTest 
private class scheduleServiceTest {

	@isTest
	private static void generateCSVandDeleteScheduleTest() {
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();

		Schedule__c sch1 = new Schedule__c();
		sch1.RecordTypeId = Schema.SObjectType.Schedule__c.getRecordTypeInfosByName().get('Break').getRecordTypeId();
		sch1.Start_Date__c = Date.today().addDays(20);
		sch1.End_Date__c = sch1.Start_Date__c.addDays(7);
		sch1.Name__c = 'Test Break';
		sch1.Description__c = 'Test Break Description';
		sch1.Status__c = 'Approved';
		sch1.Program_Term__c = testInfo.get('programTerm').Id;

		Schedule__c sch2 = new Schedule__c();
		sch2.RecordTypeId = Schema.SObjectType.Schedule__c.getRecordTypeInfosByName().get('Excursion').getRecordTypeId();
		sch2.Start_Date__c = Date.today().addDays(30);
		sch2.Start_Time__c = '1:00 PM';
		sch2.End_Date__c = sch1.Start_Date__c.addDays(2);
		sch2.Start_Time__c = '1:00 PM';
		sch2.Name__c = 'Test Excursion';
		sch2.Description__c = 'Test Excursion Description';
        sch2.Program_Term__c = testInfo.get('programTerm').Id;

		Database.insert(new List<Schedule__c>{sch1, sch2});
		Test.startTest();

		scheduleService.generateCSVandDeleteSchedule(new List<Id>{sch1.Program_Term__c});

		Test.stopTest();

		List<Schedule__c> schedules = [SELECT Id FROM Schedule__c WHERE Program_Term__c =: sch1.Program_Term__c];
		system.assertEquals(0, schedules.size());
	}
}