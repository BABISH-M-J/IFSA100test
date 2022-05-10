/**
 * Unit test for Recommendation__c trigger
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public with sharing class ifsaRecommendationTriggerTest
{
	public static testMethod void testAfterUpdateAfterDelete()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		Test.startTest();
		Application__c application = (Application__c) testInfo.get('studentApplication');
		Application_Item__c appItem = new Application_Item__c();
		appItem.Name = 'Recommendation';
		appItem.Status__c = 'Incomplete';
		appItem.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType =: 'Application_Item__c' AND Name =: 'Recommendation'].Id;
		appItem.Recommendation_Wavied__c = 'Yes';
		appItem.Number_of_Recommendations__c = 1;
		appItem.Recommendations_Completed__c = 0;
		appItem.Application__c = application.Id;
		
		Database.insert(appItem);
		
		Recommendation__c recommendation = new Recommendation__c();
		recommendation.Name = 'Test asdf';
		recommendation.Application_Item__c = appItem.Id;
		recommendation.Email_Address__c = 'dev@ifsa-butler.org.test';
		recommendation.Status__c = 'Incomplete';
		recommendation.Recommender_Name__c = 'John Smith';
		
		Database.insert(recommendation);
		
		recommendation.Status__c = 'Complete';
		Database.update(recommendation);
		
		appItem = [SELECT Id, Status__c, Number_Of_Recommendations__c, Recommendations_Completed__c FROM Application_Item__c WHERE Id =: appItem.Id];
		System.assertEquals(1, appItem.Recommendations_Completed__c, 'after update count not correct.');
		System.assertEquals('Complete', appItem.Status__c);
		
		Database.delete(recommendation);
		
		appItem = [SELECT Id, Status__c, Number_Of_Recommendations__c, Recommendations_Completed__c FROM Application_Item__c WHERE Id =: appItem.Id];
		System.assertEquals(0, appItem.Recommendations_Completed__c, 'after delete count not correct.');
		System.assertEquals('Incomplete', appItem.Status__c);
		Test.stopTest();
	}
}