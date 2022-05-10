public without sharing class opportunityCountryTriggerHandler extends BaseTriggerHandler
{
    final List<Opportunity_Country__c> newRecords;
    final List<Opportunity_Country__c> oldRecords;
    final Map<Id, Opportunity_Country__c> newMap;
    final Map<Id, Opportunity_Country__c> oldMap;

    public opportunityCountryTriggerHandler() 
    {
        newRecords = (List<Opportunity_Country__c>) Trigger.new;
        oldRecords = (List<Opportunity_Country__c>) Trigger.old;
        newMap = (Map<Id, Opportunity_Country__c>) Trigger.newMap;
        oldMap = (Map<Id, Opportunity_Country__c>) Trigger.oldMap;
    }

    public override void afterInsert()
    {
        opportunityService.updateOpportunityCountries(newRecords);
    }

    public override void afterUpdate()
    {
        opportunityService.updateOpportunityCountries(newRecords);
    }

    public override void afterDelete()
    {
        opportunityService.updateOpportunityCountries(oldRecords);
    }

    public override void afterUndelete()
    {
        opportunityService.updateOpportunityCountries(newRecords);
    }
}