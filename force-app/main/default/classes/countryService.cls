/**
 * Service clas to be used by <<countryTriggerHandler>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class countryService 
{    
    public static void newCountry(List<Country__c> newRecords)
    {
        for(Country__c c: newRecords)
        {
            Set<String> picklistValues = new Set<String>(apexConversionUtility.getPicklistStringValues(Case.Affected_Countries__c));
            if(!picklistValues.contains(c.Name))
            {
                caseService.createSFTicketToAddValueToPicklist('Case', 'Affected_Countries__c', c.Name);
            }
        }
    }
}