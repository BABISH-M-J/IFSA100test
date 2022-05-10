/**
 * @description Model class used to describe a case
 * @author Brock Barlow
 */
public with sharing class model_Case extends model_base
{
	public Id caseId {get;set;}
	public String caseNumber {get;set;}
	public String description {get;set;}
	public String subject {get;set;}
	public String priority {get;set;}
	public String severity {get;set;}
	public Datetime dateTimeOpened {get;set;}
	public String status {get;set;}
	public String owner {get;set;}
	public String student {get;set;}
	
	public model_Case()
	{

	}

	public model_Case(Case childCase)
	{
		this.caseId = childCase.Id;
		this.caseNumber = childCase.CaseNumber;
		this.description = childCase.Description;
		this.subject = childCase.Subject;
		this.status = childCase.Status;
		this.severity = childCase.Incident_Severity__c;
		this.priority = childCase.Priority;
		this.dateTimeOpened = childCase.CreatedDate;
		this.owner = childCase.Owner.Name;
		this.student = childCase.Student__c;
		this.setBaseValues();
	}

	private void setBaseValues()
	{
		this.recordId = this.caseId;
		this.recordName = this.caseNumber;
		this.sObjectName = 'Case';
	}
	
	public override Boolean equals(Object o)
	{
		if(o instanceof model_Case)
		{
			model_Case obj = (model_Case)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}