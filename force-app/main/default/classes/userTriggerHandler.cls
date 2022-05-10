public with sharing class userTriggerHandler  extends BaseTriggerHandler 
{
    @TestVisible static Boolean bypassAfterInsert = false;
    
    final List<User> newRecords;
    final List<User> oldRecords;
    final Map<Id, User> oldMap;
    final Map<Id, User> newMap;

    public userTriggerHandler()
    {
        this.newRecords = (List<User>) Trigger.new;
        this.oldRecords = (List<User>) Trigger.old;
        this.oldMap = (Map<Id, User>) Trigger.oldMap;
        this.newMap = (Map<Id, User>) Trigger.newMap;
    }
    
    // IF UPDATING SYSTEM OBJECT RECORDS THIS MUST BE DONE ASYNC
    public override void beforeInsert()
    {
        
    }
    // IF UPDATING SYSTEM OBJECT RECORDS THIS MUST BE DONE ASYNC
    public override void beforeUpdate()
    {
        userService.deactivateUsers(new Set<userService.imOperations>{userService.imOperations.createCSVAndDeleteIM, userService.imOperations.deleteSP}, newMap, oldMap);
    }
    // IF UPDATING SYSTEM OBJECT RECORDS THIS MUST BE DONE ASYNC
    public override void afterInsert()
    {
        userService.afterInsertIfsaMember(newRecords, bypassAfterInsert);
        userService.setUserCreatedDateOnContact(newRecords);
        Id jobId = system.enqueueJob(new userService.ifsaFormstackUtility(newMap));
        }
    // IF UPDATING SYSTEM OBJECT RECORDS THIS MUST BE DONE ASYNC
    public override void afterUpdate()
    {
        //creating updating IFSA Team member on  User update
        system.debug('usernewRecords='+newRecords);
        userService.afterUpdateIfsaMember(JSON.serialize(newRecords), JSON.serialize(oldMap));
    }
}