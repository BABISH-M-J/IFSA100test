@isTest(seeAllData=true)
public class SchoolSummaryCtrlSecTest{
    
    public static testMethod void methodOne(){
    
        String accId = '';
        try
        {
            for(c2g__codaTransactionLineItem__c line : [SELECT Id, Application__c, Application__r.Program_Term_Year__c,
                                                    Application__r.Program_Term_Section__c, Application__r.Home_Institution_Account__c 
                                                    FROM c2g__codaTransactionLineItem__c WHERE 
                                                    Application__r.Home_Institution_Account__c != null And  
                                                    Application__r.Program_Term_Year__c=:'2018' AND
                                                    Application__r.Program_Term_Section__c =:'Fall'
                                                    And Responsible_Party__c =:'School' limit 1]) {
            
            accId = line.Application__r.Home_Institution_Account__c;                                                   
            }
            
            Account acc = [select id from account where id=:accId ];
            
            ApexPages.StandardController ctr = new ApexPages.StandardController(acc);
            Schoolsummaryctrl schObj = new Schoolsummaryctrl(ctr);
            schObj.getTermSection();
            schObj.getTermYear();
            schObj.selectedSection = 'Fall';
            schObj.selectedYear = '2018';
            schObj.searchApplication();
            schObj.viewInvoice();
            schObj.viewIndividualInvoice();    
        }
        catch (QueryException e)
        {
            if(!e.getMessage().contains('List has no rows for assignment to SObject'))
            {
                throw e;
            }
            else
            {
                system.debug('This test method will not pass in Sanboxes without c2g__codaTransactionLineItem__c data');
            }
        }   
    }
    
    public static testMethod void methodSecond(){
        TransactionComponentctrl tc = new TransactionComponentctrl();
        tc.AllGroupDataList = new List<TransLinesWrapper>(); 
        tc.BillingContactList = new List<Contact>();
    }
    
    public static testMethod void methodThird(){
        String accId = '';
        String appId = '';
        try
        {
            for(c2g__codaTransactionLineItem__c line : [SELECT Id, Application__c, Application__r.Program_Term_Year__c,
                                                        Application__r.Program_Term_Section__c, Application__r.Home_Institution_Account__c 
                                                        FROM c2g__codaTransactionLineItem__c WHERE 
                                                        Application__r.Home_Institution_Account__c != null And  
                                                        Application__r.Program_Term_Year__c=:'2018' AND
                                                        Application__r.Program_Term_Section__c =: 'Fall'
                                                        And Responsible_Party__c =:'School' limit 1]) {
                
                accId = line.Application__r.Home_Institution_Account__c; 
                appId = line.Application__c;                                                  
            }
            Account acc = [select id from account where id=:accId ];
            
            
            ApexPages.currentPage().getParameters().put('appid',appId );
            ApexPages.currentPage().getParameters().put('selectedSection','Fall');
            ApexPages.currentPage().getParameters().put('selectedYear','2018');
            
            ApexPages.StandardController ctr = new ApexPages.StandardController(acc);
            viewSummaryPdf summObj = new viewSummaryPdf(ctr);
        }
        catch (QueryException e)
        {
            if(!e.getMessage().contains('List has no rows for assignment to SObject'))
            {
                throw e;
            }
            else
            {
                system.debug('This test method will not pass in Sanboxes without c2g__codaTransactionLineItem__c data');
            }
        }
    }
}