@isTest
public without sharing class studentLoginControllerTest
{
	@isTest
	static void testInstanceNewAccount()
	{
		//User administrator = apexMockDataUtility.createSysAdmin();
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>());
		List<String> sections = new List<String>{'Spring', 'Fall', 'Summer', 'Calendar Year', 'Academic Year'};
		List<Term__c> setupTerms = apexMockDataUtility.createTerms(sections, Date.today().year() + 1);
		apexMockDataUtility.createProgramTerms(new List<Program__c>{(Program__c) testData.get('program')}, setupTerms[0], (User) testData.get('academicAffiarsUser'));
		Test.startTest();
		Database.insert(new Program__c(Name='Undecided', Host_Institution__c=null, Country__c = testData.get('country').Id));

		studentLoginController controller = new studentLoginController();
		PageReference reference = controller.authorize();

		controller.viewModel.email = 'Test@test.org';
		controller.viewModel.password = 'theWrongPassword';

		User testUser = (User) testData.get('studentUser');
		User guestUser = [SELECT Id FROM User WHERE Name = 'Student Portal Site Guest User'].get(0);
       
		System.runAs(guestUser){
			controller = new studentLoginController();
			controller.viewModel.email = 'utest@utest.test';
			controller.viewModel.password = 'thePassword1';
			controller.viewModel.firstName = 'Unit';
			controller.viewModel.lastName = 'Test';
			Home_Institution__c homeInstitution = (Home_Institution__c) testData.get('homeInstitution1');
			controller.viewModel.homeInstitutionName = studentLoginController.searchHomeInstitution(homeInstitution.Name.subString(0, 5)).get(0).Name;
			controller.viewModel.major = controller.viewModel.majorOptions[0].label    ;
			List<Term__c> terms = studentLoginController.getTerms(controller.viewModel.countryOptions[0].Id);
			controller.viewModel.programTerms = studentLoginController.searchPrograms(controller.viewModel.countryOptions[0].Id, terms[0].Id, controller.viewModel.homeInstitutionName);
			controller.viewModel.programOfInterest = controller.viewModel.programTerms[0];
			List<Program_Term__c> programOptions = studentLoginController.getProgramOptions(controller.viewModel.programOfInterest.Id);
			// Create portal user method will always return an error in testing - SFDC testing limitation
			createCommunityUserService result = studentLoginController.register(controller.viewModel.getSerializedViewModel());
			studentLoginViewModel vm = (studentLoginViewModel) result.viewModel;
			result.viewModel = null;
			result = studentLoginController.prepareUserRecord(JSON.serialize(result), JSON.serialize(vm));
			vm = (studentLoginViewModel) result.viewModel;
			result.viewModel = null;
			String userId = studentLoginController.createUserRecord(JSON.serialize(result), JSON.serialize(vm));
			
			String url = studentLoginController.createApplicationAndUpdateContact(testUser.Id, controller.viewModel.getSerializedViewModel());
			System.debug(url);
			System.assertEquals('', url);
// added by powerfluence based on Clayton req 03/29/2022 starts
		createCommunityUserService testobj = new createCommunityUserService();
            createCommunityUserService testobj1 = new createCommunityUserService(vm, createCommunityUserService.Community.CUSTOM_PORTAL);
            createCommunityUserService testobj2 = new createCommunityUserService(vm,createCommunityUserService.Community.CHART); 
            createCommunityUserService testobj3 = new createCommunityUserService(vm,createCommunityUserService.Community.ADVISOR_PORTAL); 
            createCommunityUserService testobj4 = new createCommunityUserService(vm,createCommunityUserService.Community.STUDENT_PORTAL); 
            String abc = testobj1.getErrorEmailAddress();
            testobj1.deleteAccountAndContact();
		  testobj1.prepareUserRecord();
            abc = testobj2.getErrorEmailAddress();
            testobj2.deleteAccountAndContact();
            abc = testobj3.getErrorEmailAddress();
            testobj3.deleteAccountAndContact();
            abc = testobj4.getErrorEmailAddress();
            testobj4.deleteAccountAndContact();
		  abc = testobj.getErrorEmailAddress();

		}
// added by powerfluence based on Clayton req 03/29/2022 ends
		Test.stopTest();
		Contact testContact = [SELECT Id, Active_Application__c FROM Contact WHERE Id =: testUser.ContactId];
		Application__c testApp = [SELECT Id FROM Application__c WHERE Id =: testContact.Active_Application__c];
		Apex_String_Constant__mdt taskName = [SELECT Value__c FROM Apex_String_Constant__mdt WHERE DeveloperName = 'Welcome_Task'].get(0);
        //modified by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
		// System.assertEquals(true, [SELECT Count() FROM Task WHERE Subject =: taskName.Value__c AND WhoId =: testContact.Id AND WhatId =: testApp.Id] > 0);
		System.assertEquals(false, [SELECT Count() FROM Task WHERE Subject =: taskName.Value__c AND WhoId =: testContact.Id AND WhatId =: testApp.Id] > 0);
        //modified by PowerFluence req_dt:03/29/2022 ref email from Clayton ends

	}
	
	@isTest
	static void testInstanceExistingAccount()
	{
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>());
		Account existingAccount = new Account();		
		existingAccount.Name = 'Existing Account';
		existingAccount.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Student Account'].get(0).Id;
		Database.insert(existingAccount);

		Home_Institution__c homeInstitution = (Home_Institution__c) testData.get('homeInstitution1');

		Contact existingContact = new Contact();
		existingContact.FirstName = 'Existing';
		existingContact.LastName = 'O\'Account';
		existingContact.Email = 'existing@email.test';
		existingContact.Home_Institution__c = homeInstitution.Id;
		existingContact.AccountId = existingAccount.Id;
		Database.SaveResult sr = Database.insert(existingContact);

		system.debug(existingContact.Home_Institution__c);

		List<String> sections = new List<String>{'Spring', 'Fall', 'Summer', 'Calendar Year', 'Academic Year'};
		List<Term__c> setupTerms = apexMockDataUtility.createTerms(sections, Date.today().year() + 1);
		BaseTriggerHandler.bypass('programTermTriggerHandler');
		apexMockDataUtility.createProgramTerms(new List<Program__c>{(Program__c) testData.get('program')}, setupTerms[0], (User) testData.get('academicAffiarsUser'));
		BaseTriggerHandler.clearBypass('programTermTriggerHandler');
		Test.startTest();
		BaseTriggerHandler.bypass('programTriggerHandler');
		Database.insert(new Program__c(Name='Undecided', Host_Institution__c=null, Country__c = testData.get('country').Id));
		BaseTriggerHandler.clearBypass('programTriggerHandler');
		User testUser = apexMockDataUtility.createUser(existingContact.Id);
		System.runAs(testUser){
			studentLoginController controller = new studentLoginController();
			
			System.assertEquals(homeInstitution.Id, controller.viewModel.homeInstitutionId);
			
			controller.viewModel.major = controller.viewModel.majorOptions[0].label;
			List<Term__c> terms = studentLoginController.getTerms(controller.viewModel.countryOptions[0].Id);
			controller.viewModel.programTerms = studentLoginController.searchPrograms(controller.viewModel.countryOptions[0].Id, terms[0].Id, controller.viewModel.homeInstitutionName);
			controller.viewModel.programOfInterest = controller.viewModel.programTerms[0];
			// Create portal user method will always return an error in testing - SFDC testing limitation
			createCommunityUserService result = studentLoginController.register(controller.viewModel.getSerializedViewModel());
			studentLoginViewModel vm = (studentLoginViewModel) result.viewModel;
			result.viewModel = null;
			result = studentLoginController.prepareUserRecord(JSON.serialize(result), JSON.serialize(vm));
			vm = (studentLoginViewModel) result.viewModel;
			result.viewModel = null;
			String userId = studentLoginController.createUserRecord(JSON.serialize(result), JSON.serialize(vm));
			
			String url = studentLoginController.createApplicationAndUpdateContact(testUser.Id, controller.viewModel.getSerializedViewModel());
			System.debug(url);
			System.assertEquals('/SP_Application', url);
		}
		Contact c = [SELECT LastName FROM Contact WHERE Id =: sr.getId()];
		System.assertEquals(existingContact.LastName, c.LastName);
		List<Task> unlisted = [SELECT Id FROM Task WHERE Subject = 'Unlisted School Notification' AND WhoId =: c.Id];
		System.assertEquals(true, unlisted.isEmpty());
		
		Test.stopTest();
	}

	@isTest
	static void testRestrictedPrograms()
	{
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>());
		Home_Institution__c homeInstitution = (Home_Institution__c) testData.get('homeInstitution1');
		Program__c program = (Program__c) testData.get('program');
		Country__c country = (Country__c) testData.get('country');
		Term__c term = (Term__c) testData.get('term');

		System.debug(program);

		Restricted_Program__c rp = new Restricted_Program__c(Name = 'Test Restricted Program', Home_Institution__c = homeInstitution.Id, Program__c = program.Id);
		Database.insert(rp);

		Test.startTest();
		
		List<Id> results = programTermService.getRestrictedProgramTermIds(homeInstitution.Id, country.Id, term.Id);

		rp.Allows_Other_Programs_in_Country__c = true;

		Database.update(rp);

		results = programTermService.getRestrictedProgramTermIds(homeInstitution.Id, country.Id, term.Id);

		Test.stopTest();
	}

	/* @isTest
	static void testLeads()
	{
		Map<String, sObject> testData = apexMockDataUtility.createIfsaDataCollection();
		
		Test.startTest();
		studentLoginController controller = new studentLoginController();

		controller = new studentLoginController();
		controller.viewModel.email = 'utest@utest.test';
		controller.viewModel.firstName = 'Unit';
		controller.viewModel.lastName = 'Test';
		controller.viewModel.phone = '5551234321';
		Home_Institution__c homeInstitution = (Home_Institution__c) testData.get('homeInstitution1');
		controller.viewModel.homeInstitutionName = homeInstitution.Name;
		controller.viewModel.major = controller.viewModel.majorOptions[0].label;
		// Save new lead
		Boolean result = studentLoginController.saveLead(controller.viewModel.getSerializedViewModel());
		// Update existing lead
		controller.viewModel.homeInstitutionName = studentLoginController.searchHomeInstitution(homeInstitution.Name.subString(0, 5)).get(0).Name;
		result = studentLoginController.saveLead(controller.viewModel.getSerializedViewModel());
		controller.viewModel.programOfInterest = (Program_Term__c) TestData.get('programTerm');
		// Try to create portal user from a lead, method will always return an error in testing - SFDC testing limitation
		String url = studentLoginController.register(controller.viewModel.getSerializedViewModel());
		System.debug(url);
		Test.stopTest();
	} */

	/* @isTest
	static void testLeadWithContact()
	{
		Map<String, sObject> testData = apexMockDataUtility.createIfsaDataCollection();
		
		Test.startTest();
		studentLoginController controller = new studentLoginController();

		controller = new studentLoginController();
		controller.viewModel.email = 'utest@utest.test';
		controller.viewModel.firstName = 'Unit';
		controller.viewModel.lastName = 'Test';
		controller.viewModel.phone = '5551234321';
		Home_Institution__c homeInstitution = (Home_Institution__c) testData.get('homeInstitution1');
		controller.viewModel.homeInstitutionName = homeInstitution.Name;
		controller.viewModel.major = controller.viewModel.majorOptions[0].label;
		// Save new lead
		Boolean result = studentLoginController.saveLead(controller.viewModel.getSerializedViewModel());
		// Update existing lead
		controller.viewModel.homeInstitutionName = studentLoginController.searchHomeInstitution(homeInstitution.Name.subString(0, 5)).get(0).Name;
		result = studentLoginController.saveLead(controller.viewModel.getSerializedViewModel());
		Account testAccount = new Account(
			Name = controller.viewModel.firstName + ' ' + controller.viewModel.lastName,
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId()
		);
		Database.insert(testAccount);
		Contact testContact = new Contact(
			Email = controller.viewModel.email, 
			FirstName = controller.viewModel.firstName,
			LastName = controller.viewModel.lastName,
			Phone = controller.viewModel.phone,
			AccountId = testAccount.Id
		);
		Database.insert(testContact);
		controller.viewModel.programOfInterest = (Program_Term__c) TestData.get('programTerm');
		// Try to create portal user from a lead, method will always return an error in testing - SFDC testing limitation
		String url = studentLoginController.register(controller.viewModel.getSerializedViewModel());
		System.debug(url);
		Test.stopTest();
	} */

	@isTest
	static void testLogin()
	{
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>());
		User testUser = (User) testData.get('studentUser');
		Contact c = new Contact(Id = testUser.ContactId, First_Access_Student_Portal__c = DateTime.now());
		database.update(c);

		Test.startTest();

		studentLoginViewModel vm = new studentLoginViewModel();
		vm.email = testUser.Username.replace('.ifsa', '');
		vm.password = 'TestPassword';

		String jsonData = vm.getSerializedViewModel();
		String result = studentLoginController.login(jsonData);

		Test.stopTest();
	}
	/*
	public static testMethod void testChartToSP()
	{
		//User administrator = apexMockDataUtility.createSysAdmin();
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
		
		Database.insert(new Program__c(Name='Undecided', Host_Institution__c=null, Country__c = testData.get('country').Id));
		Contact c = (Contact) testData.get('studentContact2');
		c.LastName = 'Chart User';
		c.Id = null;
		c.Active_Application__c = null;
		database.insert(c);

		User ch_user = (User) testData.get('studentUser');
		ch_user.Id = null;
		ch_user.ContactId = c.Id;
		ch_user.ProfileId = [SELECT Id FROM Profile WHERE Name = 'IFSA CHART Student User'].get(0).Id;
		ch_user.Username = ch_user.Username.replace('ifsa', 'ifch');
		ch_user.CommunityNickname = ch_user.Username.mid(0, 39);

		Test.startTest();
		
		System.runAs(ch_user){
			studentLoginController controller = new studentLoginController();
			PageReference reference = controller.authorize();
		}

		Test.stopTest();
	}
	*/
	//added by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
	@isTest
	static void testobj(){
		Account acc = apexMockDataUtility.createAccount('test name');
		Contact ctct = apexMockDataUtility.createContact('test name', acc.Id);
		User user = apexMockDataUtility.createUser(ctct.Id);
		user.ProfileId = [SELECT Id FROM Profile WHERE Name = 'IFSA CHART Student User'].get(0).Id;
		Database.upsert(user);
		World__c world = new World__c(Name = 'Global');
        database.insert(world);
		Region__c local = new Region__c(Name = 'Local Support', World__c = world.Id);
		Database.insert(local);
		Country__c country = apexMockDataUtility.createLocalCountry(local.Id);
		Host_Institution__c hostInstitution = apexMockDataUtility.createHostInstitution(country.Id);
		Program__c prgm = apexMockDataUtility.createProgram(hostInstitution);
		Test.setCurrentPageReference(new PageReference('SP_Login'));
		System.currentPageReference().getParameters().put('UserId', user.Id);
		System.currentPageReference().getParameters().put('ProgramId', prgm.Id);
		System.runAs(user){
		studentLoginController controller = new studentLoginController();
		// controller.updateChartUser();
		List<Program_Term__c> pt = studentLoginController.getTermsByProgramId(prgm.Id);
		Pagereference pref = controller.isExistingSPUser();
		try{
		String resetPwd = studentLoginController.resetPassword(ctct.Email);
		}
		catch(System.NullPointerException e){
			System.debug('Exception '+e);
		}
	}
	}
    // added by powerfluence based on Clayton req 03/29/2022 starts
    
