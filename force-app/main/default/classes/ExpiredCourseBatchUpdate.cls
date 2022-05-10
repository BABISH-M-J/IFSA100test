/**
 * Batchable, Schedulable class that expires classes that have not been renewed in 5 years
 * @author Audrey Carson
 */
// ApexDoc updated 2/1/2021 Brock Barlow
global class ExpiredCourseBatchUpdate implements Database.Batchable<sObject>, schedulable {
	
	String query;
	Date fiveYearsAgo;
	
	/**
	 * Contructor, gets the date for 5 years ago and creates a SOQL query string for classes that have not been renewed since before that date
	 */
	global ExpiredCourseBatchUpdate() {
		fiveYearsAgo = System.today().addYears(-5);
		query = 'SELECT Id, Is_Expired__c, Expiration_Reason__c ' +
				'FROM Course__c ' +
				'WHERE Approved_for_CHART__c = true AND Is_Expired__c = false AND Last_Renewed_Date__c <=: fiveYearsAgo';
	}
	
	/**
	 * Method required by Batchable interface
	 */
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}
	/**
	 * Method required by Batchable interface, updates the Course__c record
	 */
   	global void execute(Database.BatchableContext BC, List<Course__c> scope) {
		
		for(Course__c c : scope)
		{
			if(String.isBlank(c.Expiration_Reason__c))
			{
				c.Is_Expired__c = true;
				c.Expiration_Reason__c = '5 years since last renewal';
			}
		}

		update scope;
	}
	/**
	 * Method required by Batchable interface
	 */
	global void finish(Database.BatchableContext BC) {
		
	}
	/**
	 * Method required by schedulable interface, starts the batch process
	 */
	global void execute(SchedulableContext ctx){
		ExpiredCourseBatchUpdate b = new ExpiredCourseBatchUpdate(); //ur batch class
      	database.executebatch(b);
	}
	
}