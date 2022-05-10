/**
 * Unit tests for Cases Tests legacy H&S case record types
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
@isTest
public without sharing class caseTriggerTest
{
	/**
	 * Test setup, creates test data to be used by the test class.
	 */
	@TestSetup
	static void makeData()
	{
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
		Country__c c = (Country__c) testData.get('country');
		c.Id = null;
		c.Name = 'England';
		Database.insert(c);
		Locality__c l = new Locality__c(Name = 'London', Country__c = c.Id, RecordTypeId = Schema.SObjectType.Locality__c.getRecordTypeInfosByName().get('City/Town').getRecordTypeId() );
		Database.insert(l);
		Host_Institution__c h = new Host_Institution__c(Name = 'University College London', Locality__c = l.Id, Country__c = c.Id);
		Database.insert(h);
		Program__c p = new Program__c(Name = h.Name, Locality__c = l.Id, Country__c = c.Id);
		Database.insert(p);
	}
	/**
	 * Test legacy city cases
	 */
	@IsTest
	static void testLegacyCityCase(){
		User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
		Test.startTest();
		System.runAs(contextuser){
			Case c = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident City').getRecordTypeId());
			c.Incident_Severity__c = 'Non-Emergency';
			c.Incident_Category__c = 'Program/Country Wide';
			c.Incident_Sub_Category__c = 'Political/Social Unrest';
			c.Incident_Sub_Subcategory__c = 'Protests/Demonstrations';
			c.Date_Time_of_Incident__c = Datetime.now();
			c.Affected_Cities__c = 'London';
			Database.insert(c);
		}
		Test.stopTest();
	}
	/**
	 * Test legacy country cases
	 */
	@IsTest
	static void testLegacyCountryCase(){
		User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
		Test.startTest();
		System.runAs(contextuser){
			Case c = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Country').getRecordTypeId());
			c.Incident_Severity__c = 'Non-Emergency';
			c.Incident_Category__c = 'Program/Country Wide';
			c.Incident_Sub_Category__c = 'Political/Social Unrest';
			c.Incident_Sub_Subcategory__c = 'Protests/Demonstrations';
			c.Date_Time_of_Incident__c = Datetime.now();
			c.Affected_Countries__c = 'England';
			Database.insert(c);
		}
		Test.stopTest();
	}
	// Host Institution Record Type has been disabled
	/* @IsTest
	static void testLegacyHostInstitutionCase(){
		User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
		Test.startTest();
		System.runAs(contextuse0r){
			Case c = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Host Institution').getRecordTypeId());
			c.Incident_Severity__c = 'Non-Emergency';
			c.Incident_Category__c = 'Program/Country Wide';
			c.Incident_Sub_Category__c = 'Political/Social Unrest';
			c.Incident_Sub_Subcategory__c = 'Protests/Demonstrations';
			c.Date_Time_of_Incident__c = Datetime.now();
			c.Affected_Host_Institutions__c = 'University College London';
			Database.insert(c);
		}
		Test.stopTest();
	} */
	/**
	 * Test legacy program cases
	 */
	@IsTest
	static void testLegacyProgramCase(){
		User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
		Test.startTest();
		System.runAs(contextuser){
			Case c = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Program').getRecordTypeId());
			c.Incident_Severity__c = 'Non-Emergency';
			c.Incident_Category__c = 'Program/Country Wide';
			c.Incident_Sub_Category__c = 'Political/Social Unrest';
			c.Incident_Sub_Subcategory__c = 'Protests/Demonstrations';
			c.Date_Time_of_Incident__c = Datetime.now();
			c.Affected_Programs__c = 'University College London';
			Database.insert(c);
		}
		Test.stopTest();
	}
}