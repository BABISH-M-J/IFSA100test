/**
* Unit tests for <<CourseRegistrationController>>
* @author Brock Barlow
*/
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
private class courseRegistrationControllerTest {
    @TestSetup
    static void makeData(){
        Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection(new List<String>{'programTermTriggerHandler'},new Set<String>{'Courses'});
    }
    
    // Values for Page Names                ----->                      Values for pageActionType
    static final String courseApproveGrades = 'courseApproveGrades';           //Course_Approval
    static final String courseEnterGrades = 'courseEnterGrades';               //Grade_Report
    static final String courseReviewGrades = 'courseReviewGrades';             //Review_Grades
    static final String courseCreateGradeReport = 'courseCreateGradeReport';   //Create_Grade_Report
    
    private static User staffUser {get;set;}
    private static Application__c app {get;set;}
    private static Id hostInsitutionId {get;set;}
    private static Course_Registration__c courseReg {get;set;}
    
    @isTest static void testInstance()
    {
        initTest(courseApproveGrades);
        
        Test.startTest();
        
        system.runAs(staffUser)
        {
            PageReference ref = new PageReference('/apex/courseApproveGrades');
            Test.setCurrentPage(ref);
            CourseRegistrationController controller = new CourseRegistrationController();
            CourseRegistrationViewModel viewModel = controller.viewModel;
            
            viewModel = CourseRegistrationController.populateViewModel(controller.viewModel.getSerializedViewModel());
            
            CourseRegistrationController.applicationGradesEntered('', '');
            CourseRegistrationController.populateViewModel('');
            CourseRegistrationController.commitCourses('');
            
            applicationCourseViewModel acvm = viewModel.hostInstViewModels.get(0).applicationCourses.get(0);
            acvm.courseRegistrations.get(0).courseName = 'Test Coursé';
            acvm.courseRegistrations.get(0).courseTitle = 'Test Coursé';
            acvm.courseRegistrations.get(0).applicationID = app.Id;
            //viewModel.hostInstViewModels.get(0).applicationCourses.get(0).courseRegistrations.get(0) = crvm;
            
            CourseRegistrationController.commitCourses(JSON.serialize(acvm));
            CourseRegistrationController.createCourse(JSON.serialize(acvm.courseRegistrations.get(0)), true);
            CourseRegistrationController.searchForRecord('Contact', 'test');
            CourseRegistrationController.searchForRecordWithRecordType('Contact', 'test', 'Student');
            CourseRegistrationController.searchForCourses(hostInsitutionId, 'test', 'Name');
            
            ref = new PageReference('/apex/courseEnterGrades');
            Test.setCurrentPage(ref);
            controller = new CourseRegistrationController();
            viewModel = controller.viewModel;
        }
        test.stopTest();
    }
    
