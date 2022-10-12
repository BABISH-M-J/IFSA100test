@isTest
public without sharing class model_CaseTest
{
    @TestSetup
 static void makedata(){
          BaseTriggerHandler.bypass('caseTriggerHandler');

       Case c = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Host Institution').getRecordTypeId());
      c.Incident_Severity__c = 'Non-Emergency';
      c.Incident_Category__c = 'Program/Country Wide';
      c.Incident_Sub_Category__c = 'Political/Social Unrest';
      c.Incident_Sub_Subcategory__c = 'Protests/Demonstrations';
      c.Date_Time_of_Incident__c = Datetime.now();
      c.Affected_Host_Institutions__c = 'University College London';
      Database.insert(c);
  }
  
   @isTest static void testdata(){
         
         Case c=[Select Id,CaseNumber,Description,Subject,Status,Incident_Severity__c,Priority,CreatedDate,Owner.Name,Student__c from Case ];
         Test.StartTest();
         model_case con=new model_case();
          model_case con1=new model_case(c);
         // con1.setBaseValues();
          con1.equals((object)con1);
          con1.equals((object)c);
         Test.StopTest();
         }
  }