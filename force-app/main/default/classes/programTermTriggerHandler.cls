/**
* @description Trigger Handler for Program Term
* @author Brock Barlow
*/
public with sharing class programTermTriggerHandler extends BaseTriggerHandler
{
	//added by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
	public static boolean firstRun = true;
	//added by PowerFluence req_dt:03/29/2022 ref email from Clayton ends
	final List<Program_Term__c> newRecords;
	final List<Program_Term__c> oldRecords;
	final Map<Id, Program_Term__c> oldMap;
	final Map<Id, Program_Term__c> newMap;

	public programTermTriggerHandler()
	{
		this.newRecords = (List<Program_Term__c>) Trigger.new;
		this.oldRecords = (List<Program_Term__c>) Trigger.old;
		this.oldMap = (Map<Id, Program_Term__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Program_Term__c>) Trigger.newMap;
	}

	public override void beforeInsert()
	{
		System.debug(newRecords.size());
		programTermService.setProgramTermName(newRecords);
		programTermService.assignProgramAndTerm(newRecords);
		programTermService.setDescription(newRecords);
	}

    public override void beforeUpdate()
    {
		programTermService.setDescription(newRecords);
		programTermService.markReadyToBill(newMap, oldMap, programTermService.triggerType.isBefore);
    }

	public override void afterInsert()
    {
		programTermService.programRollup(oldMap, newMap);
		programTermService.updateProgramAvailableSections(newRecords);
    }

    public override void afterUpdate()
    {	
		programTermService.updateApplicationOwner(newMap, oldMap);
		programTermService.updateCMS(newMap.keySet());
		programTermService.markReadyToBill(newMap, oldMap, programTermService.triggerType.isAfter);
		programTermService.datesChangedAfterApproved(newMap, oldMap);
		programTermService.programRollup(oldMap, newMap);
    }
    public override void afterDelete()
    {
		programTermService.programRollup(oldMap, newMap);
    }
	public override void afterUndelete()
	{
		programTermService.programRollup(oldMap, newMap);
	}
	public override void beforeDelete()
	{
		programTermService.deleteRelatedRecords(oldMap);
	}
}