    @isTest static void testProcess()
    {
        initTest(courseApproveGrades);
        Test.startTest();
        
        system.runAs(staffUser)
        {
            PageReference ref = new PageReference('/apex/courseApproveGrades');
            Test.setCurrentPage(ref);
            CourseRegistrationController controller = new CourseRegistrationController();
            CourseRegistrationViewModel viewModel = controller.viewModel;
            
            applicationCourseViewModel acvm = viewModel.hostInstViewModels.get(0).applicationCourses.get(0);
            acvm.courseRegistrations.get(0).isApproved = true;
            acvm.courseRegistrations.get(0).courseName = 'Test Coursé';
            acvm.courseRegistrations.get(0).courseTitle = 'Test Coursé';
            acvm.courseRegistrations.get(0).applicationID = app.Id;
            system.debug('courseRegId-----'+courseReg.Id);
            system.debug('acvm.courseRegistrations.get(0).courseRegId---------'+acvm.courseRegistrations.get(0).courseRegId);
            Course_Registration__c cr = [SELECT Id FROM Course_Registration__c WHERE Id =: acvm.courseRegistrations.get(0).courseRegId];
            system.debug('cr-----'+cr);
            //Approve courses
            CourseRegistrationController.applicationGradesEntered(JSON.serialize(viewModel.hostInstViewModels.get(0).applicationCourses), 'Course_Approval');
            //Grade Courses
            system.debug('courseEnterGrades--------'+courseEnterGrades);
            cr = updatecr(cr, courseEnterGrades);
            
            CourseRegistrationController.applicationGradesEntered(JSON.serialize(acvm), 'Grade_Report');
            app = [SELECT Id, Grades_Entered__c, Grades_Verified__c FROM Application__c WHERE Id =: app.Id];
            system.assertEquals(Date.today(), app.Grades_Entered__c);
        }
    }
    @isTest static void testProcess2()
    {
        initTest(courseApproveGrades);
        Test.startTest();
        
        system.runAs(staffUser)
        {
            PageReference ref = new PageReference('/apex/courseApproveGrades');
            Test.setCurrentPage(ref);
            CourseRegistrationController controller = new CourseRegistrationController();
            CourseRegistrationViewModel viewModel = controller.viewModel;
            
            applicationCourseViewModel acvm = viewModel.hostInstViewModels.get(0).applicationCourses.get(0);
            acvm.courseRegistrations.get(0).isApproved = true;
            acvm.courseRegistrations.get(0).courseName = 'Test Coursé';
            acvm.courseRegistrations.get(0).courseTitle = 'Test Coursé';
            acvm.courseRegistrations.get(0).applicationID = app.Id;
            Course_Registration__c cr = [SELECT Id FROM Course_Registration__c WHERE Id =: acvm.courseRegistrations.get(0).courseRegId];
            //Review Grades
            
            cr = updatecr(cr, courseReviewGrades);
            CourseRegistrationController.applicationGradesEntered(JSON.serialize(acvm), 'Review_Grades');
            app = [SELECT Id, Grades_Entered__c, Grades_Verified__c FROM Application__c WHERE Id =: app.Id];
            system.assertEquals(Date.today(), app.Grades_Verified__c);
            //Create Grade Report            
            //updatecr(cr, courseCreateGradeReport);
            Course_Registration__c courseReg = [SELECT Id, Final_Grade__c, Status__c, Credits_Earned__c, Application__c, Application__r.Applicant__r.Home_Institution__r.Account__c FROM Course_Registration__c WHERE Id =: cr.Id].get(0);
            system.debug(courseReg);
            courseReg.Status__c = 'Grade Verified';
            Database.update(courseReg);
            courseReg = [SELECT Id, Final_Grade__c, Status__c, Credits_Earned__c, Application__c, Application__r.Applicant__r.Home_Institution__r.Account__c FROM Course_Registration__c WHERE Id =: cr.Id].get(0);
            system.assertEquals('Grade Verified',courseReg.Status__c);
        }
    }
    @isTest static void testProcess3()
    {
        initTest(courseCreateGradeReport);
        
        system.runAs(staffUser)
        {
            
            contactTriggerHandler.bypassTrigger = true;
            
            Course_Registration__c cr = [SELECT Id FROM Course_Registration__c WHERE Id =: courseReg.Id];
            Test.startTest();
            cr = updatecr(cr, courseCreateGradeReport);
            PageReference ref = new PageReference('/apex/courseCreateGradeReport');
            Test.setCurrentPage(ref);
            CourseRegistrationController controller = new CourseRegistrationController();
            CourseRegistrationViewModel viewModel = controller.viewModel;
            applicationCourseViewModel acvm = viewModel.hostInstViewModels.get(0).applicationCourses.get(0);
            Map<String, String> result = CourseRegistrationController.generateGradeDocuments(JSON.serialize(viewModel));
            System.assertNotEquals(null, result.get('bgrId'));
            
            test.stopTest();
            contactTriggerHandler.bypassTrigger = false;
        }
    }
    
    @isTest static void testBGRTrigger()
    {
        initTest(courseCreateGradeReport);
        contactTriggerHandler.bypassTrigger = true;
        
        Butler_Grade_Report__c bgr = new Butler_Grade_Report__c();
        database.insert(bgr);
        
        Course_Registration_Grade__c crg = new Course_Registration_Grade__c(
            Course_Registration__c = courseReg.Id,
            Butler_Grade_Report__c = bgr.Id
        );
        Test.startTest();
        database.insert(crg);
        
        bgr = [SELECT Id, (SELECT Id FROM Course_Registration_Grades__r) FROM Butler_Grade_Report__c LIMIT 1].get(0);
        
        //Test Course Registration Grade Trigger, Trigger Handler            
        Database.update(bgr.Course_Registration_Grades__r.get(0));
        Database.delete(bgr.Course_Registration_Grades__r.get(0));
        Test.stopTest();
        contactTriggerHandler.bypassTrigger = false;
    }
    
