/**
 * @description The base view model for all portal pages
 * @author Cameron Ames
 */
public without sharing abstract class portalBaseViewModel extends ifsaBaseViewModel
{
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
	public Boolean isSandbox
	{
		get
		{
			return apexInstanceUtility.isSandBox;
		}
		set;
	}
}