/**
 * Unit tests for <<invocableCreateAdvisorUser>>
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public without sharing class invocableCreateAdvisorUserTest
{
    static Id contextUserId = [SELECT Id FROM User WHERE Name = 'Migration User'].get(0).Id;
    @TestSetup
    static void makeData()
    {
        Account a = new Account();
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId();
        a.Name = 'Test Account';
        a.OwnerId = contextUserId;

        insert a;
        Contact c1 = new Contact();
        c1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        c1.FirstName = 'Test A';
        c1.LastName = 'Contact';
        c1.Email = 'test_a.contact@email.test';
        c1.Phone = '5555551111';
        c1.OwnerId = contextUserId;
        c1.AccountId = a.Id;

        Contact c2 = new Contact();
        c2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        c2.FirstName = 'Test B';
        c2.LastName = 'Contact';
        c2.Email = 'test_b.contact@email.test';
        c2.Phone = '5555552222';
        c2.OwnerId = contextUserId;
        c2.AccountId = a.Id;

        insert new List<Contact>{c1, c2};
    }

    @IsTest
    static void testCreateAdvisorUser()
    {
        User contextUser = [SELECT Id FROM User WHERE Id =: contextUserId];
        
        Contact c1 = [SELECT Id FROM Contact WHERE FirstName = 'Test A'];
        String[] result;
        Test.startTest();
        System.runAs(contextuser){
            result = invocableCreateAdvisorUser.createAdvisorUser(new List<Id>{c1.Id});
        }
        Test.stopTest();
        System.assertEquals('The advisor user has been created and the advisor has been sent a password reset email.', result.get(0));
        System.runAs(contextuser){
            result = invocableCreateAdvisorUser.createAdvisorUser(new List<Id>{c1.Id});
        }
        System.assertEquals('This advisor already has access to the advisor portal.', result.get(0));
    }

    @IsTest
    static void testCreateAdvisorUserFailTooMany()
    {
        User contextUser = [SELECT Id FROM User WHERE Id =: contextUserId];
        
        Contact c1 = [SELECT Id FROM Contact WHERE FirstName = 'Test A'];
        Contact c2 = [SELECT Id FROM Contact WHERE FirstName = 'Test B'];
        String[] result;
        Test.startTest();
        System.runAs(contextuser){
            result = invocableCreateAdvisorUser.createAdvisorUser(new List<Id>{c1.Id, c2.Id});
        }
        Test.stopTest();
        System.debug(result);
        System.assertEquals('ERROR: Too many contact ids provided', result.get(0));
    }

    @IsTest
    static void testCreateAdvisorUserNotEnough()
    {
        User contextUser = [SELECT Id FROM User WHERE Id =: contextUserId];
        
        String[] result;
        Test.startTest();
        System.runAs(contextuser){
            result = invocableCreateAdvisorUser.createAdvisorUser(new List<Id>());
        }
        Test.stopTest();
        System.debug(result);
        System.assertEquals('ERROR: Did not provide a contact id', result.get(0));
    }
}