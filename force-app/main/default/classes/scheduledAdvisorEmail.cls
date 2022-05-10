/**
* @description Schedulable class to send weekly status updates to Home Institution Advisors
* @author Brock Barlow
*/
global without sharing class scheduledAdvisorEmail implements Schedulable, Database.Batchable<sObject>
{
	private List<Application__c> applicationList;
	global scheduledAdvisorEmail()
	{
		applicationList = [SELECT Id, Student_Last_Name__c, Student_First_Name__c, Status__c, Previous_Status__c, Program_Approval_Completed_By__c, Home_Institution_Account_ID__c, Program_Term__r.Display_Name__c, Applicant__r.Home_Institution__c, Applicant__r.Email, Program_Term__r.Program__r.Name, Application_Deadline__c FROM Application__c WHERE Program_Term__r.Program__r.Category__c = 'Catalog' AND Program_Term__r.Term__r.Year__c >=: Date.today().year() AND (Status__c IN ('Program Selected', 'Ready To Submit', 'Submitted', 'Accepted', 'Accepted (With Conditions)') OR (Previous_Status_Is_Current__c = false)) ORDER BY Home_Institution_Account_ID__c, Program_Term__r.Program__r.Name, Application_Deadline__c, Student_Last_Name__c, Student_First_Name__c];
	}

	global scheduledAdvisorEmail(List<Application__c> apps)
	{
		applicationList = apps;
	}
	global void execute(SchedulableContext c)
	{
		Database.executeBatch(this);
	}

	global List<Application__c> start(Database.BatchableContext bc) 
	{
		return applicationList;
	}

	global void execute(Database.BatchableContext bc, List<Application__c> applicationList)
	{
		List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
		List<Id> homeInstitutionIds = new List<Id>();

		// Get the applications and advisors		
		for(Application__c app: applicationList)
		{
			if(app.Home_Institution_Account_ID__c != null)
			{
				homeInstitutionIds.add(app.Home_Institution_Account_ID__c);
			}
			app.Previous_Status__c = app.Status__c != app.Previous_Status__c ? app.Status__c : app.Previous_Status__c;
		}
		
		List<Contact> advisorList = [SELECT Id, Email, Account.Name, AccountId FROM Contact WHERE AccountId IN: homeInstitutionIds  AND Receive_Alerts__c = true AND Email != NULL];
		system.debug('Applications: ' + applicationList.size());
		system.debug('Advisors: ' + advisorList.size());
		EmailTemplate emailTemplate = [SELECT Id, Subject FROM EmailTemplate WHERE DeveloperName = 'Advisor_Weekly_Status_Update' LIMIT 1].get(0);
		
		for(Contact advisor : advisorList)
		{
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.templateid = emailTemplate.Id;
			message.setTargetObjectId(advisor.Id);
			message.setWhatId(advisor.AccountId);

			emailList.add(message);
		}
		

		system.debug(emailList.size());
		// Send emails and update applications
		Messaging.sendEmail(emailList, false);
	}

	global void finish(Database.BatchableContext bc)
	{
		sObjectBatchUpdater.batchUpdate(applicationList, 15);
	}
}