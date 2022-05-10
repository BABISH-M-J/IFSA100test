/**
* Controller for SP_Login page - Has methods to log in an existing user or create a new user
* @author Cameron Ames
*/
// ApexDoc updated 1/26/2021 Brock Barlow
public without sharing class studentLoginController
{
    /**
     * Viewmodel for page, contains all of the information required for SP_Login to function, @see <<studentLoginViewModel>>
     */
    public studentLoginViewModel viewModel {get;set;}
    public static Date todayPlus28 = Date.today().addDays(28);
    public static final Date todayMinus7 = Date.today().addDays(-7);
    /**
	 * Google Anayltics Id
	 */
    public String gaId {get;set;}
    /**
	 * Google Tag Manager Id
	 */
    public String gtmId {get;set;}
    /**
     * Constructor, collects the data to populate an instance of <<studentLoginViewModel>>
     */
    public studentLoginController()
    {
        GoogleAnalyticsUtility util = new GoogleAnalyticsUtility('SP');
        this.gaId = util.getAnalyticsId();
        this.gtmId = util.getTagManagerId();
        this.viewModel = new studentLoginViewModel();
        system.debug(ApexPages.currentPage().getParameters());
        this.viewModel.programId = ApexPages.currentPage().getParameters().containsKey('ProgramId') ? Id.valueOf(ApexPages.currentPage().getParameters().get('ProgramId')) : null;
        this.populateViewModel();        
        if(ApexPages.currentPage().getParameters().containsKey('UserId'))
        {
            User u = [SELECT Email, Profile.Name FROM User WHERE Id =: ApexPages.currentPage().getParameters().get('UserId')];
            this.viewModel.email = u.Email;
            switch on u.Profile.Name {
                when 'IFSA Student User' {
                    this.viewModel.gwUser = true;
                }
                when 'IFSA CHART Student User' {
                    this.viewModel.chUser = true;
                }
            }                
        }
        else if(![SELECT Id FROM Profile WHERE Id =: UserInfo.getProfileId() AND Name IN ('IFSA Student User', 'IFSA CHART Student User')].isEmpty())
        {
            User u = [SELECT Id, ContactId, Profile.Name, Contact.FirstName, Contact.LastName, Contact.Home_Institution__c, Contact.Home_Institution__r.Name, Contact.Phone, Contact.Email, Contact.Major_New__c, Contact.First_Access_CHART__c, Contact.First_Access_Global_Wayfinder__c, Contact.Contact_Source__c FROM User WHERE Id =: UserInfo.getUserId()].get(0);
            List<Application__c> apps = [SELECT Id FROM Application__c WHERE Applicant__c =: u.ContactId];
            this.viewModel.hasApps = !apps.isEmpty() && u.Profile.Name == 'IFSA Student User';
            if(!this.viewModel.hasApps)
            {
                this.viewModel.email = u.Contact.Email;
                this.viewModel.firstName = u.Contact.FirstName;
                this.viewModel.lastName = u.Contact.LastName;
                this.viewModel.homeInstitutionName = u.Contact.Home_Institution__r.Name;
                this.viewModel.homeInstitutionId = u.Contact.Home_Institution__c;
                this.viewModel.phone = u.Contact.Phone;
                this.viewModel.major = u.Contact.Major_New__c;
                this.viewModel.contactId = u.Contact.Id;
                this.viewModel.password = '';
                this.viewModel.gwUser = u.Contact.First_Access_Global_Wayfinder__c != null && u.Profile.Name == 'IFSA Student User';
                this.viewModel.chUser = u.Contact.First_Access_CHART__c != null && u.Profile.Name == 'IFSA CHART Student User';
                this.viewModel.isLoggedIn = true;
                this.viewModel.userId = u.Id;
            }
        }
        else
        {
            this.viewModel.chUser = false;
            this.viewModel.gwUser = false;
        }
        
    }

    private void populateViewModel()
    {
        system.debug(viewModel);
        this.viewModel.majorOptions = apexConversionUtility.getPicklistModelValues(Contact.Major_New__c);
        
        this.viewModel.countryOptions = programTermService.getCountriesForProgramSelector();

        system.debug(viewModel.programId);
        if(this.viewModel.programId != null)
        {
            if(viewModel.programId.getSobjectType().getDescribe().getName() == 'Program__c')
            {
                this.viewModel.program = [SELECT Id, Name, Country__c, Country__r.Name FROM Program__c WHERE Id =: this.viewModel.programId];
            }
        }
    }
    /**
     * Checkes to see if the current user has the 'IFSA CHART Student User' profile, if they are, then redirects them to "SP_Apply"
     */
    public PageReference isExistingSPUser()
    {
        if(UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = 'IFSA CHART Student User'].get(0).Id)
        {
            return new PageReference('/SP_Apply');
        }
        return null;
    }
    /**
     * Authorization function, return nothing, may not be needed at all.
     */
    public PageReference authorize()
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
        studentLoginViewModel viewModel;
		try
		{
			viewModel = (studentLoginViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('studentLoginViewModel'));
            System.debug('View Model after parse: ' + viewModel);
		}
		catch(Exception e)
		{
			System.debug(LoggingLevel.WARN, e.getMessage());
        }
        
        User u = checkForExistingUser(viewModel.email);
        System.debug(u);

        if(u.Contact.First_Access_Student_Portal__c == null && u.Contact.First_Access_Advisor_Portal__c == null && u.Contact.First_Access_CHART__c != null && !viewModel.chUser){
            // CHART USER
            return 'SP_Login_ExistingUserCHError';
        }
        else if(u.Contact.First_Access_Student_Portal__c != null && viewModel.gwUser){
            return 'SP_Login_ExistingUserSPError,' + login(viewModel.email, viewModel.password);
        }
        else if(u.Contact.First_Access_Student_Portal__c == null && u.Contact.First_Access_Global_Wayfinder__c != null && !viewModel.gwUser){
            // GW USER
            return 'SP_Login_ExistingUserGWError';
        }
        else if(u.Contact.First_Access_Student_Portal__c == null && u.Contact.First_Access_Advisor_Portal__c != null){
            // Advisor Portal USER
            return 'SP_Login_ExistingUserAPError';
        }
        else {
            // SP USER
            return login(viewModel.email, viewModel.password);
        }
    }

    private static string login(String email, String password)
    {
        try 
        {
            PageReference pr = Site.login(email + '.ifsa', password, null);
            if(pr != null){
                return getURLFromPageReference(pr);
            } else {
                return 'SP_Login_IncorrectPasswordError';
            }
        }
        catch (SObjectException ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            return 'SP_Login_GenericLoginError';
        }
    }
    /**
     * Searches the Home_Institution__c table for a specific institution
     * @param SearchTerm
     * @return List<Home_Institution__c> a list of possible home institution name matches
     */
    @RemoteAction // Get list of home institutions for user form
    public static List<Home_Institution__c> searchHomeInstitution(String SearchTerm) 
    {
        List<Home_Institution__c> schools = Database.query('Select Id, Name from Home_Institution__c where name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        return schools;
    }
    /** 
     * Gets the upcomming term records for a selected country from <<programTermService>>.getTermsForProgramSelector
     * @param selectedCountry The Id of the country to get Term__c records for.
     * @return List<Term__c> resutls of the query
    */
    @RemoteAction
    public static List<Term__c> getTerms(String selectedCountry)
    {
        return programTermService.getTermsForProgramSelector(Id.valueOf(selectedCountry));
    }

    /** 
     * Gets the upcomming program term records for a selected country from <<programTermService>>.getProgramTermsForProgramSelector
     * @param selectedCountry The Id of the country to get Program_Term__c records for
     * @param selectedSemester The Id of the term to get Program_Term__c records for
     * @param homeInstitutionName The name of the student's home institution
     * @return List<Program_Term__c> resutls of the query
    */
    @RemoteAction 
    public static List<Program_Term__c> searchPrograms(String selectedCountry, String selectedSemester, String homeInstitutionName)
    {
        return programTermService.getProgramTermsForProgramSelector(selectedCountry, selectedSemester, homeInstitutionName);
    }
    /** 
     * Gets the "Program Option" program term records for a selected program term
     * @param programId The Id of the Program_Term__c to get "Program Option" Program_Term__c records for
     * @return List<Program_Term__c> resutls of the query
    */
    @RemoteAction
    public static List<Program_Term__c> getProgramOptions(Id programId)
    {
        List<Program_Term__c> programOptions = [SELECT Id, Name, Program_Option_Name__c, Description_Long__c, OwnerId FROM Program_Term__c WHERE Parent_Program_Term__c =: programId ORDER BY Name];
        return programOptions;
    }
    
    /**
     * Starts the registartion process. To reduce code repition, the student portal and CHART both use login view model that extend extend <<communityLoginViewModel>> and run functions in <<createCommunityUserService>>
     * This method will return an instance of <<createCommunityUserService>> that will be passed to the remaining registration methods.
     * @param jsonData A JSON serialized <<studentLoginViewModel>> containing user registration info to create a new user or start an application for an existing user (I.E. CHART or Global Wayfinder)
     * @return <<createCommunityUserService>> returns information about the user who is registering back to SP_Login AngularJS application.
     */
    @RemoteAction
    public static createCommunityUserService register(String jsonData)
    {
        // Create viewModel from JSON
        studentLoginViewModel viewModel;
		try
		{
			viewModel = (studentLoginViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('studentLoginViewModel'));
            System.debug('View Model after parse: ' + viewModel);
		}
		catch(Exception e)
		{
            System.debug(LoggingLevel.WARN, e.getMessage());
            throw new createCommunityUserService.createCommunityUserException('An error occurred while creating your account - please refresh and try again. If you continue to have issues, please let us know by sending an email to admissions@ifsa-butler.org.', e);
        }
        createCommunityUserService createUser = new createCommunityUserService(viewModel, createCommunityUserService.Community.STUDENT_PORTAL);
        if(viewModel.contactId == null)
        {
            createUser.checkForLeadOrContact();
        }
        else
        {
            Id chartProfileId = [SELECT Id FROM Profile WHERE Name = 'IFSA CHART Student User'].get(0).Id;
            system.debug(UserInfo.getProfileId());
            system.debug(chartProfileId);
            Boolean isCHARTUser = UserInfo.getProfileId() == chartProfileId;
            if(isCHARTUser)
            {
                updateChartUser();
            }
            createUser.userId = UserInfo.getUserId();
        }
        return createUser;
    }

    /** 
     * Prepares a new user record, uses an existing account and contact record if they exist
     * @param jsonData A JSON serialized <<createCommunityUserService>> containing user registration info to create a new user or start an application for an existing user (I.E. CHART or Global Wayfinder)
     * @return <<createCommunityUserService>> returns information about the user who is registering back to SP_Login AngularJS application.
     */
    @RemoteAction
    public static createCommunityUserService prepareUserRecord(String jsonData, String vmData)
    {
        // Create viewModel from JSON
        createCommunityUserService createUser;
        studentLoginViewModel vm;
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
			vm = (studentLoginViewModel) JSON.createParser(vmData).readValueAs(Type.forName('studentLoginViewModel'));
            System.debug('studentLoginViewModel after parse: ' + createUser);
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
     * @return <<createCommunityUserService>> returns information about the user who is registering back to SP_Login AngularJS application.
     */
    @RemoteAction
    public static String createUserRecord(String jsonData, String vmData)
    {
        // Create viewModel from JSON
        createCommunityUserService createUser;
        studentLoginViewModel vm;
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
			vm = (studentLoginViewModel) JSON.createParser(vmData).readValueAs(Type.forName('studentLoginViewModel'));
            System.debug('studentLoginViewModel after parse: ' + createUser);
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
     * Once a user record has been created / updated (in the case of CHART), this function updates the related contact, and creates the student Application__c record. 
     * @param userId the Id of the student user that is registering.
     * @param jsonData A JSON serialized <<studentLoginViewModel>> containing user registration info to create a new user or start an application for an existing user (I.E. CHART or Global Wayfinder)
     * @return String returns the login url or an error message
     */
    @RemoteAction
    public static string createApplicationAndUpdateContact(String userId, String jsonData)
    {
        // Create viewModel from JSON
        studentLoginViewModel viewModel;
		try
		{
			viewModel = (studentLoginViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('studentLoginViewModel'));
            System.debug('View Model after parse: ' + viewModel);
		}
		catch(Exception e)
		{
			System.debug(LoggingLevel.WARN, e.getMessage());
		}

        //Create an application
        Application__c newApplication = new Application__c();

        //Query the user we just created...need the contact Id
        User newUser = (User) apexQueryUtility.selectAllFrom('User', 'Profile.Name', 'Id = \'' + userId + '\'').get(0);
        if(newUser.Profile.Name != 'IFSA Student User')
        {
            throw new studentLoginControllerException('ERROR: User has not been assigned the correct profile.');
        }
        //Query the contact that was created with that user
        Contact studentContact = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Id = \'' + newUser.contactId + '\'').get(0);
        Account studentAccount = new Account(Id = studentContact.AccountId, OwnerId =viewModel.programOfInterest.OwnerId);
        studentContact.OwnerId = viewModel.programOfInterest == null ? null : viewModel.programOfInterest.OwnerId;
        studentContact.Contact_Source__c = studentContact.Contact_Source__c == null ? 'Student Portal' : studentContact.Contact_Source__c;
        studentContact.Phone = viewModel.phone;
        studentContact.First_Access_Student_Portal__c = DateTime.now();
        studentContact.Phone = viewModel.phone;
        studentContact.et4ae5__Mobile_Country_Code__c = viewModel.countryCode;
        studentContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        if(chartLoginController.getHomeInstituitionFromEmailAddress(studentContact.Email) != null)
        {
            studentContact.School_Email__c = studentContact.Email;
        }
        if(viewModel.homeInstitutionId != null && studentContact.Home_Institution__c == null)
        {
            studentContact.Home_Institution__c = viewModel.homeInstitutionId;
        }
        else if(viewModel.homeInstitutionId == null && viewModel.homeInstitutionName != null)
        {
            studentContact.Unlisted_School__c = viewModel.HomeInstitutionName;
        }
        studentContact.Major_New__c = viewModel.major == null ? '' : viewModel.major;
        studentContact.Major_Other__c = viewModel.OtherMajor == null ? '' : viewModel.OtherMajor;
        try
        {
            Database.update(studentContact);
        }
        catch (SObjectException ex)
        {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            return 'ERROR: Sorry, but we could not create an account for you. Please make sure you filled out all the fields. If you continue to have trouble, contact IFSA.';
        }

        //Associate our new application with the contact
        newApplication.Applicant__c = ((Contact) apexQueryUtility.selectAllFrom('Contact', 'Id = \'' + studentContact.Id + '\'').get(0)).Id;
        newApplication.Name = 'Initial Application';
        newApplication.OwnerId = viewModel.programOfInterest == null ? null : viewModel.programOfInterest.OwnerId;
        newApplication.Program_Term__c = viewModel.programOfInterest == null ? null : viewModel.programOfInterest.Id;
        newApplication.Status__c = 'Program Selected';
        newApplication.Source__c = 'Student Portal Login/Register';
        newApplication.Printable_Statement__c = true;
        try
        {
            Database.insert(newApplication);
        }
        catch (SObjectException ex)
        {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            return 'ERROR: Sorry, but we could not create an account for you. Please make sure you filled out all the fields. If you continue to have trouble, contact IFSA.';
        }
        

        //Associate the new application as the active one
        studentContact.Active_Application__c = newApplication.Id;
        system.enqueueJob(new sObjectQueueableUpdater(new List<Contact>{studentContact}, sObjectQueueableUpdater.dmlOperation.isUpdate));
        
        //if(studentContact.Contact_Source__c == 'Student Portal')
        if(UserInfo.getUserName().contains('student_portal@ifsa.force.com'))
        {
            //If they entered a password, log them in immediately.
            if(viewModel.password != null && viewModel.password.length() > 1)
            {
                PageReference pr = Site.login(newUser.Username, viewModel.password, null);
                system.debug(pr);
                return getURLFromPageReference(pr);
            }
            //They didn't enter a password, take them to the self reg page.
            else
            {
                PageReference page = new PageReference('/communitiesSelfRegConfirm');
                page.setRedirect(true);
                return getURLFromPageReference(page);
            }
        }
        else
        {            
            return '/SP_Application';
        }
    }
    
    private static string getURLFromPageReference(PageReference pr)
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
    private static void updateChartUser()
    {
        Boolean isSandBox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
        
        Network myNetwork = [SELECT Id FROM Network WHERE Name ='Student Portal'];
        System.debug(Network.getLoginUrl(myNetwork.Id)); // https://chartbb-ifsa.cs9.force.com/studentportal/SP_Login
        Id commProfileId = [SELECT Id FROM Profile WHERE Name = 'IFSA Student User'].get(0).Id;
        String remoteURL =  Network.getLoginUrl(myNetwork.Id).replace('SP_Login', 'CH_ProfileUpdate?userId='+UserInfo.getUserId()+'&profileId='+commProfileId);
        
        if(!isSandBox)
        {
            remoteURL = remoteURL.replace('portal.ifsa-butler.org', 'ifsa.force.com');
        }
        
        system.debug(remoteURL);
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('GET');
        httpRequest.setEndpoint(remoteURL);
        HttpResponse httpResponse = new Http().send(httpRequest);
    }
    /**
     * Queries for program term records, this is used for student's that have clicked "Apply Now" from a program in Global Wayfinder
     * @param programId The Id of the program the student is interested in applying for
     * @return List<Program_Term__c> Upcomming Program Term records for the specified program Id.
     */
    @RemoteAction
    public static List<Program_Term__c> getTermsByProgramId(String programId)
    {
        List<Program_Term__c> results = new List<Program_Term__c>();
        Date today = Date.today();

        List<Id> recordTypeIds = new List<Id>();
        recordTypeIds.add(Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId());
        recordTypeIds.add(Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Parent Program Term with Dates').getRecordTypeId());
        recordTypeIds.add(Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Parent Program Term without Dates').getRecordTypeId());
        for(Program_Term__c pt: [SELECT Id, Name, Term__c, Term__r.Name, Term__r.Section__c, Term__r.Year__c, Application_Deadline__c, RecordType.Name, OwnerId, (SELECT Id, Name, Application_Deadline__c, Description_Long__c, OwnerId, Term__r.Year__c FROM Program_Terms__r WHERE Hidden__c = FALSE) FROM Program_Term__c WHERE Program__c =: programId AND Term__r.Year__c >=: today.year() AND RecordTypeId IN: recordTypeIds AND Hidden__c = FALSE])
        {
            if(pt.RecordType.Name =='Parent Program Term without Dates')
            {
                for(Program_Term__c po: pt.Program_Terms__r)
                {
                    if((po.Application_Deadline__c != null && po.Application_Deadline__c >= todayMinus7) || (po.Application_Deadline__c == null && po.Term__r.Year__c >= Date.today().year()))
                    {
                        results.add(pt);
                        break;
                    }
                }
            }
            else if(pt.Application_Deadline__c >= todayMinus7 || pt.Application_Deadline__c == null && pt.Program_Terms__r.isEmpty())
            {
                results.add(pt);
            }
        }

        return results;
    }
    /**
     * Checks to see if we have a user record with the supplied email address. Ideally this function will return null, but this is what allows us to handle CHART and Global Wayfinder users that do not know they already have an IFSA account.
     * @param emailAddress. The users email address
     * @return the user record that matches the supplied email address
     */
    @RemoteAction
    public static User checkForExistingUser(String emailAddress)
    {
        try{
            return [SELECT Id, Contact.First_Access_CHART__c, Contact.First_Access_Global_Wayfinder__c, Contact.First_Access_Student_Portal__c, Contact.First_Access_Advisor_Portal__c FROM User WHERE Username =: emailAddress + '.ifsa'].get(0);
        }
        catch (ListException e){
            return null;
        }
    }
    /**
     * Forgot password functionallity. This replaces the need for a separate password reset page for the student portal
     */
    @RemoteAction
    public static String resetPassword(String emailAddress)
    {
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = emailAddress;
        return controller.forgotPassword().getUrl();
    }
    /**
     * Allows the controller to throw it's own custom exceptions.
     */
    public class studentLoginControllerException extends Exception {}
}