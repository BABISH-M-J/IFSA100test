public with sharing class model_tag extends model_base
{
	private Tag__c tagRecord;

	public String areaOfStudy { get; set; }
	public String courseId { get; set; }
	public String department { get; set; }
	public String tagType {get;set;}

	public model_tag() {}
	
	public model_tag(Tag__c t)
	{
		tagRecord = t;
		areaOfStudy = (String) populateField('Area_of_Study__c');
		courseId = (String) populateField('Course__c');
		department = (String) populateField('Department__c');
		setBaseValues();
	}

	/**
	 * @description Dynamically populates property in model
	 * @param fieldName - The field name from Course__c
	 * @return Object - The value from the field
	 */
	private Object populateField(String fieldName)
	{
		try
		{
			return tagRecord.get(fieldName);
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}
		return null;
	}

	private void setBaseValues() 
	{
		this.recordId = tagRecord.Id;
		this.recordName = tagRecord.Name;
		this.sObjectName = 'Tag__c';
		if(areaOfStudy != null && department == null)
		{
			tagType = 'Area Of Study';
		}
		else if(areaOfStudy == null && department != null)
		{
			tagType = 'Department';
		}
	}

	public override Boolean equals(Object o)
	{
		if(o instanceof model_tag)
		{
			model_tag obj = (model_tag)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}