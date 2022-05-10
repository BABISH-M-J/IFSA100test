/**
 * Viewmodel class used with advisorStudentController
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public without sharing class advisorStudentsViewModel extends advisorBaseViewModel
{
	/**
	 * Available Years
	 */
	public List<String> AvailableYears {get;set;}
	/**
	 * Available Terms
	 */
	public List<String> AvailableTerms {get;set;}
	/**
	 * Available Countries
	 */
	public List<String> AvailableCountries {get;set;}
	/**
	 * Available Statuses
	 */
	public List<String> AvailableStatuses {get;set;}
	/**
	 * Selected Year
	 */
	public String selectedYear {get;set;}
	/**
	 * Selected Term
	 */
	public String selectedTerm {get;set;}
	/**
	 * Selected Country
	 */
	public String selectedCountry {get;set;}
	/**
	 * Selected Status
	 */
	public String selectedStatus {get;set;}
}