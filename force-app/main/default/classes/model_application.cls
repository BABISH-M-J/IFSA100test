/**
 * @description Model class used to describe an application
 * @author Brock Barlow
 */
public with sharing class model_application extends model_base {
	public Id applicationId {get;set;}
	public String Name {get;set;}
	public String status {get;set;}
	public String applicantId {get;set;}
	public String studentName {get;set;}
	public Application__c applicaitonRecord {get;set;}
	public String programTermName {get;set;}

	public model_application ()
	{
		this.sObjectName = 'Application__c';
	}

	public model_application (Application__c a)
	{
		this();
		this.applicationId = a.Id;		
		try
		{
			this.Name = a.Name;
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}
		try
		{
			this.status = a.Status__c;	
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}

		try
		{
			this.applicantId = a.Applicant__c;
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}

		try
		{
			this.studentName = a.Student_First_Name__c + ' ' + a.Student_Last_Name__c;
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}
		try
		{
			this.programTermName = a.Program_Term__r.Name;
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}

		this.applicaitonRecord = a;
		this.setBaseValues();
	}

	private void setBaseValues()
	{
		this.recordId = this.applicationId;
		this.recordName = this.Name;
	}

	public override Boolean Equals(Object o)
	{
		if(o instanceof model_application)
		{
			model_application obj = (model_application)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}

	
}