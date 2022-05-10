/**
 * Controller class for CH_Login page - Has methods to log in an existing user or create a new user
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public without sharing class chartLoginController
{
    /**
     * Viewmodel for page, contains all of the information required for CH_Login to function, @see <<chartLoginViewModel>>
     */
    public chartLoginViewModel viewModel {get;set;}
    /**
	 * Google Anayltics Id
	 */
    public String gaId {get;set;}
    /**
	 * Google Tag Manager Id
	 */
    public String gtmId {get;set;}	
    /**
     * Constructor, collects the data to populate an instance of <<chartLoginViewModel>>
     */
    public chartLoginController() {
        GoogleAnalyticsUtility util = new GoogleAnalyticsUtility('CHART');
        this.gaId = util.getAnalyticsId();
        this.gtmId = util.getTagManagerId();
		this.viewModel = new chartLoginViewModel();
        this.viewModel.startURL = ApexPages.currentPage().getParameters().containsKey('startURL') ? ApexPages.currentPage().getParameters().get('startURL') : null;
        this.viewModel.projectId = ApexPages.currentPage().getParameters().containsKey('projectId') ? ApexPages.currentPage().getParameters().get('projectId') : null;
	}

    /**
     * Dummy method to avoid build errors, this was replaced by login(jsonData)
     */
    public PageReference login()
    {
        return null;
    }
    
    /**
     * Attempts to login the user with the data they provided in the login form
     * @param jsonData A JSON serialized <<studentLoginViewModel>> containing user creditials to log in
     * @return String returns and error message or the URL to log the user into the Student Portal
     */
    @RemoteAction
	public static String login(String jsonData) {
        
        // Create viewModel from JSON
        chartLoginViewModel viewModel;
		try
		{
			viewModel = (chartLoginViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('chartLoginViewModel'));
		}
		catch(Exception e)
		{
			System.debug(LoggingLevel.WARN, e.getMessage());
		}

        try {
            PageReference pr;
            if(viewModel.projectId != null && viewModel.projectId != 'null')
            {
                viewModel.startURL = '/chart/#/projects/' + viewModel.projectId;
                pr = Site.login(viewModel.email + '.ifsa', viewModel.password, viewModel.startURL);
            }
            else
            {
                pr = Site.login(viewModel.email + '.ifsa', viewModel.password, viewModel.startURL);
            }
            
            if(pr != null){
                return getURLFromPageReference(pr);
            } else {
                return 'The username and password you entered did not match our records. Please double-check and try again. If you continue to have issues, please let us know by sending an email to CHART@ifsa-butler.org.';
            }
        }
        catch (SObjectException ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            return 'Something went wrong. Please refresh the page and try again. If you continue to have issues, please let us know by sending an email to CHART@ifsa-butler.org.';
        }
    }

    /**
     * Dummy method to avoid build errors this was repalce by register(jsonData)
     */    
    public PageReference register(){
        return null;
    }
    /**
     * Starts the registartion process. To reduce code repition, the student portal and CHART both use login view model that extend extend <<communityLoginViewModel>> and run functions in <<createCommunityUserService>>
     * This method will return an instance of <<createCommunityUserService>> that will be passed to the remaining registration methods.
     * @param jsonData A JSON serialized <<chartLoginViewModel>> containing user registration info to create a new user or start an application for an existing user (I.E. CHART or Global Wayfinder)
     * @return <<createCommunityUserService>> returns information about the user who is registering back to CH_Login AngularJS application.
     */
    @RemoteAction
    public static createCommunityUserService register(String jsonData) // Changed return property from PageReference to Boolen for now.
    {
        // Create viewModel from JSON
        chartLoginViewModel viewModel;
        try {
			viewModel = (chartLoginViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('chartLoginViewModel'));
            System.debug('View Model after parse: ' + viewModel);
		} catch (Exception e) {
            System.debug(LoggingLevel.WARN, e.getMessage());
            throw new createCommunityUserService.createCommunityUserException('An error occurred. Please refresh and try again. If you continue to have issues, please let us know by sending an email to CHART@ifsa-butler.org.', e);
		}

        // Check user's email address to verify that it has an approved domain
        if(!validateHomeInstitution(viewModel.email))
        {
            throw new createCommunityUserService.createCommunityUserException('The school email you used isn\'t a verified \'.edu\' email address in our system. If you have a valid school email and it is failing, please let us know by sending an email to CHART@ifsa-butler.org.');
        }
        createCommunityUserService createUser = new createCommunityUserService(viewModel, createCommunityUserService.Community.CHART);
        createUser.checkForLeadOrContact();
        
        return createUser;
    }

    /** 
     * Prepares a new user record, uses an existing account and contact record if they exist
     * @param jsonData A JSON serialized <<createCommunityUserService>> containing user registration info to create a new user or start an application for an existing user (I.E. CHART or Global Wayfinder)
     * @return <<createCommunityUserService>> returns information about the user who is registering back to CH_Login AngularJS application.
     */
    @RemoteAction
    public static createCommunityUserService prepareUserRecord(String jsonData, String vmData)
    {
        // Create viewModel from JSON
        createCommunityUserService createUser;
        chartLoginViewModel vm;
		try
		{
			createUser = (createCommunityUserService) JSON.createParser(jsonData).readValueAs(Type.forName('createCommunityUserService'));
            System.debug('createCommunityUserService after parse: ' + createUser);
		}
		catch(Exception e)
		{
            System.debug(LoggingLevel.WARN, e.getMessage());
            throw new createCommunityUserService.createCommunityUserException('An error occurred while creating your account - please refresh and try again. If you continue to have issues, please let us know by sending an email to admissions@ifsa-butler.org.', e);
        }
        try
		{
			vm = (chartLoginViewModel) JSON.createParser(vmData).readValueAs(Type.forName('chartLoginViewModel'));
            System.debug('chartLoginViewModel after parse: ' + createUser);
            createUser.viewModel = vm;
		}
		catch(Exception e)
		{
            System.debug(LoggingLevel.WARN, e.getMessage());
            throw new createCommunityUserService.createCommunityUserException('An error occurred while creating your account - please refresh and try again. If you continue to have issues, please let us know by sending an email to admissions@ifsa-butler.org.', e);
        }
        createUser.prepareUserRecord();
        return createUser;
    }
    /** 
     * Inserts a new user, uses an existing account and contact record if they exist
     * @param jsonData A JSON serialized <<createCommunityUserService>> containing user registration info to create a new user or start an application for an existing user (I.E. CHART or Global Wayfinder)
     * @return <<createCommunityUserService>> returns information about the user who is registering back to CH_Login AngularJS application.
     */
    @RemoteAction
    public static String createUserRecord(String jsonData, String vmData)
    {
        // Create viewModel from JSON
        createCommunityUserService createUser;
        chartLoginViewModel vm;
		try
		{
			createUser = (createCommunityUserService) JSON.createParser(jsonData).readValueAs(Type.forName('createCommunityUserService'));
            System.debug('createCommunityUserService after parse: ' + createUser);
		}
		catch(Exception e)
		{
            System.debug(LoggingLevel.WARN, e.getMessage());
            throw new createCommunityUserService.createCommunityUserException('An error occurred while creating your account - please refresh and try again. If you continue to have issues, please let us know by sending an email to admissions@ifsa-butler.org.', e);
        }
        try
		{
			vm = (chartLoginViewModel) JSON.createParser(vmData).readValueAs(Type.forName('chartLoginViewModel'));
            System.debug('chartLoginViewModel after parse: ' + createUser);
            createUser.viewModel = vm;
		}
		catch(Exception e)
		{
            System.debug(LoggingLevel.WARN, e.getMessage());
            throw new createCommunityUserService.createCommunityUserException('An error occurred while creating your account - please refresh and try again. If you continue to have issues, please let us know by sending an email to admissions@ifsa-butler.org.', e);
        }
        return createUser.createUserRecord();
    }
    
    /** 
     * Once a user record has been created this function updates the related contact.
     * @param userId the Id of the student user that is registering.
     * @param jsonData A JSON serialized <<chartLoginViewModel>> containing user registration info.
     * @return String returns the login url or an error message
     */
    @RemoteAction
    public static String finalizeNewUser(Id userId, String jsonData)
    {
        chartLoginViewModel viewModel;
        try {
			viewModel = (chartLoginViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('chartLoginViewModel'));
            System.debug('View Model after parse: ' + viewModel);
		} catch (Exception e) {
            System.debug(LoggingLevel.WARN, e.getMessage());
            throw new createCommunityUserService.createCommunityUserException('An error occurred. Please refresh and try again. If you continue to have issues, please let us know by sending an email to CHART@ifsa-butler.org.', e);
        }
        
        //Query the user we just created...need the contact Id
        User newUser = new User();
        newUser = (User) apexQueryUtility.selectAllFrom('User', 'Id = \'' + userId + '\'').get(0);
        System.debug(newUser);

        //Query the contact that was created with that user
        System.debug('New User\'s Contact ID: ' + newUser.ContactId);
        Contact newContact = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Id = \'' + newUser.contactId + '\'').get(0);
        switch on viewModel.userType {
            when 'Student' {
                newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();     
            }
            when else {
                newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
            }
        }
        newContact.Graduation_Year__c = viewModel.graduationYear;
        newContact.Contact_Source__c = newContact.Contact_Source__c  == null ? 'CHART' : newContact.Contact_Source__c;
        newContact.First_Access_CHART__c = DateTime.now();
        newContact.School_Email__c = newContact.Email;
        if(newContact.Home_Institution__c == null)
        {
            System.debug('Attempting to find Home Institution based on user\'s email address...');
            newContact.Home_Institution__c = getHomeInstituitionFromEmailAddress(newContact.Email);
        }
        System.debug('Attempting to update contact record...');
        Database.update(newContact);
        System.debug(newContact);

        Boolean result = chartEmailConfirmationController.sendVerification(newUser, viewModel.email);

        newContact.CHART_Welcome_Email_Sent__c = true;
        system.enqueueJob(new sObjectQueueableUpdater(new List<Contact>{newContact}, sObjectQueueableUpdater.dmlOperation.isUpdate));
    
        // Log User In
        try
        {
            System.debug('Attempting to log user in...');
            PageReference pr = Site.login(newUser.Username, viewModel.password, null);
            System.debug(pr);
            if(pr != null){
                return getURLFromPageReference(pr);
            }
            else if(pr == null && Test.isRunningTest())
            {
                    return '';
            } 
            else 
            {
                return 'An error occurred while creating your account - please refresh and try again. If you continue to have issues, please let us know by sending an email to CHART@ifsa-butler.org.';
            }
            
        } catch(Exception e) 
        {
            System.debug(LoggingLevel.WARN, e.getMessage());
            return 'An error occurred while creating your account - please refresh and try again. If you continue to have issues, please let us know by sending an email to CHART@ifsa-butler.org.';
        }
    }

    private static Boolean validateHomeInstitution(String emailAddress) 
    {
        string emailDomain = emailAddress.subString(emailAddress.indexOf('@') + 1);

        return [SELECT Id FROM Email_Domain__c WHERE Domain_Name__c =: emailDomain].size() > 0;
    }
    /**
     * Get's the Id of a home institution from an email address
     * @param emailAddress The users email address
     * @return Id The Id of the Home Instituion record
     */
    public static Id getHomeInstituitionFromEmailAddress(String emailAddress) 
    {
        string emailDomain = emailAddress.subString(emailAddress.indexOf('@') + 1);

        try
        {
            return [SELECT Account__r.Institution__c FROM Email_Domain__c WHERE Domain_Name__c =: emailDomain].get(0).Account__r.Institution__c;
        }
        catch (ListException e)
        {
            System.debug('Could not find a home institution record with this email domain');
        }
        return null;
    }
    /**
     * Get's the Id of a home institution account from an email address
     * @param emailAddress The users email address
     * @return Id The Id of the Home Instituion Account record
     */
    public static Id getHomeInstituitionAccountFromEmailAddress(String emailAddress) 
    {
        string emailDomain = emailAddress.subString(emailAddress.indexOf('@') + 1);

        try
        {
            return [SELECT Account__c FROM Email_Domain__c WHERE Domain_Name__c =: emailDomain].get(0).Account__c;
        }
        catch (ListException e)
        {
            System.debug('Could not find a home institution record with this email domain');
        }
        return null;
    }


    @TestVisible
    private static String getURLFromPageReference(PageReference pr) 
    {
        try
        {
            System.debug(pr);
            return pr.getUrl();
        }
        catch (NullPointerException e)
        {
            return '';
        }
    }
}