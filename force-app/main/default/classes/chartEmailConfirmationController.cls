/**
 * Controller class for CH_EmailConfirmation Visualforce Page
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public without sharing class chartEmailConfirmationController 
{
	/**
	 * Provides the VF page information about the status of the current user and dynamically displays content based on this value
	 */
	public Boolean noId {get;set;}
	/**
	 * Provides the VF page information about the authorization status of the current user
	 */
	public Boolean hasBeenAuthorized {get;set;}
	/**
	 * User record of the current user
	 */
	public User currentUser {get;set;}
	/**
	 * The current users school email address
	 */
	public String schoolEmail {get;set;}
	/**
	 * Holds a dynamic label for a button on the visual force page
	 */
	public String buttonValue {get;set;}
	/**
	 * This value is true if the current user has the "IFSA Student Portal" user profile.
	 */
	public Boolean isStudentPortalProfile {get;set;}
	/**
	 * The user record of the owner of the current user's contact
	 */
	public User owner {get;set;}
	/**
	 * Google Anayltics Id
	 */
	public String gaId {get;set;}
	/**
	 * Google Tag Manager Id
	 */
	public String gtmId {get;set;}

	/** 
	 * Constructor, populates the viewmodel for the page
	 */
	public chartEmailConfirmationController() 
	{
		GoogleAnalyticsUtility util = new GoogleAnalyticsUtility('CHART');
        this.gaId = util.getAnalyticsId();
        this.gtmId = util.getTagManagerId();
		noId = true;
		hasBeenAuthorized = false;
		buttonValue = 'Resend Verification Email';
		isStudentPortalProfile = false;
		schoolEmail = '';
		Id userId;
		try
		{
			userId = Id.valueOf(ApexPages.currentPage().getParameters().get('UserId'));
			currentUser = [SELECT Id, Email_Confirmed_for_CHART__c, Email, Profile.Name FROM User WHERE Id =: userId];
			schoolEmail = currentUser.Email;
			noId = false;
		}
		catch (Exception e)
        {
			userId = UserInfo.getUserId();
			currentUser = [SELECT Id, Email_Confirmed_for_CHART__c, Email, Profile.Name FROM User WHERE Id =: userId];
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
		
		System.debug(currentUser);
		if(!currentUser.Email_Confirmed_for_CHART__c && (currentUser.Profile.Name == 'IFSA Student User' || currentUser.Profile.Name == 'IFSA Advisor User') && [SELECT Id FROM Email_Domain__c WHERE Domain_Name__c =: currentUser.Email.substringAfter('@')].isEmpty() == false)
		{
			schoolEmail = currentUser.Email;
			buttonValue = 'Send Verification Email';
			isStudentPortalProfile = true;
		}
		else if(!currentUser.Email_Confirmed_for_CHART__c && currentUser.Profile.Name == 'IFSA Student User' || currentUser.Profile.Name == 'IFSA Advisor User')
		{
			buttonValue = 'Send Verification Email';
			isStudentPortalProfile = true;
		}
		hasBeenAuthorized = currentUser.Email_Confirmed_for_CHART__c;
	}
	/**
	 * Method that is run once the page has loaded, allows the user to be redirected to another page depending on if the user has already been authorized.
	 * @return PageReference Where the user will be redirected, unless the method returns null, then the user stays on the current page
	 */
	public PageReference authorized()
	{
		System.debug(hasBeenAuthorized);

		if(hasBeenAuthorized)
		{
			return new PageReference('/');
		}
		else if(currentUser != null && !currentUser.Email_Confirmed_for_CHART__c && !noId)
		{
			currentUser.Email_Confirmed_for_CHART__c = true;
			System.debug(currentUser);
			database.update(currentUser);
			return new PageReference('/');
		}
		noId = true;
		return null;
	}
	/**
	 * Resends the verification email to the users school email address
	 */
	public void resendVerification()
	{
		currentUser = [SELECT Id, Name, FirstName, LastName, Email, Contact.OwnerId FROM User WHERE Id =: UserInfo.getUserId()].get(0);
		if(schoolEmail == '')
		{
			schoolEmail = currentUser.Email;
		}
		if([SELECT Id FROM Email_Domain__c WHERE Domain_Name__c =: schoolEmail.substringAfter('@')].isEmpty() == false)
		{
			if(sendVerification(currentUser, schoolEmail))
			{
				buttonValue = 'Resend Verification Email';
				isStudentPortalProfile = false;
			}
		}
		else
		{
			owner = [SELECT Id, Name, Email FROM User WHERE Id =: currentUser.Contact.OwnerId];
		}
	}
	/**
	 * Sends the verification email to the user's school email address
	 * @param currentUser The current user's User record
	 * @param schoolEmail The current user's school email address
	 * @return Boolean Returns true if successful, false if there has been a failure
	 */
	public static Boolean sendVerification(User currentUser, String schoolEmail)
	{
		Network myNetwork = [SELECT Id, Name, UrlPathPrefix FROM Network WHERE Name ='CHART'];
		String communityUrl = Network.getLoginUrl(myNetwork.id).replace('/CH_Login', '');
		EmailTemplate template = [SELECT Id, Subject, Body  FROM EmailTemplate WHERE Name = 'Chart: New Member Welcome Email'].get(0);
		//Welcome to {!Community_Name}
		String subject = template.Subject.replace('{!Community_Name}', myNetwork.Name);
		//Hi {!Receiving_User.FirstName},Welcome to IFSA {!Community_Name}! To get started, go to {!Community_Url}/CH_EmailConfirmation?UserId={!Receiving_User.Id}Username: {!Receiving_User.Email}            Thanks,{!Organization.Name}
		String body = template.Body.replace('{!Receiving_User.FirstName}', currentUser.FirstName);
		body = body.replace('{!Community_Name}', myNetwork.Name);
		body = body.replace('{!Community_Url}', communityUrl);
		body = body.replace('{!Receiving_User.Id}', currentUser.Id);
		body = body.replace('{!Receiving_User.Email}', currentUser.Email);
		body = body.replace('{!Organization.Name}', 'Institute for Study Abroad');

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setPlainTextBody(body);
		email.setReplyTo('no-reply@ifsa-butler.org');
		email.setSenderDisplayName('IFSA No Reply');
		email.setSubject(subject);
		email.setToAddresses(new List<String>{schoolEmail});
		email.setSaveAsActivity(false);

		try
		{
			Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {email});
			return true;
		}
		catch(Exception e)
		{
			System.debug(e.getMessage());
		}
		return false;
	}
}