    private static Course_Registration__c updatecr(Course_Registration__c courseReg, String pageName)
    {
        if(pageName == courseEnterGrades || pageName == courseReviewGrades || pageName == courseCreateGradeReport )
        {
            courseReg.Final_Grade__c = 'A';
            courseReg.Is_Approved__c = true;
            courseReg.Status__c = 'Grade Entered';
            app.Courseload_Approval__c = true;
        }
        if(pageName == courseReviewGrades || pageName == courseCreateGradeReport)
        {
            courseReg.Status__c = 'Grade Verified';
            app.Grades_Entered__c = Date.today();
        }
        if(pageName == courseCreateGradeReport)
        {
            courseReg.Status__c = 'Grade Verified';
            app.Grades_Entered__c = Date.today();
            app.Grades_Verified__c = Date.today();
        }
        
        system.debug('courseReg.Status__c--------'+courseReg.Status__c);
        if(courseReg.Id != null)
            Database.update(courseReg);
        Database.update(app);
        system.debug('courseReg-------'+courseReg);
        return courseReg;
    }
    
    private static void initTest(String pageName)
    {
        app = [SELECT Id, 
               Status__c, 
               Program_Term__c, 
               Courseload_Approval__c, 
               Grades_Entered__c, 
               Grades_Verified__c 
               FROM Application__c  LIMIT 1];
        
        staffUser = [SELECT Id FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Academic_Affairs_Grade_Report') AND isActive = true LIMIT 1];
       
         // Added this code by Harshitha Powerfluence on <10/8/2021> for fixing the error and code coverage
        List<Host_Institution__c> hostInsitution = new List<Host_Institution__c>();
       
        for(Host_Institution__c host:[SELECT Id,Name,Credit_Conversion_JSON__c FROM Host_Institution__c  LIMIT 1]){
            host.Credit_Conversion_JSON__c='[{"StartDate":"2021-09-20","IsActive":true,"EndDate":null,"Conversions":[{"USSemesterCreditHours":5,"HostInstitutionCredits":10}],"ActiveTerms":["Spring","Summer","Fall"]}]';
            hostInsitution.add(host);
            
        }
        Update hostInsitution;
        
        hostInsitution = [SELECT Id,Name,Credit_Conversion_JSON__c FROM Host_Institution__c LIMIT 1];
        
        hostInsitutionId = hostInsitution[0].id;
        
  
        app.Status__c = 'On Site';
        
        Program_Term__c pt = new Program_Term__c(Id = app.Program_Term__c);
        pt.Start_Date__c = Date.today();
        pt.End_Date__c = Date.today().addMonths(6);
        Database.update(pt);        
        
        courseReg = new Course_Registration__c();
        courseReg.Application__c = app.Id;
        courseReg.Host_Credits__c = 15;
        courseReg.Course__c = [SELECT Id FROM Course__c Limit 1].Id;
        //courseReg.Course_Term__c = 'Spring';
        //courseReg.US_Semester_Credit_Hours__c = 4;
        courseReg.Butler_Department_Code__c = [SELECT Id FROM Butler_Department_Code__c WHERE Department_Code__c = 'TEST'].get(0).Id;
        courseReg.Host_Institution__c = hostInsitutionId;
        courseReg.Instructor_First_Name__c = 'Test';
        courseReg.Instructor_Last_Name__c = 'Professor';
        courseReg.Status__c = 'Approval Pending';
        courseReg = updatecr(courseReg, pageName);
        system.debug(courseReg);
        Support_Personnel__c sp = new Support_Personnel__c();
        sp.RecordTypeId = Schema.SObjectType.Support_Personnel__c.getRecordTypeInfosByName().get('Host Institution').getRecordTypeId();
        sp.Host_Institution__c = hostInsitutionId;
        sp.IFSA_Staff__c = staffUser.Id;
        sp.Support_Role_Type__c = 'Resident Staff';
        sp.Type__c = 'IFSA Staff';
        
        Database.insert(new List<SObject>{sp, courseReg});
    }    
}