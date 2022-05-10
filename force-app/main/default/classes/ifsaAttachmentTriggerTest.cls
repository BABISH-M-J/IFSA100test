/**
 * Test class for Attachment
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public without sharing class ifsaAttachmentTriggerTest
{
	public static testMethod void testAfterInsert()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		test.startTest();
		Application__c application = (Application__c) testInfo.get('studentApplication');		
		Application_Item__c appItem = (Application_Item__c) testInfo.get('applicationItem');
			
		Attachment item = new Attachment();
		item.ParentId = appItem.Id;
		item.Body = EncodingUtil.base64Decode('asdfasdfasdf1');
		item.Name = 'Test Item';
		
		Database.insert(item);
		test.stopTest();
	}
}