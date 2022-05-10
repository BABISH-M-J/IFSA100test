/**
 * @description Controller class for the on site page of the student portal
 * @author Cameron Ames
 */
public class studentOnSiteController extends studentBaseController
{
    // /**
    //  * @description The page view model
    //  */
    // public studentOnSiteViewModel viewModel {get;set;}
    // public String iFrameUrl {get;set;}
    
    // /**
    //  * @description The course registration objects.
    //  */
    // private List<ifsaCourseRegistrationWrapper> courseRegistrations {get;set;}
    // private List<Trip__c> trips {get;set;}
    
    // /**
    //  * @description The student's application wrapper. This will eventually be merged in the base controller.
    //  */
    // public ifsaApplicationWrapper studentApplication {get;set;}
    
    // public Housing_Assignment__c housingAssignment {get;set;}        

    // /**
    //  * @description Constructor function.
    //  */
    // public studentOnSiteController()
    // {
    //     super();
        
    //     this.studentApplication = new ifsaApplicationWrapper(this.application);
    //     this.courseRegistrations = this.studentApplication.getCourseRegistrations();    	
	// 	try
	// 	{
	// 		this.housingAssignment = (Housing_Assignment__c) apexQueryUtility.selectAllFrom('Housing_Assignment__c', 'Country__r.Country_Code__c', 'Id = \'' + this.studentApplication.getHousingAssignmentId() + '\'').get(0);	
	// 	}
	// 	catch(Exception e)
	// 	{
	// 		this.housingAssignment = null;
	// 	}							   
        
    //     this.trips = apexQueryUtility.selectAllFrom('Trip__c', 'Trip_Phone_Country__r.Name', 'Application__c=\'' + this.application.Id + '\' AND Status__c != \'Canceled\'');
    //     //system.debug(trips.get(0).Start_Date__c);
    //     this.viewModel = this.populateViewModel(new studentOnSiteViewModel());
        
    //     if(this.housingAssignment != null && !this.housingAssignment.Hide_Map__c)
    //     {
    //     	formatGoogleMapsAddress();        	
    //     }   
    //     else if(this.housingAssignment == null)
    //     {
    //         this.viewModel.street1 = '';
    //     }
    // }

    // /**
    //  * @description Populates a view model with data.
    //  * @param viewModel The view model to fill with data.
    //  * @return The same view model instance with data.
    //  */
    // public studentOnSiteViewModel populateViewModel(studentOnSiteViewModel viewModel)
    // {
    //     viewModel = (studentOnSiteViewModel) super.populateViewModel(viewModel);
    //     viewModel.abroadPhoneNumber = this.studentContact.Address_Abroad_Cell_Phone__c;
    //     viewModel.abroadPhoneNumberCountry = this.studentContact.Abroad_Cell_Phone_Country__c;
    //     viewModel = this.studentApplication.populateViewModel(viewModel);
    //     if(this.housingAssignment != null)
    //     {
    //         viewModel = populateHousingAssignment(viewModel);
    //     }
        
    //     for(ifsaCourseRegistrationWrapper courseRegistration : this.courseRegistrations)
    //     {
    //         viewModel.courses.add(courseRegistration.populateViewModel(new studentOnSiteCourseRegViewModel()));
    //     }
    //     try
    //     {
    //         viewModel.learningPlan = portalRemotingMethods.getApplicationItemDetails([SELECT Id FROM Application_Item__c WHERE Application__c =: this.application.Id 
    //                 AND RecordTypeId =: Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Learning Plan').getRecordTypeId()].get(0).Id);
    //         viewModel.learningPlan.learningPlanUpdate = true;
    //     }
    //     catch(ListException e)
    //     {
    //         system.debug('The student does not have a learning plan application item');
    //     }
    //     viewModel.institutions = portalRemotingMethods.searchHostInstitutions(null, viewModel.programID);
    //     for(Trip__c t: this.trips)
    //     {
    //         if(t.Status__c == 'Upcoming' || t.Status__c == 'Active')
    //             viewModel.upcomingTrips.add(new model_trip(t));
    //         else
    //             viewModel.pastTrips.add(new model_trip(t));
    //     }
    //     viewModel.phoneCountries = apexQueryUtility.selectAllFrom('Country__c', 'Active_For_On_Site_Phone_Picklist__c = TRUE ORDER BY Name');
        
