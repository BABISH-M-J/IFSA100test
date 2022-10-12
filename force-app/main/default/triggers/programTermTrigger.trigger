/**
 * @description Trigger for Program Term object.
 * @author Brock Barlow
 */
trigger programTermTrigger on Program_Term__c (before insert, before update, after insert, after update, before delete, after delete, after undelete)
{	
	new programTermTriggerHandler().run();
	/*
	//(List<Application__c> newRecords, List<Application__c> oldRecords, Map<Id, Application__c> oldMap, Map<Id, Application__c> newMap)
	programTermTriggerHandler handler = new programTermTriggerHandler(Trigger.new, Trigger.old, Trigger.oldMap, Trigger.newMap);

	if(trigger.isBefore && trigger.isUpdate)
	{
		handler.beforeUpdate();
	}
	if(trigger.isBefore && trigger.isInsert) 
    {
    	handler.beforeInsert();
    }
	if (trigger.isAfter && trigger.isUpdate)
	{
		handler.afterUpdate();
	}
	if(trigger.isAfter && trigger.isDelete)
	{
		handler.afterDelete();
	}
	if(trigger.isAfter && trigger.isInsert)
	{
		handler.afterInsert();
	}
	*/
}