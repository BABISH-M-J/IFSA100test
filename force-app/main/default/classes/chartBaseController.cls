/**
 * CHART Base Visualforce Page Controller.
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public without sharing abstract class chartBaseController extends portalBaseController
{
	protected User chartUser {get;set;}
	protected Contact chartContact {get;set;}
	protected Account chartAccount {get;set;}
	/**
	 * Constructor, Initializes derived classes with a common set of data
	 */
	public chartBaseController() 
	{
		super();

		try
		{
			this.chartUser = (User) apexQueryUtility.selectAllFrom('User', 'Profile.Name', 'Id = \'' + this.userId + '\'').get(0);
			this.chartContact = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Home_Institution__r.Name, Account.Name, Active_Application__r.Name', 'Id = \'' + this.chartUser.ContactId + '\'').get(0);
			this.chartAccount = (Account) apexQueryUtility.selectAllFrom('Account', 'Id = \'' + this.chartContact.AccountId + '\'').get(0);
		}
		catch(Exception e)
		{
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
	}
	/**
	 * Populates <<chartBaseViewModel>> with data
	 * @param viewModel An instance of <<chartBaseViewModel>> to populate
	 * @return <<chartBaseViewModel>> 
	 */
	protected chartBaseViewModel populateViewModel(chartBaseViewModel viewModel)
	{
		viewModel = (chartBaseViewModel) super.populatePortalBaseViewModel(viewModel);
		System.debug(chartUser);
		System.debug(chartContact);
		System.debug(chartAccount);
		if(chartContact != null)
		{
			viewModel.firstName = this.chartContact.FirstName;
			viewModel.preferredName = this.chartContact.Preferred_Name__c;
			viewModel.lastName = this.chartContact.LastName;
			viewModel.contactId = this.chartContact.Id;
			viewModel.email = this.chartContact.Email;
			// viewModel.homeInstitutionName = this.chartContact.Home_Institution__r.Name;
			System.debug(chartUser.Profile.Name);
			if(chartUser.Profile.Name.contains('Student')){
				viewModel.userHomeInstitutionName = this.chartContact.Home_Institution__r.Name;
				viewModel.userHomeInstitutionId = this.chartContact.Home_Institution__c;
			} else if(chartUser.Profile.Name.contains('Advisor')){
				viewModel.userHomeInstitutionName = this.chartContact.Account.Name;
				viewModel.userHomeInstitutionId = this.chartContact.AccountId;
			}
			viewModel.major = this.chartContact.Major_New__c;
			
			// Course Equivalency Settings from Home Institution Account of Logged In User
			Account ceSettings = [SELECT Id, Name, Course_Equivalency_Search__c, CE_Search_Last_Updated__c, CE_Search_Last_Updated_By__r.Name FROM Account WHERE Id =: chartRemoteMethods.getHomeInstitutionAccount() LIMIT 1];
			viewModel.ceSearch = ceSettings.Course_Equivalency_Search__c;
			viewModel.ceSearchLastUpdated = ceSettings.CE_Search_Last_Updated__c;
			viewModel.ceSearchLastUpdatedBy = ceSettings.CE_Search_Last_Updated_By__r.Name;
			System.debug('ceSearch: ' + viewModel.ceSearch);
			System.debug('ceSearch Last Update: ' + viewModel.ceSearchLastUpdated);
			System.debug('ceSearch Last Update By: ' + viewModel.ceSearchLastUpdatedBy);
		}
		List<Custom_Community_Setting__mdt> settings = [SELECT DeveloperName, Content__c FROM Custom_Community_Setting__mdt WHERE DeveloperName LIKE 'CHART%'];
		for(Custom_Community_Setting__mdt ccs: settings)
		{
			viewModel.settings.put(ccs.DeveloperName, ccs.Content__c);
		}

		return viewModel;
	}
	/**
	 * Ensures that the user viewing a page built on this class is authorized to do so
	 * @return PageReference
	 */
	public virtual PageReference authorized()
    {
		if(this.chartContact != null && this.chartContact.First_Access_CHART__c == null)
		{
			this.chartContact.First_Access_CHART__c = DateTime.now();
			database.update(this.chartContact);
		}
		if(this.chartUser.Name == 'CHART Site Guest User')
		{
			return new PageReference('/CH_Login?projectId=' + ApexPages.currentPage().getParameters().get('projectId'));
		}
		if(!this.chartUser.Email_Confirmed_for_CHART__c && this.chartUser.ContactId != null)
		{
			return new PageReference('/CH_EmailConfirmation');
		}
				
		return null;
	}
	
}