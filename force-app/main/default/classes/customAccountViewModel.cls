/**
 * Viewmodel for <<customAccountController>>
 * THE CUSTOM PORTAL IS POWERD BY THE CATALOG STUDENT PORTAL SO THAT EFFORTS ARE NOT DUPLICATED AS OF SUMMER 2020.
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class customAccountViewModel  extends customBaseViewModel
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

    public customAccountViewModel()
    {
        showDepositMessage = false;
    }
}