/**
 * Service class for ContentDocumentLink
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class contentDocumentLinkService 
{
    private static final Set<String> sObjectFilesVisibleToAll = new Set<String>{'Application__c', 'Application_Item__c', 'Country__c','Host_Institution__c','Program__c','Program_Term__c','Course__c'};
    /**
     * Allows portal users to view files uploaded to the object defined in sObjectFilesVisibleToAll
     * @param newRecords
     */
    public static void setVisibility(List<ContentDocumentLink> newRecords)
    {
        Map<String, Set<String>> keywords = new Map<String, Set<String>>();
        for(Content_Document_Keyword_To_Not_Share__mdt cdk: [SELECT Object__c, Keyword__c FROM Content_Document_Keyword_To_Not_Share__mdt])
        {
            if(!keywords.containsKey(cdk.Object__c))
            {
                keywords.put(cdk.Object__c, new Set<String>());
            }
            keywords.get(cdk.Object__c).add(cdk.Keyword__c.toLowerCase());
        }
        List<Id> docIds = new List<Id>();
        for(ContentDocumentLink l: newRecords)
        {
            docIds.add(l.ContentDocumentId);
        }
        Map<Id, ContentDocument> docMap = new Map<Id, ContentDocument>([SELECT Id, Title FROM ContentDocument WHERE Id IN: docIds]);
        // Loop over new records
        for(ContentDocumentLink l: newRecords)
        {
            String objectName = l.LinkedEntityId.getSObjectType().getDescribe().getName();
            if(sObjectFilesVisibleToAll.contains(objectName) && !keywords.containsKey(objectName))
            {
                // If we had a match, change Visibility to 'AllUsers'
                l.Visibility='AllUsers';
            }
            else if(sObjectFilesVisibleToAll.contains(objectName) && keywords.containsKey(objectName))
            {
                String[] title = docMap.get(l.ContentDocumentId).Title.split(' ');
                Boolean share = true;
                for(String word: title)
                {
                    if(keywords.get(objectName).contains(word.toLowerCase()))
                    {
                        share = false;
                    }
                }
                if(share)
                {
                    l.Visibility='AllUsers';
                }
            }
        }
    }

    /**
     * Updates a related SObject with the time stamp when a new version is uploaded.
     * Current updated SObjects: Course__c
     * @param newRecords
     */
    public static void setRecentUploadField(List<ContentDocumentLink> newRecords)
    {
        List<SObject> objectsToUpdate = new List<SObject>();
        User u = [SELECT Id, IsPortalEnabled FROM User WHERE Id =: UserInfo.getUserId()];
        for(ContentDocumentLink l: newRecords)
        {        
            switch on l.LinkedEntityId.getSObjectType().getDescribe().getName(){
                when 'Course__c' {
                    if(u.IsPortalEnabled)
                        objectsToUpdate.add(new Course__c(Id = l.LinkedEntityId, Last_File_Upload_Date__c = DateTime.now()));
                }
            }
        }
        objectsToUpdate.sort();
        database.update(objectsToUpdate);
    }
}