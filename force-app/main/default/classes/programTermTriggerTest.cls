@isTest
public without sharing class programTermTriggerTest
{
	@TestSetup
    static void makeData(){
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'CMS'});
    }
	public static testMethod void test_TG_ProgramTerm_Valid()
	{
		Id sysAdminProfile = [SELECT Id FROM Profile WHERE Name =: 'System Administrator'].Id;

		User admin = [SELECT Id FROM User WHERE ProfileId = :sysAdminProfile AND isActive = true LIMIT 1];
		Test.startTest();
 
		//Creating test Program
		Program__c testProgram = [SELECT Id, Country__c FROM Program__c LIMIT 1];
		//testProgram.Id = null;
		testProgram.Name = 'University of Test Program';
		testProgram.Available_Sections__c = 'Spring';
		Database.update(testProgram);

        //Creating test Term
        Term__c testTerm = new Term__c();
        testTerm.Name = 'Spring 5555';
        testTerm.Section__c = 'Spring';
        testTerm.Year__c = 5555;
        Database.Insert(testTerm);
        System.assertNotEquals(null, testTerm.Id, 'Something went wrong while inserting the test Term.');

		//Creating test Program Term
		Program_Term__c testProgramTerm = new Program_Term__c();
		testProgramTerm.Name = 'University of Test Program Spring 5555';
		testProgramTerm.Program__c = testProgram.Id;
		testProgramTerm.Country__c = testProgram.Country__c;
		testProgramTerm.Term__c = testTerm.Id;
		Database.Insert(testProgramTerm);
		System.assertNotEquals(null, testProgramTerm.Id, 'Something went wrong while inserting the test Program Term.');

		testProgram = [SELECT Id, Available_Sections__c FROM Program__c WHERE Id =: testProgram.Id];
        system.debug('testprogram...........' + testProgram);
		System.assertEquals(true, testProgram.Available_Sections__c.contains('Spring'));

		Program_Term__c testProgramTerm2 = [SELECT Id, Name FROM Program_Term__c WHERE Id =: testProgramTerm.Id];
		System.assertEquals('Test Program Spring 5555', testProgramTerm2.Name, 'The names did not match.');

		testProgramTerm2.OwnerId = admin.Id;
		Database.SaveResult result = Database.update(testProgramTerm2);
		System.assertEquals(result.isSuccess(), true, 'OwnerId does not match.');

		Database.delete(testProgramTerm2);

		Test.stopTest();
	}

	public static testMethod void programDatesTest()
	{
        Term__c term = new Term__c();
        term.Name = 'Spring 2022';
        term.Section__c = 'Spring';
        term.Year__c = 2022;
        insert term;
        system.debug('term.....>' +term);
        
        World__c wrd = new World__c();
        wrd.Name = 'germany';
        wrd.CurrencyIsoCode = 'USD';
        Database.Insert(wrd);
        
        
		List<CMS__c> cmsList = [SELECT Id, 
								SF_Program__c, 
								Spring_Program_Term__c, 
								Summer_Program_Term__c 
								FROM CMS__c];
        //cmsList.Summer_Program_Term__c = ''
		system.debug('cmsList......'+cmsList[0]);
        system.debug('cmsList......'+cmsList[0].SF_Program__c);
        system.debug('cmsList......'+cmsList[0].Spring_Program_Term__c);
        system.debug('cmsList......'+cmsList[0].Summer_Program_Term__c);
		CMS__c program1CMS = cmsList[0];
        
		CMS__c program2CMS = cmsList[1];

		CMS__c program2aCMS = new CMS__c(SF_Program__c = program2CMS.SF_Program__c);
		program2aCMS.Name__c = 'Test Option 1';
		CMS__c program2bCMS = new CMS__c(SF_Program__c = program2CMS.SF_Program__c);
		program2aCMS.Name__c = 'Test Option 2';
		CMS__c program1Summer1CMS = new CMS__c(SF_Program__c = program1CMS.SF_Program__c);
		program1Summer1CMS.Name__c = 'Summer 1';
		CMS__c program1Summer12CMS = new CMS__c(SF_Program__c = program1CMS.SF_Program__c);
		program1Summer12CMS.Name__c = 'Summer 1 & 2';
		CMS__c program1Summer123CMS = new CMS__c(SF_Program__c = program1CMS.SF_Program__c);
		program1Summer123CMS.Name__c = 'Summer 1, 2, & 3';
		CMS__c program1Summer2CMS = new CMS__c(SF_Program__c = program1CMS.SF_Program__c);
		program1Summer2CMS.Name__c = 'Summer 2';
		CMS__c program1Summer23CMS = new CMS__c(SF_Program__c = program1CMS.SF_Program__c);
		program1Summer23CMS.Name__c = 'Summer 2 & 3';

		Database.insert(new List<CMS__c>{program2aCMS, program2bCMS, program1Summer1CMS, program1Summer12CMS, program1Summer123CMS, program1Summer2CMS, program1Summer23CMS});
		system.debug('program2aCMS.....>' + program2aCMS);
		List<Program_Term__c> programTermList = [SELECT Id, 
												 Start_Date__c, 
												 Name, Program__c, 
												 Country__c, 
												 Date_Approval_Status__c,
												 Arrival_Window_Start_Time__c,
												 RecordTypeId
												 FROM Program_Term__c];

		Program_Term__c spring = programTermList[0];
		spring.Start_Date__c = Date.today();
		spring.Name = 'Test Spring 2000';
		
		Program_Term__c ptWithOptions = programTermList[1];
		ptWithOptions.RecordTypeId = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Parent Program Term without Dates').getRecordTypeId();

		// Create Program Options
		Id ptRecordId = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option without Dates').getRecordTypeId();
		
		Program_Term__c pOption1 = [SELECT Id, 
									Name, 
									Start_Date__c, 
									RecordTypeId, 
									Program__c, 
									Country__c, 
									Parent_Program_Term__c 
									FROM Program_Term__c 
									WHERE RecordTypeId = :ptRecordId LIMIT 1];

		pOption1.Name = 'Test Option 1';
		pOption1.Start_Date__c = Date.today().addDays(2);
		pOption1.RecordTypeId = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option with Dates').getRecordTypeId();
		Program_Term__c pOption2 = new Program_Term__c(Program__c = pOption1.Program__c, Country__c = pOption1.Country__c, RecordTypeId = pOption1.RecordTypeId, Parent_Program_Term__c = pOption1.Parent_Program_Term__c);
		pOption2.Start_Date__c = Date.today().addDays(5);
		pOption2.Name = 'Test Option 2';
		
		// Create Summer and Fall Program Terms
		Program_Term__c summer = new Program_Term__c(Program__c = spring.Program__c, Country__c = spring.Country__c, RecordTypeId = ptWithOptions.RecordTypeId);
		summer.Name = 'Test Summer 2000';
		summer.Term__c = [SELECT Id FROM Term__c WHERE Section__c = 'Summer' LIMIT 1].Id;
		summer.Start_Date__c = Date.today().addMonths(2);
		// Create Summer Session Options
		Program_Term__c session1 = new Program_Term__c(Program__c = summer.Program__c, Term__c = summer.Term__c, Country__c = summer.Country__c, RecordTypeId = pOption1.RecordTypeId, Parent_Program_Term__c = summer.Id);
		session1.Name = 'Test Summer 2000 Session 1';
		session1.Start_Date__c = summer.Start_Date__c;
		Program_Term__c session12 = new Program_Term__c(Program__c = summer.Program__c, Term__c = summer.Term__c, Country__c = summer.Country__c, RecordTypeId = session1.RecordTypeId, Parent_Program_Term__c = summer.Id);
		session12.Name = 'Test Summer 2000 Sessions 1 & 2';
		session12.Start_Date__c = summer.Start_Date__c;
		Program_Term__c session123 = new Program_Term__c(Program__c = summer.Program__c, Term__c = summer.Term__c, Country__c = summer.Country__c, RecordTypeId = session1.RecordTypeId, Parent_Program_Term__c = summer.Id);
		session123.Name = 'Test Summer 2000 Sessions 1, 2, & 3';
		session123.Start_Date__c = summer.Start_Date__c;
		Program_Term__c session2 = new Program_Term__c(Program__c = summer.Program__c, Term__c = summer.Term__c, Country__c = summer.Country__c, RecordTypeId = session1.RecordTypeId, Parent_Program_Term__c = summer.Id);
		session2.Start_Date__c = session1.Start_Date__c.addDays(25);
		session2.Name = 'Test Summer 2000 Session 2';
		Program_Term__c session23 = new Program_Term__c(Program__c = summer.Program__c, Term__c = summer.Term__c, Country__c = summer.Country__c, RecordTypeId = session1.RecordTypeId, Parent_Program_Term__c = summer.Id);
		session23.Start_Date__c = session2.Start_Date__c;
		session23.Name = 'Test Summer 2000 Sessions 2 & 3';
		Program_Term__c fall = new Program_Term__c(Program__c = spring.Program__c, Country__c = spring.Country__c, RecordTypeId = spring.RecordTypeId);
		fall.Name = 'Test Fall 2000';
		fall.Term__c = [SELECT Id FROM Term__c WHERE Section__c = 'Fall' LIMIT 1].Id;
		fall.Start_Date__c = Date.today().addMonths(4);	
		List<Database.upsertResult> res1 = Database.upsert(new List<Program_Term__c>{spring, summer, session1, session12, session123, session2, session23, fall, ptWithOptions, pOption1, pOption2});
		System.debug('res1....'+res1);
		// Link Program Terms with CMS records
		program1CMS.Spring_Program_Term__c = spring.Id;
		program1CMS.Summer_Program_Term__c = summer.Id;
		program1Summer1CMS.Summer_Program_Term__c = session1.Id;
		program1Summer12CMS.Summer_Program_Term__c = session12.Id;
		program1Summer123CMS.Summer_Program_Term__c = session123.Id;
		program1Summer2CMS.Summer_Program_Term__c = session2.Id;
		program1Summer23CMS.Summer_Program_Term__c = session23.Id;
		program1CMS.Fall_Program_Term__c = fall.Id;
		// program2CMS.Spring_Program_Term__c = ptWithOptions.Id;
		// program2aCMS.Spring_Program_Term__c = pOption1.Id;

		program2aCMS.Summer_Program_Term__c =summer.Id;
		
		system.debug('program2aCMS..>'+program2aCMS.Spring_Program_Term__c);
		program2bCMS.Spring_Program_Term__c = pOption2.Id;
		
        system.debug('program1CMS...> '+program1CMS);
        system.debug('program2CMS...> '+program2CMS);
        system.debug('program2aCMS...> '+program2aCMS);
        
		//Database.update(new List<CMS__c>{program1CMS, program2CMS, program2aCMS, program2bCMS, program1Summer1CMS, program1Summer12CMS, program1Summer123CMS, program1Summer2CMS, program1Summer23CMS});
    	List<Database.SaveResult> res = Database.update(new List<CMS__c>{program1CMS,program2CMS,program2aCMS,program2bCMS,program1Summer1CMS,program1Summer12CMS,program1Summer123CMS,program1Summer2CMS,program1Summer23CMS});
		System.debug('res....'+res);
        
		Map<Id, SObject> programCMS = new Map<Id, SObject>(apexQueryUtility.selectAllFrom('CMS__c', 'Id IN (\'' + program1CMS.Id + '\', \'' + program2CMS.Id + '\')'));
		program1CMS = (CMS__c) programCMS.get(program1CMS.Id);		
		system.assertNotEquals(apexTextUtility.formatDate(Date.today()), program1CMS.SPRING_Program_Start_Date__c, 'The formatted dates should not be equal');

		Test.startTest();

		spring.Date_Approval_Status__c = 'Approved';
		summer.Date_Approval_Status__c = 'Approved';
		session1.Date_Approval_Status__c = 'Approved';
		session12.Date_Approval_Status__c = 'Approved';
		session123.Date_Approval_Status__c = 'Approved';
		session2.Date_Approval_Status__c = 'Approved';
		session23.Date_Approval_Status__c = 'Approved';
		fall.Date_Approval_Status__c = 'Approved';		
		pOption1.Date_Approval_Status__c = 'Approved';
		pOption2.Date_Approval_Status__c = 'Approved';
		
		Database.update(new List<Program_Term__c>{spring, summer, session1, session12, session123, session2, session23, fall, pOption1, pOption2});

		spring.Date_Approval_Status__c = 'Draft';
		spring.Start_Date__c = spring.Start_Date__c.addDays(3);
		
		
		
		programCMS = new Map<Id, SObject>(apexQueryUtility.selectAllFrom('CMS__c', 'Id IN (\'' + program1CMS.Id + '\', \'' + program2CMS.Id + '\')'));
		program1CMS = (CMS__c) programCMS.get(program1CMS.Id);
		Program_Term__c pt = (Program_Term__c) apexQueryUtility.selectAllFrom('Program_Term__c', 'Id = \'' + spring.Id + '\'').get(0);
		system.assertEquals(Date.today(), pt.Start_Date__c, 'The dates are not equal');
		system.assertEquals('Approved', pt.Date_Approval_Status__c, 'The statuses are not equal');
		system.assertnotEquals(apexTextUtility.formatDate(Date.today()), program1CMS.SPRING_Program_Start_Date__c, 'The formatted dates are not equal');

		spring.Date_Approval_Status__c = 'Draft';
		spring.Arrival_Window_Start_Time__c = '10:00 AM';
		spring.Start_Date__c = spring.Start_Date__c.addDays(3);

		Database.update(spring);
		String subject = spring.Name + ' - Dates have changed';
		List<Task> testTasks = [SELECT Id, Subject, Description, OwnerId FROM Task WHERE Subject =: subject];
		system.assertnotEquals(2, testTasks.size(), 'Expecting one task with the subject \'' + subject + '\'');
		//system.debug(testTasks.get(0).Description);
		Boolean hasWebsiteUpdateTask = false;
		Id websiteUpdateUserId = [SELECT User_Id__c FROM IFSA_Default_User__mdt WHERE DeveloperName = 'Website_Update'].get(0).User_Id__c;
		for(Task t: testTasks)
		{
			if(t.OwnerId == websiteUpdateUserId)
			{
				hasWebsiteUpdateTask = true;
				break;
			}
		}
		System.assertnotEquals(true, hasWebsiteUpdateTask);

		Test.stopTest();
	}

	@isTest
	public static void testTermsForProgramsSelector(){
		try {
			Country__c country = [SELECT Id FROM Country__c WHERE Name != 'United States' LIMIT 1];

			Test.startTest();
			programTermService.getTermsForProgramSelector(country.Id);
			Test.stopTest();
		} catch (Exception e) {
			system.debug(LoggingLevel.ERROR, e.getMessage());
		}
	}

	@isTest
	public static void testGetProgramTermsForProgramSelector()
	{
		// Need Country, Semester, and HomeInst ALL STRINGS!
		Home_Institution__c testHI = [SELECT Id, Name FROM Home_Institution__c LIMIT 1];
		Program_Term__c testPT = [SELECT Id, Term__r.Section__c, Program__r.Country__c, Program__c FROM Program_Term__c WHERE Program__c != NULL AND Term__c != NULL LIMIT 1];
		System.debug(LoggingLevel.ERROR, 'testPT => ' + testPT);
		Restricted_Program__c testRP = new Restricted_Program__c(Program__c = testPT.Program__c, Home_Institution__c = testHI.Id);
		Database.insert(testRP);
		programTermService.getProgramTermsForProgramSelector(testPT.Program__r.Country__c, testPT.Term__r.Section__c, testHI.Name);
	}
    @isTest
	public static void testGetProgramTermsForProgramSelector1()
    {
    	String Query='SELECT Id, Name,Country_Name__c FROM Program_Term__c';
    	applicationOwnerUpdateService updateQ= new applicationOwnerUpdateService(Query);
        Database.executeBatch (updateQ);
        
       
    }
    @isTest
	public static void testupdateProgramAvailableSections()
    {
       // List<Program_Term__c> listPrterm = new List<Program_Term__c>();
        //Program_Term__c prterm = new Program_Term__c();
       // prterm
        World__c wrd = new World__c();
        wrd.Name = 'Germany';
        Database.Insert(wrd);
        Region__c reg = new Region__c();
        system.debug('reg...' + reg);
        reg.Name = 'International Airport';
        reg.World__c = wrd.Id;
        DataBase.Insert(reg);
        system.debug('reg....' + reg);
        Country__c cut = new Country__c();
        cut.Name = 'India';
        cut.Region__c = reg.Id;
        DataBase.Insert(cut);
    }
}