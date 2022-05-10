/**
 * Trigger Handler for Application, executes business logic in <<applicationService>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public with sharing class applicationTriggerHandler 
{
    //added by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
	public static boolean firstRun = true;
    //added by PowerFluence req_dt:03/29/2022 ref email from Clayton ends
	@TestVisible static Boolean bypassTrigger = false;

	final List<Application__c> newRecords;
	final List<Application__c> oldRecords;
	final Map<Id, Application__c> oldMap;
	final Map<Id, Application__c> newMap;
    /**
     * Constuctor, initializes applicationTriggerHandler instance
     * @param newRecords
     * @param oldRecods
     * @param newMap
     * @param oldMap
     */
	public applicationTriggerHandler(List<Application__c> newRecords, List<Application__c> oldRecords, Map<Id, Application__c> oldMap, Map<Id, Application__c> newMap)
	{
		if(bypassTrigger) return;
        this.newRecords = newRecords;
		this.oldRecords = oldRecords;
		this.oldMap = oldMap;
		this.newMap = newMap;
	}
    /**
     * Before Insert
     */
	public void beforeInsert()
	{
		if(bypassTrigger) return;
		//Do something with applicationService
        applicationService.updateHomeInstitutionAdvisorSP(newRecords);   
        applicationService.validatePrintibleSatement(newRecords, oldMap, applicationService.triggerType.isInsert);
		applicationService.setApplicationDefaults(newRecords, applicationService.triggerType.isBefore);
        applicationService.updateApplicationName(newRecords);
        applicationService.updateApplicationOwner(oldMap, newRecords, applicationService.triggerType.isBefore);
        applicationService.setStatusTimeStampsNew(newRecords, null, null);
	}
    /**
     * Before Update
     */
    public void beforeUpdate()
    {
        if (bypassTrigger) return;
        //Do something with applicationService
        applicationService.updateHomeInstitutionAdvisorSP(newRecords);
        applicationService.validatePrintibleSatement(newRecords, oldMap, applicationService.triggerType.isUpdate);
        applicationService.setStatusTimeStampsUpdate(newMap, oldMap);
        applicationService.updateApplicationName(newMap, oldMap);
        applicationService.updateApplicationOwner(oldMap, newRecords, applicationService.triggerType.isBefore);
    }
    /**
     * After Insert
     */
	public void afterInsert()
    {
        if (bypassTrigger) return;
        //Do something with applicationService
        //Test failing, feature not used - Brock Barlow
        //applicationService.arrivalPlanCount(oldRecords, newRecords, applicationService.triggerType.isInsert);        
        //applicationService.verifyContactSupportPersonnelRecords(newRecords, oldMap, newMap, applicationService.triggerType.isInsert);
        applicationService.updateApplicationOwner(oldMap, newRecords, applicationService.triggerType.isAfter);
        applicationService.checkProgramAuthorizations(newRecords);
        applicationService.setApplicationDefaults(newRecords, applicationService.triggerType.isAfter);
        applicationService.populateApplicationItems(null, newRecords);
    }
    /**
     * Afer Update
     */
    public void afterUpdate()
    {
        if (bypassTrigger) return;
        //Do something with applicationService
        applicationService.updateAppItemsPhase(newMap, oldMap, newRecords);
        //Test failing, feature not used - Brock Barlow
        //applicationService.arrivalPlanCount(oldRecords, newRecords, applicationService.triggerType.isUpdate);
        applicationService.verifyContactSupportPersonnelRecords(newRecords, oldMap, newMap, applicationService.triggerType.isUpdate);
        applicationService.updateApplicationOwner(oldMap, newRecords, applicationService.triggerType.isAfter);
        //applicationService.gradesVerified(newMap, oldMap);
        applicationService.divertOtherApps(newMap, oldMap);
        applicationService.approveCourseRegistrations(newMap);
        applicationService.populateApplicationItems(oldMap, newRecords);
        /* REENABLE NEXT LINE FOR DEPLOYMENT ON 8/20/2020 */
        //applicationService.sendCRFApprovalEmail(oldMap, newMap); // !IMPORTANT This needs follow approveCourseResgistrations function call
    }
    /**
     * After Delete
     */
    public void afterDelete()
    {
    	if (bypassTrigger) return;
        //Test failing, feature not used - Brock Barlow
    	//applicationService.arrivalPlanCount(oldRecords, newRecords, applicationService.triggerType.isDelete);
    }
}