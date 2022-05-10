/**
 * @description Model class used to describe a program term
 * @author Brock Barlow
 */
public with sharing class model_program_term extends model_base
{
	public Id programTermId {get;set;}
	public String name {get;set;}
	public Id programId {get;set;}
	public Id termId {get;set;}
	public Id countryId {get;set;}
	public Boolean hasError {get;set;}
	public List<String> errors {get;set;}
	public List<model_program_term> progarmOptions {get;set;}

	public model_program_term() 
	{
		this.selectedInSearch = false;
		this.hasError = false;
		this.progarmOptions = new List<model_program_term>();
	}

	public model_program_term(Program_Term__c pt)
	{
		this();
		this.programTermId = pt.Id;
		this.name = pt.Name;
		this.countryId = pt.Country__c;
		this.programId = pt.Program__c;
		this.termId = pt.Term__c;
		this.setBaseValues();
	}

	private void setBaseValues()
	{
		this.recordId = this.programTermId;
		this.recordName = this.name;
		this.sObjectName = 'Program_Term__c';
	}
	
	public override Boolean equals(Object o)
	{
		if(o instanceof model_program_term)
		{
			model_program_term obj = (model_program_term)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}