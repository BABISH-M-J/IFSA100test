/**
 * @description Trigger Handler for Program__c.
 * @author Brock Barlow
 */
public with sharing class programTriggerHandler extends BaseTriggerHandler
{
	final List<Program__c> newRecords;
	final List<Program__c> oldRecords;
	final Map<Id, Program__c> oldMap;
	final Map<Id, Program__c> newMap;

	public programTriggerHandler()
	{
		this.newRecords = (List<Program__c>) Trigger.new;
		this.oldRecords = (List<Program__c>) Trigger.old;
		this.oldMap = (Map<Id, Program__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Program__c>) Trigger.newMap;
	}

	public override void beforeInsert()
	{
		//Do something with programService
		
	}

    public override void beforeUpdate()
    {
        //Do something with programService

    }

	public override void afterInsert()
    {
        //Do something with programService
		programService.createProgramInsitutionRecords(newRecords);
		programService.createPAandBARecords(newMap);
		programService.newProgram(newRecords);
    }

    public override void afterUpdate()
    {
        //Do something with programService
		programService.renameProgramTermsApplications(newMap, oldMap);
    }
}