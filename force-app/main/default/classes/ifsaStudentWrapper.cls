/**
 * Wrapper class for a student. Contains a user, contact, and account.
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public with sharing class ifsaStudentWrapper
{
	/**
	 * The student's user object.
	 */
	private User studentUser {get;set;}

	/**
	 * The student's contact object.
	 */
	private Contact studentContact {get;set;}

	/**
	 * The student's Account object.
	 */
	private Account studentAccount {get;set;}

	/**
	 * Constructor function. Takes the user id and queries for all student data.
	 * @param userId The Id of the user to use for data.
	 */
	public ifsaStudentWrapper(Id userId)
	{
		this.studentUser = (User) apexQueryUtility.selectAllFrom('User', 'Id = \'' + userId + '\'').get(0);
		this.studentContact = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Id = \'' + this.studentUser.ContactId + '\'').get(0);
		this.studentAccount = (Account) apexQueryUtility.selectAllFrom('Account', 'Id = \'' + this.studentContact.AccountId + '\'').get(0);
	}
	
	public ifsaStudentWrapper(Id contactId, Boolean startWithContact)
	{				
		this.studentContact = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Id = \'' + contactId + '\'').get(0);
		//this.studentUser = (User) apexQueryUtility.selectAllFrom('User', 'ContactId = \'' + this.studentContact.Id + '\'').get(0);
		this.studentAccount = (Account) apexQueryUtility.selectAllFrom('Account', 'Id = \'' + this.studentContact.AccountId + '\'').get(0);
	}

	/**
	 * Constructor function. Accepts the sObjects that are manually provided.
	 * @param aUser The user sObject.
	 * @param aContact The contact sObject.
	 * @param anAccount The account sObject.
	 */
	public ifsaStudentWrapper(User aUser, Contact aContact, Account anAccount)
	{
		this.studentUser = aUser;
		this.studentContact = aContact;
		this.studentAccount = anAccount;
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
			results = Database.update(new List<sObject>{this.studentAccount, this.studentContact});
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
	 * commits the information in the view model to the database.
	 * @param viewModel The information to be saved
	 * @return Boolean indicating whether the save was good or not
	 */
	public boolean saveInformation(studentApplyItemDetailsViewModel viewModel)
	{
    	this.studentContact.MailingCity = viewModel.mailingCity;
    	this.studentContact.MailingCountry = viewModel.mailingCountry;
    	this.studentContact.MailingPostalCode = viewModel.mailingZip;
    	this.studentContact.MailingState = viewModel.mailingState;
    	this.studentContact.MailingStreet = viewModel.mailingStreet;
    	this.studentContact.OtherCity = viewModel.sameOtherAddress != null ? viewModel.sameOtherAddress ? viewModel.mailingCity : viewModel.otherCity : viewModel.otherCity;
    	this.studentContact.OtherCountry = viewModel.sameOtherAddress != null ? viewModel.sameOtherAddress ? viewModel.mailingCountry : viewModel.otherCountry : viewModel.otherCountry;
    	this.studentContact.OtherPostalCode = viewModel.sameOtherAddress != null ? viewModel.sameOtherAddress ? viewModel.mailingZip : viewModel.otherZip : viewModel.otherZip;
    	this.studentContact.OtherState = viewModel.sameOtherAddress != null ? viewModel.sameOtherAddress ? viewModel.mailingState : viewModel.otherState : viewModel.otherState;
    	this.studentContact.OtherStreet = viewModel.sameOtherAddress != null ? viewModel.sameOtherAddress ? viewModel.mailingStreet : viewModel.otherStreet : viewModel.otherStreet;
    	this.studentAccount.BillingCity = viewModel.sameBillingAddress != null ? viewModel.sameBillingAddress ? viewModel.mailingCity : viewModel.billingCity : viewModel.billingCity;
    	this.studentAccount.BillingCountry = viewModel.sameBillingAddress != null ? viewModel.sameBillingAddress ? viewModel.mailingCountry : viewModel.billingCountry : viewModel.billingCountry;
    	this.studentAccount.BillingPostalCode = viewModel.sameBillingAddress != null ? viewModel.sameBillingAddress ? viewModel.mailingZip : viewModel.billingZip : viewModel.billingZip;
    	this.studentAccount.BillingState = viewModel.sameBillingAddress != null ? viewModel.sameBillingAddress ? viewModel.mailingState : viewModel.billingState : viewModel.billingState;
    	this.studentAccount.BillingStreet = viewModel.sameBillingAddress != null ? viewModel.sameBillingAddress ? viewModel.mailingStreet : viewModel.billingStreet : viewModel.billingStreet;

		return this.save();
	}

	/**
	 * takes a view model and populates it with data
	 * @param viewModel The pre-created view model
	 * @return the same view model instance
	 */
	public studentBaseViewModel populateStudentBaseViewModel(studentBaseViewModel viewModel)
	{
		viewModel.studentFirstName = this.studentUser.FirstName;
		viewModel.studentLastName = this.studentUser.LastName;
		
		return viewModel;
	}

	/**
	 * takes a view model and populates it with data
	 * @param viewModel The pre-created view model
	 * @return the same view model instance
	 */
	public customBaseViewModel populateCustomBaseViewModel(customBaseViewModel viewModel)
	{
		viewModel.studentFirstName = this.studentUser.FirstName;
		viewModel.studentLastName = this.studentUser.LastName;
		
		return viewModel;
	}

	/**
	 * takes a view model and populates it with data
	 * @param viewModel The pre-created view model
	 * @return the same view model instance
	 */
	public customProfileViewModel populateViewModel(customProfileViewModel viewModel)
	{
		viewModel.StudentBirthdate = this.studentContact.Birthdate;
		viewModel.StudentCitizenship = this.studentContact.Citizenship__c;
		viewModel.StudentEmail = this.studentContact.Email;
		viewModel.StudentMailingCountry = this.studentContact.MailingCountry;
		viewModel.StudentMiddleName = this.studentContact.Middle_Name__c;
		viewModel.StudentMobilePhone = this.studentContact.Phone;
		viewModel.StudentPhotoId = this.studentContact.Photo_Id__c;
		viewModel.StudentSex = this.studentContact.Sex__c;

		return viewModel;
	}

	/**
	 * getter method for the home institution id
	 * @return The Id of the home institution.
	 */
	public Id getHomeInstitutionId()
	{
		return this.studentContact.Home_Institution__c;
	}

	/**
	 * getter method for the active application id
	 * @return The Id of the active application.
	 */
	public Id getActiveApplicationId()
	{
		return this.studentContact.Active_Application__c;
	}

	/**
	 * getter method for the contact id
	 * @return The Id of the contact.
	 */
	public Id getContactId()
	{
		return this.studentContact.Id;
	}
	
	/**
	 * getter method for the contact sObject. Deprecated.
	 * @return The contact sObject
	 */
	public Contact getContact()
	{
		return this.studentContact;
	}
	
	/**
	 * getter method for the account sObject. Deprecated.
	 * @return The account sObject
	 */
	public Account getAccount()
	{
		return this.studentAccount;
	}
	
	/**
	 * getter method for the user sObject. Deprecated.
	 * @return The user sObject
	 */
	public User getUser()
	{
		return this.studentUser;
	}
}