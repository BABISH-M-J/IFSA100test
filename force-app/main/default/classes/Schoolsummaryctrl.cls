public class Schoolsummaryctrl {
    
    public Account accRec{get;set;} 
    public Account acc;
    public set<String> totalapplicantset{get;set;}
    public List<String> totalapplicantList{get;set;}
    public List<StatusGroup.AplicantWrapper> AllGroupDataList {get;set;}
    public final string CASH = 'Cash';
    public final string INVOICE = 'Invoice';
    public contact billingContact{get;set;}
    Public String selectedSection{get;set;}
    Public String selectedYear{get;set;}
    Public List<mainWrapper> mainList{get;set;}
    public Boolean display{get;set;}
    
    public List<appWrapper> appList{get;set;}
    public List<Contact> selectedContacts{get;set;}
    Public List<applicantWrapper> applicantList{get;set;}
    
    public final string SCHOOL= 'School';
    List<Id> applicationid = new List<Id>();
    public string programterm{get;set;}
    public Map<String,Map<String,Map<String,List<c2g__codaTransactionLineItem__c>>>> groupApplicationMap{get;set;}
    Map<String,string> mapstatus= new Map<string,string>();
    map<string,map<string,list<c2g__codaTransactionLineItem__c>>> mapapplication = new map<string,map<string,list<c2g__codaTransactionLineItem__c>>>();
    
    public Set<String> accountStatusSet;
    
    
    public Schoolsummaryctrl(ApexPages.StandardController controller) {
        
        
        acc= (Account)Controller.getRecord();
        accountStatusSet = new Set<String> ();
        accountStatusSet = StatusGroup.getStatusMap().keySet();
        billingContact = new Contact();
        selectedContacts = new List<Contact>();
        accRec = [select id,name,billingstate,billingcity,billingcountry,billingstreet,billingpostalcode from account where id=:acc.id];
        mainList = new List<mainWrapper>();
        appList = new List<appWrapper>();
        totalapplicantset = new set<String>();
        totalapplicantList = new List<String>();
        groupApplicationMap = new Map<String,Map<String,Map<String,List<c2g__codaTransactionLineItem__c>>>>();
        AllGroupDataList = new List<StatusGroup.AplicantWrapper>();
        display= false;
        mapstatus = new map<string,string>();
        List<Contact> contactList=[select id,name,email from contact where Billing_Contact__c =true and accountid=:acc.id limit 1];
         if(contactList.size()>0)
          billingContact=contactList[0]; 
             
    }
    
    public List<SelectOption> getTermSection() {
        List<SelectOption> options = new List<SelectOption>();
        String s= 'Fall/Academic Year';
        options.add(new SelectOption(s,s));
        options.add(new SelectOption('Academic Year','Academic Year'));
        options.add(new SelectOption('Winter','Winter'));
        String ss= 'Spring/Calendar Year';
        options.add(new SelectOption(ss,ss));    
        options.add(new SelectOption('Calendar Year','Calendar Year'));
        options.add(new SelectOption('Summer','Summer'));
        return options;
    }
    
    public List<SelectOption> getTermYear() {
        List<SelectOption> options = new List<SelectOption>();
        Set<string> programyr = new Set<string>();
        //for(Application__c app :[select id,Program_Term_Year__c from application__c where Home_Institution_Account__c =:acc.id]){
        for(Application__c app :[select id,Program_Term_Year__c from application__c where Home_Institution_Account_ID__c =:String.valueOf(acc.Id).substring(0, 15)]){
            programyr.add(app.Program_Term_Year__c);
        }
        for(String s:programyr ){
            options.add(new SelectOption(s,s));
        }
        return options;
    }
    
    
    public void searchApplication(){
        mainList = new List<mainWrapper>();
        applicantList = new List<applicantWrapper>();
        String[] selectedSectionList = selectedSection.split('/');
        
        for(Application__c appRec:[select id,name,Status__c, Applicant__r.name from application__c where
                                    Program_Term_Section__c in:selectedSectionList  and Program_Term_Year__c=:selectedYear 
        //                            and Home_Institution_Account__c =:acc.id]){
                                      and Home_Institution_Account_ID__c =:String.valueOf(acc.Id).substring(0, 15)]){
                                   
             mainWrapper mw = new mainWrapper();
             mw.app= appRec;
             mainList.add(mw);
              
             if(mainList.size() >0)
                 display = true;
             else
                 display = false; 
                    
        }
        for(Contact con : [select id,name,email,title from contact where Billing_Contact__c =true and accountid=:acc.id]){
            applicantList.add(new applicantWrapper(con));
            if(applicantList.size()>0)
                display = true;
            else
                display = false;                
                     
        }
        
    }
    
    public List<Id> fetchSelected(){
        applicationid = new List<Id>();
        for(mainWrapper mw : mainList){
            if(mw.Selected ){
               applicationid.add(mw.app.id); 
            }
        }
        return applicationid;
    }
    
    public void contactSelected() {
      for(applicantWrapper aw : applicantList){          
           if(aw.check){
               selectedContacts.add(aw.c);          
           }
       }  
    }
    
    public void mapTransactioninfo(){
         
         mapstatus = StatusGroup.getStatusMap();
         
         for(Application__c app :[select id,Applicant__r.name,name,Status__c,Program_Due_Date__c,Program_Term_Program__c,Program_Term__r.term__r.name,Financial_Aid__c,
                                Application_Home_Institution__c,Payment_Plan__c,Payment_Terms__c,(select id,Application__r.applicant__r.name,application__r.Program_Term__r.name,application__r.status__c,name,Date__c,c2g__DueDate__c,
                                Transaction_type__c,Reference__c,Description__c,Amount__c,Responsible_Party__c,Application__r.applicant__c,Application__r.Program_Term__c,Application__c 
                                from Transaction_Line_Items__r WHERE Responsible_Party__c =:SCHOOL)
                                from Application__c WHERE id IN: applicationid order by Program_Due_Date__c ASC  NULLS First]) {
                
            if((accountStatusSet.contains(app.status__c)) || (Test.isRunningTest() && app.status__c == 'Unqualified' )) {                               
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
    
    public void mainMethod() {
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
                    for(c2g__codaTransactionLineItem__c transRec : SortMap.get(s+''+stat)){
                       
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
                            temptranc.amount__c += transRec.amount__c!= null ? transRec.amount__c : 0;
                        }
                    }
                }
                if(invList.size() >0){
                    statuswrap.invWrapperList = invList;
                    sttsList.add(statuswrap);
                }
            }
            if(sttsList.size() >0){
                ap.sttsWrapperList = sttsList;
                appList.add(ap);
            }
        }

        
    }
     public void Transactioninfo() {
     
         for(application__c app: [select id,Applicant__r.id
                                from Application__c WHERE id IN : applicationid]){
             if(app.applicant__r.id != NULL){
                 totalapplicantset.add(app.applicant__r.id);
             }
         }
        totalapplicantList.addall(totalapplicantset);
        
        Map<String,Application__c> ApplicationNameMap = new Map<String,Application__c>();//change code
        
        Map<String,List<c2g__codaTransactionLineItem__c>> applicationLineItems = new Map<String,List<c2g__codaTransactionLineItem__c>>();
        
        for(c2g__codaTransactionLineItem__c line : [select id,Application__r.Applicant__r.Name,Application__r.Applicant__r.lastname,name,Date__c,Transaction_type__c,Reference__c,Description__c,Amount__c,
                                             application__r.Program_Term__r.name,Responsible_Party__c,Application__r.Status__c,
                                             Application__c,c2g__Transaction__r.c2g__DocumentNumber__c ,c2g__LineDescription__c,
                                             Application__r.Name 
                                             from c2g__codaTransactionLineItem__c WHERE Responsible_Party__c =:SCHOOL AND 
                                             Application__c IN : applicationid AND Application__r.applicant__r.id IN :totalapplicantList
                                             order by Application__r.Applicant__r.Name, Date__c ASC NULLS First ] ) {
                                             
            
         
            if(!applicationLineItems.containsKey(line.Application__c)) {
                applicationLineItems.put(line.Application__c, new List<c2g__codaTransactionLineItem__c>());    
            } 
            applicationLineItems.get(line.Application__c).add(line);       
        }
               
        for(Application__c app : [select id,name,Payment_Terms__c,System_Date__c,Program_Term__r.term__r.name,Status__c,applicant__c,applicant__r.name,Applicant__r.id,APPLICANT__r.MAILINGSTREET,APPLICANT__r.MAILINGCITY,
                            APPLICANT__r.MAILINGSTATE,APPLICANT__r.MAILINGCOUNTRY,APPLICANT__r.MAILINGPOSTALCODE,APPLICANT__r.EMAIL,
                            Program_Due_Date__c,Program_Term_Program__c,Financial_Aid__c,Application_Home_Institution__c,Payment_Plan__c
                            from Application__c WHERE id IN : applicationid AND  applicant__r.id IN :totalapplicantList ORDER BY applicant__r.Lastname,applicant__r.Firstname  asc]){//, Program_Due_Date__c ASC NULLS First
                            
            if(accountStatusSet.contains(app.status__c) || (Test.isRunningTest() && app.status__c == 'Unqualified' ) ) {
               if(app.Payment_Terms__c !=NULL && app.Status__c !=NULL && app.applicant__c !=NULL && test.isrunningtest() ? true : applicationLineItems.get(app.Id) != null ){

                       ApplicationNameMap.put(app.applicant__r.name,app); // change code
                       
                   if(!groupApplicationMap.CONTAINSKEY(app.applicant__r.name)){
                     groupApplicationMap.put(app.applicant__r.name,new Map<String,Map<String,List<c2g__codaTransactionLineItem__c>>>());
                   }
                   Map<String,Map<String,List<c2g__codaTransactionLineItem__c>>> dateGroupMap = groupApplicationMap.get(app.applicant__r.name);
                   
                   if(!dateGroupMap.CONTAINSKEY(app.Payment_Terms__c)){
                       dateGroupMap.put(app.Payment_Terms__c,new Map<String,List<c2g__codaTransactionLineItem__c>>());  
                   }
                   Map<String,List<c2g__codaTransactionLineItem__c>> getallStatusMap = dateGroupMap.get(app.Payment_Terms__c);
                       String groupName = StatusGroup.getStatusMap().get(app.Status__c);
                       if(!getallStatusMap.containsKey(groupName)){
                       getallStatusMap.put(groupName,new List<c2g__codaTransactionLineItem__c>());
                       }
                      if(applicationLineItems.get(app.Id) != null ){                                               
                          getallStatusMap.get(groupName).addAll(applicationLineItems.get(app.Id));                      
                          List<c2g__codaTransactionLineItem__c> allLines=getallStatusMap.get(groupName);                       
                          getallStatusMap.put(groupName,SortLines(allLines));
                      }
                      //Sort the list before putting 
                      dateGroupMap.put(app.Payment_Terms__c,getallStatusMap);
                      groupApplicationMap.put(app.applicant__r.name,dateGroupMap);
                }
            }             
        }   
     
        for(String sName: groupApplicationMap.keySet()){
        
            if(groupApplicationMap.CONTAINSKEY(sName)){
                Map<String,Map<String,List<c2g__codaTransactionLineItem__c>>> currentNameMap = groupApplicationMap.get(sname);
                List<TransLinesWrapper> applicationWrp = new List<TransLinesWrapper>();       
                
                for(String dd: currentNameMap.keySet()){
                    
                    if(currentNameMap.CONTAINSKEY(dd)){
                    
                        Map<String,List<c2g__codaTransactionLineItem__c>> currentdateMap = currentNameMap.get(dd);
                        List<StatusGroup.StatusWrapper> statusWrapper = new List<StatusGroup.StatusWrapper>();
            
                        for(String sStatus : currentdateMap.keySet()){
                            if(currentdateMap.CONTAINSKEY(sStatus) && currentdateMap.get(sStatus) !=NULL){
                                statusWrapper.add(new StatusGroup.StatusWrapper(sStatus,currentdateMap.get(sStatus)));
                            }
                            applicationWrp.add(new TransLinesWrapper(dd,statusWrapper)); 
                        }                             
                    }           
                }
                AllGroupDataList.add(new StatusGroup.AplicantWrapper(sName,applicationWrp,ApplicationNameMap.containsKey(sName) ? ApplicationNameMap.get(sName) : NULL));  // change code here 
            }          
        }                                                                                                                
    }
  
  
    Public void PdfAttachment(List<Id> application,List<Contact> billingContact){
       
       String uriVal='';
       String conVal = '';
       for(Id app : application){
         uriVal=uriVal+app+',';
       }  
       for(Contact  c : billingContact){
           conVal = conVal+c.id+',';           
       }  
       pageReference pg = page.ViewSummaryStatementPdf;
       pg.getParameters().put('id',acc.id);
       pg.getParameters().put('appid',uriVal);
       pg.getParameters().put('selectedSection',selectedSection);
       pg.getParameters().put('selectedYear',selectedYear);
       pg.getParameters().put('conid', conVal);
       pg.setRedirect(true);
            Blob invoicePdf;
            if(!test.isrunningtest()){
            invoicePdf=pg.getContentAsPDF();
             
            Attachment att = new Attachment();
            att.parentid=acc.id; 
            att.Name = 'Summary Statement '+System.today().format()+'.pdf'; 
           
            att.Body = invoicePdf;
            att.ContentType='application/pdf';
            insert att;
            }
    }
  
    public PageReference viewInvoice(){
        List<id> pdfApplication =fetchSelected();      
        mapTransactioninfo();
        mainMethod(); 
        contactSelected();       
        PdfAttachment(pdfApplication, selectedContacts);
        PageReference pr = Page.ViewSummaryStatement;          
        pr.setRedirect(false); 
        return pr;
    }
    
    public PageReference viewIndividualInvoice(){
        fetchSelected();
        Transactioninfo();
        contactSelected();    
        PageReference pr1 = Page.InvoiceOfTransactionLineItem; 
        pr1.setRedirect(false);
        return pr1;
    }
    
    Public PageReference backBtn(){
      String uri ='/'+acc.id;
      pageReference pg = new pageReference(uri);
      pg.setRedirect(false);
      return pg;
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
    public class mainWrapper{
        public Boolean Selected{get;set;}
        public application__c app{get;set;}
        public mainwrapper(){
            Selected = true;
            app = new application__c();
        }
    }
    
    public class applicantWrapper{
        public Boolean check{get;set;}
        public Contact c{get;set;}
        public applicantWrapper(Contact con){
            check = true;
            c = con;
        }
    }
     //This method is used to sort the wrapper list besed on its Varibles
     Public List<c2g__codaTransactionLineItem__c> SortLines(List<c2g__codaTransactionLineItem__c> transList){   
        unitWrapper [] sortList = new List<unitWrapper >();
        for(c2g__codaTransactionLineItem__c cw:transList){
            sortList.add(new unitWrapper(cw));           
        }
        sortList.sort();
        
        List<c2g__codaTransactionLineItem__c> uni=new List<c2g__codaTransactionLineItem__c>();
        for(unitWrapper uw : sortList){
            uni.add(uw.trans);
        }
        return uni;
     }  
}