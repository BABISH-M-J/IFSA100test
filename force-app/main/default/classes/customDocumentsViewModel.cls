/**
 * View model class for the my documents page of the custom portal.
 * TODO: Break out the skin data components of the customLoginViewModel, then use that new class here.
 * THE CUSTOM PORTAL IS POWERD BY THE CATALOG STUDENT PORTAL SO THAT EFFORTS ARE NOT DUPLICATED AS OF SUMMER 2020.
 * @author Cameron Ames
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public with sharing class customDocumentsViewModel extends customBaseViewModel
{
	/**
	 * @description The Id of the application being exposed on the page
	 */
	public Id applicationId {get;set;}

	/**
	 * @description The name of the application.
	 */
	public String applicationName {get;set;}

	/**
	 * @description The list of application items appearing on the page.
	 * @see studentApplyItemViewModel
	 */
	public List<studentApplyItemViewModel> appItems {get;set;}
    /**
	 * @description Page name to return to after uploading a document or photo
	 */
    public String pageSource {get;set;}
    public String portalSource {get;set;}
    public String customIntroduction {get;set;}
    public String paName {get;set;}
    public String paEmailAddress {get;set;}
}