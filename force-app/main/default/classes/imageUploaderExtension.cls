/**
 * Controller for imageUploader Visualforce page, this is used to provide a simple interface to upload image attachments and resizes the images so they are not too large for the portals
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
global with sharing class imageUploaderExtension {

	private final sObject mysObject;
    public Id parentId {get; private set;}
    public String instance {get; private set;}
    public String attachments {get;set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public imageUploaderExtension(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
        this.parentId = mysObject.Id;
        this.instance = apexInstanceUtility.instance;
        this.attachments = JSON.serialize([SELECT Id, CreatedBy.Name, LastModifiedDate, Name, ContentType FROM Attachment WHERE ParentId =: mysObject.Id]);
        this.attachments = this.attachments.escapeEcmaScript();
        //apexQueryUtility.selectAllFrom('Attachment', 'CreatedBy.Name', 'ParentId = \'' + mysObject.Id + '\'');
    }

    @RemoteAction
    global static Boolean deleteAttachment(String recordToDelete)
    {
        Database.DeleteResult dr = Database.delete(recordToDelete);
        return dr.isSuccess();
    }

    @RemoteAction
    global static Attachment upload(String name, String base64, String parentId)
    {
        try
        {   
            base64 = base64.replace('data:image/png;base64,', '');
            Database.SaveResult sr = Database.insert(new Attachment(ParentId = parentId, Name = name, Body = EncodingUtil.base64Decode(base64)));
            Attachment a = [SELECT Id, CreatedBy.Name, LastModifiedDate, Name, ContentType FROM Attachment WHERE Id =: sr.getId()];
            return a;
        }
        catch (Exception e)
        {
            system.debug(e.getMessage());
            return null;
        }
    }
}