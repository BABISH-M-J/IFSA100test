/**
 * Trigger Handler for Billing_Arrangement_Country__c, executes business logic in <<billingArrangementService>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/26/2021 Brock Barlow
public with sharing class billingArrangementCountryTriggerHandler extends BaseTriggerHandler
{
	final List<Billing_Arrangement_Country__c> newRecords;
	final List<Billing_Arrangement_Country__c> oldRecords;
	final Map<Id, Billing_Arrangement_Country__c> oldMap;
	final Map<Id, Billing_Arrangement_Country__c> newMap;
	/**
	 * Constructor, populates lists and maps from the Trigger object
	 */
	public billingArrangementCountryTriggerHandler()
	{
		this.newRecords = (List<Billing_Arrangement_Country__c>) Trigger.new;
		this.oldRecords = (List<Billing_Arrangement_Country__c>) Trigger.old;
		this.oldMap = (Map<Id, Billing_Arrangement_Country__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Billing_Arrangement_Country__c>) Trigger.newMap;
	}
	/** 
	 * Before Insert 
	 */
	public override void beforeInsert()
	{
		//Do something with billingArrangementService     
        billingArrangementService.createForCountries(newRecords);
	}
}