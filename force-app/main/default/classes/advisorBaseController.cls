/**
 * Controller that includes universal advisor portal functionality.
 * @author Cameron Ames
 */
public without sharing abstract class advisorBaseController extends portalBaseController
{
	/**
	 * The advisor object.
	 */
	protected ifsaAdvisorWrapper advisor {get;set;}

	/**
	 * The home institution object
	 */
	protected ifsaHomeInstitutionWrapper homeInstitution {get;set;}
	
	/**
	 * Constructor function.
	 */
	protected advisorBaseController()
	{
		//First execute all standard portal controller functionality
		super();
		
		this.advisor = new ifsaAdvisorWrapper(this.userId);
		this.homeInstitution = ifsaHomeInstitutionWrapper.constructByAccountId(this.advisor.getAccountId());
	}

	/**
	 * takes a view model and populates it with data.
	 * @param viewModel The pre-built instance of the view model class.
	 * @return The same view model instance
	 */
	protected advisorBaseViewModel populateAdvisorBaseViewModel(advisorBaseViewModel viewModel)
	{
		viewModel = this.advisor.populateAdvisorBaseViewModel(viewModel);
		viewModel = (advisorBaseViewModel) super.populatePortalBaseViewModel(viewModel);
		viewModel.InstitutionName = this.homeInstitution.getHomeInstitutionName();

		return viewModel;
	}

	/**
	 * Authorization function. This action is called upon page load. Uses the <pre>advisor.ApprovedForAdvising</pre> field to determine authorization status.
	 * @return PageReference
	 */
	public override virtual PageReference validateAccess()
	{
		//If they aren't approved, direct them to the unauthorized page
		if(!this.advisor.isApprovedForAdvising())
		{
			return new PageReference('/advisorportal/AP_Unauthorized');
		}

		return null;
	}
}