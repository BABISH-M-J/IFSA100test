/**
 * @description Model class used to describe a record type
 * @author Brock Barlow
 */
public with sharing class model_recordType extends model_base
{
	public String recordTypeId {get;set;}
	public String name {get;set;}
	public String developerName {get;set;}
	public String description {get;set;}

	public model_recordType() 
	{
		
	}

	public model_recordType(RecordType rt)
	{
		this.recordTypeId = rt.Id;
		this.name = rt.Name;
		this.developerName = rt.DeveloperName;
		this.description = rt.Description;
		this.setBaseValues();
	}

	private void setBaseValues()
	{
		this.recordId = this.recordTypeId;
		this.recordName = this.name;
		this.sObjectName = 'RecordType';
	}
	
	public override Boolean equals(Object o)
	{
		if(o instanceof model_recordType)
		{
			model_recordType obj = (model_recordType)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}