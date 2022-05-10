/**
 * Controller for the My Students page of the advisor portal.
 * @author Cameron Ames
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public without sharing class advisorStudentsController extends advisorBaseController
{
	/**
	 * Container for all data needed on the page.
	 * @see advisorStudentsViewModel
	 */
	public advisorStudentsViewModel viewModel {Get;Set;}

	/**
	 * Constructor function. Gets the available statuses, years, etc. And sets a default.
	 * @return void
	 */
	public advisorStudentsController()
	{
		//Execute base class code
		super();

		this.viewModel = this.populateViewModel(New advisorStudentsViewModel());
	}
	
	/**
	 * Populates a view model <<advisorStudentsViewModel>> with data.
	 * @param viewModel An instance of the <<advisorStudentsViewModel>> class.
	 * @return the same view model instance with data.
	 */
	private advisorStudentsViewModel populateViewModel(advisorStudentsViewModel viewModel)
	{
		viewModel = (advisorStudentsViewModel) super.populateAdvisorBaseViewModel(viewModel);
		
		viewModel.AvailableStatuses = New List < String > {'All'};
        viewModel.AvailableTerms = New List < String > {'All'};
        viewModel.AvailableYears = New List < String > {'All'};
        viewModel.AvailableCountries = New List < String > {'All'};
		
		//Add status except "New", "Housing Selected", "Travel Approved" And "Deceased" And "Registered" And "Diverted" And "Deferred" And "Unqualified"   to list of statuses
				
		List<String> StatusValues = system.Label.AdvisorStudentStatus.Split(',');	
		for (String status: apexConversionUtility.getPicklistStringValues(Application__c.Status__c))
		{
			if (!StatusValues.contains(status))
            {
                viewModel.AvailableStatuses.add(status);
			}
		}
		for(String section: apexConversionUtility.getPicklistStringValues(Term__c.Section__c))
		{
			if( section != 'Not Approved')
			{
				viewModel.AvailableTerms.add(section);
			}
		}
		
		if(Date.Today().Year() - 3 >= 2017)
		{
			viewModel.AvailableYears.add(String.valueOf(Date.Today().Year() - 3));
		}
		if(Date.Today().Year() - 2 >= 2017)
		{
			viewModel.AvailableYears.add(String.valueOf(Date.Today().Year() - 2));
		}
		if(Date.Today().Year() - 1 >= 2017)
		{
			viewModel.AvailableYears.add(String.valueOf(Date.Today().Year() - 1));
		}
		viewModel.AvailableYears.add(String.valueOf(Date.Today().Year()));
		viewModel.AvailableYears.add(String.valueOf(Date.Today().Year() + 1));
		viewModel.AvailableYears.add(String.valueOf(Date.today().Year() + 2));
		viewModel.AvailableYears.add(String.valueOf(Date.today().Year() + 3));
        
       
		List<String> CountryValues = system.Label.AdvisorStudentCountry.Split(',');
		List<Country__c> countryList = [SELECT Id, Name FROM Country__c WHERE Active__c = TRUE ORDER BY Name];
       
       	//Add country except "Canada", "South Korea", "Hong Kong" And "United Arab Emirates" And "Worldwide" And "Korea (the Republic of)"  to list of countries		
        for(Country__c country : countryList)
		{
            if (!CountryValues.contains(country.Name))
            {
               viewModel.AvailableCountries.add(country.Name);
			}
			
		}

		viewModel.selectedCountry = 'All';
		viewModel.selectedStatus = 'All';
		viewModel.selectedTerm = 'All';
		viewModel.selectedYear = 'All';
		
		return viewModel;
	}
	/**
	 * Authorization function required to be implemented on every page. This action is called upon page load.
	 * @return PageReference
	 */
	public override virtual PageReference validateAccess()
	{
		//If the portal has been locked down redirect to message screen
		if(this.viewModel.isLockDownActive)
		{
			return new PageReference('/advisorportal/AP_PortalMessage');
		}
		// Otherwise run method in base class
		return super.validateAccess();
	}
}