/**
 * @description Used to create mock data for testing - DEPRECIATED USED "ApexMockDataUtility" instead
 * @author Cameron Ames
 */
// ApexDoc updated 2/19/2021 Brock Barlow
@isTest
public without sharing class mockDataUtility
{
	/**
	 * Creates a student account, contact, user and application
	 * @return Id created user Id
	 */
	public static Id createStudentUserWithApp()
	{
		contactTriggerHandler.bypassTrigger = true;
		applicationTriggerHandler.bypassTrigger = true;

		Account testAccount = new Account();
	    testAccount.Name = 'Unit Test';
	    Database.SaveResult result = Database.insert(testAccount);

	    if(!result.isSuccess())
		{
			System.debug(LoggingLevel.ERROR, result.getErrors());
			return null;
		}

	    Contact testContact = new Contact();
	    testContact.FirstName = 'Unit';
	    testContact.LastName = 'Test';
		testContact.RecordTypeId = ([select Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Student']).get(0).Id;
	    testContact.AccountId = testAccount.Id;
	    result = Database.insert(testContact);

	    if(!result.isSuccess())
		{
			System.debug(LoggingLevel.ERROR, result.getErrors());
			return null;
		}

		Integer rand = Math.round(Math.random()*100);

	    User testUser = new User();
	    testUser.FirstName = 'Unit';
	    testUser.LastName = 'Test';
	    testUser.Alias = rand + 'utest';
	    testUser.CommunityNickname = rand + 'utest';
	    testUser.Email = rand + 'utest@utest.test';
	    testUser.Username = rand + 'utest@utest.test.ifsa';
	    testUser.UserRole = [SELECT Id FROM Userrole WHERE Name =: 'President'];
	    testUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: 'IFSA Student User'].Id;
	    testUser.contactId = testContact.Id;
	    testUser.TimeZoneSidKey = 'GMT';
	    testUser.LocaleSidKey = 'en_US';
	    testUser.EmailEncodingKey = 'ISO-8859-1';
	    testUser.LanguageLocaleKey = 'en_US';
	    testUser.UserPermissionsMobileUser = false;
	    result = Database.insert(testUser);

	    if(!result.isSuccess())
		{
			System.debug(LoggingLevel.ERROR, result.getErrors());
			return null;
		}

		system.setPassword(testUser.id, 'thePassword1');

		Application__c application = new Application__c();
		application.Name = 'Unit Test Application';
		application.Applicant__c = testContact.Id;
	    result = Database.insert(application);

	    if(!result.isSuccess())
		{
			System.debug(LoggingLevel.ERROR, result.getErrors());
			return null;
		}
		
		testContact.Active_Application__c = application.Id;

	    result = Database.update(testContact);

	    if(!result.isSuccess())
		{
			System.debug(LoggingLevel.ERROR, result.getErrors());
			return null;
		}

		contactTriggerHandler.bypassTrigger = false;
		applicationTriggerHandler.bypassTrigger = false;
		return testUser.Id;		
	}
	/**
	 * Creates an application item for the specified application Id
	 * @return Id created application item Id
	 */
	public static Id createAppItem(Id appId)
	{
		Application_Item__c testAppItem = new Application_Item__c();
		testAppItem.Name = 'Test Application Item';
		testAppItem.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Application_Item__c'].get(0).Id;
		testAppItem.Directions__c = 'this is only a test.';
		testAppItem.Phase__c = 'Pre-Admit';
		testAppItem.Status__c = 'Incomplete';
		testAppItem.Application__c = appId;
		Database.SaveResult result = Database.insert(testAppItem);

	    if(!result.isSuccess())
		{
			System.debug(LoggingLevel.ERROR, result.getErrors());
			return null;
		}

		return testAppItem.Id;
	}

	/*public static Id createPostAdmitAppItem(Id appId)
	{
		Application_Item__c testAppItem = new Application_Item__c();
		testAppItem.Name = 'Test Application Item';
		testAppItem.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Application_Item__c'].get(0).Id;
		testAppItem.Directions__c = 'this is only a test.';
		testAppItem.Phase__c = 'Pre-Acceptance';
		testAppItem.Status__c = 'Incomplete';
		testAppItem.Application__c = appId;
		Database.SaveResult result = Database.insert(testAppItem);

	    if(!result.isSuccess())
		{
			System.debug(LoggingLevel.ERROR, result.getErrors());
			return null;
		}

		return testAppItem.Id;
	}*/
	/**
	 * Creates a program term record
	 * @return Id created program term Id
	 */
	public static Id createProgramTerm()
	{
		Program_Term__c testProgramTerm = new Program_Term__c();
		testProgramTerm.Name = 'asdf';
		testProgramTerm.Program__c = mockDataUtility.createProgram();
		testProgramTerm.Term__c = mockDataUtility.createTerm();
		Database.SaveResult result = Database.insert(testProgramTerm);

	    if(!result.isSuccess())
		{
			System.debug(LoggingLevel.ERROR, result.getErrors());
			return null;
		}

		return testProgramTerm.Id;
	}
	/**
	 * Creates a program record
	 * @return Id created program Id
	 */
	public static Id createProgram()
	{
		return mockDataUtility.createProgram('Test Program');
	}
	/**
	 * Creates a program record, with the specified name
	 * @param name The name of the program to create
	 * @return Id created program Id
	 */
	public static Id createProgram(String name)
	{
		Program__c testProgram = new Program__c();
		testProgram.Name = name;
		testProgram.Category__c = '4: Custom';
		Database.SaveResult result = Database.insert(testProgram);

	    if(!result.isSuccess())
		{
			System.debug(LoggingLevel.ERROR, result.getErrors());
			return null;
		}

		return testProgram.Id;
	}
	/**
	 * Creates a term record
	 * @return Id created term Id
	 */
	public static Id createTerm()
	{
		Term__c testTerm = new Term__c();
		testTerm.Name = 'asdf';
		testTerm.Section__c = 'Spring';
		testTerm.Year__c = 2017;
		testTerm.Start_Date__c = Date.today().addYears(1);
		Database.SaveResult result = Database.insert(testTerm);

	    if(!result.isSuccess())
		{
			System.debug(LoggingLevel.ERROR, result.getErrors());
			return null;
		}

		return testTerm.Id;
	}
	/**
	 * Creates an application requirement record
	 * @param programTermId The Id of the program term to relate the new record to
	 * @return Id created application requirement Id
	 */
	public static Id createAppRequirement(Id programTermId)
	{
		Application_Requirement__c testRequirement = new Application_Requirement__c();
		testRequirement.Name = 'test';
		testRequirement.Program_Term__c = programTermId;
		testRequirement.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Application_Requirement__c'].get(1).Id;
		testRequirement.Phase__c = 'Pre-Admit';
		Database.SaveResult result = Database.insert(testRequirement);

	    if(!result.isSuccess())
		{
			System.debug(LoggingLevel.ERROR, result.getErrors());
			return null;
		}

		return testRequirement.Id;
	}

	/*public static Id createAppLineItem(Id appId)
	{
		Application_Line_Item__c testLineItem = new Application_Line_Item__c();
		testLineItem.Application__c = appId;
		testLineItem.Name = 'test line item';
		testLineItem.Bill_Institution__c = false;
		testLineItem.Charge__c = 1000;
		testLineItem.Notes__c = 'asdf';
		testLineItem.Type__c = 'Charge Account';
		Database.SaveResult result = Database.insert(testLineItem);

	    if(!result.isSuccess())
		{
			System.debug(LoggingLevel.ERROR, result.getErrors());
			return null;
		}

		return testLineItem.Id;
	}*/

	/*public static Id createSystemAdmin()
	{
	    User testUser = new User();
	    testUser.FirstName = 'Admin';
	    testUser.LastName = 'Test';
	    testUser.Alias = 'atest';
	    testUser.CommunityNickname = 'atest';
	    testUser.Email = 'atest@atest.test';
	    testUser.Username = 'atest@atest.test.ifsa';
	    testUser.UserRole = [SELECT Id FROM Userrole WHERE Name =: 'President'];
	    testUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: 'System Administrator'].Id;
	    testUser.TimeZoneSidKey = 'GMT';
	    testUser.LocaleSidKey = 'en_US';
	    testUser.EmailEncodingKey = 'ISO-8859-1';
	    testUser.LanguageLocaleKey = 'en_US';
	    testUser.UserPermissionsMobileUser = false;
	    Database.SaveResult result = Database.insert(testUser);

	    if(!result.isSuccess())
		{
			System.debug(result.getErrors());
			return null;
		}

		system.setPassword(testUser.id, 'thePassword1');

		return testUser.Id;
	}*/
	/**
	 * Creates a Test Advisor User
	 * @return Id of the User record
	 */
	public static Id createTestAdvisor()
	{
		//Create World
        World__c world = new World__c();
        world.Name = 'Global';
        database.insert(world);
        //Create Regions
        Region__c international = new Region__c();
        international.Name = 'International Support';
        international.World__c = world.Id;
        Region__c local = new Region__c();
        local.Name = 'Local Support';
        local.World__c = world.Id;
        database.insert(new List<Region__c>{international, local});

        //Creating test Country
		Country__c testCountry = new Country__c();
		testCountry.Name = 'UnitTestLandia';
        testCountry.Region__c = international.Id;
        testCountry.Active__c = true;
        Database.Insert(testCountry);
        System.assertNotEquals(testCountry.Id, null, 'Something went wrong while inserting the test Country.');

		//Creating test Home Institution
		Home_Institution__c testHomeInstitution = new Home_Institution__c();
		testHomeInstitution.Name = 'Unit Test homeUniversity';
		testHomeInstitution.Country__c = testCountry.Id;
		Database.insert(testHomeInstitution);
		System.assertNotEquals(testHomeInstitution.Id, null, 'Something went wrong while inserting the test Home Institutuion.');

        Account testAccount = new Account();
        testAccount.Name = 'Unit Test';
        testAccount.Institution__c = testHomeInstitution.Id;
        Database.insert(testAccount);

        System.assertNotEquals(testAccount.Id, null, 'Something went wrong while inserting the test Account.');

        Contact testContact = new Contact();
        testContact.FirstName = 'Unit';
        testContact.LastName = 'Test';
        testContact.AccountId = testAccount.Id;
		testContact.Email = 'test@test.net';
        Database.insert(testContact);

        System.assertNotEquals(testContact.Id, null, 'Something went wrong while inserting the test Contact');

        User testUser = new User();
        testUser.FirstName = 'Unit';
        testUser.LastName = 'Test';
        testUser.Alias = 'utest';
        testUser.CommunityNickname = 'utest';
        testUser.Email = 'utest@utest.test';
        testUser.Username = 'utest@utest.test';
        testUser.UserRole = [SELECT Id FROM Userrole WHERE Name =: 'President'];
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: 'IFSA Advisor User'].Id;
        testUser.contactId = testContact.Id;
        testUser.TimeZoneSidKey = 'GMT';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.UserPermissionsMobileUser = false;
        Database.insert(testUser);

        System.assertNotEquals(testUser.Id, null, 'Something went wrong while inserting the test User.');

		return testUser.Id;
	}

	/*public static Id createHomeInstitution()
	{
		Home_Institution__c homeInstitution = new Home_Institution__c();
		homeInstitution.Name = 'Test University';
	    Database.SaveResult result = Database.insert(homeInstitution);

	    if(!result.isSuccess())
		{
			System.debug(result.getErrors());
			return null;
		}

		return homeInstitution.Id;
	}*/
    
    /*public static Id createCountry()
    {
        Country__c country = new Country__c();
        country.Name = 'Test Country';
        
        Database.SaveResult result = Database.insert(country);
        if(!result.isSuccess())
        {
            System.debug(result.getErrors());
            return null;            
        }
        return country.id;
    }*/
    
    /*public static Id createHostInstitution()
    {
        Host_Institution__c hostInstitution = new Host_Institution__c();
        hostInstitution.Name = 'Test Host University';        
        hostInstitution.Country__c = createCountry();
        Database.SaveResult result = Database.insert(hostInstitution);
        if(!result.isSuccess())
        {
            System.debug(result.getErrors());
            return null;            
        }
        return hostInstitution.id;
    }*/

    /*public static Program_Institution__c createProgramInstitution()
    {
        Program_Institution__c programInstitution = new Program_Institution__c();
        programInstitution.Program__c = createProgram();
        programInstitution.Host_Institution__c = createHostInstitution();
        Database.SaveResult result = Database.insert(programInstitution);
        if(!result.isSuccess())
        {
            System.debug(result.getErrors());
            return null;            
        }
        return programInstitution;
    }*/
}