/**
* @description Viewmodel for SP_Resources page
* @author Cameron Ames
*/
public without sharing class studentResourcesViewModel extends studentBaseViewModel
{
	// Lists
	public List<Attachment> attachments {get;set;}
	public List<String> categories {get;set;}
	public List<ContentDocumentLink> files {get;set;}
    	public List<ContentDocumentLink> app_files {get;set;}
	public List<Attachment> app_attachments {get;set;}

	public List<Resource_Item__c> resourceList {get;set;}
	public List<model_schedule> scheduleList {get;set;}
	// Date Fields
	public Date applicationDeadline {get;set;} 			// Application_Deadline__c
	public Date assessmentsBegin {get;set;}    			// Assessments_Begin__c
	public Date assessmentsEnd {get;set;}      			// Assessments_End__c
	public Date classesBegin {get;set;}        			// Classes_Begin__c
	public Date classesEnd {get;set;}		 	  		// Classes_End__c
	public Date endDate {get;set;}						// End_Date__c
	public Date examBegin {get;set;}					// Exam_End_Date__c
	public Date examEnd {get;set;}						// Exam_Start_Date__c
	public Date groupTransferToHostCity {get;set;}		// Group_Transfer_to_Host_City__c
	public Date ifsaOrientationEndDate {get;set;}		// IFSA_Orientation_End_Date__c
	public Date ifsaOrientationStartDate {get;set;}		// IFSA_Orientation_Start_Date__c
	public Date moveIntoTermHousing {get;set;}			// Move_into_Term_Housing__c
	public Date programDueDate {get;set;}				// Program_Due_Date__c
	public Date startDate {get;set;}					// Start_Date__c
	public Date suggestedDepartureFromUS {get;set;}		// Suggested_Departure_from_U_S__c
	public Date startOfSecondTerm {get;set;}			// Start_Of_Second_Term__c
	public Date universityOrientationEnds {get;set;}	// University_Orientation_Ends__c
	public Date universityOrientationStarts {get;set;}	// University_Orientation_Starts__c
	// Other fields
	public String arrivalWindowEndTime {get;set;}		// Arrival_Window_End_Time__c
	public String arrivalWindowStartTime {get;set;}		// Arrival_Window_Start_Time__c

	
	//ACARSON Jun.25.2018 variables relating to Housing Costs and Cost of Attendance on the Program Term
	public Decimal tuition {get;set;}
	public Decimal airfare {get;set;}
	public Decimal startupCosts {get;set;}
	public Decimal meals {get;set;}
	public Decimal visaUS {get;set;}
	public Decimal visaAbroad {get;set;}
	public Decimal visaTotal {get;set;}
	public Decimal miscellaneous {get;set;}
	public Decimal booksAndSupplies {get;set;}
	public Decimal localTransport {get;set;}
	public Decimal personalExpenses {get;set;}
	public Decimal totalBaseCosts {get;set;}
	public Decimal totalEstCosts {get;set;}
	public Decimal baseHousing {get;set;}
	public Decimal deposit {get;set;}
	public List<Program_Term_Housing_Option__c> suppHousing {get;set;}
	public Boolean displayHousingOptions {get;set;}
	public String courseCharges {get;set;}


	public studentResourcesViewModel()
	{
		this.attachments = new List<Attachment>();
		this.categories = new List<String>();
		this.files = new List<ContentDocumentLink>();
		this.resourceList = new List<Resource_Item__c>();
		this.scheduleList = new List<model_schedule>();
	}
}