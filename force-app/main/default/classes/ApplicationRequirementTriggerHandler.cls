/**
 * @description Trigger Handler for Application Requirement
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public with sharing class ApplicationRequirementTriggerHandler  extends BaseTriggerHandler 
{
	final List<Application_Requirement__c> newRecords;
	final List<Application_Requirement__c> oldRecords;
	final Map<Id, Application_Requirement__c> oldMap;
	final Map<Id, Application_Requirement__c> newMap;

	/**
	 * Constructor, populates lists and maps from the Trigger object
	 */
	public ApplicationRequirementTriggerHandler()
	{	
		this.newRecords = (List<Application_Requirement__c>) Trigger.new;
		this.oldRecords = (List<Application_Requirement__c>) Trigger.old;
		this.oldMap = (Map<Id, Application_Requirement__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Application_Requirement__c>) Trigger.newMap;
	}
	/**
	 * Before Insert
	 */
	public override void beforeInsert()
	{
		System.debug('Application Requirement beforeInsert trigger running.');
        applicationRequirementService.setRelatedCreatedComplete(newRecords);
	}
	/**
	 * Before Update
	 */
    public override void beforeUpdate()
    {

    }
	/** 
	 * After Insert
	 */
	public override void afterInsert()
    {
        System.debug('Application Requirement afterInsert trigger running.');
		applicationRequirementService.createdRelatedApplicationItems(newMap);
    }
	/**
	 * After Update
	 */
    public override void afterUpdate()
    {
		System.debug('Application Requirement afterUpdate trigger running.');
    	applicationRequirementService.updateRelatedApplicationItems(newMap);
	}
	/**
	 * After Delete
	 */
    public override void afterDelete()
    {
    
    }
}