/**
 * @description Controller for the my profile page of the advisor portal.
 * @author Cameron Ames
 */
// ApexDoc updated 1/23/2021 Brock Barlow
 public without sharing class advisorProfileController extends advisorBaseController
{
	/**
	 * @description Container for all data needed on the page.
	 * @see advisorProfileViewModel
	 */
	public advisorProfileViewModel viewModel {get;set;}

	/**
	 * @description Constructor function. Adds data that is already obtained in the base advisorportal class.
	 */
	public advisorProfileController()
	{
		super();
		
		this.viewModel = this.populateViewModel(new advisorProfileViewModel());
	}

	/**
	 * @description Function used to add data to the view Model class.
	 * @param viewModel An instance of the advisorProfileViewModel class.
	 * @return The same viewmodel instance now populated with data.
	 */
	public advisorProfileViewModel populateViewModel(advisorProfileViewModel viewModel)
	{
		viewModel = (advisorProfileViewModel) super.populateAdvisorBaseViewModel(viewModel);
		viewModel = this.advisor.populateViewModel(viewModel);
		viewModel = this.homeInstitution.populateViewModel(viewModel);
		
		return viewModel;
	}
}