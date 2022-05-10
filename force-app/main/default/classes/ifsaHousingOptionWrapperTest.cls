/**
 * Test class for the housing option wrapper class
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public with sharing class ifsaHousingOptionWrapperTest
{
	/**
	 * Test the instance methods and constructors
	 */
	public static testMethod void testInstance()
	{
		Housing_Option__c housingOption = apexMockDataUtility.createHousingOption();
		
		//Test instance constructor
		ifsaHousingOptionWrapper housingOptionWrapper = new ifsaHousingOptionWrapper(housingOption);
		
		//Test Id constructor
		housingOptionWrapper = new ifsaHousingOptionWrapper(housingOption.Id);
		
		studentApplyItemDetailsViewModel viewModel = housingOptionWrapper.populateViewModel(new studentApplyItemDetailsViewModel());
		
		System.assertNotEquals(null, viewModel.housingOptions, 'The housing options LIST should not have been null.');
		System.assertNotEquals(null, viewModel.housingRankOptions, 'The housing rank options LIST should not have been null.');
	}
}