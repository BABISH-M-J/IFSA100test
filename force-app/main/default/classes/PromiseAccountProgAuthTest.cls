@isTest
public class PromiseAccountProgAuthTest 
{
    @TestSetup
    static void makeData(){
        BaseTriggerHandler.bypass('programTriggerHandler');
        BaseTriggerHandler.bypass('userTriggerHandler');

        User programOwner = apexMockDataUtility.CreateSysAdmin();
        Database.insert(programOwner);
        World__c world = new World__c(Name = 'Global');
		database.insert(world);

		Region__c international = new Region__c(Name = 'International Support', World__c = world.Id);
		Region__c local = new Region__c(Name = 'Local Support', World__c = world.Id);
		database.insert(new List<Region__c>{international, local});

		Country__c usa = apexMockDataUtility.createLocalCountry(local.Id);
        
        Country__c country = apexMockDataUtility.createCountry(international.Id);

		Locality__c testCity = new Locality__c(Name = 'Test City', Country__c = country.Id);
		database.insert(testCity);
		
		List<Host_Institution__c> hosts = apexMockDataUtility.createHostInstitutions(country.Id, 3);
		Host_Institution__c hostInstitution = hosts.get(0);
        
        Host_Institution__c hostInstitution2 = hosts.get(1);

		Host_Institution__c hostInstitution3 = hosts.get(2);

		List<String> names = new List<String>{'Test 1', 'Test 2', 'Test Summer', 'Test Winter'};
		List<Program__c> programs = apexMockDataUtility.createPrograms(hostInstitution, names, programOwner.Id);
		Program__c program = programs.get(0);
		Program__c program2 = programs.get(1);
        Program__c program3 = programs.get(2);
        Program__c program4 = programs.get(3);
        
        List<String> sections = new List<String>{'Spring', 'Fall', 'Summer', 'Winter', 'Calendar Year', 'Academic Year'};
		List<Term__c> terms = apexMockDataUtility.createTerms(sections, Date.today().year());
		Term__c springTerm = terms.get(0);
		Term__c fallTerm = terms.get(1);
        Term__c summerTerm = terms.get(2);
        Term__c winterTerm = terms.get(3);

		List<Program_Term__c> programTerms = apexMockDataUtility.createProgramTerms(new List<Program__c>{program, program2}, springTerm, programOwner);
        programTerms.addAll(apexMockDataUtility.createProgramTerms(new List<Program__c>{program, program2}, fallTerm, programOwner));
        programTerms.addAll(apexMockDataUtility.createProgramTerms(new List<Program__c>{program3}, summerTerm, programOwner));
        programTerms.addAll(apexMockDataUtility.createProgramTerms(new List<Program__c>{program4}, winterTerm, programOwner));
        BaseTriggerHandler.clearAllBypasses();
    }

    @IsTest
    static void testInsertingAccountWithAnApprovesAllSemester()
    {
        User contextuser = new User(Id = UserInfo.getUserId());
        Account testAccount = new Account(
            Name = 'Test University',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId(),
            Approves_All_Calendar_Programs__c = true
        );
        Test.startTest();
        Database.SaveResult sResult;
        System.runAs(contextuser)
        {
            sResult = Database.insert(testAccount);
            Account result = [SELECT Id, Approves_All_Calendar_Programs__c, Updating_Program_Authorizations__c FROM Account WHERE Id =: sResult.getId()];
            System.assertEquals(true, result.Updating_Program_Authorizations__c);
            Object promiseResult = new PromiseAccountProgAuth.ProcessSemseterCalendar().resolve(new List<Account>{testAccount});
            new PromiseAccountProgAuth.AccountProgAuthPromiseDone().done(new List<Account>{testAccount});
        }
        Test.stopTest();
        Account pResult = [SELECT Id, Approves_All_Calendar_Programs__c, Updating_Program_Authorizations__c FROM Account WHERE Id =: sResult.getId()];
        System.assertEquals(false, pResult.Updating_Program_Authorizations__c);
        System.assertEquals(true, pResult.Approves_All_Calendar_Programs__c);
    }

