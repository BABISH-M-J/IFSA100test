/**
 * Controller fore the my institution page of the advisor portal.
 * The bulk of this functionallity has been moved to <<advisorPortalController>>
 * @author Cameron Ames
 */
// ApexDoc updated 1/22/2021 Brock Barlow
 public without sharing class advisorInstitutionController extends advisorBaseController
{
	/**
	 * Container for all data needed on the page.
	 * @see advisorInstitutionViewModel
	 */
	public advisorInstitutionViewModel viewModel {get;set;}
	
	/**
	 * The list of institutional advisors
	 * @see ifsaAdvisorWrapper
	 */
	private List<ifsaAdvisorWrapper> advisorList {get;set;}

	/**
	 * Constructor function. Gets the list of advisors, program terms, and countries and obtains appropriate view model data based off of that.
	 */
	public advisorInstitutionController()
	{
		super();

		this.advisorList = this.homeInstitution.getAdvisors();

		this.viewModel = this.populateViewModel(new advisorInstitutionViewModel());
	}

	/**
	 * Function used to add data to the view Model class.
	 * @param viewModel The view model class.
	 * @return The same view model class, now filled with data.
	 */
	public advisorInstitutionViewModel populateViewModel(advisorInstitutionViewModel viewModel)
	{
		viewModel = (advisorInstitutionViewModel) super.populateAdvisorBaseViewModel(viewModel);
		viewModel = this.homeInstitution.populateViewModel(viewModel);
		viewModel = this.advisor.populateViewModel(viewModel);

		viewModel.advisorList = new List<advisorInstitutionalAdvisorsViewModel>();
		for(ifsaAdvisorWrapper advisor : advisorList)
		{
			viewModel.advisorList.add(advisor.populateViewModel(new advisorInstitutionalAdvisorsViewModel()));
		}

		Map<String, Set<String>> programTermData = ifsaProgramTermWrapper.getCurrentProgramTermOptions();
		viewModel.AvailableCountries = programTermData.get('Countries') != null ? programTermData.get('Countries') : new Set<String>();
		viewModel.AvailableCountries.add('All');
		viewModel.AvailableYears = programTermData.get('Years') != null ? programTermData.get('Years') : new Set<String>();
		viewModel.AvailableYears.add('All');
		viewModel.AvailableTerms = programTermData.get('Sections') != null ? programTermData.get('Sections') : new Set<String>();
		viewModel.AvailableTerms.add('All');
		viewModel.SelectedYear = 'All';
		viewModel.SelectedTerm = 'All';
		viewModel.SelectedCountry = 'All';
		viewModel.HomeInstitutionAccountId = this.homeInstitution.getAccountId();
		
		return viewModel;
	}
}