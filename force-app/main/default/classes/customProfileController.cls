/**
 * Controller for the my profile page of the custom portal.
 * TODO: Refactor guardians
 * THE CUSTOM PORTAL IS POWERD BY THE CATALOG STUDENT PORTAL SO THAT EFFORTS ARE NOT DUPLICATED AS OF SUMMER 2020
 * @author Cameron Ames
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class customProfileController extends customBaseController
{
	/**
	 * @description the page's view model class
	 */
	public customProfileViewModel viewModel {get;set;}

	/**
	 * @description The application object
	 */
	private ifsaApplicationWrapper application {get;set;}
	
	/**
	 * @description The student's guardians
	 */
	private List<Contact> guardians {get;set;}

	/**
	 * @description Constructor function.
	 */
	public customProfileController()
	{
		super();

		this.application = new ifsaApplicationWrapper(this.student.getActiveApplicationId());
		this.guardians = apexQueryUtility.selectAllFrom('Contact', 'Student__c = \'' + this.student.getContact().Id + '\'');

		this.viewModel = this.populateViewModel(new customProfileViewModel());
		this.viewModel = this.student.populateViewModel(this.viewModel);
	}
	
	/**
	 * @description Takes a view model and populates it with data that can be provided by the application item.
	 * @param viewModel A pre-existing view model instance.
	 * @return The same view model instance, populated with application item data.
	 */
	private customProfileViewModel populateViewModel(customProfileViewModel viewModel)
	{
		viewModel = (customProfileViewModel) super.populateCustomBaseViewModel(viewModel);
		Program_Term__c pt = [SELECT Program__r.Display_Account_Tab__c FROM Program_Term__c WHERE Id =: this.application.getProgramTermId()].get(0);
		viewModel.displayAccountTab = pt.Program__r.Display_Account_Tab__c == 'Yes';
		viewModel.StudentCitizenCountry = this.student.getContact().Non_US_Citizenship__c;
		viewModel.citizenshipOptions = apexConversionUtility.getPicklistSelectValues(Contact.Citizenship__c);
		viewModel.countryOptions = apexConversionUtility.getPicklistSelectValues(Contact.Non_Us_Citizenship__c);
		viewModel.sexOptions = apexConversionUtility.getPicklistSelectValues(Contact.Sex__c);
		viewModel.photo = new Attachment();
		
		//Needs broken out into its own method on a guardian wrapper
		if(this.guardians.size() > 0)
		{
			viewModel.GuardianEmail = this.guardians.get(0).Email;
			viewModel.GuardianFirstName = this.guardians.get(0).firstName;
			viewModel.GuardianLastName = this.guardians.get(0).lastName;
			viewModel.GuardianPhone = this.guardians.get(0).phone;
		}
		
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

	/**
	 * @description Takes a user's uploaded photo and makes it their profile picture
	 * @return A page reference (should always be null in this situation...)
	 */
	public PageReference uploadPhoto()
	{
		return null;
	}

	/**
	 * @description Saves any information the student updates on this page.
	 * @return A page reference (should always be null in this situation...)
	 */
	public PageReference save()
	{
		Contact guardian;
		if(this.guardians.size() > 0)
		{
			guardian = this.guardians.get(0);
		}
		else
		{
			guardian = new Contact();
			//ACARSON removed reqcord type query and changed it to mark as Emergency Contact
			//guardian.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Emergency Contact'].Id;
			guardian.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Other').getRecordTypeId();
			guardian.Emergency_Contact__c = true;
			guardian.Student__c = this.student.getContactId();
		}
		guardian.Email = viewModel.GuardianEmail;
		guardian.FirstName = viewModel.GuardianFirstName;
		guardian.LastName = viewModel.GuardianLastName;
		guardian.Phone = viewModel.GuardianPhone;
		
		Database.upsert(guardian);
		return null;
	}
}