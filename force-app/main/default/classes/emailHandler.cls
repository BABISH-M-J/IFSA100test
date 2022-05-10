/**
 * Class for handling apex outbound email.
 * @author Cameron Ames
 */
// ApexDoc updated 2/1/2021 Brock Barlow
public without sharing class emailHandler
{
	/**
	 * Sends an email welcoming the student to the custom portal.
	 */
	public static void sendCustomPortalWelcomeEmail(List<Contact> contacts)
	{
		if(contacts == null || contacts.size() <= 0)
		{
			return;
		}

		List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
		Id templateId = [SELECT Id FROM EmailTemplate WHERE Name = : 'CustomPortalWelcome' LIMIT 1].Id;

		for(Contact aContact : contacts)
		{
			Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
			emailMessage.setTemplateId(templateId);
			emailMessage.setTargetObjectId(aContact.Id);
			emailMessages.add(emailMessage);
		}

		if(configurationManager.shouldSendCustomPortalWelcomeEmail())
		{
			//This is a crappy workaround because sendMail fails in unit testing but otherwise works fine...
			//See https://success.salesforce.com/issues_view?id=a1p300000008aRlAAI
			//Brock Barlow - 7/20/2016
			Boolean isTestMode = configurationManager.isTestMode();
			if(!isTestMode)
			{
				Messaging.sendEmail(emailMessages, true);
			}
		}
	}
}