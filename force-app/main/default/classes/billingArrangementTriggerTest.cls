/** 
 * Unit tests for <<billingArrangementCountryTriggerHandler>>, <<billingArrangementTriggerHandler>> and <<billingArrangementService>> 
 */
// ApexDoc updated 1/26/2021 Brock Barlow
@isTest
public with sharing class billingArrangementTriggerTest 
{
	public static testMethod void testUpdate()
	{	
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();

		Billing_Arrangement__c ba = (Billing_Arrangement__c) testData.get('billingArrangement1');
		Test.setCreatedDate(ba.Id, DateTime.now().addDays(-4));
		ba.Pays_Tuition__c = !ba.Pays_Tuition__c;
		ba.Term__c = 'Spring; Calendar Year; Academic Year;';
		Test.startTest();
		database.update(ba);
		ba = [SELECT Id, Previous__c, Next__c FROM Billing_Arrangement__c WHERE Previous__c =: ba.Id].get(0);
		ba.Term__c = 'Spring; Fall; Calendar Year;';
		database.update(ba);
		ba.Pays_Tuition__c = !ba.Pays_Tuition__c;
		ba.Term__c = 'Spring; Calendar Year; Academic Year;';
		database.update(ba);
		Test.stopTest();
	}
	@isTest static void testBillingArrangementCountry()
	{
		Map<String, SObject>  testData = apexMockDataUtility.createIfsaDataCollection();
		Account a = (Account) testData.get('institutionAccount1');
		database.delete(testData.get('billingArrangement1'));
		a.Direct_Bill__c = true;
		a.Direct_Bill_Summer__c = true;
		a.Direct_Bill_Semester_Year__c = true;
		a.Pays_Tuition__c = true;

		database.update(a);
		Test.startTest();

		Billing_Arrangement_Country__c bac = new Billing_Arrangement_Country__c(Account__c = a.Id, Country__c = testData.get('country').Id, Discount_Amount__c = 1000, Discount_Recipient__c = 'School');

		database.insert(bac);

		Test.stopTest();
	}

	@isTest static void testNewCustomProgram()
	{
		Map<String, SObject>  testData = apexMockDataUtility.createIfsaDataCollection();
		Account a = (Account) testData.get('institutionAccount1');

		Test.startTest();

		Program__c cp = new Program__c(Category__c = 'Custom', Custom_Program_Home_Instituiton_Account__c = a.Id);
		cp.Country__c = testData.get('country').Id;
		cp.Host_Institution__c = testData.get('hostInstitution').Id;

		database.insert(cp);

		Test.stopTest();
	}
}