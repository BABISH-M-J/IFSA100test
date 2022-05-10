/**
 * Wrapper class for the Application sObject
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class ifsaApplicationWrapper
{
	/**
	 * The application sObject.
	 */
	private Application__c application {get;set;}

	/**
	 * Constructor function. Queries for the application based on the Id.
	 * @param appId The Id of the application.
	 */
	public ifsaApplicationWrapper(Id appId)
	{
		this.application = (Application__c) apexQueryUtility.selectAllFrom('Application__c', 'Program_Term__r.Parent_Program_Term__c', 'Id = \'' + appId + '\'').get(0);
	}
	
	/**
	 * Constructor function. Sets the Application sObject.
	 * @return void
	 */
	public ifsaApplicationWrapper(Application__c anApplication)
	{
		this.application = anApplication;
	}

	/**
	 * Returns the list of Application Items that belong to this application.
	 * @param phase The application phase from which these items should come.
	 * @return This list of application items
	 */
	public List<Application_Item__c> getApplicationItems(String phase)
	{
    	return phase != null ? apexQueryUtility.selectAllFrom('Application_Item__c', 'Application__c = \'' + this.application.Id + '\' AND Phase__c = \'' + phase + '\'') : apexQueryUtility.selectAllFrom('Application_Item__c', 'Application__c = \'' + this.application.Id + '\' AND Phase__c != \'Not Visible\'');
	}

	/**
	 * Creates application items based off of the application. Instance wrapper for the invocable method.
	 */
	public List<Application_Item__c> populateApplicationItems()
	{
		ifsaApplicationWrapper.populateApplicationItems(new List<Id>{this.application.Id});
		return apexQueryUtility.selectAllFrom('Application_Item__c', 'Application__c = \'' + this.application.Id + '\'');
	}
    
    /**
     * Gets the list of all course registrations for this application.
     * @return The list of course registrations (in wrapper class)
     */
    public List<ifsaCourseRegistrationWrapper> getCourseRegistrations()
    {
        List<Course_Registration__c> courseRegistrationList = apexQueryUtility.selectAllFrom('Course_Registration__c', 'Host_Institution__r.Name, Butler_Department_Code__r.Name, Course__r.Untranslated_Course_Title__c', 'Application__c = \'' + this.application.Id + '\' ORDER BY Rank__c NULLS LAST');
        List<ifsaCourseRegistrationWrapper> courseRegList = new List<ifsaCourseRegistrationWrapper>();

        for(Course_Registration__c courseReg : courseRegistrationList)
        {
            courseRegList.add(new ifsaCourseRegistrationWrapper(courseReg));
        }
        
        return courseRegList;
    }
	
	/**
	 * Takes a view Model Instance and populates the appropriate data.
	 * @param viewModel The pre-Created view model.
	 * @return The same view model instance, populated with data.
	 */
	public customDocumentsViewModel populateViewModel(customDocumentsViewModel viewModel)
	{
		viewModel.applicationId = this.application.Id;
		viewModel.applicationName = this.application.Display_Name__c;
		
		return viewModel;
	}
	
	/**
	 * Takes a view Model Instance and populates the appropriate data.
	 * @param viewModel The pre-Created view model.
	 * @return The same view model instance, populated with data.
	 */
	public studentOnSiteViewModel populateViewModel(studentOnSiteViewModel viewModel)
	{
		viewModel.programID = this.application.Program_Term__r.Program__c;
		viewModel.programTermId = this.application.Program_Term__c;
		Program_Term__c  pt = [SELECT Id, Term__r.Section__c, Start_Of_Second_Term__c FROM Program_Term__c WHERE Id =: viewModel.programTermId];        
        if(pt.Term__r.Section__c == 'Academic Year')
        {
        	viewModel.secondTermName = 'Spring';
        	viewModel.hasSecondTerm = true;
        }	
    	else if (pt.Term__r.Section__c == 'Calendar Year')
		{
			viewModel.secondTermName = 'Fall';        
			viewModel.hasSecondTerm = true;
		}
    	else
    		viewModel.hasSecondTerm = false;

        viewModel.isSecondTermStarted = viewModel.hasSecondTerm && pt.Start_Of_Second_Term__c <= Date.today() ? true : false;       
		
		system.debug(this.application.CRF_Status__c == 'Not Started');
		system.debug(this.application.CRF_Status__c == 'Round 1 Complete' && viewModel.isSecondTermStarted);
		
		viewModel.isCourseRegEditable = this.application.CRF_Status__c == 'Not Started' || (this.application.CRF_Status__c == 'Round 1 Complete' && viewModel.isSecondTermStarted);
		viewModel.applicationId = this.application.Id;
				
		return viewModel;
	}

	/**
	 * Indicates whether or not the application has progressed past a status.
	 * @param status The status to evaluate
	 * @return True/False indicating if the status is before(true) or after(false) the current app status
	 */
	public Boolean isBeyond(String status)
	{
		List<String> options = apexConversionUtility.getPicklistStringValues(Application__c.Status__c);
        
        if(this.application.Status__c == 'Diverted' || this.application.Status__c == 'Dropped' || this.application.Status__c == 'Deferred')
        {
            return false;
        }
		
		//If we see the app status value first, then we have not progressed to the desired point.
		for(String option : options)
		{
			if(option == this.application.Status__c)
			{
				apexErrorUtility.debug(LoggingLevel.INFO, 'We matched the current status first.');
				return false;
			}
			else if(option == status)
			{
				apexErrorUtility.debug(LoggingLevel.INFO, 'We matched the tested status first.');
				return true;
			}
		}
		
		apexErrorUtility.throwException(new ifsaDataException('The given status did not match any valid status values and the application status is invalid. Application Status: ' + this.application.Status__c + ' Given value: ' + status));
		return null;
	}
	public Boolean hasHousing()
	{
		return this.application.Housing_Assignment__c != null && this.isBeyond('Submitted');
	}
	/**
	 * Used to indicate if the application is part of a custom program.
	 * @return Boolean value, true meaning YES, part of a custom program.
	 */
	public Boolean isCustom()
	{
		return this.application.Is_Custom__c;
	}

	/**
	 * Getter for the program term id.
	 * @return the Id of the program term.
	 */
	public Id getProgramTermId()
	{
		return this.application.Program_Term__c;
	}
	/**
	 * Getter for the program option id.
	 * @return the Id of the program term.
	 */
	/*public Id getProgramOptionId()
	{
		return this.application.Program_Option__c;
	}*/
	/**
	 * Getter for the parent program term id.
	 * @return the Id of the program term.
	 */
	public Id getParentProgramTermId()
	{
		return this.application.Program_Term__r.Parent_Program_Term__c;
	}

	/**
	 * Getter for the Applicant Id.
	 * @return the Id of the Applicant.
	 */
	public Id getApplicantId()
	{
		return this.application.Applicant__c;
	}

	/**
	 * Getter for the owner id.
	 * @return the Id of the user who owns the record.
	 */
	public Id getOwnerId()
	{
		return this.application.OwnerId;
	}
    
    public Id getHousingAssignmentId()
    {
        return this.application.Housing_Assignment__c;
    }

	/**
	 * Creates application items based off of the application
	 */
	@InvocableMethod(
					label='Populate Application Items'
					description='Examines the program term of the application and populates application items.')
	public static void populateApplicationItems(List<Id> applicationIds)
	{
		List<Application__c> applications = [SELECT Id, Program_Term__c,Previous_Application__c FROM Application__c WHERE Id IN: applicationIds];
		populateApplicationItems(applications);

	}
	public static void populateApplicationItems(List<Application__c> applications)
	{
		Map<Id, List<Application_Requirement__c>> applicationRequirementsMap = new Map<Id, List<Application_Requirement__c>>();
		Map<Id, Id> programTermParentMap = new Map<Id, Id>();
		List<Application_Item__c> applicationItems = new List<Application_Item__c>();
		Map<Id, Application__c> appMap = new Map<Id, Application__c>();
		for(Application__c application: applications)
		{
			if(!applicationRequirementsMap.containsKey(application.Program_Term__c))
			{
				applicationRequirementsMap.put(application.Program_Term__c, new List<Application_Requirement__c>());
			}			
		}
		for(Program_Term__c pt: [SELECT Id, Parent_Program_Term__c FROM Program_Term__c WHERE Id IN: applicationRequirementsMap.keySet()])
		{
			if(pt.Parent_Program_Term__c != null && !applicationRequirementsMap.containsKey(pt.Parent_Program_Term__c))
			{
				applicationRequirementsMap.put(pt.Parent_Program_Term__c, new List<Application_Requirement__c>());
				programTermParentMap.put(pt.Id, pt.Parent_Program_Term__c);
			}
		}
		System.debug(applicationRequirementsMap.keySet());
		for(Application_Requirement__c appReq: (List<Application_Requirement__c>) apexQueryUtility.selectAllFrom('Application_Requirement__c', 'RecordType.DeveloperName', 'Program_Term__c IN ' + apexQueryUtility.buildInClause(applicationRequirementsMap.keySet())))
		{
			applicationRequirementsMap.get(appReq.Program_Term__c).add(appReq);
		}
		List<RecordType> appItemRecordTypes = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Application_Item__c'];
		for(Application__c application : applications)
		{
			List<Application_Requirement__c> applicationRequirements = new List<Application_Requirement__c>();
			// Get AppReqs directly related to the application's program term
			applicationRequirements.addAll(applicationRequirementsMap.get(application.Program_Term__c));
			// Get AppReqs related to the application's program term's parent program term
			if(programTermParentMap.containsKey(application.Program_Term__c))
			{
				applicationRequirements.addAll(applicationRequirementsMap.get(programTermParentMap.get(application.Program_Term__c)));
			}
			system.debug(applicationRequirements.size());
			if(applicationRequirements.size()> 0)
			{
				applicationRequirements.sort();
				List<String> appReqRecordTypeNames = new List<String>();
				for(Application_Requirement__c req: applicationRequirements)
				{
					appReqRecordTypeNames.add(req.RecordType.DeveloperName);					
				}
				system.debug(appReqRecordTypeNames);
				Map<String, RecordType> appReqMap = new Map<String, RecordType>();
				for(RecordType rt: appItemRecordTypes)
				{
					appReqMap.put(rt.DeveloperName, rt);
					system.debug(rt.DeveloperName);
				}
				
				applicationRequirementsMap.put(application.Program_Term__c, applicationRequirements);
				for(Application_Requirement__c requirement : applicationRequirements)
				{
					system.debug(requirement.RecordType.DeveloperName);
					system.debug(appReqMap.get(requirement.RecordType.DeveloperName));
					applicationItems.add(AppReqToAppItem(requirement, application, appReqMap.get(requirement.RecordType.DeveloperName).Id));
				}
			}			
			if(application.Previous_Application__c != null)
			{
				appMap.put(application.Previous_Application__c, application);
			}
		}

		
		//List<Database.SaveResult> results = Database.insert(applicationItems);
		try {
			Database.insert(applicationItems);
			// added - powerfluence - application items not added - 006 - starts
			applicationTriggerContextUtility.setRequestedPopulateApplicationItems(false);
			// added - powerfluence - application items not added - 006 - starts
			} catch (Exception e) {
			// added - powerfluence - application items not added - 006 - starts
			applicationTriggerContextUtility.setRequestedPopulateApplicationItems(false);
			// added - powerfluence - application items not added - 006 - starts
			System.debug(e.getMessage());
			throw e;
		}
		//Clones application items if the new application has an old application
		if(!appMap.isEmpty())
		{
			for(Id key: appMap.keySet())
			{
				portalRemotingMethods.cloneApplicationItems(key, appMap.get(key));
			}
		}
	}
	
	public static Application_Item__c AppReqToAppItem(Application_Requirement__c requirement, Application__c application, Id appItemRecordType)
	{
		Application_Item__c item = new Application_Item__c();
		
		item.Name = requirement.Name;
		item.Directions__c = requirement.Directions__c != null ? requirement.Directions__c : 'Please complete this form.';
		item.Application__c = application.Id;
		item.Application_Requirement__c = requirement.Id;
		item.Text_to_Sign__c = requirement.Text_to_Sign__c;
		//item.Content_Link__c = requirement.Content_Link__c;
		item.Phase__c = requirement.Phase__c;
		//String recordTypeName = [SELECT DeveloperName FROM RecordType WHERE sObjectType = 'Application_Requirement__c' AND ID =: requirement.RecordTypeId].DeveloperName;
		item.RecordTypeId = appItemRecordType;
		item.Display_Catered_Option__c = requirement.Display_Catered_Option__c;
		item.Display_Dietary_Restrictions__c = requirement.Display_Dietary_Restrictions__c;
		item.Display_Food_Allergies_Option__c = requirement.Display_Food_Allergies_Option__c;
		item.Display_Gluten_Free_Option__c = requirement.Display_Gluten_Free_Option__c;
		item.Display_Halal_Option__c = requirement.Display_Halal_Option__c;
		item.Display_Kosher_Option__c = requirement.Display_Kosher_Option__c;
		item.Display_Lactose_Intolerant_Option__c = requirement.Display_Lactose_Intolerant_Option__c;
		item.Display_Neatness_Level_Option__c = requirement.Display_Neatness_Level_Option__c;
		item.Display_NonSmoking_Option__c = requirement.Display_NonSmoking_Option__c;
		item.Display_Off_Campus_Option__c = requirement.Display_Off_Campus_Option__c;
		item.Display_On_Campus_Option__c = requirement.Display_On_Campus_Option__c;
		item.Display_Other__c = requirement.Display_Other__c;
		item.Display_Private_Bathroom_Option__c = requirement.Display_Private_Bathroom_Option__c;
		item.Display_Religious_Accomodations__c = requirement.Display_Religious_Accomodations__c;
		item.Display_Roommate_Requests__c = requirement.Display_Roommate_Requests__c;
		item.Display_Self_Catered_Option__c = requirement.Display_Self_Catered_Option__c;
		item.Display_Shabbat__c = requirement.Display_Shabbat__c;
		item.Display_Signature__c = requirement.Display_Signature__c;
		item.Display_Single_Gender_Option__c = requirement.Display_Single_Gender_Option__c;
		item.Display_Single_Room_Option__c = requirement.Display_Single_Room_Option__c;
		item.Display_Smoking_Option__c = requirement.Display_Smoking_Option__c;
		item.Display_Typical_Bedtime_Option__c = requirement.Display_Typical_Bedtime_Option__c;
		item.Display_Vegan_Option__c = requirement.Display_Vegan_Option__c;
		item.Display_Vegetarian_Option__c = requirement.Display_Vegetarian_Option__c;
		item.Number_Of_Recommendations__c = requirement.Number_of_Recommendations__c;		
		item.Question_1_Override__c = requirement.Question_1_Override__c;
		item.Question_2_Override__c = requirement.Question_2_Override__c;
		item.Question_3_Override__c = requirement.Question_3_Override__c;
		item.Question_4_Override__c = requirement.Question_4_Override__c;
		item.Question_5_Override__c = requirement.Question_5_Override__c;
		item.Question_6_Override__c = requirement.Question_6_Override__c;
		item.Question_7_Override__c = requirement.Question_7_Override__c;
		item.Question_8_Override__c = requirement.Question_8_Override__c;
		item.Question_9_Override__c = requirement.Question_9_Override__c;
		item.Question_10_Override__c = requirement.Question_10_Override__c;
		item.Question_11_Override__c = requirement.Question_11_Override__c;
		item.Question_12_Override__c = requirement.Question_12_Override__c;
		item.Question_13_Override__c = requirement.Question_13_Override__c;
		item.Question_14_Override__c = requirement.Question_14_Override__c;
		item.Question_15_Override__c = requirement.Question_15_Override__c;
		item.Question_16_Override__c = requirement.Question_16_Override__c;
		item.Question_17_Override__c = requirement.Question_17_Override__c;
		item.Question_18_Override__c = requirement.Question_18_Override__c;
		item.Question_19_Override__c = requirement.Question_19_Override__c;
		item.Question_20_Override__c = requirement.Question_20_Override__c;
		item.Question_21_Override__c = requirement.Question_21_Override__c;
		item.Question_22_Override__c = requirement.Question_22_Override__c;
		item.Question_23_Override__c = requirement.Question_23_Override__c;
		item.Question_24_Override__c = requirement.Question_24_Override__c;
		item.Question_25_Override__c = requirement.Question_25_Override__c;
		item.Question_26_Override__c = requirement.Question_26_Override__c;
		return item;
	}
}