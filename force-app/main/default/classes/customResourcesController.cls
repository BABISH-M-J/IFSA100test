/**
 * Controller for the resource page of the custom portal
 * THE CUSTOM PORTAL IS POWERD BY THE CATALOG STUDENT PORTAL SO THAT EFFORTS ARE NOT DUPLICATED AS OF SUMMER 2020
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class customResourcesController extends customBaseController
{
	public customResourcesViewModel viewModel {get;set;}
	private ifsaApplicationWrapper application {get;set;}
	private ifsaProgramTermWrapper programTerm {get;set;}

	public customResourcesController()
	{
		super();
		
		this.application = new ifsaApplicationWrapper(this.student.getActiveApplicationId());
		this.programTerm = new ifsaProgramTermWrapper(this.application.getProgramTermId());
		
		this.viewModel = this.populateViewModel(new customResourcesViewModel());
	}
	
	public customResourcesViewModel populateViewModel(customResourcesViewModel viewModel)
	{
		viewModel = (customResourcesViewModel) super.populateCustomBaseViewModel(viewModel);
		Program_Term__c pt = [SELECT Program__r.Display_Account_Tab__c FROM Program_Term__c WHERE Id =: this.application.getProgramTermId()].get(0);
		viewModel.displayAccountTab = pt.Program__r.Display_Account_Tab__c == 'Yes';
		viewModel.attachments = apexQueryUtility.selectAllFrom('Attachment', 'ParentId IN (\'' + this.student.getContactId() + '\', \'' + this.student.getActiveApplicationId() + '\', \'' + this.application.getProgramTermId() + '\', \'' + this.programTerm.getCountryId() + '\', \'' + this.programTerm.getProgramId() + '\', \'' + this.programTerm.getTermId() + '\')');
		viewModel.customResourceInstructions = [SELECT Custom_Portal_Resources_Text__c FROM Program_Term__c WHERE Id =: this.application.getProgramTermId()].get(0).Custom_Portal_Resources_Text__c;

		return viewModel;
	}
	/**
	 * @description Authorization function required to be implemented on every page. This action is called upon page load.
	 * @return PageReference
	 */
	public override PageReference validateAccess()
	{
		//If the portal has been locked down redirect to message screen
		if(this.viewModel.isLockDownActive)
		{
			return new PageReference('/advisorportal/CP_PortalMessage');
		}
		//otherwise the user has access to the page
		return null;
	}
}