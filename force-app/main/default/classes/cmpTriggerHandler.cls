/**
 * Trigger Handler for CMP__c object
 * @author Matt Eck
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public with sharing class cmpTriggerHandler extends BaseTriggerHandler{

    final List<CMP__c> newRecords;
	final List<CMP__c> oldRecords;
	final Map<Id, CMP__c> oldMap;
	final Map<Id, CMP__c> newMap;
    /**
	 * Constructor, populates lists and maps from the Trigger object
	 */
    public cmpTriggerHandler() {
        this.newRecords = (List<CMP__c>) Trigger.new;
		this.oldRecords = (List<CMP__c>) Trigger.old;
		this.oldMap = (Map<Id, CMP__c>) Trigger.oldMap;
		this.newMap = (Map<Id, CMP__c>) Trigger.newMap;
    }
    /**
     * Before Insert
     */
    public override void beforeInsert(){
        cmpService.setRecordName(newRecords);
        cmpService.checkForImagesInEmail(newRecords);
    }
    /**
     * Before Update
     */
    public override void beforeUpdate(){
        cmpService.setCompletedDate(oldMap, newMap);
        cmpService.checkForImagesInEmail(newRecords);
    }
    /**
     * After Update
     */
    public override void afterUpdate(){
        cmpService.sendCMPCompleteEmail(oldMap, newMap);
    }
}