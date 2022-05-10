/**
 * Controller extension for Housing_Assignment__c to display a google map of the housing assignment's location
 * @author Brock Barlow
 */
public with sharing class housingAssignmentControllerExtension 
{	
    /**
     * Exposes the iFrame url to the VF page
     */
    public String iFrameUrl {get; private set;}
    private Housing_Assignment__c housingAssignment {get;set;}
    /**
     * Constructor, initializes controller from Standard Controller
     * @param controller ApexPages.StandardController
     */
	public housingAssignmentControllerExtension(ApexPages.StandardController controller) {
		housingAssignment = [SELECT Id, Name, Street_1__c, Street_2__c, Locality__c, Dependent_Locality__c, Zip_Code__c, Country__r.Country_Code__c FROM Housing_Assignment__c WHERE Id =: controller.getId()];
		formatGoogleMapsAddress();  
	}	

    /**
     * Encodes address into google maps api url
     */
    public void formatGoogleMapsAddress()
    {
		String address = this.housingAssignment.Street_1__c;
		if(this.housingAssignment.Street_2__c != null)
    	{
    		address += ' ' + this.housingAssignment.Street_2__c;            
    	}
        if(this.housingAssignment.Locality__c != null)
        {
            address += ' ' + this.housingAssignment.Locality__c;    
        }
        if(this.housingAssignment.Dependent_Locality__c != null)
        {
            address += ' ' +  this.housingAssignment.Dependent_Locality__c;
        }    	    	
        if(this.housingAssignment.Zip_Code__c != null)
        {
            address += ' ' + this.housingAssignment.Zip_Code__c;
        }        
        if(this.housingAssignment.Country__r.Country_Code__c != null)
        {
            address += ' ' + this.housingAssignment.Country__r.Country_Code__c;    
        }
        
            	
    	this.iFrameUrl = 'https://www.google.com/maps/embed/v1/place?q=' + EncodingUtil.urlEncode(address, 'UTF-8') +  '&zoom=16&key=AIzaSyDB6ADjtqA6lmzAnMNKHi7I-3eTuFsKcYI';    		
    } 
}