@isTest
    static void tesforwithoutContact(){
       Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>());
		List<String> sections = new List<String>{'Spring', 'Fall', 'Summer', 'Calendar Year', 'Academic Year'};
		List<Term__c> setupTerms = apexMockDataUtility.createTerms(sections, Date.today().year() + 1);
		apexMockDataUtility.createProgramTerms(new List<Program__c>{(Program__c) testData.get('program')}, setupTerms[0], (User) testData.get('academicAffiarsUser'));
		Test.startTest();
		Database.insert(new Program__c(Name='Undecided', Host_Institution__c=null, Country__c = testData.get('country').Id));
		 Account acc = apexMockDataUtility.createAccount('test name');
       
        List<Lead> leadNew =[SELECT Id,FirstName,LastName,Email FROM Lead LIMIT 1];
        system.debug('leadNew'+leadNew);
        Lead le = new Lead();
        le.FirstName='Unit';
        le.LastName= 'Test';
       	le.Email = 'utest@utest.test';
        //le.Name='Unit';
       	le.Status='Open';
        le.CurrencyIsoCode='USD';
        le.Company='TestCompany';
        leadNew.add(le);
        Database.upsert(leadNew);
        system.debug('leadNew'+leadNew);
		Contact ctct = apexMockDataUtility.createContact('test name', acc.Id);
        ctct.FirstName='Unit';
        ctct.LastName= 'Test';
        ctct.Email = 'utest@utest.test';
        Database.update(ctct);
		studentLoginController controller = new studentLoginController();
		PageReference reference = controller.authorize();

		controller.viewModel.email = 'utest@utest.test';
		controller.viewModel.password = 'theWrongPassword';
		User u11=apexMockDataUtility.createUser(ctct.Id);
		User testUser = (User) testData.get('studentUser');
		User guestUser = [SELECT Id FROM User WHERE Name = 'Student Portal Site Guest User'].get(0);		
		System.runAs(guestUser){
			controller = new studentLoginController();
			controller.viewModel.email = 'utest@utest.test';
			controller.viewModel.password = 'thePassword1';
			controller.viewModel.firstName = 'Unit';
			controller.viewModel.lastName = 'Test';
			Home_Institution__c homeInstitution = (Home_Institution__c) testData.get('homeInstitution1');
			controller.viewModel.homeInstitutionName = studentLoginController.searchHomeInstitution(homeInstitution.Name.subString(0, 5)).get(0).Name;
			controller.viewModel.major = controller.viewModel.majorOptions[0].label    ;
			List<Term__c> terms = studentLoginController.getTerms(controller.viewModel.countryOptions[0].Id);
			controller.viewModel.programTerms = studentLoginController.searchPrograms(controller.viewModel.countryOptions[0].Id, terms[0].Id, controller.viewModel.homeInstitutionName);
			controller.viewModel.programOfInterest = controller.viewModel.programTerms[0];
			List<Program_Term__c> programOptions = studentLoginController.getProgramOptions(controller.viewModel.programOfInterest.Id);
			// Create portal user method will always return an error in testing - SFDC testing limitation
			createCommunityUserService result = studentLoginController.register(controller.viewModel.getSerializedViewModel());
			studentLoginViewModel vm = (studentLoginViewModel) result.viewModel;
			result.viewModel = null;
			result = studentLoginController.prepareUserRecord(JSON.serialize(result), JSON.serialize(vm));
			vm = (studentLoginViewModel) result.viewModel;
			result.viewModel = null;
			String userId = studentLoginController.createUserRecord(JSON.serialize(result), JSON.serialize(vm));
			
			String url = studentLoginController.createApplicationAndUpdateContact(testUser.Id, controller.viewModel.getSerializedViewModel());
			System.debug(url);
			System.assertEquals('', url);
		}

		Test.stopTest();
		Contact testContact = [SELECT Id, Active_Application__c FROM Contact WHERE Id =: testUser.ContactId];
		Application__c testApp = [SELECT Id FROM Application__c WHERE Id =: testContact.Active_Application__c];
		Apex_String_Constant__mdt taskName = [SELECT Value__c FROM Apex_String_Constant__mdt WHERE DeveloperName = 'Welcome_Task'].get(0);
        //modified by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
		// System.assertEquals(true, [SELECT Count() FROM Task WHERE Subject =: taskName.Value__c AND WhoId =: testContact.Id AND WhatId =: testApp.Id] > 0);
		System.assertEquals(false, [SELECT Count() FROM Task WHERE Subject =: taskName.Value__c AND WhoId =: testContact.Id AND WhatId =: testApp.Id] > 0);
        //modified by PowerFluence req_dt:03/29/2022 ref email from Clayton ends

		}

		@isTest
    static void tesforwithoutContactxerox(){
       Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>());
		List<String> sections = new List<String>{'Spring', 'Fall', 'Summer', 'Calendar Year', 'Academic Year'};
		List<Term__c> setupTerms = apexMockDataUtility.createTerms(sections, Date.today().year() + 1);
		apexMockDataUtility.createProgramTerms(new List<Program__c>{(Program__c) testData.get('program')}, setupTerms[0], (User) testData.get('academicAffiarsUser'));
		Test.startTest();
		Database.insert(new Program__c(Name='Undecided', Host_Institution__c=null, Country__c = testData.get('country').Id));
		 Account acc = apexMockDataUtility.createAccount('test name');
       
        
		Contact ctct = apexMockDataUtility.createContact('test name', acc.Id);
        ctct.FirstName='Unit';
        ctct.LastName= 'Test';
        ctct.Email = 'utest@utest.test';
        Database.update(ctct);
		studentLoginController controller = new studentLoginController();
		PageReference reference = controller.authorize();

		controller.viewModel.email = 'utest@utest.test';
		controller.viewModel.password = 'theWrongPassword';
		User testUser = (User) testData.get('studentUser');
		User guestUser = [SELECT Id FROM User WHERE Name = 'Student Portal Site Guest User'].get(0);		
		System.runAs(guestUser){
			controller = new studentLoginController();
			controller.viewModel.email = 'utest@utest.test';
			controller.viewModel.password = 'thePassword1';
			controller.viewModel.firstName = 'Unit';
			controller.viewModel.lastName = 'Test';
			Home_Institution__c homeInstitution = (Home_Institution__c) testData.get('homeInstitution1');
			controller.viewModel.homeInstitutionName = studentLoginController.searchHomeInstitution(homeInstitution.Name.subString(0, 5)).get(0).Name;
			controller.viewModel.major = controller.viewModel.majorOptions[0].label    ;
			List<Term__c> terms = studentLoginController.getTerms(controller.viewModel.countryOptions[0].Id);
			controller.viewModel.programTerms = studentLoginController.searchPrograms(controller.viewModel.countryOptions[0].Id, terms[0].Id, controller.viewModel.homeInstitutionName);
			controller.viewModel.programOfInterest = controller.viewModel.programTerms[0];
			List<Program_Term__c> programOptions = studentLoginController.getProgramOptions(controller.viewModel.programOfInterest.Id);
			// Create portal user method will always return an error in testing - SFDC testing limitation
			createCommunityUserService result = studentLoginController.register(controller.viewModel.getSerializedViewModel());
			studentLoginViewModel vm = (studentLoginViewModel) result.viewModel;
			result.viewModel = null;
			result = studentLoginController.prepareUserRecord(JSON.serialize(result), JSON.serialize(vm));
			vm = (studentLoginViewModel) result.viewModel;
			result.viewModel = null;
			String userId = studentLoginController.createUserRecord(JSON.serialize(result), JSON.serialize(vm));
			
			String url = studentLoginController.createApplicationAndUpdateContact(testUser.Id, controller.viewModel.getSerializedViewModel());
			System.debug(url);
			System.assertEquals('', url);
		}

		Test.stopTest();
		Contact testContact = [SELECT Id, Active_Application__c FROM Contact WHERE Id =: testUser.ContactId];
		Application__c testApp = [SELECT Id FROM Application__c WHERE Id =: testContact.Active_Application__c];
		Apex_String_Constant__mdt taskName = [SELECT Value__c FROM Apex_String_Constant__mdt WHERE DeveloperName = 'Welcome_Task'].get(0);
        //modified by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
		// System.assertEquals(true, [SELECT Count() FROM Task WHERE Subject =: taskName.Value__c AND WhoId =: testContact.Id AND WhatId =: testApp.Id] > 0);
		System.assertEquals(false, [SELECT Count() FROM Task WHERE Subject =: taskName.Value__c AND WhoId =: testContact.Id AND WhatId =: testApp.Id] > 0);
        //modified by PowerFluence req_dt:03/29/2022 ref email from Clayton ends

		}

		    
