/**
* Test class for ifsaLineItemPopulator
*/
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public without sharing class ifsaLineItemPopulatorTest
{
    @TestSetup
    static void makeData(){
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
        
        //Create Butler Department Cose Test Record
        Butler_Department_Code__c buCode = apexMockDataUtility.createBUDepartmentCode();
        
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
        
        //Create Host Course record
        Course__c hostcour = apexMockDataUtility.createHostCourse(hostIns.id,buCode);
        
        //Create Home Course record
        List<Course__c> Homecour = new List<Course__c>();
        for(integer i =0 ; i<5 ;i++){
            Course__c currHomeCurr = new Course__c();
            currHomeCurr.RecordTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId();
            currHomeCurr.Name = 'Test Course' + i;
            currHomeCurr.Course_Code__c = 'ASDF';
            currHomeCurr.Course_Title_2__c = 'Title'+ i;
            currHomeCurr.Host_Institution__c = hostIns.id;
            currHomeCurr.Home_Institution_Account__c = acct.id;
            currHomeCurr.US_Terms__c = 'Spring;Fall;Summer';
            if(i == 0){
                currHomeCurr.Year_in_Degree_Plan__c = '1 of 3';
            }else{
                currHomeCurr.Year_in_Degree_Plan__c = i+' of 4';
            }
            Homecour.add(currHomeCurr);
        }
        Database.insert(Homecour);
        
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
        
        //Create Application Line Item Test Record
        List<Application_Line_Item__c> appLineItemList = new List<Application_Line_Item__c>();
        Application_Line_Item__c applicationItem = new Application_Line_Item__c(
            Name = 'Non-Refundable Advance Deposit',
            Application__c = applicationList[0].id,
            Charge__c = 5,
            Responsible_Party__c = 'School'
        );
        appLineItemList.add(applicationItem);
        database.insert(appLineItemList);
        
        //Create Product Test Record
        List<Product2> prodList = new List<Product2>();
        prodList.add(new Product2(ProductCode = 'PRG', Name = 'Program Grant', IsActive = true));
        prodList.add(new Product2(ProductCode = 'ADV', Name = 'Non-Refundable Deposit', IsActive = true));
        prodList.add(new Product2(ProductCode = 'GSC', Name = 'Guaranteed Scholarship', IsActive = true));
        database.insert(prodList);
        
        //Create Program Fee Test Record
        List<Program_Fee__c> progfeeList = new List<Program_Fee__c>();
        progfeeList.add(new Program_Fee__c(Name = 'Tuition', Amount__c = 18000, Direct_Bill_Category__c = 'Tuition', Product__c = prodList[0].Id, Program_Term__c = progTermList[0].id));
        progfeeList.add(new Program_Fee__c(Name = 'Guaranteed Scholarship', Amount__c = 18000, Direct_Bill_Category__c = 'Accommodation', Product__c = prodList[0].Id, Program_Term__c = progTermList[0].id));
        progfeeList.add(new Program_Fee__c(Name = 'Guaranteed Scholarship', Amount__c = 18000, Direct_Bill_Category__c = 'Non-Refundable Deposit', Product__c = prodList[0].Id, Program_Term__c = progTermList[0].id));
        progfeeList.add(new Program_Fee__c(Name = 'Guaranteed Scholarship', Amount__c = 18000, Direct_Bill_Category__c = 'Supplemental', Product__c = prodList[0].Id, Program_Term__c = progTermList[0].id));
        database.insert(progfeeList);
        
        
        List<Account> homeaccountlist = new List<Account>();
        homeaccountlist.add(acct);
        List<Program__c> progList = new List<Program__c>();
        progList.add(prog);
        
        //Create Billing Arrangement Test Record
        List<Billing_Arrangement__c> billingArrangements = apexMockDataUtility.createBillingArrangements(progList,homeaccountlist);
        
        //Create Code Dimension Test Record
        c2g__codaDimension1__c c2gCodeDim = new c2g__codaDimension1__c(Name = 'Indianapolis, Administration', c2g__ReportingCode__c = 'INDY');
        insert c2gCodeDim;
        
        //Update Existing Applicaton Record Term Test Record
        List<Application__c> applicationListUpdate = [SELECT Id, Home_Institution_Account__c FROM Application__c ];
        for(Application__c currRec : applicationListUpdate){
            currRec.Home_Institution_Account__c = acct.id;
        }
        update applicationListUpdate;
    }
    
    @isTest
    public static void testPopulateLineItemsWithBillAgr(){
        //Query Program Term With/Without Appliaction
        List<Program_Term__c> programtermlist = [Select id from Program_Term__c];
        List<Id> progtermIds = new List<Id>();
        for(Program_Term__c currRec : programtermlist){
            progtermIds.add(currRec.id);
        }
        
        test.startTest();
        String result = ifsaLineItemPopulator.populateApplicationLineItems(progtermIds);
        test.stopTest();
        System.assert(String.isNotBlank(result));
    }
    
    @isTest
    public static void testPopulateLineItemsWitgMultipleProgramTerm(){
        //Query Program Term With no Appliaction
        List<Program_Term__c> programtermlist = [Select id,Name, Department__c from Program_Term__c Where Department__c != 'Test0'];
        List<Id> progtermIds = new List<Id>();
        for(Program_Term__c currRec : programtermlist){
            progtermIds.add(currRec.id);
        }
        
        test.startTest();
        String result = ifsaLineItemPopulator.populateApplicationLineItems(progtermIds);
        test.stopTest();
        System.assert(String.isNotBlank(result));
    }
    
    @isTest
    public static void testPopulateLineItemsWithOneProgramTerm(){
        //Query Program Term With no Appliaction
        List<Program_Term__c> programtermlist = [Select id,Name, Department__c from Program_Term__c Where Department__c =: 'Test1'];
        List<Id> progtermIds = new List<Id>();
        for(Program_Term__c currRec : programtermlist){
            progtermIds.add(currRec.id);
        }
        
        test.startTest();
        String result = ifsaLineItemPopulator.populateApplicationLineItems(progtermIds);
        test.stopTest();
        System.assert(String.isNotBlank(result));
    }
    
    @isTest
    public static void testpopulateApplicationLineItemsWithMultipleApplicationProgFee(){
        //Query Contact from existing 
        List<Contact> con = [Select id From Contact];
        List<Product2> productList = [Select id from Product2 where ProductCode =: 'PRG'];
        //Query Program Term With no Appliaction
        List<Program_Term__c> programtermlist = [Select id,Name, Department__c from Program_Term__c Where Department__c =: 'Test1'];
        
        List<Id> progtermIds = new List<Id>();
        for(Program_Term__c currRec : programtermlist){
            progtermIds.add(currRec.id);
        }
        
        //Creating Application for above Program Term Record
        List<Application__c> applicationList = new List<Application__c>();
        Application__c application1 = new Application__c(
            Name = 'Unit Test Application',
            Status__c = 'Accepted',
            Designation__c = 'Primary',
            Applicant__c = con[0].id,
            Program_Term__c = programtermlist[0].id,
            Approval_Override__c = true
        );
        applicationList.add(application1);
        Application__c application2 = new Application__c(
            Name = 'Unit Test Application',
            Status__c = 'Accepted (with Conditions)',
            Designation__c = 'Primary',
            Applicant__c = con[0].id,
            Program_Term__c = programtermlist[0].id,
            Approval_Override__c = true
        );
        applicationList.add(application2);
        database.insert(applicationList);
        
        //Creating Program fee for above Program Term Record
        List<Program_Fee__c> progfeeList = new List<Program_Fee__c>();
        progfeeList.add(new Program_Fee__c(Name = 'Tuition', Amount__c = 18000, Direct_Bill_Category__c = 'Tuition', Product__c = productList[0].Id, Program_Term__c = programtermlist[0].id));
        progfeeList.add(new Program_Fee__c(Name = 'Guaranteed Scholarship', Amount__c = 18000, Direct_Bill_Category__c = 'Tuition', Product__c = productList[0].Id, Program_Term__c = programtermlist[0].id));
        database.insert(progfeeList);
        
        test.startTest();
        String result = ifsaLineItemPopulator.populateApplicationLineItems(progtermIds);
        test.stopTest();
        System.assert(String.isNotBlank(result));
    }
    
    @isTest
    public static void testpopulateApplicationLineItemsWithOneApplication(){
        //Query Contact from existing 
        List<Contact> con = [Select id From Contact];
        //Query Program Term With no Appliaction
        List<Program_Term__c> programtermlist = [Select id,Name, Department__c from Program_Term__c Where Department__c =: 'Test1'];
        List<Id> progtermIds = new List<Id>();
        for(Program_Term__c currRec : programtermlist){
            progtermIds.add(currRec.id);
        }
        
        //Creating One Application for above Program Term Record
        List<Application__c> applicationList = new List<Application__c>();
        Application__c application1 = new Application__c(
            Name = 'Unit Test Application',
            Status__c = 'Accepted',
            Designation__c = 'Primary',
            Applicant__c = con[0].id,
            Program_Term__c = programtermlist[0].id,
            Approval_Override__c = true
        );
        applicationList.add(application1);
        database.insert(applicationList);
        
        test.startTest();
        String result = ifsaLineItemPopulator.populateApplicationLineItems(progtermIds);
        test.stopTest();
        System.assert(String.isNotBlank(result));
    }
    
    @isTest
    public static void testpopulateApplications(){
        List<Application__c> applist = [Select id from Application__c];
        List<Id> applistId = new List<Id>();
        for(Application__c currRec : applist){
            applistId.add(currRec.id);
        }
        
        test.startTest();
        ifsaLineItemPopulator.populateApplications(applistId);
        test.stopTest();
    }
    
}