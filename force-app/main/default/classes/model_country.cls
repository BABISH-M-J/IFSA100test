/**
 * @description Model class used to describe a country
 * @author Brock Barlow
 */
public with sharing class model_country extends model_base {
	public Id countryId {get;set;}
	public String Name {get;set;}
	public String marketingRegion {get;set;}
	
	public model_country() {
		this.selectedInSearch = false;
	}
	public model_country(Country__c country)
	{
		this();
		this.countryId = country.Id;
		this.Name = country.Name;
		try 
		{
			this.marketingRegion = country.Marketing_Region__c;
		}
		catch (SObjectException sobEx) 
		{
			this.marketingRegion = null;
		}
		this.setBaseValues();
	}

	private void setBaseValues()
	{
		this.recordId = this.countryId;
		this.recordName = this.name;
		this.sObjectName = 'Country__c';
	}
	
	public override Boolean equals(Object o)
	{
		if(o instanceof model_country)
		{
			model_country obj = (model_country)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}