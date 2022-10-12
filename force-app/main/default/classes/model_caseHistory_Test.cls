@isTest
public class model_caseHistory_Test {
    
    @TestSetup
    public static void mockData(){
        //Create test account
        Account acct = apexMockDataUtility.createAccount('TestAcct');
        
        //Create test contact
        Contact ctc = apexMockDataUtility.createContact('TestCtc', acct.Id);
        
        //Create test user
        User u= apexMockDataUtility.createUser(ctc.id);
        insert u;
        
        //Create test Case
        Case case1 = new Case();
        case1.Status = 'New';
        case1.Student__c = ctc.id;
        case1.Date_Time_of_Incident__c = DateTime.now();
        case1.Category__c  = 'Academic';
        case1.Sub_Category__c = 'Accommodations';
        case1.Subject = 'IFSA Case Controller Test';
        case1.Incident_Severity__c = 'Critical';
        case1.Description = 'Test';
        case1.Alchohol_Involved__c  = true;
        insert case1;
        
        
        case1.subject='jh';
        update case1;
        
       }
    
    @isTest 
    public static void Testmodel_caseHistory(){
    Case c=[Select Id,CaseNumber,Description,Status,Subject,Incident_Severity__c,Priority,CreatedDate,Owner.Name,Student__c from Case limit 1];
         List<CaseHistory> ah;
        test.startTest();
     if(Test.isRunningTest()){  //if TEST, create dummy 
         ah = new List<CaseHistory>{}; //OldValue, NewValue not writeable
         ah.add(new CaseHistory(CaseId=c.Id, Field='Subject'));
     }
     else 
     ah=[Select Id,CaseId,Field,OldValue,NewValue,CreatedDate from CaseHistory where CaseId=:c.Id limit 1];
       model_caseHistory mch=new model_caseHistory();
       model_caseHistory mch1=new model_caseHistory(ah[0],c);
       
        test.stopTest();
    }
    
 
    
    @isTest 
    public static void Testmodel_caseHistoryEquals(){
    test.startTest();
    model_caseHistory modCaseHis = new model_caseHistory();
        Boolean objCheck = modCaseHis.equals(modCaseHis);        
       
        test.stopTest();
     // System.assert(!objCheck);
    }
}