/**
 * Visualforce page controller to change the status of an existing application and create a new applicaiton
 * @author Brock Barlow
 */
// ApexDoc updated 2/1/2021 Brock Barlow
public without sharing class divertAppExtension {
    /**
     * The application to be modified
     */
    public Application__c oldApp {get;set;}
    /**
     * A new empty application record
     */
    public Application__c newApp {get;set;}
    /**
     * The student contact that we are working with
     */
    public Contact student {get;set;}
    /**
     * A list of ClonedApplicationItemTypeWrapper metadata type records that let us know what application items to clone
     */
    public List<ClonedApplicationItemTypeWrapper> clonedAppItemTypes {get;set;}

    /**
     * Constructor, initializes the controller with the data needed to operate
     */
    public divertAppExtension(ApexPages.StandardController stdController) {
        // The extension constructor initializes the private member
        // variable mysObject by using the getRecord method from the standard
        // controller.
        this.oldApp = (Application__c)stdController.getRecord();
        this.oldApp = [SELECT Id, Name, Status__c, Applicant__c FROM Application__c WHERE Id =: this.oldApp.Id];
        this.student = [SELECT Id, Name FROM Contact WHERE Id =: this.oldApp.Applicant__c];
        this.oldApp.Designation__c = null;
        this.newApp = new Application__c(
            Previous_Application__c = this.oldApp.Id, 
            Status__c = 'Program Selected',
            Name = 'New Application', 
            Applicant__c = student.Id,
            Status_Program_Selected__c = DateTime.now()
        );
        this.clonedAppItemTypes = new List<ClonedApplicationItemTypeWrapper>();
        for(Cloned_Application_Item_Type__mdt mdt: [SELECT MasterLabel, Specific_Name__c FROM Cloned_Application_Item_Type__mdt ORDER BY MasterLabel])
        {
            this.clonedAppItemTypes.add(new ClonedApplicationItemTypeWrapper(mdt));
        }
    }
    /**
     * Saves both application records. The old record is updated with a new status, a new application record is inserted
     * @return PageReference, redirects to the new application record, or stays on the current page if there is an error
     */
    public PageReference saveNewApp() {
        try
        {
            contactTriggerHandler.bypassCSP = true;
            Database.upsert(new List<Application__c>{this.oldApp, this.newApp});
            this.student.Active_Application__c = this.newApp.Id;
            Database.update(this.student);
            return new PageReference('/' + newApp.Id);
        }
        catch(Exception e)
        {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occured when saving', e.getMessage()));
            system.debug(e.getMessage());
        }
        return null;
    }

    /**
     * Wrapper class for Cloned_Application_Item_Type__mdt, since most users will not have permissions to view these objects.
     */
    public class ClonedApplicationItemTypeWrapper
    {
        /**
         * The record type that is to be cloned
         */
        public string recordTypeName {get;set;}
        /**
         * The application item name that is to be cloned, if it is null then all application items of this record type will be cloned to the new application
         */
        public string appItemName {get;set;}

        public ClonedApplicationItemTypeWrapper(Cloned_Application_Item_Type__mdt mdt) {
            recordTypeName = mdt.MasterLabel;
            appItemName = mdt.Specific_Name__c;
        }
    }
}