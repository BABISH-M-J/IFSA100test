/**
 * Application Item Service Class, This contains the business logic for <<applicationItemTriggerHandler>> and applicationItemTrigger
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public without sharing class applicationItemService
{
	/**
	* An enumeration to tell service methods if a dml action Is an Insert, Update, Delete.
	*/
	public Enum triggerType
	{
		isInsert, isUpdate, isDelete, isBefore, isAfter
	}

	/**
	 * Method to update the completed by And completed date fields of application item records
	 * Method runs before update of Application_Item__c
	 * @param newMap The values after the records where modified
	 * @param oldMap The values before the records where modified
	 */
	public static void setCompletedAppItem (Map<Id, Application_Item__c> newMap, Map<Id, Application_Item__c> oldMap)
	{
		Id signatureRecordTypeId = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Signature').getRecordTypeId();
		Map<Id, Application__c> appsToUpdate = new Map<Id, Application__c> ();
		for(Application_Item__c ai: newMap.values())
		{
			appsToUpdate.put(ai.Application__c, null);
		}
		// App Item Types that can be ignored when moving an application to "Ready To Submit"
		List<String> allowedAppItemTypes = new List<String>{'Program Approval', 'Advising Call','Passport Copy'};
        appsToUpdate = new Map<Id, Application__c>([SELECT Id, Status__c, Status_Contract_Signed__c, (SELECT Id, Name FROM Application_Items__r WHERE Status__c != 'Complete' AND Phase__c = 'Pre-Admit' AND (NOT Name IN: allowedAppItemTypes) AND (NOT Id IN: newMap.keySet())) FROM Application__c WHERE Id IN: appsToUpdate.keySet()]);
		for (Application_Item__c ai : newMap.values()) 
		{
			Application__c app = appsToUpdate.get(ai.Application__c);
			if(ai.Status__c == 'Complete' && oldMap.get(ai.Id).Status__c != ai.Status__c)
			{
				ai.Completed_By_User__c = UserInfo.getUserId();
				ai.Completed_Date__c = Datetime.now();
				
				if(ai.RecordTypeId == signatureRecordTypeId && ai.Name.contains('Acceptance Agreement'))
				{
					appsToUpdate.get(ai.Application__c).Status_Contract_Signed__c = Datetime.now();
					appsToUpdate.get(ai.Application__c).Printable_Statement__c = true;
				}
				else if(ai.Phase__c == 'Pre-Admit' && app != null && app.Status__c == 'Program Selected')
				{
					if(app.Application_Items__r.isEmpty())
					{
						appsToUpdate.get(ai.Application__c).Status__c = 'Ready To Submit';
					}
				}
				else
				{
					if(appsToUpdate.containsKey(ai.Application__c))
					{
						appsToUpdate.remove(ai.Application__c);
					}
				}
			}
			else
			{
				if(appsToUpdate.containsKey(ai.Application__c))
				{
					appsToUpdate.remove(ai.Application__c);
				}
			}
		}
		if(!appsToUpdate.isEmpty())
		{
			sObjectBatchUpdater.batchUpdate(appsToUpdate.values(), 200);
		}
	}

	/**
	 * Method to fill FastForms URL field for application items that use FastForms
	 * Method runs after update of Application_Item__c
	 * @param newMap The values after the records where modified
	 */
	public static void fastFormsPrefill(Map<Id, Application_Item__c> newMap)
	{
		if(Limits.getLimitQueueableJobs() < 2)
		{
			return;
		}
		List<Application_Item__c> newRecords = [SELECT Id, Form_Template_ID__c FROM Application_Item__c WHERE Id IN: newMap.keySet()];
		Map<Id, List<String>> ids = new Map<Id, List<String>>();
		List<Id> appItemIds = new List<Id>();
 		for (Application_Item__c e  : newRecords)
 		{
			if(e.Form_Template_ID__c != null)
			{
				if(!ids.containsKey(e.Form_Template_ID__c))
				{
					ids.put(e.Form_Template_ID__c, new List<String>());
				}
				ids.get(e.Form_Template_ID__c).add(e.Id);
				appItemIds.add(e.Id);
			}		
		}

		Id jobId = System.enqueueJob(new fastFormQueueable(ids));
		System.debug(LoggingLevel.INFO, jobId);
	}
	/**
	 * A class that implements the Queueable interface to update Application_Item__c records with the correct FormStack (FastForm) template id.
	 */
	public class fastFormQueueable implements Queueable
	{
		Map<Id, List<String>> ids {get;set;}

		/**
		 * Constructor, provides Map<Id, List<String>> parameter
		 * @param itemIds A map that links a form template with Application_Item__c records
		 */
		public fastFormQueueable(Map<Id, List<String>> itemIds)
		{
			this.ids = itemIds;
		}
		/**
		 * Executes Visualantidote.FastFormsUtilities.UpdateRecordsWithURL for each form template id. This method is required in implementation of Queueable
		 */
		public void execute(QueueableContext context) 
		{
			for(Id formId: ids.keySet())
			{
				//visualantidote.FastFormsUtilities.UpdateRecordsWithURL ( 'Object Being Updated' ,  'Field to Update' ,  'FastForms Form Id' ,  Application Items to Update );
				Visualantidote.FastFormsUtilities.UpdateRecordsWithURL( 'Application_item__c',  'Fast_Forms_URL__c',  formId, ids.get(formId));
			}
		}
	}

	/**
	 * Method to generate task for PA when app item offer reply or App Item marked for notification is complete
	 * @param newMap The values after the records where modified
	 * @param oldMap The values before the records where modified
	*/
	public static void createFollowUpTask(Map<Id, Application_Item__c> newMap, Map<Id, Application_Item__c> oldMap)
	{
		Map<Id,Task> appTaskMap = new Map<Id, Task>();
		Id downloadUploadRT = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Download-Upload').getRecordTypeId();

		for(Application_Item__c appItem : newMap.values())
		{
			if(appItem.Status__c == 'Complete' && oldMap.get(appItem.Id).Status__c != 'Complete' && appItem.Name.contains('Offer Reply'))
			{
				appTaskMap.put(appItem.Application__c, new Task(Subject='Send Offer Reply', WhatId=appItem.Id, Status='Not Started', ActivityDate=System.Today()+1));
			}

			else if(appItem.Status__c == 'Complete' && oldMap.get(appItem.Id).Status__c != 'Complete' && appItem.Receive_Task_When_Completed__c){
				appTaskMap.put(appItem.Application__c, new Task(Subject= appItem.Name + ' App Item Completed', WhatId=appItem.Id, Status='Not Started', ActivityDate=System.Today()+1));
			}
		}

		//added null check
		if(!appTaskMap.keySet().isEmpty())
		{
			for(Application__c app : [SELECT Id, Name, Applicant__c, OwnerId FROM Application__c WHERE Id IN :appTaskMap.keySet()])
			{
				appTaskMap.get(app.Id).OwnerId = app.OwnerId;
				appTaskMap.get(app.Id).WhoId = app.Applicant__c;
			}

			if(!appTaskMap.values().isEmpty())
			{
				insert appTaskMap.values();
			}
		}
	}
	
}