/**
 * TriggerHandler for Locality__c
 * @see <<localityService>>, <<BaseTriggerHandler>>
 * @author Brock Barlow
 */
// ApexDoc updated 2/19/2021 Brock Barlow
public without sharing class localityTriggerHandler extends BaseTriggerHandler
{
    final List<Locality__c> newRecords;
    final List<Locality__c> oldRecords;
    final Map<Id, Locality__c> oldMap;
    final Map<Id, Locality__c> newMap;
    /**
	 * Constructor, populates lists and maps from the Trigger object
	 */
    public localityTriggerHandler() {
        this.newRecords = (List<Locality__c>) Trigger.new;
        this.oldRecords = (List<Locality__c>) Trigger.old;
        this.oldMap = (Map<Id, Locality__c>) Trigger.oldMap;
        this.newMap = (Map<Id, Locality__c>) Trigger.newMap;
    }
    /**
	 * After Insert
	 */
    public override void afterInsert(){
        localityService.newLocality(newRecords);
    }
}