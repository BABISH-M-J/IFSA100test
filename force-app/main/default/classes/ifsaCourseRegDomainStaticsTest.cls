/**
 * @description Test class for the course reg domain statics.
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public without sharing class ifsaCourseRegDomainStaticsTest
{
    public static testMethod void testcreateCourseFromCourseReg()
    {
    	Map<String, sObject> dataCollection = apexMockDataUtility.createIfsaDataCollection();

    	Course_Registration__c courseRegistration = new Course_Registration__c();
    	courseRegistration.Name = 'Test';
    	courseRegistration.Application__c = ((Application__c) dataCollection.get('studentApplication')).Id;
    	courseRegistration.Course_Code__c = 'TC101';
	    courseRegistration.Host_Credits__c = 1;
    	courseRegistration.Butler_Department_Code__c = [SELECT Id FROM Butler_Department_Code__c WHERE Department_Code__c = 'TEST'].get(0).Id;
    	courseRegistration.Host_Institution__c = ((Host_Institution__c) dataCollection.get('hostInstitution')).Id;
    	courseRegistration.Instructor_First_Name__c = 'Prof';
        courseRegistration.Instructor_Last_Name__c = 'ayyo';
    	//courseRegistration.US_Semester_Credit_Hours__c = 2;
      test.startTest();
   		database.insert(courseRegistration);
   		ifsaCourseRegDomainStatics.createCourseFromCourseReg(new List<Id>{courseRegistration.Id});
    	List<Course_Registration__c> courseReg = [SELECT Id, Name, Application__c, Country__c, Course__c, Course_Code__c, Host_Credits__c, Butler_Department_Code__c, Host_Institution__c, Instructor_Full_Name__c, Instructor_First_Name__c, Instructor_Last_Name__c, US_Semester_Credit_Hours__c FROM Course_Registration__c WHERE Id =: courseRegistration.Id];	      
   		system.assertEquals(
   						1,
   						courseReg.size());
   		ifsaCourseRegDomainStatics.createCourseFromCourseReg(new List<Id>{courseRegistration.Id});
   		//Uncomment next line once field changes are made
    	courseReg = [SELECT Id, Name, Application__c, Country__c, Course__c, Course_Code__c, Host_Credits__c, Butler_Department_Code__c, Host_Institution__c, Instructor_Full_Name__c, Instructor_First_Name__c, Instructor_Last_Name__c, US_Semester_Credit_Hours__c FROM Course_Registration__c WHERE Id =: courseRegistration.Id];
   		system.assertEquals(
   						1,
   						courseReg.size());
      test.stopTest();
    }
}