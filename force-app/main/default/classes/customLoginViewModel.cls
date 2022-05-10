/**
 * @description View model for the custom portal login page.
 * @author Cameron Ames
 * TODO: Break out any skinning components that are site-wide applicable into their own class. then reference that class here.
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class customLoginViewModel
{
	/**
	 * @description The home institution name
	 */
	public String name {get;set;}
	
	/**
	 * @description The email address in a custom scheme.
	 */
	public String forQuestions {get;set;}
	
	/**
	 * @description The logo in a custom color scheme.
	 */
	public String attachmentId {get;set;}
	
	/**
	 * @description The major color in a custom color scheme.
	 */
	public String primaryColor {get;set;}
	
	/**
	 * @description The minor color in a custom color scheme.
	 */
	public String secondaryColor {get;set;}
	
	/**
	 * @description The information text to display for a customized page.
	 */
	public String splashPageInfo {get;set;}
	
	/**
	 * @description The email address (becomes the username with .ifsa on the end)
	 */
	public String userName {get;Set;}
	
	/**
	 * @description The user password
	 */
	public String password {get;Set;}
}