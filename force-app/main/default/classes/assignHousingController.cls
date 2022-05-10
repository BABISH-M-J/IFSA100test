/**
 * Controller for assign housing VF page,
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public with sharing class assignHousingController {
	//TODO This class and it's related Visualforce page needs to be refactored into a Lighting Web Component and added to the Application Lightning page
	/**
	 * Viewmodel <<assignHousingViewModel>> contains all of the data for the user to interact with on the VisualForce page
	 */
	public assignHousingViewModel viewModel {get;set;}
	/**
	 * Constructor, gets all of the data to populate viewModel property
	 */
	public assignHousingController()
	{
		// Creates an new viewModel
		this.viewModel = new assignHousingViewModel();        
		// Gets the current application
		this.viewModel.application = [SELECT Id, Name, Program_Term__c, Program_Term__r.Parent_Program_Term__c, Program_Country__c FROM Application__c WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
		// List to hold the available housing options for the applications program term/program option
		List<Program_Term_Housing_Option__c> housingOptions = new List<Program_Term_Housing_Option__c>();		
		if(viewModel.application.Program_Term__r.Parent_Program_Term__c == null)
		{
			housingOptions = [SELECT Id, Housing_Option__c, Housing_Option__r.Description__c, Housing_Option__r.Name FROM Program_Term_Housing_Option__c WHERE Program_Term__c =: viewModel.application.Program_Term__c];
		}
		else
		{
			housingOptions = [SELECT Id, Housing_Option__c, Housing_Option__r.Description__c, Housing_Option__r.Name FROM Program_Term_Housing_Option__c WHERE Program_Term__c =: viewModel.application.Program_Term__c];
			if(housingOptions.isEmpty())
			{
				housingOptions = [SELECT Id, Housing_Option__c, Housing_Option__r.Description__c, Housing_Option__r.Name FROM Program_Term_Housing_Option__c WHERE Program_Term__c =: viewModel.application.Program_Term__r.Parent_Program_Term__c];
			}
		}
		// List to hold the Ids of the options
		this.viewModel.housingIds = new List<Id>();
		for(Program_Term_Housing_Option__c ptho: housingOptions)
		{
			this.viewModel.housingIds.add(ptho.Housing_Option__c);
			system.debug(ptho.Housing_Option__c);
		}
		// Gets the housing prefernces the student ranked in the housing form
	
	    this.viewModel.housingPreferences = [SELECT Id, Program_Term_Housing_Option__c, Housing_Option_Name__c, Rank__c FROM Housing_Preference__c WHERE Application__c =: viewModel.application.Id ORDER BY Rank__c ASC];
	    if(!this.viewModel.housingPreferences.isEmpty())
	    {
	    	this.viewModel.hasPrefs = true;	    
			this.getCities(this.viewModel.application.Program_Country__c);
	    }
	    else
	    {
	    	this.viewModel.hasPrefs = false;
	    	apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'This student has not selected their housing preferences yet'));
	    }
	}
	/**
	 * Gets the cities where from the country name
	 * @param countryName
 	 */
	private void getCities(String countryName)
	{		
		List<Housing_Assignment__c> housingAssignments = [SELECT Id, Name, Locality__c, Country__r.Name, Housing_Option__c, Housing_Option__r.Name FROM Housing_Assignment__c WHERE Housing_Option__c IN: this.viewModel.housingIds AND Country__r.Name =: countryName];
	    this.viewModel.housingPreferences = [SELECT Id, Program_Term_Housing_Option__c, Housing_Option_Name__c, Rank__c FROM Housing_Preference__c WHERE Application__c =: viewModel.application.Id ORDER BY Rank__c ASC];
	    List<String> housingOptions = new List<String>();
	    Set<String> cities = new Set<String>();			    
		for(Housing_Assignment__c assignment: housingAssignments)
		{				
			if(cities.isEmpty())
			{
				this.viewModel.cities.add(assignment.Locality__c);
				cities.add(assignment.Locality__c);
			}
			else
			{
				if(!cities.contains(assignment.Locality__c))
				{
					this.viewModel.cities.add(assignment.Locality__c);
					cities.add(assignment.Locality__c);
				}
			}		
		}
	}
	/**
	 * Gets the housing assignments avaiable for that city and application
	 * @param cityName
	 * @param applicationId
 	 */
	@RemoteAction
	public static List<String> getHousing(String cityName, String applicationId)
	{
		List<String> housingOptions = new List<String>();
		if(cityName != 'none')
		{
			List<Housing_Assignment__c> housingAssignments = [SELECT Id, Name, Locality__c, Country__r.Name, Housing_Option__c, Housing_Option__r.Name FROM Housing_Assignment__c WHERE Locality__c =: cityName ORDER BY Name];
		    List<Housing_Preference__c> housingPreferences = [SELECT Id, Program_Term_Housing_Option__c, Housing_Option_Name__c, Rank__c FROM Housing_Preference__c WHERE Application__c =: applicationId ORDER BY Rank__c ASC];		    
		    for(Housing_Preference__c pref: housingPreferences)
		    {
		    	for(Housing_Assignment__c assignment: housingAssignments)
		    	{
		    		if(pref.Housing_Option_Name__c == assignment.Housing_Option__r.Name)
		    		{						
		    			housingOptions.add(assignment.Name);
		    		}
		    	}
		    }		    
		}
		return housingOptions;
	}
	/**
	 * Redirect back to the application record
	 * @return PageReference 
 	*/
	public PageReference returnToApp()
	{
		PageReference appPage = new PageReference('/' + this.viewModel.application.Id);
	    appPage.setRedirect(true);
	    return appPage;
	}
	/**
	 * Method to assign housing to the student's application
	 * @param housingAssignment The name of the housing assignement to be assigned
	 * @param applicationId The id of the application being worked with
 	 */
	@RemoteAction
	public static Boolean assignHousing(String housingAssignment, String applicationId)       
	{
		
		system.debug(housingAssignment);
		Application__c app = new Application__c();
		app.Id = applicationId;
		app.Housing_Assignment__c = [SELECT Id FROM Housing_Assignment__c WHERE Name =: housingAssignment].get(0).Id;
		
		database.update(app);
	    return true;
	}	
}