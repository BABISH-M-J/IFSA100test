/**
 * @description Model class used to describe a contact support personnel
 * @author Brock Barlow
 */
public with sharing class model_contactSupport extends model_base
{
	@AuraEnabled public String contactSupportId {get;set;}
	@AuraEnabled public String name {get;set;}
	@AuraEnabled public String studentContact {get;set;}
	@AuraEnabled public String studentContactName {get;set;}
	@AuraEnabled public String homeInstitution {get;set;}
	@AuraEnabled public String homeInstitutionName {get;set;}
	@AuraEnabled public String hostInstitution {get;set;}
	@AuraEnabled public String acct {get;set;}
	@AuraEnabled public String program {get;set;}
	@AuraEnabled public String programTerm {get;set;}
	@AuraEnabled public String programOption {get;set;}
	@AuraEnabled public String supportPersonnelName {get;set;}
	@AuraEnabled public String supportPersonnelPhone {get;set;}
	@AuraEnabled public String supportPersonnelEmail {get;set;}
	@AuraEnabled public String supportRoleTypeName {get;set;}
	@AuraEnabled public Boolean isEcontact {get;set;}
	@AuraEnabled public Set<String> tags {get;set;}
	@AuraEnabled public Boolean isCampaignMember {get;set;}

	public model_contactSupport() {
		tags = new Set<String>();
	}
	public model_contactSupport(Contact_Support_Personnel__c csp)
	{
		this();
		this.contactSupportId = csp.Support_Personnel__r.Non_IFSA_Staff__c;
		this.name = csp.Name;
		this.studentContact = csp.Contact__c;
		this.studentContactName = csp.Contact__r.Name;
		this.homeInstitution = csp.Support_Personnel__r.Home_Institution__c;
		this.homeInstitutionName = csp.Contact__r.Home_Institution__r.Name;
		this.hostInstitution = csp.Support_Personnel__r.Host_Institution__c;
		this.acct = csp.Support_Personnel__r.Account__r.Name;
		this.program = csp.Support_Personnel__r.Program__c;
		this.programTerm = csp.Support_Personnel__r.Program_Term__c;
		this.programOption = csp.Support_Personnel__r.Program_Option__c;
		this.supportPersonnelName = csp.Support_Personnel__r.SP_Plain_Text_Name__c;
		this.supportPersonnelPhone = csp.Support_Personnel__r.Non_IFSA_Staff__r.Phone;
		this.supportPersonnelEmail = csp.Support_Personnel__r.Non_IFSA_Staff__r.Email;
		this.supportRoleTypeName = csp.Support_Personnel__r.Support_Role_Type__c;
		this.isEcontact = csp.Support_Personnel__r.Emergency_Contact__c;
		this.setBaseValues();
	}

	private void setBaseValues()
	{
		this.recordId = this.contactSupportId;
		this.recordName = this.name;
		this.sObjectName = 'Contact_Support_Personnel__c';
	}

	public override Boolean equals(Object o)
	{
		if(o instanceof model_contactSupport)
		{
			model_contactSupport obj = (model_contactSupport)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}