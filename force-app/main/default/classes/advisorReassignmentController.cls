/**
 * @description Controller to update the home school advisor when a home school advisor leaves
 * @author Brock Barlow
 */
// ApexDoc updated 1/22/2021 Brock Barlow
public without sharing class advisorReassignmentController
{
    /**
	 * @description Container for all data needed on the page. See <<advisorReassignmentViewModel>>	 
	 */
    public advisorReassignmentViewModel viewModel {get;set;}
    /**
	 * @description Constructor function. Retreives the contact record for the leaving advisor and a List<SelectOption> of the advisors that remain
	 * @return void
	 */
    public advisorReassignmentController()
	{
        this.viewModel = new advisorReassignmentViewModel();        
    	this.viewModel.leavingAdvisor = [SELECT Id, Name, RecordTypeId, AccountId, Do_Not_Contact__c FROM Contact WHERE Id =: ApexPages.currentPage().getParameters().get('id')];        
        List<Contact> homeInstitutionAdvisors = [SELECT Id, Name FROM Contact WHERE (AccountId =: this.viewModel.leavingAdvisor.AccountId)
                                                 AND (Id !=: this.viewModel.leavingAdvisor.Id) 
                                                 AND (RecordTypeId =: this.viewModel.leavingAdvisor.RecordTypeId)];
        
        this.viewModel.homeInstitutionAdvisors = new List<SelectOption>();
        for(Contact advisor: homeInstitutionAdvisors)
        {
        	system.debug(advisor);    
            this.viewModel.homeInstitutionAdvisors.add(new SelectOption(advisor.Id, advisor.Name));
        }
    }
    /**
     * @description Save function for the VF page
     * @return PageReference
     */
    public PageReference save()       
    {
        system.debug(this.viewModel.newAdvisor);
        List<Application__c> applications = [SELECT Id, Home_Institution_Advisor__c FROM Application__c WHERE Home_Institution_Advisor__c =: viewModel.leavingAdvisor.Id];
        List<SObject> objectsToUpdate = new List<SObject>();

        this.viewModel.leavingAdvisor.Do_Not_Contact__c = true;
        objectsToUpdate.add(this.viewModel.leavingAdvisor);

        for(Application__c app : applications)
        {
            app.Home_Institution_Advisor__c = this.viewModel.newAdvisor;
            objectsToUpdate.add(app);
        }        
        
        Id jobId = sObjectBatchUpdater.batchUpdate(objectsToUpdate, 20);
        System.debug(LoggingLevel.INFO, jobId);
        PageReference homeInstitutionPage = new PageReference('/' + this.viewModel.leavingAdvisor.AccountId);
        homeInstitutionPage.setRedirect(true);
        return homeInstitutionPage;
    }
}