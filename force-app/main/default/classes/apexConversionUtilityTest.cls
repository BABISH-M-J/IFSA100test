/**
 * Test class for the data conversion utility
 * @author Cameron Ames
 */
// ApexDoc updated 1/25/2021 Brock Barlow
@isTest
public with sharing class apexConversionUtilityTest
{
	/**
	 * Used to test the conversion method to get a list of strings representing the picklist values of a field.
	 */
	public static testMethod void testGetPicklistStringValues()
	{
		List<Schema.PicklistEntry> valueList = Contact.LeadSource.getDescribe().getPicklistValues();
		List<String> picklistValueList = apexConversionUtility.getPicklistStringValues(Contact.LeadSource);
		
		Boolean isValid = true;
		
		for(Schema.PicklistEntry value : valueList)
		{
			Boolean isSubValid = false;
			for(String picklistValue : picklistValueList)
			{
				if(value.getLabel() == picklistValue)
				{
					isSubValid = true;
				}
			}
			
			isValid = isValid && isSubValid;
		}
		
		System.assert(isValid, 'A picklist value did not appear in our String list.');
		
		//Try a field that has no picklist values
		picklistValueList = apexConversionUtility.getPicklistStringValues(Contact.FirstName);
		System.assertEquals(0, picklistValueList.size(), 'We found picklist values in the contact first Name.');
	}
	
	/*
	 * Test the method that gets picklist values for a field and converts to a select list.
	 */
	public static testMethod void testGetPicklistSelectValues()
	{
		List<Schema.PicklistEntry> valueList = Contact.LeadSource.getDescribe().getPicklistValues();
		List<SelectOption> picklistValueList = apexConversionUtility.getPicklistSelectValues(Contact.LeadSource);
		
		Boolean isValid = true;
		
		for(Schema.PicklistEntry value : valueList)
		{
			Boolean isSubValid = false;
			for(SelectOption picklistValue : picklistValueList)
			{
				if(value.getLabel() == picklistValue.getLabel())
				{
					isSubValid = true;
				}
			}
			
			isValid = isValid && isSubValid;
		}
		
		System.assert(isValid, 'A picklist value did not appear in our String list.');
		
		//Try a field that has no picklist values
		picklistValueList = apexConversionUtility.getPicklistSelectValues(Contact.FirstName);
		System.assertEquals(0, picklistValueList.size(), 'We found picklist values in the contact first Name.');
	}
	
	/*
	 * Test the method that uniqifies the a list of select options.
	 */
	public static testMethod void testUniqify()
	{
		//Test null list
		System.assertEquals(null, apexConversionUtility.uniqify(null), 'The uniqify did not return null');
		
		//Test with duplicates
		List<SelectOption> optionList = new List<SelectOption>();
		optionList.add(new SelectOption('Test1', 'Test1'));
		optionList.add(new SelectOption('Test1', 'Test1'));
		optionList.add(new SelectOption('Test1', 'Test1'));
		
		optionList = apexConversionUtility.uniqify(optionList);
		
		System.assertEquals(1, optionList.size(), 'We should have only had one option after a uniqified LIST.');
		
		//Test with multiple unique
		optionList.add(new SelectOption('Test2', 'Test2'));
		
		optionList = apexConversionUtility.uniqify(optionList);
		
		System.assertEquals(2, optionList.size(), 'Uniqify removed an extra item.');
	}

	/**
	 * Test the create sObject map method.
	 */
	public static testMethod void testCreateSObjectMap()
	{
		Contact ctc = apexMockDataUtility.createContact('TEst1', null);
		Contact ctc2 = apexMockDataUtility.createContact('Test2', null);
		Contact ctc3 = apexMockDataUtility.createContact('Test3', null);
		
		Map<Id, sObject> contactMap = apexConversionUtility.createSObjectMap(new List<Contact>{ctc, ctc2, ctc3}, 'Id');
		System.assertEquals(ctc.FirstName, ((Contact) contactMap.get(ctc.Id)).FirstName, 'The Map\'s first Name did not match the contact\'s first Name.');
	}
}