    @IsTest
    static void testUpdatingAccountWithAnApprovesAllSemester()
    {
        User contextuser = new User(Id = UserInfo.getUserId());
        Account testAccount = new Account(
            Name = 'Test University',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId()
        );
        Database.SaveResult sResult;
        sResult = Database.insert(testAccount);
        Account result = [SELECT Id, Approves_All_Calendar_Programs__c, Updating_Program_Authorizations__c FROM Account WHERE Id =: sResult.getId()];
        System.assertEquals(false, result.Updating_Program_Authorizations__c);

        Program__c TestProgram1 = [SELECT Id FROM Program__c WHERE Name = 'Test 1' LIMIT 1].get(0);
        Program_Authorization__c pa = new Program_Authorization__c(Account__c = sResult.getId(), Program__c = TestProgram1.Id, Term__c = 'Spring');
        Database.insert(pa);

        Test.startTest();
        
        Datetime endTime;
        System.runAs(contextuser)
        {
            testAccount.Approves_All_Calendar_Programs__c = true;
            sResult = Database.update(testAccount);
            endTime = Datetime.now();
            
            result = [SELECT Id, Approves_All_Calendar_Programs__c, Updating_Program_Authorizations__c FROM Account WHERE Id =: sResult.getId()];
            System.assertEquals(true, result.Updating_Program_Authorizations__c);
            Object promiseResult = new PromiseAccountProgAuth.ProcessSemseterCalendar().resolve(new List<Account>{testAccount});
            new PromiseAccountProgAuth.AccountProgAuthPromiseDone().done(new List<Account>{testAccount});
        }
        Test.stopTest();
        Account pResult = [SELECT Id, Approves_All_Calendar_Programs__c, Updating_Program_Authorizations__c, Calendar_Approval_Changed_By__c, Calendar_Approval_Changed_Date__c, (SELECT Id, Program__c, Term__c FROM Program_Authorizations__r) FROM Account WHERE Id =: sResult.getId()];
        // Ensure Updating_Program_Authorizations__c == false
        System.assertEquals(false, pResult.Updating_Program_Authorizations__c);
        // Ensure Calendar_Approval_Changed_By__c == UserInfo.getUserId()
        System.assertEquals(UserInfo.getUserId(), pResult.Calendar_Approval_Changed_By__c);
        // Ensure Calendar_Approval_Changed_Date__c < 1500 milliseconds different than endTime
        Long between = endTime.getTime() - pResult.Calendar_Approval_Changed_Date__c.getTime();
        System.assertEquals(true, between < 1500);
        // Ensure Updating_Program_Authorizations__c == true
        System.assertEquals(true, pResult.Approves_All_Calendar_Programs__c);
        // Ensure Program_Authorizations__r.isEmpty() == false
        System.assertEquals(false, pResult.Program_Authorizations__r.isEmpty());
        // Ensure Program_Authorizations__r.size() == 2
        System.assertEquals(2, pResult.Program_Authorizations__r.size());
        // Ensure Program_Authorizations__r[0].Term__c contains "Spring"
        System.assertEquals(true, pResult.Program_Authorizations__r[0].Term__c.contains('Spring'));
        // Ensure Program_Authorizations__r[0].Term__c contains "Fall"
        System.assertEquals(true, pResult.Program_Authorizations__r[0].Term__c.contains('Fall'));
        // Ensure Program_Authorizations__r[0].Term__c contains "Spring"
        System.assertEquals(true, pResult.Program_Authorizations__r[1].Term__c.contains('Spring'));
        // Ensure Program_Authorizations__r[0].Term__c contains "Fall"
        System.assertEquals(true, pResult.Program_Authorizations__r[1].Term__c.contains('Fall'));
    }

