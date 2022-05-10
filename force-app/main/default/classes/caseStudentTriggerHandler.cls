/**
 * Trigger Handler for Case_Program__c object
 * @author Brock barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public with sharing class caseStudentTriggerHandler extends BaseTriggerHandler
{
    final List<Case_Student__c> newRecords;
	final List<Case_Student__c> oldRecords;
	final Map<Id, Case_Student__c> oldMap;
	final Map<Id, Case_Student__c> newMap;

    /**
	 * Constructor, populates lists and maps from the Trigger object
	 */    
    public caseStudentTriggerHandler()
	{
		this.newRecords = (List<Case_Student__c>) Trigger.new;
		this.oldRecords = (List<Case_Student__c>) Trigger.old;
		this.oldMap = (Map<Id, Case_Student__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Case_Student__c>) Trigger.newMap;
	}
    /**
     * Before Insert
     */
	public override void beforeInsert()
	{
        caseService.setReasonAffected(newRecords);     
	}
    /**
     * After Delete
     */
	public override void afterInsert()
    {
        caseService.generateCaseTeam(newRecords);
    }
}