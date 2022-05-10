/**
 * Unit tests for <<advisorUnauthorizedController>>
 */
@isTest
public without sharing class advisorUnauthorizedControllerTest
{
	/**
	 * Tests an instance of <<advisorUnauthorizedController>>
	 */
	// ApexDoc updated 1/25/2021 Brock Barlow
	public static testMethod void testInstance()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		Contact studentContact = (Contact) testInfo.get('studentContact');
		Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
		Id advisorContactId = [SELECT Id FROM Contact WHERE RecordTypeId = :advisorRecordType LIMIT 1].Id;
		User advisorUser = apexMockDataUtility.createAdvisor(advisorContactId);
		test.startTest();
		System.runAs(advisorUser)
		{
			advisorUnauthorizedController controller = new advisorUnauthorizedController();
			PageReference reference = controller.validateAccess();
		}
		test.stopTest();
	}
}