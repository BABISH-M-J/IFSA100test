/**
 * Trigger Handler for Course_Registration__c object
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class courseTriggerHandler extends BaseTriggerHandler 
{
	final List<Course__c> newRecords;
	final List<Course__c> oldRecords;
	final Map<Id, Course__c> oldMap;
	final Map<Id, Course__c> newMap;
	List<Trigger_Handler_Extension_Setting__mdt> extSettings;
    /**
	 * Constructor, populates lists and maps from the Trigger object
	 */
	public courseTriggerHandler()
	{
		this.newRecords = (List<Course__c>) Trigger.new;
		this.oldRecords = (List<Course__c>) Trigger.old;
		this.oldMap = (Map<Id, Course__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Course__c>) Trigger.newMap;
		extSettings = [SELECT DeveloperName, Extension_Class__c FROM Trigger_Handler_Extension_Setting__mdt WHERE SObject__c = 'Course__c'];
	}
    /**
     * Before Insert
     */
	public override void beforeInsert()
	{
        courseService.updateShortDescription(newRecords);
		courseService.unapproveExpiredCourses(newRecords);
		for(Trigger_Handler_Extension_Setting__mdt setting: extSettings)
		{
			Callable extension = (Callable) Type.forName(setting.Extension_Class__c).newInstance();
			Boolean result = (Boolean) extension.call('beforeInsert', new Map<String, Object> { 'newRecords' => newRecords });
		}
	}
    /**
     * Before Update
     */
    public override void beforeUpdate()
    {
        courseService.updateShortDescription(newRecords);
		courseService.unapproveExpiredCourses(newRecords);		
		for(Trigger_Handler_Extension_Setting__mdt setting: extSettings)
		{
			Callable extension = (Callable) Type.forName(setting.Extension_Class__c).newInstance();
			Boolean result = (Boolean) extension.call('beforeUpdate', new Map<String, Object> { 'newRecords' => newRecords, 'newMap' => newMap, 'oldRecords' => oldRecords, 'oldMap' => oldMap });
		}
    }
	/**
     * After Insert
     */
	public override void afterInsert()
    {
		for(Trigger_Handler_Extension_Setting__mdt setting: extSettings)
		{
			Callable extension = (Callable) Type.forName(setting.Extension_Class__c).newInstance();
			Boolean result = (Boolean) extension.call('afterInsert', new Map<String, Object> { 'newRecords' => newRecords, 'newMap' => newMap });
		}
	}
	/**
     * After Update
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