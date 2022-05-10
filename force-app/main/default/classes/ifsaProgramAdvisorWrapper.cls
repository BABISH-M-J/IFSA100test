/**
 * Wrapper class for the program advisor (User)
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class ifsaProgramAdvisorWrapper
{
	/**
	 * PA User sObject.
	 */
	private User paUser {get;set;}

	/**
	 * Constructor. Takes the Id and validates that it is a PA.
	 * @param userId The Id of the PA User.
	 */
	public ifsaProgramAdvisorWrapper(Id userId)
	{
		this.paUser = (User) apexQueryUtility.selectAllFrom('User', 'Profile.Name', 'Id = \'' + userId + '\'').get(0);
		System.debug(LoggingLevel.ERROR, this.paUser.Profile.Name);
		if(this.paUser.Profile.Name != 'IFSA Program Advisor')
		{
			apexErrorUtility.throwException(new ifsaDataException('The given user was not an IFSA Program Advisor.'));
		}
	}

	/**
	 * Constructor. Takes the given user sObject. Does NOT validate that it is indeed a PA.
	 * @param aUser The user sObject.
	 */
	public ifsaProgramAdvisorWrapper(User aUser)
	{
		this.paUser = aUser;
	}

	/**
	 * Takes the view model and fills it with the appropriate data
	 * @param viewModel the pre-built view model class
	 * @return The same view model instance, now populated with data.
	 */
	public studentApplyViewModel populateViewModel(studentApplyViewModel viewModel)
	{
    	viewModel.advisorFirstName = this.paUser.FirstName;
    	viewModel.advisorLastName = this.paUser.LastName;
    	viewModel.advisorPhone = this.paUser.Phone;
    	viewModel.advisorPhotoUrl = this.paUser.FullPhotoUrl;
		viewModel.advisorEmail = this.paUser.Email;
		
		return viewModel;
	}
}