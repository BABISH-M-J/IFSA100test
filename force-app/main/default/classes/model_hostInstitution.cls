/**
 * @description Model class used to describe a host institution
 * @author Brock Barlow
 */
public with sharing class model_hostInstitution extends model_base
{
	public Id hostInstitutionId {get;set;}
	public String Name {get;set;}
	public String countryId {get;set;}
	public String localityId {get;set;}

	public model_hostInstitution() {
		this.selectedInSearch = false;
	}
	public model_hostInstitution(Host_Institution__c host)
	{
		this();
		this.hostInstitutionId = host.Id;
		this.Name = host.Name;
		try
		{
			this.countryId = host.Country__c;
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}
		try
		{
			this.localityId = host.Locality__c;
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}
		this.setBaseValues();
	}
	private void setBaseValues()
	{
		this.recordId = this.hostInstitutionId;
		this.recordName = this.name;
		// system.debug(this.recordName);
		this.sObjectName = 'Host_Institution__c';
	}
	
	public override Boolean equals(Object o)
	{
		if(o instanceof model_hostInstitution)
		{
			model_hostInstitution obj = (model_hostInstitution)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}