/**
 * Test class for the recommendation wrapper class
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public with sharing class ifsaRecommendationWrapperTest
{
	/**
	 * Test the instance methods and constructors
	 */
	public static testMethod void testInstance()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		Test.startTest();
		Application__c application = (Application__c) testInfo.get('studentApplication');
		Application_Item__c appItem = (Application_Item__c) apexQueryUtility.selectAllFrom('Application_Item__c', 'Application__c = \'' + application.Id + '\'').get(0);
		
		Recommendation__c recommendation = apexMockDataUtility.createRecommendation(appItem.Id);
		
		//Test instance constructor
		ifsaRecommendationWrapper recommendationWrapper = new ifsaRecommendationWrapper(recommendation);
		
		//Test Id constructor
		recommendationWrapper = new ifsaRecommendationWrapper(recommendation.Id);
		
		studentApplyItemDetailsViewModel viewModel = recommendationWrapper.populateViewModel(new studentApplyItemDetailsViewModel());
		System.assertNotEquals(null, viewModel.recommendations, 'The view model recommendations should not be null.');
		Test.stopTest();
	}
}