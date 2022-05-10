/**
* @description Viewmodel class used by the studentAccountController
* @author Brock Barlow
*/
public without sharing class studentAccountViewModel extends studentBaseViewModel
{
    public Decimal accountTotal {get;set;}
    public String paymentAmount {get;set;}
    public List<Cash_Entry_Staging__c> cashRecords {get;set;}
    public List<studentAccountAppViewModel> applicationList {get;set;}
    public List<c2g__codaCashEntry__c> cashEntries {get;set;}
    public List<c2g__codaTransactionLineItem__c> transactions {get;set;}
    public List<Application_Line_Item__c> applicationLineItems {get;set;}
    public String paymentProcessor {get;set;}
    public Boolean showDepositMessage {get;set;}
    public Date dueDate {get;set;}
    public String street {get;set;}
    public String city {get;set;}    
    public String state {get;set;}
    public String zipCode {get;set;}
    public String email {get;set;}

    public studentAccountViewModel()
    {
        showDepositMessage = false;
    }
}