@isTest
private class model_baseTest {
	
	@isTest static void testHashCode() {
		List<Contact> contacts = new List<Contact>();
		Id advisorContactRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Advisor'].get(0).Id;
		for(Integer i = 0; i < 200; i++)
		{
			contacts.add(new Contact(FirstName = 'Hash', LastName = 'Code'+i, Email = i+'hashcode@test.test', RecordTypeId = advisorContactRT));
		}
		Database.insert(contacts);
		system.debug('Inserted ' + contacts.size() + ' contact records');
		Test.startTest();

		Map<Integer, model_contact> results = new Map<Integer, model_contact>();
		Set<model_contact> results2 = new Set<model_contact>();
		contacts.clear();
		contacts = [SELECT Id, FirstName, LastName, Name, Email FROM Contact];
		system.debug('Selected ' + contacts.size() + ' contact records');
		for(Contact c: contacts)
		{
			model_contact mc = new model_contact(c);			
			results.put(mc.hashCode(), mc);
			results2.add(mc);
		}
		system.debug('Items in map: ' + results.size());
		system.assertEquals(200, results.size());
		//Number of items in the set. Should be 200
		system.debug('Items in set:' + results2.size());
		system.assertEquals(200, results2.size());

		List<Contact> contacts2 = [SELECT Id, FirstName, LastName, Name, Email FROM Contact];
		system.debug('Selected ' + contacts.size() + ' contact records again');
		for(Contact c: contacts)
		{
			model_contact mc = new model_contact(c);			
			results.put(mc.hashCode(), mc);
			results2.add(mc);
		}
		//Number of items in the map. Should be 200
		system.debug('Items in map: ' + results.size());
		system.assertEquals(200, results.size());
		//Number of items in the set. Should be 200
		system.debug('Items in set:' + results2.size());
		system.assertEquals(200, results2.size());		

		Test.stopTest();
	}
	@isTest static void testHashCodeWithCities() {
		World__c w = new World__c(Name = 'Test World');
		Database.insert(w);
		Region__c r = new Region__c(Name = 'Test Region', World__c = w.Id);
		Database.insert(r);
		Country__c c = new Country__c(Name = 'Test County', Region__c = r.Id);
		Database.insert(c);
		List<Locality__c> localities = new List<Locality__c>();
		Id  cityRT = Schema.SObjectType.Locality__c.getRecordTypeInfosByName().get('City/Town').getRecordTypeId();
		for(Integer i = 0; i < 10; i++)
		{
			Locality__c l = new Locality__c(Name = i + 'Test Locality', RecordTypeId = cityRT, Country__c = c.Id);
			localities.add(l);
		}
		Database.insert(localities);
		Set<model_city> results = new Set<model_city>();
		localities.clear();
		localities = [SELECT Id, Name, Country__c FROM Locality__c WHERE RecordTypeId =: cityRT];
		for(Locality__c l: localities)
		{
			results.add(new model_city(l));
		}
		system.assertEquals(10, results.size());
		model_city mc = new model_city(localities.get(0));
		
		for(Locality__c l: localities)
		{
			results.add(new model_city(l));
		}
		system.assertEquals(10, results.size());
		system.assertEquals(true, results.contains(mc));
	}
	@isTest static void testAllModels() {
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
		model_application mApp = new model_application((Application__c) testData.get('studentApplication'));
		model_case mCase = new model_case();
		model_caseComment mComment = new model_caseComment();
		model_caseHistory mCaseHistory = new model_caseHistory();
		model_city mCity = new model_city((Locality__c) testData.get('city'));
		model_contact mContact = new model_contact((Contact) testData.get('studentContact'), true);
		model_contactSupport mCSP = new model_contactSupport();
		model_country mCountry = new model_country();
		model_homeInstitution mHome = new model_homeInstitution((Home_Institution__c) testData.get('homeInstitution1'));
		model_hostInstitution mHost = new model_hostInstitution((Host_Institution__c)testData.get('hostInstitution'));
		model_picklist mPick = new model_picklist();
		model_program_option mOption = new model_program_option();
		model_program_term mProgramTerm = new model_program_term((Program_Term__c) testData.get('programOption1'));
		model_program mProgram = new model_program();
		model_recordType mRecordType = new model_recordType();
		model_support_personnel mSP = new model_support_personnel();
		model_task mTask = new model_task();
		model_term mTerm = new model_term();
		model_trip mTrip = new model_trip();
		model_user mUser = new model_user();
	}
}