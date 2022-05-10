/**
* @description Controller to populate page with a students grade report - NOT FINISHED
* @author Brock Barlow
*/
public with sharing class studentGradeReportController extends studentBaseController
{
    /**
     * @description The page view model
     */
    public studentOnSiteViewModel viewModel {get;set;}
    public String iFrameUrl {get;set;} 
    
    /**
     * @description The course registration objects.
     */
    private List<ifsaCourseRegistrationWrapper> courseRegistrations {get;set;}
    
    /**
     * @description The student's application wrapper. This will eventually be merged in the base controller.
     */
    public ifsaApplicationWrapper studentApplication {get;set;}
    
    private Housing_Assignment__c housingAssignment {get;set;}        

    /**
     * @description Constructor function.
     */
    public studentGradeReportController()
    {
        super();
        
        this.studentApplication = new ifsaApplicationWrapper(this.application);
        this.courseRegistrations = this.studentApplication.getCourseRegistrations();    	
		try
		{
			this.housingAssignment = (Housing_Assignment__c) apexQueryUtility.selectAllFrom('Housing_Assignment__c', 'Country__r.Country_Code__c', 'Id = \'' + this.studentApplication.getHousingAssignmentId() + '\'').get(0);	
		}
		catch(Exception e)
		{
			this.housingAssignment = null;
		}							   
        
        this.viewModel = this.populateViewModel(new studentOnSiteViewModel());
        
        if(this.housingAssignment != null && !this.housingAssignment.Hide_Map__c)
        {
        	formatGoogleMapsAddress();        	
        }   
        else if(this.housingAssignment == null)
        {
            this.viewModel.street1 = '';
        }
    }

    public PageReference GradeReport()
    {
        PageReference gr = Page.SP_GradeReport;
        return gr;
    }

    /**
     * @description Populates a view model with data.
     * @param viewModel The view model to fill with data.
     * @return The same view model instance with data.
     */
    public studentOnSiteViewModel populateViewModel(studentOnSiteViewModel viewModel)
    {
        viewModel = (studentOnSiteViewModel) super.populateViewModel(viewModel);
        viewModel = this.studentApplication.populateViewModel(viewModel);
        if(this.housingAssignment != null)
        {
        	viewModel = populateHousingAssignment(viewModel);
        }

        viewModel.courses = new List<studentOnSiteCourseRegViewModel>();
        for(ifsaCourseRegistrationWrapper courseRegistration : this.courseRegistrations)
        {
            viewModel.courses.add(courseRegistration.populateViewModel(new studentOnSiteCourseRegViewModel()));
        }

        
        return viewModel;
    }
    /**
     * @description Fills view model with housing assignment data     
     */
    public studentOnSiteViewModel populateHousingAssignment(studentOnSiteViewModel viewModel)
    {
        viewModel.cellPhone = this.housingAssignment.Cell_Phone__c;
        viewModel.country = this.housingAssignment.Country__r.Country_Code__c;
        viewModel.dependentLocality = this.housingAssignment.Dependent_Locality__c;
        viewModel.description = this.housingAssignment.Description__c;
        viewModel.displayName = this.housingAssignment.Display_Name__c;
        viewModel.email = this.housingAssignment.Email__c;
        viewModel.housingOption = this.housingAssignment.Housing_Option__c;
        viewModel.landline = this.housingAssignment.Landline__c;
        viewModel.locality = this.housingAssignment.Locality__c;
        viewModel.street1 = this.housingAssignment.Street_1__c;
        viewModel.street2 = this.housingAssignment.Street_2__c;
        viewModel.zipCode = this.housingAssignment.Zip_Code__c;
        viewModel.photos = new List<studentOnSitePhotosViewModel>();
        List<Attachment> attach = [SELECT Id, Name, Body, BodyLength, Description FROM Attachment WHERE ParentID =: this.housingAssignment.Id];
        for(Attachment a: attach)
        {
            studentOnSitePhotosViewModel photo = new studentOnSitePhotosViewModel();
            photo.image = EncodingUtil.Base64Encode(a.body);
            photo.text = a.Description;

            if(a.BodyLength < 200000)
            {
                viewModel.photos.add(photo);}
            }
        return viewModel;
    }

    /**
     * @description Encodes address into google maps api url     
     */
    public void formatGoogleMapsAddress()
    {
		String address = this.viewModel.street1;
		if(this.viewModel.street2 != null)
    	{
    		address += ' ' + this.viewModel.street2;
    	}
        if(this.viewModel.locality != null)
        {
            address += ' ' + this.viewModel.locality;    
        }
        if(this.viewModel.dependentLocality != null)
        {
            address += ' ' +  this.viewModel.dependentLocality;    
        }    	    	
        if(this.viewModel.zipCode != null)
        {
            address += ' ' + this.viewModel.zipCode;    
        }        
        if(this.viewModel.country != null)
        {
            address += ' ' + this.viewModel.country + ' ';    
        }
        
            	
    	this.iFrameUrl = 'https://www.google.com/maps/embed/v1/place?q=' + EncodingUtil.urlEncode(address, 'UTF-8') +  '&zoom=16&key=AIzaSyAsZq3xzdJHfB2UNfCkxAbZgsnRWQGpMdU';    		
    } 
    /**
     * @description Ensures the student has access to this page.
     * @return Null if the student has valid access, otherwise a page reference.
     */
    public override PageReference validateAccess()
    {
        if(!this.studentApplication.hasHousing())
        {
        	if(!this.studentApplication.isBeyond('Accepted'))
        	{
            	return new PageReference('/studentportal/SP_Home');
        	}
        }
        
        return null;
    }
}