@isTest
public without sharing class studentAccountControllerTest
{
  public static testMethod void testInstance()
  {
    Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
    Application__c application = (Application__c) testInfo.get('studentApplication');
      //Begin Added by Powerfluence 24Aug2022 
    Application_Item__c applicationItem = new Application_Item__c(
            Name = 'Test item',
            Directions__c = 'asdf',
            RecordTypeId = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Program Approval').getRecordTypeId(),
            Application__c = application.Id,
            Phase__c = 'Pre-Admit'
        );
        Database.insert(applicationItem);
    Contact studContact = [SELECT Id, Name FROM Contact WHERE Id = :application.Applicant__c LIMIT 1];
    User studUser  = [SELECT Id, Name FROM User WHERE ContactId =: studContact.Id];
    test.startTest();
    System.runAs(studUser)
    {
      try{
      studentAccountController controller = new studentAccountController();
      controller.viewModel.paymentAmount ='6';
      controller.doDML = true;
      PageReference reference = controller.validateAccess();
      reference = controller.payNow();
      }
      catch (Exception e) {
        System.debug('Debug:Exception>>> ERROR ='+e);
      }    	
    }
    //End Added by Powerfluence 24Aug2022
    test.stopTest();
  }
}