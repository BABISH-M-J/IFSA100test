/**
 * @description Viewmodel class for <<assignHousingController>> and VF page
 * @author Brock Barlow
*/
// ApexDoc updated 1/25/2021 Brock Barlow
public with sharing class assignHousingViewModel extends portalBaseViewModel
{
    /**
     * Application record that is having housing assigned
     */
    public Application__c application {get;set;}        
    /**
     * Housing assignment name
     */
    public String housingAssignment {get;set;}
    /**
     * Has housing preferences (has Housing_Preference__c records, set to true, otherwise false)
     */
    public Boolean hasPrefs {get;set;}
    /**
     * Id of the country
     */
    public Id selectedCountry {get;set;}
    /**
     * Name of the selected city
     */
    public String selectedCity {get;set;}
    /**
     * List<Housing_Preference__c> The student's preferences
     */
    public List<Housing_Preference__c> housingPreferences {get;set;}
    /**
     * List<String> The names of the avaliable housing options
     */
    public List<String> housingOptions {get;set;}
    /**
     * List<String> The names of countries
     */
    public List<String> countries {get;set;}
    /**
     * List<String> The names of cities
     */
    public List<String> cities {get;set;}
    /**
     * List<Id> The Id field of housing option records
     */
    public List<Id> housingIds {get;set;}

    /**
     * Constructor, initializes lists
     */
    public assignHousingViewModel()
    {
    	housingPreferences = new List<Housing_Preference__c>();
    	housingOptions = new List<String>();
    	cities = new List<String>();
    }
}