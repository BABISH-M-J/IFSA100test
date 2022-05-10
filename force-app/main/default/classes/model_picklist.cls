/**
 * @description Model class used to describe a picklist item
 * @author Brock Barlow
 */
public with sharing class model_picklist extends model_base{
	public String apiName {get;set;}
	public String label {get;set;}
	
	public model_picklist() {
		
	}
	public model_picklist(Schema.PicklistEntry item)
	{
		this.apiName = item.getValue();
		this.label = item.getLabel();
	}
	public static model_picklist getModelFromList(List<model_picklist> picklist, String fieldValue)
	{
		for(model_picklist value: picklist)
		{
			if(value.apiName == fieldValue)
			{
				return value;
			}
		}
		return null;
	}
	private void setBaseValues()
	{
		//this.recordId = this.localityId;
		this.recordName = this.label;
		this.sObjectName = 'PicklistEntry';
	}
	
	public override Boolean equals(Object o)
	{
		if(o instanceof model_picklist)
		{
			model_picklist obj = (model_picklist)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}