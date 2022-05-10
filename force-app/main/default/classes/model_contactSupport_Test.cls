@isTest
public class model_contactSupport_Test {

    @testSetup
    public static void mockData(){
        //Create test account
        Account acct = apexMockDataUtility.createAccount('TestAcct');
        
        //Create test contact
        Contact ctc = apexMockDataUtility.createContact('TestCtc', acct.Id);
        
        //Create test user
        User u= apexMockDataUtility.createUser(ctc.id);
        insert u;
        
        Support_Personnel__c sp = new Support_Personnel__c();
        sp.Support_Role_Type__c = 'Academic Records Coordinator Administration';
		sp.Type__c = 'IFSA Staff';
        sp.IFSA_Staff__c = u.id;
        insert sp;
        
        Contact_Support_Personnel__c csp = apexMockDataUtility.createContactSupport(ctc,sp);
        insert csp;
    }
    
    @isTest
    public static void testmodel_contactSupport(){
        List<Contact_Support_Personnel__c> cspList = [Select id, Support_Personnel__r.Non_IFSA_Staff__c, Name, Contact__c, Contact__r.Name, Support_Personnel__r.Home_Institution__c, 
												Contact__r.Home_Institution__r.Name, Support_Personnel__r.Host_Institution__c, Support_Personnel__r.Account__r.Name, Support_Personnel__r.Program__c,
                                                Support_Personnel__r.Program_Term__c, Support_Personnel__r.Program_Option__c, Support_Personnel__r.SP_Plain_Text_Name__c, Support_Personnel__r.Non_IFSA_Staff__r.Phone,
												Support_Personnel__r.Non_IFSA_Staff__r.Email, Support_Personnel__r.Support_Role_Type__c, Support_Personnel__r.Emergency_Contact__c FROM Contact_Support_Personnel__c];
        test.startTest();
        model_contactSupport mcs = new model_contactSupport(cspList[0]);
        test.stopTest();
        System.debug('mcs + '+mcs.name);
    }
    
    @isTest
    public static void testmodel_contactSupportequalsPositive(){
        test.startTest();
        model_contactSupport mcs = new model_contactSupport();
        Boolean b = mcs.equals(mcs);
        test.stopTest();
        System.assert(b);
    }
    
    @isTest
    public static void testmodel_contactSupportequalsNegative(){
        List<Contact_Support_Personnel__c> cspList = [Select id, Support_Personnel__r.Non_IFSA_Staff__c, Name, Contact__c, Contact__r.Name, Support_Personnel__r.Home_Institution__c, 
												Contact__r.Home_Institution__r.Name, Support_Personnel__r.Host_Institution__c, Support_Personnel__r.Account__r.Name, Support_Personnel__r.Program__c,
                                                Support_Personnel__r.Program_Term__c, Support_Personnel__r.Program_Option__c, Support_Personnel__r.SP_Plain_Text_Name__c, Support_Personnel__r.Non_IFSA_Staff__r.Phone,
												Support_Personnel__r.Non_IFSA_Staff__r.Email, Support_Personnel__r.Support_Role_Type__c, Support_Personnel__r.Emergency_Contact__c FROM Contact_Support_Personnel__c];
        test.startTest();
        model_contactSupport mcs = new model_contactSupport();
        Boolean b = mcs.equals(cspList[0]);
        test.stopTest();
        System.assert(!(b));
    }
}