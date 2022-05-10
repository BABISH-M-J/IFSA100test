/**
 * Unit tests for <<ifsaRecordLookupMethods>>
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
private class ifsaRecordLookupMethodsTest 
{	
	@TestSetup
	static void makeData(){
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
	}

	@isTest static void testRecordLookup() 
	{
		List<ifsaRecordLookupViewModel> results = ifsaRecordLookupMethods.searchForRecord('RecordType', 'Incident');

		system.assert(!results.isEmpty());

		results = ifsaRecordLookupMethods.searchForRecord('Contact', 'Test');

		system.assert(!results.isEmpty());

		results = portalRemotingMethods.searchForRecord('Program_Term__c', 'Test');

		system.assert(!results.isEmpty());
	}

	@isTest static void testRecordLookupWithRecordType() 
	{
		Contact studentContact = [SELECT Id, FirstName, RecordTypeId FROM Contact LIMIT 1];

		String studentRecordTypeDeveloperName = [SELECT DeveloperName FROM RecordType WHERE Id =: studentContact.RecordTypeId].get(0).DeveloperName;
		
		List<ifsaRecordLookupViewModel> results = ifsaRecordLookupMethods.searchForRecordWithRecordType('Contact', studentContact.FirstName, studentRecordTypeDeveloperName);

		system.assert(!results.isEmpty());

		Country__c country = [SELECT Id FROM Country__c LIMIT 1];
		Locality__c locality1 = new Locality__c(Name = 'Test Locality 1', Country__c = country.Id);
		Locality__c locality2 = new Locality__c(Name = 'Test Locality 2', Country__c = country.Id);
		Locality__c locality3 = new Locality__c(Name = 'Test Locality 3', Country__c = country.Id);
		Database.insert(new List<Locality__c>{locality1, locality2, locality3});
		
		results = portalRemotingMethods.searchForRecordWithRecordType('Locality__c', 'Test', 'Test');		
	}	
}