/**
 * Trigger Handler for Case, executes business logic in <<caseService>>. This trigger handler is an instance that does contain some more logic that most trigger handlers 
 * in the system, but the bulk of the processing happens in other classes. This trigger handler dynamically apex classes that implement Saleforce's Callable Interface and IFSA's <<TriggerHandlerExtendable>> Interfaces like <<HealthSafety_CaseTriggerHandlerExtension>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public without sharing class caseTriggerHandler extends BaseTriggerHandler 
{
	final List<Case> newRecords;
	final List<Case> oldRecords;
	final Map<Id, Case> oldMap;
	final Map<Id, Case> newMap;
	final List<Case> newRecordsLegacyIncidents;
	final List<Case> oldRecordsLegacyIncidents;
	final Map<Id, Case> oldMapLegacyIncidents;
	final Map<Id, Case> newMapLegacyIncidents;
	final List<Case> newRecordsIncidents;
	final List<Case> oldRecordsIncidents;
	final Map<Id, Case> oldMapIncidents;
	final Map<Id, Case> newMapIncidents;
	List<Trigger_Handler_Extension_Setting__mdt> extSettings;
	/**
	 * Constructor, populates lists and maps from the Trigger object
	 */
	public caseTriggerHandler()
	{
		this.newRecords = (List<Case>) Trigger.new;
		this.oldRecords = (List<Case>) Trigger.old;
		this.oldMap = (Map<Id, Case>) Trigger.oldMap;
		this.newMap = (Map<Id, Case>) Trigger.newMap;
		extSettings = [SELECT DeveloperName, Extension_Class__c FROM Trigger_Handler_Extension_Setting__mdt WHERE SObject__c = 'Case'];
	}
	/**
	 * Before Insert Runs methods that are hardcoded into this class before running Before Insert methods on trigger handler extentions
	 */
	public override void beforeInsert()
	{	
		caseService.setEmailToCaseUser(newRecords);
		for(Trigger_Handler_Extension_Setting__mdt setting: extSettings)
		{
			Callable extension = (Callable) Type.forName(setting.Extension_Class__c).newInstance();
			Boolean result = (Boolean) extension.call('beforeInsert', new Map<String, Object> { 'newRecords' => newRecords });
		}
	}
	/**
	 * Before Update Runs methods that are hardcoded into this class before running Before Update methods on trigger handler extentions
	 */
    public override void beforeUpdate()
    {
        for(Trigger_Handler_Extension_Setting__mdt setting: extSettings)
		{
			Callable extension = (Callable) Type.forName(setting.Extension_Class__c).newInstance();
			Boolean result = (Boolean) extension.call('beforeUpdate', new Map<String, Object> { 'newRecords' => newRecords, 'newMap' => newMap, 'oldRecords' => oldRecords, 'oldMap' => oldMap });
		}
    }
	/**
	 * After Insert Runs methods that are hardcoded into this class before running After Insert methods on trigger handler extentions
	 */
	public override void afterInsert()
    {
		caseService.useAssignmentRule(newMap.keySet());
		for(Trigger_Handler_Extension_Setting__mdt setting: extSettings)
		{
			Callable extension = (Callable) Type.forName(setting.Extension_Class__c).newInstance();
			Boolean result = (Boolean) extension.call('afterInsert', new Map<String, Object> { 'newRecords' => newRecords, 'newMap' => newMap });
		}
    }
	/**
	 * After Update Runs methods that are hardcoded into this class before running After Update methods on trigger handler extentions
	 */
    public override void afterUpdate()
    {
		for(Trigger_Handler_Extension_Setting__mdt setting: extSettings)
		{
			Callable extension = (Callable) Type.forName(setting.Extension_Class__c).newInstance();
			Boolean result = (Boolean) extension.call('afterUpdate', new Map<String, Object> { 'newRecords' => newRecords, 'newMap' => newMap, 'oldRecords' => oldRecords, 'oldMap' => oldMap });
		}
    }
}