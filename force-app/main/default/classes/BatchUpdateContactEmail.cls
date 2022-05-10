/**
 *  Batch class to update values in contacts email address fields
 *  to end with '.test'
 *
 *  @author Audrey Carson
 *  Oct.14.2017    Spiceworks Ticket: #6163
 */
// ApexDoc updated 1/26/2021 Brock Barlow
global class BatchUpdateContactEmail implements Database.Batchable<sObject> {
	
	String query;
	/**
	 * Queries for the contact records
	 */
	global BatchUpdateContactEmail() {
		//Query pulling contact records where any email field isn't null
		query = 'SELECT Id, Email, Secondary_Email__c, IFSA_Butler_NET_Email__c FROM Contact WHERE (Email != NULL AND (NOT(Email LIKE \'%.test\'))) OR ' +
				'(Secondary_Email__c != NULL AND (NOT(Secondary_Email__c LIKE \'%.test\'))) OR (IFSA_Butler_NET_Email__c != NULL AND (NOT(IFSA_Butler_NET_Email__c LIKE \'%.test\')))';
	}
	/**
     * Start function required by the Batchable Interface
     */
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}
	/**
     * Appends .test to contact email addresses
     * Execute method required by the Batchable interface
     */
   	global void execute(Database.BatchableContext BC, List<Contact> scope) {

		List<Contact> contactList = new List<Contact>();

		for(Contact c : scope){
			//variable to determine if contact should be updated
			Boolean shouldUpdate = false;

			if(String.isNotBlank(c.Email) && !c.Email.endsWith('.test')){
				c.email += '.test';
				shouldUpdate = true;
			}
			if(String.isNotBlank(c.Secondary_Email__c) && !c.Secondary_Email__c.endsWith('.test')){
				c.Secondary_Email__c += '.test';
				shouldUpdate = true;
			}
			if(String.isNotBlank(c.IFSA_Butler_NET_Email__c) && !c.IFSA_Butler_NET_Email__c.endsWith('.test')){
				c.IFSA_Butler_NET_Email__c += '.test';
				shouldUpdate = true;
			}
			if(shouldUpdate){
				contactList.add(c);
			}
		}

		if(!contactList.isEmpty()){
			
			update contactList;
		}
	}
	/**
     * Nothing happens here, but it could send an email, or notification to a user that the job has completed or if any errors occured during processing
     * Finish method required by the Batchable interface
     */
	global void finish(Database.BatchableContext BC) {
		
	}
	
}