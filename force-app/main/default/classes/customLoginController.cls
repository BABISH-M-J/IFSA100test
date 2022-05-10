/**
 * Controller for the login page of the custom portal
 * @author Cameron Ames
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class customLoginController
{
	/**
	 * Container for page data.
	 */
	public customLoginViewModel viewModel {get;set;}

	/**
	 * Constructor function.
	 * 	can take the id parameter from the URL and customize the look and feel of the page to match the HI.
	 */
	public customLoginController()
	{
		String homeInstitutionId = ApexPages.currentPage().getParameters().get('id');

		try
		{
			viewModel = new customLoginViewModel();
			
			//Customize look and feel of page
			if(homeInstitutionId != null)
			{
				Home_Institution__c institution = (Home_Institution__c) apexQueryUtility.selectAllFrom('Home_Institution__c', 'Id = \'' + homeInstitutionId + '\'').get(0);
				viewModel.forQuestions = institution.For_Questions__c;
				viewModel.name = institution.Name;
				viewModel.primaryColor = institution.Primary_Color__c;
				viewModel.secondaryColor = institution.Secondary_Color__c;
				viewModel.splashPageInfo = institution.Splash_Page_Info__c;
				viewModel.attachmentId = institution.Attachment_Id__c;
			}
		}
		catch (Exception e)
		{
			apexErrorUtility.debug(LoggingLevel.WARN, e.getMessage());
			viewModel = new customLoginViewModel();
		}
	}

	/**
	 * Takes user name and password and attempts to log the student in.
	 * @return a page reference indicating that the student has been granted access (to the default page) or has not (null)
	 */
	public PageReference login()
	{
    	return Site.login(viewModel.username + '.ifsa', viewModel.password, null);
	}
}