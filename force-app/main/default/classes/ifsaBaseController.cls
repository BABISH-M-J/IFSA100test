/**
 * Base controller. All controllers, internal and portal, inherit from this controller.
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing abstract class ifsaBaseController
{
	/**
	 * The functional current user id. Will be the actual user's current Id, or will be an Id specified by the system administrator.
	 */
	protected Id userId {get;set;}

	/**
	 * Base constructor function. Sets the functional user id.
	 */
	protected ifsaBaseController()
	{
		this.userId = this.getUserId();
	}

	/**
	 * Gets the functional current user id, which is the current user or the sys admin specified Id.
	 * @return The Id to use as the current user.
	 */
	protected virtual Id getUserId()
	{
		//Get the URL Parameter Id
		String userId;
		try {
			userId = ApexPages.currentPage().getParameters().get('id');	
		} catch (NullPointerException e) {
			
		}		

		//Get the current user
		User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];

		//If there is an Id parameter AND the current user is a sys admin, use the specified id. Otherwise, use the current.
		if(userId != null && currentUser.Profile.Name == 'System Administrator')
		{
			return userId;
		}
		else
		{
			return UserInfo.getUserId();
		}
	}

	/**
	 * Populates a view model with applicable data
	 * @param viewModel the pre-existing view model.
	 * @return the same view model instance, populated with data.
	 */
	public ifsaBaseViewModel populateIfsaBaseViewModel(ifsaBaseViewModel viewModel)
	{
		viewModel.userId = this.userId;

		return viewModel;
	}
}