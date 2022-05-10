/**
 * TriggerHandler for Application Item 
 * @see <<applicationItemService>>, <<BaseTriggerHandler>>
 * @author Brock Barlow
 */
public without sharing class applicationItemTriggerHandler extends BaseTriggerHandler
{
	final List<Application_Item__c> newRecords;
	final List<Application_Item__c> oldRecords;
	final Map<Id, Application_Item__c> oldMap;
	final Map<Id, Application_Item__c> newMap;

	/**
	 * Constructor, populates lists and maps from the Trigger object
	 */
	public applicationItemTriggerHandler()
	{
		this.newRecords = (List<Application_Item__c>) Trigger.new;
		this.oldRecords = (List<Application_Item__c>) Trigger.old;
		this.oldMap = (Map<Id, Application_Item__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Application_Item__c>) Trigger.newMap;
	}

	/**
	 * Before Insert
	 */
	public override void beforeInsert()
	{
		
	}
	/**
	 * Before Update
	 */
    public override void beforeUpdate()
    {        
        applicationItemService.setCompletedAppItem(newMap, oldMap);
    }
	/**
	 * After Insert
	 */
	public override void afterInsert()
    {        
        applicationItemService.fastFormsPrefill(newMap);        
    }
	/**
	 * After Update
	 */
    public override void afterUpdate()
    {        
        applicationItemService.createFollowUpTask(newMap, oldMap);        
	}
	/**
	 * After Delete
	 */
	public override void afterDelete()
    {    	

    }
}