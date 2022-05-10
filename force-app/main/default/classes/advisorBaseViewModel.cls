/**
 * The view model class containing all data common to all pages on the advisor portal.
 * @author Cameron Ames
 */
public without sharing abstract class advisorBaseViewModel extends portalBaseViewModel
{
	/**
	 * The advisor first name.
	 */
	public String FirstName {get;set;}

	/**
	 * The advisor last name.
	 */
	public String LastName {get;set;}

	/**
	 * The name of the Home Institution.
	 */
	public String InstitutionName {get;set;}

	/**
	 * Indicates whether or not an advisor has been approved for advising.
	 */
	public Boolean approvedForAdvising {get;set;}

	/**
	 * Indicates whether or not an advisor has manage program authorizations.
	 */
	public Boolean approvedForProgramAuthorizations {get;set;}
	public Boolean showChart
	{
		get
		{
			try
			{
				Custom_Community_Setting__mdt value = [SELECT DeveloperName, Content__c FROM Custom_Community_Setting__mdt WHERE DeveloperName = 'Show_CHART_In_Portals'].get(0);
				return value.Content__c == 'true' ? true : false;
			}
			catch(Exception e)
			{
				return false;
			}
		}
		set;
	}
	/**
	 * The Id of the user's home institution
	 */
	public Id homeInstitutionId {get;set;}
}