/**
 * @description Model class used to describe a task
 * @author Brock Barlow
 */
public with sharing class model_task extends model_base
{
	public String taskId {get;set;}
	public String whatId {get;set;}
	public String status {get;set;}
	public String subject {get;set;}		
	public String comments {get;set;}
	public Date dueDate {get;set;}
	public DateTime lastModifiedDate {get;set;}
	public String whoId {get;set;}
	public String whoName {get;set;}
	public model_user owner {get;set;}
	public String priority {get;set;}

	public model_task() {
		
	}
	public model_task(Task t) 
	{
		this.taskId = t.Id;
		this.whatId = t.WhatId;
		this.whoId = t.WhoId;
		this.whoName = t.Who.Name;
		this.status = t.Status;
		this.subject = t.Subject;
		this.comments = t.Description;
		this.dueDate = t.ActivityDate;
		this.lastModifiedDate = t.LastModifiedDate;
		this.owner = new model_user(t.OwnerId, t.Owner.FirstName, t.Owner.LastName);
		this.priority = t.Priority;
		this.setBaseValues();
	}

	private void setBaseValues()
	{
		this.recordId = this.taskId;
		this.recordName = this.subject;
		this.sObjectName = 'Task';
	}
	
	public override Boolean equals(Object o)
	{
		if(o instanceof model_task)
		{
			model_task obj = (model_task)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}