/**
 * The wrapper class for the course registration sObject.
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public class ifsaCourseRegistrationWrapper
{
	/**
	 * The course registration sObject.
	 */
    private Course_Registration__c courseRegistration {get;set;}
    
    /**
     * Constructor function. The sObject is directly populated.
     * @param aCourseRegistration The sObject that will directly populate the wrapper class.
     */
    public ifsaCourseRegistrationWrapper(Course_Registration__c aCourseRegistration)
    {
        this.courseRegistration = aCourseRegistration;
    }
    
    /**
     * Constructor function. Populates the sObject based on the Id.
     * @param courseRegistrationId The Id of the course registration object.
     */
    public ifsaCourseRegistrationWrapper(Id courseRegistrationId)
    {
        this.courseRegistration = (Course_Registration__c) apexQueryUtility.selectAllFrom('Course_Registration__c', 'Host_Institution__r.Name, Butler_Department_Code__r.Name, Course__r.Untranslated_Course_Title__c', 'Id = \'' + courseRegistrationId + '\'').get(0);
    }

	/**
	 * Populates the view model with course registration information.
	 * @param viewModel The pre-created view model object.
	 * @return The same view model instance, populated with data.
	 */
    public studentOnSiteCourseRegViewModel populateViewModel(studentOnSiteCourseRegViewModel viewModel)
    {
        viewModel.courseRegId = this.courseRegistration.Id;
        viewModel.courseCode = this.courseRegistration.Course_Code__c;        
        viewModel.courseId = this.courseRegistration.Course__c;
        viewModel.courseName = this.courseRegistration.Name;   
        viewModel.courseTitle = this.courseRegistration.Course_Title__c;     
    	viewModel.credits = this.courseRegistration.Host_Credits__c;
        viewModel.departmentCode = this.courseRegistration.Butler_Department_Code__c;
        try {
            viewModel.departmentCodeString = this.courseRegistration.Butler_Department_Code__r.Name;    
        } catch (Exception e) {
            
        }        
        viewModel.instructorFirstName = this.courseRegistration.Instructor_First_Name__c; 
        viewModel.instructorLastName = this.courseRegistration.Instructor_Last_Name__c;
    	viewModel.usCredits = this.courseRegistration.US_Semester_Credit_Hours__c;
        viewModel.usCreditsEarned = this.courseRegistration.Credits_Earned__c;
        viewModel.courseGrade = this.courseRegistration.Final_Grade__c;
        viewModel.courseTerm = this.courseRegistration.Course_Term__c;
        viewModel.courseStatus = this.courseRegistration.Status__c;
        viewModel.alternateFor = this.courseRegistration.Alternate_For__c;
        viewModel.rank = this.courseRegistration.Rank__c;
        viewModel.hostInstitutionId = this.courseRegistration.Host_Institution__c;
        viewModel.notRegisteredReason = this.courseRegistration.Not_Registered_Reason__c;
        viewModel.notRegisteredReasonOther = this.courseRegistration.Not_Registered_Reason_Other__c;
        viewModel.otherClassReason = this.courseRegistration.Other_Class_Reason__c;
        viewModel.otherClassReasonOther = this.courseRegistration.Other_Class_Reason_Other__c;
        viewModel.untranslatedTitle = this.courseRegistration.Untranslated_Course_Title__c != null ? this.courseRegistration.Untranslated_Course_Title__c : this.courseRegistration.Course__r.Untranslated_Course_Title__c;
        viewModel.fulfillsDegreeRequirement = this.courseRegistration.Fulfills_Degree_Requirement__c;
        viewModel.required = this.courseRegistration.Required_Class__c;
        viewModel.selectedDepartment = this.courseRegistration.Host_Institution_Departement__c;
        try
        {
        	viewModel.hostInstitutionName = this.courseRegistration.Host_Institution__r.Name;
        }
        catch(sObjectException e){}

        return viewModel;
    }
}