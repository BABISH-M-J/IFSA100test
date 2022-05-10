@isTest
public without sharing class studentAccountControllerTest
{
  public static testMethod void testInstance()
  {
    Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
    Application__c application = (Application__c) testInfo.get('studentApplication');
    User studentUser = (User) testInfo.get('studentUser');
    Contact studentContact = new Contact(
      Id = studentUser.ContactId,
      MailingStreet = '123 Main St',
      MailingCity = 'Anytown',
      MailingState = 'IN',
      MailingPostalCode = '46239'
    );

    database.update(studentContact);
      
    test.startTest();
    System.runAs(studentUser)
    {
      studentAccountController controller = new studentAccountController();
      controller.viewModel.paymentAmount ='6';
      controller.doDML = true;
      PageReference reference = controller.validateAccess();
      reference = controller.payNow();
    }
    test.stopTest();
  }
}