    @IsTest
    static void testInsertingAccountWithAnApprovesAllSummer()
    {
        User contextuser = new User(Id = UserInfo.getUserId());
        Account testAccount = new Account(
            Name = 'Test University',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId(),
            Approves_All_Summer_Programs__c = true
        );
        Test.startTest();
        Database.SaveResult sResult;
        System.runAs(contextuser)
        {
            sResult = Database.insert(testAccount);
            Account result = [SELECT Id, Approves_All_Summer_Programs__c, Updating_Program_Authorizations__c FROM Account WHERE Id =: sResult.getId()];
            System.assertEquals(true, result.Updating_Program_Authorizations__c);
            Object promiseResult = new PromiseAccountProgAuth.ProcessSummer().resolve(new List<Account>{testAccount});
            new PromiseAccountProgAuth.AccountProgAuthPromiseDone().done(new List<Account>{testAccount});
        }
        Test.stopTest();
        Account pResult = [SELECT Id, Approves_All_Summer_Programs__c, Updating_Program_Authorizations__c FROM Account WHERE Id =: sResult.getId()];
        System.assertEquals(false, pResult.Updating_Program_Authorizations__c);
        System.assertEquals(true, pResult.Approves_All_Summer_Programs__c);
    }

    @IsTest
    static void testUpdatingAccountWithAnApprovesAllSummer()
    {
        User contextuser = new User(Id = UserInfo.getUserId());
        Account testAccount = new Account(
            Name = 'Test University',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId()
        );
        Test.startTest();
        Database.SaveResult sResult;
        Datetime endTime;
        System.runAs(contextuser)
        {
            sResult = Database.insert(testAccount);
            Account result = [SELECT Id, Approves_All_Summer_Programs__c, Updating_Program_Authorizations__c FROM Account WHERE Id =: sResult.getId()];
            System.assertEquals(false, result.Updating_Program_Authorizations__c);
            testAccount.Approves_All_Summer_Programs__c = true;
            sResult = Database.update(testAccount);
            endTime = Datetime.now();
            result = [SELECT Id, Approves_All_Summer_Programs__c, Updating_Program_Authorizations__c FROM Account WHERE Id =: sResult.getId()];
            System.assertEquals(true, result.Updating_Program_Authorizations__c);
            Object promiseResult = new PromiseAccountProgAuth.ProcessSummer().resolve(new List<Account>{testAccount});
            new PromiseAccountProgAuth.AccountProgAuthPromiseDone().done(new List<Account>{testAccount});
        }
        Test.stopTest();
        Account pResult = [SELECT Id, Approves_All_Summer_Programs__c, Updating_Program_Authorizations__c, Summer_Approval_Changed_By__c, Summer_Approval_Changed_Date__c FROM Account WHERE Id =: sResult.getId()];
        System.assertEquals(false, pResult.Updating_Program_Authorizations__c);
        System.assertEquals(true, pResult.Approves_All_Summer_Programs__c);
        // Ensure Summer_Approval_Changed_By__c == UserInfo.getUserId()
        System.assertEquals(UserInfo.getUserId(), pResult.Summer_Approval_Changed_By__c);
        // Ensure Summer_Approval_Changed_Date__c < 1500 milliseconds different than endTime
        Long between = endTime.getTime() - pResult.Summer_Approval_Changed_Date__c.getTime();
        System.assertEquals(true, between < 1500);
    }

    @IsTest
    static void testInsertingAccountWithAnApprovesAllWinter()
    {
        User contextuser = new User(Id = UserInfo.getUserId());
        Account testAccount = new Account(
            Name = 'Test University',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId(),
            Approves_All_Winter_Programs__c = true
        );
        Test.startTest();
        Database.SaveResult sResult;
        System.runAs(contextuser)
        {
            sResult = Database.insert(testAccount);
            Account result = [SELECT Id, Approves_All_Winter_Programs__c, Updating_Program_Authorizations__c FROM Account WHERE Id =: sResult.getId()];
            System.assertEquals(true, result.Updating_Program_Authorizations__c);
            Object promiseResult = new PromiseAccountProgAuth.ProcessWinter().resolve(new List<Account>{testAccount});
            new PromiseAccountProgAuth.AccountProgAuthPromiseDone().done(new List<Account>{testAccount});
        }
        Test.stopTest();
        Account pResult = [SELECT Id, Approves_All_Winter_Programs__c, Updating_Program_Authorizations__c FROM Account WHERE Id =: sResult.getId()];
        System.assertEquals(false, pResult.Updating_Program_Authorizations__c);
        System.assertEquals(true, pResult.Approves_All_Winter_Programs__c);
    }

