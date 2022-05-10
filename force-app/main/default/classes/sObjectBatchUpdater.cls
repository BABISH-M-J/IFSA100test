/**
 * @description Batchable class to update existing sObjects or insert new objects
 * @author Brock Barlow
 */
global class sObjectBatchUpdater implements Database.Batchable<sObject>,Database.Stateful {
	//Enum of possible DML operations
	global enum dmlTypes
	{
		dmlUpdate, dmlInsert, dmlDelete, dmlUpsert
	}
	//List of sObjects to Update
	List<SObject> sObjectsToUpdate;
	//DML Operation Type
	dmlTypes dType;
	//Record to report back to
	List<Id> relatedObjectIds;
	List<RecordWithError> recordsWithErrors = new List<RecordWithError>();
	//Constructor for class
	//Must pass a list of SObjects and a DML Type
	global sObjectBatchUpdater(List<SObject> objs, dmlTypes dt) {
		this.sObjectsToUpdate = objs;
		this.dType = dt;
		this.relatedObjectIds = new List<Id>();
	}
	global sObjectBatchUpdater(List<SObject> objs, dmlTypes dt, List<Id> related) {
		this(objs, dt);
		this.relatedObjectIds = related;
	}
	//This is run by the system scheduler to start the batch
	global List<SObject> start(Database.BatchableContext BC) {
		return this.sObjectsToUpdate;
	}
	//Runs with each batch
   	global void execute(Database.BatchableContext BC, List<SObject> scope) {
		if(this.dType == dmlTypes.dmlUpdate)
		{
			Database.SaveResult[] results = Database.update(scope, false);
			for (Integer i = 0; i < results.size() -1; i++) 
			{
				Database.SaveResult result = results.get(i);
				if(!result.isSuccess())
				{
					system.debug(LoggingLevel.ERROR, result.getErrors());
					system.debug(LoggingLevel.ERROR, scope.get(i));
					recordsWithErrors.add(new RecordWithError(result.getErrors().get(0), scope.get(i)));
				}
			}
		}
		else if(this.dType == dmlTypes.dmlInsert)
		{
			Database.SaveResult[] results = Database.insert(scope, false);
			for (Integer i = 0; i < results.size() -1; i++) 
			{
				Database.SaveResult result = results.get(i);
				if(!result.isSuccess())
				{
					system.debug(LoggingLevel.ERROR, result.getErrors());
					system.debug(LoggingLevel.ERROR, scope.get(i));
					recordsWithErrors.add(new RecordWithError(result.getErrors().get(0), scope.get(i)));
				}
			}
		}
		else if(this.dType == dmlTypes.dmlDelete)
		{
			Database.DeleteResult[] results = Database.delete(scope, false);
			for (Integer i = 0; i < results.size() -1; i++) 
			{
				Database.DeleteResult result = results.get(i);
				if(!result.isSuccess())
				{
					system.debug(LoggingLevel.ERROR, result.getErrors());
					system.debug(LoggingLevel.ERROR, scope.get(i));
					recordsWithErrors.add(new RecordWithError(result.getErrors().get(0), scope.get(i)));
				}
			}
		}
		else if(this.dType == dmlTypes.dmlUpsert)
		{
			Database.UpsertResult[] results = Database.upsert(scope, false);
			for (Integer i = 0; i < results.size() -1; i++) 
			{
				Database.UpsertResult result = results.get(i);
				if(!result.isSuccess())
				{
					system.debug(LoggingLevel.ERROR, result.getErrors());
					system.debug(LoggingLevel.ERROR, scope.get(i));
					recordsWithErrors.add(new RecordWithError(result.getErrors().get(0), scope.get(i)));
				}
			}
		}
	}
	//Runs after last batch completes. Can send and email or create a task
	global void finish(Database.BatchableContext BC) {
		// Can update parent objects if Ids are supplied
		if(!relatedObjectIds.isEmpty())		{
			List<SObject> objectsToUpdate = new List<SObject>();
			for(String recordId: this.relatedObjectIds)
			{
				// Updates Related_records_created__c on Application_Requirement__c
				if(recordId.substring(0, 3) == 'a0129')
				{
					Application_Requirement__c appReq = new Application_Requirement__c(Id = recordId, Related_records_created__c = true);
					objectsToUpdate.add(appReq);
				}
			}
			Id jobId = system.enqueueJob(new sObjectQueueableUpdater(objectsToUpdate));
		}
		if(!recordsWithErrors.isEmpty() && UserInfo.getUserType() == 'Standard')
		{
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.setToAddresses(new String[] {UserInfo.getUserEmail()});
			message.setSubject('An error occured during an asynchronous operation');
			String newLine = '<br />';
			String body = 'Hello ' + UserInfo.getFirstName() + ',' + newLine;
			body = body + newLine;
			body = body + 'An error occured during an asynchronous operation. The following record(s) did not save:' + newLine;
			body = body + '<table><tr><th>Record Id</th><th>Field(s)</th><th>Error Message</th><th>Status Code</th></tr>';
			for(RecordWithError rwe: recordsWithErrors)
			{
				body = body + '<tr><td>';
				if(rwe.record.Id != null)
				{
					body = body +  rwe.record.Id;
				}
				else
				{
					body = body + '-';
				}
				body = body + '</td><td>';
				if( !rwe.fields.isEmpty())
				{
					for(String field: rwe.fields)
					{
						body = body + field + ', ';
					}
				}
				else
				{
					body = body + '-';
				}
				body = body + '</td><td>';
				body = body + rwe.message + '</td><td>' + rwe.statuscode + '</td></tr>';
				body = body + '<tr><td colspan="4">' + JSON.serialize(rwe.record) + '</td></tr>';
			}
			body = body + '</table>' + newLine + newLine;
			body = body + 'Please contact IFSA IT Support if you have any questions.' + newLine;
			body = body + 'IFSA Salesforce Team';
			
			message.setHtmlBody(body);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		}
	}
	/**
	 * @description global method to update records in batch
	 * @param objectsToUpdate The list of SObjects to be updated
	 * @param batchSize The size of the batches to be run
	 */
	global static Id batchUpdate(List<SObject> objectsToUpdate, Integer batchSize)
	{		
		return batchUpdate(objectsToUpdate, batchSize, dmlTypes.dmlUpdate);
	}
	/**
	 * @description global method to insert, update, or delete records in batch
	 * @param objectsToUpdate The list of SObjects to be updated
	 * @param batchSize The size of the batches to be run
	 * @param dType the DML Operation to perform.
	 */
	global static Id batchUpdate(List<SObject> objectsToUpdate, Integer batchSize, dmlTypes dType)
	{		
		sObjectBatchUpdater updater = new sObjectBatchUpdater(objectsToUpdate, dType);
		Id batchId = Database.executeBatch(updater, batchSize);
		system.debug(batchId);
		return batchId;
	}
	/**
	 * @description global method to insert, update, or delete records in batch
	 * @param objectsToUpdate The list of SObjects to be updated
	 * @param batchSize The size of the batches to be run
	 * @param dType the DML Operation to perform.
	 * @param relatedObjectId A list of Ids that need updated once the batch operation is complete.
	 */
	global static Id batchUpdate(List<SObject> objectsToUpdate, Integer batchSize, dmlTypes dType, List<Id> relatedObjectId)
	{		
		sObjectBatchUpdater updater = new sObjectBatchUpdater(objectsToUpdate, dType, relatedObjectId);
		Id batchId = Database.executeBatch(updater, batchSize);
		system.debug(batchId);
		return batchId;
	}
	public with sharing class RecordWithError
	{
		List<String> fields {get;set;}
		String message {get;set;}
		String statuscode {get;set;}
		SObject record {get;set;}

		public RecordWithError(Database.Error em, SObject r)
		{
			
			fields = em.fields;
			message = em.message;
			statuscode = em.statuscode.name();
			record = r;
		}
	}
}