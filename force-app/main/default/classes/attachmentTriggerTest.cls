/**
 * Unit tests for attachmentTrigger, <<attachmentTriggerHandler>> and <<attachmentService>>
 */
// ApexDoc updated 1/25/2021 Brock Barlow
@isTest
public without sharing class attachmentTriggerTest
{
	/**
	 * Tests the after insert of an attachment related to an application item
	 */
	public static testMethod void testAfterInsert()
	{
		try
		{
			Id studentId = mockDataUtility.createStudentUserWithApp();
			User studentUser = [SELECT Id, Name, contactId FROM User WHERE Id =: studentId].get(0);
			Contact studentContact = [select Id, FirstName, LastName, Active_Application__c FROM Contact WHERE Id =: studentUser.contactId].get(0);
			Application__c activeApplication = [select Id, Name FROM Application__c WHERE Id =: studentContact.Active_Application__c].get(0);
			Id appItemId = mockDataUtility.createAppItem(activeApplication.Id);
			
			Attachment item = new Attachment();
			item.ParentId = appItemId;
			item.Body = EncodingUtil.base64Decode('asdfasdfasdf1');
			item.Name = 'Test Item';
			
			Database.insert(item);
		}
		catch(Exception e)
		{
			System.debug(LoggingLevel.ERROR, e.getMessage());
			System.assertEquals(false, true, 'An Exception was thrown.');
		}
	}
}