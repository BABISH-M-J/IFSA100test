/**
 * Batch class to insert new application line items when a program term is ready for billing or an application is marked as accepted
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
global class ifsaLineItemBatchInsert implements Database.Batchable<Application_Line_Item__c>, Database.Stateful {
	
	private List<Application_Line_Item__c> lineItems {get;set;}
	private List<Program_Term__c> programTerms {get;set;}
	
	/** Constructor takes a list of Application_Line_Item__c and a list of Program_Term__c */
	global ifsaLineItemBatchInsert(List<Application_Line_Item__c> lis, List<Program_Term__c> pts) {
		this.lineItems = lis;
		this.programTerms = pts;
	}
	/** Constructor takes a list of Application_Line_Item__c */
	global List<Application_Line_Item__c> start(Database.BatchableContext BC) {
		return lineItems;
	}
	/**
	 * Execute method required by Batchable interface, inserts a batch of Application_Line_Item__c records
	 */
   	global void execute(Database.BatchableContext BC, List<Application_Line_Item__c> scope) {
		Database.insert(scope);
	}
	/**
	 * Finish method required by Batachable interface, Sends email to the user that started the process if it has taken too long
	 */
	global void finish(Database.BatchableContext BC) {
		if(programTerms != null)
        {            
            List<Id> ptIds = new List<Id>();
            for(Program_Term__c progTerm: programTerms)
            {                
                progTerm.Ready_for_Billing__c = true;
                progTerm.Ready_for_Billing_Checked__c = true;
                ptIds.add(progTerm.Id);
            }
            database.update(programTerms);

        	programTerms = [SELECT Id, Name FROM Program_Term__c WHERE Id IN: ptIds];
        	String ptNames = '';
        	for(Program_Term__c pt: programTerms)
        	{
        		ptNames = ptNames + pt.Name + ' <br />';
        	}

        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setReplyTo('no-reply@ifsa-butler.org');
				mail.setSenderDisplayName('IFSA-Butler No Reply');
				mail.setToAddresses(new List<String> {UserInfo.getUserEmail()});
				mail.setSubject('Line Item population complete');
				mail.setHtmlBody('Line Item population is complete and have been added to accepted applications in the following program terms: <br /><br />' + ptNames);

			Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
		}
	}	
}