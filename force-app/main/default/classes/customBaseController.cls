/**
 * Controller that contains base functionality for the custom portal.
 * TODO: Break out skin data population into a home institution wrapper
 * THE CUSTOM PORTAL IS POWERD BY THE CATALOG STUDENT PORTAL SO THAT EFFORTS ARE NOT DUPLICATED AS OF SUMMER 2020.
 * @author Cameron Ames
 */
// ApexDoc updated 1/28/2021 Brock Barlow
 public without sharing abstract class customBaseController extends portalBaseController
{
	/**
	 * @description Home Institution sObject
	 */
	protected Home_Institution__c homeInstitution {get;set;}

	/**
	 * @description Student wrapper object
	 */
	protected ifsaStudentWrapper student {get;set;}

	/**
	 * @description Constructor function. Gets student and home institution sObjects.
	 * @return void
	 */
	public customBaseController()
	{
		//Perform base controller operations
		super();

		try
		{
			//Get student sObjects followed by home institution
			this.student = new ifsaStudentWrapper(this.userId);
			this.homeInstitution = (Home_Institution__c) apexQueryUtility.selectAllFrom('Home_Institution__c', 'Id = \'' + this.student.getHomeInstitutionId() + '\'').get(0);
		}
		catch(Exception e)
		{
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
	}

	/**
	 * @description Method to populate custom portal view models with standard data.
	 * @see customBaseViewModel
	 * @return customBaseViewModel
	 */
	protected customBaseViewModel populateCustomBaseViewModel(customBaseViewModel viewModel)
	{
		viewModel = (customBaseViewModel) super.populatePortalBaseViewModel(viewModel);
		viewModel = student.populateCustomBaseViewModel(viewModel);

		//This needs its own method in a home institution wrapper - viewModel = hostInstitutionWrapper.populateViewModel(viewModel);
		viewModel.skinData = new customLoginViewModel();
		viewModel.skinData.Name = this.homeInstitution.Name;
		viewModel.skinData.forQuestions = this.homeInstitution.For_Questions__c;
		viewModel.skinData.primaryColor = this.homeInstitution.Primary_Color__c;
		viewModel.skinData.secondaryColor = this.homeInstitution.Secondary_Color__c;

		return viewModel;
	}
}