/**
 * @description View model component representing a course registration
 * @author Cameron Ames
 */
public class studentOnSiteCourseRegViewModel
{
	/**
	 * @description Course name.
	 */
    public String courseRegId {get;set;}

    public String courseName {get;set;}

    public String courseTitle {get;set;}

    public String encodedCourseTitle {get;set;}

    public String encodedCourseName {get;set;}
    /**
	 * @description Course code.
	 */
    public String courseCode {get;set;}

    /**
	 * @description Department code ID
	 */ 	

    public String departmentCode {get;set;}

    /**
	 * @description Department code
	 */ 	

    public String departmentCodeString {get;set;}
    
	/**
	 * @description The name of the instructor
	 */
    public String instructorName {get;set;}
    /**
	 * @description The first name of the instructor
	 */
    public String instructorFirstName {get;set;}
	/**
	 * @description The last name of the instructor
	 */
    public String instructorLastName {get;set;}

	/**
	 * @description The Id of the course this points to, if it is linked to a course.
	 */
    public Id courseId {get;set;}
    
	/**
	 * @description Number of Credits
	 */
    public Decimal credits {get;set;}
    
	/**
	 * @description Number of US Credits
	 */
    public Decimal usCredits {get;set;}

	/**
	 * @description Number of US Credits
	 */
    public Decimal usCreditsEarned {get;set;}

	/**
	 * @description Is Course Registration approved
	 */
    public Boolean isApproved {get;set;}

	/**
	 * @description Is Course Registration dropped
	 */
    public Boolean isDropped {get;set;}

    /**
	 * @description Host Institution Id
	 */
    public String hostInstitutionId {get;set;}
    
    /**
	 * @description Host Institution Name
	 */
    public String hostInstitutionName {get;set;}
	/**
	 * @description Original Host Institution Name
	 */
    public String originalHostInstitutionName {get;set;}

	/*
	 * @description Host Institution Grade
	 */
	public String hostInstitutionGrade {get;set;}

    /**
	 * @description Grade
	 */
    public String courseGrade {get;set;}

	/**
	 * @description ApplicationID
	 */
    public String applicationID {get;set;}

    /**
    *@description Course Term
    */
    public String courseTerm {get;set;}

	/**
    *@description Course Status
    */
    public String courseStatus {get;set;}

	/**
    *@description Course Status
    */
    public Decimal qualityPoints {get;set;}    

	/**
	 * @description Alternate For Course Registration
	 */
    public String alternateFor {get;set;}
	/**
	 * @description Interest Rank
	 */
    public Decimal rank {get;set;}
	/**
	 * @description Reason course was not registered
	 */
	public String notRegisteredReason { get; set; }
	/**
	 * @description Reason course was not registered (if other is selected for notRegistered Reason)
	 */
	public String notRegisteredReasonOther { get; set; }
	/**
	 * @description Reason other course was not registered
	 */
	public String otherClassReason { get; set; }
	/**
	 * @description Reason other course was not registered (if other is selected for notRegistered Reason)
	 */
	public String otherClassReasonOther { get; set; }
	/**
	* @description Untranslated Class Title
	*/
	public String untranslatedTitle { get; set; }
	/**
	* @description Fulfills Degree Requirement
	*/
public Boolean fulfillsDegreeRequirement { get; set; }
	/**
	* @description Required Class
	*/
	public Boolean required { get; set; }
	/**
	 * @description Location of Instruction Id
	 */
	public String locationId {get;set;}
	/**
	 * @description Host Institution Department Id
	 */
	public String selectedDepartment {get;set;}
}