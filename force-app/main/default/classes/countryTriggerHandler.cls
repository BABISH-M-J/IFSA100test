/**
 * Trigger Handler for Country__c object
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class countryTriggerHandler extends BaseTriggerHandler
{
    final List<Country__c> newRecords;
    final List<Country__c> oldRecords;
    final Map<Id, Country__c> oldMap;
    final Map<Id, Country__c> newMap;
    /**
	 * Constructor, populates lists and maps from the Trigger object
	 */
    public countryTriggerHandler() {
        this.newRecords = (List<Country__c>) Trigger.new;
        this.oldRecords = (List<Country__c>) Trigger.old;
        this.oldMap = (Map<Id, Country__c>) Trigger.oldMap;
        this.newMap = (Map<Id, Country__c>) Trigger.newMap;
    }
    /**
     * After Insert
     */
    public override void afterInsert(){
        countryService.newCountry(newRecords);
    }
}