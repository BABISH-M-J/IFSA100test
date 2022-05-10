/**
 * Unit Tests for <<cmpTriggerHandler>> and <<cmpService>>
 * @author Matt Eck
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
public with sharing class cmpTriggerTest 
{
    /**
     * Test Setup
     */
    @TestSetup
    static void makeData(){
        //Create main dataset
        Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
        Id ceRecordType = Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Course Equivalency').getRecordTypeId();
        Id ciRecordType = Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Curriculum Integration').getRecordTypeId();

        Contact testContact = (Contact) testData.Get('studentContact');
        Contact progAdvisor = (Contact) testData.Get('advisorContact1');
        Contact homeInstitutionAdvisor = (Contact) testData.Get('advisorContact2');

        User progAdvisorUser = apexMockDataUtility.createProgramAdvisor();
        Database.insert(progAdvisorUser);
        User homeInstitutionAdvisorUser = (User) testData.get('studentUser');

        Program__c prog = (Program__c) testData.get('program');

        //Add CMPs
        List<CMP__c> cmpList = new List<CMP__c>();
        CMP__c newCMP = new CMP__c(Status__c = 'Submitted',
                                   Custom_Message_Text__c = 'Test Text',
                                   Contact__c = testContact.Id,
                                   Home_Institution_Account__c = homeInstitutionAdvisor.AccountId,
                                   RecordTypeId = ceRecordType);
        cmpList.add(newCMP);

        CMP__c newCMP2 = new CMP__c(Status__c = 'Submitted',
                                   Custom_Message_Text__c = 'Test Text',
                                   Contact__c = testContact.Id,
                                   Home_Institution_Account__c = homeInstitutionAdvisor.AccountId,
                                   Major__c = 'Accounting',
                                   RecordTypeId = ciRecordType);
        cmpList.add(newCMP2);
        
        insert cmpList;

        //Add SPs
        List<Support_Personnel__c> spList = new List<Support_Personnel__c>();
        Support_Personnel__c sp1 = new Support_Personnel__c(type__c = 'Non IFSA Staff',
                                                            Support_Role_Type__c = 'Advisor',
                                                            Non_Ifsa_Staff__c = progAdvisor.Id,
                                                            Program__c = prog.Id);
        spList.add(sp1);

        Support_Personnel__c sp2 = new Support_Personnel__c(type__c = 'Non IFSA Staff',
                                                            Support_Role_Type__c = 'Advisor',
                                                            Non_Ifsa_Staff__c = homeInstitutionAdvisor.Id,
                                                            Home_Institution__c = testContact.Home_Institution__c);
        spList.add(sp2);

        Support_Personnel__c sp3 = new Support_Personnel__c(type__c = 'IFSA Staff',
                                                            Support_Role_Type__c = 'Advisor',
                                                            Ifsa_Staff__c = progAdvisorUser.Id,
                                                            Program__c = prog.Id);
        spList.add(sp3);

        Support_Personnel__c sp4 = new Support_Personnel__c(type__c = 'IFSA Staff',
                                                            Support_Role_Type__c = 'Advisor',
                                                            Ifsa_Staff__c = homeInstitutionAdvisorUser.Id,
                                                            Home_Institution__c = testContact.Home_Institution__c);
        spList.add(sp4);

        Support_Personnel__c sp5 = new Support_Personnel__c(type__c = 'Non IFSA Staff',
                                                            Support_Role_Type__c = 'Field Director',
                                                            Non_Ifsa_Staff__c = homeInstitutionAdvisor.Id,
                                                            Program__c = prog.Id);
        spList.add(sp5);

        insert spList;
    }

    @IsTest
    static void updateCMPtoCompleted(){
        CMP__c cmp= [SELECT Id, Status__c, Contact__r.Active_Application__r.Program_Term__r.Program__r.Name FROM CMP__c WHERE RecordTypeId =: Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Course Equivalency').getRecordTypeId()];
        test.startTest();
            cmp.Status__c = 'Completed';
            update cmp;
            Integer invocations = Limits.getEmailInvocations();
        test.stopTest();

        system.assertEquals(1, invocations);
    }

    @IsTest
    static void updateCICMPtoCompleted(){
        CMP__c cmp= [SELECT Id, Status__c, Contact__r.Active_Application__r.Program_Term__r.Program__r.Name FROM CMP__c WHERE RecordTypeId =: Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Curriculum Integration').getRecordTypeId()];
        test.startTest();
            cmp.Status__c = 'Completed';
            update cmp;
            Integer invocations = Limits.getEmailInvocations();
        test.stopTest();

        system.assertEquals(1, invocations);
    }

    @IsTest
    static void onlyNonIfsaProgAdvisor(){
        List<Support_Personnel__c> spsToDelete = [SELECT Id FROM Support_Personnel__c WHERE Non_Ifsa_Staff__c = null OR Program__c = null];
        delete spsToDelete;

        CMP__c cmp= [SELECT Id, Status__c, Contact__r.Active_Application__r.Program_Term__r.Program__r.Name FROM CMP__c WHERE RecordTypeId =: Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Course Equivalency').getRecordTypeId()];
        test.startTest();
            cmp.Status__c = 'Completed';
            update cmp;
            Integer invocations = Limits.getEmailInvocations();
        test.stopTest();

        system.assertEquals(1, invocations);
    }

    @IsTest
    static void onlyNonIfsaHomeAdvisor(){
        List<Support_Personnel__c> spsToDelete = [SELECT Id FROM Support_Personnel__c WHERE Non_Ifsa_Staff__c = null OR Home_Institution__c = null];
        delete spsToDelete;

        CMP__c cmp= [SELECT Id, Status__c, Contact__r.Active_Application__r.Program_Term__r.Program__r.Name FROM CMP__c WHERE RecordTypeId =: Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Course Equivalency').getRecordTypeId()];
        test.startTest();
            cmp.Status__c = 'Completed';
            update cmp;
            Integer invocations = Limits.getEmailInvocations();
        test.stopTest();

        system.assertEquals(1, invocations);
    }

    @IsTest
    static void onlyIfsaProgAdvisor(){
        List<Support_Personnel__c> spsToDelete = [SELECT Id FROM Support_Personnel__c WHERE Ifsa_Staff__c = null OR Program__c = null];
        delete spsToDelete;

        CMP__c cmp= [SELECT Id, Status__c, Contact__r.Active_Application__r.Program_Term__r.Program__r.Name FROM CMP__c WHERE RecordTypeId =: Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Course Equivalency').getRecordTypeId()];
        test.startTest();
            cmp.Status__c = 'Completed';
            update cmp;
            Integer invocations = Limits.getEmailInvocations();
        test.stopTest();

        system.assertEquals(1, invocations);
    }

    @IsTest
    static void onlyIfsaHomeAdvisor(){
        List<Support_Personnel__c> spsToDelete = [SELECT Id FROM Support_Personnel__c WHERE Ifsa_Staff__c = null OR Home_Institution__c = null];
        delete spsToDelete;

        CMP__c cmp= [SELECT Id, Status__c, Contact__r.Active_Application__r.Program_Term__r.Program__r.Name FROM CMP__c WHERE RecordTypeId =: Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Course Equivalency').getRecordTypeId()];
        test.startTest();
            cmp.Status__c = 'Completed';
            update cmp;
            Integer invocations = Limits.getEmailInvocations();
        test.stopTest();

        system.assertEquals(1, invocations);
    }

    @isTest
    static void addAdditionalnonIfsaProgramAdvisor(){
        List<Support_Personnel__c> spsToDelete = [SELECT Id FROM Support_Personnel__c WHERE Non_Ifsa_Staff__c = null OR Program__c = null];
        delete spsToDelete;

        Support_Personnel__c spToUpdate = [SELECT Id, Support_Role_Type__c FROM Support_Personnel__c WHERE Support_Role_Type__c = 'Field Director'];
        spToUpdate.Support_Role_Type__c = 'Advisor';
        update spToUpdate;

        CMP__c cmp= [SELECT Id, Status__c, Contact__r.Active_Application__r.Program_Term__r.Program__r.Name FROM CMP__c WHERE RecordTypeId =: Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Course Equivalency').getRecordTypeId()];
        test.startTest();
            cmp.Status__c = 'Completed';
            update cmp;
            Integer invocations = Limits.getEmailInvocations();
        test.stopTest();

        system.assertEquals(1, invocations);
    }
}