/**
* @description Controller for SP_Home page
* @author Cameron Ames
*/
public without sharing class studentHomeController extends studentBaseController
{
	public studentHomeViewModel viewModel {get;set;}
	private Program_Term__c programTerm {get;set;}
  	private Program_Term__c parentProgramTerm {get;set;}
	private User programAdvisor {get;set;}

	public studentHomeController()
	{
		super();
		
		if(this.application.Program_Term__c != null)
        {
            this.programTerm = [SELECT Id, Name, OwnerId, Parent_Program_Term__c, Program__r.Name, Program__r.Webpage_Url__c, Program__r.Host_Institution__r.Country__r.Name FROM Program_Term__c WHERE ID =: this.application.Program_Term__c];
            this.programAdvisor = [SELECT Id, FirstName, LastName, Email, Phone, FullPhotoUrl, Calendly_Link__c, PA_Intro_Video__c FROM User WHERE Id =: programTerm.OwnerId];
            try
			{
				this.parentProgramTerm = [SELECT Id, Name, OwnerId, Program__r.Name, Program__r.Webpage_Url__c, Program__r.Host_Institution__r.Country__r.Name FROM Program_Term__c WHERE ID =: this.programTerm.Parent_Program_Term__c];
			}
			catch (QueryException ex) 
			{
				system.debug('Program Term: ' + this.programTerm.Name + ' does not have a program term.');
			}
		}
		this.viewModel = new studentHomeViewModel();
		this.populateViewModel();
	}

	public override PageReference validateAccess()
	{
		if(!this.viewModel.isProgramSelected && !this.viewModel.isLockDownActive)
		{
			return new PageReference('/SP_Select');
		}
		return null;
	}

	public void populateViewModel()
	{
		this.viewModel = (studentHomeViewModel) super.populateViewModel(this.viewModel);
		this.viewModel.advisorEmail = this.programAdvisor.Email;
	    this.viewModel.advisorFirstName = this.programAdvisor.FirstName;
	    this.viewModel.advisorLastName = this.programAdvisor.LastName;
	    this.viewModel.advisorPhone = this.programAdvisor.Phone;
	    this.viewModel.advisorPhotoUrl = this.programAdvisor.FullPhotoUrl;
	    this.viewModel.advisorCalendlylink = this.programAdvisor.Calendly_Link__c;
		this.viewModel.paIntroVideo = this.programAdvisor.PA_Intro_Video__c;
	}
}