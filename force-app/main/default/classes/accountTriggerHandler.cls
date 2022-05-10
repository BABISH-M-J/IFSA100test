/**
 * Trigger Handler for Account. Executes business logic in <<accountService>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/22/2021 Brock Barlow
public without sharing class accountTriggerHandler extends BaseTriggerHandler 
{
	public static boolean firstRun = true;
	
	final List<Account> newRecords;
	final List<Account> oldRecords;
	final Map<Id, Account> oldMap;
	final Map<Id, Account> newMap;

	/**
	 * Constructor, populates lists and maps from the Trigger object
	 */
	public accountTriggerHandler()
	{
		this.newRecords = (List<Account>) Trigger.new;
		this.oldRecords = (List<Account>) Trigger.old;
		this.oldMap = (Map<Id, Account>) Trigger.oldMap;
		this.newMap = (Map<Id, Account>) Trigger.newMap;
	}

	/**
	 * Handles Trigger Before Insert
	 */
	public override void beforeInsert()
	{
		//Do something with accountService
		accountService.beforeAccountInsert(newRecords);
		accountService.checkApprovesChangedBefore(null, newRecords);
		accountService.parseBillingAddress(newRecords);
        
	}
	/**
	 * Handles Trigger Before Update
	 */
    public override void beforeUpdate()
    {
		//Do something with accountService
		//accountService.verifyApprovesAll(oldMap, newMap);
		accountService.checkApprovesChangedBefore(oldMap, newRecords);
        accountService.parseBillingAddress(newRecords);
        //added by powerfluence - harshitha req #15 - starts
        if(Test.isRunningTest()){
			// added by powerfluence - ramakrishnan sabdbox error rectification - starts
			// accountService.verifyApprovesAll(oldMap, newMap);
			// added by powerfluence - ramakrishnan sabdbox error rectification - ends
		}
        //added by powerfluence - harshitha req #15 - ends
	}
	
	/**
	 * Handles Trigger After Insert
	 */
	public override void afterInsert()
    {
        //Do something with accountService
		accountService.afterInsertHomeInstitutionAccount(newRecords);
		accountService.generateEmptyPAuthsAndBillingArrangements(newRecords);
		accountService.checkApprovesChangedAfter(null, newRecords);
	}
	
	/**
	 * Handles Trigger After Update
	 */
    public override void afterUpdate()
    {
        //Do something with accountService
		//accountService.checkApprovesChanged(oldMap, newMap);  
		accountService.checkCESearch(oldMap, newMap);
		accountService.checkApprovesChangedAfter(oldMap, newRecords);
    }
}