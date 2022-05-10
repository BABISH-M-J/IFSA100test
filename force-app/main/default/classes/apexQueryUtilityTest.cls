/**
 * Test class for the query utility.
 * @author Cameron Ames
 */
// ApexDoc updated 1/25/2021 Brock Barlow
@isTest
public with sharing class apexQueryUtilityTest
{
	/**
	 * test the selectAllFrom methods.
	 */
	public static testMethod void testSelectAllFrom()
	{
		//try to get an exception 
		try
		{
			apexQueryUtility.selectAllFrom('Unknown', '');
			System.assert(false, 'An Exception should have been thrown by now.');
		}
		catch(Exception e)
		{
			System.assert(true, 'An Exception was supposed to be thrown.');
		}

		//attempt valid
		Account acct = apexMockDataUtility.createAccount('Test');
		
		Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);

		List<Contact> contactList = apexQueryUtility.selectAllFrom('Contact', 'Id != \'\'');
		System.assertEquals(1, contactList.size(), 'We inserted 1 contact into the Database but we aren\'t getting it.');

		Contact ctc2 = apexMockDataUtility.createContact('Test2', acct.Id);
		
		contactList = apexQueryUtility.selectAllFrom('Contact', 'Account.Name', 'Id != \'\'');
		System.assertEquals(2, contactList.size(), 'We inserted 2 contacts into the Database but we aren\'t getting them.');
		System.assertNotEquals(null, contactList.get(0).Account.Name, 'The Account Name was not correctly queried.');
	}

	/**
	 * test the buildInClause methods.
	 */
	public static testMethod void testBuildInClause()
	{
		//Attempt with an actual set of ids.
		Contact ctc = apexMockDataUtility.createContact('Test1', null);
		Contact ctc2 = apexMockDataUtility.createContact('Test2', null);

		List<Id> idList = new List<Id>();
		idList.add(ctc.Id);
		idList.add(ctc2.Id);
		
		String inClause = apexQueryUtility.buildInClause(idlist);
		String expectedResult = '(\'' + ctc.Id + '\', \'' + ctc2.Id + '\')';
		System.assertEquals(expectedResult, inClause, 'The inClause String did not match the expected value.');
		
		//Test the alternative method
		List<Contact> contactList = new List<Contact> {ctc, ctc2};
		inClause = apexQueryUtility.buildInClause(contactList, 'Id');
		System.assertEquals(expectedResult, inClause, 'The inClause String did not match the expected value.');
	}
}