/**
 * Unit tests for <<chartEmailConfirmationController>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
@isTest
private class chartEmailConfirmationControllerTest {
	/**
	 * Tests an instance of <<chartEmailConfirmationController>>
	 */
	@isTest static void testInstance() 
	{
		Account a = apexMockDataUtility.createAccount('CHART Test');
		Contact con = apexMockDataUtility.createContact('Test', a.Id);
		User u = apexMockDataUtility.createUser(con.Id);
		u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'IFSA CHART Student User'].get(0).Id;
		u.Email_Confirmed_for_CHART__c = false;
		database.insert(u);
		Test.startTest();
		System.runAs(u)
		{
			Test.setCurrentPageReference(new PageReference('CH_EmailConfirmation'));
			chartEmailConfirmationController c = new chartEmailConfirmationController();
			c.authorized();
			System.assertEquals(false, c.hasBeenAuthorized);
			c.resendVerification();
			Test.setCurrentPageReference(new PageReference('CH_EmailConfirmation'));
			System.currentPageReference().getParameters().put('UserId', u.Id);
			c = new chartEmailConfirmationController();
			c.authorized();
			u = [SELECT Id, Email_Confirmed_for_CHART__c FROM User WHERE Id =: u.Id];
			System.assertEquals(true, u.Email_Confirmed_for_CHART__c);
			
			c = new chartEmailConfirmationController();
			c.authorized();
			System.assertEquals(true, c.hasBeenAuthorized);
		}
		Test.stopTest();
	}
	
}