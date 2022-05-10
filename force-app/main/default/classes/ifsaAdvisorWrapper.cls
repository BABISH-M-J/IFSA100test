/**
 * Wrapper class for an advisor. Contains a user and contact but not an account because that is grouped on an institutional-level
 * @author Cameron Ames
 * TODO Break out the save function into a parent class for all wrappers
 */
// ApexDoc updated 2/16/2021 Brock Barlow
global with sharing class ifsaAdvisorWrapper
{
	/**
	 * The advisors's user object.
	 */
	private User advisorUser {get;set;}

	/**
	 * The advisor's contact object.
	 */
	private Contact advisorContact {get;set;}

	/**
	 * Constructor function. Takes the user id and queries for all advisor data.
	 * @param userId The Id of the user to use for data.
	 */
	public ifsaAdvisorWrapper(Id userId)
	{
		this.advisorUser = (User) apexQueryUtility.selectAllFrom('User', 'Id = \'' + userId + '\'').get(0);
		this.advisorContact = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Id = \'' + this.advisorUser.ContactId + '\'').get(0);
	}
	
	/**
	 * Constructor function. Accepts the sObjects that are manually provided.
	 * @param aUser The user sObject.
	 * @param aContact The contact sObject.
	 */
	public ifsaAdvisorWrapper(User aUser, Contact aContact)
	{
		this.advisorUser = aUser;
		this.advisorContact = aContact;
	}

	/**
	 * Commits the sObject changes to the database.
	 * @return Boolean indicating if the items were saved.
	 */
	public Boolean save()
	{
		List<Database.SaveResult> results = new List<Database.SaveResult>();
		
		if(!Test.isRunningTest())
		{
			Database.update(new List<sObject>{this.advisorContact});
		}
		
		Boolean isSaved = true;
		for(Database.SaveResult result : results)
		{			
			if(!result.isSuccess())
			{
				isSaved = false;
				for(Database.Error error : result.getErrors())
				{
					apexErrorUtility.debug(LoggingLevel.ERROR, error.getMessage());
				}
			}
		}
		
		return isSaved;
	}

	/**
	 * View model populator for the advisor portal base class.
	 * @param viewModel A pre-built instance of the view model class.
	 * @return The same view model instance, now populated with advisor data.
	 */
	public advisorBaseViewModel populateAdvisorBaseViewModel(advisorBaseViewModel viewModel)
	{
		viewModel.firstName = this.advisorContact.FirstName;
		viewModel.lastName = this.advisorContact.LastName;
		viewModel.approvedForAdvising = this.advisorContact.Approved_for_Advising__c;
		viewModel.approvedForProgramAuthorizations = this.advisorContact.Approved_for_Program_Authorizations__c;
		viewModel.homeInstitutionId = this.advisorContact.Home_Institution__c;

		return viewModel;
	}
	
	/**
	 * View model populator for the advisor portal profile class.
	 * @param viewModel A pre-built instance of the view model class.
	 * @return the same view model instance, now populated with advisor data.
	 */
	public advisorProfileViewModel populateViewModel(advisorProfileViewModel viewModel)
	{
		viewModel.AdvisorApprovalCountries = this.advisorContact.Approval_Countries__c;
		viewModel.AdvisorEmail = this.advisorContact.Email;
		viewModel.AdvisorFax = this.advisorContact.Fax;
		viewModel.AdvisorMailingCity = this.advisorContact.MailingCity;
		viewModel.AdvisorMailingCountry = this.advisorContact.MailingCountry;
		viewModel.AdvisorMailingPostalCode = this.advisorContact.MailingPostalCode;
		viewModel.AdvisorMailingState = this.advisorContact.MailingState;
		viewModel.AdvisorMailingStreet = this.advisorContact.MailingStreet;
		viewModel.AdvisorMobilePhone = this.advisorContact.MobilePhone;
		viewModel.AdvisorOfficeName = this.advisorContact.Office_Name__c;
		viewModel.AdvisorPhone = this.advisorContact.Phone;
		viewModel.AdvisorReceiveAlerts = this.advisorContact.Receive_Alerts__c;
		viewModel.AdvisorReceiveApprovals = this.advisorContact.Do_not_send_approval__c == true ? false : true;
		viewModel.AdvisorReceiveNewsletter = this.advisorContact.Receive_Newsletter__c;
		viewModel.AdvisorTitle = this.advisorContact.Title;
		viewModel.AdvisorType = this.advisorContact.Advisor_Type__c;		
		return viewModel;
	}
	
	/**
	 * View model populator for the advisor portal institution class.
	 * @param viewModel A pre-built instance of the view model class.
	 * @return the same view model instance, now populated with advisor data.
	 */
	public advisorInstitutionViewModel populateViewModel(advisorInstitutionViewModel viewModel)
	{
		viewModel.AdvisorType = this.advisorContact.Advisor_Type__c;
		
		return viewModel;
	}
	
	/**
	 * Populates a (view model) record on the list of advisors for an institution.
	 * @param viewModel An instance of the view model class.
	 * @return the same view model instance, now populated with advisor data.
	 */
	public advisorInstitutionalAdvisorsViewModel populateViewModel(advisorInstitutionalAdvisorsViewModel viewModel)
	{
		viewModel.AdvisorApprovedForAdvising = this.advisorContact.Approved_For_Advising__c;
		viewModel.AdvisorFirstName = this.advisorContact.FirstName;
		viewModel.AdvisorId = this.advisorContact.Id;
		viewModel.AdvisorLastName = this.advisorContact.LastName;
		viewModel.AdvisorTitle = this.advisorContact.Title;
		
		return viewModel;
	}
	
	/**
	 * Takes view model data and saves it to these sObjects.
	 * @param viewModel The data to save.
	 * @return Boolean value indicating if the save was successful.
	 */
	public Boolean saveInformation(advisorProfileViewModel viewModel)
	{
		advisorContact.Email = viewModel.AdvisorEmail;
		advisorContact.Fax = viewModel.AdvisorFax;
		advisorContact.MailingCity = viewModel.AdvisorMailingCity;
		advisorContact.MailingCountry = viewModel.AdvisorMailingCountry;
		advisorContact.MailingPostalCode = viewModel.AdvisorMailingPostalCode;
		advisorContact.MailingState = viewModel.AdvisorMailingState;
		advisorContact.MailingStreet = viewModel.AdvisorMailingStreet;
		advisorContact.MobilePhone = viewModel.AdvisorMobilePhone;
		advisorContact.Office_Name__c = viewModel.AdvisorOfficeName;
		advisorContact.Phone = viewModel.AdvisorPhone;
		advisorContact.Receive_Alerts__c = viewModel.AdvisorReceiveAlerts;		
		advisorContact.Do_not_send_approval__c = viewModel.AdvisorReceiveApprovals == true ? false : true;
		advisorContact.Receive_Newsletter__c = viewModel.AdvisorReceiveNewsletter;
		advisorContact.Title = viewModel.AdvisorTitle;
		advisorContact.Advisor_Type__c = viewModel.AdvisorType;
		advisorContact.FirstName = viewModel.FirstName;
		advisorContact.LastName = viewModel.LastName;
		
		return this.save();
	}

	/**
	 * Getter for the account Id 
	 * @return the Account Id of the advisor.
	 */
	public Id getAccountId()
	{
		return this.advisorContact.AccountId;
	}

	/**
	 * Indicates if the advisor has been approved.
	 * @return a Boolean indicating if the advisor is approved for advising.
	 */
	public Boolean isApprovedForAdvising()
	{
		return this.advisorContact.Approved_for_Advising__c;
	}

	webService static String createAdvisorUser(Id contactId)
	{
		List<User> currentUsers = [SELECT Id, ContactId, Name FROM User WHERE ContactId =: contactId];
		if(currentUsers.size() > 0)
		{
			return 'This advisor already has access to the advisor portal.';
		}
		
		Contact advisorContact = [SELECT FirstName, LastName, Email, Phone FROM Contact WHERE Id =: contactId LIMIT 1];
		if(advisorContact.FirstName == null || advisorContact.FirstName == '')
		{
			return 'ERROR: The advisor must have a first name.';
		}
		if(advisorContact.LastName == null || advisorContact.LastName == '')
		{
			return 'ERROR: The advisor must have a last name.';
		}
		if(advisorContact.Email == null || advisorContact.Email == '')
		{
			return 'ERROR: The advisor must have a valid email address.';
		}

		User advisorUser = new User();
		advisorUser.FirstName = advisorContact.FirstName;
		advisorUser.LastName = advisorContact.LastName;
		advisorUser.Email = advisorContact.Email;
		advisorUser.Phone = advisorContact.Phone;
		if(advisorContact.Email.split('@').get(0).length() > 20)
		{
			advisorUser.CommunityNickname = advisorContact.Email.split('@').get(0).substring(0,20) + String.valueOf(Math.random() * 100);
		}
		else
		{
			advisorUser.CommunityNickname = advisorContact.Email.split('@').get(0) + String.valueOf(Math.random() * 100);
		}
		
		Integer aliasEnding = 4;
		if(advisorContact.LastName.length() < 4)
		{
			aliasEnding = advisorContact.LastName.length();
		}
		
		advisorUser.Alias = advisorContact.FirstName.substring(0,1) + advisorContact.LastName.substring(0,aliasEnding);
		advisorUser.Username = advisorContact.Email + '.ifsa';
		advisorUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'IFSA Advisor User' LIMIT 1].Id;
		advisorUser.EmailEncodingKey = 'UTF-8';
		advisorUser.LanguageLocaleKey = 'en_US';
		advisorUser.LocaleSidKey = 'en_US';
		advisorUser.TimeZoneSidKey = 'America/Indiana/Indianapolis';
		advisorUser.ContactId = advisorContact.Id;

		Database.SaveResult result;

		try
		{
			 result = Database.insert(advisorUser);
		}
		catch (Exception e)
		{
			System.debug(LoggingLevel.ERROR, e.getMessage());
			return 'ERROR : ' + e.getMessage();
		}
		
		if(result.isSuccess())
		{
			return 'The advisor User has been created and the advisor has been sent a password reset email.';
		}
		
		return String.valueOf(result.getErrors().get(0));
	}

	@InvocableMethod(label='Cascade fields to user' description='Modifies User record to conform to Contact.')
	public static void cascadeToUser(List<Id> contactIds)
	{
		//Replaced this future method with queueable job. If too many queueable jobs are running this non-essential method will not run.
		//ifsaAdvisorWrapper.updateUsers(contactIds);
		if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()){
   			ID jobID = System.enqueueJob(new syncUserContactRecords(contactIds));
		}
	}

	/*@future(Delay='0')
	public static void updateUsers(List<Id> contactIds)
	{
		List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, Phone, Title FROM Contact WHERE Id IN: contactIds AND RecordType.Name =: 'Advisor'];
		List<User> users = [SELECT Id, FirstName, LastName, Email, Phone, UserName, ContactId, CommunityNickname FROM User WHERE ContactId IN: contactIds];

		for(Contact aContact : contacts)
		{
			for(User aUser : users)
			{
				if(aUser.ContactId == aContact.Id)
				{
					aUser.UserName = aContact.Email + '.ifsa';
					aUser.FirstName = aContact.FirstName;
					aUser.LastName = aContact.LastName;
					aUser.Email = aContact.Email;
					aUser.Title = aContact.Title;
					aUser.Phone = aContact.Phone;
				}
			}
		}
		
		if(!Test.isRunningTest())
		{
			Database.update(users);
		}
	}*/
}