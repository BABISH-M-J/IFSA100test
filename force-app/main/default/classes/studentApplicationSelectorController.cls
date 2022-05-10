/**
* @description Controller class to allow the user to change their active application
* @author Brock Barlow
*/
public without sharing class studentApplicationSelectorController extends portalBaseController
{	
	
	public studentApplicationSelectorViewModel viewModel {get;set;}
	public String selectedApplicationId {get;set;}
	protected User studentUser {get;set;}
	protected Contact studentContact {get;set;}
	protected Account studentAccount {get;set;}	
	
	public studentApplicationSelectorController() 
	{
		
		super();
		
		this.studentUser = (User) apexQueryUtility.selectAllFrom('User', 'Id = \'' + this.userId + '\'').get(0);
		this.studentContact = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Active_Application__r.Name', 'Id = \'' + this.studentUser.ContactId + '\'').get(0);
		this.studentAccount = (Account) apexQueryUtility.selectAllFrom('Account', 'Id = \'' + this.studentContact.AccountId + '\'').get(0);		
		this.viewModel = new studentApplicationSelectorViewModel();				
		populateViewModel(this.viewModel);		
		this.viewModel.applications = getApplications();
	}

	private studentBaseViewModel populateViewModel(studentBaseViewModel viewModel)
	{
		viewModel.studentFirstName = this.studentContact.FirstName;
		viewModel.studentLastName = this.studentContact.LastName;
		viewModel.contactId = this.studentContact.Id;
		//viewModel.applicationStatus = this.application.Status__c;
		//viewModel.hasHousing = this.application.Housing_Assignment__c != null && (this.application.Status__c == 'Accepted' || this.application.Status__c == 'Accepted with Conditions');
		List<Application__c> apps = [SELECT Id FROM Application__c WHERE Applicant__c =: this.studentContact.Id AND Status__c != 'Diverted' AND Status__c != 'Withdrawn' AND Status__c != 'Rejected' ];
		viewModel.applicationCount = apps.size();
		system.debug(viewModel.applicationCount);
		viewModel.hasManyApplications = apps.size() > 1;

		return viewModel;
	}

	private List<SelectOption> getApplications()
	{		
		List<Application__c> applications = [SELECT Id, Name, Status__c FROM Application__c WHERE Applicant__c =: studentContact.Id];
		List<SelectOption> appOptions = new List<SelectOption>();
				
		for(Application__c app : applications)
		{			
			if(app.Status__c != 'Diverted' && app.Status__c != 'Dropped' && app.Status__c != 'Deferred' && app.Status__c != 'Withdraw' && app.Status__c != 'Unqualified' && app.Status__c != 'Deceased')
			{				
				appOptions.add(new SelectOption(app.Id, app.Name));
			}			
		}		
		return appOptions;
	}

	public PageReference Save()
	{
		PageReference success;
		//Get selected application
		
		Application__c selectedApplication = [SELECT Id, Applicant__c FROM Application__c WHERE Id =: this.selectedApplicationId].get(0);		
		//Get Applicant
		Contact applicant = [SELECT Id, Active_Application__c FROM Contact WHERE Id =: selectedApplication.Applicant__c].get(0);		
		//Set selected application to applicant's active application 
		applicant.Active_Application__c = selectedApplication.Id;
		
		Database.SaveResult sr = database.update(applicant);
		
		if(sr.isSuccess())
		{
			 success = new PageReference('/SP_Apply');

		}
		else
		{
			success = null;
		}
		
		return success;
	}
}