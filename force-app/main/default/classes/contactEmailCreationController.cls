/**
 * Controller class for contactEmailCreation Visualforce page. This page is used to manually create an ifsa-butler.net email account on Microsoft 365
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public with sharing class contactEmailCreationController {

    /**
     * The contact record of the user to create an email account for
     */
    public Contact record { get; set; }
    /**
     * The email address to attempt to create in M365
     */
    public String generatedEmailAddress { get; set;}
    /**
     * This flag is true when the contact already has an email account listed on their contact record and this will prevent
     * the user attempting to create another account
     */
    public Boolean hasEmail { get; set; }
    /**
     * This flag is true when the system is attempting to create an email account on M365
     */
    public Boolean updatingContact { get; set; }

    /**
     * The extension constructor initializes the private member variable mysObject by using the getRecord method from the standard controller.
     * @param stdController an instance of ApexPages.StandardController 
     */
    public contactEmailCreationController(ApexPages.StandardController stdController) {
        record = [SELECT Id, Name, FirstName, LastName, Owner.Email, Owner.Name, IFSA_Butler_NET_Email__c FROM Contact WHERE Id =: stdController.getId()];
        generatedEmailAddress = record.FirstName + '.' + record.LastName + '@ifsa-butler.net';
        hasEmail = record.IFSA_Butler_NET_Email__c != null;
        updatingContact = false;
    }
    /**
     * Starts the email account creation process
     * @return PageReference When successfull, the user is redirected back to the contact record
     */
    public PageReference createEmail()
    {
        contactService.createIFSAButlerNETEmail(record.FirstName, record.LastName, record.Owner.Email, String.valueOf(record.Id));
        record.Updating_IFSA_Butler_NET_Email__c = true;
        database.update(record);
        updatingContact = true;
        return new PageReference('/' + record.Id);
    }
}