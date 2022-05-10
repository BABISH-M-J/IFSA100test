/**
 * The view model class for the advisor profile
 * @author Cameron Ames
 */
// ApexDoc updated 1/22/2021 Brock Barlow
public without sharing class advisorProfileViewModel extends advisorBaseViewModel
{
	/**
	 * The name of the home institution
	 */
    public String HomeInstitutionName {get;set;}
	
	/**
	 * The advisor type.
	 */
    public String AdvisorType {get;set;}
	
	/**
	 * The advisor's title.
	 */
    public String AdvisorTitle {get;set;}
	
	/**
	 * The name of the advisor's office.
	 */
    public String AdvisorOfficeName {get;set;}
	
	/**
	 * The countries which this advisor approves.
	 */
    public String AdvisorApprovalCountries {get;set;}
	
	/**
	 * The advisor's office address.
	 */
    public String AdvisorMailingStreet {get;set;}
	
	/**
	 * The advisor's office City.
	 */
    public String AdvisorMailingCity {get;set;}
	
	/**
	 * The advisor's office State.
	 */
    public String AdvisorMailingState {get;set;}
	
	/**
	 * The advisor's office ZIP.
	 */
    public String AdvisorMailingPostalCode {get;set;}
	
	/**
	 * The advisors country.
	 */
    public String AdvisorMailingCountry {get;set;}
	
	/**
	 * The advisor's office phone number.
	 */
    public String AdvisorPhone {get;set;}
	
	/**
	 * The advisor's cell.
	 */
    public String AdvisorMobilePhone {get;set;}
	
	/**
	 * The advisor's fax.
	 */
    public String AdvisorFax {get;set;}
	
	/**
	 * The advisor's email address.
	 */
    public String AdvisorEmail {get;set;}
	
	/**
	 * Indicates if the advisor receives alerts.
	 */
    public Boolean AdvisorReceiveAlerts {get;set;}

    /**
	 * Indicates if the advisor receives approval notifications.
	 */
    public Boolean AdvisorReceiveApprovals {get;set;}
	
	/**
	 * Indicates if the advisor receives our newsletter.
	 */
    public Boolean AdvisorReceiveNewsletter {get;set;}
}