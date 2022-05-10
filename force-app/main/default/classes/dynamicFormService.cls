/**
 * Service class to work with Dynamic_Form__c and related objects
 */
// ApexDoc updated 2/1/2021 Brock Barlow
public with sharing class dynamicFormService 
{
    /**
     * Gets picklist options for fields used with Dynamic_Form_Item__c. This method is not referenced anywhere in apex. It could be deleted
     * @param formItems A list of Dynamic_Form_Item__c related to a Dynamic_Form__c
     */
    public static void getPicklistValues(List<Dynamic_Form_Item__c> formItems)
    {
        for(Dynamic_Form_Item__c item : formItems)
        {
            if(item.Use_Destination_Field_s_Picklist_Values__c)
            {
                Schema.SObjectType objectType = Schema.getGlobalDescribe().get(item.Destination_Object_Name__c);
                Map<String, Schema.SObjectField> FsMap = objectType.getDescribe().fields.getMap();
                Schema.SObjectField field = FsMap.get(item.Destination_Field_Name__c);
                String[] pickListValues = apexConversionUtility.getPicklistStringValues(field);
                for(Integer i = 0; i < pickListValues.size(); i++)
                {
                    if(i == 0)
                    {
                        item.Values__c = pickListValues[i];
                    }
                    else if(i < pickListValues.size() - 1)
                    {
                        item.Values__c = item.Values__c + ', ' + pickListValues[i];
                    }
                }
                item.Use_Destination_Field_s_Picklist_Values__c = false;
            }
        }
    }
    
    /**
     * Converts a form item response to the correct data type
     * @param formItem an instance of <<formBuilderComponentController>>.Item to convert the reponse value
     * @return object, the converted response
     */
    public static object convertResponse(formBuilderComponentController.Item formItem)
    {
        if(formItem.fieldType == 'Text')
        {
            return formItem.response;
        }
        else if(formItem.fieldType == 'Number')
        {
            return Double.valueOf(formItem.response);
        }
        else if(formItem.fieldType == 'Check_Box')
        {
            return Boolean.valueOf(formItem.response);
        }
        else if(formItem.fieldType == 'Date_Time')
        {
            String dateTimeString = formItem.response.replace('T', ' ');
            dateTimeString = dateTimeString.replace('.000Z', '');

            return Datetime.valueOf(dateTimeString);
        }
        else if(formItem.fieldType == 'Date')
        {
            System.debug(formItem.response);
            String[] dateTimeString = formItem.response.split('T');

            return Date.valueOf(dateTimeString[0]);
        }
        else
        {
            return formItem.response;
        }        
    }
    /**
     * Converts a form item response to the correct data type
     * @param formItem an instance of <<formBuilderComponentController>>.Item to convert the reponse value
     * @param value any object instance. This method attempts to convert it to a string
     * @return String, the value converted to a String
     */
    public static String convertResponse(formBuilderComponentController.Item formItem, object value)
    {
        if(formItem.fieldType == 'Text' && value != null)
        {
            String temp = value.toString();
            return temp;
        }
        else if(formItem.fieldType == 'Number' && value != null)
        {
            system.debug(value);
            Decimal temp = (Decimal) value;
            return temp.toPlainString();
        }
        else if(formItem.fieldType == 'Check Box' && value != null)
        {
            system.debug(value.toString());
            return value.toString();
        }
        else if(formItem.fieldType == 'Date/Time' && value != null)
        {
            Datetime temp = (Datetime) value;

            return temp.format();
        }
        else if(formItem.fieldType == 'Date' && value != null)
        {
            Date temp = (Date) value;

            return temp.format();
        }
        else
        {
            return value != null ? value.toString() : '';
        }        
    }
}