@isTest
public without sharing class portalOnSiteRemotingMethodsTest {

    // Setup data for tests
    @TestSetup
    static void makeData(){
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'Billing', 'Housing', 'Courses', 'Support_Personnel', 'Program_Auths'/*, 'ParentAndChildCourses'*/});
    }

	public static testMethod void testModifyCourseRegistration()
	{
		List<Course__c> mockCourses = apexMockDataUtility.createParentAndChildCourses();
		Course__c Child = [SELECT Id FROM Course__c WHERE Type__c = 'Standard' LIMIT 1];
		System.debug('Child is ' + Child);
		Test.startTest();
		Course__c testCourse = portalOnSiteRemotingMethods.modifyCourseRegistration(Child.Id);
		System.debug('From testModifyCourseRegistration ' + testCourse);
		System.assertEquals (testCourse.Id, Child.Id );
		Test.stopTest();
	}
    public static testMethod void testSubmitCourseRegistration()
	{
		Program_Term__c programTerm = [SELECT Id FROM Program_Term__c LIMIT 1];
		Application__c application = [SELECT Id FROM Application__c LIMIT 1];
		Host_Institution__c hostInstitution = [SELECT Id, Name FROM Host_Institution__c LIMIT 1];
		Course__c hostCourse = [SELECT Id FROM Course__c LIMIT 1];
		Butler_Department_Code__c buCode = [SELECT Id FROM Butler_Department_Code__c LIMIT 1];

		application.Status__c = 'On Site';
		Database.update(application);
		
		Test.startTest();

		studentOnSiteViewModel viewModel = new studentOnSiteViewModel();
		viewModel.programTermId = programTerm.Id;
		viewModel.applicationId = application.Id;
		viewModel.courses = new List<studentOnSiteCourseRegViewModel>();

		studentOnSiteCourseRegViewModel subViewModel = new studentOnSiteCourseRegViewModel();
		subViewModel.courseName = 'OverrideTest';
		subViewModel.courseTitle = 'OverrideTest';
		subViewModel.courseId = hostCourse.Id;
		subViewModel.hostInstitutionName = hostInstitution.Name;
		subViewModel.hostInstitutionId = hostInstitution.Id;
		subViewModel.courseCode = 'NC1';
		subViewModel.credits = 5;
		subViewModel.departmentCode = buCode.Id;
		subViewModel.instructorName = 'new Instructor';
		subViewModel.usCredits = 4;
		subViewModel.courseStatus = 'Approval Pending';
		
		viewModel.courses.add(subViewModel);
		
		// Create ALTERNATE
		studentOnSiteCourseRegViewModel subViewModelAlt = new studentOnSiteCourseRegViewModel();
		subViewModelAlt.courseName = 'OverrideTestAlt';
		subViewModelAlt.courseTitle = 'OverrideTestAlt';
		subViewModelAlt.courseId = hostCourse.Id;
		subViewModelAlt.hostInstitutionName = hostInstitution.Name;
		subViewModelAlt.hostInstitutionId = hostInstitution.Id;
		subViewModelAlt.courseCode = 'NC2';
		subViewModelAlt.credits = 5;
		subViewModelAlt.departmentCode = buCode.Id;
		subViewModelAlt.instructorName = 'new Instructor';
		subViewModelAlt.usCredits = 4;
		subViewModelAlt.courseStatus = 'Approval Pending';
		subViewModelAlt.alternateFor = subViewModel.courseId;

		viewModel.courses.add(subViewModelAlt);


		//Boolean isSuccess = portalRemotingMethods.submitCourseRegistration(JSON.serialize(viewModel.courses), viewModel.applicationId);
        Boolean isSuccess = portalOnSiteRemotingMethods.submitCourseRegistration(JSON.serialize(viewModel.courses), viewModel.applicationId);
		System.assert(isSuccess, 'The course registration failed to save.');
		Test.stopTest();
	}
	public static testMethod void testSubmitCourseRegistration2()
	{
		Program_Term__c programTerm = [SELECT Id FROM Program_Term__c LIMIT 1];
		Application__c application = [SELECT Id FROM Application__c LIMIT 1];
		Host_Institution__c hostInstitution = [SELECT Id, Name FROM Host_Institution__c LIMIT 1];
		Course__c hostCourse = [SELECT Id FROM Course__c LIMIT 1];
		Butler_Department_Code__c buCode = [SELECT Id FROM Butler_Department_Code__c LIMIT 1];

		application.Status__c = 'Completed';
		Database.update(application);
		
		Test.startTest();

		studentOnSiteViewModel viewModel = new studentOnSiteViewModel();
		viewModel.programTermId = programTerm.Id;
		viewModel.applicationId = application.Id;
		viewModel.courses = new List<studentOnSiteCourseRegViewModel>();

		studentOnSiteCourseRegViewModel subViewModel = new studentOnSiteCourseRegViewModel();
		subViewModel.courseName = 'OverrideTest';
		subViewModel.courseTitle = 'OverrideTest';
		subViewModel.courseId = hostCourse.Id;
		subViewModel.hostInstitutionName = hostInstitution.Name;
		subViewModel.hostInstitutionId = hostInstitution.Id;
		subViewModel.courseCode = 'NC1';
		subViewModel.credits = 5;
		subViewModel.departmentCode = buCode.Id;
		subViewModel.instructorName = 'new Instructor';
		subViewModel.usCredits = 4;
		subViewModel.courseStatus = 'Approval Pending';
		
		viewModel.courses.add(subViewModel);
		
		// Create ALTERNATE
		studentOnSiteCourseRegViewModel subViewModelAlt = new studentOnSiteCourseRegViewModel();
		subViewModelAlt.courseName = 'OverrideTestAlt';
		subViewModelAlt.courseTitle = 'OverrideTestAlt';
		subViewModelAlt.courseId = hostCourse.Id;
		subViewModelAlt.hostInstitutionName = hostInstitution.Name;
		subViewModelAlt.hostInstitutionId = hostInstitution.Id;
		subViewModelAlt.courseCode = 'NC2';
		subViewModelAlt.credits = 5;
		subViewModelAlt.departmentCode = buCode.Id;
		subViewModelAlt.instructorName = 'new Instructor';
		subViewModelAlt.usCredits = 4;
		subViewModelAlt.courseStatus = 'Approval Pending';
		subViewModelAlt.alternateFor = subViewModel.courseId;

		viewModel.courses.add(subViewModelAlt);


		//Boolean isSuccess = portalRemotingMethods.submitCourseRegistration(JSON.serialize(viewModel.courses), viewModel.applicationId);
        Boolean isSuccess = portalOnSiteRemotingMethods.submitCourseRegistration(JSON.serialize(viewModel.courses), viewModel.applicationId);
		System.assert(isSuccess, 'The course registration failed to save.');
		Test.stopTest();
	}
    public static testMethod void testCreateCourseRegistration()
    {
        // Hello
        Application__c application = [SELECT Id FROM Application__c LIMIT 1];
        Host_Institution__c hostInstitution = [SELECT Id, Name FROM Host_Institution__c LIMIT 1];

        Test.startTest();
        //	public static Id createCourseRegistration(String courseName, String courseCode, Integer credits, String instructorFirstName, String instructorLastName, Id hostInstitution, String appId)
        Id resultId = portalOnSiteRemotingMethods.createCourseRegistration('Test Course', 'TEST101', 4, 'TestInstructorFirstName', 'TestInstructorLastName', hostInstitution.Id, String.valueOf(application.Id));
		Test.stopTest();
    }
	/**
	 * @description test the method that searches for courses.
	 */
	public static testMethod void testSearchForCourses()
	{
		Program_Term__c programTerm = [SELECT Id FROM Program_Term__c LIMIT 1];

		Test.startTest();
		List<studentOnSiteCourseRegViewModel> viewModelList = portalOnSiteRemotingMethods.searchForCourses(programTerm.Id, 'Te');
		Test.stopTest();
	}
	public static testMethod void testSearchForCoursesByProgram()
	{
		Application__c application = [SELECT Id FROM Application__c LIMIT 1];

		Test.startTest();
		List<Course__c> listResultCourses = portalOnSiteRemotingMethods.searchForCoursesByProgram(application.Id, 'Te');
		Test.stopTest();
	}
	public static testMethod void testGetCourseRegistrations()
	{
		Application__c application = [SELECT Id FROM Application__c LIMIT 1];

		Test.startTest();
		List<studentOnSiteCourseRegViewModel> listSOSCRVM = portalOnSiteRemotingMethods.getCourseRegistrations(String.valueOf(application.Id));
		Test.stopTest();
	}
	public static testMethod void testGetChildClasses()
	{
		List<Course__c> mockCourses = apexMockDataUtility.createParentAndChildCourses();
		Course__c Parent = [SELECT Id FROM Course__c WHERE Type__c = 'Generic' LIMIT 1];
		System.debug('Parent is ' + Parent);
		Test.startTest();
		List<Course__c> testList = portalOnSiteRemotingMethods.getChildClasses(Parent.Id);
		System.debug('From testGetChildClasses ' + testList);
		System.assert(testList.size() > 0);
		Test.stopTest();
	}
	public static testMethod void testCheckForExistingCourse()
	{
		Program_Term__c programTerm = [SELECT Id FROM Program_Term__c LIMIT 1];
		Application__c application = [SELECT Id FROM Application__c LIMIT 1];
		Host_Institution__c hostInstitution = [SELECT Id, Name FROM Host_Institution__c LIMIT 1];
		Course__c hostCourse = [SELECT Id FROM Course__c LIMIT 1];
		Butler_Department_Code__c buCode = [SELECT Id FROM Butler_Department_Code__c LIMIT 1];

		application.Status__c = 'On Site';
		Database.update(application);
		
		Test.startTest();

		studentOnSiteCourseRegViewModel viewModel = new studentOnSiteCourseRegViewModel();
		viewModel.courseTitle = 'OverrideTest';
		viewModel.courseCode = 'NC1';
		viewModel.hostInstitutionId = hostInstitution.Id;
		
		//Map<String, Object> mapObjectResults = portalOnSiteRemotingMethods.checkForExistingCourse(JSON.serialize(viewModel.courses));
		Map<String, Object> mapObjectResults = portalOnSiteRemotingMethods.checkForExistingCourse(JSON.serialize(viewModel));

		Test.stopTest();
	}
	public static testMethod void testSubmitSyllabus()
	{
		//	public static Boolean submitSyllabus(String courseId, String fileData, String fileType, String fileName)
		Course__c testCourse = [SELECT Id FROM Course__c LIMIT 1];

		Test.startTest();
		Boolean result = portalOnSiteRemotingMethods.submitSyllabus(String.valueOf(testCourse.Id), 'fileData', 'pdf', 'testFile');
		Test.stopTest();

	}
	public static testMethod void testGetCRFConfiguration()
	{
		//	public static Map<String, Object> getCRFConfiguration(String programTermName)
		Program_Term__c programTerm = [SELECT Id, Name FROM Program_Term__c LIMIT 1];

		Test.startTest();
		Map<String, Object> mapCRFConfig = portalOnSiteRemotingMethods.getCRFConfiguration(programTerm.Name);
		Test.stopTest();
	}
	public static testMethod void testupdateAbroadPhoneNumber()
	{
		Country__c country = [SELECT Id FROM Country__c LIMIT 1];
		Contact student = [SELECT Id FROM Contact LIMIT 1];
		String testPhoneNumber = '555-555-5555';
		//Call public static method portalRemotingMethods.updateAbroadPhoneNumber
		//Params (String phoneNumber, String countryId, String studentId)
		//Returns Boolean
		Test.startTest();
		Boolean success = portalOnSiteRemotingMethods.updateAbroadPhoneNumber(testPhoneNumber, country.Id, student.Id);

		Contact c = [SELECT Id, Address_Abroad_Cell_Phone__c, Abroad_Cell_Phone_Country__c FROM Contact WHERE Id =: student.Id];
		System.assertEquals(testPhoneNumber, c.Address_Abroad_Cell_Phone__c);
		System.assertEquals(country.Id, c.Abroad_Cell_Phone_Country__c);
		Test.stopTest();
	}
	public static testMethod void testSaveAndGetTrip()
	{
		Contact c = [SELECT Id FROM Contact LIMIT 1];
		Application__c app = [SELECT Id FROM Application__c LIMIT 1];
		Country__c country = [SELECT Id, Name FROM Country__c LIMIT 1];

		Test.startTest();

		model_trip trip = new model_trip();

		trip.travelId = '';
		trip.applicationId = app.Id;
		trip.contactId = c.Id;
		//trip.countryId = country.Id;
		trip.countryName = country.Name;
		trip.endDate = Date.today().addDays(7);
		trip.startDate = Date.today();
		trip.description = 'Lorem ipsum dolar amit...';
		trip.localityId = null;
		trip.localityName = null;
		trip.selectedStatus = 'Upcoming';
		trip.statuses = apexConversionUtility.getPicklistStringValues(Trip__c.Status__c);
		trip.tripPhoneCountry = country.Id;
		trip.tripPhone = '+1 (317) 555-5555';

		//Save the trip
		String sResult = portalOnSiteRemotingMethods.saveTrip(JSON.serialize(trip));
		System.assertNotEquals(null, sResult);
		//Reinstaniate trip object with the trip record using the record Id
		trip = new model_trip(sResult);		
		//Get the trip
		List<model_trip> gResult = portalOnSiteRemotingMethods.getTrips(String.valueOf(app.Id));

		Test.stopTest();
	}
	public static testMethod void testSaveAndDeleteTrip()
	{
		Contact c = [SELECT Id FROM Contact LIMIT 1];
		Application__c app = [SELECT Id FROM Application__c LIMIT 1];
		Country__c country = [SELECT Id, Name FROM Country__c LIMIT 1];

		Test.startTest();

		model_trip trip = new model_trip();

		trip.travelId = '';
		trip.applicationId = app.Id;
		trip.contactId = c.Id;
		//trip.countryId = country.Id;
		trip.countryName = country.Name;
		trip.endDate = Date.today().addDays(7);
		trip.startDate = Date.today();
		trip.description = 'Lorem ipsum dolar amit...';
		trip.localityId = null;
		trip.localityName = null;
		trip.selectedStatus = 'Upcoming';
		trip.statuses = apexConversionUtility.getPicklistStringValues(Trip__c.Status__c);
		trip.tripPhoneCountry = country.Id;
		trip.tripPhone = '+1 (317) 555-5555';

		//Save the trip
		String sResult = portalOnSiteRemotingMethods.saveTrip(JSON.serialize(trip));
		System.assertNotEquals(null, sResult);
		//Reinstaniate trip object with the trip record using the record Id
		trip = new model_trip(sResult);		
		//Delete the trip
		Boolean dResult = portalOnSiteRemotingMethods.deleteTrip(trip.travelId);
		System.assertEquals(true, dResult);

		Test.stopTest();
	}
	
	public static testMethod void testGetHousingInfo()
	{
		//	public static studentOnSiteViewModel getHousingInfo(String applicationId)
		Application__c application = [SELECT Id, Housing_Assignment__c FROM Application__c LIMIT 1];
		Housing_Assignment__c HA = [SELECT Id FROM Housing_Assignment__c LIMIT 1];
		application.Housing_Assignment__c = HA.Id;
		Database.update(application);

		Test.startTest();
		studentOnSiteViewModel sosvmResult = portalOnSiteRemotingMethods.getHousingInfo(String.valueOf(application.Id));
		Test.stopTest();
	}
}