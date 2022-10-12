@isTest
public class model_billingArrangementTest
{
    @testSetup
    public static void testdata(){
        //BaseTriggerHandler.bypass('billingArrangementTriggerHandler');
        World__c world = new World__c(Name = 'Global');
        database.insert(world);
        
        Region__c international = new Region__c(Name = 'International Support', World__c = world.Id);
        Region__c local = new Region__c(Name = 'Local Support', World__c = world.Id);
        database.insert(new List<Region__c>{international, local});
        
        Country__c usa = apexMockDataUtility.createLocalCountry(local.Id);
        Country__c country = apexMockDataUtility.createCountry(international.Id);
        Host_Institution__c hc= apexMockDataUtility.createHostInstitution(country.Id);
        List<String> names = new List<String>{'Test 1', 'Test 2', 'Undecided'};
            User academicAffiarsUser = apexMockDataUtility.CreateSysAdmin();
        
        List<Program__c> programs = apexMockDataUtility.createPrograms(hc, names, academicAffiarsUser.Id);
        List<Account> accounts = apexMockDataUtility.createAccounts('Test', 2);
        
        List<Billing_Arrangement__c> billingArrangements = apexMockDataUtility.createBillingArrangements(programs, accounts);
    }
    
    
    @isTest
    public static void testmodelbillingArrangementdataset(){
        Billing_Arrangement__c ba=[Select Id,Status__c,Name,Account__c,Program__c,Program__r.Name,Term__c,Discount_Amount__c,Discount_Recipient__c,Direct_Bill__c,
                                   Pays_Accomodation__c,Pays_Deposit__c,Pays_Late_Withdraw_Fees__c,Pays_Supplemental_Accommodation_Fees__c,Pays_Supplemental_Tuition_Fees__c,
                                   Pays_Tuition__c from Billing_Arrangement__c limit 1];
        Test.StartTest();
        model_billingArrangement con1 = new model_billingArrangement(ba);
        Test.StopTest();
    }
    
    @isTest
    public static void testmodelbillingArrangementquery(){
        Billing_Arrangement__c ba=[Select Id,Status__c,Name,Account__c,Program__c,Program__r.Name,Term__c,Discount_Amount__c,Discount_Recipient__c,Direct_Bill__c,
                                   Pays_Accomodation__c,Pays_Deposit__c,Pays_Late_Withdraw_Fees__c,Pays_Supplemental_Accommodation_Fees__c,Pays_Supplemental_Tuition_Fees__c,
                                   Pays_Tuition__c from Billing_Arrangement__c limit 1];
        Test.StartTest();
        model_billingArrangement con1 = new model_billingArrangement(ba.id);
        Test.StopTest();
    }
    
    @isTest
    public static void testconvertFromJsonToList(){
        Test.StartTest();
        List<model_billingArrangement> mbaList = model_billingArrangement.convertFromJsonToList('[{"name":"John"}]');
        Test.StopTest();
        System.assert(!mbaList.isEmpty());
    }
    
    @isTest
    public static void testconvertFromJson(){
        Test.StartTest();
        model_billingArrangement mba = model_billingArrangement.convertFromJson('{"name":"John"}');
        Test.StopTest();
        System.assert(mba != null);
    }
    
    @isTest
    public static void testequalstrue(){
        Test.StartTest();
        model_billingArrangement con1 = new model_billingArrangement();
        boolean equalcheck = con1.equals(con1);
        Test.StopTest();
        System.assert(equalcheck);
    }
    
    @isTest
    public static void testequalsfalse(){
        Test.StartTest();
        Case cs = new Case();
        model_billingArrangement con1 = new model_billingArrangement();
        boolean equalcheck = con1.equals(cs);
        Test.StopTest();
        System.assert(!equalcheck);
    }
    
    @isTest
    public static void testsave(){
        Billing_Arrangement__c ba=[Select Id,Status__c,Name,Added_Sections__c ,Account__c,Program__c,Program__r.Name,Term__c,Discount_Amount__c,Discount_Recipient__c,Direct_Bill__c,
                                   Pays_Accomodation__c,Pays_Deposit__c,Pays_Late_Withdraw_Fees__c,Pays_Supplemental_Accommodation_Fees__c,Pays_Supplemental_Tuition_Fees__c,
                                   Pays_Tuition__c from Billing_Arrangement__c limit 1];
        Test.StartTest();
        model_billingArrangement con1 = new model_billingArrangement(ba.id);
        con1.save();
        Test.StopTest();
    }
    
}