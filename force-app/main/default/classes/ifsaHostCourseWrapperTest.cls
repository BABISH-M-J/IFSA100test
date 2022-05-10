/**
* Test class for the host course wrapper class
* @author Cameron Ames
*/
// ApexDoc updated 2/16/2021 Brock Barlow
//  // Added this code by Vinod Powerfluence on <10/12/2021> for fixing the error and code coverage
@isTest
public with sharing class ifsaHostCourseWrapperTest
{
    @TestSetup
    static void makeData(){
        Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
    }
    /**
* Test the instance methods on this class.
*/
    public static testMethod void testInstance()
    {
		Butler_Department_Code__c buCode = apexMockDataUtility.createBUDepartmentCode();
         // Added this code by Vinod Powerfluence on <9/29/2021> for fixing the error and code coverage
        List<Host_Institution__c> hostInstitution = [SELECT Id, Name, Credit_Conversion_JSON__c,Country__c FROM Host_Institution__c LIMIT 1 ];
        Course__c course = null;
        List<Course__c> existingCourse = [SELECT Id From Course__c Where Host_Institution__c = :hostInstitution[0].Id LIMIT 1 ];
        if(existingCourse.isEmpty())
        {
            Course__c creatingCourse = apexMockDataUtility.createHostCourse(hostInstitution[0].Id, buCode);
            existingCourse = [SELECT Id From Course__c Where Host_Institution__c = :hostInstitution[0].Id LIMIT 1 ];
        }
        course = existingCourse[0]; 
       //Course__c course = apexMockDataUtility.createHostCourse(null, buCode);
		//Test constructor that takes instance
		ifsaHostCourseWrapper courseWrapper = new ifsaHostCourseWrapper(course);
		//Test constructor that takes id
		courseWrapper = new ifsaHostCourseWrapper(course.Id);
		
		studentApplyItemDetailsViewModel viewModel = courseWrapper.populateViewModel(new studentApplyItemDetailsViewModel());
		System.assertNotEquals(null, viewModel.courses, 'The LIST of courses should not have been null.');
		
		try
		{
			course = apexMockDataUtility.createHomeCourse();
			courseWrapper = new ifsaHostCourseWrapper(course.Id);
			System.assert(false, 'An exception should have been thrown.');
		}
		catch(Exception e)
		{
			System.assert(true, 'We were expecting this Exception.');
		}
    }
     // Added this code by Vinod Powerfluence on <10/12/2021> for fixing the error and code coverage
      public static testMethod void testInstance1()
      {
          World__c world = new World__c();
          world.name='Global';
          insert world;
          Region__c region = new Region__c();
          region.name = 'International airport';
          region.World__c = world.Id;
          insert region;
          List<Country__c> country = [select Id,Name From Country__c Limit 1];
          Host_Institution__c hostInstitution = new Host_Institution__c();
          hostInstitution.Name	= 'Universitat Pompeu Fabra';
          hostInstitution.Country__c = country[0].Id ;
          insert hostInstitution;
          Course__c course = new Course__c();
          course.Name = 'Global Change Biology: The Ecology of Our Plants Under Stress';
          course.Host_Institution__c = hostInstitution.Id;
          course.Course_Title__c = 'Global Change Biology: The Ecology of Our Plants Under Stress';
			insert course;
          ifsaHostCourseWrapper courseWrapper = new ifsaHostCourseWrapper(course);
          studentOnSiteCourseRegViewModel viewModel = courseWrapper.populateViewModel(new studentOnSiteCourseRegViewModel());
       		System.assertNotEquals(null, viewModel, 'The LIST of courses should not have been null.');
        
          try
		{
			course = apexMockDataUtility.createHomeCourse();
			courseWrapper = new ifsaHostCourseWrapper(course.Id);
			System.assert(false, 'An exception should have been thrown.');
		}
		catch(Exception e)
		{
			System.assert(true, 'We were expecting this Exception.');
		}
      }
    }