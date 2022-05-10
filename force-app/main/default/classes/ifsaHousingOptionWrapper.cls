/**
 * Wrapper class for the housing option sObject.
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class ifsaHousingOptionWrapper
{
	/**
	 * housing option sObject.
	 */
	private Housing_Option__c housingOption {get;set;}
	
	/**
	 * Constructor. Takes the Id and propagates the housing option.
	 * @param housingOptionId The Id of the housing option
	 */
	public ifsaHousingOptionWrapper(Id housingOptionId)
	{
		this.housingOption = (Housing_Option__c) apexQueryUtility.selectAllFrom('Housing_Option__c', 'Id = \'' + housingOptionId + '\'').get(0);
	}
	
	/**
	 * Constructor. Takes the sObject and assigns it.
	 * @param aHousingOption The housing option sObject.
	 */
	public ifsaHousingOptionWrapper(Housing_Option__c aHousingOption)
	{
		this.housingOption = aHousingOption;
	}

	/**
	 * Populates the view model with housing option data
	 * @param viewModel the pre-existing view model
	 * @return The same view model instance, now populated with data
	 */
	public studentApplyItemDetailsViewModel populateViewModel(studentApplyItemDetailsViewModel viewModel)
	{
		if(viewModel.housingOptions == null)
		{
			viewModel.housingOptions = new List<Map<String,String>>();
		}
		
		if(viewModel.housingRankOptions == null)
		{
			viewModel.housingRankOptions = new List<Integer>();
		}
		
		//Add a housing option to the list
		Map<String, String> housingOptionMap = new Map<String, String>();
		housingOptionMap.put('Description', this.housingOption.Description__c);
		housingOptionMap.put('Name', this.housingOption.Name);
		housingOptionMap.put('Id', this.housingOption.Id);
		viewModel.housingOptions.add(housingOptionMap);
		
		viewModel.housingRankOptions.add(viewModel.housingRankOptions.size());
		
		return viewModel;
	}
}