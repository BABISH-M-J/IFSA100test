@isTest
public class dynamicFormViewModel_Test {
	@testSetup
    public static void mockdata(){
        //Cretae World Test Record
        World__c world = new World__c(Name = 'Global');
        database.insert(world);
        
        //Cretae Region Test Record
        Region__c reg = new Region__c(Name = 'Local Support', World__c = world.Id);
        database.insert(reg);
        
        //Cretae Country Test Record
        Country__c cou = apexMockDataUtility.createCountry(reg.id);
        
        //Cretae Host Institute Test Record
        Host_Institution__c hostIns = apexMockDataUtility.createHostInstitution(cou.id);
        
        //Create Home Institution Test Record
        Home_Institution__c homeIns = apexMockDataUtility.createHomeInstitution('Test', cou.id);
        
        //Cretae Program Test Record
        Program__c prog = apexMockDataUtility.createProgram(hostIns, 'Test Program');
        
        //Create test account
        Account acct = apexMockDataUtility.createAccount('TestAcct',homeIns.id);
        
        //Create test contact
        Contact ctc = apexMockDataUtility.createContact('TestCtc', acct.Id);
        ctc.Home_Institution__c = homeIns.id;
        update ctc;
        
        //Create test user
        User u= apexMockDataUtility.createUser(ctc.id);
        insert u;
        
        //Create Term Test Record
        Term__c term = apexMockDataUtility.createTerm('Spring' , Date.today().year());
        
        //Create Program Term Test Record
        List<Program_Term__c> progTermList = new List<Program_Term__c>();
        for(Integer i =0; i<3;i++){
            Program_Term__c progterm = apexMockDataUtility.createProgramTerm(prog,term,false);
            progterm.Department__c = 'Test'+i;
            progTermList.add(progterm);
        }
        database.insert(progTermList);
        
        //Create Application Test Record
        List<Application__c> applicationList = new List<Application__c>();
        Application__c application1 = new Application__c(
            Name = 'Unit Test Application',
            Status__c = 'Accepted',
            Designation__c = 'Primary',
            Applicant__c = ctc.id,
            Program_Term__c = progTermList[0].id,
            Approval_Override__c = true
        );
        applicationList.add(application1);
        Application__c application2 = new Application__c(
            Name = 'Unit Test Application',
            Status__c = 'Accepted (with Conditions)',
            Designation__c = 'Primary',
            Applicant__c = ctc.id,
            Program_Term__c = progTermList[0].id,
            Approval_Override__c = true
        );
        applicationList.add(application2);
        database.insert(applicationList);
        
        Application_Requirement__c appReq = apexMockDataUtility.createApplicationRequirement(progTermList[0].Id);
        
        Application_Item__c appItem = apexMockDataUtility.createApplicationItem(applicationList[0].id); 
        appItem.Application_Requirement__c = appReq.id;
        update appItem;
        
        formBuilderComponentController.Form formWrap = new formBuilderComponentController.Form();
        Id cifRecordTypeId = Schema.SObjectType.Dynamic_Form__c.getRecordTypeInfosByName().get('CIF').getRecordTypeId();

        formWrap = formBuilderComponentController.initForm(null, cifRecordTypeId);
        String jsonWrapper = JSON.serialize(formWrap, true);
        String formId = formBuilderComponentController.submitForm(jsonWrapper, 4, 4, 'testForm', true);
        
        
        Dynamic_Form__c df = [SELECT Id,JSON__c From Dynamic_Form__c WHERE Name = 'testForm' Limit 1];
        df.JSON__c = jsonWrapper;
        update df;

        
        Application_Requirement__c appReq1 = [SELECT id, Dynamic_Form__c From Application_Requirement__c];
        appReq1.Dynamic_Form__c = df.id;
        update appReq1;  
        
    }
    
    @isTest
    public static void test1(){
        Application_Item__c appItem1 = [SELECT Id,Application__c,Application_Requirement__c,Application_Requirement__r.Dynamic_Form__c, Status__c FROM Application_Item__c LIMIT 1];
        
        System.debug('appItem1 '+ appItem1.Application_Requirement__r.Dynamic_Form__c);
        dynamicFormViewModel dfvm = new dynamicFormViewModel(appItem1);
    }
}