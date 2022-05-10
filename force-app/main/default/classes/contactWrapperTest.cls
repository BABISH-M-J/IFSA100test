/**
 * Unit tests for contactWrapper
 * @author Cameron Ames
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
public without sharing class contactWrapperTest 
{
    public static testMethod void testCascadeToUser()
    {
		Map<String,sObject> dataMap = apexMockDataUtility.createIfsaDataCollection();
		BaseTriggerHandler.bypass('userTriggerHandler');
        test.startTest();
    	contactWrapper.cascadeToUser((Id) dataMap.get('studentContact').get('Id'));
    	
    	contactWrapper.createAdvisorUser((Id) dataMap.get('studentContact').get('Id'));
    	
    	Contact testContact = apexMockDataUtility.createContact('Test', null);
    	testContact.firstName = 'tester';
    	testContact.email = 'test@tester.te';
        
    	database.update(testContact);
    	contactWrapper.createAdvisorUser(testContact.Id);
        test.stopTest();
    }
}