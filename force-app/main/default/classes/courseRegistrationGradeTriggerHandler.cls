/**
 * Trigger Handler for Course_Registration_Grade__c object
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class courseRegistrationGradeTriggerHandler extends BaseTriggerHandler
{
	final List<Course_Registration_Grade__c> newRecords;
	final List<Course_Registration_Grade__c> oldRecords;
	final Map<Id, Course_Registration_Grade__c> oldMap;
	final Map<Id, Course_Registration_Grade__c> newMap;
    /**
	 * Constructor, populates lists and maps from the Trigger object
	 */
	public courseRegistrationGradeTriggerHandler()
	{
		this.newRecords = (List<Course_Registration_Grade__c>) Trigger.new;
		this.oldRecords = (List<Course_Registration_Grade__c>) Trigger.old;
		this.oldMap = (Map<Id, Course_Registration_Grade__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Course_Registration_Grade__c>) Trigger.newMap;
	}
    /**
     * After Insert
     */
	public override void afterInsert()
    {
        courseRegistrationService.courseGradeCreated(newRecords);
    }
}