/**
 * @description Trigger Handler for Program_Authorization__c
 * @author Brock Barlow
 */
public class programAuthorizationTriggerHandler extends BaseTriggerHandler
{
	final List<Program_Authorization__c> newRecords;
	final List<Program_Authorization__c> oldRecords;
	final Map<Id, Program_Authorization__c> oldMap;
	final Map<Id, Program_Authorization__c> newMap;
	public static Map<Id, Program_Authorization__c> newProgramAuthorizations {get;set;}
	public static List<Program_Authorization__c> recordsToDelete {get;set;}

	public programAuthorizationTriggerHandler()
	{
		this.newRecords = (List<Program_Authorization__c>) Trigger.new;
		this.oldRecords = (List<Program_Authorization__c>) Trigger.old;
		this.oldMap = (Map<Id, Program_Authorization__c>) Trigger.oldMap;
		this.newMap = (Map<Id, Program_Authorization__c>) Trigger.newMap;
		if(programAuthorizationTriggerHandler.newProgramAuthorizations == null)
		{
			programAuthorizationTriggerHandler.newProgramAuthorizations = new Map<Id, Program_Authorization__c>();
		}
		if(programAuthorizationTriggerHandler.recordsToDelete == null)
		{
			programAuthorizationTriggerHandler.recordsToDelete = new List<Program_Authorization__c>();
		}
	}

	public override void beforeInsert()
	{
		System.debug('Program Authorization Before Insert Start');
		//Do something with programAuthorizationService     
        try
		{
			programAuthorizationService.beforeInsertProgramAuthorizations(newRecords);
		}
		catch(programAuthorizationService.programAuthorizationServiceException e)
		{
			System.debug('Exception caught in trigger handler');
			System.debug(e.getMessage());
			throw e;
		}
		
		System.debug('Program Authorization Before Insert End');
	}

    public override void beforeUpdate()
    {
		System.debug('Program Authorization Before Update Start');
        //Do something with programAuthorizationService
        //programAuthorizationService.updateProgramAuthorization(newMap, oldMap);
		programAuthorizationService.updateProgramAuthorizationsBefore(newMap, oldMap);
        System.debug(programAuthorizationTriggerHandler.newProgramAuthorizations);
		System.debug('Program Authorization Before Update End');
    }

	public override void afterInsert()
    {
        //Do something with programAuthorizationService
        
    }

    public override void afterUpdate()
    {
		System.debug('Program Authorization After Update Start');
        //Do something with programAuthorizationService
		programAuthorizationService.updateProgramAuthorizationsAfter(newMap, oldMap, programAuthorizationTriggerHandler.newProgramAuthorizations);
		programAuthorizationService.createProgramAuthorizationUpdatedTask(newRecords);
        programAuthorizationService.updateAccountApproved(newMap);

		if(!programAuthorizationTriggerHandler.recordsToDelete.isEmpty())
		{
			System.debug(LoggingLevel.INFO, 'jobs enqueued: ' + Limits.getQueueableJobs());
        	System.debug(LoggingLevel.INFO, 'Remaining queueable jobs: ' + Limits.getLimitQueueableJobs());
			//system.enqueueJob(new sObjectQueueableUpdater(programAuthorizationTriggerHandler.recordsToDelete, sObjectQueueableUpdater.dmlOperation.isDelete));
			database.delete(programAuthorizationTriggerHandler.recordsToDelete);
			programAuthorizationTriggerHandler.recordsToDelete.clear();
		}
		System.debug('Program Authorization After Update End');
    }
}