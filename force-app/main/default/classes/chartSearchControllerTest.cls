@isTest
private class chartSearchControllerTest {
/*
	@isTest static void chartSearch() {
		// Create Test Records
		Map<String, sObject> testData = apexMockDataUtility.createIfsaDataCollection();
		User chartUser = (User) testData.get('studentUser');
		
		Course__c c = new Course__c();
		c.RecordTypeId = Schema.sObjectType.Course__c.getRecordTypeInfosByName().get('Host Institution').getRecordTypeId();
		c.Name = 'Test Course';
		c.Approved_for_CHART__c = True;
		Database.insert(c);
		Program_Course__c pc = new Program_Course__c();
		pc.Program__c = testData.get('program').Id;
		pc.Course__c = c.Id;
		Database.insert(pc);

		// Test
		Test.startTest();
			
			System.runAs(chartUser)
			{
				PageReference ref = new PageReference('/apex/CH_Search');
				Test.setCurrentPage(ref);
				chartSearchController controller = new chartSearchController();
				chartSearchViewModel viewModel = controller.viewModel;

				// Get list of courses
				List<Course__c> courses = chartSearchController.getCourses(viewModel.courseIds);
				System.assertEquals(false, courses.isEmpty());

				model_course course = chartSearchController.getCourse(viewModel.courseIds.get(0));
				System.assertNotEquals(null, course);
			}
		
		Test.stopTest();
	}
*/	
}