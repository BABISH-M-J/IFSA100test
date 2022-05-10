/**
 * Trigger Handler for Case_Country__c object
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public with sharing class caseCountryTriggerHandler extends BaseTriggerHandler
{
    final List<Case_Country__c> newRecords;
	final List<Case_Country__c> oldRecords;
	final Map<Id, Case_Country__c> oldMap;
    final Map<Id, Case_Country__c> newMap;
    /**
	 * Constructor, populates lists and maps from the Trigger object
	 */
    public caseCountryTriggerHandler()
	{
		this.newRecords = (List<Case_Country__c>) Trigger.new;
		this.oldRecords = (List<Case_Country__c>) Trigger.old;
		this.oldMap = (Map<Id, Case_Country__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Case_Country__c>) Trigger.newMap;
	}
    /**
     * Before Insert
     */
    public override void afterInsert()
    {
        caseService.linkStudentsToCountryCase(newRecords);
    }
}