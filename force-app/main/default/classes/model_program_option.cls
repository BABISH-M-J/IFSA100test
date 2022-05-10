/**
 * @description Model class used to describe a program option
 * @author Brock Barlow
 */
public with sharing class model_program_option extends model_base {
	
	public String name {get; set;}
	public Id programOptionId {get;set;}
	public Id programTermId {get;set;}

	public model_program_option() {
		this.selectedInSearch = false;
	}

	public model_program_option(Program_Option__c po)
	{
		this.name = po.Name;
		this.programOptionId = po.Id;
		//this.programTermId = po.Program_Term__c;
		this.setBaseValues();
	}
	

	private void setBaseValues()
	{
		this.recordId = this.programOptionId;
		this.recordName = this.name;
		this.sObjectName = 'Program_Option__c';
	}
	
	public override Boolean equals(Object o)
	{
		if(o instanceof model_program_option)
		{
			model_program_option obj = (model_program_option)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}