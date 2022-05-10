@isTest
public without sharing class accountTriggerTest 
{
    @TestSetup
    static void makeData(){
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'CMS'});
    }

    @IsTest
    static void testTrigger(){
        BaseTriggerHandler.bypass('programTriggerHandler');
		BaseTriggerHandler.bypass('opportunityTrigger');
		BaseTriggerHandler.bypass('programTermTrigger');

        List<Account> newAccounts = new List<Account>();
        Account a = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId(),
            Name = 'Test Account',
            BillingStreet = 'Test Account\r\nTest Office\r\nRecipient Test\r\n123 Test Street',
            Approves_All_Calendar_Programs__c = True
        );
        newAccounts.add(a);

        Account b = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId(),
            Name = 'Test Account2',
            BillingStreet = 'Test Account2\r\nTest Office2\r\nRecipient Test2\r\n124 Test Street'
        );
        newAccounts.add(b);

        Account c = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId(),
            Name = 'Test Account3',
            BillingStreet = 'Test Account2\r\nTest Office2\r\nRecipient Test2\r\n124 Test Street'
        );
        newAccounts.add(c);

        Test.startTest();
        
        //Database.insert(a);
        Database.insert(newAccounts);
        a = [SELECT Id, Name, Billing_Address_1__c, Billing_Address_2__c, Billing_Address_3__c, Billing_Address_4__c, Approves_All_Summer_Programs__c, Approves_All_Winter_Programs__c, Course_Equivalency_Search__c FROM Account WHERE Id =: a.Id];
        System.assertNotEquals(null, a.Billing_Address_1__c);
        a.Approves_All_Summer_Programs__c = True;
        a.Approves_All_Winter_Programs__c = True;
        a.Course_Equivalency_Search__c = False;
        Database.update(a);
        a = [SELECT Id, Name, Billing_Address_1__c, Billing_Address_2__c, Billing_Address_3__c, Billing_Address_4__c FROM Account WHERE Id =: a.Id];
        Test.stopTest();
        
    }
}