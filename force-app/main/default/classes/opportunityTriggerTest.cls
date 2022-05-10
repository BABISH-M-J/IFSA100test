/**
 * @description Unit tests for opportunityTrigger, opportunityTriggerHandler and opportunityService
 * @author Brock Barlow
 */
@isTest
public class opportunityTriggerTest 
{
    static User contextuser()
    {
        return new User(Id = UserInfo.getUserId());
    }

    @TestSetup
    static void makeData()
    {
        system.debug('--- makeData Start ---');
        BaseTriggerHandler.bypass('programTriggerHandler');
        BaseTriggerHandler.bypass('userTriggerHandler');
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
        World__c world = new World__c(Name = 'Global');
		database.insert(world);

		Region__c international = new Region__c(Name = 'International Support', World__c = world.Id);
		Region__c local = new Region__c(Name = 'Local Support', World__c = world.Id);
		database.insert(new List<Region__c>{international, local});

		Country__c usa = apexMockDataUtility.createLocalCountry(local.Id);
        
        Country__c country = apexMockDataUtility.createCountry(international.Id);

		Locality__c testCity = new Locality__c(Name = 'Test City', Country__c = country.Id);
		database.insert(testCity);
        List<Home_Institution__c> homeInstitutions = apexMockDataUtility.createHomeInstitution('Test Institution', 1, usa.Id);
        List<Account> accounts = [SELECT Id, Name, Institution__c FROM Account WHERE Institution__c IN: homeInstitutions];
        accounts.get(0).OwnerId = fieldDirector.Id;
        Database.update(accounts);

        Contact schoolAdvisor = new Contact(AccountId = accounts[0].Id, FirstName = 'Test', LastName = 'Advisor', Email = 'tadvisor@email.test', OwnerId = fieldDirector.Id);
        database.insert(schoolAdvisor);

		List<Host_Institution__c> hosts = apexMockDataUtility.createHostInstitutions(country.Id, 3);
		Host_Institution__c hostInstitution = hosts.get(0);        
        
        Program__c program = apexMockDataUtility.createProgram(hostInstitution.Id, 'Test Existing Program', 'Custom');
        program.Resident_director_team_member__c = residentDirector.Id;
        database.update(program);
        Program__c program1 = apexMockDataUtility.createProgram(hostInstitution.Id, 'Test Catalog Program');
        
        List<String> sections = new List<String>{'Spring', 'Fall', 'Summer', 'Winter', 'Calendar Year', 'Academic Year'};
		List<Term__c> terms = apexMockDataUtility.createTerms(sections, Date.today().addDays(90).year());
		Term__c springTerm = terms.get(0);
		Term__c fallTerm = terms.get(1);
        Term__c summerTerm = terms.get(2);
        Term__c winterTerm = terms.get(3);

        List<Program_Term__c> programTerms = apexMockDataUtility.createProgramTerms(new List<Program__c>{program}, springTerm, programOwner);
        List<Custom_Program_Task_Assignment__c> taskAssignments = new List<Custom_Program_Task_Assignment__c>();
        Id roleRT = Schema.SObjectType.Custom_Program_Task_Assignment__c.getRecordTypeInfosByName().get('Role').getRecordTypeId();        
        taskAssignments.add(new Custom_Program_Task_Assignment__c(
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
        
        Database.insert(taskAssignments);
        BaseTriggerHandler.clearAllBypasses();
        system.debug('--- makeData End ---');
    }

    @IsTest
    static void testUpdateAmmount(){
        Account schoolAccount = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Home Institution' LIMIT 1].get(0);
        Contact schoolAdvisor = [SELECT Id, Name FROM Contact WHERE AccountId =: schoolAccount.Id LIMIT 1].get(0);
        Country__c country = [SELECT Id, Name FROM Country__c WHERE Name = 'England' LIMIT 1].get(0);
        Locality__c city = [SELECT Id, Name FROM Locality__c WHERE Name = 'Test City'];
        
        Id oppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Custom Program (New)').getRecordTypeId();
        Integer fee = 2000;
        Decimal profit = 500;
        Integer enrollment = 10;
        Opportunity o = new Opportunity(
            RecordTypeId = oppRT,
            Country__c = country.Id,
            City__c = city.Id,
            AccountId = schoolAccount.Id,
            Sending_Institution_Advisor__c = schoolAdvisor.Id,
            Program_Name__c = 'New Custom Program',
            Projected_Enrollment__c = enrollment,
            Fee__c = fee,
            StageName = 'Lead',
            Name = 'Test Oppy',
            CloseDate = Date.today().addDays(90),
            Profit__c = profit
        );
        Formula.recalculateFormulas(new List<Opportunity>{o});
        //System.debug(o.Program_Operation_Status2__c);
        Test.startTest();
        System.runAs(contextuser())
        {    
            Database.insert(o);
            o = [SELECT Id, Amount FROM Opportunity WHERE Id =: o.Id];
            System.assertEquals(enrollment * profit, o.Amount);
            // enrollment = 9;
            // o.Final_Enrollment__c = enrollment;
            // Database.update(o);
            // o = [SELECT Id, Amount FROM Opportunity WHERE Id =: o.Id];
            // System.assertEquals(enrollment * profit, o.Amount);
            // Database.update(o);
        }
        Test.stopTest();        
    }

    @IsTest
    static void testClosedWonCatalog(){
        Id userId = contextuser().Id;
        Account schoolAccount = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Home Institution' LIMIT 1].get(0);
        Program__c program = [SELECT Id, Name FROM Program__c WHERE Category__c = 'Catalog' LIMIT 1].get(0);
        Opportunity o = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Program Approval').getRecordTypeId(),
            Program__c = program.Id,
            AccountId = schoolAccount.Id,
            StageName = 'Collaborate with Campus',
            Name = 'Test Oppy',
            CloseDate = Date.today().addDays(90),
            OwnerId = userId
        );

        
        Database.insert(o);
        Test.startTest();
        System.runAs(contextuser())
        {
            o.StageName = 'Program Approved';
            database.update(o);
        }
        Test.stopTest();
    }
    @IsTest
    static void testClosedWonCustomNoExistingProgram(){
        Id userId = contextuser().Id;
        //System.debug(userId);
        Account schoolAccount = [SELECT Id, Name, OwnerId FROM Account WHERE RecordType.Name = 'Home Institution' LIMIT 1].get(0);
        Contact schoolAdvisor = [SELECT Id, Name, OwnerId FROM Contact WHERE AccountId =: schoolAccount.Id LIMIT 1].get(0);
        Country__c country = [SELECT Id, Name FROM Country__c WHERE Name = 'England' LIMIT 1].get(0);
        Locality__c city = [SELECT Id, Name FROM Locality__c WHERE Name = 'Test City'];
        Program_Term__c programTerm = [SELECT Id, OwnerId, Program__r.Resident_director_team_member__c FROM Program_Term__c WHERE Term__r.Section__c = 'Spring' LIMIT 1].get(0);
        Integer fee = 2000;
        Date startDate = Date.today().addDays(90);
        Opportunity o = new Opportunity();
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Custom Program (New)').getRecordTypeId();
        o.Country__c = country.Id;
        o.City__c = city.Id;
        o.AccountId = schoolAccount.Id;
        o.Sending_Institution_Advisor__c = schoolAdvisor.Id;
        o.Program_Name__c = 'New Custom Program';
        o.Projected_Enrollment__c = 10;
        o.Fee__c = fee;
        o.StageName = 'Lead';
        o.Name = 'Test Oppy';
        o.CloseDate = Date.today().addDays(90);
        o.Term__c = 'Spring';
        o.Year__c = String.valueOf(startDate.year());
        o.Length_in_Weeks__c = 4;
        o.Start_Date__c = startDate;
        o.End_Date__c = Date.today().addDays(90 + (4 * 7));
        o.Roster_Deadline__c = Date.today().addDays(45);
        o.Program_Advisor__c = programTerm.OwnerId;
        o.OwnerId = userId;
        o.Resident_Director__c = programTerm.Program__r.Resident_director_team_member__c;
        o.Field_Director__c = schoolAccount.OwnerId;
        o.Profit__c = 500;
        o = testCustom(o);
        o = [SELECT Id, Program_Term__c, Program__c FROM Opportunity WHERE Id =: o.Id];
        System.assertNotEquals(null, o.Program__c);
        System.assertNotEquals(null, o.Program_Term__c);
        List<Application__c> apps = new List<Application__c>();
        for(Contact c: [SELECT Id FROM Contact WHERE RecordType.Name = 'Student'])
        {
            apps.add(new Application__c(Applicant__c = c.Id, Status__c = 'Program Selected', Program_Term__c = o.Program_Term__c));
        }
        contactTriggerHandler.bypassTrigger = true;
        Database.insert(apps);
        contactTriggerHandler.bypassTrigger = false;
        Database.update(o);
        o = [SELECT Id, Program_Term__c, Program__c, Amount, Profit__c, Final_Enrollment_Formula__c FROM Opportunity WHERE Id =: o.Id];
        //System.assertEquals(o.Profit__c * o.Final_Enrollment_Formula__c, o.Amount);
    }
    @IsTest
    static void testClosedWonCustomNoExistingServiceOnlyProgram(){
        system.debug('testClosedWonCustomNoExistingServiceOnlyProgram Start');
        Id userId = contextuser().Id;
        //System.debug(userId);
        Account schoolAccount = [SELECT Id, Name, OwnerId FROM Account WHERE RecordType.Name = 'Home Institution' LIMIT 1].get(0);
        Contact schoolAdvisor = [SELECT Id, Name, OwnerId FROM Contact WHERE AccountId =: schoolAccount.Id LIMIT 1].get(0);
        Country__c country = [SELECT Id, Name FROM Country__c WHERE Name = 'England' LIMIT 1].get(0);
        Locality__c city = [SELECT Id, Name FROM Locality__c WHERE Name = 'Test City'];
        Program_Term__c programTerm = [SELECT Id, OwnerId, Program__r.Resident_director_team_member__c, Term__c, Applicant_Count__c, Applicant_Count_Parent_PT__c FROM Program_Term__c WHERE Term__r.Section__c = 'Spring' LIMIT 1].get(0);
        //programTerm.Applicant_Count__c = 10;
        //system.debug(LoggingLevel.ERROR, 'programTerm to update => ' + programTerm.Id);
        //Database.update(programTerm);
        Database.delete(programTerm.Id);
        Integer fee = 2000;
        Date startDate = Date.today().addDays(90);
        Opportunity o = new Opportunity();
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Custom Program (New)').getRecordTypeId();
        o.Country__c = country.Id;
        o.City__c = city.Id;
        o.AccountId = schoolAccount.Id;
        o.Sending_Institution_Advisor__c = schoolAdvisor.Id;
        o.Program_Name__c = 'New Custom Program';
        o.Projected_Enrollment__c = 10;
        o.Fee__c = fee;
        o.StageName = 'Lead';
        o.Name = 'Test Oppy';
        o.CloseDate = Date.today().addDays(90);
        o.Term__c = 'Spring';
        o.Year__c = String.valueOf(startDate.year());
        o.Length_in_Weeks__c = 4;
        o.Start_Date__c = startDate;
        o.End_Date__c = Date.today().addDays(90 + (4 * 7));
        o.Roster_Deadline__c = Date.today().addDays(45);
        o.Program_Advisor__c = programTerm.OwnerId;
        o.OwnerId = userId;
        o.Resident_Director__c = programTerm.Program__r.Resident_director_team_member__c;
        o.Field_Director__c = schoolAccount.OwnerId;
        o.Profit__c = 500;
        o.Service_Only__c = true;
        //o.Program_Term__c = programTerm.Id;

        // Testing before list
        List<Program_Term__c> beforePTList = [SELECT Id FROM Program_Term__c WHERE Term__r.Section__c = 'Spring'];
        system.debug(LoggingLevel.ERROR, 'beforePTList.size => ' + beforePTList.size());

        system.debug(LoggingLevel.ERROR, 'o.Program_Term__c BEFORE => ' + o.Program_Term__c);

        //o.Program_Term__r.Term__c = programTerm.Term__c;
        o = testCustom(o);
        //o = [SELECT Id, Program_Term__c, Program__c, Program_Term__r.Applicant_Count__c, Program_Term__r.Applicant_Count_Parent_PT__c FROM Opportunity WHERE Id =: o.Id];

        //Testing after list
        List<Program_Term__c> afterPTList = [SELECT Id FROM Program_Term__c WHERE Term__r.Section__c = 'Spring'];
        system.debug(LoggingLevel.ERROR, 'afterPTList.size => ' + afterPTList.size());

        system.debug(LoggingLevel.ERROR, 'o.Program_Term__c AFTER => ' + o.Program_Term__c);
        system.debug(LoggingLevel.ERROR, 'o.Program_Term__r.Applicant_Count__c => ' + o.Program_Term__r.Applicant_Count__c);
        System.assertNotEquals(null, o.Program__c);
        System.assertNotEquals(null, o.Program_Term__c);
        List<Application__c> apps = new List<Application__c>();
        //system.debug('Contacts => ' + [SELECT Id FROM Contact WHERE RecordType.Name ='Student']);
        for(Contact c: [SELECT Id FROM Contact WHERE RecordType.Name = 'Student'])
        {
            apps.add(new Application__c(Applicant__c = c.Id, Status__c = 'Program Selected', Program_Term__c = o.Program_Term__c));
        }
        contactTriggerHandler.bypassTrigger = true;
        //Database.insert(apps);
        contactTriggerHandler.bypassTrigger = false;
        Database.update(o);
        o = [SELECT Id, Program_Term__c, Program__c, Amount, Profit__c, Final_Enrollment_Formula__c, Program_Term__r.Applicant_Count__c, Program_Term__r.Applicant_Count_Parent_PT__c FROM Opportunity WHERE Id =: o.Id];
        system.debug(LoggingLevel.ERROR, 'o.Final_Enrollment_Formula__c => ' + o.Final_Enrollment_Formula__c + ' in opp ' + o.Id + ' with PT ' + o.Program_Term__c);
        system.debug(LoggingLevel.ERROR, 'o.Program_Term.Applicant_Count__c => ' + o.Program_Term__r.Applicant_Count__c + ' in PT ' + o.Program_Term__c);
        system.debug(LoggingLevel.ERROR, 'o.Program_Term.Applicant_Count_Parent_PT__c => ' + o.Program_Term__r.Applicant_Count_Parent_PT__c + ' in PT ' + o.Program_Term__c);
        System.assertEquals(o.Profit__c * o.Final_Enrollment_Formula__c, o.Amount);
        system.debug('testClosedWonCustomNoExistingServiceOnlyProgram End');

    }

    @IsTest
    static void testClosedWonCustomExistingProgram(){
        Id userId = contextuser().Id;
        Account schoolAccount = [SELECT Id, Name, OwnerId FROM Account WHERE RecordType.Name = 'Home Institution' LIMIT 1].get(0);
        Contact schoolAdvisor = [SELECT Id, Name, OwnerId FROM Contact WHERE AccountId =: schoolAccount.Id LIMIT 1].get(0);
        Country__c country = [SELECT Id, Name FROM Country__c WHERE Name = 'England' LIMIT 1].get(0);
        Locality__c city = [SELECT Id, Name FROM Locality__c WHERE Name = 'Test City'];
        Program_Term__c programTerm = [SELECT Id, OwnerId, Program__r.Resident_director_team_member__c, Program__c FROM Program_Term__c WHERE Term__r.Section__c = 'Spring' LIMIT 1].get(0);
        Integer fee = 2000;
        Opportunity o = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Custom Program (Repeat)').getRecordTypeId(),
            Country__c = country.Id,
            City__c = city.Id,
            AccountId = schoolAccount.Id,
            Sending_Institution_Advisor__c = schoolAdvisor.Id,
            Program__c = programTerm.Program__c,
            Projected_Enrollment__c = 10,
            Fee__c = fee,
            StageName = 'Lead',
            Name = 'Test Oppy',
            CloseDate = Date.today().addDays(180),
            Term__c = 'Spring',
            Year__c = String.valueOf(Date.today().year() + 1),
            Length_in_Weeks__c = 4,
            Start_Date__c = Date.today().addDays(366),
            End_Date__c = Date.today().addDays(366 + (4 * 7)),
            Roster_Deadline__c = Date.today().addDays(225),
            Program_Advisor__c = programTerm.OwnerId,
            OwnerId = userId,
            Resident_Director__c = programTerm.Program__r.Resident_director_team_member__c,
            Field_Director__c = schoolAccount.OwnerId,
            Profit__c = 500
        );

        // Term__c testTerm = new Term__c(Name = 'Spring ' + o.Year__c, Section__c = 'Spring', Year__c = o.Year__c);
        // Database.insert(testTerm);

        o = testCustom(o);
        System.assertEquals(programTerm.Program__c, o.Program__c);
        List<Program_Term__c> programTerms = [SELECT Id, Name, Term__c, Term__r.Section__c, Term__r.Year__c FROM Program_Term__c WHERE Term__r.Section__c =: o.Term__c];
        System.assertEquals(2, programTerms.size());
    }

