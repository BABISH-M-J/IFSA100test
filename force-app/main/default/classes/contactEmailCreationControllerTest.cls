/**
 * Unit tests for <<contactEmailCreationController>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
private class contactEmailCreationControllerTest {
	
	@isTest static void testInstance() 
	{
		Test.setMock(WebServiceMock.class, new ifsaButlerNetEmailServiceMock());
		Account a = new Account(Name = 'Test Email-Forwarding');
		database.insert(a);
		Contact c = new Contact(FirstName = 'Test', LastName = 'Email-Forwarding', AccountId = a.Id);
		database.insert(c);
		Test.startTest();
		// Create standard controller and extension instances
		ApexPages.StandardController std = new ApexPages.StandardController(c);
		contactEmailCreationController ext = new contactEmailCreationController(std);
		// Assert controller properties
		system.AssertEquals(false, ext.hasEmail);
		system.AssertEquals(false, ext.updatingContact);
		// Run createEmail() method
		PageReference result = ext.createEmail();
		// Assert PageReference is not null
		system.AssertNotEquals(null, result);

		// Fake existing email
		c.IFSA_Butler_NET_Email__c = 'test.email-forwarding@email.test';
		database.update(c);

		std = new ApexPages.StandardController(c);
		ext = new contactEmailCreationController(std);

		system.AssertEquals(true, ext.hasEmail);

		Test.stopTest();
	}	
}