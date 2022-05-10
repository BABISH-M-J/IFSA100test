/** **********************************************************
    Name        : PopulateNetValueTotalBatch
    Function    : This batch updates Cash Entry Line Item Net Value to Total Paid Amount field of application.
    Author      : Nida, Salesforce Developer, Astrea IT Services Pvt. Ltd.                
    Created On  : 4-Nov-16
    Modified On : 4-Nov-16
*********************************************************** */

global class PopulateNetValueTotalBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, Total_Paid_Amount__c FROM Application__c' );
    }
    
    global void execute(Database.BatchableContext BC, List<Application__c> appList){
        
        Map<String, Double> netValMap = new Map<String, Double>();
        List<Application__c> applList = new List<Application__c>();
        
        for(AggregateResult ar : [Select Application__c app, sum(c2g__NetValue__c) totvalue from c2g__codaCashEntryLineItem__c 
                            where Application__c IN:appList Group By Application__c]) {
       
           netValMap.put(String.ValueOf(ar.get('app')),Double.ValueOf(ar.get('totvalue')));
       } 
        
        for( Application__c prj : appList ) {
            prj.Total_Paid_Amount__c = netValMap.containsKey(prj.id) ? netValMap.get(prj.id) : 0;
            applList.add(prj);
        } 
        
        update applList; 
        system.debug('============'+applList.size()); 
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
}