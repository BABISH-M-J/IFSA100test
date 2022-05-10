/**************************************************************************************
    @Name         :         callbackController
    @Author       :         Astrea
    @Description  :         To get response from CashNet and save the cash entry record
**************************************************************************************/
//class...
public class callbackController{
    public Map<String, String> sMap {get; set;}
    public boolean showerror {get; set;}
    public boolean showsuccess {get;set;}
    List<c2g__codaCashEntry__c> cashEntryList = new  List<c2g__codaCashEntry__c>();
    List<Account> acc = new List<Account>();
    public Id conId    {get; set;}
    public set<Id> appIdset = new set<Id>();
    public set<Id> prgmIdset = new set<Id>();
    List<contact> con = new List<contact>();
    public List<Application__c> appList {get;set;}
    public List<Program_Offered__c> prgmList{get;set;}
    public List<Product2> prd{get;set;}
    List<c2g__codaCashEntryLineItem__c> cshEntrylinItemList = new List<c2g__codaCashEntryLineItem__c>();
    //constructor...
    public callbackController(){
        User u = [SELECT Id, ContactId FROM User WHERE id=:userInfo.getUserId() limit 1];
        system.debug('userId' +u.id);
        con = [SELECT Id, Name, FirstName , LastName, Phone, Email, MailingCity, MailingCountry, MailingStreet, MailingState
              ,MailingPostalCode from Contact WHERE Id =: u.contactId];
         system.debug('con' +con );
              
        acc = [SELECT Id FROM account LIMIT 1];
        system.debug('con' +con );
        if(con.size () > 0)
         appList = [SELECT Id, Name, Personal_Interests__c, Program_Offered__c FROM Application__c WHERE Applicant__c =:con[0].Id ]; 
        system.debug('appList ' +appList );
        if(appList.size() > 0){
            for(Application__c  ap : appList ){
                appIdset.add(ap.id);
            }
        }
        
        if(appIdset.size() > 0)
            prgmList = [SELECT Id, Product__c FROM Program_Offered__c WHERE ID =:appList[0].Program_Offered__c];
            system.debug('prgmList ' +prgmList );
       /* If(prgmList.size() > 0 ){
            for(Program_Offered__c pg : prgmList){
                prgmIdset.add(pg.Product__c);
            }
        }
        system.debug('prgmIdset'+prgmIdset);
        
        if(prgmIdset.size() > 0){
            prd = [SELECT Id FROM Product2 WHERE ID in: prgmIdset];
        }
        system.debug('prd '+prd);*/
        
        showerror = false;
        showsuccess = true;
        sMap = apexPages.currentPage().getParameters();
      //  String conId = apexPages.currentPage().getParameters('PARENT RECORD ID');
        List<String> s1 = new List<String>();
        for(String  s : sMap.KeySet()){
            System.debug('################################===============>'+s);
            String s2 = '';
            s2 = sMap.get(s);
            if(s2.contains('Customer Cancelled before processing payment')){
                showerror = true; 
                showsuccess = false;
            }
        }
    }
    
    public void createCashEntry(){
        List<c2g__codaAccountingCurrency__c> acurr = new List<c2g__codaAccountingCurrency__c>();
        acurr = [SELECT Id , name FROM c2g__codaAccountingCurrency__c where name = 'USD' limit 1];
        List<c2g__codaBankAccount__c> bkacct = new List<c2g__codaBankAccount__c>();
        bkacct = [SELECT Id FROM c2g__codaBankAccount__c WHERE c2g__BankAccountCurrency__c =:acurr[0].id LIMIT 1];
        List<c2g__codaPeriod__c> period = new List<c2g__codaPeriod__c>();
        period = [SELECT Id FROM c2g__codaPeriod__c LIMIT 1];
        // If payment success then create a cash entry record
        system.debug('--------------------'+showsuccess );
        if(showsuccess == true){
        system.debug('---------------'+con[0].id);
        system.debug('---------------'+bkacct[0].id);
        system.debug('---------------'+acurr[0].id);
        system.debug('---------------'+period[0].id);
                c2g__codaCashEntry__c c = new c2g__codaCashEntry__c();
                c.c2g__Date__c = date.today();
                c.Contact__c = con[0].id;
                c.c2g__BankAccount__c = bkacct[0].id;
                c.c2g__Type__c = 'Receipt';
                c.c2g__PaymentMethod__c = 'Cash';
                c.c2g__CashEntryCurrency__c = acurr[0].id;
                c.c2g__Status__c = 'In Progress';
                c.c2g__Value__c = 0.01;
                c.c2g__Period__c = period[0].id;
                c.c2g__ChargesAmount__c = 0.00;
                c.c2g__TotalCharges__c = 0.00;
                cashEntryList.add(c); 
                
               /* c2g__codaCashEntryLineItem__c cl = new c2g__codaCashEntryLineItem__c();
                cl.c2g__Account__c = acc[0].id;
                cl.c2g__CashEntryValue__c = 100;
                cl.Product__c = prd [0].id;
                cshEntrylinItemList.add(cl);*/
        }
        
        if(cashEntryList.size() > 0)
          insert cashEntryList;
        //if(cshEntrylinItemList.size() > 0)
         //  insert cshEntrylinItemList;
    }
}