/**
 * Trigger Handler for Course_Registration__c object
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class courseRegistrationTriggerHandler extends BaseTriggerHandler
{
     
    
	final List<Course_Registration__c> newRecords;
	final List<Course_Registration__c> oldRecords;
	final Map<Id, Course_Registration__c> oldMap;
	final Map<Id, Course_Registration__c> newMap;
	List<Trigger_Handler_Extension_Setting__mdt> extSettings;

	// added by Powerfluence to avoid recursive calling - gradereport error - 001 - start
	//public static boolean firstRun = true;
	// added by Powerfluence to avoid recursive calling - gradereport error - 001 - end
	public static boolean beforeInsertFirstRun = true;
	public static boolean afterInsertFirstRun = true;
	public static boolean beforeUpdateFirstRun = true;
	public static boolean afterUpdateFirstRun = true;

    /**
	 * Constructor, populates lists and maps from the Trigger object
	 */
    
	public courseRegistrationTriggerHandler()
	{
		System.debug('--- courseRegistrationTriggerHandler Start ---');
		this.newRecords = (List<Course_Registration__c>) Trigger.new;
		this.oldRecords = (List<Course_Registration__c>) Trigger.old;
		this.oldMap = (Map<Id, Course_Registration__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Course_Registration__c>) Trigger.newMap;
		extSettings = [SELECT DeveloperName, Extension_Class__c FROM Trigger_Handler_Extension_Setting__mdt WHERE SObject__c = 'Course_Registration__c'];
          
            
	}
        
    
    /**
     * Before Insert
     */
     
	public override void beforeInsert()
	{
		if(beforeInsertFirstRun){
			System.debug('--- courseRegistrationTriggerHandler.beforeInsert Start ---');
			beforeInsertFirstRun = false;
			courseRegistrationService.courseRegistrationEntered(newRecords);
			//courseRegistrationService.gradeEnteredOrChanged(newMap, oldMap);
			courseRegistrationService.markOmitted(newRecords);
			for(Trigger_Handler_Extension_Setting__mdt setting: extSettings)
			{
				Callable extension = (Callable) Type.forName(setting.Extension_Class__c).newInstance();
				Boolean result = (Boolean) extension.call('beforeInsert', new Map<String, Object> { 'newRecords' => newRecords });
			}
		}
	}
    /**
     * Before Update
     */
    public override void beforeUpdate()
    {
		if(beforeUpdateFirstRun){	
			System.debug('--- courseRegistrationTriggerHandler.beforeUpdate Start ---');
			beforeUpdateFirstRun = false;
			courseRegistrationService.gradeConversion(newRecords);
			courseRegistrationService.gradeEnteredOrChanged(newMap, oldMap);
			courseRegistrationService.checkCourseforApprovalOrOmmision(newMap, oldMap);
			courseRegistrationService.markOmitted(newRecords);
			for(Trigger_Handler_Extension_Setting__mdt setting: extSettings)
			{
				Callable extension = (Callable) Type.forName(setting.Extension_Class__c).newInstance();
				Boolean result = (Boolean) extension.call('beforeUpdate', new Map<String, Object> { 'newRecords' => newRecords, 'newMap' => newMap, 'oldRecords' => oldRecords, 'oldMap' => oldMap });
			}
		}
    }
    /**
     * After Insert
     */
      
	public override void afterInsert()
    {
         
        if(afterInsertFirstRun){
			System.debug('--- courseRegistrationTriggerHandler.afterInsert Start ---');
			afterInsertFirstRun = false;
			courseRegistrationService.createNewCourseRecords(new List<Id>(newMap.keySet()));
			for(Trigger_Handler_Extension_Setting__mdt setting: extSettings)
			{
				Callable extension = (Callable) Type.forName(setting.Extension_Class__c).newInstance();
				system.debug('' + extension);
				Boolean result = (Boolean) extension.call('afterInsert', new Map<String, Object> { 'newRecords' => newRecords, 'newMap' => newMap });
			}
		}
	}
	/**
     * After Update
     */
	public override void afterUpdate()
	{
		if(afterUpdateFirstRun){
			System.debug('--- courseRegistrationTriggerHandler.afterUpdate Start ---');
			afterUpdateFirstRun = false;
			for(Trigger_Handler_Extension_Setting__mdt setting: extSettings)
			{
				Callable extension = (Callable) Type.forName(setting.Extension_Class__c).newInstance();
				Boolean result = (Boolean) extension.call('afterUpdate', new Map<String, Object> { 'newRecords' => newRecords, 'newMap' => newMap, 'oldRecords' => oldRecords, 'oldMap' => oldMap });
			}
		}
	}
}