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
                 // // added by powerfluence based on Clayton req 03/29/2022 starts
            	Host_Institution_Grade__c='A',
        		// // added by powerfluence based on Clayton req 03/29/2022 ends
                Status__c = 'Approval Pending'
            ));
        }
        Database.SaveResult[] a = Database.insert(crs);
        
       
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
     // added by powerfluence based on Clayton req 03/29/2022 starts
    @IsTest
    static void testCourseRegCreation1(){
        List<Application__c> apps = [SELECT Id, Program_Term__r.Start_Of_Second_Term__c FROM Application__c LIMIT 1];
        List<Course__c> courses = [SELECT Id, Name FROM Course__c LIMIT 1];
         Course_Registration__c crsf;
        Test.startTest();
        Host_Institution__c courseIn = [SELECT Id FROM Host_Institution__c LIMIT 1];
        Grade_Conversion__c gradeCon = new Grade_Conversion__c(
        	CurrencyIsoCode= 'USD',
            Host_Institution__c = courseIn.Id,
            Sections__c= 'Spring',
            Start_Date__c= Date.today(),
            Type__c ='Number Range'
        );
        Database.insert(gradeCon);
       /* Grade_Conversion__c gradeCon1 = new Grade_Conversion__c(
        	CurrencyIsoCode= 'USD',
            Host_Institution__c = courseIn.Id,
            Sections__c= 'Spring',
            Start_Date__c= Date.today(),
            Type__c ='Letter Grade'
        );
        Database.insert(gradeCon1);*/
         Grade_Conversion__c gradeConQuery = [SELECT Id FROM Grade_Conversion__c LIMIT 1 ];
        List<Course_Registration__c> crs = new List<Course_Registration__c>();
        for(Application__c app: apps)
        {
            crs.add(new Course_Registration__c(
                Course__c = courses[0].Id,
                Name = courses[0].Name,
                Course_Title__c = courses[0].Name,
                Application__c = app.Id,
                Status__c = 'Grade Submitted',
                Host_Institution_Grade__c = 'A',
                Grade_Conversion__c =gradeConQuery.Id
            ));
        }
        Database.SaveResult[] a = Database.insert(crs);
      
        
		system.debug('courseIn'+courseIn);
        crsf = [SELECT Course__c,Name,Course_Title__c,Application__c,Final_Grade__c,Host_Institution__c,Host_Institution_Grade__c FROM Course_Registration__c WHERE Status__c =:'Grade Submitted' LIMIT 1];
       System.debug('CourseRegistration'+crsf);
     
             crsf.Course__c = courses[0].Id;
             crsf.Name = courses[0].Name;
             crsf.Course_Title__c = courses[0].Name;
            crsf.Final_Grade__c='B';
        	crsf.Host_Institution_Grade__c = 'A';
       		crsf.Host_Institution__c = courseIn.Id;
             crsf.Status__c = 'Approval Pending';
             crsf.Is_Approved__c = True;
            
        
        Database.update(crsf);
        System.debug('crsf.Course__c'+crsf.Course__c);
        crsf = [SELECT Id FROM Course_Registration__c LIMIT 1];
        Butler_Grade_Report__c butGrade =new Butler_Grade_Report__c(
        Date_Submitted__c = Date.today()
        );
         Database.insert(butGrade);
         Butler_Grade_Report__c butGrade1 = [SELECT Id FROM Butler_Grade_Report__c LIMIT 1];
        courseRegistrationService.markCourseSubmitted(butGrade1.Id);
        Course_Registration_Grade__c grade = new Course_Registration_Grade__c(
        	Course_Registration__c= crsf.Id,
            Butler_Grade_Report__c = butGrade1.Id,
            	CurrencyIsoCode= 'USD'
            
        );
        Database.insert(grade);
    }
    
     @IsTest
    static void testCourseRegCreation2(){
         List<Application__c> apps = [SELECT Id, Program_Term__r.Start_Of_Second_Term__c FROM Application__c LIMIT 1];
        List<Course__c> courses = [SELECT Id, Name FROM Course__c LIMIT 1];
         Course_Registration__c crsf;
        Test.startTest();
        Host_Institution__c courseIn = [SELECT Id FROM Host_Institution__c LIMIT 1];
      Grade_Conversion__c gradeCon1 = new Grade_Conversion__c(
    		 CurrencyIsoCode= 'USD',
       		 Host_Institution__c = courseIn.Id,
            	Grade_A__c = 'A',
             Sections__c= 'Spring',
             Start_Date__c= Date.today(),
             Type__c ='Letter Grade'
         );
        Database.insert(gradeCon1);
        
        Grade_Conversion__c gradeConQuery = [SELECT Id FROM Grade_Conversion__c ];
        List<Course_Registration__c> crs = new List<Course_Registration__c>();
        for(Application__c app: apps)
        {
           
                crs.add(new Course_Registration__c(
                    Course__c = courses[0].Id,
                    Name = courses[0].Name,
                    Course_Title__c = courses[0].Name,
                    Application__c = app.Id,
                    Status__c = 'Grade Submitted',
                    Host_Institution_Grade__c = 'A',
                    Grade_Conversion__c =gradeConQuery.Id
                ));
            
        }
        Database.SaveResult[] a = Database.insert(crs);
        system.debug('courseIn'+courseIn);
        crsf = [SELECT Course__c,Name,Course_Title__c,Application__c,Final_Grade__c,Host_Institution__c,Host_Institution_Grade__c FROM Course_Registration__c WHERE Status__c =:'Grade Submitted' LIMIT 1];
       System.debug('CourseRegistration'+crsf);
     
             crsf.Course__c = courses[0].Id;
             crsf.Name = courses[0].Name;
             crsf.Course_Title__c = courses[0].Name;
            crsf.Final_Grade__c='B';
        	crsf.Host_Institution_Grade__c = 'A';
       		crsf.Host_Institution__c = courseIn.Id;
             crsf.Status__c = 'Approval Pending';
             crsf.Is_Approved__c = True;
            
        
        Database.update(crsf);
        System.debug('crsf.Course__c'+crsf.Course__c);
        crsf = [SELECT Id FROM Course_Registration__c LIMIT 1];
        Course_Registration_Grade__c grade = new Course_Registration_Grade__c(
        	Course_Registration__c= crsf.Id,
            	CurrencyIsoCode= 'USD'
        );
        Database.insert(grade);
    }
    @IsTest
    static void testCourseRegCreation3(){
         List<Application__c> apps = [SELECT Id, Program_Term__r.Start_Of_Second_Term__c FROM Application__c LIMIT 1];
        List<Course__c> courses = [SELECT Id, Name FROM Course__c LIMIT 1];
         Course_Registration__c crsf;
        Test.startTest();
        Host_Institution__c courseIn = [SELECT Id FROM Host_Institution__c LIMIT 1];
        Grade_Conversion__c gradeCon1 = new Grade_Conversion__c(
    		 CurrencyIsoCode= 'USD',
       		 Host_Institution__c = courseIn.Id,
            Grade_A_Minus__c ='B',
            Grade_B__c='B',
           Grade_B_Plus__c ='c',
           Grade_D__c ='D',
            Grade_C_Minus__c='C',
           Grade_C_Plus__c='C',
           Grade_C__c='C',
            Grade_B_Minus__c='B',
			Grade_F__c='F',
            Grade_D_Minus__c='D',
            Grade_D_Plus__c='D+',
             Sections__c= 'Spring',
             Start_Date__c= Date.today(),
             Type__c ='Letter Grade'
         );
        Database.insert(gradeCon1);
        
        Grade_Conversion__c gradeConQuery = [SELECT Id FROM Grade_Conversion__c ];
        List<Course_Registration__c> crs = new List<Course_Registration__c>();
        for(Application__c app: apps)
        {
           
                crs.add(new Course_Registration__c(
                    Course__c = courses[0].Id,
                    Name = courses[0].Name,
                    Course_Title__c = courses[0].Name,
                    Application__c = app.Id,
                    Status__c = 'Grade Submitted',
                    Host_Institution_Grade__c = 'D',
                    Host_Institution__c = courseIn.Id,
                    Grade_Conversion__c =gradeConQuery.Id
                ));
            
        }
        Database.SaveResult[] a = Database.insert(crs);
        system.debug('courseIn'+courseIn);
        crsf = [SELECT Course__c,Name,Course_Title__c,Application__c,Final_Grade__c,Host_Institution__c,Host_Institution_Grade__c FROM Course_Registration__c WHERE Status__c =:'Grade Submitted' LIMIT 1];
       System.debug('CourseRegistration'+crsf);
     
             crsf.Course__c = courses[0].Id;
             crsf.Name = courses[0].Name;
             crsf.Course_Title__c = courses[0].Name;
            crsf.Final_Grade__c='F';
        	crsf.Host_Institution_Grade__c = 'F';
       		crsf.Host_Institution__c = courseIn.Id;
             crsf.Status__c = 'Approval Pending';
             crsf.Is_Approved__c = True;
        Database.update(crsf);
        System.debug('crsf.Course__c'+crsf.Course__c);
       
        crsf = [SELECT Id FROM Course_Registration__c LIMIT 1];
        Course_Registration_Grade__c grade = new Course_Registration_Grade__c(
        	Course_Registration__c= crsf.Id,
            	CurrencyIsoCode= 'USD'
            
        );
        Database.insert(grade);
    }
  @IsTest
    static void testCourseRegCreation4(){
         List<Application__c> apps = [SELECT Id, Program_Term__r.Start_Of_Second_Term__c FROM Application__c LIMIT 1];
        List<Course_Registration__c> crs = new List<Course_Registration__c>();
        Test.startTest();
          Host_Institution__c courseIn = [SELECT Id FROM Host_Institution__c LIMIT 1];
        Grade_Conversion__c gradeCon1 = new Grade_Conversion__c(
    		 CurrencyIsoCode= 'USD',
       		 Host_Institution__c = courseIn.Id,
            	Grade_A__c = 'A',
            Grade_A_Minus__c ='B',
            Grade_B__c='B',
           Grade_B_Plus__c ='c',
           Grade_D__c ='D',
            Grade_C_Minus__c='C',
           Grade_C_Plus__c='C',
           Grade_C__c='C',
            Grade_B_Minus__c='B',
			Grade_F__c='F',
            Grade_D_Minus__c='D',
            Grade_D_Plus__c='D+',
             Sections__c= 'Spring',
             Start_Date__c= Date.today(),
             Type__c ='Letter Grade'
         );
        Database.insert(gradeCon1);
        
        Grade_Conversion__c gradeConQuery = [SELECT Id FROM Grade_Conversion__c ];
        for(Application__c app: apps)
        {
           
                crs.add(new Course_Registration__c(
                    Application__c = app.Id,
                    Status__c = 'Grade Submitted',
                     Host_Institution_Grade__c = 'x',
                    Host_Institution__c = courseIn.Id,
                    Grade_Conversion__c =gradeConQuery.Id
                    
                ));
            
        }
        Database.SaveResult[] a = Database.insert(crs);
        Test.stopTest();
    }
     @IsTest
    static void testCourseRegCreation5(){
         List<Application__c> apps = [SELECT Id, Program_Term__r.Start_Of_Second_Term__c FROM Application__c LIMIT 1];
        List<Course_Registration__c> crs = new List<Course_Registration__c>();
        Test.startTest();
          Host_Institution__c courseIn = [SELECT Id FROM Host_Institution__c LIMIT 1];
        Grade_Conversion__c gradeCon1 = new Grade_Conversion__c(
    		 CurrencyIsoCode= 'USD',
       		 Host_Institution__c = courseIn.Id,
            	Grade_A__c = 'A',
            Grade_A_Minus__c ='B',
            Grade_B__c='B',
           Grade_B_Plus__c ='c',
           Grade_D__c ='D',
            Grade_C_Minus__c='C',
           Grade_C_Plus__c='C',
           Grade_C__c='C',
            Grade_B_Minus__c='B',
			Grade_F__c='F',
            Grade_D_Minus__c='D',
            Grade_D_Plus__c='D+',
             Sections__c= 'Spring',
             Start_Date__c= Date.today(),
             Type__c ='Letter Grade'
         );
        Database.insert(gradeCon1);
        
        Grade_Conversion__c gradeConQuery = [SELECT Id FROM Grade_Conversion__c ];
        for(Application__c app: apps)
        {
           
                crs.add(new Course_Registration__c(
                    Application__c = app.Id,
                    Status__c = 'Grade Submitted',
                     Host_Institution_Grade__c = 'B',
                    Host_Institution__c = courseIn.Id,
                    Grade_Conversion__c =gradeConQuery.Id
                    
                ));
            
        }
        Database.SaveResult[] a = Database.insert(crs);
        Test.stopTest();
    }
    @IsTest
    static void testCourseRegCreation6(){
         List<Application__c> apps = [SELECT Id, Program_Term__r.Start_Of_Second_Term__c FROM Application__c LIMIT 1];
        List<Course_Registration__c> crs = new List<Course_Registration__c>();
        Test.startTest();
          Host_Institution__c courseIn = [SELECT Id FROM Host_Institution__c LIMIT 1];
        Grade_Conversion__c gradeCon1 = new Grade_Conversion__c(
    		 CurrencyIsoCode= 'USD',
       		 Host_Institution__c = courseIn.Id,
           Grade_B_Plus__c ='B',
             Sections__c= 'Spring',
             Start_Date__c= Date.today(),
             Type__c ='Letter Grade'
         );
        Database.insert(gradeCon1);
        
        Grade_Conversion__c gradeConQuery = [SELECT Id FROM Grade_Conversion__c ];
        for(Application__c app: apps)
        {
           
                crs.add(new Course_Registration__c(
                    Application__c = app.Id,
                    Status__c = 'Grade Submitted',
                     Host_Institution_Grade__c = 'B',
                    Host_Institution__c = courseIn.Id,
                    Grade_Conversion__c =gradeConQuery.Id
                    
                ));
            
        }
        Database.SaveResult[] a = Database.insert(crs);
        Test.stopTest();
    }
    @IsTest
    static void testCourseRegCreation7(){
         List<Application__c> apps = [SELECT Id, Program_Term__r.Start_Of_Second_Term__c FROM Application__c LIMIT 1];
        List<Course_Registration__c> crs = new List<Course_Registration__c>();
        Test.startTest();
          Host_Institution__c courseIn = [SELECT Id FROM Host_Institution__c LIMIT 1];
        Grade_Conversion__c gradeCon1 = new Grade_Conversion__c(
    		 CurrencyIsoCode= 'USD',
       		 Host_Institution__c = courseIn.Id,
            
            Grade_C_Minus__c='C',
             Sections__c= 'Spring',
             Start_Date__c= Date.today(),
             Type__c ='Letter Grade'
         );
        Database.insert(gradeCon1);
        
        Grade_Conversion__c gradeConQuery = [SELECT Id FROM Grade_Conversion__c ];
        for(Application__c app: apps)
        {
           
                crs.add(new Course_Registration__c(
                    Application__c = app.Id,
                    Status__c = 'Grade Submitted',
                     Host_Institution_Grade__c = 'C',
                    Host_Institution__c = courseIn.Id,
                    Grade_Conversion__c =gradeConQuery.Id
                    
                ));
            
        }
        Database.SaveResult[] a = Database.insert(crs);
        Test.stopTest();
    }
    @IsTest
    static void testCourseRegCreation8(){
         List<Application__c> apps = [SELECT Id, Program_Term__r.Start_Of_Second_Term__c FROM Application__c LIMIT 1];
        List<Course_Registration__c> crs = new List<Course_Registration__c>();
        Test.startTest();
          Host_Institution__c courseIn = [SELECT Id FROM Host_Institution__c LIMIT 1];
        Grade_Conversion__c gradeCon1 = new Grade_Conversion__c(
    		 CurrencyIsoCode= 'USD',
       		 Host_Institution__c = courseIn.Id,
           Grade_C_Plus__c='C',
            Grade_D_Minus__c='D',
            Grade_D_Plus__c='D+',
            Grade_D__c='A',
            Grade_C__c='Y',
            Grade_B_Minus__c='B-',
            Grade_B__c='B',
             Sections__c= 'Spring',
             Start_Date__c= Date.today(),
             Type__c ='Letter Grade'
         );
        Database.insert(gradeCon1);
        
        Grade_Conversion__c gradeConQuery = [SELECT Id FROM Grade_Conversion__c ];
        for(Application__c app: apps)
        {
           
                crs.add(new Course_Registration__c(
                    Application__c = app.Id,
                    Status__c = 'Grade Submitted',
                     Host_Institution_Grade__c = 'C',
                    Host_Institution__c = courseIn.Id,
                    Grade_Conversion__c =gradeConQuery.Id
                    
                ));
            crs.add(new Course_Registration__c(
                    Application__c = app.Id,
                    Status__c = 'Grade Submitted',
                     Host_Institution_Grade__c = 'D',
                    Host_Institution__c = courseIn.Id,
                    Grade_Conversion__c =gradeConQuery.Id
                    
                ));
            crs.add(new Course_Registration__c(
                    Application__c = app.Id,
                    Status__c = 'Grade Submitted',
                     Host_Institution_Grade__c = 'D+',
                    Host_Institution__c = courseIn.Id,
                    Grade_Conversion__c =gradeConQuery.Id
                    
                ));
              crs.add(new Course_Registration__c(
                    Application__c = app.Id,
                    Status__c = 'Grade Submitted',
                     Host_Institution_Grade__c = 'A',
                    Host_Institution__c = courseIn.Id,
                    Grade_Conversion__c =gradeConQuery.Id
                    
                ));
             crs.add(new Course_Registration__c(
                    Application__c = app.Id,
                    Status__c = 'Grade Submitted',
                     Host_Institution_Grade__c = 'Y',
                    Host_Institution__c = courseIn.Id,
                    Grade_Conversion__c =gradeConQuery.Id
                    
                ));
            crs.add(new Course_Registration__c(
                    Application__c = app.Id,
                    Status__c = 'Grade Submitted',
                     Host_Institution_Grade__c = 'B-',
                    Host_Institution__c = courseIn.Id,
                    Grade_Conversion__c =gradeConQuery.Id
                    
                ));
             crs.add(new Course_Registration__c(
                    Application__c = app.Id,
                    Status__c = 'Grade Submitted',
                     Host_Institution_Grade__c = 'B',
                    Host_Institution__c = courseIn.Id,
                    Grade_Conversion__c =gradeConQuery.Id
                    
                ));
            
        }
        Database.SaveResult[] a = Database.insert(crs);
        courseRegistrationService.courseRegistrationGradesVerified(crs);
        Test.stopTest();
    }
     // added by powerfluence based on Clayton req 03/29/2022 ends
}