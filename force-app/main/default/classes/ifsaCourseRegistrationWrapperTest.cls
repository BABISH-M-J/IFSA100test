/**
* Test class for the course registration wrapper class.
* @author Cameron Ames
*/
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public class ifsaCourseRegistrationWrapperTest
{
    	@TestSetup
static void makeData(){
Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
}
    /**
* Test the instance methods.
*/
    public static testMethod void testInstance()
    {
        Butler_Department_Code__c buCode = apexMockDataUtility.createBUDepartmentCode();
        // Added this code by Harshitha Powerfluence on <10/5/2021> for fixing the error and code coverage
        List<Host_Institution__c> hostInstitution = [SELECT Id, Name, Credit_Conversion_JSON__c,Country__c FROM Host_Institution__c LIMIT 1 ];
     
        Course__c course = null;
        List<Course__c> existingCourse = [SELECT Id From Course__c Where Host_Institution__c = :hostInstitution[0].Id LIMIT 1 ];
        if(existingCourse.isEmpty())
        {
            Course__c  creatingCourse = apexMockDataUtility.createHostCourse(hostInstitution[0].Id, buCode);
            existingCourse = [SELECT Id From Course__c Where Host_Institution__c = :hostInstitution[0].Id LIMIT 1 ];
        }
        course = existingCourse[0];
        //	Course__c course = apexMockDataUtility.createHostCourse(null, buCode);
        Account acct = apexMockDataUtility.createAccount('TestAcct');
        Contact ctc = apexMockDataUtility.createContact('TestCtc', acct.Id);
        
        // Added this code by Harshitha Powerfluence on <10/5/2021> for fixing the error and code coverage
        Application__c application = null;
        
        List<Application__c> existingApplication = [SELECT Id From Application__c  LIMIT 1 ];
        application = existingApplication[0];
        
        // Application__c application = apexMockDataUtility.createApplication(ctc.Id);
        Course_Registration__C courseReg = apexMockDataUtility.createCourseRegistration(course.Id, application.Id, buCode);
        
        //Test constructor that takes instance
        ifsaCourseRegistrationWrapper courseRegWrapper = new ifsaCourseRegistrationWrapper(courseReg);
        //Test constructor that takes id
        courseRegWrapper = new ifsaCourseRegistrationWrapper(courseReg.Id);
        
        studentOnSiteCourseRegViewModel viewModel = courseRegWrapper.populateViewModel(new studentOnSiteCourseRegViewModel());
        System.assertEquals(course.id, viewModel.courseId, 'The course id view model did not match the expected course id.');
    }
}