    //     return viewModel;
    // }
    // /**
    //  * @description Fills view model with housing assignment data     
    //  */
    // public studentOnSiteViewModel populateHousingAssignment(studentOnSiteViewModel viewModel)
    // {
    //     viewModel.cellPhone = this.housingAssignment.Cell_Phone__c;
    //     viewModel.country = this.housingAssignment.Country__r.Country_Code__c;
    //     viewModel.dependentLocality = this.housingAssignment.Dependent_Locality__c;
    //     viewModel.description = this.housingAssignment.Description__c;
    //     viewModel.displayName = this.housingAssignment.Display_Name__c;
    //     viewModel.email = this.housingAssignment.Email__c;
    //     viewModel.housingAssignmentId = this.housingAssignment.Id;
    //     viewModel.housingOption = this.housingAssignment.Housing_Option__c;
    //     viewModel.landline = this.housingAssignment.Landline__c;
    //     viewModel.locality = this.housingAssignment.Locality__c;
    //     viewModel.street1 = this.housingAssignment.Street_1__c;
    //     viewModel.street2 = this.housingAssignment.Street_2__c;
    //     viewModel.zipCode = this.housingAssignment.Zip_Code__c;
    //     viewModel.photos = getHousingPhotos();    

    //     return viewModel;        
    // }

    // private List<studentOnSitePhotosViewModel> getHousingPhotos()
    // {
    //     List<studentOnSitePhotosViewModel> photos = new List<studentOnSitePhotosViewModel>();

    //     List<Attachment> attach = [SELECT Id, Name, Body, BodyLength, Description FROM Attachment WHERE ParentID =: this.housingAssignment.Id];
    //     for(Attachment a: attach)
    //     {
    //         studentOnSitePhotosViewModel photo = new studentOnSitePhotosViewModel();
    //         //photo.image = EncodingUtil.Base64Encode(a.body);
    //         photo.text = a.Description;
    //         //https://c.na34.content.force.com/servlet/servlet.FileDownload?file=00P61000004vO3C
    //         photo.url = apexInstanceUtility.attachmentUrl +  a.Id;
    //         system.debug(photo.url);
    //         photos.add(photo);
    //     }

    //     return photos;
    // }


    // /**
    //  * @description Encodes address into google maps api url     
    //  */
    // public void formatGoogleMapsAddress()
    // {
	// 	String address = this.viewModel.street1;
	// 	if(this.viewModel.street2 != null)
    // 	{
    // 		address += ' ' + this.viewModel.street2;
    // 	}
    //     if(this.viewModel.locality != null)
    //     {
    //         address += ' ' + this.viewModel.locality;    
    //     }
    //     if(this.viewModel.dependentLocality != null)
    //     {
    //         address += ' ' +  this.viewModel.dependentLocality;    
    //     }    	    	
    //     if(this.viewModel.zipCode != null)
    //     {
    //         address += ' ' + this.viewModel.zipCode;    
    //     }        
    //     if(this.viewModel.country != null)
    //     {
    //         address += ' ' + this.viewModel.country + ' ';    
    //     }
        
            	
    // 	this.iFrameUrl = 'https://www.google.com/maps/embed/v1/place?q=' + EncodingUtil.urlEncode(address, 'UTF-8') +  '&zoom=16&key=AIzaSyAsZq3xzdJHfB2UNfCkxAbZgsnRWQGpMdU';    		
    // } 
    // /**
    //  * @description Ensures the student has access to this page.
    //  * @return Null if the student has valid access, otherwise a page reference.
    //  */
    // public override PageReference validateAccess()
    // {
    //     if(this.viewModel.isLockDownActive)
    //     {
    //         return new PageReference('/SP_Home');
    //     }
    //     else if(!this.studentApplication.hasHousing() && !this.studentApplication.isBeyond('Accepted'))
    //     {
    //         return new PageReference('/studentportal/SP_Home');
    //     }
        
    //     return null;
    // }
}