/**
 * Wrapper class for the program-term object.
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class ifsaProgramTermWrapper
{
	/**
	 * The program term sObject
	 */
	private Program_Term__c programTerm {get;set;}

	/**
	 * Constructor. Takes the Id and obtains the program term based off of that.
	 * @param programTermId The Id of the program term.
	 */
	public ifsaProgramTermWrapper(Id programTermId)
	{
		this.programTerm = (Program_Term__c) apexQueryUtility.selectAllFrom('Program_Term__c', 'Program__r.Host_Institution__r.Country__c, Program__r.Name, Program__r.Webpage_Url__c', 'Id = \'' + programTermId + '\'').get(0);
	}

	/**
	 * Constructor. Takes the give sObject with no additional actions.
	 * @param programTerm The program term sObject.
	 */
	public ifsaProgramTermWrapper(Program_Term__c aProgramTerm)
	{
		this.programTerm = aProgramTerm;
	}

	/**
	 * Takes a view model and populates the appropriate data.
	 * @param viewModel The pre-existing view model instance
	 * @return the same view model instance with new data
	 */
	public studentApplyViewModel populateViewModel(studentApplyViewModel viewModel)
	{
    	viewModel.programName = this.programTerm.Program__r.Name;
		viewModel.programUrl = this.programTerm.Program__r.Webpage_Url__c;

		return viewModel;
	}

	/**
	 * Getter for the Id of the owner of the program term.
	 * @return id cooresponding to the owner of the program term.
	 */
	public Id getOwnerId()
	{
		return this.programTerm.OwnerId;
	}

	/**
	 * Getter for the Id of the program of the program term.
	 * @return id cooresponding to the program of the program term.
	 */
	public Id getProgramId()
	{
		return this.programTerm.Program__c;
	}

	/**
	 * Getter for the Id of the parent program term of the program term.
	 * @return id cooresponding to the parent program term of the program term.
	 */
	public Id getParentProgramTermId()
	{
		return this.programTerm.Parent_Program_Term__c;
	}

	/**
	 * Getter for the Id of the country of the program term.
	 * @return id cooresponding to the country of the program term.
	 */
	public Id getCountryId()
	{
		return this.programTerm.Program__r.Host_Institution__r.Country__c;
	}

	/**
	 * Getter for the Id of the term of the program term.
	 * @return id cooresponding to the term of the program term.
	 */
	public Id getTermId()
	{
		return this.programTerm.Term__c;
	}

	/**
	 * Obtains data on the currently active program terms in salesforce.
	 * @return a Map with the key being the program term id, and the value being another map of program term info and keys
	 */
	public static Map<String, Set<String>> getCurrentProgramTermOptions()
	{		
		List<Program_Term__c> availableProgramTerms = apexQueryUtility.selectAllFrom('Program_Term__c', 'Program__r.Host_Institution__r.Country__r.Name, Term__r.Year__c, Term__r.Section__c', 'Term__r.Year__c >= ' + Date.Today().Year() + ' AND Is_Custom__c = FALSE AND Program__r.Active__c = TRUE ORDER BY Program__r.Host_Institution__r.Country__r.Name');
		
		Set<String> countries = new Set<String>();
		Set<String> sections = new Set<String>();
		Set<String> years = new Set<String>();
		
		for(Program_Term__c item : availableProgramTerms)
		{
			if(item != null && item.Program__c != null && item.Program__r.Host_Institution__c != null && Item.Program__r.Host_Institution__r.Country__c != null && item.Program__r.Host_Institution__r.Country__r.Name != null)
			{				
				if(item.Program__r.Host_Institution__r.Country__r.Name != 'Undecided')
				{
					countries.add(item.Program__r.Host_Institution__r.Country__r.Name);
				}
			}

			if(item != null && item.Term__c != null)
			{
				sections.add(item.Term__r.Section__c);
				years.add(String.valueOf(item.Term__r.Year__c));
			}
		}
		
		Map<String, Set<String>> programTermOptions = new Map<String, Set<String>>();
		programTermOptions.put('Countries', countries);
		programTermOptions.put('Sections', sections);
		programTermOptions.put('Years', years);
		
		return programTermOptions;
	}
}