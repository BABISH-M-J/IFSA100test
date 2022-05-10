/**
 * @description Model class used to describe a home institution
 * @author Brock Barlow
 */
public with sharing class model_homeInstitution extends model_base
{
	public Id homeInstitutionId {get;set;}
	public String name {get;set;}
	public String countryId {get;set;}
	public String localityId {get;set;}

	public model_homeInstitution() {
		this.selectedInSearch = false;
	}

	public model_homeInstitution(Home_Institution__c hi)
	{
		this();
		this.homeInstitutionId = hi.Id;
		this.name = hi.Name;
		try
		{
			this.countryId = hi.Country__c;
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}
		try
		{
			this.localityId = hi.Locality__c;
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}
		this.setBaseValues();
	}

	private void setBaseValues()
	{
		this.recordId = this.homeInstitutionId;
		this.recordName = this.name;
		this.sObjectName = 'Home_Institution__c';
	}

	public override Boolean equals(Object o)
	{
		if(o instanceof model_homeInstitution)
		{
			model_homeInstitution obj = (model_homeInstitution)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}