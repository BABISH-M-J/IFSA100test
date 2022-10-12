/**
 * Common class used to create portal (Community or Experience Users). 
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class createCommunityUserService 
{
    /**
     * Community types
     */
    public enum Community {
        STUDENT_PORTAL, ADVISOR_PORTAL, CUSTOM_PORTAL, CHART
    }
    /**
     * Yes / No Enum This allows for a null option that a Boolean does not allow for
     */
    public enum RecordExist{
        YES, NO
    }    
    /**
     * Instance of <<communityLoginViewModel>> containing new user data
     */
    public communityLoginViewModel viewModel { get; set; }
    /**
     * A contact record for a new user
     */
    public Contact userContact { get; set; }
    /**
     * An account record for a new user
     */
    public Account userAccount { get; set; }
    /**
     * The community (Experience) to create this new user for
     */
    public Community selectedCommunity { get; set; }
    /**
     * The new user's user record id
     */
    public Id userId { get; set; }
    /**
     * The user record for the new user
     */
    public User newUser { get; set; }
    /**
     * Do records exist for this user? YES, NO , null
     */
    public RecordExist doRecordsExist { get; set; }
    private static final Id defaultAccountOwner = [SELECT OwnerId FROM Program__c WHERE Name = 'Undecided'].get(0).OwnerId;
    /**
     *  Default constructor
     */
    public createCommunityUserService() {

    }
    /**
     * Constructor with viewModel and community parameters
     * @param vm <<communityLoginViewModel>>
     * @param comm Community Enum
     */
    public createCommunityUserService(communityLoginViewModel vm, Community comm)
    {
        viewModel = vm;
        selectedCommunity = comm;
    }
// added by powerfluence based on Clayton req 03/29/2022 starts
   @TestVisible private String getErrorEmailAddress()