    static Opportunity testCustom(Opportunity o)
    {
        system.debug('--- testCustom Start ---');
        system.debug('o.Program_Term__c TESTCUSTOM START => ' + o.Program_Term__c);
        system.debug('o.Id testCustom before insert => ' + o.Id);
        Database.insert(o);
        system.debug('o.Id testCustom after insert => ' + o.Id);
        system.debug('o.Program_Term__c testCustom after insert => ' + o.Program_Term__c);
        Test.startTest();
        System.runAs(contextuser())
        {
            o.StageName = 'Proposal Accepted';
            // error happens here
            database.update(o);
        }
        //system.debug('--- AFTER UPDATE ---');
        Test.stopTest();
        system.debug('o.Id testCustom before query => ' + o.Id);
        system.debug('o.Program_Term__c testCustom after update => ' + o.Program_Term__c);
        o = [SELECT Id, Program__c, Start_Date__c, End_Date__c, Roster_Deadline__c, Term__c, Cities__c, Countries__c, Service_Only__c, Profit__c, Final_Enrollment_Formula__c, Amount, Program_Term__c, Program_Term__r.Applicant_Count__c, Projected_Enrollment__c, (SELECT StageName, CreatedDate FROM OpportunityHistories WHERE StageName = 'Proposal Accepted'), (SELECT Id, Name, OpportunityId, OpportunityAccessLevel, TeamMemberRole, Title, UserId FROM OpportunityTeamMembers), (SELECT Id, Country__c, Opportunity__c FROM Opportunity_Countries__r), (SELECT Id, City__c, Opportunity__c FROM Opportunity_Cities__r) FROM Opportunity WHERE Id =: o.Id];
        Program_Term__c updatePT = [SELECT Id, Applicant_Count__c, Applicant_Count_Parent_PT__c, RecordType.Name FROM Program_Term__c WHERE Id =: o.Program_Term__c];
        updatePT.Applicant_Count__c = o.Projected_Enrollment__c;
        updatePT.Applicant_Count_Parent_PT__c = o.Projected_Enrollment__c;
        system.debug('o.Projected_Enrollment__c => ' + o.Projected_Enrollment__c);
        system.debug('updatePT RecordType => ' + updatePT.RecordType.Name);
        Database.update(updatePT);
        system.debug('After update Program Term => ' + [SELECT Applicant_Count__c FROM Program_Term__c WHERE Id = :updatePT.Id]);
        system.debug('o.Id testCustom after query => ' + o.Id);
        system.debug('o.Program_Term__c TESTCUSTOM => ' + o.Program_Term__c);
        system.debug('o.Program_Term__r.Applicant_Count__c => ' + o.Program_Term__r.Applicant_Count__c);
        o = [SELECT Id, Program__c, Start_Date__c, End_Date__c, Roster_Deadline__c, Term__c, Cities__c, Countries__c, Service_Only__c, Profit__c, Final_Enrollment_Formula__c, Amount, Program_Term__c, Program_Term__r.Applicant_Count__c, Program_Term__r.Applicant_Count_Parent_PT__c, Projected_Enrollment__c, (SELECT StageName, CreatedDate FROM OpportunityHistories WHERE StageName = 'Proposal Accepted'), (SELECT Id, Name, OpportunityId, OpportunityAccessLevel, TeamMemberRole, Title, UserId FROM OpportunityTeamMembers), (SELECT Id, Country__c, Opportunity__c FROM Opportunity_Countries__r), (SELECT Id, City__c, Opportunity__c FROM Opportunity_Cities__r) FROM Opportunity WHERE Id =: o.Id];

        
        List<Task> testTasks = [SELECT Id, Subject, Owner.Name, OwnerId, ActivityDate FROM Task WHERE WhatId =: o.Id];
        System.assertEquals(false, testTasks.isEmpty());
        List<Custom_Program_Task_Assignment__c> taskAssignments;
        if(o.Service_Only__c)
        {
            taskAssignments= [SELECT Id, Name,Assign_To__c, Due_Date_Type__c, Due_Date_Units__c, Due_Date_Number__c FROM Custom_Program_Task_Assignment__c WHERE Exclude_From_Service_Only_Programs__c = FALSE];
            System.assertEquals(taskAssignments.size(), testTasks.size());
        }
        else
        {
            taskAssignments = [SELECT Id, Name,Assign_To__c, Due_Date_Type__c, Due_Date_Units__c, Due_Date_Number__c FROM Custom_Program_Task_Assignment__c];
            System.assertEquals(taskAssignments.size(), testTasks.size());    
        }        
        Map<String, Custom_Program_Task_Assignment__c> assigmentMap = new Map<String, Custom_Program_Task_Assignment__c>();        
        for(Custom_Program_Task_Assignment__c a: taskAssignments)
        {
            assigmentMap.put(a.Name, a);
        }
        for(Task t: testTasks)
        {
            //System.debug(t.Owner.Name);
            Custom_Program_Task_Assignment__c a = assigmentMap.get(t.Subject);
            System.assertEquals(a.Name, t.Subject);
            Date result = opportunityService.getDueDate(a, o);
            System.assertEquals(result, t.ActivityDate);
        }
        System.assertEquals(4, o.OpportunityTeamMembers.size());
        System.assertEquals(false, o.Opportunity_Countries__r.isEmpty());
        System.assertEquals(false, o.Opportunity_Cities__r.isEmpty());
        System.assertNotEquals(null, o.Cities__c);
        System.assertNotEquals(null, o.Countries__c);
        //system.debug('oe => ' + o);
        system.debug('o.Profit__c => ' + o.Profit__c);
        system.debug('o.Final_Enrollment_Formula__c => ' + o.Final_Enrollment_Formula__c);
        system.debug('o.Amount => ' + o.Amount);
        o = [SELECT Id, Program__c, Start_Date__c, End_Date__c, Roster_Deadline__c, Term__c, Cities__c, Countries__c, Service_Only__c, Profit__c, Final_Enrollment_Formula__c, Amount, Program_Term__c, Program_Term__r.Applicant_Count__c, Projected_Enrollment__c, (SELECT StageName, CreatedDate FROM OpportunityHistories WHERE StageName = 'Proposal Accepted'), (SELECT Id, Name, OpportunityId, OpportunityAccessLevel, TeamMemberRole, Title, UserId FROM OpportunityTeamMembers), (SELECT Id, Country__c, Opportunity__c FROM Opportunity_Countries__r), (SELECT Id, City__c, Opportunity__c FROM Opportunity_Cities__r) FROM Opportunity WHERE Id =: o.Id];
        system.debug('--- testCustom End ---');
        return o;
    }

