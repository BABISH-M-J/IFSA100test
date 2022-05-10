/**
 * Service class for Lead SObject
 * @author Brock Barlow
 */
// ApexDoc updated 2/19/2021 Brock Barlow
public without sharing class leadService 
{
	/**
     * Converts a lead to a contact. Can convert a lead to an existing contact or a new contact
     * @param leadToConvert The Lead record to convert
     * @param c The Contact record to convert the lead to
     * @return Id The contact Id of the converted lead
     */
	public static Id convertLead(Lead leadToConvert, Contact c)
    {
        Database.LeadConvert lc= new database.LeadConvert();
        lc.setLeadId(leadToConvert.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setAccountId(c != null ? c.AccountId : null);
        lc.setContactId(c != null ? c.Id : null);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult leadConversionResult = Database.convertLead(lc);

        return leadConversionResult.getContactId();
    }
}