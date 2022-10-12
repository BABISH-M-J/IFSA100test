/**
 * Unit tests for <<formBuilderComponentController>>
 * @author Matt Eck
 */
// ApexDoc updated 2/8/2021 Brock Barlow
@isTest
public with sharing class formBuilderComponentControllerTest {
    @TestSetup
    static void makeData(){
        // All Data
       // Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
        World__c world = new World__c(Name = 'Global');
        database.insert(world);
        
        Region__c international = new Region__c(Name = 'International Support', World__c = world.Id);
        Region__c local = new Region__c(Name = 'Local Support', World__c = world.Id);
        database.insert(new List<Region__c>{international, local});
        
        Country__c usa = apexMockDataUtility.createLocalCountry(local.Id);
        Country__c country = apexMockDataUtility.createCountry(international.Id);
        
           Host_Institution__c hostInstitution  =   apexMockDataUtility.createHostInstitution(country.Id);
          Term__c term=    apexMockDataUtility.createTerm();

      Program__c program= apexMockDataUtility.createProgram(hostInstitution, 'testname');
       
        Program_Term__c programTerm=apexMockDataUtility.createProgramTerm(program, term);
       
         Application_Requirement__c appReq = new Application_Requirement__c(
            Name = 'Unit Test',
            //Do 1 because of academic/personal statement,
            RecordTypeId = Schema.SObjectType.Application_Requirement__c.getRecordTypeInfosByName().get('Academic/Personal Statement').getRecordTypeId(),
            Phase__c = 'Pre-Admit',
            Program_Term__c = programTerm.Id
        );
        
        Database.insert(appReq);
        
           
        // Form Data
        formBuilderComponentController.Form formWrap = new formBuilderComponentController.Form();
        Id cifRecordTypeId = Schema.SObjectType.Dynamic_Form__c.getRecordTypeInfosByName().get('CIF').getRecordTypeId();

        formWrap = formBuilderComponentController.initForm(null, cifRecordTypeId);
        String jsonWrapper = JSON.serialize(formWrap, true);
        String formId = formBuilderComponentController.submitForm(jsonWrapper, 4, 4, 'testForm', true);
             Id df= [SELECT Id From Dynamic_Form__c WHERE Name = 'testForm' Limit 1].Id;
   
 Dynamic_Form_Item__c dfi=new Dynamic_Form_Item__c(Dynamic_Form__c=df,Name='testFormItem',Use_Destination_Field_s_Picklist_Values__c=true);
     Database.insert(dfi);
   Dynamic_Form_Rule__c dfr=new Dynamic_Form_Rule__c(Name='test',Application_Requirement__c=appReq.Id, Controlling_Form_Item__c=dfi.Id, Dependent_Form_Item__c=dfi.Id, Dynamic_Form__c=df);
    Database.insert(dfr); 
Rule_Item__c ri=new Rule_Item__c(Name='testrule', Dynamic_Form_Rule__c=dfr.Id);
Database.insert(ri); 
         
    }

    public static testMethod void initNullFormTest(){
        formBuilderComponentController.Form formWrap = new formBuilderComponentController.Form();
        Id cifRecordTypeId = Schema.SObjectType.Dynamic_Form__c.getRecordTypeInfosByName().get('CIF').getRecordTypeId();

        Test.startTest();
        formWrap = formBuilderComponentController.initForm(null, cifRecordTypeId);
        Test.stopTest();

        system.assertEquals(null, formWrap.formRules);
        system.assertEquals(null, formWrap.itemRules);
    }

    public static testMethod void initNonNullFormTest(){
        formBuilderComponentController.Form formWrap = new formBuilderComponentController.Form();
        Id formId = [SELECT Id From Dynamic_Form__c WHERE Name = 'testForm' Limit 1].Id;

        Test.startTest();
        formWrap = formBuilderComponentController.initForm(formId, null);
        Test.stopTest();

        system.assertEquals(null, formWrap.formRules);
        system.assertEquals(null, formWrap.itemRules);
    }

    public static testMethod void submitNewFormTest(){
        formBuilderComponentController.Form formWrap = new formBuilderComponentController.Form();
        Id cifRecordTypeId = Schema.SObjectType.Dynamic_Form__c.getRecordTypeInfosByName().get('CIF').getRecordTypeId();
        
        Test.startTest();
        formWrap = formBuilderComponentController.initForm(null, cifRecordTypeId);
        Id progTermId = [SELECT Id FROM Program_Term__c LIMIT 1].Id;
        formWrap.progTermId = progTermId;
        String jsonWrapper = JSON.serialize(formWrap, true);
        String formId = formBuilderComponentController.submitForm(jsonWrapper, 5, 5, 'newForm', true);
        formId = formBuilderComponentController.submitForm(jsonWrapper, 5, 5, 'newForm', false);
        Test.stopTest();
    }

    public static testMethod void submitExistingFormTest(){
        formBuilderComponentController.Form formWrap = new formBuilderComponentController.Form();
        Id formId = [SELECT Id From Dynamic_Form__c WHERE Name = 'testForm' Limit 1].Id;

        Test.startTest();
        formWrap = formBuilderComponentController.initForm(formId, null);
        Program_Term__c progTerm = [SELECT Id FROM Program_Term__c LIMIT 1];
        formWrap.progTermId = progTerm.Id;
        String jsonWrapper = JSON.serialize(formWrap, true);
        formId = formBuilderComponentController.submitForm(jsonWrapper, 5, 5, 'updateForm', true);
        formId = formBuilderComponentController.submitForm(jsonWrapper, 5, 5, 'updateForm', false);
        Test.stopTest();
    }

    public static testMethod void cloneHelperTest(){
        formBuilderComponentController.Form formWrap = new formBuilderComponentController.Form();
        Id formId = [SELECT Id From Dynamic_Form__c WHERE Name = 'testForm' Limit 1].Id;
        Id appReqId = [SELECT Id FROM Application_Requirement__c LIMIT 1].Id;

        Test.startTest();
        formWrap = formBuilderComponentController.initForm(formId, null);
        String jsonWrapper = JSON.serialize(formWrap, true);
        formWrap = formBuilderComponentController.cloneHelper(jsonWrapper, appReqId);
        Test.stopTest();
    }


     public static testMethod void courseSearchTest(){
        List<Course__c> courseList = new List<Course__c>();
        Test.startTest();
        Program_Term__c progTerm = [SELECT Name, Id FROM Program_Term__c LIMIT 1];
        courseList = formBuilderComponentController.courseSearch('Test', progTerm.Id, null);
        Test.stopTest();

       // system.assertEquals(1, courseList.size());
     }

     public static testMethod void progTermSearchTest(){
        List<Program_Term__c> progTermList = new List<Program_Term__c>();
        Test.startTest();
        progTermList = formBuilderComponentController.progTermSearch('Test');
        Test.stopTest();

      //  system.assertEquals(1, progTermList.size());
     }

     public static testMethod void objectSearchTest(){
        List<EntityDefinition> EntityDefinitionList = new List<EntityDefinition>();
        Test.startTest();
        EntityDefinitionList = formBuilderComponentController.objectSearch('Contact');
        Test.stopTest();

        system.assertEquals(1, EntityDefinitionList.size());
     }

     public static testMethod void setProgTermTest(){
        formBuilderComponentController.Form formWrap = new formBuilderComponentController.Form();
        Id formId = [SELECT Id From Dynamic_Form__c WHERE Name = 'testForm' Limit 1].Id;

        Test.startTest();
        Program_Term__C progTerm = [SELECT Name, Id FROM Program_Term__c LIMIT 1];
        formWrap = formBuilderComponentController.initForm(formId, null);
        String jsonWrapper = JSON.serialize(formWrap, true);

        formWrap = formBuilderComponentController.setProgTerm(jsonWrapper, progTerm.Name, progTerm.Id);
        Test.StopTest();

        system.assertNotEquals(null, formWrap.progTermName);
        system.assertNotEquals(null, formWrap.progTermId);
     }

     public static testMethod void fieldSearchTest(){
        List<String> fieldList = new List<String>();
        Test.startTest();
        fieldList = formBuilderComponentController.fieldSearch('Contact', new List<String>{'STRING', 'TEXTAREA'});
        Test.stopTest();

        system.assertNotEquals(true, fieldList.isEmpty());
     }
     
     public static testMethod void innerclassTest(){
             Application_Requirement__c appReqId = [SELECT Id,Name,Phase__c FROM Application_Requirement__c LIMIT 1];

     
     formBuilderComponentController.Form form1= new formBuilderComponentController.Form();
      formBuilderComponentController.Item item1 = new formBuilderComponentController.Item();
       formBuilderComponentController.Rule rule1= new formBuilderComponentController.Rule();
        formBuilderComponentController.RuleItem ruleitem1= new formBuilderComponentController.RuleItem();
                formBuilderComponentController.DesignationItem designationitem1= new formBuilderComponentController.DesignationItem();
                designationitem1.id='01p4N000008m8tj';
                designationitem1.name ='testname';
                designationitem1.designationRequired=true;
        Rule_Item__c ri=[Select Id,Name,Dynamic_Form_Rule__c, Dynamic_Form_Rule__r.Name from  Rule_Item__c limit 1];
         ruleitem1.relId =ri.Id;
         ruleitem1.relObj=ri.Name;
       ruleitem1.relObjName =ri.Dynamic_Form_Rule__r.Name;
          rule1.appReqId =appReqId.Id;
         rule1.appReqName =appReqId.Name;
         rule1.changeToPhase =appReqId.Phase__c;
         rule1.contItemNum = 5;
         rule1.contItemLabel ='test';
         rule1.contRule ='test';
         rule1.contData ='data';
         rule1.depAffect ='depeffect';
         rule1.depItemNum =6;
         rule1.depItemLabel ='string';
         rule1.altForEach =true;
         rule1.reqRuleItems =2;
         rule1.ruleName ='test';
      
         rule1.dataNum =5;
         rule1.minDepts =4;
         rule1.maxDepts =3;
         rule1.selectDesignations =true;
         rule1.linkClassesDept =false;
         rule1.minClassesPerDept =2;
         rule1.maxClassesPerDept =1;
       
       
     }
     
}