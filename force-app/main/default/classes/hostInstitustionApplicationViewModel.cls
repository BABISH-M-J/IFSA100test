/**
 * Viewmodel for approval of course registrations and creating grade reports.
 * Links host institutions with the students/applications that attended
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public with sharing class hostInstitustionApplicationViewModel 
{
	/**
	 * The name of the home institution
	 */
	public String institutionName {get;set;}
	/**
	 * A list of applicationCourseViewModel
	 */
	public List<applicationCourseViewModel> applicationCourses {get;set;}
	/**
	 * Constructor, initializes lists
	 */
	public hostInstitustionApplicationViewModel()
	{
		applicationCourses = new List<applicationCourseViewModel>();
	}
}