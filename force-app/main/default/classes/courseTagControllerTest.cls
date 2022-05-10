/**
 * Unit tests for <<courseTagController>>
 * @author Audrey Carson
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
private class courseTagControllerTest {
	
	@isTest static void test_method_one() {
		// Test course for Tags
		Course__c testcourse = new Course__c();
		testcourse.Name = 'test course 101';
		testcourse.Host_Credits__c = 15.00;
		//testcourse.US_Semester_Credit_Hours__c = 4.00;
		insert testcourse;

		List<Tag__c> tagList = new List<Tag__c>();
		Tag__c t1 = new Tag__c(Department__c='Language, Literature and Cultural Studies', Area_Of_Study__c='Linguistics', Course__c=testcourse.Id);
		Tag__c t2 = new Tag__c(Department__c='Language, Literature and Cultural Studies', Course__c=testcourse.Id);
		tagList.add(t1);
		tagList.add(t2);
		insert tagList;

		//Creating a subsection of the CHART Tag Matrix as it stands on 10.30.2018
		List<Course_Tag_Matrix__c> ctmList = new List<Course_Tag_Matrix__c>();
		//ctmList.add(new Course_Tag_Matrix__c(Department__c='Business and Economics', Primary_Area_Of_Study__c='Communications', Secondary_Area_Of_Study__c='Rhetoric'));
		//ctmList.add(new Course_Tag_Matrix__c(Department__c='Business and Economics', Primary_Area_Of_Study__c='Communications', Secondary_Area_Of_Study__c='Telecommunications'));
		ctmList.add(new Course_Tag_Matrix__c(Department__c='Communications and Film', Primary_Area_Of_Study__c='Communications', Secondary_Area_Of_Study__c='Rhetoric'));
		ctmList.add(new Course_Tag_Matrix__c(Department__c='Communications and Film', Primary_Area_Of_Study__c='Communications', Secondary_Area_Of_Study__c='Telecommunications'));

		ctmList.add(new Course_Tag_Matrix__c(Department__c='Biological and Life Sciences', Primary_Area_Of_Study__c='Biology', Secondary_Area_Of_Study__c='Behavioral and Cognitive Sciences'));
		ctmList.add(new Course_Tag_Matrix__c(Department__c='Social Sciences', Primary_Area_Of_Study__c='Biology', Secondary_Area_Of_Study__c='Behavioral and Cognitive Sciences'));
		ctmList.add(new Course_Tag_Matrix__c(Department__c='Social Sciences', Primary_Area_Of_Study__c='Communications', Secondary_Area_Of_Study__c='Behavioral and Cognitive Sciences'));
		insert ctmList;

		//instantiating a reference to the courseTag page
		PageReference ref = Page.courseTagPage;
		//setting up page url for testing
		Test.setCurrentPage(ref);

		//getting the standard controller for course
		ApexPages.StandardController stdTag = new ApexPages.StandardController(testcourse);
		//instantiating controller extension courseTag Controller
		courseTagController controller = new courseTagController(stdTag);

		//adding
		controller.newTags.add(new Tag__c(Department__c='Business and Economics', Area_Of_Study__c='Telecommunications'));
		controller.newTags.add(new Tag__c(Department__c='Social Sciences', Area_Of_Study__c='Biology'));

		controller.saveTags();

		Boolean hasCommunications = false;
		Boolean hasBiologicalDep = false;
		Boolean hasBehaveAndCog = false;
		List<Tag__c> newerTags = [SELECT Id, Department__c, Area_Of_Study__c FROM Tag__c WHERE Course__c =:testcourse.Id];
		for(Tag__c t : newerTags)
		{
			if(t.Area_Of_Study__c == 'Communications')
			{
				hasCommunications = true;
			}
			if(t.Department__c == 'Biological and Life Sciences')
			{
				hasBiologicalDep = true;
			}
			if(t.Area_of_Study__c == 'Behavioral and Cognitive Sciences')
			{
				hasBehaveAndCog = true;
			}
		}

		System.assert(hasCommunications);
		System.assert(hasBiologicalDep);
		System.assertNotEquals(true, hasBehaveAndCog);
		System.assertEquals(6, newerTags.size());

	}
	
}