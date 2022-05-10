/**
 * Wrapper class for home instituitons.
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class ifsaHomeInstitutionWrapper
{
	/**
	 * The Application sObject component.
	 */
	private Home_Institution__c homeInstitution {get;set;}

	/**
	 * The Account sObject component. Shared with the institutional advisors.
	 */
	private Account homeInstitutionAccount {get;set;}

	/**
	 * Sometimes we have the account Id and need to constructo this object, but cannot overload the constructor with another method with a single Id parameter.
	 * @param accountId The Account Id of the institution.
	 * @return An instance of ifsaHomeInstitutionWrapper
	 */
	public static ifsaHomeInstitutionWrapper constructByAccountId(Id accountId)
	{
		Account homeInstitutionAccount = (Account) apexQueryUtility.selectAllFrom('Account', 'Id = \'' + accountId + '\'').get(0);
		Home_Institution__c homeInstitution = (Home_Institution__c) apexQueryUtility.selectAllFrom('Home_Institution__c', 'Id = \'' + homeInstitutionAccount.Institution__c + '\'').get(0);
		
		return new ifsaHomeInstitutionWrapper(homeInstitution, homeInstitutionAccount);
	}

	/**
	 * Constructor function.
	 * @param homeInstitutionName The Name of the home institution.
	 */
	public ifsaHomeInstitutionWrapper(String homeInstitutionName)
	{
		this.homeInstitution = (Home_Institution__c) apexQueryUtility.selectAllFrom('Home_Institution__c', 'Name = \'' + homeInstitutionName + '\'').get(0);

		List<Account> accountList = apexQueryUtility.selectAllFrom('Account', 'Institution__c = \'' + this.homeInstitution.Id + '\'');
		if(accountList.size() != 1)
		{
			apexErrorUtility.throwException(new ifsaDataException('There were ' + accountList.size() + ' accounts matching home institution ' + homeInstitutionName + '.'));
		}

		this.homeInstitutionAccount = accountList.get(0);
	}

	/**
	 * Constructor function.
	 * @param homeInstitutionId The Id of the home institution.
	 */
	public ifsaHomeInstitutionWrapper(Id homeInstitutionId)
	{
		this.homeInstitution = (Home_Institution__c) apexQueryUtility.selectAllFrom('Home_Institution__c', 'Id = \'' + homeInstitutionId + '\'').get(0);

		List<Account> accountList = apexQueryUtility.selectAllFrom('Account', 'Institution__c = \'' + homeInstitutionId + '\'');
		if(accountList.size() != 1)
		{
			apexErrorUtility.throwException(new ifsaDataException('There were ' + accountList.size() + ' accounts matching home institution ' + homeInstitutionId + '.'));
		}

		this.homeInstitutionAccount = accountList.get(0);
	}

	/**
	 * Constructor function. Does not perform any checks, since sObjects are being passed directly.
	 * @param aHomeInstitution The home institution sObject.
	 * @param anAccount The account sObject.
	 */
	public ifsaHomeInstitutionWrapper(Home_Institution__c aHomeInstitution, Account anAccount)
	{
		this.homeInstitution = aHomeInstitution;
		this.homeInstitutionAccount = anAccount;
	}
	
	/**
	 * Gets all the advisors associated with this home institution.
	 * @return The list of advisors.
	 */
	public List<ifsaAdvisorWrapper> getAdvisors()
	{
		List<User> userList = apexQueryUtility.selectAllFrom('User', 'Contact.AccountId = \'' + this.homeInstitutionAccount.Id + '\' ORDER BY LastName, FirstName');
		List<Contact> contactList = apexQueryUtility.selectAllFrom('Contact', 'AccountId = \'' + this.homeInstitutionAccount.Id + '\' ORDER BY LastName, FirstName');
		Map<Id, SObject> contactMap = apexConversionUtility.createSObjectMap(contactList, 'Id');
		
		List<ifsaAdvisorWrapper> advisorList = new List<ifsaAdvisorWrapper>();
		for(User aUser : userList)
		{
			advisorList.add(new ifsaAdvisorWrapper(aUser, (Contact) contactMap.get(aUser.ContactId)));
		}
		
		return advisorList;
	}

	/**
	 * Populates an advisor profile page view model with data.
	 * @param A preexisting instance of the view model class.
	 * @return The same view model instance, populated with data.
	 */
	public advisorProfileViewModel populateViewModel(advisorProfileViewModel viewModel)
	{
		viewModel.HomeInstitutionName = this.homeInstitution.Name;
		
		return viewModel;
	}
	
	/**
	 * Populates an advisor institution page view model with data.
	 * @param An instance of the advisor institution view model class
	 * @return The same view model instance populated with data.
	 */
	public advisorInstitutionViewModel populateViewModel(advisorInstitutionViewModel viewModel)
	{
		viewModel.HomeInstitutionAffiliation = this.homeInstitution.Affiliation__c;
		viewModel.HomeInstitutionApprovesAllCalendarPrograms = this.homeInstitutionAccount.Approves_All_Calendar_Programs__c;
		viewModel.HomeInstitutionApprovesAllSummerPrograms = this.homeInstitutionAccount.Approves_All_Summer_Programs__c;
		viewModel.HomeInstitutionDirectBill = this.homeInstitutionAccount.Direct_Bill__c;
		viewModel.HomeInstitutionId = this.homeInstitution.Id;
		viewModel.HomeInstitutionInstitutionType = this.homeInstitutionAccount.Institution_Type__c;
		viewModel.HomeInstitutionName = this.homeInstitution.Name;
		viewModel.HomeInstitutionPaysAccomodation = this.homeInstitutionAccount.Pays_Accommodation__c;
		viewModel.HomeInstitutionPaysAdvancedDeposit = this.homeInstitutionAccount.Pays_Deposit__c;
		viewModel.HomeInstitutionPaysLateWithdrawFees = this.homeInstitutionAccount.Pays_Late_Withdraw_Fees__c;
		//viewModel.HomeInstitutionPaysHousingDeposit = this.homeInstitutionAccount.Pays_Housing_Deposit__c;
		//viewModel.HomeInstitutionPaysSummerPrograms = this.homeInstitutionAccount.Pays_Summer_Programs__c;
		viewModel.HomeInstitutionPaysSupplemental = this.homeInstitutionAccount.Pays_Supplemental_Fees__c;
		viewModel.HomeInstitutionPaysTuition = this.homeInstitutionAccount.Pays_Tuition__c;
		
		return viewModel;
	}
	
	/**
	 * Getter for the account Id
	 * @return The Account Id
	 */
	public Id getAccountId()
	{
		return this.homeInstitutionAccount.Id;
	}

	public Id getHomeInstitutionId()
	{
		return this.homeInstitution.Id;
	}

	public String getHomeInstitutionName()
	{
		return this.homeInstitutionAccount.Name;
	}
}