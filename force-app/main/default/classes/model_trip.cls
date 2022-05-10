/**
 * @description Model class used to describe a trip
 * @author Brock Barlow
 */
public with sharing class model_trip extends model_base
{
	public String travelId {get;set;}
	public String applicationId {get;set;}
	public String contactId {get;set;}
	public String countryId {get;set;}
	public String countryName {get;set;}
	public DateTime startDate {get;set;}
	public DateTime endDate {get;set;}
	public String description {get;set;}
	public String localityId {get;set;}
	public String localityName {get;set;}
	public String selectedStatus {get;set;}
	public List<String> statuses {get;set;}
	public String tripPhoneCountry {get;set;}
	public String tripPhoneCountryName {get;set;}
	public String tripPhone {get;set;}

	public model_trip() {}	

	public model_trip(Trip__c t)
	{
		this.travelId = t.Id;
		this.applicationId = t.Application__c;
		this.contactId = t.Contact__c;
		this.countryId = t.Country__c;
		this.countryName = t.Country_Text__c;
		this.endDate = t.End_Date__c;
		this.startDate = t.Start_Date__c;
		this.description = t.Description__c;
		this.localityId = t.Locality__c;
		this.localityName = t.Locality_Text__c;
		this.selectedStatus = t.Status__c;
		this.statuses = apexConversionUtility.getPicklistStringValues(Trip__c.Status__c);
		this.tripPhoneCountry = t.Trip_Phone_Country__c;
		this.tripPhoneCountryName = t.Trip_Phone_Country__r.Name;
		this.tripPhone = t.Trip_Phone__c;
	}

	public model_trip(String tId)
	{
		this((Trip__c) apexQueryUtility.selectAllFrom('Trip__c', 'Trip_Phone_Country__r.Name', 'Id=\'' + tId + '\'').get(0));
	}

	private void setBaseValues()
	{
		this.recordId = this.travelId;
		//this.recordName = this.name;
		this.sObjectName = 'Trip__c';
	}
	
	public override Boolean equals(Object o)
	{
		if(o instanceof model_trip)
		{
			model_trip obj = (model_trip)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}

	public String save()
	{
		if(this.countryId == null)
		{
			try
			{
				ifsaRecordLookupViewModel countryLookup = ifsaRecordLookupMethods.searchForRecord('Country__c', this.countryName).get(0);
				this.countryId = countryLookup.name == this.countryName ? countryLookup.id : null;
			}
			catch(Exception e)
			{
				this.countryId = null;
			}

		}

		if(this.localityId == null)
		{
			try
			{
				ifsaRecordLookupViewModel localityLookup = ifsaRecordLookupMethods.searchForRecord('Locality__c', this.localityName).get(0);
				this.localityId = localityLookup.name == this.localityName ? localityLookup.id : null;
			}
			catch(Exception e)
			{
				this.localityId = null;
			}

		}

		Trip__c t = new Trip__c();		
		t.Id = this.travelId != '' ? this.travelId : null;
		t.Application__c = this.applicationId;
		t.Contact__c = this.contactId;
		t.Country__c = this.countryId;
		t.Country_Text__c = this.countryName;
		t.End_Date__c = this.endDate.Date();
		t.Start_Date__c = this.startDate.Date();
		t.Description__c = this.description;
		t.Locality__c = this.localityId;
		t.Locality_Text__c = this.localityName;
		t.Status__c = this.selectedStatus;
		t.Trip_Phone_Country__c = this.tripPhoneCountry;
		t.Trip_Phone__c = this.tripPhone;

		try
		{
			Database.upsert(t);
			this.travelId = t.Id;
			return t.Id;
		}
		catch(Exception e)
		{
			throw e;
		}
	}
}