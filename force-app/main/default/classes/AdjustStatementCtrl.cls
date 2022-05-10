/**
    Adjust the Values for Transaction Line Items. Only those Transaction line Items display satisfies the following Criteria
               1. Account is equals to the where the Button is clicked.
               2. Transaction Type of transaction is CASH and NOT ANALYSIS
                  OR
                  Transaction Type of Transaction NOT equals to CASH And general Ledge Account Not start with 1110 AND 2099.
    Created Date - 4/16/2017
**/
// ApexDoc updated 1/22/2021 Brock Barlow
public class AdjustStatementCtrl{
    /**
     * List of Transaction Line Items
     */
    public list<c2g__codaTransactionLineItem__c> translist{get;set;}
    /**
     * The active account
     */
    public Account acc{get;set;}
    static final String CASH = 'Cash';
    static final String ANALYSIS = 'Analysis';
    
    /**
     * Controller constructor
     * @param stdController
     */
    public AdjustStatementCtrl(ApexPages.StandardController stdController){
        acc= (Account)stdController.getRecord();
    }
    
    /**
     * Gets Transaction line item records for the account
     * @return List<c2g__codaTransactionLineItem__c>
     */
    public List<c2g__codaTransactionLineItem__c> getTransline(){
        //translist will contain the details of Transaction Line Items
        translist= new List<c2g__codaTransactionLineItem__c>(); 
        translist= [select c2g__Transaction__r.c2g__DocumentNumber__c, c2g__Transaction__r.c2g__TransactionDate__c,c2g__HomeValue__c,
                    Description__c, name, Reference__c ,Responsible_Party__c, c2g__LineDescription__c, Application__c,Amount__c
                    from c2g__codaTransactionLineItem__c where c2g__Account__c =:acc.id 
                    AND ( (c2g__Transaction__r.c2g__TransactionType__c =:CASH AND c2g__LineType__c !=:ANALYSIS  )  
                    OR (c2g__Transaction__r.c2g__TransactionType__c !=:CASH AND((NOT c2g__GeneralLedgerAccount__r.name like '1110%') 
                    AND (NOT c2g__GeneralLedgerAccount__r.name like '2099%') )))
                    order by c2g__Transaction__r.c2g__TransactionDate__c , c2g__Transaction__r.c2g__DocumentNumber__c  ];                        
        return translist;
    }
 
    /**
        Update the Transaction Line Items chnaged by the user from the UI.
        @Param - None
        @Return Type - PageReference - If there is any error then display the error Otherwise 
                                       return to the Associated Account from where the screen opens.
    **/
    public PageReference save(){
        try{
            upsert translist;
        }
        catch(Exception ex){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,''+ex.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        } 
        PageReference pr = new PageReference('/'+acc.id);
        pr.setRedirect(true);
        return pr;
    } 
    
    /**
     * Returns user back to the account record
     */
    public PageReference cancel(){
        PageReference pr = new PageReference('/'+acc.id);
        pr.setRedirect(true);
        return pr;
    }   
}