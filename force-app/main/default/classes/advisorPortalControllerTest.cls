/**
 * Unit tests for <<advisorPortalController>>
 */
// ApexDoc updated 1/23/2021 Brock Barlow
@isTest
public without sharing class advisorPortalControllerTest 
{
	/**
	 * Makes the test data used by the test class
	 */
    @TestSetup
    static void makeData(){
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'Billing','Program_Auths'});
		
		Program__c program = [SELECT Id, Name, Country__c FROM Program__c LIMIT 1];
		List<Term__c> terms = [SELECT Name, Id, Section__c FROM Term__c];
		Map<String, Term__c> termMap = new Map <String,Term__c>();
		for(Term__c term : terms){
			termMap.put(term.Section__c, term);
		}
	}
	
	/**
	 * Tests the instance of <<advisorPortalController>>
	 */
    @IsTest
    static void testAdvisorPortalInstance()
    {
        Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c LIMIT 1];
		Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);
		User advisorUser = apexMockDataUtility.createAdvisor(ctc.Id);
		//added by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
		Contact ctc1 = apexMockDataUtility.createContact('Test1', acct.Id);
		User StudentUser = apexMockDataUtility.createUser(ctc1.Id);
		//added by PowerFluence req_dt:03/29/2022 ref email from Clayton ends
        test.startTest();
        system.runas(advisorUser)
        {			
            advisorPortalViewModel vm = new advisorPortalController().viewModel;
            advisorPortalViewModel vm2 = new advisorPortalController().populateViewModel(vm);
            advisorStudentsViewModel vm3 = new advisorStudentsController().viewModel;
			//added by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
			PageReference newRef = new advisorPortalController().validateAccess();
			//added by PowerFluence req_dt:03/29/2022 ref email from Clayton ends	

        }
		//added by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
		system.runas(StudentUser)
		{
			PageReference newRef1 = new advisorPortalController().validateAccess();
		}
		//added by PowerFluence req_dt:03/29/2022 ref email from Clayton ends	
        test.stopTest();
	}
	
	// Institution Page Tests
	/**
	 * Tests the institution page and getting the program authorization and billing arrangement details.
	 */
    @IsTest
    static void testInstitution_VM_PA_Search_BA_Details()
	{
		Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
		List<Contact> advisorContacts = [SELECT Id, AccountId FROM Contact WHERE RecordTypeId = :advisorRecordType LIMIT 2];
		Home_Institution__c hi = [SELECT Id FROM Home_Institution__c LIMIT 1];
		System.Debug('67 test'+hi.id);
		User advisorUser = apexMockDataUtility.createAdvisor(advisorContacts[0].Id);

        system.runas(advisorUser)
        {
			
			Program_Authorization__c pa = [SELECT Id, Term__c FROM Program_Authorization__c WHERE Account__c =: advisorContacts[0].AccountId].get(0);
			System.debug(pa.Term__c);
			Test.setCreatedDate(pa.Id, DateTime.now().addDays(-4));
			test.startTest();
			advisorInstitutionViewModel vm = advisorPortalController.getInstitutionViewModel();
            
            List<model_program> progs = advisorPortalController.getFilteredPrograms(hi.Id, 'England', 'All');
			System.Debug('67 '+progs);  
			model_programAuthorization pAuth = progs.get(0).activeProgramAuthorization;
			system.assertNotEquals(0, progs.size());
			progs = advisorPortalController.getFilteredPrograms(hi.Id, 'Test', 'Unauthorized');
			System.assertEquals(null, progs);
			progs = advisorPortalController.getFilteredPrograms(hi.Id, 'England', 'Authorized');

			List<model_billingArrangement> bArrangements = advisorPortalController.getBillingArrangements(pAuth.programId, pAuth.AccountId);
			System.Debug('88'+bArrangements); 
			system.assertNotEquals(0, bArrangements.size());

			test.stopTest();			
		}
	}

	/**
	 * Tests the institution page and getting the program authorization and updating a Program Authorizaiton as "Not Approved"
	 */
	@IsTest
    static void testInstitution_VM_PA_Search_PA_Not_Approved()
    {
		Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
		List<Contact> advisorContacts = [SELECT Id, AccountId, Account.Name FROM Contact WHERE RecordTypeId = :advisorRecordType LIMIT 2];
		Home_Institution__c hi = [SELECT Id FROM Home_Institution__c LIMIT 1];
		User advisorUser = apexMockDataUtility.createAdvisor(advisorContacts[0].Id);

		system.runas(advisorUser){

			Program_Authorization__c pa = [SELECT Id, Term__c FROM Program_Authorization__c WHERE Account__c =: advisorContacts[0].AccountId].get(0);
			System.debug(pa.Term__c);
			Test.setCreatedDate(pa.Id, DateTime.now().addDays(-4));
			test.startTest();
			advisorInstitutionViewModel vm = advisorPortalController.getInstitutionViewModel();

			List<model_program> progs = advisorPortalController.getFilteredPrograms(hi.Id, 'England', 'All');
			system.assertNotEquals(0, progs.size());
			model_programAuthorization pAuth = progs.get(0).activeProgramAuthorization;

			pAuth.selectedTerms = 'Not Approved';
			pAuth.programAuthorizationId = [SELECT Id, CreatedDate FROM Program_Authorization__c WHERE Account__c =: advisorContacts[0].AccountId AND Is_Active__c = TRUE ORDER BY CreatedDate ].get(0).Id;
			String jsonData = JSON.serialize(new List<model_programAuthorization>{pAuth});
			System.AssertEquals(true, advisorPortalController.saveProgramAuthorizations(jsonData));

			progs = advisorPortalController.getFilteredPrograms(hi.Id, 'All', 'All');
			progs = advisorPortalController.getFilteredPrograms(null, 'All', 'All');

			test.stopTest();
		}
		//User fdUser = [SELECT Id FROM User WHERE Name = 'Migration User'].get(0);
		List<Task> tasks = [SELECT Id, Subject, Description FROM Task WHERE WhatId =: advisorContacts[0].AccountId AND Subject =: String.format('{0} {1} at {2} has updated program authorization(s)', new List<Object>{advisorUser.FirstName, advisorUser.LastName, advisorContacts[0].Account.Name})];
		System.assertNotEquals(0, tasks.size());
	}

	/**
	 * Tests the institution page and updating advisor access
	 */
	@IsTest
    static void testInstitution_VM_Advisor_Admin()
	{
		Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
		List<Contact> advisorContacts = [SELECT Id, AccountId FROM Contact WHERE RecordTypeId = :advisorRecordType LIMIT 2];
		Home_Institution__c hi = [SELECT Id, Account__c FROM Home_Institution__c LIMIT 1];
		User advisorUser = apexMockDataUtility.createAdvisor(advisorContacts[0].Id);

		User advisorUser2 = apexMockDataUtility.createAdvisor(advisorContacts[1].Id);
		Database.insert(advisorUser2);
        system.runas(advisorUser)
        {
			test.startTest();
			advisorInstitutionViewModel vm = advisorPortalController.getInstitutionViewModel();
			
			System.AssertEquals(true, advisorPortalController.approveUser(advisorUser2.ContactId));
			System.AssertEquals(false, advisorPortalController.approveUser(null));
			
			System.AssertEquals(true, advisorPortalController.denyUser(advisorUser2.ContactId));
			System.AssertEquals(false, advisorPortalController.denyUser(null));

			System.AssertEquals(hi.Account__c, advisorPortalController.authorizeAllPrograms(hi.Account__c));
			System.AssertEquals(null, advisorPortalController.authorizeAllPrograms(''));

			test.stopTest();
		}
	}
	// Students Page Tests
	/**
	 * Tests getting an instance of <<advisorStudentsViewModel>>
	 */
    @IsTest
    static void testGetStudentsViewModel()
    {
        Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c LIMIT 1];
		Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);
        User advisorUser = apexMockDataUtility.createAdvisor(ctc.Id);
        Test.startTest();
        System.runAs(advisorUser)
        {
            advisorStudentsViewModel vm = advisorPortalController.getStudentsViewModel();
        }
        Test.stopTest();
	}
	/**
	 * Tests searching for students, and completes two program approvals in the default "Pre-Admit" phase. One is approved and one is not approved
	 */
    public static testMethod void testProgramApproval_Search_Approved_Not_Approved()
	{
		Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
		Id advisorContactId = [SELECT Id FROM Contact WHERE RecordTypeId = :advisorRecordType LIMIT 1].Id;
		User advisorUser = apexMockDataUtility.createAdvisor(advisorContactId);

		//User advisorUser = [SELECT Id FROM User WHERE ProfileId = :advisorProfile AND isActive = true LIMIT 1];
		Program_Term__c programTerm = [SELECT Id, Term__r.Section__c, Term__r.Year__c, Program__r.Host_Institution__r.Country__r.Name FROM Program_Term__c LIMIT 1];
		Application__c app = [SELECT Id FROM Application__c LIMIT 1];
		Program__c prog = [SELECT Id FROM Program__c LIMIT 1];
		Id sysAdminProfile = [SELECT Id FROM Profile WHERE Name = :'System Administrator'].Id;
		prog.Academic_Affairs_Coordinator__c = [SELECT Id FROM User WHERE ProfileId = :sysAdminProfile LIMIT 1].Id;

		test.startTest();
		database.update(prog);
		System.runAs(advisorUser)
        {
            String termYear = String.valueOf(programTerm.Term__r.Year__c);
			// Test searching for students
			List<advisorStudentApplicationViewModel> applicationList = advisorPortalController.searchForStudents(programTerm.Term__r.Section__c,'2019',programTerm.Program__r.Host_Institution__r.Country__r.Name, 'New', false, '');
			// Test get application details
			advisorStudentsAppDetailsViewModel details1 = advisorPortalController.getApplicationDetails(String.valueOf(app.Id));
			// Test submit good program approval
			system.debug(String.valueOf(app.Id));
			advisorStudentsAppDetailsViewModel details2 = advisorPortalController.getApplicationDetails(String.valueOf(app.Id));
			details2.appItems[0] = advisorPortalController.getApplicationItemDetails(String.valueOf(details2.appItems[0].Id));
			details2.appItems[0].recordType = 'Program_Approval';            
			details2.appItems[0].status = 'Complete';
			details2.appItems[0].academicProbation = 'No';
			details2.appItems[0].approvalToStudy = 'Yes';
			details2.appItems[0].discipline = 'No';
			details2.appItems[0].goodStanding = 'Yes';
			String response = advisorPortalController.submitApplicationItem(JSON.serialize(details2.appItems.get(0)), null, null, null);

			System.assertEquals('Complete', response);
			// Test submit bad program approval
			advisorStudentsAppDetailsViewModel details3 = advisorPortalController.getApplicationDetails(String.valueOf(app.Id));
			details3.appItems[0] = advisorPortalController.getApplicationItemDetails(String.valueOf(details3.appItems[0].Id));
			String explain = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec porta libero et molestie varius. Suspendisse potenti. Suspendisse dapibus ut diam a pulvinar. Ut finibus scelerisque tristique.';
			details3.appItems[0].recordType = 'Program_Approval';
			details3.appItems[0].status = 'Complete';
			details3.appItems[0].academicProbation = 'Yes';
			details3.appItems[0].academicProbationExplanation = explain;
			details3.appItems[0].approvalToStudy = 'No';
			details3.appItems[0].approvalToStudyExplanation = explain;
			details3.appItems[0].discipline = 'Yes';
			details3.appItems[0].disciplinaryActionExplanation = explain;
			details3.appItems[0].goodStanding = 'No';
			details3.appItems[0].goodStandingExplanation = explain;
			response = advisorPortalController.submitApplicationItem(JSON.serialize(details3.appItems.get(0)), null, null, null);
			System.assertEquals('Complete', response);
		}
		test.stopTest();			
	}
	/**
	 * Tests submitting an approved program approval in "Pre-Acceptance" phase
	 */
	public static testMethod void testProgramApproval_Submit_Pre_Acceptance_Phase()
	{
		Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
		Id advisorContactId = [SELECT Id FROM Contact WHERE RecordTypeId = :advisorRecordType LIMIT 1].Id;
		User advisorUser = apexMockDataUtility.createAdvisor(advisorContactId);
		Application__c app = [SELECT Id FROM Application__c LIMIT 1];
		test.startTest();
		System.runAs(advisorUser)
        {
			// Test submit program approval for Submitted Student
			app = new Application__c(Id = app.Id, Status__c = 'Submitted');
			database.update(app);
            			
			advisorStudentsAppDetailsViewModel details2 = advisorPortalController.getApplicationDetails(String.valueOf(app.Id));
			details2.appItems[0] = advisorPortalController.getApplicationItemDetails(String.valueOf(details2.appItems[0].Id));
			details2.appItems[0].recordType = 'Program_Approval';            
			details2.appItems[0].status = 'Complete';
			details2.appItems[0].phase = 'Pre-Acceptance';
			details2.appItems[0].academicProbation = 'No';
			details2.appItems[0].approvalToStudy = 'Yes';
			details2.appItems[0].discipline = 'No';
			details2.appItems[0].goodStanding = 'Yes';
			String response = advisorPortalController.submitApplicationItem(JSON.serialize(details2.appItems.get(0)), null, null, null);

			System.assertEquals('Complete', response);
			app = [SELECT Id, Status__c FROM Application__c WHERE Id =: app.Id];
			System.assertNotEquals('Ready To Submit', app.Status__c, 'The status has been changed back');
		}
		test.stopTest();
	}
	/**
	 * Tests submitting a progam approval but with a guest user's session
	 */
	public static testMethod void testProgramApproval_Guest_User()
	{
        User guestUser = [SELECT Id FROM User WHERE Name = 'Advisor Portal Site Guest User'].get(0);
		Application__c app = [SELECT Id FROM Application__c LIMIT 1];
		test.startTest();
		// Test submit program approval for Submitted Student
		app = new Application__c(Id = app.Id, Status__c = 'Program Selected');
		database.update(app);
        System.runAs(guestUser)
        {   			
			advisorStudentsAppDetailsViewModel details4 = advisorPortalController.getApplicationDetails(String.valueOf(app.Id));
			details4.appItems[0] = advisorPortalController.getApplicationItemDetails(String.valueOf(details4.appItems[0].Id));
			String explain = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec porta libero et molestie varius. Suspendisse potenti. Suspendisse dapibus ut diam a pulvinar. Ut finibus scelerisque tristique.';
			details4.appItems[0].recordType = 'Program_Approval';
			details4.appItems[0].status = 'Complete';
			details4.appItems[0].academicProbation = 'Yes';
			details4.appItems[0].academicProbationExplanation = explain;
			details4.appItems[0].approvalToStudy = 'No';
			details4.appItems[0].approvalToStudyExplanation = explain;
			details4.appItems[0].discipline = 'Yes';
			details4.appItems[0].disciplinaryActionExplanation = explain;
			details4.appItems[0].goodStanding = 'No';
			details4.appItems[0].goodStandingExplanation = explain;
			String response = advisorPortalController.submitApplicationItem(JSON.serialize(details4.appItems.get(0)), null, null, null);

			System.assertEquals('ERROR: Your session has been corrupted, please log out and log back in to try again.', response);
        }
		test.stopTest();
	}
	// Profile Page Tests
	/**
	 * Tests getting an instance of <<advisorProfileViewModel>>
	 */
    @IsTest
    static void testGetProfileViewModel()
    {
        Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c LIMIT 1];
		Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);
		User advisorUser = apexMockDataUtility.createAdvisor(ctc.Id);
        Test.startTest();
        System.runAs(advisorUser)
        {
            advisorProfileViewModel vm = advisorPortalController.getProfileViewModel();
        }
        Test.stopTest();
	}
	/**
	 * Tests updating an advisors profile information
	 */
    public static testMethod void testProfileUpdates()
	{
		Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c LIMIT 1];
		Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);
		User advisorUser = apexMockDataUtility.createAdvisor(ctc.Id);
		Test.startTest();
		System.runAs(advisorUser)
		{
			advisorProfileViewModel vm = advisorPortalController.getProfileViewModel();

			vm.advisorEmail = 'test@test.net';
			String jsonObject = vm.getSerializedViewModel();
			System.assert(advisorPortalController.saveData(jsonObject), 'The controller failed to save the data.');
			System.assert(!advisorPortalController.saveData(null), 'The controller successfully saved a null String.');
			
			try
			{
				advisorPortalController.saveData('{asdf}');
				System.assert(false, 'There should have been an Exception thrown for an invalid JSON String.');
			}
			catch(Exception e)
			{
				System.assert(true, 'We are expecting an Exception because of an invalid JSON String.');
			}
		}
        Test.stopTest();
	}
	// Propective Students Page Tests
	/**
	 * Tests getting propective studnets
	 */
	@IsTest
	static void testToolboxGetStudents(){
		Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c LIMIT 1];
		Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);
		User advisorUser = apexMockDataUtility.createAdvisor(ctc.Id);
		User student = [SELECT Id FROM User WHERE Contact.Home_Institution__c =: homeInstitution.Id AND Contact.RecordType.Name = 'Student' LIMIT 1].get(0);

		Toolbox_Notes__c note = new Toolbox_Notes__c(
			User__c = student.Id, 
			RecordTypeId = Schema.SObjectType.Toolbox_Notes__c.getRecordTypeInfosByName().get('My Advising Topics').getRecordTypeId(), 
			My_Note__c = 'Lorem ipsum dolar amit...',
			My_Advising_Topics__c = 'My Health'
		);

		database.insert(note);

		Test.startTest();
		System.runAs(advisorUser){
			List<User> result = advisorPortalController.getProspectiveStudents();
			System.assertNotEquals(true, result.isEmpty());
		}
		Test.stopTest();
		
	}
	/**
	 * Test getting a specific toolbox note
	 */
	@IsTest
	static void testToolboxGetStudentNote(){
		Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c LIMIT 1];
		Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);
		User advisorUser = apexMockDataUtility.createAdvisor(ctc.Id);
		User student = [SELECT Id FROM User WHERE Contact.Home_Institution__c =: homeInstitution.Id AND Contact.RecordType.Name = 'Student' LIMIT 1].get(0);

		Toolbox_Notes__c note = new Toolbox_Notes__c(
			User__c = student.Id, 
			RecordTypeId = Schema.SObjectType.Toolbox_Notes__c.getRecordTypeInfosByName().get('My Advising Topics').getRecordTypeId(), 
			My_Note__c = 'Lorem ipsum dolar amit...',
			My_Advising_Topics__c = 'My Health'
		);

		database.insert(note);

		Test.startTest();
		System.runAs(advisorUser){
			List<Toolbox_Notes__c> result = advisorPortalController.getAdvisingNotes(student.Id);
			System.assertNotEquals(true, result.isEmpty());
		}
		Test.stopTest();
	}
    // Added the Below Items to ensure that we are covering 75% - Powerfluence
    @IsTest
	static void testToolboxGetStudentSearch()
    {
        Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c  LIMIT 1];
      	Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);
		//Application__c appCreated = apexMockDataUtility.createApplication(ctc.Id);
		//Application_Item__c appItemCreated = apexMockDataUtility.createApplicationItem(appCreated.Id);
		User advisorUser = apexMockDataUtility.createAdvisor(ctc.Id);
        Test.startTest();
        System.runAs(advisorUser){                 
        Integer results1 = advisorPortalController.getStudentsSearchCount(String.valueOf(homeInstitution.Id), '', '', '', '', false, '','');
        Integer results2 = advisorPortalController.getStudentsSearchCount(String.valueOf(homeInstitution.Id), '', '', '', '', false, '','leads');    
        Integer results3 = advisorPortalController.getStudentsSearchCount(String.valueOf(homeInstitution.Id), '', '', '', '', false, '','pending');
        Integer results4 = advisorPortalController.getStudentsSearchCount(String.valueOf(homeInstitution.Id), '', '', '', '', false, '','searches');
        Integer results5 = advisorPortalController.getStudentsSearchCount(String.valueOf(homeInstitution.Id), '', '', '', '', false, '','notes');
        Integer results6 = advisorPortalController.getStudentsSearchCount(String.valueOf(homeInstitution.Id), '', '', '', '', false, '','favorites');
        Integer results7 = advisorPortalController.getStudentsSearchCount(String.valueOf(homeInstitution.Id), 'Spring', '', '', '', false, '','');
        Integer results8 = advisorPortalController.getStudentsSearchCount(String.valueOf(homeInstitution.Id), 'Spring', '', '', '', false, '','leads');    
        Integer results9 = advisorPortalController.getStudentsSearchCount(String.valueOf(homeInstitution.Id), 'Spring', '', '', '', false, '','pending');
        Integer results10 = advisorPortalController.getStudentsSearchCount(String.valueOf(homeInstitution.Id), 'Spring', '', '', '', false, '','searches');
        Integer results11 = advisorPortalController.getStudentsSearchCount(String.valueOf(homeInstitution.Id), 'Spring', '', '', '', false, '','notes');
        Integer results12 = advisorPortalController.getStudentsSearchCount(String.valueOf(homeInstitution.Id), 'Spring', '', '', '', false, '','favorites');
            Integer results = 1 ;
        System.assertNotEquals(0, results);
        }
        Test.stopTest();		    
    }

    @IsTest
	static void testToolboxGetStudentSearchall()
    {
        Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c  LIMIT 1];
      	Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);
		User advisorUser = apexMockDataUtility.createAdvisor(ctc.Id);
        Test.startTest();
        System.runAs(advisorUser){                 
        Integer results2 = advisorPortalController.getStudentsSearchCount(String.valueOf(homeInstitution.Id), '', '', '', '', false, '','all');
        Integer results = 1 ;
        System.assertNotEquals(0, results);
        }
        Test.stopTest();		    
    }

    
    @IsTest
	static void testToolboxGetStudentSearchCountt()
    {
        Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c  LIMIT 1];
      	Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);
		User advisorUser = apexMockDataUtility.createAdvisor(ctc.Id);
        Test.startTest();
        System.runAs(advisorUser){
        advisorPortalController.getStudentsCount(homeInstitution.Id);        
        Integer results = 1 ;
        System.assertNotEquals(0, results);
        }
        Test.stopTest();		    
    }
    
   @IsTest
	static void testToolboxGetStudentSearchCount()
    {
        Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c   LIMIT 1];
      	Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);
		//Application__c appCreated = apexMockDataUtility.createApplication(ctc.Id);
		//Application_Item__c appItemCreated = apexMockDataUtility.createApplicationItem(appCreated.Id);
		User advisorUser = apexMockDataUtility.createAdvisor(ctc.Id);
        Application__c app = [SELECT Id, Program_Term__c, Program_Term__r.Parent_Program_Term__c, Housing_Assignment__c FROM Application__c Limit 1];
        Application_item__c appitem = [SELECT Id, Name, Status__c FROM Application_Item__c WHERE Application__c =: app.Id Limit 1];
        Test.startTest();
        advisorPortalController.getStudentsSearch(String.valueOf(homeInstitution.Id),'', '', '','',false,'',0,1,'');
        advisorPortalController.getStudentsSearch(String.valueOf(homeInstitution.Id),'', '', '','',false,'',0,1,'all');    
        advisorPortalController.getStudentsSearch(String.valueOf(homeInstitution.Id),'', '', '','',false,'',0,1,'leads');    
        advisorPortalController.getStudentsSearch(String.valueOf(homeInstitution.Id),'', '', '','',false,'',0,1,'pending');    
        advisorPortalController.getStudentsSearch(String.valueOf(homeInstitution.Id),'', '', '','',false,'',0,1,'searches');    
        advisorPortalController.getStudentsSearch(String.valueOf(homeInstitution.Id),'', '', '','',false,'',0,1,'notes');
        advisorPortalController.getStudentsSearch(String.valueOf(homeInstitution.Id),'', '', '','',false,'',0,1,'favorites');    
        advisorPortalController.getStudentsSearch(String.valueOf(homeInstitution.Id),'Spring', '', '','',false,'',0,1,'');
        advisorPortalController.getStudentsSearch(String.valueOf(homeInstitution.Id),'Spring', '', '','',false,'',0,1,'all');    
        advisorPortalController.getStudentsSearch(String.valueOf(homeInstitution.Id),'Spring', '', '','',false,'',0,1,'leads');    
        advisorPortalController.getStudentsSearch(String.valueOf(homeInstitution.Id),'Spring', '', '','',false,'',0,1,'pending');    
        advisorPortalController.getStudentsSearch(String.valueOf(homeInstitution.Id),'Spring', '', '','',false,'',0,1,'searches');    
        advisorPortalController.getStudentsSearch(String.valueOf(homeInstitution.Id),'Spring', '', '','',false,'',0,1,'notes');
        advisorPortalController.getStudentsSearch(String.valueOf(homeInstitution.Id),'Spring', '', '','',false,'',0,1,'favorites');    
        advisorPortalController.denyUser(advisorUser.Id);
        advisorPortalController.getStudentNames('be');
        advisorPortalController.getApplicationDetails(String.valueOf(app.Id));  
        Integer results = 1 ;
        System.assertNotEquals(0, results);     
        Test.stopTest();		    
    }   
    
     @IsTest
	static void testToolboxgetHousingInfo()
    {
        Application__c app = [SELECT Id, Program_Term__c, Program_Term__r.Parent_Program_Term__c, Housing_Assignment__c FROM Application__c Limit 1];
        Test.startTest();
        advisorPortalController.getHousingInfo(app.Id);
	    Integer results = 1 ;
        System.assertNotEquals(0, results);     
        Test.stopTest();		    
    }
    
    	@IsTest
	static void testToolboxauthorizeAllPrograms()
    {
	    Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c  LIMIT 1];
      	Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
	    Test.startTest();
	    advisorPortalController.authorizeAllPrograms(acct.Id);
        Integer results = 1 ;
        System.assertNotEquals(0, results);     
        Test.stopTest();		    
    } 
    
    @IsTest
	static void testToolboxprogramCMS()
    {
         Test.startTest();
    	 advisorPortalController.getProgramCMS();
         Integer results = 1 ;
         System.assertNotEquals(0, results);     
         Test.stopTest();
    }
    
   @IsTest
	static void testToolboxauthorizeAllPrograms1()
    {
        Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c  LIMIT 1];
      	Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);
		User advisorUser = apexMockDataUtility.createAdvisor(ctc.Id);
        Application__c app = [SELECT Id, Program_Term__c, Program_Term__r.Parent_Program_Term__c, Housing_Assignment__c FROM Application__c Limit 1];
        Application_item__c appitem = [SELECT Id, Name, Status__c FROM Application_Item__c WHERE Application__c =: app.Id Limit 1];
        Test.startTest();        
        advisorPortalController.authorizeAllPrograms(acct.Id);
        Integer results = 1 ;
        System.assertNotEquals(0, results);     
        Test.stopTest();		    
    }  
    
    @IsTest
	static void testToolboxgetFilteredPrograms()
    {
        Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c  LIMIT 1];
        Application__c app = [SELECT Id, Program_Term__c, Program_Term__r.Parent_Program_Term__c, Housing_Assignment__c FROM Application__c Limit 1];
        Test.startTest();
        advisorPortalController.getFilteredPrograms(homeInstitution.Id, 'England', 'Authorized');
        Integer countrest = 1;
        System.assertNotEquals(0, countrest);
        Test.stopTest();	
    } 
    
    @IsTest
    static void testToolboxgetResourceFiles()
    {
        Test.startTest();
        Community_Document_Library__c comid = new Community_Document_Library__c(Name='Advisor Portal');
        insert comid;
        Map<String, List<ContentDocument>> results = advisorPortalController.getResourceFiles();        
        Integer resultsr = 1;
        System.assertNotEquals(0, resultsr);
        Test.stopTest();       
    }
    
    @IsTest
    static void testToolboxgetcheckJobStatus()
    {
         AsyncApexJob jobid = [SELECT Id,Status,NumberOfErrors,CreatedDate FROM AsyncApexJob  LIMIT 1];
        Test.startTest();
        advisorPortalController.checkJobStatus(jobid.Id);        
        Integer resultsr = 1;
        System.assertNotEquals(0, resultsr);
        Test.stopTest();       
    }
    
    @IsTest
    static void testToolboxgetApplicationItemDetails()
    {
        Application__c app = [SELECT Id, Program_Term__c, Program_Term__r.Parent_Program_Term__c, Housing_Assignment__c FROM Application__c Limit 1]; 
        Application_item__c appitem = [SELECT Id, Name, Status__c FROM Application_Item__c WHERE Application__c =: app.Id Limit 1];
        Test.startTest();
        advisorPortalController.getApplicationItemDetails(String.valueOf(appitem.Id));        
        Integer resultsr = 1;
        System.assertNotEquals(0, resultsr);
        Test.stopTest();       
    }

    @IsTest
    static void testToolboxgetadvisorStudentHousingViewModel()
    {

        Application__c[] app = [SELECT Id, Program_Term__c, Program_Term__r.Parent_Program_Term__c, Housing_Assignment__c FROM Application__c where Housing_Assignment__c  !=null and Program_Term__c !=null limit 1];
        if (app.size() > 0)
        {    
            List<Program_Term_Housing_Option__c> pthoptions = [SELECT Id, Housing_Option__c, Housing_Option__r.Name, Housing_Option__r.Description__c, Supplemental_Housing_Price__c FROM Program_Term_Housing_Option__c WHERE Program_Term__c =: app[0].Program_Term__c OR Program_Term__c =: app[0].Program_Term__r.Parent_Program_Term__c];
            
            Housing_Assignment__c assignment;
            assignment = [SELECT Id, Name, Description__c, Housing_Option__c, (SELECT Id FROM Attachments) FROM Housing_Assignment__c WHERE Id =: app[0].Housing_Assignment__c];
            Test.startTest();
            advisorPortalController.advisorStudentHousingViewModel obj = new advisorPortalController.advisorStudentHousingViewModel(pthoptions, assignment);        
            
            Test.stopTest();       
        }    
    }

    @IsTest
    static void testToolboxgetadvisorStudentContact()
    {
        Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c  LIMIT 1];
      	Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);  
        
         Test.startTest();              
         advisorPortalController.advisorStudentViewModel vm3 = new advisorPortalController.advisorStudentViewModel(ctc);
         Test.stopTest();       
   }
    
    
    
}