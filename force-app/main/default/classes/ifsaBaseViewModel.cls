/**
 * Base view model.
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing abstract class ifsaBaseViewModel
{
	/**
	 * The current user Id, or the id of the user a sys admin is impersonating.
	 */
	public Id userId {get;set;}
}