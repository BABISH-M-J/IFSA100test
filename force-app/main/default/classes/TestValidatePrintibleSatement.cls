@isTest
private class TestValidatePrintibleSatement{
    static testMethod void test(){
         
          Account acc=new Account(name='Account');
          insert acc;
          Contact con=new Contact(Lastname='contact');
          insert con;
          Application__c app=new Application__c();
          app.name='test appliaction';
          app.account__c=acc.id;
          app.Printable_Statement__c = false;
          app.Applicant__c =con.id;
       
        Test.startTest();
           insert app;
           app.Printable_Statement__c = true;
           update app;
        Test.stopTest();
      
      }
}