/**
 * Test class for <<chartLoginController>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
@isTest
private class chartLoginControllerTest 
{
	static String expected = 'An error occurred while creating your account - please refresh and try again. If you continue to have issues, please let us know by sending an email to CHART@ifsa-butler.org.';
	/** 
	 * Test Setup, creates test data 
	 */
	@TestSetup
    static void makeData(){
		Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>());
		Id homeInstAccountId = [SELECT Id FROM Account WHERE RecordType.Name = 'Home Institution'].get(0).Id;
		Email_Domain__c ed = new Email_Domain__c(Account__c = homeInstAccountId, Domain_Name__c = 'utest.test');
		database.insert(ed);
    }
	/**
	 * Test Incorrect Password
	 * NOTE: Cannot test for correct password, because the method always fails in test methods
	 */
	static testMethod void testLogin()
	{
		Test.startTest();

		chartLoginController controller = new chartLoginController();
		controller.viewModel = new chartLoginViewModel();
		controller.viewModel.email = 'utest@utest.test';
		controller.viewModel.password = 'WrongPassword1';
		
		String url = chartLoginController.login(controller.viewModel.getSerializedViewModel());
		System.debug(url);
		System.assert(url.contains('The username and password you entered did not match our records.'), url);

		PageReference pr = new PageReference('https://wwww.google.com');
		chartLoginController.getURLFromPageReference(pr);

		//modified by powerfluence based on Clayton's mail req 03/29/2022 starts
		Id iedi= chartLoginController.getHomeInstituitionAccountFromEmailAddress(controller.viewModel.email);
		Id ied= chartLoginController.getHomeInstituitionAccountFromEmailAddress('test123');
		

		Test.stopTest();
	}

	static testMethod void testLogin1()
	{
		Test.startTest();

		chartLoginController controller = new chartLoginController();
		controller.viewModel = new chartLoginViewModel();
		controller.viewModel.email = 'utest@utest.test';
		controller.viewModel.password = 'WrongPassword1';
		controller.viewModel.projectId = 'te';
		//insert(controller);
		String url = chartLoginController.login(controller.viewModel.getSerializedViewModel());
		System.debug(url);
		System.assert(url.contains('The username and password you entered did not match our records.'), url);

		PageReference pr = new PageReference('https://wwww.google.com');
		chartLoginController.getURLFromPageReference(pr);
		Test.stopTest();
	}
	//modified by powerfluence based on Clayton's mail req 03/29/2022 ends
	/**
	 * Test Registration - Register with unknown email domain
	 */
	static testMethod void testRegistrationUnknownDomain()
	{
		Test.startTest();

		chartLoginController controller = new chartLoginController();
		controller.viewModel = new chartLoginViewModel();
		controller.viewModel.email = 'utest@badtest.test';
		controller.viewModel.password = 'thePassword1';
		controller.viewModel.firstName = 'Unit';
		controller.viewModel.lastName = 'Test';
		controller.viewModel.userType = 'Student';


		string error;
		try
		{
			createCommunityUserService result = chartLoginController.register(controller.viewModel.getSerializedViewModel());
		}
		catch(createCommunityUserService.createCommunityUserException e)
		{
			error = e.getMessage();
		}
		System.assertNotEquals(null, error);
		System.assertEquals('The school email you used isn\'t a verified \'.edu\' email address in our system. If you have a valid school email and it is failing, please let us know by sending an email to CHART@ifsa-butler.org.', error);

		Test.stopTest();
	}

	/**
	 * Test Registration - Register with known email domain
	 */
	static testMethod void testRegistrationKnownDomain()
	{
		Test.startTest();

		chartLoginController controller = new chartLoginController();
		controller.viewModel = new chartLoginViewModel();
		controller.viewModel.firstName = 'Unit';
		controller.viewModel.lastName = 'O\'Test';
		controller.viewModel.email = 'utest@utest.test';
		controller.viewModel.userType = 'Student';

		createCommunityUserService result = chartLoginController.register(controller.viewModel.getSerializedViewModel());
		chartLoginViewModel vm = (chartLoginViewModel) result.viewModel;
		result.viewModel = null;
		result = chartLoginController.prepareUserRecord(JSON.serialize(result), JSON.serialize(vm));
		vm = (chartLoginViewModel) result.viewModel;
		result.viewModel = null;
		String userId = chartLoginController.createUserRecord(JSON.serialize(result), JSON.serialize(vm));
			
		//userId = getTestUser([SELECT Id FROM Contact WHERE AccountId =: result.userAccount.Id].get(0).Id).Id;
		String url = chartLoginController.finalizeNewUser(userId, controller.viewModel.getSerializedViewModel());
		System.debug(url);
		System.assertEquals('', url);

		Test.stopTest();
		Contact c = [SELECT Id, CHART_Welcome_Email_Sent__c FROM Contact WHERE Contact_Source__c = 'CHART'];
		System.assertEquals(true, c.CHART_Welcome_Email_Sent__c);
	}

	/**
	 * Test Registration - Register with an existiting Contact and Lead record
	 */
	static testMethod void testRegistrationExistingContactAndLead()
	{
		Contact testContact = [SELECT Id, Email, FirstName, LastName, AccountId FROM Contact LIMIT 1];
		testContact.Email = 'utest2@utest.test';
		testContact.Id = null;
		Contact testContact2 = testContact.clone();
		testContact2.FirstName = 'Unit Lead';
		testContact2.LastName = 'Test';
	    testContact2.Email = 'utest3@utest.test';
		testContact2.Id = null;
//modified by powerfluence based on Clayton's mail req 03/29/2022 stars
		// List<Contact> newContacts = new List<Contact>{testContact, testContact2};
		// database.insert(newContacts);
//modified by powerfluence based on Clayton's mail req 03/29/2022 ends

		Lead testLead = new Lead(
			FirstName = testContact.FirstName,
			LastName = testContact.LastName,
			Email = testContact.Email,
			Company = testContact.FirstName + ' ' + testContact.LastName
		);
		database.insert(testLead);
//modified by powerfluence based on Clayton's mail req 03/29/2022 stars

		List<Contact> newContacts = new List<Contact>{testContact, testContact2};
		database.insert(newContacts);

//modified by powerfluence based on Clayton's mail req 03/29/2022 ends
		Test.startTest();

		chartLoginController controller = new chartLoginController();
		controller.viewModel = new chartLoginViewModel();
		controller.viewModel.email = testContact.Email;
		controller.viewModel.password = 'thePassword1';
		controller.viewModel.firstName = testContact.FirstName;
		controller.viewModel.lastName = testContact.LastName;
		controller.viewModel.userType = 'Student';

		createCommunityUserService result = chartLoginController.register(controller.viewModel.getSerializedViewModel());
		chartLoginViewModel vm = (chartLoginViewModel) result.viewModel;
		result.viewModel = null;
		result = chartLoginController.prepareUserRecord(JSON.serialize(result), JSON.serialize(vm));
		vm = (chartLoginViewModel) result.viewModel;
		result.viewModel = null;
		String userId = chartLoginController.createUserRecord(JSON.serialize(result), JSON.serialize(vm));
		String url = chartLoginController.finalizeNewUser(userId, controller.viewModel.getSerializedViewModel());
		System.debug(url);
		System.assertEquals('', url);

		Test.stopTest();
	}

	/**
	 * Test Registration - Register with an existing Lead record
	 */
	static testMethod void testRegistrationExistingLead()
	{
		Test.startTest();

		chartLoginController controller = new chartLoginController();

		Lead existingLead = new Lead(FirstName = 'Test', LastName = 'Lead', Email = 'testlead@utest.test', Company = 'Test Lead');
		database.insert(existingLead);

		controller.viewModel = new chartLoginViewModel();
		controller.viewModel.email = existingLead.Email;
		controller.viewModel.password = 'thePassword1';
		controller.viewModel.firstName = existingLead.FirstName;
		controller.viewModel.lastName = existingLead.LastName;
		controller.viewModel.userType = 'Student';

		createCommunityUserService result = chartLoginController.register(controller.viewModel.getSerializedViewModel());
		chartLoginViewModel vm = (chartLoginViewModel) result.viewModel;
		result.viewModel = null;
		result = chartLoginController.prepareUserRecord(JSON.serialize(result), JSON.serialize(vm));
		vm = (chartLoginViewModel) result.viewModel;
		result.viewModel = null;
		String userId = chartLoginController.createUserRecord(JSON.serialize(result), JSON.serialize(vm));
		userId = getTestUser([SELECT Id FROM Contact WHERE Account.Name =: existingLead.Company].get(0).Id).Id;
		String url = chartLoginController.finalizeNewUser(userId, controller.viewModel.getSerializedViewModel());
		System.debug(url);
		System.assertEquals('', url);
		Test.stopTest();
	}

	static User getTestUser(Id contactId)
	{
		Integer rand = Math.round(Math.random()*999);
		String orgId = userInfo.getOrganizationId();
		String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
		Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
    	String uniqueName = orgId + dateString + randomInt;
	    
	    User testUser = new User(
			FirstName = 'Unit',
			LastName = 'Test',
			email = 'ifsa' + uniqueName + '@test' + orgId + '.org.test.ifsa',
			Username = 'ifsa' + uniqueName + '@test' + orgId + '.org.test.ifsa',
			Alias = uniqueName.substring(18, 23),
			CommunityNickname = uniqueName,
			ContactId = contactId,
			UserRole = [SELECT Id FROM Userrole WHERE Name =: 'President'].get(0),
			ProfileId = [SELECT Id FROM Profile WHERE Name =: 'IFSA CHART Student User'].get(0).Id,
			TimeZoneSidKey = 'GMT',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'ISO-8859-1',
			LanguageLocaleKey = 'en_US',
			UserPermissionsMobileUser = false,
			Email_Confirmed_For_CHART__c = true
		);

		Database.insert(testUser);

		return testUser;
	}
}