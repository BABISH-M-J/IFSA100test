/**
 * ViewModel class getting a student's application for the advisor portal
 */
// ApexDoc updated 1/23/2021 Brock Barlow
public without sharing class advisorStudentApplicationViewModel
{
	/**
	 * The student's first name
	 */
	public String ApplicationStudentFirstName {get;set;}
	/**
	 * The student's last name
	 */
	public String ApplicationStudentLastName {get;set;}
	/**
	 * The student's program
	 */
	public String ApplicationProgramTermProgram {get;set;}
	/**
	 * The student's program term section
	 */
	public String ApplicationProgramTermSection {get;set;}
	/**
	 * The student's program term year
	 */
	public String ApplicationProgramTermYear {get;set;}
	/**
	 * The student's appliation status
	 */
	public String ApplicationStatus {get;set;}
	/**
	 * The student's appliation contract status
	 */
	public Boolean ApplicationContracted {get;set;}
	/**
	 * The student's appliation designation
	 */
	public String ApplicationDesignation {get;set;}
	/**
	 * The student's appliation Id
	 */
	public String ApplicationId {get;set;}
	/**
	 * The student's appliation program approval status
	 */
	public String ProgramApprovalStatus {get;set;}
	/**
	 * The student's appliation program approval application item id
	 */
	public Id ProgramApprovalId {get;set;}
	/**
	 * The student's appliation learning plan status
	 */
	public String LearningPlanStatus {get;set;}
	/**
	 * The student's appliation learning plan application item id
	 */
	public Id LearningPlanId {get;set;}
}