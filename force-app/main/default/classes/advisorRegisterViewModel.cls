/**
 * View model class for the advisor register page
 * @author Cameron Ames
 */
// ApexDoc updated 1/23/2021 Brock Barlow
public without sharing class advisorRegisterViewModel
{
	/**
	 * the email of the user attempting to log in
	 */
    public String email{get;set;}
	
	/**
	 * The user's password
	 */
    public String password{get;set;}
	
	/**
	 * The user's first name
	 */
    public String firstName {get;set;}
	
	/**
	 * The user's last name.
	 */
    public String lastName {get;set;}
	
	/**
	 * The user's password confirmation - must be the same as the password.
	 */
	public String confirmPassword {get;set;}
	
	/**
	 * The user's title.
	 */
	public String title {get;set;}
	
	/**
	 * The Id of the home institution.
	 */
	public String institutionId {get;set;}

	/**
	 * The name of the home institution.
	 */
	public String homeInstitutionName {get;set;}
	
	/**
	 * Boolean indicating whether or not we need to display custom messages.
	 */
	public Boolean displayCustomMessages {get;set;}
	
	/**
	 * Any custom messages that need to be displayed.
	 */
	public String customMessages {get;set;}

	// System Maintenance Fields
	/**
	 * The message to be presented to the user
	 */
	public String systemMessage {get;set;}
	/**
	 * Lock down status
	 */
    public Boolean isLockDownActive {get;set;}
	/**
	 * List of home institutions
	 */
	public List<Home_Institution__c> homeInstitutions {get;set;}

	/**
	 * Simple Constructor, initializes homeInstitutions
	 */
	public advisorRegisterViewModel()
	{
		this.homeInstitutions = new List<Home_Institution__c>();
	}
	/**
	 * JSON serialized <<advisorRegisterViewModel>>
	 * @return String
	 */
	public String getSerializedViewModel()
	{
		return JSON.serialize(this);
	}
	/**
	 * Escaped JSON searialized <<advisorRegisterViewModel>>
	 * @return String
	 */
	public String getEscapedSerializedViewModel()
	{
		return getSerializedViewModel().escapeEcmaScript();
	}
}