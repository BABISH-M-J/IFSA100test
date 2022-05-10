/**
* @description Viewmodel for SP_Apply page
* @author Cameron Ames
*/
public without sharing class studentApplyViewModel extends studentBaseViewModel
{
    // public String advisorFirstName {get;set;}
    // public String advisorLastName {get;set;}
    // public String advisorEmail {get;set;}
    // public String advisorPhone {get;set;}
    // public String advisorPhotoUrl {get;set;}
    // public String advisorCalendlyLink {get;set;}
	public Boolean completionNotificationReceived {get;set;}
	public Integer appItemsIncomplete {get;set;}
	public Id applicationId {get;set;}
	public String acceptanceConditions {get;set;}
	public Boolean conditionsMet {get;set;}
	public String waitlistMessage {get; set;}

	public String applicationName {get;set;}
	// public String programName {get;set;}
	public String countryName {get;set;}
	
	public String firstName {get; set;}
    public String programTermName {get; set;}
	
	public String programUrl {get;set;}
    public String pageSource {get;set;}

	public List<studentApplyItemViewModel> appItems {get;set;}
	public List<Schema.PicklistEntry> aidTypes {get; set;}
	public List<Country__c> phoneCountries {get;set;}

	public Boolean isUnauthorizedProgram {get;set;}
    public String abroadPhoneNumber {get;set;}
	public String abroadPhoneNumberCountry {get;set;}
	public String programId {get;set;}
	public String programTermId {get;set;}
	public String programOptionId {get;set;}
	public List<Custom_Community_Setting__mdt> portalSettings { get; set; }
	public Boolean profileCompleted { get; set; }
	public Integer totalAppItemCount {get; set;}
	public Boolean showAccountTab {get; set;}
	public String customWelcomeText {get;set;}
	public String customResourcesText {get;set;}
	public String customLogoId {get;set;}


	public studentApplyViewModel()
	{
		this.portalSettings = [SELECT Label, DeveloperName, Content__c FROM Custom_Community_Setting__mdt WHERE DeveloperName LIKE 'SP_%'];
	}
}