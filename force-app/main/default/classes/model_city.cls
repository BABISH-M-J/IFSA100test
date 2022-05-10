/**
 * @description Model class used to describe a city
 * @author Brock Barlow
 */
public with sharing class model_city  extends model_base {
	public String localityId {get;set;}
	public String name {get;set;}
	public String countryId {get;set;}
	
	public model_city()
	{
		this.selectedInSearch = false;
	}
	public model_city(Locality__c locality)
	{
		this();
		this.localityId = locality.Id;
		this.name = locality.name;
		this.countryId = locality.Country__c;
		this.setBaseValues();
	}

	private void setBaseValues()
	{
		this.recordId = this.localityId;
		this.recordName = this.name;
		this.sObjectName = 'Locality__c';
	}

	public override Boolean equals(Object o)
	{
		if(o instanceof model_city)
		{
			model_city obj = (model_city)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}