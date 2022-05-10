/**
 * Allows Program Advisors to Log a call to multiple applications
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public with sharing class applicationLogACallController {
	
	ApexPages.StandardSetController setCon;
	/** A task record to be created */
	public Task t {get;set;}
	/** The applications to relate to the task */
	public List<Application__c> applications {get;set;}
	/** Too Many Applications Selected */
	public Boolean tooManyApps {get;set;}
	/** No Applications Selected */
	public Boolean noApps {get;set;}

	/**
	 * Contstructor, Ensures that atleat one application is selected and that no more than 50 are selected
	 * @param controller A Standard Set Controller
	 */
	public applicationLogACallController(ApexPages.StandardSetController controller)
	{
		setCon = controller;		
		this.applications = (Application__c[])setCon.getSelected();
		this.t = new Task(
			OwnerId = UserInfo.getUserId(), 
			Subject = 'Call', 
			Status = 'Completed', 
			ActivityDate = Date.today(), 
			RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Simple Task').getRecordTypeId()
			//WhoId = this.applications.get(0).Applicant__c
		);
		this.tooManyApps = this.applications.size() > 50;
		this.noApps = this.applications.isEmpty();
		if(this.noApps)
		{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'There are not any selected applications.');
			ApexPages.addMessage(myMsg);
		}
		if(this.tooManyApps)
		{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'You have selected too many applications. Multi App Log A Call will only work with 50 or less. Please click the Back button and select fewer applications');
			ApexPages.addMessage(myMsg);
		}
	}
	/**
	 * Creates a new task and links the selected applications
	 * @return PageReference (Null is returned on a fail, The task is opened on success)
	 */
	public pageReference save()
    {
		
		Database.SaveResult taskSave = database.insert(this.t);
		Boolean relationsFailed = false;
		
		if(taskSave.isSuccess())
		{
			Database.SaveResult[] relationsSave = null;
			Set<TaskRelation> relations = new Set<TaskRelation>();
			system.debug(this.applications.size());
			for(Application__c app: this.applications)
			{
				TaskRelation tr = new TaskRelation(
					RelationId = app.Applicant__c,
					TaskId = this.t.Id
				);
				system.debug(tr);
				relations.add(tr);
			}
			relationsSave = database.insert(new List<TaskRelation>(relations));
			for(Database.SaveResult sr: relationsSave)
			{
				if(!sr.isSuccess())
				{
					relationsFailed = true;
					break;
				}
			}
			if(relationsFailed)
			{
				database.delete(this.t);
			}
		}
        if(!taskSave.isSuccess() || relationsFailed)
		{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Unable to save records');
            ApexPages.addMessage(myMsg);
			return null;
		}
		return new PageReference('/' + this.t.Id);
    }
}