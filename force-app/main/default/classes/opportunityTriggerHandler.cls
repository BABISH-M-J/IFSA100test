/**
 * @description Trigger Handler class for the Opportunity object. This class links the opportunityTrigger to opportunityService.
 * @author Brock Barlow
 */
public without sharing class opportunityTriggerHandler extends BaseTriggerHandler
{
    final List<Opportunity> newRecords;
    final List<Opportunity> oldRecords;
    final Map<Id, Opportunity> newMap;
    final Map<Id, Opportunity> oldMap;

    public opportunityTriggerHandler() 
    {
        newRecords = (List<Opportunity>) Trigger.new;
        oldRecords = (List<Opportunity>) Trigger.old;
        newMap = (Map<Id, Opportunity>) Trigger.newMap;
        oldMap = (Map<Id, Opportunity>) Trigger.oldMap;
    }

    public override void beforeInsert()
    {
        opportunityService.updateAmmount(newRecords);
    }

    public override void beforeUpdate()
    {
        opportunityService.updateAmmount(newRecords);
    }

    public override void afterInsert()
    {
        opportunityService.updateTeamMembers(newMap);
        opportunityService.createOpportunityJunctionRecords(newMap, new Map<Id, Opportunity>());
    }

    public override void afterUpdate()
    {
        opportunityService.updateTeamMembers(newMap);
        opportunityService.checkIfOpportunityIsWon(newRecords, oldMap);
        opportunityService.createOpportunityJunctionRecords(newMap, oldMap);
    }
}