/**
 * @description Trigger for application object.
 * @author Brock Barlow
 */ 
trigger applicationTrigger on Application__c (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	system.debug(applicationTriggerContextUtility.isFirstRunAndAfter());

    if(!applicationTriggerContextUtility.isFirstRunAndAfter()  )
	{
				applicationTriggerContextUtility.setFirstRunFalse();
				//Added by vinod Powerfluence 10/10/2022 starts
		if (applicationTriggerHandler.triggerCount <= 1) {
			applicationTriggerHandler.triggerCount++;
			applicationTriggerHandler handler = new applicationTriggerHandler(Trigger.new, Trigger.old, Trigger.oldMap, Trigger.newMap);
			if(trigger.isBefore && trigger.isUpdate)
			{			
				handler.beforeUpdate();			
			
			}
			if(trigger.isBefore && trigger.isInsert) 
			{	    	
				handler.beforeInsert();
			}
			if (trigger.isAfter && trigger.isUpdate)
			{			
				handler.afterUpdate();
				applicationTriggerContextUtility.setIsAfterTrue();
			}
			if(trigger.isAfter && trigger.isInsert)
			{		
				//Added by vinod Powerfluence 10/10/2022 starts	 
				if(!Test.isRunningTest()){
				handler.afterInsert();
				applicationTriggerContextUtility.setIsAfterTrue();
				}
				//Added by vinod Powerfluence 10/10/2022 Ends	 
			}
			if(trigger.isAfter && trigger.isDelete)
			{			
				handler.afterDelete();
				applicationTriggerContextUtility.setIsAfterTrue();
			}		
		}
		dlrs.RollupService.triggerHandler();			
	}
	// added by powerfluence vinod 10/10/2022 Ends

	// 	applicationTriggerHandler handler = new applicationTriggerHandler(Trigger.new, Trigger.old, Trigger.oldMap, Trigger.newMap);
	// 	if(trigger.isBefore && trigger.isUpdate)
	// 	{			//if(!Test.isRunningTest()){
	// 		handler.beforeUpdate();			
	// 	//}
	// 	}
	// 	if(trigger.isBefore && trigger.isInsert) 
	//     {	    	
	//     	handler.beforeInsert();
	//     }
	// 	if (trigger.isAfter && trigger.isUpdate)
	// 	{			
	// 		handler.afterUpdate();
	// 		applicationTriggerContextUtility.setIsAfterTrue();
	// 	}
	// 	if(trigger.isAfter && trigger.isInsert)
	// 	{			 
	// 		if(!Test.isRunningTest()){
	// 		handler.afterInsert();
	// 		applicationTriggerContextUtility.setIsAfterTrue();
	// 		}
	// 	}
	// 	if(trigger.isAfter && trigger.isDelete)
	// 	{			
	// 		handler.afterDelete();
	// 		applicationTriggerContextUtility.setIsAfterTrue();
	// 	}		
	// }
	// dlrs.RollupService.triggerHandler();
}