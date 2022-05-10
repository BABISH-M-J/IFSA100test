/**
 * Application Requirement Service. Business logic executed by <<ApplicationRequirementTriggerHandler>> and ApplicationRequirementTrigger
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public with sharing class ApplicationRequirementService {
    /**
     * DML operations
     */
	public enum triggerType
	{
		isInsert,isUpdate,isDelete
	}

    /**
     * Used when creating new application requirement and knowing that the related application item records have been created in the batch process
	 * @param newRecords List of records from Trigger.new
     */
	public static void setRelatedCreatedComplete(List<Application_Requirement__c> newRecords)
	{
		Map<Application_Requirement__c, Integer> ptReqs = new Map<Application_Requirement__c, Integer>();
		Map<Application_Requirement__c, Integer> poReqs = new Map<Application_Requirement__c, Integer>();
		for(Application_Requirement__c req: newRecords)
		{
			if(req.Program_Term__c != null)
			{
				if(!ptReqs.containsKey(req))
					{
						ptReqs.put(req, 0);
					}
				ptReqs.put(req, ptReqs.get(req)+1);
			}
			else
			{
				if(!poReqs.containsKey(req))
					{
						poReqs.put(req, 0);
					}
				poReqs.put(req, poReqs.get(req)+1);
			}
		}
		newRecords = new List<Application_Requirement__c>();
		for(Application_Requirement__c req: ptReqs.keySet())
		{
			if(ptReqs.get(req) < 76)
			{
				req.Related_records_created__c = true;
				newRecords.add(req);
			}
		}
		for(Application_Requirement__c req: poReqs.keySet())
		{
			if(poReqs.get(req) < 76)
			{
				req.Related_records_created__c = true;
				newRecords.add(req);
			}
		}
		
	}
    /**
     * Creates application items for existing applications of a program term or program option when a new application requirement is created
	 * @param newMap Map from Trigger.newMap
     */
	public static void createdRelatedApplicationItems(Map<Id, Application_Requirement__c> newMap)
	{
		Map<Application_Requirement__c, Id> idPTMap = new Map<Application_Requirement__c, Id>();
        Map<Application_Requirement__c, Id> idPOMap = new Map<Application_Requirement__c, Id>();
        Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>();    
        for(Application_Requirement__c appReq : newMap.values())
        {
			idPTMap.put(appReq, appReq.Program_Term__c);
        	/*if(appReq.Program_Term__c != null)
        	{
        		idPTMap.put(appReq, appReq.Program_Term__c);
        	}
        	else
        	{
        		idPOMap.put(appReq, appReq.Program_Option__c);
        	}*/		
        }
        
    	List<RecordType> appReqRT = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Application_Requirement__c'];
    	List<RecordType> appItemRT = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Application_Item__c'];
    	
    	for(RecordType appReq: appReqRT)
    	{
    		for(RecordType appItem: appItemRT)
    		{
    			if(appReq.DeveloperName == appItem.DeveloperName)
    			{
    				recordTypeMap.put(appReq.Id, appItem);
    			}	
    		}		
    	}
        List<String> statuses = new List<String>{'Program Selected', 'Ready To Submit', 'Submitted', 'Accepted', 'On Site'};
        statuses.add('Accepted (with Conditions)');
        List<Application__c> ptApps = [SELECT Id, Name, Program_Term__c, Program_Term__r.Parent_Program_Term__c FROM Application__c WHERE (Program_Term__r.Parent_Program_Term__c IN: idPTMap.values() OR Program_Term__c IN: idPTMap.values()) AND Status__c IN: statuses];
        /*if(idPOMap.size() > 0)
        {
        	List<Application__c> poApps = [SELECT Id, Name, Program_Term__c, Parent_Program_Term__c FROM Application__c WHERE Program_Option__c IN: idPOMap.values()];
        }*/
        
        List<Application_Item__c> appItems = new List<Application_Item__c>();
        
        for(Application__c app: ptApps)
        {
        	for(Application_Requirement__c ptAppReq: idPTMap.keySet())
        	{
        		if(ptAppReq.Program_Term__c == app.Program_Term__c || ptAppReq.Program_Term__c == app.Program_Term__r.Parent_Program_Term__c)
        		{
        			appItems.add(ifsaApplicationWrapper.AppReqToAppItem(ptAppReq, app, recordTypeMap.get(ptAppReq.RecordTypeId).Id));
        		}
        	}
        	/*for(Application_Requirement__c poAppReq: idPOMap.keySet())
        	{
        		if(poAppReq.Program_Option__c == app.Program_Option__c)
        		{
        			appItems.add(ifsaApplicationWrapper.AppReqToAppItem(poAppReq, app, recordTypeMap.get(poAppReq.RecordTypeId).Id));
        		}
        	}*/
        }
        //if(appItems.size() > 75)
            //sObjectBatchUpdater.batchUpdate(appItems, 75, sObjectBatchUpdater.dmlTypes.dmlInsert, new List<Id>(newMap.keySet()));
        //else
        //    database.insert(appItems);
        if(!appItems.isEmpty() && !Test.isRunningTest())
        {
            //insert appItems;
			sObjectBatchUpdater.batchUpdate(appItems, 75, sObjectBatchUpdater.dmlTypes.dmlInsert);
        }
	}
    /**
     * Updates select fields on application items when an application requirement is updated
	 * @param newMap Map from Trigger.newMap
     */
	public static void updateRelatedApplicationItems(Map<Id, Application_Requirement__c> newMap)
	{
        List<Application_Item__c> itemsToCheck = [SELECT Id, Name, Directions__c, Phase__c, Application_Requirement__c FROM Application_Item__c WHERE Override_Requirement_Directions__c = FALSE AND Status__c != 'Complete' AND Application_Requirement__c IN: newMap.keySet()];
        List<Application_Item__c> itemsToUpdate = new List<Application_Item__c>();
        for(Application_Item__c appItem: itemsToCheck)
        {       
			Boolean itemChanged = false; 	
            if(appItem.Directions__c != newMap.get(appItem.Application_Requirement__c).Directions__c)
            {
            	appItem.Directions__c = newMap.get(appItem.Application_Requirement__c).Directions__c;
            	itemChanged = true;
            }
			if(appItem.Name != newMap.get(appItem.Application_Requirement__c).Name)
			{
				appItem.Name = newMap.get(appItem.Application_Requirement__c).Name;
				itemChanged = true;
			}
			if(appItem.Phase__c != newMap.get(appItem.Application_Requirement__c).Phase__c)
			{
				appItem.Phase__c = newMap.get(appItem.Application_Requirement__c).Phase__c;
				itemChanged = true;
			}
			if(itemChanged)
			{
				itemsToUpdate.add(appItem);
			}
        }
        if(!itemsToUpdate.isEmpty())
        {
        	sObjectBatchUpdater.batchUpdate(itemsToUpdate, 50, sObjectBatchUpdater.dmlTypes.dmlUpdate);	
        }
        
        //Line below needs to call sObjectBatchUpdater instead
        /*
        applicationItemBatchUpdate updateService = new applicationItemBatchUpdate('SELECT Id, Directions__c, Application_Requirement__r.Directions__c FROM Application_Item__c WHERE Override_Requirement_Directions__c = FALSE AND Status__c = \'Incomplete\' AND Application_Requirement__c IN ' + inClause);
        Id batchId = Database.executeBatch(updateService, 50);
        */
	}
}