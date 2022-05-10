/**
 * Wrapper class for contact sObject
 * @author Cameron Ames
 */
// ApexDoc updated 1/28/2021 Brock Barlow
global without sharing class contactWrapper
{
	/**
	 * Updates a contacts user record. Executes contactWrapper.cascadeToUser
	 * @param contactId
	 */
	public static void cascadeToUser(Id contactId)
	{
		contactWrapper.cascadeToUser(new List<Id> {contactId});
	}
	/**
	 * This method is executed from Javascript button on contact record
	 * @param contactId
	 * @return String returns an error message
	 */
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
			return 'The advisor user has been created and the advisor has been sent a password reset email.';
		}
		
		return String.valueOf(result.getErrors().get(0));
	}

	/**
	 * Executeable from Flow or Process Builder, executes contactWrapper.updateUsers to update contact's user record
	 * @param contactIds
	 */
	@InvocableMethod(label='Cascade fields to user' description='Modifies User record to conform to Contact.')
	public static void cascadeToUser(List<Id> contactIds)
	{
		contactWrapper.updateUsers(contactIds);
	}
	/**
	 * Updates the user records related to the contact Ids supplied in the contactIds paramater
	 * @param contactIds
	 */
	@future(Delay='0')
	public static void updateUsers(List<Id> contactIds)
	{
		List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Id IN: contactIds];
		List<User> users = [SELECT Id, FirstName, LastName, Email, Phone, UserName, ContactId, CommunityNickname FROM User WHERE ContactId IN: contactIds];

		for(Contact aContact : contacts)
		{
			for(User aUser : users)
			{
				if(aUser.ContactId == aContact.Id)
				{
					aUser.UserName = aContact.Email + '.ifsa';
					aUser.FirstName = aContact.FirstName;
				}
			}
		}
		
		Database.update(users);
	}
}