    @IsTest
    static void testProgramTermDelete(){
        BaseTriggerHandler.bypass('opportunityTriggerHandler');
        Id userId = contextuser().Id;
        Account schoolAccount = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Home Institution' LIMIT 1].get(0);
        Contact schoolAdvisor = [SELECT Id, Name, OwnerId FROM Contact WHERE AccountId =: schoolAccount.Id LIMIT 1].get(0);
        Country__c country = [SELECT Id, Name FROM Country__c WHERE Name = 'England' LIMIT 1].get(0);
        Locality__c city = [SELECT Id, Name FROM Locality__c WHERE Name = 'Test City'];
        Program_Term__c programTerm = [SELECT Id, OwnerId, Program__r.Resident_director_team_member__c, Program__c, Program__r.Name FROM Program_Term__c WHERE Term__r.Section__c = 'Spring' LIMIT 1].get(0);
        Integer fee = 2000;
        Opportunity o = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Custom Program (Repeat)').getRecordTypeId(),
            Country__c = country.Id,
            City__c = city.Id,
            AccountId = schoolAccount.Id,
            Sending_Institution_Advisor__c = schoolAdvisor.Id,
            Program__c = programTerm.Program__c,
            Projected_Enrollment__c = 10,
            Fee__c = fee,
            StageName = 'Proposal Accepted',
            Name = 'Test Oppy',
            CloseDate = Date.today().addDays(180),
            Term__c = 'Spring',
            Year__c = String.valueOf(Date.today().year() + 1),
            Length_in_Weeks__c = 4,
            Start_Date__c = Date.today().addDays(366),
            End_Date__c = Date.today().addDays(366 + (4 * 7)),
            Roster_Deadline__c = Date.today().addDays(225),
            Program_Advisor__c = programTerm.OwnerId,
            OwnerId = userId,
            Resident_Director__c = programTerm.Program__r.Resident_director_team_member__c,
            Profit__c = 500
        );
        Term__c t = new Term__c(
            Name = 'Spring ' + o.Year__c,
            Section__c = 'Spring',
            Year__c =  Integer.valueOf(o.Year__c)
        );
        Database.insert(t);
        Program_Term__c pt = new Program_Term__c(
            Name = programTerm.Program__r.Name + ' Spring ' + o.Year__c,
            Term__c = t.Id,
            Program__c = programTerm.Program__c,
            Country__c = country.Id
        );

