/**
 * Trigger Handler for Host_Institution__c object
 * @see <<hostInstitutionService>>, <<BaseTriggerHandler>>
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class hostInstitutionTriggerHandler extends BaseTriggerHandler
{
    final List<Host_Institution__c> newRecords;
    final List<Host_Institution__c> oldRecords;
    final Map<Id, Host_Institution__c> oldMap;
    final Map<Id, Host_Institution__c> newMap;
    /**
	 * Constructor, populates lists and maps from the Trigger object
	 */
    public hostInstitutionTriggerHandler() {
        this.newRecords = (List<Host_Institution__c>) Trigger.new;
        this.oldRecords = (List<Host_Institution__c>) Trigger.old;
        this.oldMap = (Map<Id, Host_Institution__c>) Trigger.oldMap;
        this.newMap = (Map<Id, Host_Institution__c>) Trigger.newMap;
    }
    /**
	 * After Insert
	 */
    public override void afterInsert(){
        hostInstitutionService.newHostInstitution(newRecords);
    }
}