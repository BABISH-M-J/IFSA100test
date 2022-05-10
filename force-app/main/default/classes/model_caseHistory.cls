/**
 * @description Model class used to describe a case history record
 * @author Brock Barlow
 */
public with sharing class model_caseHistory extends model_base {
	public String caseHistoryId {get;set;}
	public model_case relatedCase {get;set;}
	public String field {get;set;}
	public object oldValue {get;set;}
	public object newValue {get;set;}
	public model_user createdBy {get;set;}
	public DateTIme createdDate {get;set;}
	
	public model_caseHistory() {
		
	}
	public model_caseHistory(CaseHistory record, Case relatedCaseRecord) {
		this.caseHistoryId = record.Id;
		this.relatedCase = new model_case(relatedCaseRecord);
		system.debug(record.Field);
		try 
		{
			Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();
			Schema.DescribeFieldResult field = objectFields.get(record.Field).getDescribe();
			system.debug(field.getLabel());
			this.field = field.getLabel();
		}
		catch(NullPointerException e)
		{
			this.field = record.Field;
		}		
		this.oldValue = record.OldValue;
		this.newValue = record.NewValue;
		this.createdBy = new model_user(record.CreatedById, record.CreatedBy.FirstName, record.CreatedBy.LastName);
		this.createdDate = record.CreatedDate;
		this.setBaseValues();
	}

	private void setBaseValues()
	{
		this.recordId = this.caseHistoryId;
		this.sObjectName = 'CaseHistory';
		//this.recordName = this.name;
	}

	public override Boolean equals(Object o)
	{
		if(o instanceof model_caseHistory)
		{
			model_caseHistory obj = (model_caseHistory)o;
			return (this.recordId == obj.recordId);
		}
		return false;
	}
}