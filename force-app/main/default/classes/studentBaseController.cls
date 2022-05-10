/**
* @description Base class for student portal
* @author Cameron Ames
*/
public without sharing abstract class studentBaseController extends portalBaseController
{
	protected User studentUser {get;set;}
	protected Contact studentContact {get;set;}
	protected Account studentAccount {get;set;}
	protected Application__c application {get;set;}


	protected studentBaseController()
	{
		super();

		try
		{
			this.studentUser = (User) apexQueryUtility.selectAllFrom('User', 'Id = \'' + this.userId + '\'').get(0);
			this.studentContact = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Active_Application__r.Name', 'Id = \'' + this.studentUser.ContactId + '\'').get(0);
			this.studentAccount = (Account) apexQueryUtility.selectAllFrom('Account', 'Id = \'' + this.studentContact.AccountId + '\'').get(0);
			this.application = studentBaseController.getActiveApplication(studentContact);
		}
		catch(Exception e)
		{
			System.debug(LoggingLevel.ERROR, e.getMessage());
		}
	}

	protected studentBaseViewModel populateViewModel(studentBaseViewModel viewModel)
	{
		viewModel = (studentBaseViewModel) super.populatePortalBaseViewModel(viewModel);
		viewModel.studentFirstName = this.studentContact.FirstName;
		viewModel.studentPreferredName = this.studentContact.Preferred_Name__c;
		viewModel.studentLastName = this.studentContact.LastName;
		viewModel.contactId = this.studentContact.Id;
		viewModel.butlerId = this.studentContact.Butler_ID__c;
		viewModel.applicationStatus = this.application.Status__c;
		viewModel.hasFinancialHold = this.application.Financial_Hold__c;
		viewModel.hasHousing = this.application.Housing_Assignment__c != null && (this.application.Status__c == 'Accepted' || this.application.Status__c == 'Accepted (with Conditions)');
		List<Application__c> apps = [SELECT Id FROM Application__c WHERE Applicant__c =: this.studentContact.Id AND Status__c != 'Diverted' AND Status__c != 'Withdrawn' AND Status__c != 'Rejected' ];
		viewModel.applicationCount = apps.size();
		system.debug(viewModel.applicationCount);
		viewModel.hasManyApplications = apps.size() > 1;
		viewModel.isTraveling = this.studentContact.Traveling_Status__c == 'Pre-Program';
		viewModel.isCustom = this.application.Is_Custom__c;

		return viewModel;
	}
	public static Application__c getActiveApplication(Contact student)
	{
		if(student.Compare_Name_to_Active_Application__c == true)
		{
			return (Application__c) apexQueryUtility.selectAllFrom('Application__c', 'Program_Term__r.Program__c', 'Id = \'' + student.Active_Application__c + '\'').get(0);
		}
		else
		{			
			try
			{
				List<String> statuses = new List<String>{'New', 'Registered', 'Program Selected', 'Ready To Submit', 'Submitted', 'Accepted', 'Accepted with Conditions', 'On Site', 'Program Completed'};
				List<Application__c> apps = [SELECT Id, Designation__c, Applicant__r.Name 
											 FROM Application__c 
											 WHERE Applicant__c =: student.id AND
											 Status__c IN: statuses
											 ORDER BY Designation__c NULLS LAST];
				Boolean hasPrimary = false;
				Boolean hasSecondary = false;
				for(Application__c app: apps)
				{
					if(app.Designation__c == 'Primary' && app.Applicant__r.Name == student.Name)
					{
						student.Active_Application__c = app.Id;
						hasPrimary = true;
						return (Application__c) apexQueryUtility.selectAllFrom('Application__c', 'Program_Term__r.Program__c', 'Id = \'' + student.Active_Application__c + '\'').get(0);
					}

				}
				if(!hasPrimary)
				{
					for(Application__c app: apps)
					{
						if(app.Designation__c == 'Secondary' && app.Applicant__r.Name == student.Name)
						{
							student.Active_Application__c = app.Id;
							hasSecondary = true;
							return (Application__c) apexQueryUtility.selectAllFrom('Application__c', 'Program_Term__r.Program__c', 'Id = \'' + student.Active_Application__c + '\'').get(0);
						}
					}
				}
				if(!hasSecondary)
				{
					if(!apps.isEmpty())
					{
						student.Active_Application__c = apps.get(0).Id;
						if(apps.get(0).Applicant__r.Name == student.Name)
						{
							return (Application__c) apexQueryUtility.selectAllFrom('Application__c', 'Program_Term__r.Program__c', 'Id = \'' + student.Active_Application__c + '\'').get(0);
						}
					}
				}
			}
			catch (Exception e)
			{
				system.debug(e.getMessage());
				return null;
			}
		}
		return null;
	}
}