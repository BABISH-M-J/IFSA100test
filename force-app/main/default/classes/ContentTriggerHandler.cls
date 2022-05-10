public class ContentTriggerHandler {
    public static void createPublicLinkForFile(List<ContentVersion> contentVersions){
        List<ContentDistribution> distributionsToInsert = new List<ContentDistribution>();
        Set<Id> contentDocId = new Set<Id>();
        Map<Id, Id> objCVIdCDId = new Map<Id, Id>();
        Map<Id, Id> objCVIdCBId = new Map<Id, Id>();
        
        for(ContentVersion objContentVersion : contentVersions){
            if(objContentVersion.ContentDocumentId != null){
                objCVIdCDId.put(objContentVersion.Id, objContentVersion.ContentDocumentId);
                contentDocId.add(objContentVersion.ContentDocumentId);
            }
            if(objContentVersion.ContentBodyId != null){
                objCVIdCBId.put(objContentVersion.Id, objContentVersion.ContentBodyId);
            }
        }
        
        system.debug('contentDocId--> '+contentDocId);
        System.debug('objCVIdCDId--> '+objCVIdCDId);
        System.debug('objCVIdCBId--> '+objCVIdCBId);
        
        Map<Id,ContentDocument> contentDocMap = new Map<Id,ContentDocument>([Select id, ParentId From ContentDocument WHere ID in : contentDocId]);
        
        system.debug('contentDocMap--> '+contentDocMap);
        
        Map<Id, Id> objCDIdLEId = new Map<Id, Id>();
        List<ContentDocumentLink> objCDLList = [SELECT ContentDocumentId,Id,LinkedEntityId,ShareType,Visibility FROM ContentDocumentLink 
                                               WHERE ContentDocumentId IN: contentDocId];
        
        system.debug('objCDLList--> '+objCDLList);
        for(ContentDocumentLink objCDL : objCDLList){
            system.debug(objCDL.LinkedEntityId);
            string ParentID = objCDL.LinkedEntityId;
            if(objCDL.ContentDocumentId != null && objCDL.LinkedEntityId != null && ParentID != null && !ParentID.startsWith('005')){
                objCDIdLEId.put(objCDL.ContentDocumentId, objCDL.LinkedEntityId);
            }
        }
        
        system.debug('objCDIdLEId--> '+objCDIdLEId);
        
        set<Id> existedCVIdSet = new set<Id>();
        for(ContentVersion objContentVersion : contentVersions){
            if(contentDocMap.containsKey(objContentVersion.ContentDocumentId) && !existedCVIdSet.contains(objContentVersion.Id)){
                if(objCDIdLEId.containsKey(objContentVersion.ContentDocumentId)){
                    string ParentID = objCDIdLEId.get(objContentVersion.ContentDocumentId);
                    system.debug('ParentID--> '+ParentID);
                    if(!ParentID.startsWith('005')){
                        distributionsToInsert.add(createContentDistribution(objContentVersion.Id));
                        existedCVIdSet.add(objContentVersion.Id);
                    }
                }
            }
        }
        
        system.debug('existedCVIdSet--> '+existedCVIdSet);
        
        system.debug('--> '+distributionsToInsert.size());
        //insert contentDocumentLinks;
        List<ContentDistribution> objConDistList2 = [SELECT ContentDocumentId,ContentDownloadUrl,ContentVersionId,DistributionPublicUrl,Id,Name,OwnerId,Password,PdfDownloadUrl FROM ContentDistribution WHERE ContentVersionId IN: contentVersions ORDER By CreatedDate DESC];
        
        system.debug('objConDistList2--> '+objConDistList2);
        
        Delete objConDistList2;
        if(distributionsToInsert.size() > 0){
            system.debug('distributionsToInsert--> '+distributionsToInsert);
            insert distributionsToInsert;
        }
        List<ContentDistribution> objConDistList = [SELECT ContentDocumentId,ContentDownloadUrl,ContentVersionId,DistributionPublicUrl,Id,Name,OwnerId,Password,PdfDownloadUrl FROM ContentDistribution WHERE Id IN: distributionsToInsert ORDER By CreatedDate DESC];
        //system.debug('objConDistList--> '+objConDistList);
        
        List<IFSA_Team_Member__c> objAccListToUpdate = new List<IFSA_Team_Member__c>();
        Map<Id, IFSA_Team_Member__c> objParentIFSATeamMemberMap = new Map<Id, IFSA_Team_Member__c>([SELECT Id, Team_Member_Image__c FROM IFSA_Team_Member__c WHERE Id IN: objCDIdLEId.values()]);
        
        system.debug('objParentIFSATeamMemberMap--> '+objParentIFSATeamMemberMap);
        /*
        for(ContentDistribution objConDist : objConDistList){
            system.debug('for');
            if(objConDist.ContentDocumentId != null ){
                system.debug('1');
                system.debug(objCDIdLEId.get(objConDist.ContentDocumentId));
                if(objCDIdLEId.containsKey(objConDist.ContentDocumentId) && objParentIFSATeamMemberMap.containsKey(objCDIdLEId.get(objConDist.ContentDocumentId))){
                    system.debug('2');
                    IFSA_Team_Member__c objIFSATeamMember = objParentIFSATeamMemberMap.get(objCDIdLEId.get(objConDist.ContentDocumentId));
                    String objPublicURL = '';
                    string baseURL = Label.Base_URL_for_Public_File_Link;
                    objPublicURL = 'https://c.';
                    if(baseURL != null){
                        objPublicURL += baseURL;
                    }
                    objPublicURL+= '.content.force.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId=';
                    objPublicURL += objConDist.ContentVersionId;
                    if(objCVIdCBId.containsKey(objConDist.ContentVersionId)){
                        objPublicURL += '&operationContext=DELIVERY&contentId=' + objCVIdCBId.get(objConDist.ContentVersionId);
                    }
                    objPublicURL += '&page=0';
                    system.debug('objConDist--<> '+objConDist);
                    if(objConDist.DistributionPublicUrl != null && objConDist.DistributionPublicUrl.contains('/a/')){
                        objPublicURL += '&d=/a/';
                        string url = objConDist.DistributionPublicUrl.substringAfter('/a/');
                        objPublicURL += url;
                    }
                    objPublicURL += '&oid='+UserInfo.getOrganizationId()+'&dpt=null&viewId=';
                
                    if(objPublicURL != null){
                        system.debug('objPublicURL---> '+objPublicURL);
                        objIFSATeamMember.Team_Member_Image__c = objPublicURL;
                        objAccListToUpdate.add(objIFSATeamMember);
                    }
                }
            }
        }
        
        if(objAccListToUpdate.size() > 0){
            update objAccListToUpdate;
        }
		*/
    }
    
    public static void getContentVersionList(List<ContentDocumentLink> objContentDocumentLinkList){
        set<Id> objCdSet = new set<Id>();
        for(ContentDocumentLink objCDL : objContentDocumentLinkList){
            if(objCDL.ContentDocumentId != null){
                objCdSet.add(objCDL.ContentDocumentId);
            }
        }
        
        List<ContentVersion> objCVList = [SELECT Id, ContentBodyId, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: objCdSet];
        if(objCVList != null){
            createPublicLinkForFile(objCVList);
        }
    }
    
    public static ContentDistribution createContentDistribution(Id contentVersionId){
        ContentDistribution newDist = new ContentDistribution();
        newDist.ContentVersionId = contentVersionId;
        newDist.Name = 'External Link '+System.now();
        newDist.PreferencesNotifyOnVisit = false;
        newDist.PreferencesAllowViewInBrowser = true;
        return newDist;
    }
}