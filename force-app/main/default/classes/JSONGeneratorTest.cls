@isTest
public with sharing class JSONGeneratorTest {
    static testMethod void generator(){
        CMS__c cmsObj = new CMS__c();
        cmsObj.RecordTypeId=Schema.SObjectType.CMS__c.getRecordTypeInfosByName().get('Program Data').getRecordTypeId();
        cmsObj.Program_Name__c='TEST';
        cmsObj.Active__c=true;
        
        insert cmsObj;
        
        WordPress_Setting__c connDetails = new WordPress_Setting__c();
        connDetails.Authkey__c = 'test';
        connDetails.EndPoint__c = 'test'; 
        connDetails.Name='WordPress';
        
        insert connDetails;
        
        test.setMock(HttpCalloutMock.class, new calloutMock());
        
        Test.startTest();
        JSONGenerator.generateForCMS(new List<CMS__c>{cmsObj}, 'insert');
        Test.stopTest();
    }
}