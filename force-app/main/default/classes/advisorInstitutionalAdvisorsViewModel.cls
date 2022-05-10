/**
 * The view model class for the list of advisors on the my institution page.
 * @author Cameron Ames
 */
public without sharing class advisorInstitutionalAdvisorsViewModel
{
	/**
	 * The first name of the advisor.
	 */
	public String AdvisorFirstName {get;set;}

	/**
	 * The last name of the advisor.
	 */
	public String AdvisorLastName {get;set;}

	/**
	 * The title of the advisor.
	 */
	public String AdvisorTitle {get;set;}

	/**
	 * Indicates if the advisor has been approved.
	 */
	public Boolean AdvisorApprovedForAdvising {get;set;}

	/**
	 * The Id of the advisor.
	 */
	public String AdvisorId {get;set;}
}