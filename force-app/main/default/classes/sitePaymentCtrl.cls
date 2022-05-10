/* ***************************************************
    Name         : sitePaymentCtrl
    Description  : This Apex Class is used to create Cash Entry Staging and Cash Entry Lines records in Salesforce from CashNet Server.
    Author       : Nida, Salesforce Developer, Astrea IT Services
    Created Date : 31 Oct,2015
    Modified On  : 2 Dec,2015
*************************************************** */

public class sitePaymentCtrl{
    Public Map<String, String> pMap {get; set;}   //Map for getting all parameter values from the cashnet server
    List<Cash_Entry_Staging__c> cashEntryList = new  List<Cash_Entry_Staging__c>();
    List<Cash_Entry_Staging_Lines__c > cshEntrylinItemList = new List<Cash_Entry_Staging_Lines__c >();
    List<contact> con = new List<contact>();
    Public boolean showerror {get; set;}
    Public boolean showsuccess {get;set;}
    
    public sitePaymentCtrl() {
        showerror = false;
        pMap = apexPages.currentPage().getParameters();
        for(String  s : pMap.KeySet()){
            String s2 = '';
            s2 = pMap.get(s);
            if(s2.contains('Customer Cancelled before processing payment')){
                showerror = true; 
                showsuccess = false;
            }
        }
    }
    
    /** Method to create cash entry records ******/
    public void createCashEntry(){
        
        String payerName = (pmap.get('NAME_G') != null) ? pmap.get('NAME_G').trim() : NULL;
        String conName = (pmap.get('SNAME') != null) ? pmap.get('SNAME').trim() : NULL;
        
        String contactID = (pmap.get('PARENT RECORD ID') != null) ? String.ValueOf(pmap.get('PARENT RECORD ID')).trim() : NULL;
        
        List<User> userList;
        if( contactID != null && conName != null ) {
            userList = [SELECT Id, ContactId FROM User WHERE ContactId=:contactID ];
            if( userList.size() > 0 ) {
                User u = userList[0];
                if(u.contactId !=null) {
                
                    con = [SELECT Id, AccountId,Name, FirstName,Active_Application__c,Active_Application__r.name,
                           LastName,Account.Name, Phone, Email, MailingCity, MailingCountry, MailingStreet, MailingState,
                           MailingPostalCode FROM Contact WHERE Id =:u.contactId]; 
                    
                    if( con.size() > 0 ) {
                        Savepoint sp = Database.setSavepoint();
                        try {
                            //Creation of Cash Entry Staging Records 
                            Cash_Entry_Staging__c ce = new Cash_Entry_Staging__c();
                            ce.Applicant__c = u.contactId; 
                            ce.Household_ID__c = String.ValueOf(pMap.get('batchno'));
                            ce.Reference__c = String.ValueOf(pMap.get('PARENT RECORD ID')); 
                            ce.SFDCAccountid__c = con[0].accountId !=null ? con[0].accountId : NULL;
                            ce.Trade_Date__c = Date.today(); 
                            cashEntryList.add(ce); 
                            insert cashEntryList;
                               
                            //Creation of Cash Entry Staging Lines Records
                            Cash_Entry_Staging_Lines__c cle = new Cash_Entry_Staging_Lines__c();
                            cle.Account__c = con[0].accountId !=null ? con[0].accountId : NULL;
                            cle.Activity_ID__c = '101';           
                            cle.Amount__c = pMap.get('amount1') != null ? decimal.valueOf(pMap.get('amount1')) : 0; 
                            cle.Cash_Entry_Staging__c = cashEntryList[0].id;
                            cle.Debit_Account_Name_Detail__c = con[0].Account.name !=null ? con[0].Account.name : '' ;
                            cle.Debit_Account_Number__c = con[0].Account.name ;
                            cle.Application__c = con[0].Active_Application__c;
                            cle.Payer__c = payerName;
                            cshEntrylinItemList.add(cle);
                            insert cshEntrylinItemList;
                                
                        }catch(Exception ex) {
                            Database.rollback(sp);
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));    
                        }
                    }
                                        
                }
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There are No User with this Name.'));    
            }
        }else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The parameter does not contains any Student Name.'));    
        }
    } // Method ends here
}