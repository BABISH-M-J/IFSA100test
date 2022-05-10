/**
* @description Viewmodel for Application_Item__c used with SP_Apply and SP_Commit to 
* generate the tiles in the student portal
* @author Cameron Ames
*/
public without sharing class studentApplyItemViewModel
{
	public Id id {get;set;}
	public String name {get;set;}
	public String status {get;set;}
	public String phase {get;set;}
	public String recordTypeName { get; set; }
	public Date deadline { get; set; }
	public Boolean isStarted 
	{
		get
		{
			if(isStarted != true)
			{
				isStarted = this.status == 'Started';
			}
			return isStarted;
		}
		set;
	}

	public Boolean isComplete
	{
		get
		{
			if(isComplete != true)
			{
				isComplete = this.status == 'Complete';
			}
			return isComplete;
		}
		set;
	}
	public Boolean formActive { get; set; }
	
	public studentApplyItemViewModel() {}

	public studentApplyItemViewModel(Application_Item__c appItem) {
		this.id = appItem.Id;
		this.name = appItem.Name;
		this.status = appItem.Status__c;
		this.recordTypeName = appItem.RecordType.Name;
		this.phase = appItem.Phase__c;
		this.deadline = appItem.Deadline__c;
		this.formActive = (appItem.Application_Requirement__r.Dynamic_Form__c != null && appItem.Application_Requirement__r.Dynamic_Form__r.Status__c == 'Published') || appItem.Application_Requirement__r.Dynamic_Form__c == null;
	}
}