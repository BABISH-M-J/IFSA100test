/**
 * Schedulable, Batchable class that sends the CRF Cutoff email to student who are approaching the CRF cutoff date to prompt them to complete their CRF in the student portal
 * @author Brock Barlow
 */
// ApexDoc updated 1/26/2021 Brock Barlow
global with sharing class batchSendCRFCutoffEmail implements Database.Batchable<sObject>, Schedulable{
    /**
     * Start function required by the Batchable Interface
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date cutoff = Date.today().addDays(7);
        String query = 'SELECT Id, (SELECT Id, Applicant_Email__c, Applicant__c FROM Applications__r WHERE Status__c = \'On Site\' AND CRF_Status__c = \'Not Started\') ' + 
        'FROM Program_Term__c WHERE CRF_Editable__c = true AND CRF_Cutoff_Date__c = :cutoff';
		return Database.getQueryLocator(query);
	}
    /**
     * Creates and send email messages to the applicants of the queried applications from the start method.
     * Execute method required by the Batchable interface
     */
    global void execute(Database.BatchableContext BC, List<Program_Term__c> scope){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for(Program_Term__c progTerm : scope){
            for(Application__C app : progTerm.Applications__r){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setReplyTo('no-reply@ifsa-butler.org');
                mail.setSenderDisplayName('IFSA-Butler No-Reply');
                mail.setSubject('CRF Deadline appoaching!');
                //Still need verbage here
                mail.setHtmlBody('<p>CRF Deadline is in 1 week.</p>');
                mail.setTargetObjectId(app.Applicant__c);
                mail.setSaveAsActivity(true);

                List<String> emailReciever = new List<String>{app.Applicant_Email__c};
                mail.setToAddresses(emailReciever);

                emails.add(mail);
            }
        }
        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
    }
    /**
     * Nothing happens here, but it could send an email, or notification to a user that the job has completed or if any errors occured during processing
     * Finish method required by the Batchable interface
     */
    global void finish(Database.BatchableContext BC) {
		
    }
    /**
     * Creates an instance of batchSendCRFCutoffEmail and puts the job in the queue.
     * Execute method required by the Schedulable interface
     */
    public void execute(SchedulableContext c)
	{
		batchSendCRFCutoffEmail b = new batchSendCRFCutoffEmail();
      	database.executebatch(b);
	}
}