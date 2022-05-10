@isTest
private class scheduledProgMovementUpdateTest {
	
	@isTest static void test_method_one() {
		Term__c spring2018 = new Term__c();
		spring2018.Section__c = 'Spring';
		spring2018.Year__c = 2018;
		insert spring2018;

		World__c earth = new World__c();
		earth.Name = 'earth';
		insert earth;

		Region__c intl = new Region__c();
		intl.Name = 'international support';
		intl.World__c = earth.Id;
		insert intl;

		Country__c chile = new Country__c();
		chile.Name = 'chile';
		chile.Active__c = true;
		chile.Region__c = intl.Id;
		insert chile;

		Country__c argentina = new Country__c();
		argentina.Name = 'argentina';
		argentina.Active__c = true;
		argentina.Region__c = intl.Id;
		insert argentina;


		Program__c prog = new Program__c();
		prog.Name = 'test program';
		prog.Country__c = chile.Id;
		insert prog;
		
		List<Program_Term__c> progList = new List<Program_Term__c>();
		for(Integer i = 0; i <30; i++)
		{
			Program_Term__c pt = new Program_Term__c();
			pt.Program__c = prog.Id;
			pt.Term__c = spring2018.Id;
			pt.Name = 'test Program ' + 'Spring 2018 ' + i;
			pt.Country__c = chile.Id;
			progList.add(pt);
		}
		insert progList;

		Id progMoveRT = Schema.SObjectType.Schedule__c.getRecordTypeInfosByName().get('Program Movement').getRecordTypeId();
		List<Schedule__c> scheduleList = new List<Schedule__c>();

		for(Integer i=0; i<15; i++)
		{
			Schedule__c s = new Schedule__c();
			s.Program_Term__c = progList[i].Id;
			s.RecordTypeId = progMoveRT;
			s.Start_Date__c = System.Today();
			s.Country__c = argentina.Id;
			s.Name__c = 'test movement ' + i;
			scheduleList.add(s);
		}
		insert scheduleList;

		test.startTest();
		scheduledProgramMovementUpdate batchJob = new scheduledProgramMovementUpdate();
		Database.executeBatch(batchJob);
		test.stopTest();

		List<Program_Term__c> changedProgramTerms = [SELECT Id FROM Program_Term__c WHERE Country__c = :argentina.Id];
		System.assertNotEquals(00, changedProgramTerms.size());


	}
	
	@isTest static void test_method_two() {
		//test schedule method
		Test.startTest();
		Datetime dt = Datetime.now().addMinutes(1);
		String chron = '0 ' + dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
		String jobId = System.schedule('testmethod', chron, new scheduledProgramMovementUpdate());
		Test.stopTest();
	}
	
}