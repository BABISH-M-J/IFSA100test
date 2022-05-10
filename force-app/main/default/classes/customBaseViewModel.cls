/**
 * Base view model data for the custom portal.
 * TODO: Break out the skin data components of the customLoginViewModel, then use that new class here.
 * THE CUSTOM PORTAL IS POWERD BY THE CATALOG STUDENT PORTAL SO THAT EFFORTS ARE NOT DUPLICATED AS OF SUMMER 2020.
 * @author Cameron Ames
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing abstract class customBaseViewModel extends portalBaseViewModel
{
	/**
	 * @description the student's first name.
	 */
	public String studentFirstName {get;set;}
	
	/**
	 * @description The student's last name.
	 */
	public String studentLastName {get;set;}
	
	/**
	 * @description The login page's view model. Since that has all of our appropriate skin data, we are using it right now.
	 */
	public customLoginViewModel skinData {get;set;}
	/**
	 * @description Determines if we are to display the account tab in the nav bar
	 */
	public Boolean displayAccountTab {get;set;}
}