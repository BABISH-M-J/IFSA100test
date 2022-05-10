/**
 * @description Model class used to describe a program option
 * @author Brock Barlow
 */
public with sharing class model_support_personnel extends model_base
{
	public Id supportPersonnelId {get;set;}
	public String supportPersonnelName {get;set;}
	public Boolean isEmergencyContact {get;set;}
	public String contactName {get;set;}
	public String contactLastName {get;set;}
	public String accountName {get;set;}
	public String accountId {get;set;}
	public String emailAddress {get;set;}
	public String phoneNumber {get;set;}
	public String nonIfsaStaffId {get;set;}
	public String supportRoleType {get;set;}
	public String recordTypeName {get;set;}
	public Integer numberOfTraveling {get;set;}
	public Integer numberOfOnSite {get;set;}
	public Integer numberOfProgramCompleted {get;set;}


	public model_support_personnel() 
	{
		this.numberOfTraveling = 0;
		this.numberOfOnSite = 0;
		this.numberOfProgramCompleted = 0;
	}

	public model_support_personnel(Support_Personnel__c sp)
	{
		// These fields must be referenced in the 'sp' record.
		this();
		this.supportPersonnelId = sp.Id;
		this.supportPersonnelName = sp.Name;
		this.isEmergencyContact = sp.Emergency_Contact__c;
		this.nonIfsaStaffId = sp.Non_IFSA_Staff__c;
		this.contactName = sp.Non_IFSA_Staff__r.Name;
		this.supportRoleType = sp.Support_Role_Type__c;
		try
		{
			this.contactLastName = sp.Non_IFSA_Staff__r.LastName;
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}
		try
		{
			this.accountName = sp.Account__r.Name;
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}
		try
		{
			this.accountId = sp.Account__c;
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}
		try
		{
			this.emailAddress = sp.Email__c;
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}
		try
		{
			this.phoneNumber = sp.Phone__c;
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}
		try
		{
			this.recordTypeName = sp.RecordType.Name;
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}
	}

	private void setBaseValues()
	{
		this.recordId = this.supportPersonnelId;
		this.recordName = this.contactName;
		this.sObjectName = 'Support_Personnel__c';
	}
	
	public override Boolean equals(Object o)
	{
		if(o instanceof model_support_personnel)
		{
			model_support_personnel obj = (model_support_personnel)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}