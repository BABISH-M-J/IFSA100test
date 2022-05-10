/**
 * Unit Tests for <<courseRegistrationService>>, <<courseRegistrationTriggerHandler>> and <<courseRegistrationGradeTriggerHandler>>
 * @author Matt Eck
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
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
		//BaseTriggerHandler.bypass('accountTriggerHandler');

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

		BaseTriggerHandler.bypass('accountTriggerHandler');
				
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
            studentContacts[i].Active_Application__c = applications[i].Id;
        }
				
        Database.update(studentContacts);

        contactTriggerHandler.bypassTrigger = false;
		applicationTriggerHandler.bypassTrigger = false;
		BaseTriggerHandler.bypass('applicationItemTriggerHandler');
		BaseTriggerHandler.clearAllBypasses();
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
        // List<Application__c> apps1 = [SELECT Id, Program_Term__r.Start_Of_Second_Term__c FROM Application__c LIMIT 1];
        // List<Course__c> courses1 = [SELECT Id, Name FROM Course__c LIMIT 1];
        Course_Registration__c crsf = [SELECT Course__c,Name,Course_Title__c,Application__c FROM Course_Registration__c WHERE Status__c =:'Approval Pending' LIMIT 1];
       System.debug('CourseRegistration'+crsf);
        // List<Course_Registration__c> crs1 = new List<Course_Registration__c>();
             crsf.Course__c = courses[0].Id;
             crsf.Name = courses[0].Name;
             crsf.Course_Title__c = courses[0].Name;
            
             crsf.Status__c = 'Approval Pending';
            // crs1.add(crsf);

            // crs1.add(new Course_Registration__c(
            //     crsf.Course__c = courses1[0].Id,
            //     crsf.Name = courses1[0].Name,
            //     crsf.Course_Title__c = courses1[0].Name,
            //     crsf.Application__c = apps1[0].Id,
            //     crsf.Status__c = 'Approval Pending'
            // ));
        
        Database.update(crsf);
        System.debug('crsf.Course__c'+crsf.Course__c);
        // Database.delete(crsf.Course__c);
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
    static void testCourseRegCreation1(){
        Course_Registration__c crsf1 = [SELECT Course__c,Name,Course_Title__c,Application__c FROM Course_Registration__c WHERE Status__c =:'Approval Pending' LIMIT 1];
        System.debug('');
       // Database.delete(crsf1.Course__c);
    }
 
}