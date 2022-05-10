/**
 * Attachment Service class, business logic for AttachmentTrigger and <<attachmentTriggerHandler>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public without sharing class attachmentService 
{
    /**
     * Updates the status of related Application_Item__c records
     * @param newRecords
     */
    public static void updateParentRecordStatus(List<Attachment> newRecords)
    {
        List<Id> idList = new List<Id>();
	
        //Add the attachment's parent id to the list
        for(Attachment attmt : newRecords)
        {
            idList.add(attmt.parentId);
        }

        //Get any application items that are in our idlist
        List<Application_Item__c> appItems = new List<Application_Item__c>();
        List<appItemStatusConfig> configs = new List<appItemStatusConfig>();
        configs.add(new appItemStatusConfig('Download-Upload', 'Started', 'Complete'));
        configs.add(new appItemStatusConfig('Passport Copy', 'Started', 'Complete'));
        configs.add(new appItemStatusConfig('No Action', 'Started', 'Complete', 'Transcript'));
        configs.add(new appItemStatusConfig('No Action', 'Started', 'Complete', 'Academic Recommendation'));
        configs.add(new appItemStatusConfig('No Action', 'Started', 'Complete', 'Academic Recommendation (Second)'));
        configs.add(new appItemStatusConfig('Recommendation', 'Started', 'Started'));
        configs.add(new appItemStatusConfig('Spanish Language Evaluation', 'Started', 'Started'));
        
        //Mark as complete
        for(Application_Item__c appItem : [SELECT Id, Name, Status__c, Not_Currently_Enrolled__c, RecordType.Name FROM Application_Item__c WHERE Id IN: idList])
        {
            Boolean hasMatch = false;

            for(appItemStatusConfig config: configs)
            {
                if(appItem.RecordType.Name == config.recordTypeName && config.allRecordTypes && appItem.Status__c == config.currentStatus)
                {
                    appItem.Status__c = config.finalStatus;
                    appItems.add(appItem);
                    hasMatch = true;
                    break;
                }
                else if(appItem.RecordType.Name == config.recordTypeName && !config.allRecordTypes && appItem.Name == config.appItemName && appItem.Status__c == config.currentStatus)
                {
                    appItem.Status__c = config.finalStatus;
                    appItems.add(appItem);
                    hasMatch = true;
                    break;
                }
            }
            if(!hasMatch)
            {
                appItem.Status__c = 'Complete';
                appItems.add(appItem);
            }
        }
        
        if(!appItems.isEmpty())
        {
            Database.update(appItems);
        }
    }
    /**
     * Instances of this class configure how <<attachmentService>> updates specific records types (sometimes with specific record names) status
     */
    public class appItemStatusConfig
    {
        /**
         * The Application Item Record Type name that this instance controls
         */
        public String recordTypeName {get;set;}  
        /**
         * The Application Item Status that this instance controls
         */
        public String currentStatus {get;set;}
        /**
         * The Application Item Status that <<attachmentService>> will update to
         */
        public String finalStatus {get;set;}
        /**
         * The Application Item Name that this instance controls
         */
        public String appItemName {get;set;}
        /**
         * Determines if this instance controlls all Application Items of a specific record type
         */
        public Boolean allRecordTypes {get;set;}
        /**
         * Contstuctor, Supply a specific application item name, other application items of this record type will follow a different configuration, possibly controlled by another instance or uses the default configuration built in to the logic in the trigger handler. This sets allRecordTypes to false
         * @param rt The record type name
         * @param cs The current status of the application item
         * @param fs The status that <<attachmentService>> will change the application item record to
         * @param ai The name of the Application Item this instance controls
         */
        public appItemStatusConfig(String rt, String cs, String fs, String ai)
        {
            recordTypeName = rt;
            currentStatus = cs;
            finalStatus = fs;
            appItemName = ai;
            allRecordTypes = false;
        }
        /**
         * Constructor, Works with all application items of a specific record type. This sets allRecordTypes to true
         * @param rt The record type name
         * @param cs The current status of the application item
         * @param fs The status that <<attachmentService>> will change the application item record to
         */
        public appItemStatusConfig(String rt, String cs, String fs)
        {
            recordTypeName = rt;
            currentStatus = cs;
            finalStatus = fs;
            allRecordTypes = true;
        }
    }
}