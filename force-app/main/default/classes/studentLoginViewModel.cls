/**
* @description Viewmodel for SP_Login page
* @author Cameron Ames
*/
public without sharing class studentLoginViewModel extends communityLoginViewModel
{
    public String homeInstitutionName {get;set;}
    public Id homeInstitutionId {get;set;}
    public String major {get;set;}
    public String OtherMajor {get;set;}
    public List<model_picklist> majorOptions {get;set;}
    public Boolean courses {get;set;}
    public String coursesDescription {get;set;}
    public List<Home_Institution__c> homeInstitutionOptions {get;set;}
    public Boolean countryOfInterest {get;set;} // Checkbox for students who know what country they would like to travel to
    public List<Country__c> countryOptions {get;set;} // List of available countries
    public Country__c desiredCountry {get;set;} // Final value for which country they want to travel to
    public Country__c desiredCountry2 {get;set;} // Final value for which country they want to travel to
    public Country__c desiredCountry3 {get;set;} // Final value for which country they want to travel to
    public List<Term__c> semesterOptions {get;set;} // List of semesters for semester filter
    public List<Program_Term__c> programTerms {get;set;} // List of Program Terms based on their search criteria
    public Program_Term__c programOfInterest {get;set;} // Final value for which program they want to go on
    public Program__c program {get;set;}
    public Id contactId {get;set;} // If user is coming to SP from CHART this will not be empty
    public Map<String, String> errorMessages {get;set;}
    public Boolean gwUser {get;set;}
    public Boolean chUser {get;set;}
    public Boolean hasApps {get;set;}
    public Id programId {get;set;}
    public Boolean isLoggedIn {get;set;}
    public Id userId {get;set;}
    public String countryCode {get;set;}
    
    public studentLoginViewModel()
    {
        countryOptions = new List<Country__c>();
        semesterOptions = new List<Term__c>();
        errorMessages = new Map<String,String>();  //Custom_Community_Setting.SP_Login_GenericRegError.md-meta
        for(Custom_Community_Setting__mdt message: [SELECT DeveloperName, MasterLabel, Content__c FROM Custom_Community_Setting__mdt WHERE DeveloperName LIKE 'SP_Login_%Error'])
        {
            errorMessages.put(message.DeveloperName, message.Content__c);
        }
        gwUser = false;
        homeInstitutionOptions = [SELECT Id, Name FROM Home_Institution__c];
        userType = 'Student';
        isLoggedIn = false;
        hasApps = false;
    }
}