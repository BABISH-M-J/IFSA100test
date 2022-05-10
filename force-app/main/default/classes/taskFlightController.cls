/**
 * @description Controller for the FlightsListView page
 * @author Brock Barlow
 */
public class taskFlightController {
    private ApexPages.StandardController controller {get;set;}
    public Task t {get;set;}    
    public List<Flight__c> flights {get;set;}
    
    /**
    * @description Get the flights related to the travel plan the task is related to
    */
    public taskFlightController(ApexPages.StandardController controller) {
        this.controller = controller;        
        try
        {
            this.t = (Task)controller.getRecord();
            
            Task record = [SELECT Id, Subject, WhatId FROM Task WHERE Id =: t.Id];        
            this.flights = apexQueryUtility.selectAllFrom('Flight__c', 'Travel_Plan__c = \'' + record.WhatId + '\'');
        }
        catch (Exception e)
        {
            this.flights = new List<Flight__c>();            
        }
    }
}