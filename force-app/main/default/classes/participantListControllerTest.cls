@isTest
public without sharing class participantListControllerTest {
	
	@isTest static void participantList() {

		// Record Types
		Id accountRT = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId();
		Id contactRT = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
		Id ptRT = Schema.sObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();

		// Create Test Data
		World__c earth = new World__c();
		insert earth;

		Region__c r = new Region__c();
		r.World__c = earth.Id;
		insert r;

		Country__c country = new Country__c();
		country.Name = 'Test Country';
		country.Region__c = r.Id;
		country.Active__c = TRUE;
		insert country;

		Home_Institution__c hmi = new Home_Institution__c(Name = 'Test Home Institution');
		insert hmi;

		Program__c p = new Program__c(Name = 'Test Program', Country__c = country.Id, Transcript__c = 'Butler');
		insert p;

		Term__c t = new Term__c();
		t.Name = 'Spring 2018';
		t.Section__c = 'Spring';
		t.Year__c = 2018;
		insert t;
		
		Program_Term__c pt = new Program_Term__c();
		pt.Name = 'Test Program Term';
		pt.RecordTypeId = ptRT;
		pt.Program__c = p.Id;
		pt.Term__c = t.Id;
		pt.Country__c = country.Id;
		insert pt;

		// Studemt 1 - no address
		Account a1 = new Account();
		a1.Name = 'Test Student 1';
		a1.RecordTypeId = accountRT;

		// Studemt 2 - short address
		Account a2 = new Account();
		a2.Name = 'Test Student 2';
		a2.RecordTypeId = accountRT;

		// Studemt 3 - long address
		Account a3 = new Account();
		a3.Name = 'Test Student 3';
		a3.RecordTypeId = accountRT;
		// Insert Accounts
		insert new List<Account>{a1, a2, a3};

		Contact c1 = new Contact();
		c1.FirstName = 'Test';
		c1.LastName = 'Student 1';
		c1.RecordTypeId = contactRT;
		c1.AccountId = a1.Id;
		c1.Home_Institution__c = hmi.Id;

		Contact c2 = new Contact();
		c2.FirstName = 'Test';
		c2.LastName = 'Student 2';
		c2.RecordTypeId = contactRT;
		c2.MailingStreet = '123 Test Street';
		c2.AccountId = a2.Id;
		c2.Home_Institution__c = hmi.Id;

		Contact c3 = new Contact();
		c3.FirstName = 'Test';
		c3.LastName = 'Student 3';
		c3.RecordTypeId = contactRT;
		c3.MailingStreet = '123 Super long address that is so long it cannot even be real avenue';
		c3.AccountId = a3.Id;
		c3.Home_Institution__c = hmi.Id;
		// Insert Contacts
		insert new List<Contact>{c1, c2, c3};

		Application__c app1 = new Application__c();
		app1.Name = 'Test Application 1';
		app1.Designation__c = 'Primary';
		app1.Status__c = 'Accepted';
		app1.Applicant__c = c1.Id;
		app1.Program_Term__c = pt.Id;
		app1.Status_Contract_Signed__c = System.today();

		Application__c app2 = new Application__c();
		app2.Name = 'Test Application 2';
		app2.Designation__c = 'Primary';
		app2.Status__c = 'Accepted';
		app2.Applicant__c = c2.Id;
		app2.Program_Term__c = pt.Id;
		app2.Status_Contract_Signed__c = System.today();

		Application__c app3 = new Application__c();
		app3.Name = 'Test Application 3';
		app3.Designation__c = 'Primary';
		app3.Status__c = 'Accepted';
		app3.Applicant__c = c3.Id;
		app3.Program_Term__c = pt.Id;
		app3.Status_Contract_Signed__c = System.today();

		// Insert Applications
		insert new List<Application__c>{app1, app2, app3};

		// Reference vf page
		PageReference pageRef = Page.participantList;
		Test.setCurrentPageReference(pageRef);

		// Test
		Test.startTest();

			participantListController plCntrl = new participantListController();
			
			plCntrl.selectedYear = 2018;
			plCntrl.selectedSection = 'Spring';

			// Get list of participants
			plCntrl.getParticipants();

			// Create file
			if(plCntrl.hasRecords == TRUE){
				plCntrl.export();
				plCntrl.export();
			}

		Test.stopTest();
	}
}