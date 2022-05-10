/**
 * Wrapper class for the recommendation sObject.
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class ifsaRecommendationWrapper
{
	/**
	 * recommendation sObject.
	 */
	private Recommendation__c recommendation {get;set;}
	
	/**
	 * Constructor. Takes the Id and propagates the recommendation.
	 * @param recommendationId The Id of the recommendation
	 */
	public ifsaRecommendationWrapper(Id recommendationId)
	{
		this.recommendation = (Recommendation__c) apexQueryUtility.selectAllFrom('Recommendation__c', 'Application_Item__r.Recommendation_Wavied__c', 'Id = \'' + recommendationId + '\'').get(0);
	}
	
	/**
	 * Constructor. Takes the sObject and assigns it.
	 * @param aRecommendation The recommendation sObject.
	 */
	public ifsaRecommendationWrapper(Recommendation__c aRecommendation)
	{
		this.recommendation = aRecommendation;
	}

	/**
	 * Takes a view model and populates it with recommendation data.
	 * @param viewModel The pre-existing view model object.
	 * @return The same view model instance with populated data.
	 */
	public studentApplyItemDetailsViewModel populateViewModel(studentApplyItemDetailsViewModel viewModel)
	{
		if(viewModel.recommendations == null)
		{
			viewModel.recommendations = new List<studentRecommendationItemViewModel>();
		}

		studentRecommendationItemViewModel recommendationItem = new studentRecommendationItemViewModel();
		recommendationItem.recommendationStatus = this.recommendation.Status__c;
		recommendationItem.recommendationUrl = this.recommendation.Status__c == 'Complete' && this.recommendation.Application_Item__r.Recommendation_Wavied__c == 'No' ? 'SP_Recommendation?app=' + this.recommendation.Application_Item__c +  '&recommender=' + this.recommendation.Id : '';
		recommendationItem.recommenderEmail = this.recommendation.Email_Address__c;
		recommendationItem.recommenderName = this.recommendation.Name;
		viewModel.recommendations.add(recommendationItem);

		return viewModel;
	}
}