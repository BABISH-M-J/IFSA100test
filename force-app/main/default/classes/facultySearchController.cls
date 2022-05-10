//Project BlackHole
/**
 * Controller for facultySearch Visualforce page. The VF page is used to find the home school emergency contacts for all of the students that studied abroad during a specific term. Filters can be applied so that you can only see students that were on a specific program or in specific countries or cities.
 * @author Brock Barlow
 */
// ApexDoc updated 2/4/2021 Brock Barlow
public with sharing class facultySearchController 
{
	/**
	 * Viewmodel, an instance of <<facultySearchViewModel>>
	 */
	public facultySearchViewModel viewModel {get;set;}

	/**
	 * Constructor, initializes an instance of <<facultySearchViewModel>>
	 */
	public facultySearchController() 
	{
		this.viewModel = new facultySearchViewModel();
	}

	/**
	 * Updates the filter options
	 * @param jsonData JSON stringified <<facultySearchViewModel>>
	 * @return JSON serialized <<facultySearchViewModel>>
	 */
	@RemoteAction
	public static String updateFilters(String jsonData)
	{
		facultySearchViewModel vm = facultySearchViewModel.parseJSONString(jsonData);

		vm.updateFilters();

		return vm.getSerializedViewModel();
	}

	/**
	 * Resets filter options
	 * @param jsonData JSON stringified <<facultySearchViewModel>>
	 * @return JSON serialized <<facultySearchViewModel>>
	 */
	@RemoteAction
	public static String resetFilters(String jsonData)
	{
		facultySearchViewModel vm = facultySearchViewModel.parseJSONString(jsonData);

		vm.resetFilters();

		return vm.getSerializedViewModel();	
	}

	/**
	 * Searchs for home institution
	 * @param jsonData JSON stringified <<facultySearchViewModel>>
	 * @param searchString The home institution to search for 
	 * @return JSON serialized <<facultySearchViewModel>>
	 */
	@RemoteAction
	public static String searchHomeInstitutionByName(String jsonData, String searchString)
	{
		facultySearchViewModel vm = facultySearchViewModel.parseJSONString(jsonData);

		vm.searchHomeInstitutionByName(searchString);

		return vm.getSerializedViewModel();
	}

	/**
	 * Searches for Home Institution Contacts related to the students whose application matches the search filters
	 * @param jsonData JSON stringified <<facultySearchViewModel>>
	 * @return JSON serialized <<facultySearchViewModel>>
	 */
	@RemoteAction
	public static String search(String jsonData)
	{
		facultySearchViewModel vm = facultySearchViewModel.parseJSONString(jsonData);
		vm.search();

		return vm.getSerializedViewModel();	
	}

	/**
	 * Gets the student's for that home school advisor
	 * @param jsonData JSON stringified <<facultySearchViewModel>>
	 * @return JSON serialized <<facultySearchViewModel>>
	 */
	@RemoteAction
	public static String getStudents(String jsonData)
	{
		facultySearchViewModel vm = facultySearchViewModel.parseJSONString(jsonData);

		vm.getStudents();

		return vm.getSerializedViewModel();	
	}
	
	/**
	 * Gets the faculty contact's details
	 * @param jsonData JSON stringified <<facultySearchViewModel>>
	 * @return JSON serialized <<facultySearchViewModel>>
	 */
	@RemoteAction
	public static String getFacultyContact(String jsonData)
	{
		facultySearchViewModel vm = facultySearchViewModel.parseJSONString(jsonData);

		vm.getFacultyContact();

		return vm.getSerializedViewModel();	
	}

	/**
	 * Sends an email message
	 * @param emailMessage The contents of the email message
	 * @param subject The subject of the email message
	 * @param toContact The recipent of the email message
	 * @param ccEmails The CC'd recipents of the email message
	 * @param bccEmails The BCC'd recipents of the email message
	 * @return Boolean
	 */
	@RemoteAction
	public static Boolean sendEmailMessage(String emailMessage, String subject, String toContact, String ccEmails, String bccEmails)
	{
		Boolean success;
		try
		{
			apexEmailUtility.sendGeneralEmail(subject, emailMessage, new List<Id>{toContact}, true, ccEmails, bccEmails);
			success = true;
		}
		catch (Exception ex)
		{
			success = false;
		}
		return success;
	}
}