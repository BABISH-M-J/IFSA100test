/**
*  Viewmodel class for <<courseRegistrationController>>
* @author Brock Barlow
*/
// ApexDoc updated 1/28/2021 Brock Barlow
public with sharing class courseRegistrationViewModel extends portalBaseViewModel
{
	/**
	 * List of Department Codes
	 */
	public List<String> deptCodes {get;set;}
	/**
	 * List of Grade Options
	 */
	public List<String> gradeOptions {get;set;}
	/**
	 * Determines what functionallity to used based on which VF page is loaded
	 */
	public String pageActionType {get;set;}
	/**
	 * If provided only the application matching this Id is loaded
	 */
	public Id applicationId {get;set;}
	/**
	 * If provided only the applications matching this program term Id are loaded
	 */
	public Id programTermId {get;set;}	
	/**
	 * This helps group applications by host instiution
	 */
	public List<hostInstitustionApplicationViewModel> hostInstViewModels {get;set;}
	/**
	 * Contstructor, initializes lists and get values
	 */
	public courseRegistrationViewModel() {
		hostInstViewModels = new List<hostInstitustionApplicationViewModel>();
		deptCodes = new List<String>();
		gradeOptions = apexConversionUtility.getPicklistStringValues(Course_Registration__c.Final_Grade__c);
		for(Butler_Department_Code__c c: [SELECT Id, Name, Department_Name__c, College__c FROM Butler_Department_Code__c WHERE Is_Inactive__c = FALSE ORDER BY Name])
        {
            deptCodes.add(c.Name);
        }
	}
}