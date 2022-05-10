/**
 * @description Batachable class to update application owner
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
global class applicationOwnerUpdateService implements Database.Batchable<sObject> {
	
	String query;	
	/**
	 * Constructor, sets the SOQL query string
	 * @param queryString
	 */
	global applicationOwnerUpdateService(String queryString) {
		this.query = queryString;
	}
	/**
	 * Start function, required to implement Database.Batchable<sObject>
	 */
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}
	/**
	 * Execute function, required to implement Database.Batchable<sObject>
	 * Updates all of the queried data in the specified batch sizes
	 */
   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		System.debug(scope.size());
		Database.update(scope);
	}
	/**
	 * Finish function, required to implement Database.Batchable<sObject>
	 */
	global void finish(Database.BatchableContext BC) {
		System.debug('Updated Application Owner');
	}
	
}