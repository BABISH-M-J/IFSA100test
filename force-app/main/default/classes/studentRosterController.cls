/**
* @description Controller for printable student roster
* @author Brock Barlow
*/
public with sharing class studentRosterController {
	public studentRosterViewModel viewModel {get;set;}
	public studentRosterController() {
		this.viewModel = new studentRosterViewModel();		
		this.viewModel.programTerm = [SELECT Id, Name, Program__r.Host_Institution__c, Program__r.Host_Institution__r.Name, Term__c, Is_Custom__c, (SELECT Id FROM Program_Terms__r) FROM Program_Term__c WHERE Id =: ApexPages.currentPage().getParameters().get('Id')];
		List<Id> progarmTermIds = new List<Id>{viewModel.programTerm.Id};
		for(Program_Term__c pt: viewModel.programTerm.Program_Terms__r)
		{
			progarmTermIds.add(pt.Id);
		}
		Map<Id, Application__c> apps = new Map<Id, Application__c>([SELECT Id, Applicant__c, Applicant__r.Name, Applicant__r.Phone, Applicant__r.Address_Abroad_Cell_Phone__c, Applicant__r.Email, Applicant__r.Home_Institution__r.Name FROM Application__c WHERE Status__c IN ('Accepted', 'Accepted (with Conditions)', 'On Site') AND Program_Term__c IN: progarmTermIds ORDER BY Applicant__r.LastName, Applicant__r.FirstName]);
		Map<Id, Application_Item__c> photoItemIdMap = new Map<Id, Application_Item__c>([SELECT Id, Application__c FROM Application_Item__c WHERE Application__c IN: apps.KeySet() AND RecordType.Name = 'Upload' AND Name LIKE '%Photo%']);
		List<Attachment> attachs =[SELECT Id, Name, ParentID FROM Attachment WHERE ParentID IN: photoItemIdMap.KeySet()]; 
		//Map of Application Ids and Attachments
		Map<Id, Attachment> appItemAttachmentMap = new Map<Id, Attachment>();
		if(attachs.size() > 0)
		{
			for(Attachment attach: attachs)
			{
				appItemAttachmentMap.put(photoItemIdMap.get(attach.ParentID).Application__c, attach);
			}
		}

		for(Application__c app: apps.values())
		{
			studentRosterInformationViewModel student = new studentRosterInformationViewModel();
			student.name = app.Applicant__r.Name;
			student.studentId = app.Applicant__c;
			student.phone = app.Applicant__r.Phone;
			student.phoneAbroad = app.Applicant__r.Address_Abroad_Cell_Phone__c;
			student.email = app.Applicant__r.Email;
			student.homeSchoolName = app.Applicant__r.Home_Institution__r.Name;
			if(appItemAttachmentMap.containsKey(app.Id))
			{
				student.imageId = appItemAttachmentMap.get(app.Id).Id;
			}
            this.viewModel.students.add(student);
		}
	}
}