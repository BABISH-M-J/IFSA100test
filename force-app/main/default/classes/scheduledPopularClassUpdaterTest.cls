@isTest
public without sharing class scheduledPopularClassUpdaterTest 
{
    @TestSetup
    static void makeData(){
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'Courses'});
        Course__c course = (Course__c) testData.get('hostCourse');
        Course__c clonedCourse = course.clone(false,false,false,false);
        clonedCourse.Name = clonedCourse.Name + ' Cloned';
        clonedCourse.Course_Title_2__c = clonedCourse.Name;
        List<SObject> newObjects = new List<SObject>{clonedCourse};

        Contact c = (Contact) testData.get('studentContact');
        Contact clonedContact;
        Integer recordsToCreate = 5;
        for(Integer i = 0; i < recordsToCreate; i++)
        {
            clonedContact = c.clone(false, false, false, false);
            clonedContact.LastName = clonedContact.LastName + i;
            clonedContact.Active_Application__c = null;
            newObjects.add(clonedContact);
        }
        database.insert(newObjects);
        Application__c app = (Application__c) testData.get('studentApplication');
        Application__c clonedApp;
        List<Application__c> newApps = new List<Application__c>();
        for(Integer i = 0; i < recordsToCreate; i++)
        {
            clonedApp = app.clone(false, false, false, false);
            clonedApp.Applicant__c = newObjects.get(i+1).Id;
            newApps.add(clonedApp);
        }
        applicationTriggerHandler.bypassTrigger = true;
        database.insert(newApps);
        applicationTriggerHandler.bypassTrigger = false;
        
        System.debug('Test Setup Completed');
    }
    private static testMethod void testFallLogic()
    {
        Test.startTest();
        Term__c term = [SELECT Id, Year__c, Section__c FROM Term__c WHERE Section__c = 'Fall' ORDER BY Year__c DESC LIMIT 1];
        List<Program_Term__c> progTerms = [SELECT Id FROM Program_Term__c];
        for(Program_Term__c pt: progTerms)
        {
            pt.Term__c = term.Id;
        }
        Database.update(progTerms);
        Course__c course = [SELECT Id, Name, Host_Institution__c, Course_Title_2__c FROM Course__c LIMIT 1];
        Course_Registration__c cr = new Course_Registration__c(Course__c = course.Id, Name = course.Name, Course_Title__c = course.Course_Title_2__c, Status__c = 'Ready For Butler', Host_Institution__c = course.Host_Institution__c);
        Course_Registration__c clonedCR;
        List<Course_Registration__c> newCRs = new List<Course_Registration__c>();
        for(Application__c app: [SELECT Id FROM Application__c WHERE Program_Term__r.Term__r.Section__c =: term.Section__c])
        {
            clonedCR = cr.clone(false, false, false, false);
            clonedCR.Application__c = app.Id;
            newCRs.add(clonedCR);
        }
        Database.insert(newCrs);
        scheduledPopularClassUpdater.updatePopularClasses(date.newInstance((Date.today().year() + 1), 1, 1));
        Test.stopTest();
    }
    private static testMethod void testSpringLogic()
    {
        Test.startTest();
        Term__c term = [SELECT Id, Year__c, Section__c FROM Term__c WHERE Section__c = 'Spring' ORDER BY Year__c DESC LIMIT 1];
        List<Program_Term__c> progTerms = [SELECT Id FROM Program_Term__c];
        for(Program_Term__c pt: progTerms)
        {
            pt.Term__c = term.Id;
        }
        database.update(progTerms);
        Course__c course = [SELECT Id, Name, Host_Institution__c, Course_Title_2__c FROM Course__c LIMIT 1];
        Course_Registration__c cr = new Course_Registration__c(Course__c = course.Id, Name = course.Name, Course_Title__c = course.Course_Title_2__c, Status__c = 'Ready For Butler', Host_Institution__c = course.Host_Institution__c);
        Course_Registration__c clonedCR;
        List<Course_Registration__c> newCRs = new List<Course_Registration__c>();
        for(Application__c app: [SELECT Id FROM Application__c WHERE Program_Term__r.Term__r.Section__c =: term.Section__c])
        {
            clonedCR = cr.clone(false, false, false, false);
            clonedCR.Application__c = app.Id;
            newCRs.add(clonedCR);
        }
        Database.insert(newCrs);
        scheduledPopularClassUpdater.updatePopularClasses(date.newInstance((Date.today().year() + 1), 6, 1));
        Test.stopTest();
    }
    private static testMethod void testSummerLogic()
    {
        Test.startTest();
        Term__c term = [SELECT Id, Year__c, Section__c FROM Term__c WHERE Section__c = 'Summer' ORDER BY Year__c DESC LIMIT 1];
        List<Program_Term__c> progTerms = [SELECT Id FROM Program_Term__c];
        for(Program_Term__c pt: progTerms)
        {
            pt.Term__c = term.Id;
        }
        database.update(progTerms);
        Course__c course = [SELECT Id, Name, Host_Institution__c, Course_Title_2__c FROM Course__c LIMIT 1];
        Course_Registration__c cr = new Course_Registration__c(Course__c = course.Id, Name = course.Name, Course_Title__c = course.Course_Title_2__c, Status__c = 'Ready For Butler', Host_Institution__c = course.Host_Institution__c);
        Course_Registration__c clonedCR;
        List<Course_Registration__c> newCRs = new List<Course_Registration__c>();
        for(Application__c app: [SELECT Id FROM Application__c WHERE Program_Term__r.Term__r.Section__c =: term.Section__c])
        {
            clonedCR = cr.clone(false, false, false, false);
            clonedCR.Application__c = app.Id;
            newCRs.add(clonedCR);
        }
        Database.insert(newCrs);
        scheduledPopularClassUpdater.updatePopularClasses(date.newInstance((Date.today().year() + 1), 12, 1));
        Test.stopTest();
    }
    private static testMethod void testOtherDayOfYear()
    {
        Test.startTest();
        scheduledPopularClassUpdater.updatePopularClasses(date.newInstance((Date.today().year() + 1), 12, 31));
        Test.stopTest();
    }
    private static testMethod void testManualOperation()
    {
        Test.startTest();
        scheduledPopularClassUpdater.manuallyCalculateCoursePopulatity('Spring');
        scheduledPopularClassUpdater.manuallyCalculateCoursePopulatity('Fall');
        scheduledPopularClassUpdater.manuallyCalculateCoursePopulatity('Summer');
        Test.stopTest();
    }
    private static testMethod void testSchedule()
    {
    	Test.startTest();
    	String jobId = System.schedule('testscheduledPopularClassUpdater',
            '0 0 0 * * ? *', new scheduledPopularClassUpdater());
        
        Test.stopTest();
    }
}