/**
 * Creates a portal user for an advisor contact from either a Flow or Lightning Process
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class invocableCreateAdvisorUser 
{
    /**
     * @InvocableMethod Creates a portal user for an advisor contact from either a Flow or Lightning Process
     */
    @InvocableMethod(label='Create Portal User' description='Creates portal user for contact' category='Contact')
    public static List<String> createAdvisorUser(List<Id> contactIds)
    {
        List<String> results = new List<String>();
        if(contactIds.size() == 1)
        {
            results.add(contactWrapper.createAdvisorUser(contactIds[0]));
        }
        else if(contactIds.size() > 1)
        {
            results.add('ERROR: Too many contact ids provided');
        }
        else
        {
            results.add('ERROR: Did not provide a contact id');
        }
        return results;        
    }
}