@isTest
public class ContentTriggerHandler_Test {
    public static testMethod void ContentTriggerMethod1(){
        
        IFSA_Team_Member__c ifsa=new IFSA_Team_Member__c();
        ifsa.Name='Test IFSA';
        ifsa.Team_Member_Image__c='Test Image';
        insert ifsa;        
        List<ContentVersion> contentVersionList= new  List<ContentVersion>();
        Set<String> converId=new  Set<String>();
        ContentVersion testVersion = new ContentVersion();
        String csv = 'Test Data';
        testVersion.Title = 'Content Trigger Test';
        testVersion.PathOnClient = '/'+testVersion.Title+'.csv';
        testVersion.VersionData = Blob.valueOf(csv);
        insert testVersion;
        Set<id> ids=new Set<id>();
        ids.add(testVersion.id);
        List<ContentDocumentLink> cdlinkList=new  List<ContentDocumentLink>();
        contentVersionList=[SELECT Id, Title,PathOnClient,VersionData,ContentBodyId,ContentDocumentId FROM ContentVersion where id IN :ids];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = ifsa.id;
        cdl.ContentDocumentId = contentVersionList[0].ContentDocumentId;
        cdl.shareType = 'V';
        insert cdl;
        cdlinkList.add(cdl);
        test.startTest();
       // ContentTriggerHandler.createPublicLinkForFile(contentVersionList);
        ContentTriggerHandler.getContentVersionList(cdlinkList);
        test.stopTest();
    }
}