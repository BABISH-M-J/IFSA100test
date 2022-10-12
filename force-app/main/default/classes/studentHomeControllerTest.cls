@isTest
public without sharing class studentHomeControllerTest
{
	public static testMethod void testInstance()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		User studentUser = (User) testInfo.get('studentUser');
		Test.startTest();
		System.runAs(studentUser)
		{
			studentHomeController controller = new studentHomeController();
			PageReference reference = controller.validateAccess();
		}
		//added by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
		Account acct = new Account(
            Name = 'name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId(),
            c2g__CODAAccountTradingCurrency__c = 'USD'
        );
		Database.insert(acct);
		Contact studentContact = new Contact(
            LastName = 'name',
            AccountId = acct.Id,
            Email = 'test' + Math.random() + '@ifsa-butler.org',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId()
        );
		Database.insert(studentContact);
		Application__c app = studentBaseController.getActiveApplication(studentContact);
		Application__c application = new Application__c(
            Name = 'Unit Test Application',
            Status__c = 'Registered',
            Applicant__c = studentContact.Id,
			Designation__c = 'Primary'
        );
		Database.insert(application);
		app = studentBaseController.getActiveApplication(studentContact);
		//added by PowerFluence req_dt:03/29/2022 ref email from Clayton ends
		Test.stopTest();
	}
}