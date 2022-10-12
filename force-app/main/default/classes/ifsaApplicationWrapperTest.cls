/**
* Test class for the application extension class
* @author Cameron Ames
*/
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public with sharing class ifsaApplicationWrapperTest
{
    @TestSetup
    static void makeData(){
        Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
    }
    /**
* Test the instance methods
*/
    public static testMethod void testInstance()
    {
        Application__c application = [SELECT Id, Status__c FROM Application__c LIMIT 1];
        Butler_Department_Code__c buCode = [SELECT Id FROM Butler_Department_Code__c LIMIT 1];
        
        application.Status__c = 'Registered';
        
        // Added this code by Harshitha Powerfluence on <10/8/2021> for fixing the error and code coverage
        List<Host_Institution__c> hostInstitution = [SELECT Id, Name, Credit_Conversion_JSON__c,Country__c FROM Host_Institution__c LIMIT 1 ];
      
        Test.startTest();
        Database.update(application);
      
        Course__c course = null;
        List<Course__c> existingCourse = [SELECT Id From Course__c Where Host_Institution__c = :hostInstitution[0].Id LIMIT 1 ];
        if(existingCourse.isEmpty())
        {
            Course__c  creatingCourse = apexMockDataUtility.createHostCourse(hostInstitution[0].Id, buCode);
            existingCourse = [SELECT Id From Course__c Where Host_Institution__c = :hostInstitution[0].Id LIMIT 1 ];
        }
        course = existingCourse[0];
        
        Course_Registration__C courseReg = apexMockDataUtility.createCourseRegistration(course.Id, application.Id, buCode);        
        //Test constructor w/id
        ifsaApplicationWrapper appWrapper = new ifsaApplicationWrapper(application.Id);
        
        Id testId = appWrapper.getProgramTermId();
        testId = appWrapper.getOwnerId();
        Boolean isCustom = appWrapper.isCustom();
        
        System.assert(!appWrapper.isBeyond('Registered'), 'IsBeyond indicates that the application is beyond registered.');
        
        //Test constructor w/object
        application.Status__c = 'NotReal';
        Database.update(application);
        appWrapper = new ifsaApplicationWrapper(application);
        
        System.assert(appWrapper.isBeyond('Registered'), 'IsBeyond indicates that the application is NOT beyond registered');
        
        application.Status__c = 'NotReal';
        Database.update(application);
        appWrapper = new ifsaApplicationWrapper(application);
        
        List<ifsaCourseRegistrationWrapper> courseRegistrationList = appWrapper.getCourseRegistrations();
        system.assertEquals(1, courseRegistrationList.size(), 'There should have been at least 1 course registration.');
        
        try
        {
            Boolean isTrue = appWrapper.isBeyond('FakeStatus');
            System.assert(false, 'An Exception should have been thrown.');
        }
        catch (Exception e)
        {
            System.assert(true, 'An Exception was meant to be thrown here.');
        }
        test.stopTest();
    }
    public static testMethod void testInstance2()
    {			
        Application__c application = [SELECT Id, Display_Name__c, Program_Term__r.Program__c, Program_Term__c, CRF_Status__c FROM Application__c LIMIT 1];
        //Test constructor w/id
        ifsaApplicationWrapper appWrapper = new ifsaApplicationWrapper(application);
        Test.startTest();
        
        Integer numOfAppReqs = appWrapper.getApplicationItems('Pre-Admit').size();
        numOfAppReqs += appWrapper.getApplicationItems('Pre-Acceptance').size();
        numOfAppReqs += appWrapper.getApplicationItems('Post-Acceptance').size();
        //numOfAppReqs += appWrapper.getApplicationItems('Post-Contract').size();
        numOfAppReqs += appWrapper.getApplicationITems('').size();
        
        Integer numOfNewAppItems = appWrapper.populateApplicationItems().size();
        System.assertEquals(numOfAppReqs + 1, numOfNewAppItems, 'There should be just one more application item after populating.');
        //System.assertEquals(numOfAppReqs, numOfNewAppItems, 'There should be just one more application item after populating.');
        
        customDocumentsViewModel viewModel = appWrapper.populateViewModel(new customDocumentsViewModel());
        System.assertNotEquals(null, viewModel.applicationId, 'The view model application id should not be null.');
        
        studentOnSiteViewModel viewModel2 = appWrapper.populateViewModel(new studentOnSiteViewModel());
        System.assertNotEquals(null, viewModel2.programTermId, 'The view model program term Id should not be null.');
        
        Test.stopTest();
    }
}