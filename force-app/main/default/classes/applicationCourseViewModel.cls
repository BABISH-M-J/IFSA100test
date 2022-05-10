/**
 * Viewmodel class used with internal course registrations VF pages. Links Course Registrations with their application
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public with sharing class applicationCourseViewModel {
     /**
      * An Application__c record
      */
     public Application__c application {get;set;}
     /**
      * The transcript recipients name
      */
     public String transcriptRecipientName {get;set;}
     /**
      * The transcript recipients contact id
      */
     public String transcriptRecipientId {get;set;}
     /**
      * The transcript recipients account id
      */
     public String transcriptRecipientAccountId {get;set;}
     /**
      * The transcript recipients account name
      */
     public String transcriptRecipientAccountName {get;set;}
     /**
      * The courses a student has told us they are taking while on their program
      */
     public List<studentOnSiteCourseRegViewModel> courseRegistrations {get;set;}
     /**
      * Constructor, initialized courseRegistrations list
      */
     public applicationCourseViewModel()
     {
          courseRegistrations = new List<studentOnSiteCourseRegViewModel>();
     }
}