// added by powerfluence based on Clayton req 03/29/2022 ends
    {
        switch on selectedCommunity {
            when CHART {
                return 'CHART@ifsa-butler.org';
            }
            when STUDENT_PORTAL {
                return 'admissions@ifsa-butler.org';
            }
            when ADVISOR_PORTAL {
                return 'studyabroad@ifsa-butler.org';
            }
            when CUSTOM_PORTAL {
                return 'custom@ifsa-butler.org';
            }
        }
        return '';
    }
    /**
     * Checks for an existing Lead or Contact record for the new user
     */
    public void checkForLeadOrContact()
    {
        // Check to see if there are existing records for this user, and then handle the registration accordingly
		List<Contact> checkForExistingContact = [SELECT Id, FirstName, LastName, Email, AccountId FROM Contact WHERE FirstName =: viewModel.firstName AND LastName =: viewModel.lastName AND Email =: viewModel.email];
		List<Lead> checkForExistingLead = [SELECT Id, FirstName, LastName, Email FROM Lead WHERE FirstName =: viewModel.firstName AND LastName =: viewModel.lastName AND Email =: viewModel.email];
        if(!checkForExistingContact.isEmpty())
        {
            userContact = checkForExistingContact[0];
        }
        if(!checkForExistingContact.isEmpty() && !checkForExistingLead.isEmpty())
        {
            System.debug('Found existing Contact and Lead.');
            try {
                Id contactId = leadService.convertLead(checkForExistingLead.get(0), userContact);
                doRecordsExist = RecordExist.YES;
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN, e.getMessage());
                throw new createCommunityUserException('An error occurred while creating your account - please refresh and try again. If you continue to have issues, please let us know by sending an email to ' + getErrorEmailAddress() + '. ERROR_REG_0001', e);
            }
        }
        else if(!checkForExistingContact.isEmpty() && checkForExistingLead.isEmpty())
        {
            System.debug('Found existing Contact and but no existing Lead.');
            try {
                doRecordsExist = RecordExist.YES;
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN, e.getMessage());
                throw new createCommunityUserException('An error occurred while creating your account - please refresh and try again. If you continue to have issues, please let us know by sending an email to ' + getErrorEmailAddress() + '. ERROR_REG_0002', e);
            }
        }
		else if(!checkForExistingLead.isEmpty() && checkForExistingContact.isEmpty())
		{
            System.debug('Found existing lead, but no existing Contact.');
			try {
                userContact = [SELECT Id, FirstName, LastName, Email, AccountId FROM Contact WHERE Id =: leadService.convertLead(checkForExistingLead.get(0), null)].get(0);
                doRecordsExist = RecordExist.YES;
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN, e.getMessage());
                throw new createCommunityUserException('An error occurred while creating your account - please refresh and try again. If you continue to have issues, please let us know by sending an email to ' + getErrorEmailAddress() + '. ERROR_REG_0003', e);
            }
            
		}
        else if(checkForExistingContact.isEmpty() && checkForExistingLead.isEmpty())
        {
            System.debug('Did not find an existing Contact or Lead.');
            try {
                doRecordsExist = RecordExist.NO;
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN, e.getMessage());
                throw new createCommunityUserException('An error occurred while creating your account - please refresh and try again. If you continue to have issues, please let us know by sending an email to ' + getErrorEmailAddress() + '. ERROR_REG_0004', e);
            }
        }
        else
        {
            throw new createCommunityUserException('An error occurred while creating your account - please refresh and try again. If you continue to have issues, please let us know by sending an email to ' + getErrorEmailAddress() + '. ERROR_REG_0005');
        }        
    }
    /**
     * Prepares a user record for the new user
     */
    public void prepareUserRecord()
    {
        try
        {
            Account newAccount;
            Contact newContact;
            newUser = new User();
            if(userContact != null && viewModel.userType == 'Student')
            {
                System.debug('Existing Account and Contact');
                newContact = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Id = \'' + userContact.Id + '\'').get(0);
                newAccount = (Account) apexQueryUtility.selectAllFrom('Account', 'Id = \'' + userContact.AccountId + '\'').get(0);
                System.debug('Existing Account and Contact'+userContact.Id);
                List<User> users = [SELECT Id, Profile.Name FROM User WHERE ContactId =: userContact.Id];
                if(!users.isEmpty())
                {
                    User u = users[0];
                    switch on u.Profile.Name {
                        when 'IFSA Student User' {
                            throw new createCommunityUserException('Existing IFSA Student User. ERROR_REG_0006');
                        }
                        when 'IFSA CHART Student User' {
                            throw new createCommunityUserException('Existing IFSA CHART Student User. ERROR_REG_0007');
                        }
                        when else {
                            throw new createCommunityUserException('Unexpected Exception. ERROR_REG_0008');
                        }
                    }
                }
            }
            else
            {
                System.debug('Create new account and contact');
                viewModel.firstName = viewModel.firstName != null ? viewModel.firstName.normalizeSpace() : null;
                viewModel.lastName = viewModel.lastName.normalizeSpace();
                //Create an account with that name
                newAccount = new Account();
                
                switch on viewModel.userType {
                    when 'Student' {
                        newAccount.Name = viewModel.firstName + ' ' + viewModel.lastName;
                        newAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId();
                        newAccount.OwnerId = defaultAccountOwner;
                        
                        Database.UpsertResult aResult = Database.upsert(newAccount);
                        newAccount.Id = aResult.getId();
                        if(!aResult.isSuccess())
                        {
                            throw new createCommunityUserException('Could not create account. ERROR_REG_0009');
                        }
                    }
                    when 'Faculy', 'Advisor' {
                        newAccount = (Account) apexQueryUtility.selectAllFrom('Account', 'Id = \'' + chartLoginController.getHomeInstituitionAccountFromEmailAddress(viewModel.email) + '\'').get(0);
                    }
                }
            }  

            //Create a portal user with the given info
            
            newUser.Username = viewModel.email + '.ifsa';
            newUser.CommunityNickname = viewModel.email.replaceAll('[^a-zA-Z0-9]', '');
            if(newUser.CommunityNickname.length() > 40){
                newUser.CommunityNickname = newUser.CommunityNickname.substring(0,40);
            }
            newUser.Email = viewModel.email;
            newUser.Firstname = viewModel.firstName;
            newUser.LastName = viewModel.lastName;
            newUser.ContactId = newContact != null ? newContact.Id : null;
            newUser.TimeZoneSidKey = 'GMT';
            newUser.LocaleSidKey = 'en_US';
            newUser.EmailEncodingKey = 'ISO-8859-1';
            newUser.LanguageLocaleKey = 'en_US';
            newUser.UserPermissionsMobileUser = false;
            if(viewModel.userType != null && viewModel.userType == 'Student' && selectedCommunity == Community.CHART)
            {
                newUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: 'IFSA Chart Student User'].get(0).Id;
            }
            else if(viewModel.userType != null && viewModel.userType == 'Student' && selectedCommunity == Community.STUDENT_PORTAL)
            {
                newUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: 'IFSA Student User'].get(0).Id;
            }
            else if(viewModel.userType != null && viewModel.userType == 'Faculty' && selectedCommunity == Community.CHART)
            {
                newUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: 'IFSA Chart Faculty User'].get(0).Id;
            }
            // -----  UNCOMMENT THESE LINES AS THE OTHER PORTALS IMPLEMENT THIS REGISTRATION PROCESS ------
            /*
            else if(viewModel.userType != null && viewModel.userType == 'Student' && selectedCommunity == Community.CUSTOM_PORTAL)
            {
                newUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: 'IFSA Custom Student User'].get(0).Id;
            }
            else if(viewModel.userType != null && viewModel.userType == 'Advisor' && (selectedCommunity == Community.CHART || selectedCommunity == Community.ADVISOR_PORTAL))
            {
                newUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: 'IFSA Advisor User'].get(0).Id;
            }
            */

            System.debug(newAccount);
            System.debug(newContact);
            System.debug(newUser);
            userAccount = newAccount;
            userContact = newContact;
        }
        catch(Exception e)
        {
            system.debug(LoggingLevel.WARN, e.getMessage());
            throw new createCommunityUserException('Unexpected Exception. ERROR_REG_0010', e);
        }
    }

    /**
     * Attempts to create an external user by calling Site.createExternalUser(User, Id, String);
     */
    public String createUserRecord()
    {
        String userId;
        if(!Test.isRunningTest()){
            try 
            {
                userId = Site.createExternalUser(newUser, userAccount.Id, viewModel.password);
                if(userId == null){
                    deleteAccountAndContact();
                    throw new createCommunityUserException('An error occurred while creating your account - please refresh and try again. If you continue to have issues, please let us know by sending an email to ' + getErrorEmailAddress() + '. ERROR_REG_0011');
                }                
            }
            catch (Site.ExternalUserCreateException e) 
            {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                deleteAccountAndContact();
                throw e;
            }
        }
        else {
            if(viewModel.userType == 'Student')
            {
                userAccount = new Account();
                userAccount.Name = 'TestForCommunity';
                userAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId();
                userAccount.OwnerId = defaultAccountOwner;
                insert userAccount;
            }                

            userContact = new Contact();
            userContact.FirstName = 'Unit';
            userContact.LastName = 'Test';
            userContact.Email = 'comtest' + viewModel.userType +'@comtest.test';
            userContact.AccountId = viewModel.userType == 'Student' ? userAccount.Id : userAccount.Id;
            insert userContact;

            newUser.ContactId = userContact.Id;
            newUser.alias = 'comtests';
            newUser.DefaultGroupNotificationFrequency = 'N';
            newUser.DigestFrequency = 'N';
            newUser.Email = userContact.Email;
            newUser.EmailEncodingKey = 'ISO-8859-1';
            newUser.LanguageLocaleKey = 'en_US';
            newUser.FirstName = 'Unit';
            newUser.LastName = 'Test';
            newUser.LocaleSidKey = 'en_US';
            // Check to see if the the registering user is a student or advisor and and set the appropriate profile
            // newUser.ProfileId = viewModel.userType == 'Student' ? [SELECT Id FROM Profile WHERE Name =: 'IFSA Chart Student User'].get(0).Id : [SELECT Id FROM Profile WHERE Name =: 'IFSA Chart Faculty User'].get(0).Id;
            System.debug('User Type: ' + viewModel.userType);
            if(viewModel.userType != null && viewModel.userType == 'Student' && selectedCommunity == Community.CHART)
            {
                newUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'IFSA CHART Student User'].get(0).Id;
            }
            else if(viewModel.userType != null && viewModel.userType == 'Student' && selectedCommunity == Community.STUDENT_PORTAL)
            {
                newUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'IFSA Student User'].get(0).Id;
            }
            // -----  UNCOMMENT THESE LINES AS THE OTHER PORTALS IMPLEMENT THIS REGISTRATION PROCESS ------
            /*
            else if(viewModel.userType != null && viewModel.userType == 'Faculty' && selectedCommunity == Community.CHART)
            {
                newUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'IFSA CHART Faculty User'].get(0).Id;
            }
            else if(viewModel.userType != null && viewModel.userType == 'Advisor' && selectedCommunity == Community.ADVISOR_PORTAL)
            {
                newUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'IFSA Advisor User'].get(0).Id;
            }
            */
            newUser.CommunityNickname = 'test' + viewModel.userType + 'UserFor' + selectedCommunity.name();
            newUser.TimeZoneSidKey = 'GMT'; 
            newUser.Username = userContact.Email + '.ifsa';
            newUser.UserPermissionsCallCenterAutoLogin = false;
            newUser.UserPermissionsMarketingUser = false;
            newUser.UserPermissionsOfflineUser = false;
            insert newUser;
            userId = newUser.Id;
        }
        //If the user ID is not null that means the user was created
        if(userId != null)
        {
            System.debug(LoggingLevel.INFO, 'Created user, User ID: ' + userId);
            return userId;
        }
        throw new createCommunityUserException('An error occurred while creating your account - please refresh and try again. If you continue to have issues, please let us know by sending an email to ' + getErrorEmailAddress() + '. ERROR_REG_0012');
    }
//// added by powerfluence based on Clayton req 03/29/2022 starts
   @TestVisible private void deleteAccountAndContact()
// added by powerfluence based on Clayton req 03/29/2022 ends
    {
        if(userId == null && doRecordsExist == RecordExist.NO)
        {
            try 
            {
                database.delete(userContact);
            } 
            finally 
            {
                database.delete(userAccount);
            }
        }        
    }
    /**
     * Exception class for <<createCommunityUserService>>
     */
    public class createCommunityUserException extends Exception {}
}