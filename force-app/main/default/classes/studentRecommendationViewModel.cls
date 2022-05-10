/**
* @description Viewmodel for SP_Recommendation page
* @author Cameron Ames
*/
public with sharing class studentRecommendationViewModel
{
	public String recommendationId {get;set;}
	public String recommendationName {get;set;}
	public String recommendationRecommenderName {get;set;}
	public String recommendationStatus {get;set;}
	public String recommendationTitle {get;set;}
	public String recommendationEmail {get;set;}
	public String recommendationDepartment {get;set;}
	public String university {get;set;}
	public String phone {get;set;}
	public String applicationName {get;set;}
	public String content {get;set;}
	public String studentFirstName {get;set;}
	public String studentPreferredName {get;set;}
	public String studentLastName {get;set;}
	public String programTerm {get;set;}
	public Boolean isRecommendee {get;set;}
	public Boolean recommendeeWaived {get;set;}
	public String fileData {get;set;}
	public String fileType {get;set;}
	public String fileName {get;set;}

	// System Maintenance Fields
    public String systemMessage {get;set;}
    public Boolean isLockDownActive {get;set;}

	/**
	 * @description Takes the current view model and converts into a serialized JSON String. Useful for Angular integration.
	 * @return The view Model class, serialized into a JSON String.
	 */
	public String getSerializedViewModel()
	{
		return JSON.serialize(this);
	}
	public String getEscapedSerializedViewModel()
	{
		return getSerializedViewModel().escapeEcmaScript();
	}
}