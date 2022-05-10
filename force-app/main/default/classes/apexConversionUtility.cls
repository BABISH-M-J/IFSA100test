/**
 * Utility class for data conversion and introspection.
 * @author Cameron Ames
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public without sharing class apexConversionUtility
{
	/**
	 * Gets the picklist values for a field and returns them as a string list.
	 * @param field The picklist field to obtain values for.
	 * @return The list of string values representing picklist options.
	 */
	public static List<String> getPicklistStringValues(Schema.SObjectField field)
	{
		List<Schema.PicklistEntry> values = field.getDescribe().getPicklistValues();

		//We successfully got the picklist values, now add them to the String list
		List<String> selectList = new List<String>();
		for(Schema.PicklistEntry item : values)
		{
			selectList.add(item.getLabel());
		}

		return selectList;
	}

	public static List<model_picklist> getPicklistModelValues(Schema.SObjectField field)
	{
		List<Schema.PicklistEntry> values = field.getDescribe().getPicklistValues();

		//We successfully got the picklist values, now add them to the String list
		List<model_picklist> selectList = new List<model_picklist>();
		for(Schema.PicklistEntry item : values)
		{			
			selectList.add(new model_picklist(item));
		}

		return selectList;
	}

	/**
	 * Gets the picklist values for a field and returns them as a string list.
	 * @param field The picklist field to obtain values for.
	 * @return The list of selectOption values representing the picklist options.
	 */
	public static List<SelectOption> getPicklistSelectValues(Schema.SObjectField field)
	{
		List<Schema.PicklistEntry> values = field.getDescribe().getPicklistValues();

		//We successfully got the picklist values, now add them to the String list
		List<SelectOption> selectList = new List<SelectOption>();
		for(Schema.PicklistEntry item : values)
		{
			selectList.add(new SelectOption(item.getLabel(),item.getValue()));
		}

		return selectList;
	}

	/**
	 * Takes a list of select options and removes duplicate values
	 * @param listToUniquify.
	 * @return A select list with no duplicate values
	 */
	public static List<SelectOption> uniqify(List<SelectOption> listToUniqify)
	{
		//Deal with trivial instances
		if(listToUniqify == null || listToUniqify.size() <= 1)
		{
			return listToUniqify;
		}

		//Dump all values into a map (If there are duplicates they will overwrite each other
		Map<String, SelectOption> optionMap = new Map<String, SelectOption>();

		for(SelectOption option : listToUniqify)
		{
			optionMap.put(option.getLabel(), option);
		}

		//Dump the map back into a list of selectOptions
		List<SelectOption> uniqueList = new List<SelectOption>();

		for(String key : optionMap.keySet())
		{
			uniqueList.add(optionMap.get(key));
		}

		return uniqueList;
	}
	
	/**
	 * Takes a list of sObjects and places them into a map with the map key being an Id field on the sObject.
	 * @param objectList The list of sObjects which are to be placed in the map.
	 * @param field The field name which contains the Id to use as the key. WARNING: If you use a lookup/master-detail Id, it is possible that two sObjects will have the same Id in the field, resulting in one of the values being dropped.
	 * @return A map of the Sobjects with the key being the selected Id field.
	 */
	public static Map<Id, sObject> createSObjectMap(List<sObject> objectList, String field)
	{
		Map<Id, sObject> sObjectMap = new Map<Id, sObject>();
		
		for(sObject item : objectList)
		{
			sObjectMap.put((Id) item.get(field), item);
		}
		
		return sObjectMap;
	}

	/**
	 * Comparse an SObject with a specific SObject type
	 * @param compare The object to compare
	 * @param checkType The name of the type to compare
	 * @return Boolean does the SObject match the checkType
	 */
	public static Boolean Compare(SObject compare, String checkType){
		try
		{
			Schema.SObjectType targetType = Schema.getGlobalDescribe().get(checkType);
			if(targetType == null)
			{
				return false;
			}
			else if( compare.getSObjectType() == targetType)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		catch(Exception e)
		{
			//handle exception
		             return false;
		}
		return false;
	}
}