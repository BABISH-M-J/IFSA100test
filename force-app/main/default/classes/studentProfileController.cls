/**
 * @description Controller for the my profile page on the student portal.
 * @author Cameron Ames
 */
public without sharing class studentProfileController extends studentBaseController
{
	/*
	public studentProfileViewModel viewModel {get;set;}

	public studentProfileController()
	{
		super();
		this.viewModel = this.populateViewModel(new studentProfileViewModel());
	}
	
	public override PageReference validateAccess()
	{
		if(this.viewModel.isLockDownActive)
		{
			return new PageReference('/SP_Home');
		}
		return null;
	}

	private studentProfileViewModel populateViewModel(studentProfileViewModel viewModel)
	{
		viewModel = (studentProfileViewModel) super.populateViewModel(viewModel);
		viewModel.mailingStreet = this.studentContact.MailingStreet;
		viewModel.mailingCity = this.studentContact.MailingCity;
		viewModel.mailingState = this.studentContact.MailingState;
		viewModel.mailingZip = this.studentContact.MailingPostalCode;
		viewModel.mailingCountry = this.studentContact.MailingCountry;
		viewModel.otherStreet = this.studentContact.OtherStreet;
		viewModel.otherCity = this.studentContact.otherCity;
		viewModel.otherState = this.studentContact.otherState;
		viewModel.otherZip = this.studentContact.otherPostalCode;
		viewModel.otherCountry = this.studentContact.otherCountry;
		viewModel.billingStreet = this.studentAccount.billingStreet;
		viewModel.billingCity = this.studentAccount.billingCity;
		viewModel.billingState = this.studentAccount.BillingState;
		viewModel.billingZip = this.studentAccount.BillingPostalCode;
		viewModel.billingCountry = this.studentAccount.BillingCountry;

		viewModel.accountId = this.studentAccount.Id;
		viewModel.contactId = this.studentContact.Id;

		return viewModel;
	}
	*/
}