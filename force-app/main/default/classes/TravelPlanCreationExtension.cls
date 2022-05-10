/**
 * @description Controller extension for the internal page to create travel plans for students
 * @author Brock Barlow
 */
public with sharing class TravelPlanCreationExtension {

	private final sObject mysObject;
    public String travelPlanId {get;set;}
    public String appId {get;set;}
    public studentApplyItemDetailsViewModel viewModel {get;set;}

    /**
    * @description Gets the travel plan related to the student's application
    */
    public TravelPlanCreationExtension(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
        this.appId = mysObject.Id;
        this.travelPlanId = [SELECT Id FROM Application_Item__c WHERE Application__c =: this.mysObject.Id AND RecordType.DeveloperName = 'Travel_Plan'].get(0).Id;
        this.viewModel = portalRemotingMethods.getApplicationItemDetails(this.travelPlanId);
    }
    /**
    * @description Submit independent travel plan
    * @return Success of the operation
    */
    @RemoteAction
    public static Boolean submitIndependentTravel(String info, List<Map<String,String>> data, Id applicationItemId)
    {
        //return portalRemotingMethods.submitIndependentTravel(name, arrivalPlanId, info, data, applicationItemId);
        return portalRemotingMethods.submitIndependentTravel(info, data, applicationItemId);
    }
    /**
    * @description Gets the travel plan application item
    * @return application item view model
    */
    @RemoteAction
    public static studentApplyItemDetailsViewModel getApplicationItemDetails(String Id)
    {
        return portalRemotingMethods.getApplicationItemDetails(Id);
    }
}