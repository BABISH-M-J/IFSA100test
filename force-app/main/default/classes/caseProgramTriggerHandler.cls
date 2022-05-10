/**
 * Trigger Handler for Case_Program__c object
 * @author Brock barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public with sharing class caseProgramTriggerHandler  extends BaseTriggerHandler
{
    final List<Case_Program__c> newRecords;
	final List<Case_Program__c> oldRecords;
	final Map<Id, Case_Program__c> oldMap;
	final Map<Id, Case_Program__c> newMap;
    /**
	 * Constructor, populates lists and maps from the Trigger object
	 */    
	public caseProgramTriggerHandler()
	{
		this.newRecords = (List<Case_Program__c>) Trigger.new;
		this.oldRecords = (List<Case_Program__c>) Trigger.old;
		this.oldMap = (Map<Id, Case_Program__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Case_Program__c>) Trigger.newMap;
    }
    /**
     * Before Insert
     */
    public override void afterInsert()
    {
        caseService.linkStudentsToProgramCase(newRecords);
    }
}