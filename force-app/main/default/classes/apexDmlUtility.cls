/**
 * Utility class used for generic DML operations
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public without sharing class apexDmlUtility
{
    /**
    * Deletes records if they have been created in error
    */
    public static void deleteIfCreated(List<sObject> sObjectList)
    {
    	List<sObject> toDelete = new List<sObject>();
    	for(sObject item : sObjectList)
    	{
    		if(item.get('Id') != null)
    		{
    			toDelete.add(item);
    		}
    	}
    	database.delete(toDelete);
    }
}