/**
 * Utility class for query convenience methods.
 * @author Cameron Ames
 */
// ApexDoc updated 1/25/2021 Brock Barlow
 public without sharing class apexQueryUtility
{
	/**
	 * Method is equivalent to a SELECT * from statement in SQL
	 * @param objectName The name of the sObject to query.
	 * @param extras This should be any extra fields you would like to query (RecordType.Name, Account.Contact.FirstName, etc.)
	 * @param whereClause Criteria for determining the records to return (the WHERE clause in a SOQL/SQL query without the word WHERE)
	 * @return The list of sObjects that are obtained from the query
	 */
	public static List<sObject> selectAllFrom(String objectName, String extras, String whereClause)
	{
		String query = 'SELECT' + getAllFields(objectName);        

		//If there are extras, then we need to add a space and the extras. Otherwise add nothing to the query.
        query += extras != null ? ' ,' + extras : '';

		//Add the sobject and where clause to the query
        query += ' FROM ' + objectName;
        query += (whereClause != null) ? ' WHERE ' + whereClause : '';

		//Log the query and execute.
		apexErrorUtility.debug(LoggingLevel.INFO, query);
		system.debug(query);
        return Database.query(query);
	}

	/**
	 * Wrapper method for full-parametered selectAllFrom. Makes the extras parameter optional.
	 * @param objectName See the description on the full-parametered method.
	 * @param whereClause See the description on the full-parametered method.
	 * @return See the description on the full-parametered method.
	 */
	public static List<sObject> selectAllFrom(String objectName, String whereClause)
	{
		return apexQueryUtility.selectAllFrom(objectName, null, whereClause);
	}

	/**
	 * Allows IN clauses to be used with the selectAllFrom method.
	 * @param objects The list of Ids to form the IN clause.
	 * @return A string in this format : '(\'Id1\', \'Id2\')'
	 */
    public static String buildInClause(List<Id> objects)
    {
		//We don't need to return anything if we didn't get any Ids.
		if(objects == null || objects.size() < 1)
		{
			return null;
		}

		//Add each Id inside the parenthsies
        String inClause = '(';
        for(Id obj : objects)
        {
            if(obj != null)
            	inClause += '\'' + obj + '\', ';
        }

		//Remove the trailing comma if there is one because we are done adding IDs.
        if (inClause.Length() > 2 && inClause.subString(inClause.Length()-2, inClause.length()) == ', ')
        {
            inClause = inClause.subString(0, inClause.Length()-2);
        }

        inClause += ')';

        return inClause;
	}
	
	/**
	 * Allows IN clauses to be used with the selectAllFrom method.
	 * @param objects The set of Ids to form the IN clause.
	 * @return A string in this format : '(\'Id1\', \'Id2\')'
	 */
    public static String buildInClause(Set<Id> objects)
    {
		return buildInClause(new List<Id>(objects));
	}

	/**
	 * Builds an in clause from the specified field on an sObject.
	 * @param objectList The list of sObjects with the in clause values.
	 * @param field The field in the sObjects that should be used in the in clause.
	 * @return A string with the in clause.
	 */
	public static String buildInClause(List<sObject> objectList, String field)
	{
		Set<Id> idList = new Set<Id>();
		
		for(SObject item : objectList)
		{
			idList.add((Id) item.get(field));
		}
		
        return apexQueryUtility.buildInClause(new List<Id>(idList));
	}

	/**
	 * Gets the API names of an objects fields
	 * @param objectName The object name to get fields for
	 * @return String A comma separated string of all of the fields on the specified object
	 */
	public static String getAllFields(String objectName)
	{
		Map<String, Schema.SObjectField> objectFields = getFieldMap(objectName);
		String fields = '';

		//Add each field to the query
        for(String field : objectFields.keySet())
        {
            fields += ' ' + field + ',';
        }

		//Remove the trailing comma from the fields if it exists because we are done adding fields.
        if (fields.subString(fields.Length()-1,fields.Length()) == ',')
        {
            fields = fields.subString(0,fields.Length()-1);
        }

		return fields;
	}

	/**
	 * Gets a Map of an objects fields
	 * @param objectName The object name to get fields for
	 * @return Map<String, Schema.SObjectField> A map of the the objects fields
	 */
	public static Map<String, Schema.SObjectField> getFieldMap(String objectName)
	{
		Map<String, Schema.SObjectField> objectFields;
		String fields = '';
		//Try to get a list of the fields present on this sObject. If the sObject name was not proper, then throw an exception.
        try
        {
            objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        }
        catch(Exception e)
        {
			apexErrorUtility.throwException(new ifsaQueryException('The objectName parameter in selectAllFrom was not an SObject. The original error follows: ' + e.getMessage()));
		}
		
		return objectFields;
	}

}