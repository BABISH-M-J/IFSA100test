/**
 * @description Model class used to describe a term
 * @author Brock Barlow
 */
public with sharing class model_term extends model_base{
	public Decimal year {get;set;}
	public String section {get;set;}
	public String name {get;set;}
	public String termId {get;set;}

	public model_term() {
		this.selectedInSearch = false;	
	}

	public model_term(Term__c t)
	{
		this();
		this.termId = t.Id;
		this.name = t.Name;
		this.section = t.Section__c;
		this.year = t.Year__c;
		this.setBaseValues();
	}
	private void setBaseValues()
	{
		this.recordId = this.termId;
		this.recordName = this.name;
		this.sObjectName = 'Term__c';
	}
	
	public override Boolean equals(Object o)
	{
		if(o instanceof model_term)
		{
			model_term obj = (model_term)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}