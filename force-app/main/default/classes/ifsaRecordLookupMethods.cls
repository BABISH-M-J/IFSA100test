/**
 * Class to perform lookups from VF pages
 * @author Brock Barlow
*/
public without sharing class ifsaRecordLookupMethods 
{	
	/**
	 * Constructor to enable use with any IFSA controllers.
	 */
	public ifsaRecordLookupMethods(ifsaBaseController controller){}
	
	/**
	 * Searches for SObjects.
	 * @param objectName The object name being searched.
	 * @param searchTerm The name of the record that is being searched for
	 * @return the list of appropriate records.
	 */
    @RemoteAction
    public static List<ifsaRecordLookupViewModel> searchForRecord(String objectName, String searchTerm) 
    {
    	String query = '';

    	if(objectName == 'Contact')
    		query = 'SELECT Id, Name, FirstName, LastName FROM ' + objectName + ' WHERE name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' LIMIT 100';
		else if(objectName == 'Case')
			query = 'SELECT Id, CaseNumber FROM ' + objectName + ' WHERE CaseNumber LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
		else if(objectName == 'User')
			query = 'SELECT Id, Name, FirstName, LastName FROM ' + objectName + ' WHERE name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' AND UserType = \'Standard\'';
		else
    		query  = 'SELECT Id, Name FROM ' + objectName + ' WHERE name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';

        return createList(query, objectName);
	}
	/**
	 * Searches for SObjects.
	 * @param objectName The object name being searched.
	 * @param searchTerm The name of the record that is being searched for
	 * @param recordTypeDeveloperName The name of the recordtype that is being searched
	 * @return the list of appropriate records.
	 */
	@RemoteAction
    public static List<ifsaRecordLookupViewModel> searchForRecordWithRecordType(String objectName, String searchTerm, String recordTypeDeveloperName) 
    {
    	String query = '';

    	if(objectName == 'Contact')
    		query = 'SELECT Id, Name, FirstName, LastName FROM ' + objectName + ' WHERE name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' AND RecordType.DeveloperName = \'' + recordTypeDeveloperName + '\'  LIMIT 100';
		else if(objectName == 'Case')
			query = 'SELECT Id, CaseNumber FROM ' + objectName + ' WHERE CaseNumber LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' AND RecordType.DeveloperName = \'' + recordTypeDeveloperName + '\'';
		else if(objectName == 'Locality__c')
			query = 'SELECT Id, Name FROM ' + objectName + ' WHERE name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' AND Country__r.Name = \'' + recordTypeDeveloperName + '\' AND RecordType.DeveloperName = \'City_Town\'';
		else
    		query = 'SELECT Id, Name FROM ' + objectName + ' WHERE name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' AND RecordType.DeveloperName = \'' + recordTypeDeveloperName + '\'';
		
        return createList(query, objectName);
	}	
	/**
	 * Searches for SObjects.
	 * @param query The SOQL query that is being used
	 * @param objectName The name of object being searched
	 * @return the list of appropriate records.
	 */
	private static List<ifsaRecordLookupViewModel> createList(String query, String objectName)
	{
		system.debug(query);
		List<SObject> records = Database.query(query);

		List<ifsaRecordLookupViewModel> viewModels = new List<ifsaRecordLookupViewModel>();
		for(SObject record : records)
		{
			ifsaRecordLookupViewModel recordLookup = new ifsaRecordLookupViewModel();
			recordLookup.Id = record.Id;
			recordLookup.Name = objectName != 'Case' ? (String) record.get('Name') : (String) record.get('CaseNumber');
			if(objectName == 'Contact' || objectName == 'User')
			{
				recordLookup.firstName = (String) record.get('FirstName');
				recordLookup.lastName = (String) record.get('LastName');
			}
			viewModels.add(recordLookup);
		}

		return viewModels;
	}
}