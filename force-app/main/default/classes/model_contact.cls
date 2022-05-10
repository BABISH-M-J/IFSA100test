/**
 * @description Model class used to describe a contact
 * @author Brock Barlow
 */
public with sharing class model_contact extends model_base
{
	@AuraEnabled public Id contactId {get;set;}
	@AuraEnabled public String Name 
	{
		get
		{
			return this.firstName + ' ' + this.lastName;
		}
		private set;
	}	
	@AuraEnabled public String firstName {get;set;}
	@AuraEnabled public String lastName {get;set;}
	@AuraEnabled public String phone {get;set;}
	@AuraEnabled public String mobilePhone {get;set;}
	@AuraEnabled public String homePhone {get;set;}
	@AuraEnabled public String workPhone {get;set;}
	@AuraEnabled public String abroadPhone {get;set;}
	@AuraEnabled public String email {get;set;}
	@AuraEnabled public String mailingStreet {get;set;}
    @AuraEnabled public String mailingCity {get;set;}
	@AuraEnabled public String mailingState {get;set;}
	@AuraEnabled public String mailingPostalCode {get;set;}
    @AuraEnabled public String mailingCountry {get;set;}
    @AuraEnabled public String relationshipWithStudent {get;set;}
    @AuraEnabled public String studentId {get;set;}
	@AuraEnabled public String recordTypeId {get;set;}
    @AuraEnabled public Boolean sendMarketingMaterials {get;set;}
    @AuraEnabled public Boolean isEmergencyContact {get;set;}
    @AuraEnabled public Boolean isInvalid {get;set;}
    @AuraEnabled public Boolean doNotContact {get;set;}
	@AuraEnabled public Contact contactRecord {get;set;}
	@AuraEnabled public String relatedCaseId {get;set;}
	@AuraEnabled public String relatedCaseNumber {get;set;}
	@AuraEnabled public Set<String> tags {get;set;}
	@AuraEnabled public Boolean isCustom {get;set;}
	@AuraEnabled public Boolean isOnSite {get;set;}
	@AuraEnabled public Boolean isTraveling {get;set;}
	@AuraEnabled public Boolean isCompleted {get;set;}
	@AuraEnabled public Boolean isCampaignMember {get;set;}
	@AuraEnabled public Boolean isStudent {get;set;}
	@AuraEnabled public String homeInstitutionName {get;set;}
	@AuraEnabled public String programTermName {get;set;}
	@AuraEnabled public String programCountry {get;set;}

	public model_contact() {
		this.tags = new Set<String>();
		this.selectedInSearch = false;
		this.sObjectName = 'Contact';
	}
	public model_contact(Contact c)
	{
		this();
		this.contactId = c.Id;
		this.FirstName = c.FirstName;
		this.LastName = c.LastName;
		this.Name = this.firstName + ' ' + this.lastName;
		this.abroadPhone = (String) this.populateField('Address_Abroad_Cell_Phone__c', c);
		this.homeInstitutionName = (String) this.populateField('Home_Institution__r.Name', c);
		this.email = (String) this.populateField('Email', c);
		
		this.isStudent = (Id) this.populateField('RecordTypeId', c) == Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
		this.contactRecord = c;
		this.setBaseValues();
	}
	
	public model_contact(Contact c, Boolean isRelatedContact)
	{
		this(c);
		if(isRelatedContact)
		{
			this.mobilePhone = c.MobilePhone;
			this.homePhone = c.HomePhone;
			this.workPhone  = c.Phone;
			this.email = c.Email;
			this.mailingStreet = c.MailingStreet;
			this.mailingCity = c.MailingCity;
			this.mailingState = c.MailingState;
			this.mailingPostalCode = c.MailingPostalCode;
			this.mailingCountry = c.MailingCountry;
			this.relationshipWithStudent = c.Relationship_With_Student__c;
			this.studentId = c.Student__c;
			this.recordTypeId = c.RecordTypeId;
			this.sendMarketingMaterials = c.Send_Marketing_Materials__c;
			this.isEmergencyContact = c.Emergency_Contact__c;
			this.doNotContact = c.Do_Not_Contact__c;
			this.isInvalid = false;
			Boolean hasPhone = (mobilePhone != null || workPhone != null || homePhone != null);
			if(hasPhone == false || email == null || mailingStreet == null || mailingCity == null || mailingState == null ||
				mailingPostalCode == null || mailingCountry == null || relationshipWithStudent == null || firstName == null || lastName == null)
			{
				this.isInvalid = true;
			}
		}
	}

	private void setBaseValues()
	{
		this.recordId = this.contactId;
		this.recordName = this.name;
	}

	public override Boolean equals(Object o)
	{
		if(o instanceof model_contact)
		{
			model_contact obj = (model_contact)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}