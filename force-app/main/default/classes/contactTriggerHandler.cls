/**
 * @description Trigger handler for the contact class
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class contactTriggerHandler
{
    @TestVisible static Boolean bypassTrigger = false;
    public static Boolean bypassCSP = false;

	final List<Contact> newRecords;
	final List<Contact> oldRecords;
	final Map<Id, Contact> oldMap;
	final Map<Id, Contact> newMap;
     /**
     * Constuctor, initializes applicationTriggerHandler instance
     * @param newRecords
     * @param oldRecods
     * @param newMap
     * @param oldMap
     */
	public contactTriggerHandler(List<Contact> newRecords, List<Contact> oldRecords, Map<Id, Contact> oldMap, Map<Id, Contact> newMap)
	{
        if(bypassTrigger) return;
		this.newRecords = newRecords;
		this.oldRecords = oldRecords;
		this.oldMap = oldMap;
		this.newMap = newMap;
	}
    /**
     * Before Insert
     */
	public void beforeInsert()
	{
		if(bypassTrigger) return;
        contactService.formatPhoneNumber(newRecords);
        contactService.unescapeContactName(newRecords);
    }
    /**
     * Before Update
     */
    public void beforeUpdate()
    {
        if (bypassTrigger) return;
        contactService.updateContactOwner(newMap,contactService.triggerType.isBefore);
        contactService.checkIFSAButlerNETEmail(newMap, oldMap);
        contactService.formatPhoneNumber(newRecords);
        contactService.unescapeContactName(newRecords);
    }
    /**
     * Afer Insert
     */
	public void afterInsert()
    {
        if (bypassTrigger) return;

       	//contactService.verifyContactSupportPersonnelRecords(newRecords, oldMap, newMap, contactService.triggerType.isInsert);
        //ACARSON
        //contactService.createContactSP(newRecords);
        contactService.upsertContactSP(newMap, oldMap);
    }
    /**
     * Afer Update
     */
    public void afterUpdate()
    {
        if (bypassTrigger) return;
        // BBARLOW
        // contactService.verifyContactSupportPersonnelRecords(newRecords, oldMap, newMap, contactService.triggerType.isUpdate);
        // JHOLT
        contactService.updateContactOwner(newMap,contactService.triggerType.isAfter);
        //ACARSON
        //contactService.updateContactSP(newMap, oldMap);
        if(!bypassCSP)
        {
            contactService.upsertContactSP(newMap, oldMap);
        }
        contactService.removeInactive(newRecords, oldMap);
        contactService.checkGPARequirement(newMap, oldMap);
        contactService.completeAdvisingCall(newMap, oldMap);
    }
    /**
     * After Delete
     */
    public void afterDelete()
    {
    	if (bypassTrigger) return;

    }
}