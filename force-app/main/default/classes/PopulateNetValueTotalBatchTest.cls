@isTest(seealldata = false)
public class PopulateNetValueTotalBatchTest{
    static testmethod void myUnitTest(){
    
        Account acc = new Account();
        acc.name ='test -acc';
        acc.BillingState = 'OH';
        acc.c2g__CODAAccountTradingCurrency__c = 'USD';
        insert acc;
        
        contact con = new contact();
        con.lastname = 'clName';
        con.accountId = acc.Id;
        insert con;
        
        Application__c app = new Application__c();
        app.name = 'apName';
        app.Applicant__c = con.id;
        insert app;
        
        List<Application__c> prjList = new List<Application__c >{app};
        // Create an instance of query locator
        Database.QueryLocator QL;
        // Create an instance of batchable context
        Database.BatchableContext BC;
        PopulateNetValueTotalBatch  be = new PopulateNetValueTotalBatch ();
        QL = be.start(bc);
        Database.QueryLocatorIterator QLI =  QL.iterator();
        be.execute(BC, prjList); 
        be.finish(BC);      
   }
 }