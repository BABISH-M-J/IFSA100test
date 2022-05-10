/**
 * Trigger Handler for Billing_Arrangement__c, executes business logic in <<billingArrangementService>>. This trigger handler is an instance that does contain some more logic that most trigger handlers 
 * in the system, but the bulk of the processing happens in other classes
 * @author Brock Barlow
 */
// ApexDoc updated 1/26/2021 Brock Barlow
public class billingArrangementTriggerHandler extends BaseTriggerHandler
{
	final List<Billing_Arrangement__c> newRecords;
	final List<Billing_Arrangement__c> oldRecords;
	final Map<Id, Billing_Arrangement__c> oldMap;
	final Map<Id, Billing_Arrangement__c> newMap;
	public static Map<Id, Billing_Arrangement__c> newBillingArrangements {get;set;}
	public static List<Billing_Arrangement__c> recordsToDelete {get;set;}

	/**
	 * Constructor, populates lists and maps from the Trigger object
	 */
	public billingArrangementTriggerHandler()
	{
		this.newRecords = (List<Billing_Arrangement__c>) Trigger.new;
		this.oldRecords = (List<Billing_Arrangement__c>) Trigger.old;
		this.oldMap = (Map<Id, Billing_Arrangement__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Billing_Arrangement__c>) Trigger.newMap;

		if(billingArrangementTriggerHandler.newBillingArrangements == null)
		{
			billingArrangementTriggerHandler.newBillingArrangements = new Map<Id, Billing_Arrangement__c>();
		}
		if(billingArrangementTriggerHandler.recordsToDelete == null)
		{
			billingArrangementTriggerHandler.recordsToDelete = new List<Billing_Arrangement__c>();
		}
	}
	/**
	 * Before Insert
	 */
	public override void beforeInsert()
	{
		//This was not desired functionality and is currently disabled.
		//billingArrangementService.setDiscountRecipient(newRecords);
        billingArrangementService.checkCustomProgram(newRecords);
	}
	/**
	 * Before Update
	 */
    public override void beforeUpdate()
    {
        billingArrangementService.checkCustomProgram(newRecords);
		billingArrangementService.updateBillingArrangementBefore(newMap, oldMap);
    }
	/**
	 * After Update
	 */
    public override void afterUpdate()
    {
        billingArrangementService.updateBillingArrangementAfter(newMap, oldMap, billingArrangementTriggerHandler.newBillingArrangements);

		if(programAuthorizationTriggerHandler.recordsToDelete != null && !programAuthorizationTriggerHandler.recordsToDelete.isEmpty())
		{
			system.enqueueJob(new sObjectQueueableUpdater(billingArrangementTriggerHandler.recordsToDelete, sObjectQueueableUpdater.dmlOperation.isDelete));
			billingArrangementTriggerHandler.recordsToDelete.clear();
		}
    }
}