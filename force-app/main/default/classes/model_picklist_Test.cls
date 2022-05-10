@isTest
public class model_picklist_Test {
    
    @testSetup
    public static void mockdata(){
        
    }
    
    @isTest
    public static void testmodelpicklist(){
        List<Schema.PicklistEntry> ple = Account.AccountSource.getDescribe().getPicklistValues();
        test.startTest();
        model_picklist mp = new model_picklist(ple[0]);
        test.stopTest();
        System.assertEquals(ple[0].getValue(),mp.apiName);
    }
    
    @isTest
    public static void testgetModelFromListPassCheck(){
        List<Schema.PicklistEntry> ple = Account.AccountSource.getDescribe().getPicklistValues();
        test.startTest();
        List<model_picklist> mpList = new List<model_picklist>();
        for(Schema.PicklistEntry item : ple){
            model_picklist mp = new model_picklist(ple[0]);
            mpList.add(mp);
        }
        System.debug('mpList '+mpList);
        model_picklist mp2 = model_picklist.getModelFromList(mpList,'Abroad101');
        test.stopTest();
        System.assert(mp2 != null);
    }
    
    @isTest
    public static void testgetModelFromListFailCheck(){
        List<Schema.PicklistEntry> ple = Account.AccountSource.getDescribe().getPicklistValues();
        test.startTest();
        List<model_picklist> mpList = new List<model_picklist>();
        for(Schema.PicklistEntry item : ple){
            model_picklist mp = new model_picklist(ple[0]);
            mpList.add(mp);
        }
        model_picklist mp2 = model_picklist.getModelFromList(mpList,'Tets');
        test.stopTest();
        System.assert(mp2 == null);
    }
    
    @isTest
    public static void testequalstrue(){
        test.startTest(); 
        model_picklist mp = new model_picklist();
        boolean check = mp.equals(mp);
        test.stopTest();
        System.assert(check);
    }
    
	@isTest
    public static void testequalsfalse(){
        Case cs = new Case();
        test.startTest(); 
        model_picklist mp = new model_picklist();
        boolean check = mp.equals(cs);
        test.stopTest();
        System.assert(!check);
    }
}