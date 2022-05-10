public without sharing class opportunityCityTriggerHandler extends BaseTriggerHandler
{
    final List<Opportunity_City__c> newRecords;
    final List<Opportunity_City__c> oldRecords;
    final Map<Id, Opportunity_City__c> newMap;
    final Map<Id, Opportunity_City__c> oldMap;

    public opportunityCityTriggerHandler() 
    {
        newRecords = (List<Opportunity_City__c>) Trigger.new;
        oldRecords = (List<Opportunity_City__c>) Trigger.old;
        newMap = (Map<Id, Opportunity_City__c>) Trigger.newMap;
        oldMap = (Map<Id, Opportunity_City__c>) Trigger.oldMap;
    }

    public override void afterInsert()
    {
        opportunityService.updateOpportunityCities(newRecords);
    }

    public override void afterUpdate()
    {
        opportunityService.updateOpportunityCities(newRecords);
    }

    public override void afterDelete()
    {
        opportunityService.updateOpportunityCities(oldRecords);
    }

    public override void afterUndelete()
    {
        opportunityService.updateOpportunityCities(newRecords);
    }
}