/* 
   @author     : Avaneesh Singh
   Description : In this class application status are grouped together 
  */

public class StatusGroup{
  
    public static Map<string,string> getStatusMap(){    
        Map<String,String> groupStatusMap = new map<string,string>();
        groupStatusMap.put('Program Selected', 'Students not yet accepted');
        groupStatusMap.put('Ready To Submit', 'Students not yet accepted');
        groupStatusMap.put('Submitted', 'Students not yet accepted');    
        groupStatusMap.put('Accepted' ,'Accepted Students');
        groupStatusMap.put('Accepted (with Conditions)' ,'Accepted Students' );
        groupStatusMap.put('On Site' , 'Accepted Students') ;
        groupStatusMap.put('Program Completed' , 'Accepted Students');    
        groupStatusMap.put('Diverted','Withdrawn Students');
        groupStatusMap.put('Dropped' ,'Withdrawn Students');
        groupStatusMap.put('Deferred','Withdrawn Students');
        groupStatusMap.put('Withdraw','Withdrawn Students');      
        return groupStatusMap;
    }
    
    public class AplicantWrapper {
        public String childName{get;set;}
        public list<TransLinesWrapper> applications {get;set;}
        public Application__c ApplicationValues{get;set;}
        public String App_status{get;set;}
        
        public AplicantWrapper(String cName , list<TransLinesWrapper> app , Application__c appValues){
             childName=cName;
             applications=app;
             ApplicationValues = appValues;
        }
    }
 
    
    
    public class StatusWrapper{
        public String status{get;set;}
        public List<c2g__codaTransactionLineItem__c> transactionLineitem{get;set;}             
        public StatusWrapper(String st,List<c2g__codaTransactionLineItem__c> tran){
            status = st;
            transactionLineitem = tran;
        }
    }
}