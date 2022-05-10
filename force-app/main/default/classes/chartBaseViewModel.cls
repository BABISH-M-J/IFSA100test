/**
 * Base view model class used with CHART
 * @author Brock Barlow
 */

public without sharing abstract class chartBaseViewModel extends portalBaseViewModel
{
	/**
	 * The user's first name
	 */
	public String firstName {get;set;}
	/**
	 * The user's preferred name
	 */
	public String preferredName {get;set;}
	/**
	 * The user's last name
	 */
	public String lastName {get;set;}
	/**
	 * The user's contact id
	 */
	public String contactId {get;set;}
	/**
	 * The user's email address
	 */
	public String email {get;set;}
	// public String homeInstitutionName {get;set;}
	/**
	 * The user's home institution name
	 */
	public String userHomeInstitutionName {get;set;}
	/**
	 * The user's home institution id
	 */
	public Id userHomeInstitutionId { get;set; }
	/**
	 * The user's major
	 */
	public String major {get;set;}
	/**
	 * Settings to use in the AngularJS app
	 */
	public Map<String, String> settings {get;set;}
	/**
	 * Determines if Class Equivencey Search (CE Search) is enabled
	 */
	public Boolean ceSearch { get;set; }
	/**
	 * The last time CE Search was updates
	 */
	public Datetime ceSearchLastUpdated { get;set; }
	/**
	 * The user who last updated CE Search
	 */
	public String ceSearchLastUpdatedBy { get;set; }
	/**
	 * Constructor, initializes this.settings Map<String, String>
	 */
	public chartBaseViewModel()
	{
		settings = new Map<String, String>();
	}
}