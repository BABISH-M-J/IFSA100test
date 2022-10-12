/**
 * Unit Tests for <<courseRegistrationService>>, <<courseRegistrationTriggerHandler>> and <<courseRegistrationGradeTriggerHandler>>
 * @author Matt Eck
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest(SeeAllData=false)
private class courseRegistrationServiceTest 
{
    @TestSetup
    static void makeData()
    {
        apexMockDataUtility.setFdUserId([SELECT Id FROM User WHERE Name = 'Migration User'].get(0));
        
		contactTriggerHandler.bypassTrigger = true;
		applicationTriggerHandler.bypassTrigger = true;
		BaseTriggerHandler.bypass('applicationItemTriggerHandler');
		BaseTriggerHandler.bypass('applicationRequirementTriggerHandler');
		BaseTriggerHandler.bypass('userTriggerHandler');
		BaseTriggerHandler.bypass('accountTriggerHandler');

		List<SObject> objectsToAdd = new List<SObject>();
		List<SObject> objectsToUpdate = new List<SObject>();

		World__c world = new World__c(Name = 'Global');
		database.insert(world);

		Region__c international = new Region__c(Name = 'International Support', World__c = world.Id);
		Region__c local = new Region__c(Name = 'Local Support', World__c = world.Id);
		database.insert(new List<Region__c>{international, local});

		Country__c usa = apexMockDataUtility.createLocalCountry(local.Id);

		List<Home_Institution__c> homeInstitutions = apexMockDataUtility.createHomeInstitution('Test Institution', 1, usa.Id);		
		
		List<Account> accounts = apexMockDataUtility.createAccounts('Test', 6);

		//BaseTriggerHandler.bypass('accountTriggerHandler');
				
		List<Contact> studentContacts = apexMockDataUtility.createContacts('Test Contact', accounts, homeInstitutions);

		User academicAffiarsUser = apexMockDataUtility.CreateSysAdmin();
		User studentUsr = apexMockDataUtility.createUser(studentContacts[0].Id);
		User studentUsr2 = apexMockDataUtility.createUser(studentContacts[1].Id);		
		Contact guardianCtc = apexMockDataUtility.createGuardian(studentContacts[0].Id, true);
		
		//Need to add world, region, country, program, term, hi, because of selective program approval		

		Country__c country = apexMockDataUtility.createCountry(international.Id);
		Locality__c testCity = new Locality__c(Name = 'Test City', Country__c = country.Id);
		database.insert(testCity);		
		List<Host_Institution__c> hosts = apexMockDataUtility.createHostInstitutions(country.Id, 3);
		Host_Institution__c hostInstitution = hosts.get(0);        
        Host_Institution__c hostInstitution2 = hosts.get(1);
		Host_Institution__c hostInstitution3 = hosts.get(2);
        Grade_Conversion__c gradeConversion = new Grade_Conversion__c(Host_Institution__c = hostInstitution.Id, Type__c = 'Number Range', Sections__c = 'Spring;Summer;Fall', Start_Date__c = Date.newInstance(2022,1,1), Grade_A__c = '93-100', Grade_A_Minus__c = '90-92', Grade_B_Plus__c = '87-89', Grade_B__c = '83-86', Grade_B_Minus__c = '80-82', Grade_C_Plus__c = '77-79', Grade_C__c = '73-76', Grade_C_Minus__c = '70-72', Grade_D_Plus__c = '67-69', Grade_D__c = '63-66', Grade_D_Minus__c = '60-62', Grade_F__c = '0-59');
		Database.insert(gradeConversion);
        List<String> names = new List<String>{'Test Program', 'Summer Test Program', 'Winter Test Program'};
		List<Program__c> programs = apexMockDataUtility.createPrograms(hostInstitution, names, academicAffiarsUser.Id);
		Program__c semProgram = programs[0];
        Program__c sumProgram = programs[1];
        Program__c winProgram = programs[2];

        Butler_Department_Code__c buCode = apexMockDataUtility.createBUDepartmentCode();
        Course__c course = apexMockDataUtility.createHostCourse(hostInstitution.Id, buCode, null);
        List<Program_Course__c> progCourses = new List<Program_Course__c>();
        for(Program__c p: programs)
        {
            progCourses.add(new Program_Course__c(Program__c = p.Id, Course__c =course.Id));
        }
        Database.insert(progCourses);
		
		List<String> sections = new List<String>{'Spring', 'Fall', 'Summer', 'Calendar Year', 'Academic Year', 'Winter'};
        List<Term__c> terms = apexMockDataUtility.createTerms(sections, Date.today().year());		

        List<Program_Term__c> programTerms = new List<Program_Term__c>();
        for(Term__c t: terms)
        {
            switch on t.Section__c {
                when 'Spring', 'Fall', 'Calendar Year', 'Academic Year' {
                    programTerms.add(new Program_Term__c(Program__c = semProgram.Id, Term__c = t.Id, Country__c = country.Id));
                }
                when 'Summer' {
                    programTerms.add(new Program_Term__c(Program__c = sumProgram.Id, Term__c = t.Id, Country__c = country.Id));
                }
                when 'Winter' {
                    programTerms.add(new Program_Term__c(Program__c = winProgram.Id, Term__c = t.Id, Country__c = country.Id));
                }
            }
        }
        Database.insert(programTerms);
		
		List<String> status = new List<String>{'On Site', 'On Site', 'On Site', 'On Site', 'On Site', 'On Site'};
		List<String> designation = new List<String>{'Primary', 'Primary', 'Primary', 'Primary', 'Primary', 'Primary'};
		List<Date> dates = new List<Date>();

		dates.add(date.Today().addDays(-29));
		dates.add(date.Today().addDays(-15));
        dates.add(null);
        dates.add(Date.today());
        dates.add(Date.today());
        dates.add(Date.today());

		List<Application__c> applications = apexMockDataUtility.createApplications(studentContacts, programTerms, new List<Program_Term__c>(), null, status, dates, designation);

        for(Integer i = 0; i > studentContacts.size(); i++)
        {
            //studentContacts[i].Active_Application__c = applications[i].Id;
        }
				
        Database.update(studentContacts);

        contactTriggerHandler.bypassTrigger = false;
		applicationTriggerHandler.bypassTrigger = false;
		BaseTriggerHandler.bypass('applicationItemTriggerHandler');
		BaseTriggerHandler.clearAllBypasses();
    }

    public static testMethod void testGradeEnteredOrChanged1()
    {
        BaseTriggerHandler.bypass('courseTriggerHandler');
        Course__c courseRecord = [SELECT Id, Name FROM Course__c LIMIT 1].get(0);
        Host_Institution__c hi = [SELECT Id FROM Host_Institution__c LIMIT 1].get(0);
        Application__c app = [SELECT Id, Name, Host_Institution_Id__c FROM Application__c LIMIT 1].get(0);
        app.Host_Institution_Id__c = hi.Id;
        Database.update(app);
        Grade_Conversion__c gc = new Grade_Conversion__c(Host_Institution__c = hi.Id, Type__c = 'Number Range', Sections__c = 'Spring;Summer;Fall', Start_Date__c = Date.newInstance(2022,1,1), Grade_A__c = '93-100', Grade_A_Minus__c = '90-92', Grade_B_Plus__c = '87-89', Grade_B__c = '83-86', Grade_B_Minus__c = '80-82', Grade_C_Plus__c = '77-79', Grade_C__c = '73-76', Grade_C_Minus__c = '70-72', Grade_D_Plus__c = '67-69', Grade_D__c = '63-66', Grade_D_Minus__c = '60-62', Grade_F__c = '0-59');
        Database.insert(gc);
        List<Course_Registration__c> listCR = new List<Course_Registration__c>();
        Course_Registration__c cr = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, Host_Institution_Grade__c = '10', Status__c = 'Grade Submitted');
        listCR.add(cr);
        Course_Registration__c cr2 = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, Host_Institution_Grade__c = '100', Status__c = 'Grade Submitted');
        listCR.add(cr2);
        Course_Registration__c cr3 = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, Host_Institution_Grade__c = '92', Status__c = 'Grade Submitted');
        listCR.add(cr3);
        Course_Registration__c cr4 = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, Host_Institution_Grade__c = '89', Status__c = 'Grade Submitted');
        listCR.add(cr4);
        Course_Registration__c cr5 = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, Host_Institution_Grade__c = '86', Status__c = 'Grade Submitted');
        listCR.add(cr5);
        Course_Registration__c cr6 = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, Host_Institution_Grade__c = '82', Status__c = 'Grade Submitted');
        listCR.add(cr6);
        Course_Registration__c cr7 = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, Host_Institution_Grade__c = '79', Status__c = 'Grade Submitted');
        listCR.add(cr7);
        Course_Registration__c cr8 = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, Host_Institution_Grade__c = '76', Status__c = 'Grade Submitted');
        listCR.add(cr8);
        Course_Registration__c cr9 = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, Host_Institution_Grade__c = '72', Status__c = 'Grade Submitted');
        listCR.add(cr9);
        Course_Registration__c cr10 = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, Host_Institution_Grade__c = '69', Status__c = 'Grade Submitted');
        listCR.add(cr10);
        Course_Registration__c cr11 = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, Host_Institution_Grade__c = '66', Status__c = 'Grade Submitted');
        listCR.add(cr11);
        Course_Registration__c cr12 = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, Host_Institution_Grade__c = '62', Status__c = 'Grade Submitted');
        listCR.add(cr12);
        Database.insert(listCR);
        //Database.SaveResult rslt = Database.insert(cr);
        cr.Host_Institution_Grade__c = '100';
        Test.startTest();
        Database.update(cr);
        Test.stopTest();
    }

    public static testMethod void testGradeEnteredOrChanged2()
    {
        BaseTriggerHandler.bypass('courseTriggerHandler');
        Course__c courseRecord = [SELECT Id, Name FROM Course__c LIMIT 1].get(0);
        Host_Institution__c hi = [SELECT Id FROM Host_Institution__c LIMIT 1].get(0);
        Application__c app = [SELECT Id, Name, Host_Institution_Id__c FROM Application__c LIMIT 1].get(0);
        app.Host_Institution_Id__c = hi.Id;
        Database.update(app);
        Grade_Conversion__c gc = new Grade_Conversion__c(Host_Institution__c = hi.Id, Type__c = 'Number Range', Sections__c = 'Spring;Summer;Fall', Start_Date__c = Date.newInstance(2022,1,1), Grade_A__c = '93-100', Grade_A_Minus__c = '90-92', Grade_B_Plus__c = '87-89', Grade_B__c = '83-86', Grade_B_Minus__c = '80-82', Grade_C_Plus__c = '77-79', Grade_C__c = '73-76', Grade_C_Minus__c = '70-72', Grade_D_Plus__c = '67-69', Grade_D__c = '63-66', Grade_D_Minus__c = '60-62', Grade_F__c = '0-59');
        Database.insert(gc);
        Course_Registration__c cr = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, /*Host_Institution_Grade__c = '82',*/ Status__c = 'Approved');
        Database.SaveResult rslt = Database.insert(cr);
        cr.Host_Institution_Grade__c = '100';
        Test.startTest();
        Database.update(cr);
        Test.stopTest();
    }

    public static testMethod void testMarkCourseSubmitted()
    {
        Application__c app = [SELECT Id, Name, Host_Institution_Id__c FROM Application__c LIMIT 1].get(0);
        Host_Institution__c hi = [SELECT Id FROM Host_Institution__c LIMIT 1].get(0);
        Course__c courseRecord = [SELECT Id, Name FROM Course__c LIMIT 1].get(0);
        BaseTriggerHandler.bypass('courseRegistrationTriggerHandler');
        BaseTriggerHandler.bypass('courseRegistrationGradeTriggerHandler');
        Course_Registration__c cr = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, /*Host_Institution_Grade__c = '82',*/ Status__c = 'Approved');
        Database.insert(cr);        
        Butler_Grade_Report__c bgr = new Butler_Grade_Report__c();
        Database.insert(bgr);
        Course_Registration_Grade__c crg = new Course_Registration_Grade__c(Course_Registration__c = cr.Id, Application__c = app.Id, Butler_Grade_Report__c = bgr.Id);
        Database.insert(crg);
        courseRegistrationService.markCourseSubmitted(bgr.Id);        
    }

    public static testMethod void testCreateNewCourseRecords()
    {
        Application__c app = [SELECT Id, Name, Host_Institution_Id__c FROM Application__c LIMIT 1].get(0);
        Host_Institution__c hi = [SELECT Id FROM Host_Institution__c LIMIT 1].get(0);
        BaseTriggerHandler.bypass('courseRegistrationTriggerHandler');
        Course_Registration__c cr = new Course_Registration__c(/*Course__c = courseRecord.Id,*/ Name = 'Test Course', Course_Title__c = 'Test Course', Host_Credits__c = 3, Course_Code__c = 'TEST123', Application__c = app.Id, Host_Institution__c = hi.Id, /*Host_Institution_Grade__c = '82',*/ Status__c = 'Approved');
        Test.startTest();
        Database.insert(cr); 
        List<Id> listIds = new List<Id>();
        listIds.add(cr.Id);
        courseRegistrationService.createNewCourseRecords(listIds);
        Test.stopTest();
    }

    public static testMethod void testCourseGradeCreated()
    {
        Application__c app = [SELECT Id, Name, Host_Institution_Id__c FROM Application__c LIMIT 1].get(0);
        Host_Institution__c hi = [SELECT Id FROM Host_Institution__c LIMIT 1].get(0);
        Course__c courseRecord = [SELECT Id, Name FROM Course__c LIMIT 1].get(0);
        Course_Registration__c cr = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, /*Host_Institution_Grade__c = '82',*/ Status__c = 'Approved');
        Database.insert(cr);
        Butler_Grade_Report__c bgr = new Butler_Grade_Report__c();
        Database.insert(bgr);
        Course_Registration_Grade__c crg = new Course_Registration_Grade__c(Course_Registration__c = cr.Id, Application__c = app.Id, Butler_Grade_Report__c = bgr.Id);
        Database.insert(crg);
    }

    public static testMethod void testCourseRegistrationGradesVerified()
    {
        Application__c app = [SELECT Id, Name, Host_Institution_Id__c FROM Application__c LIMIT 1].get(0);
        Host_Institution__c hi = [SELECT Id FROM Host_Institution__c LIMIT 1].get(0);
        Course__c courseRecord = [SELECT Id, Name FROM Course__c LIMIT 1].get(0);
        Course_Registration__c cr = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, /*Host_Institution_Grade__c = '82',*/ Status__c = 'Approved');
        Database.insert(cr);
        List<Course_Registration__c> listCR = new List<Course_Registration__c>();
        listCR.add(cr);
        courseRegistrationService.courseRegistrationGradesVerified(listCR);
    }

    @IsTest
    static void testCourseRegCreation(){
        List<Application__c> apps = [SELECT Id, Program_Term__r.Start_Of_Second_Term__c FROM Application__c LIMIT 1];
        List<Course__c> courses = [SELECT Id, Name FROM Course__c LIMIT 1];
        Test.startTest();
        List<Course_Registration__c> crs = new List<Course_Registration__c>();
        for(Application__c app: apps)
        {
            crs.add(new Course_Registration__c(
                Course__c = courses[0].Id,
                Name = courses[0].Name,
                Course_Title__c = courses[0].Name,
                Application__c = app.Id,
                Status__c = 'Approval Pending'
            ));
        }
        Database.insert(crs);
        Test.stopTest();
        Application__c app = apps.get(0);
        for(Course_Registration__c cr: [SELECT Id, Program_Term_Section__c, Course_Term__c FROM Course_Registration__c])
        {
            switch on cr.Program_Term_Section__c {
                when 'Spring', 'Winter' {
                    system.assertEquals('Spring', cr.Course_Term__c);
                }
                when 'Fall' {
                    system.assertEquals('Fall', cr.Course_Term__c);
                }
                when 'Summer' {
                    system.assertEquals('Summer', cr.Course_Term__c);
                }
                when 'Calendar Year' {
                    if(app.program_term__r.Start_Of_Second_Term__c > Date.today())
                    {
                        system.assertEquals('Spring', cr.Course_Term__c);
                    }	
                    else
                    {
                        system.assertEquals('Fall', cr.Course_Term__c);
                    }					
                }
                when 'Academic Year' {
                    if(app.program_term__r.Start_Of_Second_Term__c > Date.today())
                    {
                        system.assertEquals('Fall', cr.Course_Term__c);
                    }
                    else
                    {
                        system.assertEquals('Spring', cr.Course_Term__c);
                    }
                }
                when else{
                    System.debug(LoggingLevel.ERROR, 'Unexpected Value for Program_Term_Section__c');
                    throw new dataException('Unexpected Value for Program_Term_Section__c');
                }
            }
        }
    }

    @IsTest
    static void createEditRegistration(){
        System.debug(LoggingLevel.ERROR, '--- createEditRegistration Start ---');
        //Get needed lookup records
        List<Application__c> apps = [SELECT Id, Program_Term__r.Start_Of_Second_Term__c FROM Application__c LIMIT 1];
        List<Course__c> courses = [SELECT Id, Name FROM Course__c LIMIT 1];
        List<Host_Institution__c> HIs = [SELECT Id, Name FROM Host_Institution__c LIMIT 1];

        // Create Course Registration
        Course_Registration__c cr = new Course_Registration__c();
        cr.Application__c = apps[0].Id;
        cr.Course__c = courses[0].Id;
        cr.Host_Institution__c = HIs[0].Id;
        cr.Name = courses[0].Name;
        cr.Course_Title__c = courses[0].Name;

        //Test.startTest();
        // Insert Course Registration
        //Database.SaveResult insertCR = Database.insert(cr);
        //System.debug(LoggingLevel.ERROR, 'insertCR => ' + insertCR);
        //Test.stopTest();

        Test.startTest();
        Savepoint sp = Database.setSavePoint();
        // Do stuff here //
        Database.insert(cr);

        cr.Required_Class__c = true;
        Database.update(cr);
        Database.rollback(sp);
    }

    public static testMethod void testCalculateLetterGradeConversion()
    {
        Application__c app = [SELECT Id, Name, Host_Institution_Id__c FROM Application__c LIMIT 1].get(0);
        Host_Institution__c hi = [SELECT Id FROM Host_Institution__c LIMIT 1].get(0);
        Course__c courseRecord = [SELECT Id, Name FROM Course__c LIMIT 1].get(0);
        Course_Registration__c cr = new Course_Registration__c(Course__c = courseRecord.Id, Application__c = app.Id, Host_Institution__c = hi.Id, /*Host_Institution_Grade__c = '82',*/ Status__c = 'Approved');
        Database.insert(cr);
        Butler_Grade_Report__c bgr = new Butler_Grade_Report__c();
        Database.insert(bgr);
        Course_Registration_Grade__c crg = new Course_Registration_Grade__c(Course_Registration__c = cr.Id, Application__c = app.Id, Butler_Grade_Report__c = bgr.Id);
        Database.insert(crg);
        Grade_Conversion__c gc = new Grade_Conversion__c(Host_Institution__c = hi.Id, Type__c = 'Number Range', Sections__c = 'Spring;Summer;Fall', Start_Date__c = Date.newInstance(2022,1,1), Grade_A__c = '93-100', Grade_A_Minus__c = '90-92', Grade_B_Plus__c = '87-89', Grade_B__c = '83-86', Grade_B_Minus__c = '80-82', Grade_C_Plus__c = '77-79', Grade_C__c = '73-76', Grade_C_Minus__c = '70-72', Grade_D_Plus__c = '67-69', Grade_D__c = '63-66', Grade_D_Minus__c = '60-62', Grade_F__c = '0-59');
        Database.insert(gc);
        courseRegistrationService.calculateLetterGradeConversion(cr, gc);
    }
}