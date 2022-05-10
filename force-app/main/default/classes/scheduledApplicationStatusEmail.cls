/**
 * scheduledApplicationStatusEmail - Depreciated
 * Schedulable apex to send application updates to students at two or four week intervals
 * based on time to application deadline
 * 
 * @author Brock Barlow
 */
global without sharing class scheduledApplicationStatusEmail// implements Schedulable 
{
	/*
    global void execute(SchedulableContext c)
	{
		scheduledApplicationStatusEmail.sendStatus();
	}
	
	public static void sendStatus()
	{
		EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'App_2_Week_Follow_up'];
		EmailTemplate etChile = [SELECT id FROM EmailTemplate WHERE developerName = 'Application_Status_Update_Chile'];

		//List of Email Messages
		List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
		
		Date threeMonths = Date.Today().addMonths(3);
		//List of Applications with deadlines closer than three months and more than two weeks since last update
		List<Application__c> lessList = [SELECT Id, Applicant__c, Owner.Name, CreatedDate, Last_Application_Update__c, Program_Term__r.Name FROM Application__c WHERE Status__c = 'Program Selected' AND Applicant__r.EmailBouncedReason = NULL AND ((Program_Term__r.Application_Deadline__c <: threeMonths OR Program_Term__r.Parent_Program_Term__r.Application_Deadline__c <: threeMonths) AND (Last_Application_Update__c < LAST_N_DAYS:14 OR (CreatedDate < LAST_N_DAYS:14 AND Last_Application_Update__c = NULL))) ORDER BY Last_Application_Update__c ASC NULLS FIRST LIMIT 40];
		system.debug('Less: ' + lessList.size());
		Integer qty = 80 - lessList.size();
		//List of Applications with deadline further than three months and more than four weeks since last update
		List<Application__c> moreList = [SELECT Id, Applicant__c, Owner.Name, CreatedDate, Last_Application_Update__c, Program_Term__r.Name FROM Application__c WHERE Status__c = 'Program Selected' AND Applicant__r.EmailBouncedReason = NULL AND ((Program_Term__r.Application_Deadline__c >: threeMonths OR Program_Term__r.Parent_Program_Term__r.Application_Deadline__c >: threeMonths) AND (Last_Application_Update__c < LAST_N_DAYS:28 OR (CreatedDate < LAST_N_DAYS:28 AND Last_Application_Update__c = NULL))) ORDER BY Last_Application_Update__c ASC NULLS FIRST LIMIT: qty];		
		system.debug('More: ' + moreList.size());
		//List for all applications that have been pulled from database to be combined into
		List<Application__c> appList = new List<Application__c>();
		appList.addAll(lessList);
		appList.addAll(moreList);
		system.debug('Total: ' + appList.size());
		//List of applications that will be updated - This may not be needed since the queries only pull records that meet requirements
		List<Application__c> updatedApps = new List<Application__c>();
		for(Application__c app: appList)
		{
		    system.debug(app.Last_Application_Update__c);
		    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();		    
		    mail.setTargetObjectId(app.Applicant__c); // Specify who the email should be sent to.
		    mail.setWhatId(app.Id); //What is this email about.		    
		    if(app.Program_Term__r.Name.contains('Chilean Universities Program'))
		    {
		    	mail.setTemplateId(etChile.id);
		    }
		    else
		    {
		    	mail.setTemplateId(et.id);
		    }
		    
		    mail.setReplyTo('no-reply@ifsa-butler.org');
		    mail.setSenderDisplayName('IFSA-Butler No Reply');
		    emailList.add(mail);
		    app.Last_Application_Update__c = Date.Today();
		    updatedApps.add(app);
		}
		system.debug(updatedApps.size());
		if(emailList.size() > 0)
		{
		    system.debug(emailList.size());
		    //This is a crappy workaround because sendMail fails in unit testing but otherwise works fine...
		    //See https://success.salesforce.com/issues_view?id=a1p300000008aRlAAI
		    //Brock Barlow - 7/15/2016
		    Boolean isTestMode = configurationManager.isTestMode();
		    if(!isTestMode)
		    {
		        Messaging.sendEmail(emailList);		
		    }
		    Database.update(updatedApps);
		    /*
		    Id brock = [SELECT Id FROM User WHERE Username LIKE 'bbarlow.1@ifsa-butler.%'].get(0).Id;
        	Task t = new Task();
        	t.Subject = 'scheduledApplicationStatusEmail has been run';
        	t.Description = 'Number of scheduledApplicationStatusEmail sent: ' + emailList.size();
        	t.ActivityDate = Date.today();
        	t.OwnerId = brock;

        	database.insert(t);
        	*//*
		}
	}*/
}