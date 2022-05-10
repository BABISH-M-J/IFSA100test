/**
 * Service class for Locality__c SOBject, see <<localityTriggerHandler>>
 * @author Brock Barlow
 */
// ApexDoc updated 2/19/2021 Brock Barlow
public without sharing class localityService 
{
    /**
     * When a new Locality__c record is created, this funciton will create a Case for the Salesforce team to add the new Locality to the affected Cities picklist on Case
     * @param newRecords The new Locality__c records
     */
    public static void newLocality(List<Locality__c> newRecords)
    {
        for(Locality__c l: newRecords)
        {
            Set<String> picklistValues = new Set<String>(apexConversionUtility.getPicklistStringValues(Case.Affected_Cities__c));
            if(!picklistValues.contains(l.Name) && l.RecordTypeId == Schema.SObjectType.Locality__c.getRecordTypeInfosByName().get('City/Town').getRecordTypeId())
            {
                caseService.createSFTicketToAddValueToPicklist('Case', 'Affected_Cities__c', l.Name);
            }
        }
    }
}