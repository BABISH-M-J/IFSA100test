/**
 * Controller class for VisualForce email template used when student's course registrations have been approved by IFSA stafff
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public without sharing class approvedCRComponentController {
    public String onSiteAppId {get; set; }
    /**
     * Contstructor, nothing happens here
     */
	public approvedCRComponentController() {
        
	}
    /**
     * Gets the course registrations that have been approved
     */
    public List<Course_Registration__c> getCourses {
        get {
            return [SELECT Course_Code__c, Course_Title__c, Status__c, US_Semester_Credit_Hours__c, Host_Institution__r.Name FROM Course_Registration__c WHERE Status__c = 'Approved' AND Application__c =: onSiteAppId];
        }
        set;
    }
}