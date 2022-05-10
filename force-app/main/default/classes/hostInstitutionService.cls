/**
 * Service class for Host_Institution__c object
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class hostInstitutionService 
{
    /**
     * Creates a case notifying Salesforce team that a new Host Institution record has been created.
     */
    public static void newHostInstitution(List<Host_Institution__c> newRecords)
    {
        for(Host_Institution__c h: newRecords)
        {
            Set<String> picklistValues = new Set<String>(apexConversionUtility.getPicklistStringValues(Case.Affected_Host_Institutions__c));
            if(!picklistValues.contains(h.Name))
            {
                caseService.createSFTicketToAddValueToPicklist('Case', 'Affected_Host_Institutions__c', h.Name);
            }
        }
    }
}