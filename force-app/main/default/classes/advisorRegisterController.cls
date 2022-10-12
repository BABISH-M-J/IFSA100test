/**
 * Controller for the sign-up page of the advisor portal.
 * @author Cameron Ames
 */
// ApexDoc updated 1/23/2021 Brock Barlow
 public without sharing class advisorRegisterController
{
	/**
	 * Container for all data needed on the page.
	 * @see advisorRegisterViewModel
	 */
    public advisorRegisterViewModel viewModel {get;set;}

	/**
	 * Custom Error messages.
	 */
	public List<String> pageMessages {get;set;}

	private Portal_System_Message__mdt message {get;set;}

	/**
	 * Constructor function. Creates a blank view model and populates the list of home Institutions.
	 * @return void
	 */
    public advisorRegisterController()
    {

        this.viewModel = new advisorRegisterViewModel();
		this.viewModel.displayCustomMessages = false;
		try
		{
			this.message = [SELECT MasterLabel, Affected_Portal__c, Is_Lockdown_Active__c, Message__c, Message_End_Date__c, Message_Start_Date__c FROM Portal_System_Message__mdt WHERE Affected_Portal__c = 'Advisor' AND Message_Start_Date__c <=: Date.today() AND Message_End_Date__c >=: Date.today()].get(0);
		}
		catch (ListException ex)
		{
			system.debug('No System Messages at this time');
		}
		this.viewModel.systemMessage = this.message.Message__c;
		this.viewModel.isLockDownActive = this.message.Is_Lockdown_Active__c == true ? true : false;
		this.viewModel.homeInstitutions = [SELECT Id, Name FROM Home_Institution__c];
    }

	/**
	 * Authorization function required to be implemented on every page. This action is called upon page load.
	 * @return PageReference
	 */
    public PageReference validateAccess()
	{
		//If the portal has been locked down redirect to message screen
		if(this.viewModel.isLockDownActive)
		{
			return new PageReference('/advisorportal/AP_PortalMessage');
		}
        // Other wise return null (is authorized) because no authorization is needed.
		return null;
	}
	
	/**
	 * determines if the password is allowed.
	 * @returns A boolean indicating the validity of the password.
	 */
    private Boolean isValidPassword()
    {
        return viewModel.password == viewModel.confirmPassword;
    }

	/**
	 * Searches home institution table for names matching the search query.
	 * @return List<Home_Institution__c>
	 */
    @RemoteAction
    public static List<Home_Institution__c> searchHomeInstitution(String SearchTerm) 
    {
        List<Home_Institution__c> schools = Database.query('Select Id, Name from Home_Institution__c where name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' ORDER BY Name ASC');
        return schools;
    }

	/**
	 * Action method to register the user.
	 * @return PageReference
	 */
    public PageReference registerUser()
    {
        return null;
    }

	/**
	 * Function used login to the website.
	 * @return PageReference
	 */
    public PageReference login()
    {
        return Site.login(viewModel.email + '.ifsa', viewModel.password, null);
    }
	@RemoteAction
    public static String register(String jsonData) // Changed return property from PageReference to Boolen for now.
    {
		// Create viewModel from JSON
        advisorRegisterViewModel viewModel;
		System.debug(jsonData);
		try
		{
			viewModel = (advisorRegisterViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('advisorRegisterViewModel'));
            System.debug('View Model after parse: ' + viewModel);
		}
		catch(Exception e)
		{
			System.debug(LoggingLevel.WARN, e.getMessage());
		}
		
		return createUserRecord(viewModel);
	}

	/**
	 * Creates a new user, uses an existing account and contact record if they exist
	 * @param viewModel <<advisorRegisterViewModel>>
	 * @return String
	 */
    private static String createUserRecord(advisorRegisterViewModel viewModel)
    {
        try
        {
            Account homeInstAccount = [SELECT Id, Institution__c, Institution__r.Field_Director__c FROM Account WHERE Institution__c =: viewModel.institutionId AND RecordType.Name = 'Home Institution'].get(0);
            
            //Create a portal user with the given info
            User newUser = new User();
			newUser.Username = viewModel.email + '.ifsa';
			try 
			{
				User existingUser = [SELECT Id FROM User WHERE Username =: newUser.Username];
				throw new advisorRegisterControllerException('A user with the email ' + viewModel.email + ' already exists. If you would like to reset your password, <a href="advisorForgotPassword">click here</a>. If you continue to need help, contact Institutional Engagement at <a href="mailto:mailto:InstitutionalEngagement@ifsa-butler.org">InstitutionalEngagement@ifsa-butler.org</a>.');
			}
			catch (Exception e) 
			{
				if(e instanceOf QueryException)
				{
					System.debug(LoggingLevel.INFO, 'We want a QueryException exception here!');
				}
				else if(e instanceOf advisorRegisterControllerException)
				{
					return 'ERROR: ' + e.getMessage();
				}
				else
				{
					throw e;
				}				
			}
			
			newUser.CommunityNickname = viewModel.email.replaceAll('[^a-zA-Z0-9]', '');
            if(newUser.CommunityNickname.length() > 40){
                newUser.CommunityNickname = newUser.CommunityNickname.substring(0,40);
            } 
			newUser.Email = viewModel.email;
			newUser.Firstname = viewModel.firstName;
			newUser.LastName = viewModel.lastName;
			newUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'IFSA Advisor User'].get(0).Id;
			System.debug('12345'+newUser.ProfileId);
            System.debug('112345'+homeInstAccount);
            System.debug('1112345'+newUser);
            System.debug('11112345'+homeInstAccount.Id);
            system.debug('pass'+viewModel.password);
            // added by powerfluence based on Clayton req 03/29/2022 starts
			//DateTime now = DateTime.now();
			DateTime now = Date.today();
             //added by powerfluence based on Clayton req 03/29/2022 ends
            String userId = Site.createPortalUser(newUser, homeInstAccount.Id, viewModel.password);
			 System.debug('123451'+userId);
            //If the user ID is not null that means the user was created
            if(userId == null)
            {
				
				newUser = [SELECT Id, ContactId, Username FROM User WHERE ProfileId =: newUser.ProfileId AND CreatedDate >=: now AND Email =: viewModel.email].get(0);
				               
                system.debug('testuser123'+newUser);
				
			}
			else
			{
				newUser = [SELECT Id, ContactId, Username FROM User WHERE Id =: userId];
            }
			Contact advisorContact = new Contact(Id = newUser.ContactId, FirstName = viewModel.FirstName, LastName = viewModel.LastName, RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId());
			advisorContact.AccountId = homeInstAccount.Id;
			advisorContact.Home_Institution__c = homeInstAccount.Institution__c;
			advisorContact.Contact_Source__c = 'Advisor Portal';
			advisorContact.First_Access_Advisor_Portal__c = DateTime.now();
			database.update(advisorContact);
			PageReference pr = Site.login(newUser.Username, viewModel.password, null);
			return pr.getUrl();
		}
        catch(Exception e)
        {
            system.debug(LoggingLevel.WARN, e.getMessage());
        }

        return 'ERROR: Sorry, but we could not create an account for you. Please make sure you filled out all the fields. If you continue to have trouble, contact IFSA at <a href="mailto:mailto:InstitutionalEngagement@ifsa-butler.org">InstitutionalEngagement@ifsa-butler.org</a>.';
	}
	
	/**
	 * Exception class for <<advisorRegisterController>>
	 */
	public class advisorRegisterControllerException extends Exception {}
}