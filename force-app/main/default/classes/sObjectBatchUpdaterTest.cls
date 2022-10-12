@isTest
public without sharing class sObjectBatchUpdaterTest {

    // Create test data
    @TestSetup
    static void makeData(){
        //Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'CMS'});
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection(new List<String>{'accountTrigger'}, new Set<String>{'CMS'});
    }

    public static testMethod void testBatchInsert()
    {
        Test.startTest();
        List<SObject> sObj = new List<SObject>();
        Account aRecord = new Account(Name='Test Account');
        sObj.add(aRecord);
        sObjectBatchUpdater sOBU = new sObjectBatchUpdater(sObj, sObjectBatchUpdater.dmlTypes.dmlInsert);
        Database.executeBatch(sOBU);
        Test.stopTest();
    }

    public static testMethod void testBatchInsertWTriggerBypass()
    {
        Test.startTest();
        List<SObject> sObj = new List<SObject>();
        List<String> listTriggerBypass = new List<String>();
        listTriggerBypass.add('accountTriggerHandler');
        Account aRecord = new Account(Name='Test Account');
        sObj.add(aRecord);
        sObjectBatchUpdater sOBU = new sObjectBatchUpdater(sObj, sObjectBatchUpdater.dmlTypes.dmlInsert, listTriggerBypass);
        Database.executeBatch(sOBU);
        Test.stopTest();
    }

    public static testMethod void testBatchInsertWRelatedList()
    {
        List<Contact> listContacts = apexQueryUtility.selectAllFrom('Contact', 'Id != null');
        List<SObject> sObj = new List<SObject>();
        List<String> listTriggerBypass = new List<String>();
        List<Id> listIds = new List<Id>();
        listIds.add(listContacts.get(0).Id);
        listTriggerBypass.add('accountTriggerHandler');
        Account aRecord = new Account(Name='Test Account');
        sObj.add(aRecord);
        Test.startTest();
        sObjectBatchUpdater sOBU = new sObjectBatchUpdater(sObj, sObjectBatchUpdater.dmlTypes.dmlInsert, listIds);
        Database.executeBatch(sOBU);
        Test.stopTest();
    }

    public static testMethod void testBatchUpdate()
    {
        List<Contact> listContacts = apexQueryUtility.selectAllFrom('Contact', 'Id != null');
        Contact contactToUpdate = listContacts.get(0);
        contactToUpdate.FirstName = 'Test Update';
        List<SObject> sObj = new List<SObject>();
        sObj.add(contactToUpdate);
        Test.startTest();
        sObjectBatchUpdater sOBU = new sObjectBatchUpdater(sObj, sObjectBatchUpdater.dmlTypes.dmlUpdate);
        Database.executeBatch(sOBU);
        Test.stopTest();
    }

    public static testMethod void testBatchUpsert()
    {
        List<Account> listAccounts = apexQueryUtility.selectAllFrom('Account', 'Id != null');
        Account accountToUpsert = listAccounts.get(0);
        accountToUpsert.Name = 'TEST Upsert';
        List<SObject> sObj = new List<SObject>();  
        sObj.add(accountToUpsert);
        Test.startTest();
        sObjectBatchUpdater sOBU = new sObjectBatchUpdater(sObj, sObjectBatchUpdater.dmlTypes.dmlUpsert);
        Database.executeBatch(sOBU);
        Test.stopTest();      
    }

    public static testMethod void testBatchDelete()
    {
        List<Account> listAccounts = apexQueryUtility.selectAllFrom('Account', 'Id != null');
        Account accountToDelete = listAccounts.get(0);
        List<SObject> sObj = new List<SObject>();
        sObj.add(accountToDelete);
        Test.startTest();
        sObjectBatchUpdater sOBU = new sObjectBatchUpdater(sObj, sObjectBatchUpdater.dmlTypes.dmlDelete);
        Database.executeBatch(sOBU);
    }

    public static testMethod void testErrorEmail()
    {
        List<Account> listAccounts = apexQueryUtility.selectAllFrom('Account', 'Id != null');
        Account acct = listAccounts.get(0);
        acct.Discount_Rate__c = 3.2;
        List<SObject> sObj = new List<SObject>();
        sObj.add(acct);

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);

        System.runAs(u) 
        {
            // The following code runs as user 'u'
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            System.debug('Current User Type: ' +UserInfo.getUserType());
            Test.startTest();
            sObjectBatchUpdater sOBU = new sObjectBatchUpdater(sObj, sObjectBatchUpdater.dmlTypes.dmlInsert);
            Database.executeBatch(sOBU);
            Test.stopTest();
        }
    }
}