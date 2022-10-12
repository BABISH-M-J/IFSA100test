/**
 * Unit tests for applicationRequirementTrigger, <<applicationRequirementTriggerHander>> and <<applicationRequirementService>>
 */
// ApexDoc updated 1/25/2021 Brock Barlow
@isTest
private class applicationRequirementTriggerTest 
{
    /**
     * Creates test data
     */
    @TestSetup
    static void makeData(){
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection();
    }
    /**
     * Tests inserting an Application_Requirement__c record
     */
    static testMethod void testProgramTermRequirement() 
    {
        Application_Requirement__c newAppReq = [SELECT Id FROM Application_Requirement__c LIMIT 1];
        newAppReq.id = null;
        system.debug(newAppReq);
        test.startTest();
        database.insert(newAppReq);
        test.stopTest();
    }
    /**
     * Tests updating an Application_Requirement__c record
     */
    static testMethod void testUpdateProgramTermRequirement() 
    {
        Application_Requirement__c req1 = [SELECT Id, Name, Directions__c FROM Application_Requirement__c].get(0);
        Application_Requirement__c oldReq1 = [SELECT Id, Name, Directions__c FROM Application_Requirement__c WHERE Id =: req1.Id].get(0);
        req1.Directions__c = 'New Directions ' + DateTime.Now().format();
        req1.Name = 'New Name ' + req1.Name  + DateTime.Now().format();
        test.startTest();
        database.update(req1);
        test.stopTest();
        req1 = [SELECT Id, Name, Directions__c FROM Application_Requirement__c WHERE Id =: req1.Id].get(0);
        system.assertNotEquals(req1.Name, oldReq1.Name, 'Name fields should not be the same');
        system.assertNotEquals(req1.Directions__c, oldReq1.Directions__c, 'Directions__c fields should not be the same');
    }    
    /**
     * Tests inserting an Application_Requirement__c record for a "Program Option" program term
     */
    static testMethod void testProgramOptionRequirement() 
    {
        Application_Requirement__c newAppReq = [SELECT Id, Program_Term__c FROM Application_Requirement__c LIMIT 1];
        Application__c app = [SELECT Id, Program_Term__c FROM Application__c LIMIT 1];
        Id progOptionRecordType = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option without Dates').getRecordTypeId();
        newAppReq.id = null;
        newAppReq.Program_Term__c = [SELECT Id FROM Program_Term__c WHERE RecordTypeId = :progOptionRecordType LIMIT 1].Id;
        app.Program_Term__c = newAppReq.Program_Term__c;
        test.startTest();
        database.insert(newAppReq);
        test.stopTest();
    }
}