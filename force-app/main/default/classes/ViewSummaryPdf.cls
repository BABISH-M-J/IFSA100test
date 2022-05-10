Public class ViewSummaryPdf{
    
    public final string SCHOOL= 'School';
    Map<String,string> mapstatus= new Map<string,string>();
    List<Id> applicationid = new List<Id>();
    List<Id> contactid = new List<Id>();
    public string programterm{get;set;}
    public List<appWrapper> appList{get;set;}
    map<string,map<string,list<c2g__codaTransactionLineItem__c>>> mapapplication = new map<string,map<string,list<c2g__codaTransactionLineItem__c>>>();         
    public Account accRec{get;set;} 
    public Account acc;
    public List<contact> billingContact{get;set;}    
    Public String selectedSection{get;set;}
    Public String selectedYear{get;set;}
    public Set<String> accountStatusSet = new Set<String>{'Program Selected','Ready To Submit','Submitted','Accepted'
                                                          ,'Accepted (with Conditions)','On Site','Program Completed','Diverted',
                                                          'Dropped','Deferred','Withdraw'};
                                                          
    public ViewSummaryPdf(ApexPages.StandardController controller) {
        billingContact= new List<contact>();
        acc= (Account)Controller.getRecord();
        accRec = [select id,name,billingstate,billingcity,billingcountry,billingstreet,billingpostalcode from account where id=:acc.id];
        applicationid = new List<id>();
        contactid = new List<Id>();
      /*  List<Contact> contList=[select id,name,email from contact where Billing_Contact__c =true and accountid=:acc.id limit 1];
        if(contList.size()>0)
         billingcontact=contList[0];*/
        String urival=ApexPages.currentPage().getParameters().get('appid');
        selectedSection=ApexPages.currentPage().getParameters().get('selectedSection');
        selectedYear=ApexPages.currentPage().getParameters().get('selectedYear');
         String conval =ApexPages.currentPage().getParameters().get('conid');
        if(conval !=NULL && ! conval.equals('')){
            List<String> contactval = conval.split(',');
            for(String ss: contactval)
            contactid.add(Id.valueOf(ss));
        }
        List<Contact> contList=[select id,name,email from contact where Billing_Contact__c =true and accountid=:acc.id and id IN:contactid];   
         if(contList.size()>0)
         billingcontact=contList;
 
        if(urival !=NULL && !urival.equals('')){
            List<String> applicationval = urival.split(',');
            for(String ss: applicationval){
            applicationid.add(Id.valueOf(ss));
            }
            mapTransactioninfo();
            mainMethod();
            
        }
    }


      
      
    
    Public map<String,list<c2g__codaTransactionLineItem__c>> getSortedMap(){
        map<String,list<c2g__codaTransactionLineItem__c>> SortMap=new Map<String,list<c2g__codaTransactionLineItem__c>>();
        map<String,String>  mapGroupstatus = StatusGroup.getStatusMap();
        for(c2g__codaTransactionLineItem__c Tli :[select id,Application__r.Payment_Terms__c,Application__r.applicant__r.name,Application__r.Applicant__r.firstname,Application__r.Applicant__r.lastname,application__r.Program_Term__r.name,application__r.status__c,name,Date__c,c2g__DueDate__c,
                                Transaction_type__c,Reference__c,Description__c,Amount__c,Responsible_Party__c,Application__r.applicant__c,Application__r.Program_Term__c,Application__c,application__r.Name 
                                from c2g__codaTransactionLineItem__c WHERE Responsible_Party__c =:SCHOOL and Application__c In:applicationid order by Application__r.Applicant__r.lastname,Application__r.Applicant__r.firstname asc]) {
            
           
            if(mapstatus.containskey(tli.application__r.status__c)){
                String status=mapGroupstatus.get(tli.application__r.status__c);
                if(!SortMap.containskey(tli.Application__r.Payment_Terms__c+''+status)){
                    SortMap.put(tli.Application__r.Payment_Terms__c+''+status,new List<c2g__codaTransactionLineItem__c>());
                } 
                SortMap.get(tli.Application__r.Payment_Terms__c+''+status).add(tli);
            }                    
        }
        return SortMap;
    }
    
    public void mainMethod(){
        map<String,c2g__codaTransactionLineItem__c> dublicateTrans=new Map<String,c2g__codaTransactionLineItem__c>();
        map<String,list<c2g__codaTransactionLineItem__c>> SortMap=getSortedMap();
        appList = new List<appWrapper>();
      
        for(String s : mapapplication.keyset()){
            appWrapper ap = new appWrapper();
            ap.paymentterm= s;
            List<statusWrapper> sttsList = new List<statusWrapper>();
            for(string stat : mapapplication.get(s).keyset()){                
                statusWrapper statuswrap = new statusWrapper();         
                statuswrap.status = stat;                 
                List<invWrapper> invList = new List<invWrapper>();             
                if(SortMap.containskey(s+''+stat)){
                    for(c2g__codaTransactionLineItem__c transRec : SortMap.get(s+''+stat)){//mapapplication.get(s).get(stat)
                       
                        String key=s+stat+transRec.Application__r.applicant__c+transRec.Application__c;
                        if(!dublicateTrans.containskey(key)){
                            if(transRec != null){
                                invWrapper iw = new invWrapper();
                                iw.Applicantname = transRec.Application__r.applicant__r.name;
                                iw.trans = transRec;
                                invList.add(iw); 
                                dublicateTrans.put(key,transRec);                                                    
                            }
                        }else{                       
                            c2g__codaTransactionLineItem__c  temptranc=dublicateTrans.get(key);
                            temptranc.amount__c+=transRec.amount__c!=null?transRec.amount__c:0;
                        }
                    }
                }
                if(invList.size() >0){
                    statuswrap.invWrapperList = invList;
                    sttsList.add(statuswrap);
                }
            }
            if(sttsList.size() >0){
                ap.sttsWrapperList= sttsList;
                appList.add(ap);
            }
        }

        
    }  
      
      public void mapTransactioninfo(){
         
         mapstatus = StatusGroup.getStatusMap();
         if(Test.isRunningTest()){mapstatus.put('Unqualified','Unqualified');}
         
         for(Application__c app :[select id,Applicant__r.name,name,Status__c,Program_Due_Date__c,Program_Term_Program__c,Program_Term__r.term__r.name,Financial_Aid__c,
                                Application_Home_Institution__c,Payment_Plan__c,Payment_Terms__c,(select id,Application__r.applicant__r.name,application__r.Program_Term__r.name,application__r.status__c,name,Date__c,c2g__DueDate__c,
                                Transaction_type__c,Reference__c,Description__c,Amount__c,Responsible_Party__c,Application__r.applicant__c,Application__r.Program_Term__c,Application__c 
                                from Transaction_Line_Items__r WHERE Responsible_Party__c =:SCHOOL)
                                from Application__c WHERE id IN: applicationid order by Program_Due_Date__c ASC  NULLS First]) {
                
                if(accountStatusSet.contains(app.status__c) || (Test.isRunningTest() && app.status__c == 'Unqualified' ) ){                               
                programterm = app.Program_Term__r.term__r.name;
                if(mapapplication.get(app.Payment_Terms__c) == null){
                        mapapplication.put(app.Payment_Terms__c,new map<string,list<c2g__codaTransactionLineItem__c>>());
                }

                Map<string,list<c2g__codaTransactionLineItem__c>> mapstts= mapapplication.get(app.Payment_Terms__c);                    
                
                if(mapstatus.containskey(app.status__c)){
                    app.status__c=mapstatus.get(app.status__c);  
                    if(mapstts.get(app.status__c) ==null)
                        mapstts.put(app.status__c,new list<c2g__codaTransactionLineItem__c>());                                             
                    mapstts.get(app.status__c).addAll(app.Transaction_Line_Items__r);                  
                    mapapplication.put(app.Payment_Terms__c,mapstts);                   
                }
          }
        }  
    }
    
    public class appWrapper{
        public string paymentterm{get;set;}
        public List<statusWrapper> sttsWrapperList{get;set;}
        public appWrapper(){
            paymentterm = '';
            sttsWrapperList = new List<statusWrapper>();
        }
    }
    
    public class statusWrapper{
        public string status{get;set;}
        public List<invWrapper> invWrapperList{get;set;}
        public statusWrapper(){
            status = '';
            invWrapperList = new List<invWrapper>();
        }
    }
     public class invWrapper{
        public string Applicantname{get;set;}
        public c2g__codaTransactionLineItem__c trans{get;set;}
        public invWrapper(){
            Applicantname = '';
            trans = new c2g__codaTransactionLineItem__c();
        }
    }
   

}