    @IsTest
    static void testUpdatingAccountWithAnApprovesAllWinter()
    {
        User contextuser = new User(Id = UserInfo.getUserId());
        Account testAccount = new Account(
            Name = 'Test University',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId()
        );
        Test.startTest();
        Database.SaveResult sResult;
        Datetime endTime;
        System.runAs(contextuser)
        {
            sResult = Database.insert(testAccount);
            Account result = [SELECT Id, Approves_All_Winter_Programs__c, Updating_Program_Authorizations__c FROM Account WHERE Id =: sResult.getId()];
            System.assertEquals(false, result.Updating_Program_Authorizations__c);
            testAccount.Approves_All_Winter_Programs__c = true;
            sResult = Database.update(testAccount);
            endTime = Datetime.now();
            result = [SELECT Id, Approves_All_Winter_Programs__c, Updating_Program_Authorizations__c FROM Account WHERE Id =: sResult.getId()];
            System.assertEquals(true, result.Updating_Program_Authorizations__c);
            Object promiseResult = new PromiseAccountProgAuth.ProcessWinter().resolve(new List<Account>{testAccount});
            new PromiseAccountProgAuth.AccountProgAuthPromiseDone().done(new List<Account>{testAccount});
        }
        Test.stopTest();
        Account pResult = [SELECT Id, Approves_All_Winter_Programs__c, Updating_Program_Authorizations__c, Winter_Approval_Changed_Date__c, Winter_Approval_Changed_By__c FROM Account WHERE Id =: sResult.getId()];
        System.assertEquals(false, pResult.Updating_Program_Authorizations__c);
        System.assertEquals(true, pResult.Approves_All_Winter_Programs__c);
        // Ensure Winter_Approval_Changed_By__c == UserInfo.getUserId()
        System.assertEquals(UserInfo.getUserId(), pResult.Winter_Approval_Changed_By__c);
        // Ensure Winter_Approval_Changed_Date__c < 1500 milliseconds different than endTime
        Long between = endTime.getTime() - pResult.Winter_Approval_Changed_Date__c.getTime();
      
        System.assertEquals(true, between < 1500);
        
    }

    @IsTest
    static void testError()
    {
        User contextuser = new User(Id = UserInfo.getUserId());
        
        Test.startTest();
        
        System.runAs(contextuser)
        {
            PromiseAccountProgAuth.AccountProgAuthPromiseError promiseError = new PromiseAccountProgAuth.AccountProgAuthPromiseError();
            try
            {
                integer i = 1/0;
            }
            catch (Exception e)
            {
                promiseError.error(e);                
            }
        }
        Test.stopTest();
    }
    @IsTest
    static void testObjectInstance()
    {
        User contextuser = new User(Id = UserInfo.getUserId());
        Account testAccount = new Account(
            Name = 'Test University',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId(),
            Approves_All_Calendar_Programs__c = true,
            Approves_All_Summer_Programs__c = true,
            Approves_All_Winter_Programs__c = true
        );
        Database.SaveResult sResult;
        BaseTriggerHandler.bypass('accountTriggerHandler');
        sResult = Database.insert(testAccount);
        
        Test.startTest();
        
        System.runAs(contextuser)
        {
            //Test object with null parma
            /* try {
                new PromiseAccountProgAuth(null);
            } catch (NullPointerException e) {
                System.debug(LoggingLevel.INFO, 'This was expected');
            } */
            //Test object with account
            new PromiseAccountProgAuth(new List<Account>{testAccount});
        }
        Test.stopTest();
    }
}