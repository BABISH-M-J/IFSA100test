/**
 * Test class for the institution controller
 * @author Cameron Ames
 */
@isTest
public without sharing class advisorInstitutionControllerTest
{
	/* @TestSetup
    static void makeData(){
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'Billing','Program_Auths'});

		Program__c program = [SELECT Id, Name, Country__c FROM Program__c LIMIT 1];
		List<Term__c> terms = [SELECT Name, Id, Section__c FROM Term__c];
		Map<String, Term__c> termMap = new Map <String,Term__c>();
		for(Term__c term : terms){
			termMap.put(term.Section__c, term);
		}
	}/*
	/**
	 * test the instance methods
	 * There may be some non instance methods here (only because data is instantiated.)
	 */
	/* public static testMethod void testInstance()
	{
		Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
		List<Contact> advisorContacts = [SELECT Id, AccountId FROM Contact WHERE RecordTypeId = :advisorRecordType LIMIT 2];
		Home_Institution__c hi = [SELECT Id FROM Home_Institution__c LIMIT 1];
		User advisorUser = apexMockDataUtility.createAdvisor(advisorContacts[0].Id);

        system.runas(advisorUser)
        {
			
			Program_Authorization__c pa = [SELECT Id, Term__c FROM Program_Authorization__c WHERE Account__c =: advisorContacts[0].AccountId].get(0);
			System.debug(pa.Term__c);
			Test.setCreatedDate(pa.Id, DateTime.now().addDays(-4));
			test.startTest();
			advisorInstitutionController controller = new advisorInstitutionController();
			advisorInstitutionViewModel vm = controller.viewModel;
			
			PageReference reference = controller.validateAccess();
			
			List<model_program> progs = advisorInstitutionController.getFilteredPrograms(hi.Id, 'England', 'All');
			model_programAuthorization pAuth = progs.get(0).activeProgramAuthorization;
			system.assertNotEquals(0, progs.size());
			progs = advisorInstitutionController.getFilteredPrograms(hi.Id, 'Test', 'Unauthorized');
			System.assertEquals(null, progs);
			progs = advisorInstitutionController.getFilteredPrograms(hi.Id, 'England', 'Authorized');

			List<model_billingArrangement> bArrangements = advisorInstitutionController.getBillingArrangements(pAuth.programId, pAuth.AccountId);
			system.assertNotEquals(0, bArrangements.size());

			test.stopTest();			
		}
		
	}

	public static testMethod void testInstance2(){
		Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
		List<Contact> advisorContacts = [SELECT Id, AccountId FROM Contact WHERE RecordTypeId = :advisorRecordType LIMIT 2];
		Home_Institution__c hi = [SELECT Id FROM Home_Institution__c LIMIT 1];
		User advisorUser = apexMockDataUtility.createAdvisor(advisorContacts[0].Id);

		system.runas(advisorUser){

			Program_Authorization__c pa = [SELECT Id, Term__c FROM Program_Authorization__c WHERE Account__c =: advisorContacts[0].AccountId].get(0);
			System.debug(pa.Term__c);
			Test.setCreatedDate(pa.Id, DateTime.now().addDays(-4));
			test.startTest();
			advisorInstitutionController controller = new advisorInstitutionController();
			advisorInstitutionViewModel vm = controller.viewModel;
			
			PageReference reference = controller.validateAccess();

			List<model_program> progs = advisorInstitutionController.getFilteredPrograms(hi.Id, 'England', 'All');
			system.assertNotEquals(0, progs.size());
			model_programAuthorization pAuth = progs.get(0).activeProgramAuthorization;

			pAuth.selectedTerms = 'Not Approved';
			pAuth.programAuthorizationId = [SELECT Id, CreatedDate FROM Program_Authorization__c WHERE Account__c =: advisorContacts[0].AccountId AND Is_Active__c = TRUE ORDER BY CreatedDate ].get(0).Id;
			String jsonData = JSON.serialize(new List<model_programAuthorization>{pAuth});
			System.AssertEquals(true, advisorInstitutionController.saveProgramAuthorizations(jsonData));

			progs = advisorInstitutionController.getFilteredPrograms(hi.Id, 'All', 'All');
			progs = advisorInstitutionController.getFilteredPrograms(null, 'All', 'All');

			test.stopTest();
		}
		User fdUser = [SELECT Id FROM User WHERE Name = 'Migration User'].get(0);
		List<Task> tasks = [SELECT Id FROM Task WHERE OwnerId =: fdUser.Id AND Subject LIKE '%has updated program authorization(s)%'];
		System.assertNotEquals(0, tasks.size());
	}

	public static testMethod void testInstance3()
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
			advisorInstitutionController controller = new advisorInstitutionController();
			advisorInstitutionViewModel vm = controller.viewModel;
			
			PageReference reference = controller.validateAccess();

			System.AssertEquals(true, advisorInstitutionController.approveUser(advisorUser2.ContactId));
			System.AssertEquals(false, advisorInstitutionController.approveUser(null));
			
			System.AssertEquals(true, advisorInstitutionController.denyUser(advisorUser2.ContactId));
			System.AssertEquals(false, advisorInstitutionController.denyUser(null));

			System.AssertEquals(true, advisorInstitutionController.authorizeAllPrograms(hi.Account__c));
			System.AssertEquals(false, advisorInstitutionController.authorizeAllPrograms(''));

			controller.viewModel.isLockDownActive = true;
			reference = controller.validateAccess();

			test.stopTest();
		}
	} */

}