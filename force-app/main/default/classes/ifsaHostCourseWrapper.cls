/**
 * Wrapper class for the Host Course sObject.
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class ifsaHostCourseWrapper
{
	/**
	 * Course sObject.
	 */
	private Course__c course {get;set;}

	/**
	 * Constructor. Takes the Id and propagates the course. Validates that it is not a home institution course.
	 * @param courseId The Id of the course
	 */
	public ifsaHostCourseWrapper(Id courseId)
	{
		this.course = (Course__c) apexQueryUtility.selectAllFrom('Course__c', 'RecordType.Name', 'Id = \'' + courseId + '\'').get(0);
		
		if(this.course.RecordType.Name != 'Host Institution')
		{
			apexErrorUtility.throwException(new ifsaDataException('The ifsaHostCourseWrapper was constructed with a non-host institution record Type. The record Type was: ' + this.course.RecordType.Name));
		}
	}

	/**
	 * Constructor. Takes the sObject and assigns it. It does NOT run any validation.
	 * @param aCourse The course sObject.
	 */
	public ifsaHostCourseWrapper(Course__c aCourse)
	{
		this.course = aCourse;
	}

	/**
	 * populates the view model with host course information.
	 * @param viewModel The pre-created view model object.
	 * @return The same view model instance, populated with data.
	 */
	public studentApplyItemDetailsViewModel populateViewModel(studentApplyItemDetailsViewModel viewModel)
	{
		if(viewModel.courses == null)
		{
			viewModel.courses = new List<studentHomeSchoolCourseViewModel>();
		}

		studentHomeSchoolCourseViewModel courseItem = new studentHomeSchoolCourseViewModel();
		courseItem.Id = this.course.Id;
		courseItem.courseCode = this.course.Course_Code__c;
		courseItem.courseName = this.course.Name;
		viewModel.courses.add(courseItem);

		return viewModel;
	}

	/**
	 * populates the view model with on site course information.
	 * @param viewModel The pre-created view model object.
	 * @return The same view model instance, populated with data.
	 */
	public studentOnSiteCourseRegViewModel populateViewModel(studentOnSiteCourseRegViewModel viewModel)
	{		
		viewModel.courseCode = this.course.Course_Code__c;
		viewModel.courseId = this.course.Id;
		viewModel.courseName = this.course.Name;
		viewModel.courseTitle = this.course.Course_Title__c;
		viewModel.departmentCode = this.course.Butler_Department_Code__c;
		viewModel.encodedCourseName = this.course.Name.replace('&', 'IFSA_ampSymbol_IFSA');
		viewModel.encodedCourseTitle = this.course.Course_Title__c != null ? this.course.Course_Title__c.replace('&', 'IFSA_ampSymbol_IFSA') : viewModel.encodedCourseName;
		viewModel.credits = this.course.Host_Credits__c;
		viewModel.usCredits = this.course.US_Semester_Credit_Hours__c;
		viewModel.hostInstitutionId = this.course.Host_Institution__r.Id;
		viewModel.hostInstitutionName = this.course.Host_Institution__r.Name;
		viewModel.untranslatedTitle = this.course.Untranslated_Course_Title__c;
		
		return viewModel;
	}
}