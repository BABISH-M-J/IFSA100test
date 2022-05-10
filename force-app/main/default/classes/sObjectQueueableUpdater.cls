/**
* @description Queueable class to update sObjects
* @author Brock Barlow
*/
public without sharing class sObjectQueueableUpdater implements Queueable {
	public enum dmlOperation {
		isInsert,isUpdate,isDelete,isUpsert
	}
	private List<SObject> sObjs;
	private Integer limitSize {get;set;}
	private Id oldProgramTermId {get;set;}
	private dmlOperation dtype {get;set;}
	private Boolean isBatch {get; set;}
	private Boolean sendEmail {get;set;}
	private Map<Id, Application_Requirement__c> appReqMap {get;set;}
	private List<String> triggers;
	/**
	* @description Constructor with list of SObjects to update
	* @param List<SObject> recordsToUpdate - records to update
	*/
	public sObjectQueueableUpdater(List<SObject> recordsToUpdate)
	{
		this.sObjs = recordsToUpdate;
		this.limitSize = null;
		this.oldProgramTermId = null;
		this.dtype = null;
		this.isBatch = false;
		this.sendEmail = false;
		this.triggers = new List<String>();
	}
	public sObjectQueueableUpdater(List<SObject> recordsToUpdate, dmlOperation dmlType)
	{
		this(recordsToUpdate);
		this.dtype = dmlType;
	}
	public sObjectQueueableUpdater(List<SObject> recordsToUpdate, dmlOperation dmlType, Map<Id, Application_Requirement__c> appReqMap)
	{
		this(recordsToUpdate);
		this.dtype = dmlType;
		this.appReqMap = appReqMap;
	}
	public sObjectQueueableUpdater(List<SObject> recordsToUpdate, dmlOperation dmlType, List<String> trigs)
	{
		this(recordsToUpdate);
		this.dtype = dmlType;
		this.triggers = trigs;
	}
	public sObjectQueueableUpdater(List<SObject> recordsToUpdate, Boolean hasEmail)
	{
		this(recordsToUpdate);
		this.dtype = dmlOperation.isInsert;
		this.sendEmail = hasEmail;
	}

	/**
	* @description Constructor with list of SObjects to update
	* @param List<SObject> recordsToUpdate - records to update
	* @param Integer lSize - number of program terms left to run
	* @param Id oldPTId - the Id of the program term that just ran. We need to pass it back 
	*	to programOptionConverterUtility so that we do not try to run the process again on any
	*	program options that have oldPTId as it's program term
	*/
	public sObjectQueueableUpdater(List<SObject> recordsToUpdate, Integer lSize, Id oldPTId)
	{
		this(recordsToUpdate);
		this.limitSize = lSize;
		this.oldProgramTermId = oldPTId;
	}

	public sObjectQueueableUpdater(List<SObject> recordsToUpdate, dmlOperation dmlType, Integer batchSize)
	{
		this(recordsToUpdate, dmlType);
		this.limitSize = batchSize;
		this.isBatch = true;
	}
	/**
	* @description Execute method of Queueable class - updates the records.
	*	if limitSize and oldProgramTerm are NOT null queue another programOptionConverterUtility
	* @param QueueableContext context
	*/
	public void execute(QueueableContext context) {
		system.debug(this.sObjs);
		if(this.dtype == dmlOperation.isInsert)
			executeInsert();
		else if(this.dtype == dmlOperation.isUpdate || this.dtype == null)
			executeUpdate();
		else if(this.dtype == dmlOperation.isDelete)
			executeDelete();
		else if(this.dtype == dmlOperation.isUpsert)
			executeUpsert();
	}

	private void executeUpdate()
	{
		// Updates the records
		if(!isBatch)
		{
			Database.update(this.sObjs);
		}
		else
		{
			sObjectBatchUpdater.batchUpdate(this.sObjs, this.limitSize, sObjectBatchUpdater.dmlTypes.dmlUpdate);
		}
	}
	private void executeInsert()
	{
		// Inserts the records
		if(!isBatch)
		{
			if(!triggers.isEmpty()){
				for (String s : triggers) {
					system.debug('trigger is ' + s);
					BaseTriggerHandler.bypass(s);
				}
			}
			Database.insert(this.sObjs);

			if(appReqMap != null){
				Map<Id, Dynamic_Form__c> formMap = new Map<Id, Dynamic_Form__c>();
				List<Dynamic_Form__c> forms = new List<Dynamic_Form__C>();
				
				forms = [SELECT Id,
						 Name, 
						 JSON__c,
						 Number_of_Required_Elements__c,
						 Program_Term__c,
						 RecordTypeId,
						 Status__c
						 FROM Dynamic_Form__c
						 WHERE ID IN (SELECT Dynamic_Form__c FROM Application_Requirement__c WHERE Id IN :appReqMap.KeySet())];

				if(!forms.isEmpty()){
					for(Dynamic_form__c form : forms){
						for(Id oldReq : appReqMap.KeySet()){
							if(appReqMap.get(oldReq).Dynamic_Form__c == form.Id){
								formBuilderComponentController.Form formWrap = formBuilderComponentController.cloneHelper(form.JSON__c, appReqMap.get(oldReq).Id);
								String json = JSON.serialize(formWrap, true);
								form.JSON__c = json;
								form.Program_Term__c = formWrap.progTermName;
								form.Status__c = 'Draft';

								formMap.put(appReqMap.get(oldReq).Dynamic_Form__c, form);
							}
						}
						form.Id = null;
					}
					Database.insert(forms);

					for(Application_Requirement__c newAppReq : appReqMap.values()){
						if(formMap.containsKey(newAppReq.Dynamic_Form__c)){
							newAppReq.Dynamic_Form__c = formMap.get(newAppReq.Dynamic_Form__c).Id;
						}
					}

					Database.update(appReqMap.values());
				}
			}
		}
		else
		{
			sObjectBatchUpdater.batchUpdate(this.sObjs, this.limitSize, sObjectBatchUpdater.dmlTypes.dmlInsert);
		}
		if(this.sendEmail)
		{
			// Send Email
			sendEmail((ContentVersion) this.sObjs.get(0));
		}
	}
	private void executeUpsert()
	{
		//Upserts the records
		if(!isBatch)
		{
			Database.upsert(this.sObjs);
		}
		else
		{
			sObjectBatchUpdater.batchUpdate(this.sObjs, this.limitSize, sObjectBatchUpdater.dmlTypes.dmlUpsert);
		}
	}
	private void executeDelete()
	{
		//throw new sObjectQueueableUpdaterException('Not Implemented');
		if(!isBatch)
		{
			try 
			{
				Database.delete(this.sObjs);	
			}
			catch (DmlException e) 
			{
				System.debug(logginglevel.INFO, e.getMessage());
			}
			
		}
		else
		{
			sObjectBatchUpdater.batchUpdate(this.sObjs, this.limitSize, sObjectBatchUpdater.dmlTypes.dmlDelete);
		}
	}
	private void sendEmail(ContentVersion cv)
	{
		String fileURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + cv.Id;
		String body = '<p>Your file has been completed.</p>';
		body = body + '<p><a href="'+ fileURL  +'">Download File</a></p>';
		body = body + '<p><strong>Salesforce Team</strong></p>';


		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		
		message.setReplyTo('no-reply@ifsa-butler.org');
		message.setSenderDisplayName('IFSA-Butler No Reply');
		message.setToAddresses(new List<Id>{UserInfo.getUserId()});
		message.setSubject(cv.Title + ' has been created!');
		message.setHtmlBody('Hi ' + UserInfo.getFirstname() + ',<br/>');
		message.setHtmlBody(body);

		Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
	}
	public class sObjectQueueableUpdaterException extends Exception {}
}