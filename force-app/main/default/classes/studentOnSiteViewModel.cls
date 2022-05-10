/**
 * @description View Model class for the on site page of the student portal.
 * @author Cameron Ames
 */
public class studentOnSiteViewModel extends studentBaseViewModel
{
	public studentOnSiteViewModel()
	{
		this.institutions = new List<Host_Institution__c>();
		this.upcomingTrips = new List<model_trip>();
		this.pastTrips = new List<model_trip>();
		this.photos = new List<studentOnSitePhotosViewModel>();
		this.courses = new List<studentOnSiteCourseRegViewModel>();
		this.phoneCountries = new List<Country__c>();
	}
    /**
     * @description The Id of the program term.
     */
    public Id programTermId {get;set;}
	
	/**
	 * @description The Id of the application.
	 */
	public Id applicationId {get;set;}
        
    /**
	 * @description The Id of the program.
	 */
    public Id programID {get;set;}

	/**
	 * @description The list of course registrations for a student.
	 */
    public List<studentOnSiteCourseRegViewModel> courses {get;set;}
    
	/**
	 * @description The picklist options for the number of credits.
	 */
    public List<String> creditsOptions {get;set;}
    
	/**
	 * @description The picklist options for the number of US credits.
	 */
    public List<String> usCreditsOptions {get;set;}

	/**
	 * @description Is the course registration form editable? Or has it already been submitted?
	 */
	public Boolean isCourseRegEditable {get;set;}
    
    /**
	 * @description Cell Phone number of Housing Assignment.
	 */
     
    public String cellPhone {get; set;}
    /**
	 * @description Country number of Housing Assignment.
	 */
     
    public String country {get; set;}
    
    /**
	 * @description Dependent Locality of Housing Assignment.
	 */
    public String dependentLocality {get; set;}
    
    /**
	 * @description Description of Housing Assignment.
	 */
    public String description {get; set;}
    
    /**
	 * @description Display Name number of Housing Assignment.
	 */
    public String displayName {get; set;}
    
    /**
	 * @description Email address of Housing Assignment.
	 */
    public String email {get; set;}
    
    /**
	 * @description Housing Option of Housing Assignment.
	 */
    public String housingOption {get; set;}

    /**
	 * @description Housing Assignment Id.
	 */
    public String housingAssignmentId {get; set;}
    
    /**
	 * @description Land Line phone number of Housing Assignment.
	 */
    public String LandLine {get; set;}
    
    /**
	 * @description Locality of Housing Assignment.
	 */
    public String locality {get; set;}
    
    /**
	 * @description Street 1 of Housing Assignment address.
	 */
    public String street1 {get; set;}
    
    /**
	 * @description Street 2 of Housing Assignment address.
	 */
    public String street2 {get; set;}
    
    /**
	 * @description Zip Code of Housing Assignment.
	 */
    public String zipCode {get; set;}

    /**
	 * @description Abroad Phone Number
	 */
    public String abroadPhoneNumber {get;set;}
    
    /**
	 * @description Country of Abroad Phone Number.
	 */
	public String abroadPhoneNumberCountry {get;set;}

	/**
	 * @description Viewmodel instance of learning plan
	 */
	public studentApplyItemDetailsViewModel learningPlan {get;set;}
    
    /**
	 * @description Photo URL of Housing Assignment photo.
	 */
	public List<studentOnSitePhotosViewModel> photos {get;set;}
    public String photoUrl {get; set;}
    public String photoUrl2 {get; set;}
    	
	public Id institutionId {get;set;}
	public String institutionName {get;set;}
	public List<Host_Institution__c> institutions {get;set;}

	public Boolean hasSecondTerm {get;set;}
	public Boolean isSecondTermStarted {get;set;}
	public String secondTermName {get;set;}

	public List<Country__c> phoneCountries {get;set;}
	public List<model_trip> upcomingTrips {get;set;}
	public List<model_trip> pastTrips {get;set;}
}