        Database.insert(new List<SObject>{o, pt});
        BaseTriggerHandler.clearBypass('opportunityTriggerHandler');
        Test.startTest();
        System.runAs(contextuser()){
            o.Program_Did_Not_Operate_Status__c = 'Did not enroll';
            o.Program_Did_Not_Operate_Reason__c = 'Test';
            database.update(o);
        }
        Test.stopTest();

        List<Program_Term__c> programTerms = [SELECT Id FROM Program_Term__c WHERE Term__c =: t.Id AND Program__c =: pt.Program__c];
        System.assertEquals(true, programTerms.isEmpty());   
    }
    @IsTest
    static void testExceptions(){
        
        Test.startTest();
        System.runAs(contextuser()){
            try
            {
                throw new opportunityService.opportunityServiceException(opportunityService.ErrorType.MISSING_RD,  'Testing opportunityService.opportunityServiceException');
            }
            catch(opportunityService.opportunityServiceException e)
            {
                System.debug(e);
            }
            try
            {
                throw new opportunityService.opportunityServiceException(opportunityService.ErrorType.MISSING_PA, 'Testing opportunityService.opportunityServiceException');
            }
            catch(opportunityService.opportunityServiceException e)
            {
                System.debug(e);
            }
            try
            {
                throw new opportunityService.opportunityServiceException(opportunityService.ErrorType.MISSING_FD, 'Testing opportunityService.opportunityServiceException');
            }
            catch(opportunityService.opportunityServiceException e)
            {
                System.debug(e);
            }
            try
            {
                throw new opportunityService.opportunityServiceException(opportunityService.ErrorType.MISSING_COUNTRY, 'Testing opportunityService.opportunityServiceException');
            }
            catch(opportunityService.opportunityServiceException e)
            {
                System.debug(e);
            }
            try
            {
                throw new opportunityService.opportunityServiceException(opportunityService.ErrorType.MISSING_CITY, 'Testing opportunityService.opportunityServiceException');
            }
            catch(opportunityService.opportunityServiceException e)
            {
                System.debug(e);
            }

        }
        Test.stopTest();        
    }
}