@isTest
public without sharing class programTriggerTest
{
	@TestSetup
	static void makeData(){
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection(new Set<String>());

		system.debug('--- makeData Start ---');
        //BaseTriggerHandler.bypass('programTriggerHandler');
        BaseTriggerHandler.bypass('userTriggerHandler');
		// Create users
        User fieldDirector = apexMockDataUtility.CreateSysAdmin();
        fieldDirector.FirstName = 'Field';
        fieldDirector.LastName = 'Director';
        User programOwner = apexMockDataUtility.CreateSysAdmin();
        programOwner.FirstName = 'Program';
        programOwner.LastName = 'Advisor';
        User residentDirector = apexMockDataUtility.CreateSysAdmin();
        residentDirector.FirstName = 'Resident';
        residentDirector.LastName = 'Director';
        Database.insert(new List<User>{fieldDirector, programOwner, residentDirector});
		// Create world
        World__c world = new World__c(Name = 'Global');
		database.insert(world);
		// Create regions
		Region__c international = new Region__c(Name = 'International Support', World__c = world.Id);
		Region__c local = new Region__c(Name = 'Local Support', World__c = world.Id);
		database.insert(new List<Region__c>{international, local});
		// Create countries
		Country__c usa = apexMockDataUtility.createLocalCountry(local.Id);
        Country__c country = apexMockDataUtility.createCountry(international.Id);
		// Create cities
		Locality__c testCity = new Locality__c(Name = 'Test City', Country__c = country.Id);
		database.insert(testCity);
		// Create homeInstitution
        List<Home_Institution__c> homeInstitutions = apexMockDataUtility.createHomeInstitution('Test Institution', 1, usa.Id);
		// Create accounts
        List<Account> accounts = [SELECT Id, Name, Institution__c FROM Account WHERE Institution__c IN: homeInstitutions];
        accounts.get(0).OwnerId = fieldDirector.Id;
        Database.update(accounts);
		// Create schoolAdvisor
        Contact schoolAdvisor = new Contact(AccountId = accounts[0].Id, FirstName = 'Test', LastName = 'Advisor', Email = 'tadvisor@email.test', OwnerId = fieldDirector.Id);
        database.insert(schoolAdvisor);
		// Create hostInstitution
		List<Host_Institution__c> hosts = apexMockDataUtility.createHostInstitutions(country.Id, 3);
		Host_Institution__c hostInstitution = hosts.get(0);        
        // Create program
        Program__c program = apexMockDataUtility.createProgram(hostInstitution.Id, 'Test Existing Program', 'Custom');
        program.Resident_director_team_member__c = residentDirector.Id;
        database.update(program);
        Program__c program1 = apexMockDataUtility.createProgram(hostInstitution.Id, 'Test Catalog Program');
        // Create terms
        List<String> sections = new List<String>{'Spring', 'Fall', 'Summer', 'Winter', 'Calendar Year', 'Academic Year'};
		List<Term__c> terms = apexMockDataUtility.createTerms(sections, Date.today().year());
		Term__c springTerm = terms.get(0);
		Term__c fallTerm = terms.get(1);
        Term__c summerTerm = terms.get(2);
        Term__c winterTerm = terms.get(3);

        //List<Program_Term__c> programTerms = apexMockDataUtility.createProgramTerms(new List<Program__c>{program}, springTerm, programOwner);
        List<Custom_Program_Task_Assignment__c> taskAssignments = new List<Custom_Program_Task_Assignment__c>();
        Id roleRT = Schema.SObjectType.Custom_Program_Task_Assignment__c.getRecordTypeInfosByName().get('Role').getRecordTypeId();        
        /*taskAssignments.add(new Custom_Program_Task_Assignment__c(
            Assign_To__c = 'Program Manager',
            Due_Date_Type__c = 'Proposal Acceptance',
            Due_Date_Units__c = 'Day(s)',
            Due_Date_Number__c = 30,
            Name = 'Program Manager, Proposal Acceptance Task',
            Exclude_From_Service_Only_Programs__c = true,
            RecordTypeId = roleRT
        ));

        taskAssignments.add(new Custom_Program_Task_Assignment__c(
            Assign_To__c = 'Program Advisor',
            Due_Date_Type__c = 'Roster Deadline',
            Due_Date_Units__c = 'Month(s)',
            Due_Date_Number__c = 1,
            Name = 'Program Advisor, Roster Deadline Task',
            RecordTypeId = roleRT
        ));

        taskAssignments.add(new Custom_Program_Task_Assignment__c(
            Assign_To__c = 'Resident Director',
            Due_Date_Type__c = 'Program Start',
            Due_Date_Units__c = 'Day(s)',
            Due_Date_Number__c = 0,
            Name = 'Resident Director, Program Start Task',
            RecordTypeId = roleRT
        ));

        taskAssignments.add(new Custom_Program_Task_Assignment__c(
            Assign_To__c = 'Program Manager',
            Due_Date_Type__c = 'Program End',
            Due_Date_Units__c = 'Week(s)',
            Due_Date_Number__c = 2,
            Name = 'Program Manager, Program End Task',
            RecordTypeId = roleRT
        ));
        
        Database.insert(taskAssignments);*/
        BaseTriggerHandler.clearAllBypasses();
        system.debug('--- makeData End ---');

	}
	@isTest
	public static void testAfterInsert()
	{
		//Creating test Program
		Id homeInstitutionAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId();	
		Account a = [SELECT Id, Direct_Bill__c, Direct_Bill_Summer__c, Direct_Bill_Semester_Year__c, Pays_Tuition__c, RecordTypeId FROM ACCOUNT WHERE recordTypeId = :homeInstitutionAccId LIMIT 1];
		a.Direct_Bill__c = true;
		a.Direct_Bill_Summer__c = true;
		a.Direct_Bill_Semester_Year__c = true;
		a.Pays_Tuition__c = true;
		a.Approves_All_Calendar_Programs__c = true;
		a.Approves_All_Summer_Programs__c = true;
		Account a2 = new Account();
		a2.RecordTypeId = homeInstitutionAccId;
		a2.Name = 'Test School 2';
		a2.Direct_Bill__c = true;
		a2.Direct_Bill_Summer__c = false;
		a2.Direct_Bill_Semester_Year__c = true;
		Account a3 = new Account();
		a3.RecordTypeId = homeInstitutionAccId;
		a3.Name = 'Test School 3';
		a3.Direct_Bill__c = true;
		a3.Direct_Bill_Summer__c = true;
		a3.Direct_Bill_Semester_Year__c = false;
		baseTriggerHandler.bypass('accountTriggerHandler');
		database.upsert(new list<Account>{a, a2, a3 });
		baseTriggerHandler.clearBypass('accountTriggerHandler');
		Country__c country = [SELECT Id FROM Country__c WHERE Name != 'United States' LIMIT 1];

		Billing_Arrangement_Country__c bac = new Billing_Arrangement_Country__c(Account__c = a.Id, Country__c = country.Id, Discount_Amount__c = 1000, Discount_Recipient__c = 'School');
		Billing_Arrangement_Country__c bac2 = new Billing_Arrangement_Country__c(Account__c = a2.Id, Country__c = country.Id, Discount_Amount__c = 1000, Discount_Recipient__c = 'School');
		Billing_Arrangement_Country__c bac3 = new Billing_Arrangement_Country__c(Account__c = a3.Id, Country__c = country.Id, Discount_Amount__c = 1000, Discount_Recipient__c = 'School');
		Database.insert(new List<Billing_Arrangement_Country__c>{bac, bac2, bac3});
		test.startTest();

		Program__c catProgram = new Program__c();
		catProgram.Name = 'Catalog Program';
		catProgram.Category__c = 'Catalog';
		catProgram.Available_Sections__c = 'Spring;Fall';
		catProgram.Country__c = country.Id;
		Program__c custProgram = new Program__c();
		custProgram.Name = 'Custom Program';
		custProgram.Custom_Program_Home_Instituiton_Account__c = a.Id;
		custProgram.Country__c = country.Id;
		custProgram.Category__c = 'Custom';
		custProgram.Available_Sections__c = 'Spring;Fall';
		Database.insert(new List<Program__c>{catProgram, custProgram});
		test.stopTest();
		System.assertNotEquals(catProgram.Id, null, 'Something went wrong while inserting the test Program.');
	}
	@isTest
	public static void testAfterUpdate()
	{
		try
		{
			Test.startTest();
			Id studentId = mockDataUtility.createStudentUserWithApp();
			User studentUser = [SELECT Id, Name, contactId FROM User WHERE Id =: studentId].get(0);
			Contact studentContact = [select Id, FirstName, LastName, Active_Application__c FROM Contact WHERE Id =: studentUser.contactId].get(0);
			Application__c activeApplication = [select Id, Name FROM Application__c WHERE Id =: studentContact.Active_Application__c].get(0);
			Program_Term__c programTerm = [SELECT Id, Program__c FROM Program_Term__c LIMIT 1];
			activeApplication.Program_Term__c = programTerm.Id;
			Program__c program = [SELECT Id, Name FROM Program__c WHERE Id =: programTerm.Program__c];
			
			program.Name = 'new Name test';
			Database.update(program);
			Test.stopTest();
		}
		catch(Exception e)
		{
			System.debug(LoggingLevel.ERROR, e.getMessage());
			System.assertEquals(false, true, 'An Exception was thrown.');
		}
	}
	

}