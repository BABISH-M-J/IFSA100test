/**
 * Unit tests for homeInstitutionTrigger and homeInstitutionTriggerHandler
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public without sharing class homeInstitutionTriggerTest
{
	public static testMethod void testAfterInsertBeforeUpdate()
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

		Home_Institution__c homeInstitution = new Home_Institution__c();
		homeInstitution.Name = 'testUniversity';
		homeInstitution.Country__c = testCountry.Id;
		
		Database.insert(homeInstitution);
		
		List<Account> accounts = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		System.assertEquals(1, accounts.size());
		
		Database.delete(homeInstitution);
		
		accounts = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id];
		System.assertEquals(0, accounts.size());
	}
}