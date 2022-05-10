public with sharing class model_schedule extends model_base
{
	public String accommodation {get;set;}
	public String countryId {get;set;}
	public String countryName {get;set;}
	public String description {get;set;}
	public String displayName {get;set;}
	public Date endDate {get;set;}
	public String endTime {get;set;}
	public String location {get;set;}
	public String mealDetails {get;set;}
	public Boolean mealsIncluded {get;set;}
	public String programTermId {get;set;}
	public String rsvpDetails {get;set;}
	public Boolean rsvpRequired {get;set;}
	public Date startDate {get;set;}
	public String startTime {get;set;}
	public String status {get;set;}
	public String transportationDetails {get;set;}
	public String type {get;set;}
	public String waiverRequired {get;set;}	


	public model_schedule() 
	{
		this.sObjectName = 'Schedule';
	}

	public model_schedule(Schedule__c schedule)
	{
		this();
		this.recordId = schedule.Id;
		this.recordName = schedule.Name;
		this.displayName = schedule.Name__c;
		this.accommodation = schedule.Accommodation__c;
		this.countryId = schedule.Country__c;
		this.countryName = schedule.Country__r.Name;
		this.description = schedule.Description__c;
		this.endDate = schedule.End_Date__c;
		this.endTime = schedule.End_Time__c;
		this.location = schedule.Location__c;
		this.mealDetails = schedule.Meal_Details__c;
		this.mealsIncluded = schedule.Meal_Included__c == true ? true : false;
		this.programTermId = schedule.Program_Term__c;
		this.rsvpDetails = schedule.RSVP_Details__c;
		this.rsvpRequired = schedule.RSVP_Required__c;
		this.startDate = schedule.Start_Date__c;
		this.startTime = schedule.Start_Time__c;
		this.transportationDetails = schedule.Transportation_Details__c;
		this.type = schedule.RecordType.Name;
		this.waiverRequired = schedule.Waiver_Required__c;
	}

	private void setBaseValues()
	{
		// This method is required by the base class but is not needed for this class because we are not
		// going to create properites on this class called 'scheduleName' or 'scheduleId' and just use the 
		// properties on the base class 'recordName' and 'recordId'
	}

	public override Boolean equals(Object o)
	{
		if(o instanceof model_schedule)
		{
			model_schedule obj = (model_schedule)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}