@isTest
public class partialUploadWrapper_Test {
    
    @TestSetup
    public static void mockdata(){
        //Create test account
        Account acct = apexMockDataUtility.createAccount('TestAcct');
        
        partialUploadWrapper puw = new partialUploadWrapper('TestPartial' , 'Image', acct.id);
		puw.addComponent('TestComponent');
    }
    
    @isTest
    public static void testattach(){
        test.startTest();
        partialUploadWrapper puw = new partialUploadWrapper('TestPartial' , 'Image', '12345678');
        puw.attach();
        test.stopTest();
        Id PartialUploadID = puw.getId();
        Partial_Upload__c partialUpload  = [SELECT Id, Name, Ready_for_Upload__c, File_Type__c, Parent_Id__c FROM Partial_Upload__c WHERE Id =: partialUploadId].get(0);
        System.assertEquals(partialUpload.Ready_for_Upload__c, true);
    }
    
    @isTest
    public static void testpartialUploadWrapper(){
        test.startTest();
        Partial_Upload__c partialUpload  = [SELECT Id, Name, Ready_for_Upload__c, File_Type__c, Parent_Id__c FROM Partial_Upload__c].get(0);
        partialUploadWrapper puw = new partialUploadWrapper(partialUpload.Id);
        Id PartialUploadID = puw.getId();
        test.stopTest();
        System.assertEquals(partialUpload.id, PartialUploadID);
    }
    
    @isTest
    public static void testuploadFile(){
        test.startTest();
        List<Partial_Upload__c> PartialUpload  = [SELECT Id, Name, Ready_for_Upload__c, File_Type__c, Parent_Id__c FROM Partial_Upload__c];
        List<Id> PartialUploadID = new List<Id>();
        for(Partial_Upload__c currRec : PartialUpload){
            PartialUploadID.add(currRec.id);
        }
        partialUploadWrapper.uploadFile(PartialUploadID);
        test.stopTest();
        List<Attachment> att = [Select id,name from Attachment where ParentId =: PartialUpload[0].Parent_Id__c];
        System.assert(!att.isEmpty());
    }
}