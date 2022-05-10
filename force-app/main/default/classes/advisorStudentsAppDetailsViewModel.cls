/**
 * View Model of a Student Application with more detalis
 */
// ApexDoc updated 1/23/2021 Brock Barlow
public without sharing class advisorStudentsAppDetailsViewModel
{
	/**
	 * Application for a custom program (Custom/Collaborative - true / Catalog - false)
	 */
	public Boolean CustomApplication {get;set;}
	/**
	 * Student's first name
	 */
	public String StudentFirstName {get;set;}
	/**
	 * Student's last name
	 */
	public String StudentLastName {get;set;}
	/**
	 * Student's email
	 */
	public String StudentEmail {get;set;}
	/**
	 * Student's middle name
	 */
	public String StudentMiddleName {get;set;}
	/**
	 * Student's preferred name
	 */
	public String StudentPreferredName {get;set;}
	/**
	 * Student's suffix (Jr, Sr)
	 */
	public String StudentSuffix {get;set;}
	/**
	 * Student's citizenship
	 */
	public String StudentCitizenship {get;set;}
	/**
	 * Student's First Generation Status (Is first generation college student - true)
	 */
	public Boolean StudentFirstGeneration {get;set;}
	/**
	 * Student's sex (Male / Female) 
	 */
	public String StudentSex {get;set;}
	/**
	 * Student's birtdate
	 */
	public Date StudentBirthdate {get;set;}
	/**
	 * Student's mailing address - street
	 */
	public String StudentMailingStreet {get;set;}
	/**
	 * Student's mailing address - city
	 */
	public String StudentMailingCity {get;set;}
	/**
	 * Student's mailing address - state
	 */
	public String StudentMailingState {get;set;}
	/**
	 * Student's mailing address - country
	 */
	public String StudentMailingCountry {get;set;}
	/**
	 * Student's mailing address - postal code
	 */
	public String StudentMailingPostalCode {get;set;}
	/**
	 * Student's mailing address - phone number
	 */
	public String StudentPhone {get;set;}
	/**
	 * Student's home institution name
	 */
	public String HomeInstitutionName {get;set;}
	/**
	 * Student's degree (2 year / 4 year)
	 */
	public String StudentDegree {get;set;}
	/**
	 * Student's grade leve
	 */
	public String StudentGradeLevel {get;set;}
	/**
	 * Student's twitter handle
	 */
	public String StudentTwitterHandle {get;set;}
	/**
	 * Student's major
	 */
	public String StudentMajor {get;set;}
	/**
	 * Student's GPA
	 */
    public Decimal StudentGPA {get;set;}
	/**
	 * Student's program name
	 */
	public String ApplicationProgramTermProgram {get;set;}
	/**
	 * Student's program term section
	 */
	public String ApplicationProgramTermSection {get;set;}
	/**
	 * Student's program term year
	 */
	public String ApplicationProgramTermYear {get;set;}
	/**
	 * Student's application status
	 */
	public String ApplicationStatus {get;set;}
	/**
	 * Student's application id
	 */
	public String ApplicationId {get;set;}
	/**
	 * List<advisorStudentsAppItemViewModel> Student's application items
	 * @see <<advisorStudentsAppItemViewModel>>
	 */
	public List<advisorStudentsAppItemViewModel> appItems {get;set;}
}