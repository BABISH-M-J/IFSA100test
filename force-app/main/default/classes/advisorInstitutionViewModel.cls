/**
 * View model class for the advisor institution page.
 * @author Cameron Ames
 */
public without sharing class advisorInstitutionViewModel extends advisorBaseViewModel
{
	/**
	 * The list of years available for filtering.
	 */
	public Set<String> AvailableYears {get;set;}
	
	/**
	 * The selected year for filtering.
	 */
	public String SelectedYear {get;set;}
	
	/**
	 * The list of terms available for filtering.
	 */
	public Set<String> AvailableTerms {get;set;}
	
	/**
	 * The selected term for filtering.
	 */
	public String SelectedTerm {get;set;}
	
	/**
	 * The list of countries on the country filter.
	 */
	public Set<String> AvailableCountries {get;set;}
	
	/**
	 * The country currently selected for filtering.
	 */
	public String SelectedCountry {get;set;}
	
	/**
	 * The type of advisor.
	 */
	public String AdvisorType {get;set;}
	
	/**
	 * The name of the home institution.
	 */
	public String HomeInstitutionName {get;set;}
	
	/**
	 * The type of home institution.
	 */
	public String HomeInstitutionInstitutionType {get;set;}
	
	/**
	 * The Id of the home institution account.
	 */
	public String HomeInstitutionAccountId {get;set;}

	/**
	 * The Id of the home institution.
	 */
	public String HomeInstitutionId {get;set;}
	
	/**
	 * Indicates the home institution affiliation with IFSa-butler.
	 */
	public String HomeInstitutionAffiliation {get;set;}
	
	/**
	 * Indicates if the home institution is generally direct bill.
	 */
	public Boolean HomeInstitutionDirectBill {get;set;}
	
	/**
	 * Indicates if the home institution generally pays tuition.
	 */
	public Boolean HomeInstitutionPaysTuition {get;set;}
	
	/**
	 * Indicates if the home institution generally pays accomodation fees.
	 */
	public Boolean HomeInstitutionPaysAccomodation {get;set;}
	
	/**
	 * Indicates if the home institution generally pays the program deposit.
	 */
	public Boolean HomeInstitutionPaysAdvancedDeposit {get;set;}
	
	/**
	 * Indicates if the home institution generally pays late withdraw fees.
	 */
	public Boolean HomeInstitutionPaysLateWithdrawFees {get;set;}
	
	/**
	 * Indicates if the home institution generally pays the application fee.
	 */
	public Boolean HomeInstitutionPaysApplicationFee {get;set;}
	
	/**
	 * Indicates if the home institution generally pays supplemental fees.
	 */
	public Boolean HomeInstitutionPaysSupplemental {get;set;}
	
	/**
	 * Indicates if the home institution generally pays summer programs.
	 */
	public Boolean HomeInstitutionPaysSummerPrograms {get;set;}
	
	/**
	 * Indicates if the home institution generally approves summer programs.
	 */
	public Boolean HomeInstitutionApprovesAllSummerPrograms {get;set;}
	
	/**
	 * The general approves all calendar programs for this institution.
	 */
	public Boolean HomeInstitutionApprovesAllCalendarPrograms {get;set;}
	
	/**
	 * The list of advisors for this institution.
	 */
	public List<advisorInstitutionalAdvisorsViewModel> advisorList{get;set;}
}