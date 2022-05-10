/**
 * Trigger Handler for Case_Host_Institution__c object
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public with sharing class caseHostInstitutionTriggerHandler extends BaseTriggerHandler
{
    final List<Case_Host_Institution__c> newRecords;
	final List<Case_Host_Institution__c> oldRecords;
	final Map<Id, Case_Host_Institution__c> oldMap;
	final Map<Id, Case_Host_Institution__c> newMap;
    /**
	 * Constructor, populates lists and maps from the Trigger object
	 */
    public caseHostInstitutionTriggerHandler()
	{
		this.newRecords = (List<Case_Host_Institution__c>) Trigger.new;
		this.oldRecords = (List<Case_Host_Institution__c>) Trigger.old;
		this.oldMap = (Map<Id, Case_Host_Institution__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Case_Host_Institution__c>) Trigger.newMap;
	}
    /**
     * Before Insert
     */
    public override void afterInsert()
    {
        caseService.linkStudentsToHostInstitutionCase(newRecords);
    }
}