@isTest
static void tesforwithoutContactLead(){
   Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>());
	 List<String> sections = new List<String>{'Spring', 'Fall', 'Summer', 'Calendar Year', 'Academic Year'};
	 List<Term__c> setupTerms = apexMockDataUtility.createTerms(sections, Date.today().year() + 1);
	 apexMockDataUtility.createProgramTerms(new List<Program__c>{(Program__c) testData.get('program')}, setupTerms[0], (User) testData.get('academicAffiarsUser'));
	 Test.startTest();
	 Database.insert(new Program__c(Name='Undecided', Host_Institution__c=null, Country__c = testData.get('country').Id));
	  Account acc = apexMockDataUtility.createAccount('test name');
   
    List<Lead> leadNew =[SELECT Id,FirstName,LastName,Email FROM Lead LIMIT 1];
    system.debug('leadNew'+leadNew);
    Lead le = new Lead();
    le.FirstName='Unit';
    le.LastName= 'Test';
	le.Email = 'utest@utest.test';
	le.Status='Open';
    le.CurrencyIsoCode='USD';
    le.Company='TestCompany';
    leadNew.add(le);
    Database.upsert(leadNew);
    system.debug('leadNew'+leadNew);
	
	 studentLoginController controller = new studentLoginController();
	 PageReference reference = controller.authorize();

	 controller.viewModel.email = 'utest@utest.test';
	 controller.viewModel.password = 'theWrongPassword';
	 User testUser = (User) testData.get('studentUser');
	 User guestUser = [SELECT Id FROM User WHERE Name = 'Student Portal Site Guest User'].get(0);		
	 System.runAs(guestUser){
		 controller = new studentLoginController();
		 controller.viewModel.email = 'utest@utest.test';
		 controller.viewModel.password = 'thePassword1';
		 controller.viewModel.firstName = 'Unit';
		 controller.viewModel.lastName = 'Test';
		 Home_Institution__c homeInstitution = (Home_Institution__c) testData.get('homeInstitution1');
		 controller.viewModel.homeInstitutionName = studentLoginController.searchHomeInstitution(homeInstitution.Name.subString(0, 5)).get(0).Name;
		 controller.viewModel.major = controller.viewModel.majorOptions[0].label    ;
		 List<Term__c> terms = studentLoginController.getTerms(controller.viewModel.countryOptions[0].Id);
		 controller.viewModel.programTerms = studentLoginController.searchPrograms(controller.viewModel.countryOptions[0].Id, terms[0].Id, controller.viewModel.homeInstitutionName);
		 controller.viewModel.programOfInterest = controller.viewModel.programTerms[0];
		 List<Program_Term__c> programOptions = studentLoginController.getProgramOptions(controller.viewModel.programOfInterest.Id);
		 // Create portal user method will always return an error in testing - SFDC testing limitation
		 createCommunityUserService result = studentLoginController.register(controller.viewModel.getSerializedViewModel());
		 studentLoginViewModel vm = (studentLoginViewModel) result.viewModel;
		 result.viewModel = null;
		 result = studentLoginController.prepareUserRecord(JSON.serialize(result), JSON.serialize(vm));
		 vm = (studentLoginViewModel) result.viewModel;
		 result.viewModel = null;
		 String userId = studentLoginController.createUserRecord(JSON.serialize(result), JSON.serialize(vm));
		 
		 String url = studentLoginController.createApplicationAndUpdateContact(testUser.Id, controller.viewModel.getSerializedViewModel());
		 System.debug(url);
		 System.assertEquals('', url);
	
	 }

	 Test.stopTest();
	 Contact testContact = [SELECT Id, Active_Application__c FROM Contact WHERE Id =: testUser.ContactId];
	 Application__c testApp = [SELECT Id FROM Application__c WHERE Id =: testContact.Active_Application__c];
	 Apex_String_Constant__mdt taskName = [SELECT Value__c FROM Apex_String_Constant__mdt WHERE DeveloperName = 'Welcome_Task'].get(0);

	 // System.assertEquals(true, [SELECT Count() FROM Task WHERE Subject =: taskName.Value__c AND WhoId =: testContact.Id AND WhatId =: testApp.Id] > 0);
	 System.assertEquals(false, [SELECT Count() FROM Task WHERE Subject =: taskName.Value__c AND WhoId =: testContact.Id AND WhatId =: testApp.Id] > 0);
    

	 }
    //babish
	//added by PowerFluence req_dt:03/29/2022 ref email from Clayton ends
}