/**
 * Test class for <<chartRemoteMethods>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
@isTest
private class chartRemoteMethodsTest 
{
	/**
	 * Test setup Creates test data
	 */
	@TestSetup
	static void makeData(){
		Map<String, sObject> testData = apexMockDataUtility.createIfsaDataCollection();
	}
	static testMethod void testStudentCMP()
	{
		// Generates test data
		Contact c = [SELECT Id, Home_Institution__r.Account__c, Home_Institution__r.Name FROM Contact WHERE RecordType.Name = 'Student' LIMIT 1];
		User testUser = [SELECT Id FROM User WHERE ContactId =: c.Id];

		Test.startTest();
		System.runAs(testUser)
		{
			// Test creating a CMP request
			chartJSRemotingResponse response = chartRemoteMethods.saveCMPRequest('');
			System.assertEquals(false, response.success);

			model_courseMatchingProject request = new model_courseMatchingProject();
			request.contactId = c.Id;
			request.homeInstitutionAccountId = c.Home_Institution__r.Account__c;
			request.homeInstitutionName = c.Home_Institution__r.Name;
			request.major = 'Accounting';
			request.type = 'CE';
			request.additionalInformation = 'Magnam autem in. Laudantium autem quo voluptatem perferendis nisi iure enim fugiat. Ducimus minus eum laboriosam praesentium perferendis inventore. Et hic ut cumque eum consectetur maxime non. Natus illo maxime quia.';
			request.yearInSchool = '3';
			request.includeNonApprovedPrograms = false;
			request.yearsAbroad = new List<String>{String.valueOf(Date.today().year() + 1), String.valueOf(Date.today().year() + 2)};

			response = chartRemoteMethods.saveCMPRequest(JSON.serialize(request));
			system.debug(response);
			System.assertEquals(true, response.success);

			// Test getting all CMPs
			response = chartRemoteMethods.getCMPs();
			List<CMP__c> cmps = (List<CMP__c>) response.payload;
			System.assertEquals(false, cmps.isEmpty());

			// Test getting CMP details
			response =  chartRemoteMethods.getCMPDetails(cmps.get(0).Id);
			System.assertnotEquals(null, response.payload);
		}
		Test.stopTest();
	}
	
	static testMethod void testAdvisorCMP()
	{
		// Generates test data
		Contact c = [SELECT Id, AccountId, Account.Name FROM Contact WHERE RecordType.Name = 'Advisor' LIMIT 1];
		User testUser =  apexMockDataUtility.createAdvisor(c.Id);
		Account homeInstAccount = [SELECT Id, Name FROM Account WHERE Id =: c.AccountId];
		Course__c course1 = [SELECT Id FROM Course__c WHERE RecordType.Name = 'Host Institution'];
		Tag__c t = new Tag__c(
			Course__c = course1.Id,
			Area_of_Study__c = 'Accounting',
			Department__c = 'Business and Economics'
		);
		Database.insert(t);
		course1.Approved_For_CHART__c = true;
		Database.update(course1);
		Test.startTest();
		System.runAs(testUser)
		{
			// Test creating a CMP request
			chartJSRemotingResponse response = chartRemoteMethods.saveCMPRequest('');
			System.assertEquals(false, response.success);

			model_courseMatchingProject request = new model_courseMatchingProject();
			request.contactId = c.Id;
			request.homeInstitutionAccountId = homeInstAccount.Id;
			request.homeInstitutionName = homeInstAccount.Name;
			request.major = 'Accounting';
			request.type = 'CI';
			request.additionalInformation = 'Magnam autem in. Laudantium autem quo voluptatem perferendis nisi iure enim fugiat. Ducimus minus eum laboriosam praesentium perferendis inventore. Et hic ut cumque eum consectetur maxime non. Natus illo maxime quia.';
			request.includeNonApprovedPrograms = true;
			request.yearsAbroad = new List<String>{String.valueOf(Date.today().year() + 1), String.valueOf(Date.today().year() + 2)};

			response = chartRemoteMethods.saveCMPRequest(JSON.serialize(request));
			system.debug(response);
			System.assertEquals(true, response.success);

			// Test getting CMPs
			response = chartRemoteMethods.getCMPs();
			List<CMP__c> cmps = (List<CMP__c>) response.payload;
			System.assertEquals(false, cmps.isEmpty());

			// Test getting CMP details
			// Completing CMP so that last viewed date is updated
			for(CMP__c cmp: cmps)
			{
				cmp.Status__c = 'Completed';
				cmp.Do_Not_Include_Custom_Message__c = true;
			}
			Database.update(cmps);

			response = chartRemoteMethods.getCMPDetails(cmps.get(0).Id);
			System.assertnotEquals(null, response.payload);

			PageReference ref = new PageReference('/apex/CH_Search');
			Test.setCurrentPage(ref);
			chartSearchController controller = new chartSearchController();
			List<Id> courseIds = controller.viewModel.courseIds;

			Course__c homeCourse = apexMockDataUtility.createHomeCourse();
			Course_Equivalency__c ce = new Course_Equivalency__c(Home_Institution_Course__c = homeCourse.Id, Host_Institution_Course__c = courseIds.get(0));
			database.insert(ce);

			response = chartRemoteMethods.getAllCourseEquivalents(courseIds);
			System.assertNotEquals(null, response.payload);

			PageReference ref2 = new PageReference('/apex/chartInternal');
			ApexPages.currentPage().getParameters().put('cmpId', cmps[0].Id);
			chartSearchController controller2 = new chartSearchController();
		}
		Test.stopTest();
	}
	
	static testMethod void chartSearch() 
	{
		// Create Test Records
		Contact studentContact = [SELECT Id, Home_Institution__r.Account__c, Home_Institution__r.Name FROM Contact WHERE RecordType.Name = 'Student' LIMIT 1];
		User chartUser = [SELECT Id FROM User WHERE ContactId =: studentContact.Id];

		// Test
		Test.startTest();
		
		Course__c c = new Course__c();
		c.RecordTypeId = Schema.sObjectType.Course__c.getRecordTypeInfosByName().get('Host Institution').getRecordTypeId();
		c.Name = 'Test Course';
		Database.insert(c);
		Program_Course__c pc = new Program_Course__c();
		pc.Program__c = [SELECT Id FROM Program__c LIMIT 1].get(0).Id;
		pc.Course__c = c.Id;
		Tag__c t = new Tag__c(
			Course__c = c.Id,
			Area_of_Study__c = 'Accounting',
			Department__c = 'Business and Economics'
		);
		Database.insert(new List<SObject>{pc, t});
		c.Approved_for_CHART__c = True;
		c.Butler_Department_Code__c = [SELECT Id FROM Butler_Department_Code__c LIMIT 1].get(0).Id;
		
		Database.update(c);
			
			System.runAs(chartUser)
			{
				PageReference ref = new PageReference('/apex/CH_Search');
				Test.setCurrentPage(ref);
				chartSearchController controller = new chartSearchController();
				chartSearchViewModel viewModel = controller.viewModel;

				// Get list of courses
				chartJSRemotingResponse response = chartRemoteMethods.getCourses(viewModel.courseIds, null);
				System.assertNotEquals(null, response.payload);
				List<Course__c> courses = (List<Course__c>) response.payload;
				System.assertEquals(false, courses.isEmpty());

				response = chartRemoteMethods.getCourse(viewModel.courseIds.get(0), null);
				model_course course = (model_course) response.payload;
				System.assertNotEquals(null, response.payload);
			}
		
		Test.stopTest();
	}
	
	static testMethod void testSaveEquivalents()
	{
		// Create Test Records
		Course__c homeCourse = apexMockDataUtility.createHomeCourse();
		Course__c hostCourse = [SELECT Id FROM Course__c WHERE RecordType.Name = 'Host Institution' LIMIT 1];

		CMP__c cmp = new CMP__c();
		cmp.Home_Institution_Account__c = [SELECT Id FROM Account WHERE RecordType.Name = 'Home Institution' LIMIT 1].get(0).Id;
		cmp.RecordTypeId = Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Curriculum Integration').getRecordTypeId();
		cmp.Status__c = 'Completed';
		cmp.Do_Not_Include_Custom_Message__c = true;

		Database.insert(cmp);

		Course_Equivalency__c ce = new Course_Equivalency__c();
		ce.Home_Institution_Course__c = homeCourse.Id;
		ce.Host_Institution_Course__c = hostCourse.Id;
		ce.Status__c = 'Potential Match';

		
		Database.insert(ce);

		test.startTest();
		List<model_courseEquivalency> mces = new List<model_courseEquivalency>();
		model_courseEquivalency mce = new model_courseEquivalency(ce);
		mce.status = 'Match';
		mces.add(mce);
		chartJSRemotingResponse response = chartRemoteMethods.saveCourseEquivalents(JSON.serialize(mces));
		System.assertEquals(true, response.success);
		test.stopTest();

		ce = [SELECT Id, Status__c FROM Course_Equivalency__c WHERE Id =: ce.Id];
		System.assertEquals(mce.status, ce.Status__c);
	}

	static testMethod void testUpdateCESearch()
	{
		
		// Create User
		Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
  
		User u = new User(
			LastName = 'USER',
			FirstName='TEST',
			Alias = 'tuser',
			Email = 'tuser@email.test',
			Username = 'tuser@email.test',
			ProfileId = profileId.id,
			TimeZoneSidKey = 'GMT',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			LocaleSidKey = 'en_US'
		);
		insert(u);
		
		Id homeInstitutionRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId();
		// Create Account
		Account a = new Account(
			Name = 'Test Home Institution Account',
			RecordTypeId = homeInstitutionRecordTypeId
		);
		insert(a);
		
		// Run test
		test.startTest();
		chartJSRemotingResponse response = chartRemoteMethods.updateCESearch(true, u.Id, a.Id);
		System.assertEquals(true, response.success);

		response = chartRemoteMethods.updateCESearch(false, u.Id, a.Id);
		Task[] tasks = [SELECT Id FROM Task WHERE WhatId =: a.Id];
		System.assertNotEquals(true, tasks.isEmpty());

		test.stopTest();
	}

	static testMethod void testAddingCourseToCMP()
	{
		Contact c = [SELECT Id, AccountId, Account.Name FROM Contact WHERE RecordType.Name = 'Advisor' LIMIT 1];
		User testUser =  apexMockDataUtility.createAdvisor(c.Id);
		Account homeInstAccount = [SELECT Id, Name FROM Account WHERE Id =: c.AccountId];
		Country__c country = [SELECT Id, Name FROM Country__c LIMIT 1];
		Program__c program = [SELECT Id, Name FROM Program__c LIMIT 1];
		Course__c hostCourse = [SELECT Id FROM Course__c WHERE RecordType.Name = 'Host Institution'];
		Course__c homeCourse = apexMockDataUtility.createHomeCourse();
		/*
		homeCourse.Home_Institution_Account__c = homeInstAccount.Id;
		Database.update(homeCourse);
		*/
		
		test.startTest();

		model_courseMatchingProject request = new model_courseMatchingProject();
		request.contactId = c.Id;
		request.homeInstitutionAccountId = homeInstAccount.Id;
		request.homeInstitutionName = homeInstAccount.Name;
		request.major = 'Accounting';
		request.type = 'CI';
		request.additionalInformation = 'Magnam autem in. Laudantium autem quo voluptatem perferendis nisi iure enim fugiat. Ducimus minus eum laboriosam praesentium perferendis inventore. Et hic ut cumque eum consectetur maxime non. Natus illo maxime quia.';
		request.includeNonApprovedPrograms = true;
		request.yearsAbroad = new List<String>{String.valueOf(Date.today().year() + 1), String.valueOf(Date.today().year() + 2)};
		request.specificCountries = new List<String>{country.Name};
		request.specificPrograms = new List<String>{program.Name};		
		request.convertToCMP(true);

		

		chartJSRemotingResponse reponse = chartRemoteMethods.addCourseToCMP(hostCourse.Id, request.recordId);

		test.stopTest();
	}

	static testMethod void testAddingCoursesToCMP()
	{
		Contact c = [SELECT Id, AccountId, Account.Name FROM Contact WHERE RecordType.Name = 'Advisor' LIMIT 1];
		User testUser =  apexMockDataUtility.createAdvisor(c.Id);
		Account homeInstAccount = [SELECT Id, Name FROM Account WHERE Id =: c.AccountId];
		Country__c country = [SELECT Id, Name FROM Country__c LIMIT 1];
		Program__c program = [SELECT Id, Name FROM Program__c LIMIT 1];
		Course__c hostCourse = [SELECT Id FROM Course__c WHERE RecordType.Name = 'Host Institution'];
		Course__c homeCourse = apexMockDataUtility.createHomeCourse();
		homeCourse.Home_Institution_Account__c = homeInstAccount.Id;
		test.startTest();
		Database.update(homeCourse);
		

		model_courseMatchingProject request = new model_courseMatchingProject();
		request.contactId = c.Id;
		request.homeInstitutionAccountId = homeInstAccount.Id;
		request.homeInstitutionName = homeInstAccount.Name;
		request.major = 'Accounting';
		request.type = 'CI';
		request.additionalInformation = 'Magnam autem in. Laudantium autem quo voluptatem perferendis nisi iure enim fugiat. Ducimus minus eum laboriosam praesentium perferendis inventore. Et hic ut cumque eum consectetur maxime non. Natus illo maxime quia.';
		request.includeNonApprovedPrograms = true;
		request.yearsAbroad = new List<String>{String.valueOf(Date.today().year() + 1), String.valueOf(Date.today().year() + 2)};
		request.specificCountries = new List<String>{country.Name};
		request.specificPrograms = new List<String>{program.Name};		
		request.convertToCMP(true);

		chartJSRemotingResponse reponse = chartRemoteMethods.addCoursesToCMP(new List<String>{hostCourse.Id}, request.recordId);

		test.stopTest();
	}

	static testMethod void testAddingNewHomeInstitutionCourse()
	{
		Contact c = [SELECT Id, AccountId, Account.Name FROM Contact WHERE RecordType.Name = 'Advisor' LIMIT 1];
		User testUser =  apexMockDataUtility.createAdvisor(c.Id);
		Account homeInstAccount = [SELECT Id, Name FROM Account WHERE Id =: c.AccountId];
		Country__c country = [SELECT Id, Name FROM Country__c LIMIT 1];
		Program__c program = [SELECT Id, Name FROM Program__c LIMIT 1];
		Course__c hostCourse = [SELECT Id FROM Course__c WHERE RecordType.Name = 'Host Institution'];
		

		model_courseMatchingProject request = new model_courseMatchingProject();
		request.contactId = c.Id;
		request.homeInstitutionAccountId = homeInstAccount.Id;
		request.homeInstitutionName = homeInstAccount.Name;
		request.major = 'Accounting';
		request.type = 'CI';
		request.additionalInformation = 'Magnam autem in. Laudantium autem quo voluptatem perferendis nisi iure enim fugiat. Ducimus minus eum laboriosam praesentium perferendis inventore. Et hic ut cumque eum consectetur maxime non. Natus illo maxime quia.';
		request.includeNonApprovedPrograms = true;
		request.yearsAbroad = new List<String>{String.valueOf(Date.today().year() + 1), String.valueOf(Date.today().year() + 2)};
		request.specificCountries = new List<String>{country.Name};
		request.specificPrograms = new List<String>{program.Name};		
		request.convertToCMP(true);

		test.startTest();

		Map<String, String> homeCourseData = new Map<String, String>();
		homeCourseData.put('CourseCode', 'TST100');
		homeCourseData.put('CourseTitle', 'Intro to Testing');
		homeCourseData.put('CourseDescription', 'Est ipsam harum consequuntur eos at perferendis officia perspiciatis expedita. Maxime perferendis molestiae quis eveniet. Alias qui non. Odit ut ut expedita quidem et nihil nihil nisi. Ex magni voluptatem qui fuga fugit suscipit et vel.');
		homeCourseData.put('HomeInstitutionAccount', homeInstAccount.Id);
		String jsonData = JSON.serialize(homeCourseData);
		chartJSRemotingResponse reponse = chartRemoteMethods.createNewHomeInstitutionCourseEquivalency(jsonData, hostCourse.Id, request.recordId);

		test.stopTest();
	}

	static testMethod void testchartJSRemotingResponse()
	{
		// This test method is to test CHART error and exception handling
		try
		{
			chartJSRemotingResponse response = new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_1001);
			throw new chartJSRemotingResponse.chartJSRemotingResponseException();
		}
		catch(Exception e)
		{
			chartJSRemotingResponse response = new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_1001, e);
		}		
	}
    static testMethod void testClassMatchUpload()
	{
		// Create Mock Data
		Contact c = [SELECT Id, AccountId, Account.Name FROM Contact WHERE RecordType.Name = 'Advisor' LIMIT 1];
		User testUser =  apexMockDataUtility.createAdvisor(c.Id);
		Account homeInstAccount = [SELECT Id, Name FROM Account WHERE Id =: c.AccountId];

		Blob fileData = Blob.valueOf('Code,Title,Description,IFSA Course Code, IFSA Course Title \r\n CS-101, Intro to Computing, Introduction to Computing., Program Name, Host Instituion Sint saepe consectetur libero excepturi exercitationem amet. Nam quae et debitis voluptatem. Voluptatem consequuntur odit. Accusamus qui quibusdam magnam tempora ut perspiciatis mollitia nemo., CIS-100, Computer Introduction, King\'s College London, King\'s College London');

		test.startTest();
		System.runAs(testUser)
		{
			chartJSRemotingResponse response = chartRemoteMethods.uploadCEFile(null, 'text', 'Test.csv');
			System.assertEquals(false, response.success);
			response = chartRemoteMethods.uploadCEFile(fileData.toString(), 'text', 'Test.csv');
			System.assertEquals(false, response.success);
			response = chartRemoteMethods.uploadCEFile(System.EncodingUtil.base64Encode(fileData), 'text', 'Test.csv');
			System.assertEquals(true, response.success);
		}
		test.stopTest();

		Id rtId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Uploaded File Task').getRecordTypeId();
		List<Task> tasks = [SELECT Id FROM Task WHERE RecordTypeId =: rtId];
		System.assertEquals(false, tasks.isEmpty());
	}

	static testMethod void chartPreAdmitCIFAppItems() 
	{
		// Create Test Records
		Contact c = [SELECT Id, Home_Institution__r.Account__c, Home_Institution__r.Name, Active_Application__c FROM Contact WHERE RecordType.Name = 'Student' AND Active_Application__c != null LIMIT 1];
		User chartUser = [SELECT Id FROM User WHERE ContactId =: c.Id];
		
		Application_Item__c cif = new Application_Item__c(
			RecordTypeId = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Class Interest Form').getRecordTypeId(),
			Application__c = c.Active_Application__c,
			Name = 'Class Interest Form',
			Status__c = 'Incomplete',
			Phase__c = 'Pre-Admit'
		);

		Database.insert(cif);

		// Test
		Test.startTest();
		chartSearchController controller;
		chartSearchViewModel viewModel;
		PageReference ref;
			
		System.runAs(chartUser)
		{
			// Pre-Admit CIF
			ref = new PageReference('/apex/CH_Search');
			Test.setCurrentPage(ref);
			controller = new chartSearchController();
			viewModel = controller.viewModel;

			system.assertEquals(false, viewModel.cifAppItems.isEmpty());
			
			// Pre-Acceptance 
			/* cif.Phase__c = 'Pre-Acceptance';
			app.Status__c = 'Submitted';
			database.update(new List<SObject>{cif, app});
			ref = new PageReference('/apex/CH_Search');
			Test.setCurrentPage(ref);
			controller = new chartSearchController();
			viewModel = controller.viewModel;

			system.assertEquals(false, viewModel.cifAppItems.isEmpty()); */

			// Post-Acceptance 
			/* cif.Phase__c = 'Post-Acceptance';
			app.Status__c = 'Accepted';
			database.update(new List<SObject>{cif, app});
			ref = new PageReference('/apex/CH_Search');
			Test.setCurrentPage(ref);
			controller = new chartSearchController();
			viewModel = controller.viewModel;

			system.assertEquals(false, viewModel.cifAppItems.isEmpty()); */
		}
		
		Test.stopTest();
	}

	static testMethod void chartPreAcceptCIFAppItems() 
	{
		// Create Test Records
		Contact c = [SELECT Id, Home_Institution__r.Account__c, Home_Institution__r.Name, Active_Application__c FROM Contact WHERE RecordType.Name = 'Student' AND Active_Application__c != null LIMIT 1];
		User chartUser = [SELECT Id FROM User WHERE ContactId =: c.Id];
		Application__c app = new Application__c(Id = c.Active_Application__c, Status__c = 'Submitted');
        system.debug ('app--'+app);
        // Added this code by Vinod Powerfluence on <9/28/2021> for fixing the error and code coverage
       List<Favorite__c> favorites = new List<Favorite__c>();
			favorites = [SELECT Id, Name, Contact__c, Course__c, Course__r.Course_Title_2__c, Course__r.Course_Description_Short__c, CreatedDate FROM Favorite__c  ];
		Database.update(favorites);
            // Test
		Test.startTest();
		Application_Item__c cif = new Application_Item__c(
			RecordTypeId = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Class Interest Form').getRecordTypeId(),
			Application__c = c.Active_Application__c,
			Name = 'Class Interest Form',
			Status__c = 'Incomplete',
			Phase__c = 'Pre-Acceptance'
		);
		Database.insert(cif);
		chartSearchController controller;
		chartSearchViewModel viewModel;
		PageReference ref;	
		System.runAs(chartUser)
		{
			// Pre-Admit CIF
			ref = new PageReference('/apex/CH_Search');
			Test.setCurrentPage(ref);
			controller = new chartSearchController();
			viewModel = controller.viewModel;
			system.assertEquals(true, viewModel.cifAppItems.isEmpty());
		}
		Test.stopTest();
	}
	static testMethod void chartPostAcceptCIFAppItems() 
	{
		// Create Test Records
		Contact c = [SELECT Id, Home_Institution__r.Account__c, Home_Institution__r.Name, Active_Application__c FROM Contact WHERE RecordType.Name = 'Student' AND Active_Application__c != null LIMIT 1];
		User chartUser = [SELECT Id FROM User WHERE ContactId =: c.Id];
		Application__c app = new Application__c(Id = c.Active_Application__c, Status__c = 'Accepted', Approval_Override__c = true);
		contactTriggerHandler.bypassTrigger = true;
		Database.update(app);
		// Test
		Test.startTest();
		Application_Item__c cif = new Application_Item__c(
			RecordTypeId = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Class Interest Form').getRecordTypeId(),
			Application__c = c.Active_Application__c,
			Name = 'Class Interest Form',
			Status__c = 'Incomplete',
			Phase__c = 'Post-Acceptance'
		);
		Database.insert(cif);
		chartSearchController controller;
		chartSearchViewModel viewModel;
		PageReference ref;
			
		System.runAs(chartUser)
		{
			// Pre-Admit CIF
			ref = new PageReference('/apex/CH_Search');
			Test.setCurrentPage(ref);
			controller = new chartSearchController();
			viewModel = controller.viewModel;
			system.assertEquals(false, viewModel.cifAppItems.isEmpty());
		}
		
		Test.stopTest();
	}
    
    // Added this code by Vinod Powerfluence on <10/12/2021> for fixing the error and code coverage
	 static testMethod void getFavoritesItems(){ 
        Test.startTest();
        chartJSRemotingResponse response = chartRemoteMethods.getFavorites();
        System.assertEquals(true, response.success);
        Test.stopTest();
    }
    // Added this code by Vinod Powerfluence on <10/12/2021> for fixing the error and code coverage
    static testMethod void updateFavoriteitems()
    { 
        Test.startTest();
        List<Course__c> course = [Select Id,Name,Course_Title__c,Host_Institution__c From Course__c Limit 1];
        List<Contact> contact = [Select Id,Lastname,Home_Institution__c,CurrencyIsoCode  From Contact Limit 1];
        Favorite__c favorite = new Favorite__c ();
        favorite.CurrencyIsoCode = 'USD';
        favorite.Contact__c = contact[0].Id;
        favorite.Course__c = course[0].Id;
        insert favorite;
        chartJSRemotingResponse addFavResponse = chartRemoteMethods.updateFavorite(contact[0].Id,course[0].Id,'',False);
        System.assertEquals(true, addFavResponse.success);
        chartJSRemotingResponse deleteFavResponse = chartRemoteMethods.updateFavorite('','',favorite.Id,true);
        System.assertEquals(true, deleteFavResponse.success);
        Test.stopTest();    
} 
    // Added this code by Vinod Powerfluence on <10/12/2021> for fixing the error and code coverage
    static testMethod void updateCourseEquivalents(){
        Test.startTest();
        List<Course__c> course = [Select Id,Name,Course_Title__c,Host_Institution__c From Course__c Limit 1];
        Account account = new Account();
        account.name = 'Text';
        insert account;
        Contact contact = new Contact();
        contact.lastname= ' Text1';
        contact.AccountId = account.Id;
        insert contact;
        chartJSRemotingResponse Response = chartRemoteMethods.getCourseEquivalents(course[0].Id,contact.AccountId);
        System.assertEquals(true, Response.success);
        Test.stopTest(); 
    }
}