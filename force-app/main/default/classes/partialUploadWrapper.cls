/**
 * @description sObject wrapper for the partial upload object.
 * @author Cameron Ames
 */
public without sharing class partialUploadWrapper
{
	@InvocableMethod(label='Finalize partial upload' description='Converts partial upload and components into an attachment.')
	public static void uploadFile(List<Id> partialUploadIds)
	{
		List<Partial_Upload__c> partialUploads = [SELECT Id, Name, File_Type__c, Ready_For_Upload__c, Parent_Id__c FROM Partial_Upload__c WHERE Id IN: partialUploadIds];
		
		List<Partial_Upload_Component__c> partialUploadComponents = [SELECT Id, Name, Content__c, LastModifiedDate, Partial_Upload__c FROM Partial_Upload_Component__c WHERE Partial_Upload__c IN: partialUploadIds ORDER BY Place__c ASC];
		List<Attachment> attachments = new List<Attachment>();
		
		for(Partial_Upload__c partialUpload : partialUploads)
		{
			String contentBody = '';
			
			for(Integer i = 0; i < partialUploadComponents.size(); i++)
			{
				Partial_Upload_Component__c partialUploadComponent = partialUploadComponents.get(i);
				if(partialUploadComponent.Partial_Upload__c == partialUpload.Id)
				{
					contentBody += partialUploadComponent.Content__c;
					partialUploadComponents.remove(i);
				}
			}

			Attachment attmt = new Attachment();
			attmt.ParentId = Id.valueOf(partialUpload.Parent_Id__c);
			attmt.ContentType = partialUpload.File_Type__c;
			attmt.Body = EncodingUtil.base64Decode(contentBody);
			attmt.Name = partialUpload.Name;
			
			attachments.add(attmt);
		}

		Database.insert(attachments);
		Database.delete(partialUploads);
	}

	private Partial_Upload__c partialUpload {get;set;}
	List<Partial_Upload_Component__c> components {get;set;}

	public partialUploadWrapper(String name, String type, String parentId)
	{
		this.partialUpload = new Partial_Upload__c();
		this.partialUpload.Name = name;
		this.partialUpload.File_Type__c = type;
		this.partialUpload.Parent_Id__c = parentId;
		Database.insert(this.partialUpload);
		this.components = new List<Partial_Upload_Component__c>();
	}

	public partialUploadWrapper(Id partialUploadId)
	{
		this.partialUpload = [SELECT Id, Name, File_Type__c, Parent_Id__c FROM Partial_Upload__c WHERE Id =: partialUploadId].get(0);
		this.components = [SELECT Id, Content__c, CreatedDate FROM Partial_Upload_Component__c WHERE Partial_Upload__c =: partialUploadId ORDER BY CreatedDate ASC];
	}

	public void addComponent(String content)
	{
		Partial_Upload_Component__c newComponent = new Partial_Upload_Component__c();
		newComponent.Content__c = content;
		newComponent.Partial_Upload__c = this.partialUpload.Id;
		newComponent.Place__c = this.components.size();
		Database.insert(newComponent);
		this.components.add(newComponent);
	}

	public void attach()
	{
		if(this.partialUpload.Parent_Id__c != null && this.partialUpload.File_Type__c != null)
		{
			this.partialUpload.Ready_for_Upload__c = true;
		}
		
		Database.update(this.partialUpload);
	}

	public Id getId()
	{
		return this.partialUpload.Id;
	}
}