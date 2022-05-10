/**
 * Trigger Handler for Flight__c SObject
 * @author Brock Barlow
 */
// ApexDoc updated 2/8/2021 Brock Barlow
public without sharing class flightTriggerHandler extends BaseTriggerHandler
{		
	final List<Flight__c> newRecords;
	final List<Flight__c> oldRecords;
	final Map<Id, Flight__c> oldMap;
	final Map<Id, Flight__c> newMap;
	/**
	 * Constructor, populates lists and maps from the Trigger object
	 */
	public flightTriggerHandler()
	{
		this.newRecords = (List<Flight__c>) Trigger.new;
		this.oldRecords = (List<Flight__c>) Trigger.old;
		this.oldMap = (Map<Id, Flight__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Flight__c>) Trigger.newMap;
	}
	/**
     * Before Delete
     */
    public override void beforeDelete()
    {
    	flightAndTravelService.getFirstDepartureAndLastArrival(newRecords, oldRecords, Trigger.operationType);
    }
	/**
     * After Insert
     */
	public override void afterInsert()
    {
       	flightAndTravelService.getFirstDepartureAndLastArrival(newRecords, oldRecords, Trigger.operationType);
    }
	/**
     * After Update
     */
    public override void afterUpdate()
    {
        flightAndTravelService.getFirstDepartureAndLastArrival(newRecords, oldRecords, Trigger.operationType);
    }
}