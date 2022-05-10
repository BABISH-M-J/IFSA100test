/**
* @description Utility class to sync information from the contact record to the user record
* @author Cameron Ames
*/
public class syncUserContactRecords implements Queueable {
	private List<Id> contactIds;

	public syncUserContactRecords(List<Id> contactIds)
	{
		this.contactIds = contactIds;
	}

	public void execute(QueueableContext context) {		
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
					aUser.Title = aContact.Title != null && aContact.Title.length() > 80 ? aContact.Title.substring(0, 79) : aContact.Title;
					aUser.Phone = aContact.Phone;
				}
			}
		}
		
		if(!Test.isRunningTest())
		{
			Database.update(users);
		}
	}
}