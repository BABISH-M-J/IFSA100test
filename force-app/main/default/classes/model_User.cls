/**
 * @description Model class used to describe a user
 * @author Brock Barlow
 */
public with sharing class model_User extends model_base
{
	public String userId {get;set;}
	public String firstName {get; set;}
	public String lastName {get;set;}
	public String email {get;set;}
	public String name 
	{
		get
		{
			return this.firstName + ' ' + this.lastName;
		}
		private set;
	}
	public model_User() 
	{		
		
	}
	public model_User(String userId)
	{
		Id sId = userId;
		String sobjectType = sId.getSObjectType().getDescribe().getName();
		if(sobjectType == 'User')
		{
			User thisUser = [SELECT Id, FirstName, LastName, Email FROM User WHERE Id =: sId];
			this.userId = thisUser.Id;
			this.firstName = thisUser.FirstName;
			this.lastName = thisUser.LastName;
			this.email = thisUser.Email;
		}
		else if(sobjectType == 'Group')
		{
			Group thisQueue = [SELECT Id, Name FROM Group WHERE Id =: sId];
			this.userId = thisQueue.Id;
			this.firstName = thisQueue.Name;
		}
		
		this.setBaseValues();
	}
	public model_User(String userId, String firstName, String lastName)
	{
		this.userId = userId;
		this.firstName = firstName;
		this.lastName = lastName;
		this.name = this.firstName + ' ' + this.lastName;
		this.setBaseValues();

	}
	public model_User(String userId, String firstName, String lastName, String emailaddress)
	{
		this(userId, firstName, lastName);
		this.email = emailaddress;
		this.setBaseValues();
	}
	private void setBaseValues()
	{
		this.recordId = this.userId;
		this.recordName = this.name;
		this.sObjectName = 'User';
	}

	public override Boolean equals(Object o)
	{
		if(o instanceof model_User)
		{
			model_User obj = (model_User)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}