/**
 * Trigger Handler for Case_City__c object
 * @author Brock barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public with sharing class caseCityTriggerHandler  extends BaseTriggerHandler
{
    final List<Case_City__c> newRecords;
	final List<Case_City__c> oldRecords;
	final Map<Id, Case_City__c> oldMap;
	final Map<Id, Case_City__c> newMap;
    /**
	 * Constructor, populates lists and maps from the Trigger object
	 */
	public caseCityTriggerHandler()
	{
		this.newRecords = (List<Case_City__c>) Trigger.new;
		this.oldRecords = (List<Case_City__c>) Trigger.old;
		this.oldMap = (Map<Id, Case_City__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Case_City__c>) Trigger.newMap;
    }
    /**
     * Before Insert
     */
	public override void afterInsert()
    {
        caseService.linkStudentsToCityCase(newRecords);
    }
}