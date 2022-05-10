/*
 *
 * @description: schedule job to run to temporarily fix
 *   Fast_Forms_URL__c on Primary applications
 * @author: Audrey Carson
 *
*/
global class scheduleFormstackFix implements Schedulable {
	global void execute(SchedulableContext sc) {
		ID jobId = System.enqueueJob(new formstackFixQueueable());
	}

	public static void formstackFix(List<Application_Item__c> newRecords){
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
		for(Id formId: ids.keySet())
		{
			//visualantidote.FastFormsUtilities.UpdateRecordsWithURL ( 'Object Being Updated' ,  'Field to Update' ,  'FastForms Form Id' ,  Application Items to Update );
			Visualantidote.FastFormsUtilities.UpdateRecordsWithURL( 'Application_item__c',  'Fast_Forms_URL__c',  formId, ids.get(formId));
		}
	}

	public class formstackFixQueueable implements Queueable
	{
		public void execute(QueueableContext context) {
			List<Application_Item__c> newRecords = [SELECT Id, Form_Template_ID__c FROM Application_Item__c WHERE Form_Template_ID__c != NULL AND Fast_Forms_URL__c = NULL];
			if(!newRecords.isEmpty())
			{
				scheduleFormstackFix.formstackFix(newRecords);
				if(!Test.isRunningTest()){
					ID jobId = System.enqueueJob(new formstackFixQueueable());
				}
			}
		}			
	}
}