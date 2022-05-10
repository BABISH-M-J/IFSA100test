public with sharing class portalMessageController extends portalBaseController {

	public portalMessageViewModel viewModel {get;set;}

	public portalMessageController() {
		// String portalName = ApexPages.currentPage().getParameters().get('portalName');
		// Portal_System_Message__mdt portalMessage = [SELECT MasterLabel, Affected_Portal__c, Is_Lockdown_Active__c, Message__c, Message_End_Date__c, Message_Start_Date__c FROM Portal_System_Message__mdt WHERE Affected_Portal__c =: portalName  AND Message_Start_Date__c <=: Date.today() AND Message_End_Date__c >=: Date.today()].get(0);
		super();

		this.viewModel = this.populateMessageViewModel(new portalMessageViewModel());
		//this.viewModel.systemMessage = portalMessage.Message__c;
		//this.viewModel.isLockDownActive = portalMessage.Is_Lockdown_Active__c;
		
	}

	private portalMessageViewModel populateMessageViewModel(portalMessageViewModel viewModel)
	{
		viewModel = (portalMessageViewModel) super.populatePortalBaseViewModel(viewModel);

		return viewModel;
	}
}