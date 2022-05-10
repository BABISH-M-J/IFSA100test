/**
 * @description The remoting methods used in the portals.
 * @author Cameron Ames
 */
public without sharing class portalRemotingMethods
{
	/**
	 * @description Constructor to enable use with any IFSA controllers.
	 */
	public portalRemotingMethods(ifsaBaseController controller){}
	/**
	 * @description Create records for the student's independent travel
	 * @param name - The type of travel
	 * @param info - Free text the student can enter about their travel plans
	 * @param data - the flight data
	 * @param applicationItemId - Id of the application item
	 * @return Boolean - Success of the method
	 */
  	@RemoteAction
	public static Boolean submitIndependentTravel(String info, List<Map<String,String>> data, Id applicationItemId)
	{
		Application_Item__c appItem = [SELECT Id, Name, Application__r.Name, Application__c, Status__c FROM Application_Item__c WHERE Id =: applicationItemId];    
	    Application__c application = [SELECT Id, OwnerId, Applicant__c, Applicant__r.Name, Is_Custom__c, Program_Term__r.Term__r.Name, Program_Term__r.Program__r.Resident_director_team_member__c FROM Application__c WHERE Id =: appItem.Application__c];
	  	
	    Travel_Plan__c travelPlan = new Travel_Plan__c();        
		// Create Travel Plan Record
		travelPlan.Name = application.Applicant__r.Name + '\'s ' + application.Program_Term__r.Term__r.Name + ' Travel Plan';
		travelPlan.Flag__c = 'Independent';
		
		
		travelPlan.Name = travelPlan.Name.length() >= 80 ? travelPlan.Name.subString(0,79) : travelPlan.Name;
	    travelPlan.Is_Custom__c = application.Is_Custom__c;
	    travelPlan.Travel_Plan_Information__c = info;
	    travelPlan.Status__c = 'Submitted For Approval';
        // Save the travel plan record
	    Database.SaveResult result = Database.insert(travelPlan);
        if (!result.isSuccess())
	    {
	        Return result.isSuccess();
	    }

		//Create Task to notify PA of student's Travel Plan
		Task travelPlanApproval = new Task();
		travelPlanApproval.description = travelPlan.Travel_Plan_Information__c;
		travelPlanApproval.OwnerId = application.Program_Term__r.Program__r.Resident_director_team_member__c != null ? application.Program_Term__r.Program__r.Resident_director_team_member__c : application.OwnerId;		
		travelPlanApproval.Priority = 'Normal';
		travelPlanApproval.recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Travel Plan').getRecordTypeId();
		travelPlanApproval.Status = 'Not Started';
		travelPlanApproval.Subject = 'Student Travel Plan needs approval';
		travelPlanApproval.WhatId = travelPlan.Id;
		travelPlanApproval.WhoId = application.Applicant__c;
		result = Database.insert(travelPlanApproval);
        if (!result.isSuccess())
	    {
	        Return result.isSuccess();
	    }
		
		// Create the flight records
	    List<Flight__c> flightList = new List<Flight__c>();	  
	    for(Map<String, String> item : data)
	    {
	        Flight__c flight = new Flight__c();        
	        flight.Flight_Number__c = item.get('flightNumber');
	        flight.Airline__c = item.get('airlineName');
	        flight.Name = flight.Airline__c + ' ' + flight.Flight_Number__c;
	        flight.Type__c = item.get('type');
	        flight.Departure_Airport_Code__c = item.get('Departure_Airport_Code__c');
	        flight.Arrival_Airport_Code__c = item.get('Arrival_Airport_Code__c');
	        DateTime DepartureTime = portalRemotingMethods.parseDate(item.get('departureTime'));
	        DateTime ArrivalTime = portalRemotingMethods.parseDate(item.get('arrivalTime'));
	        //Parse Departure Time
	        flight.Departure_Year__c = DepartureTime.Year();
	        flight.Departure_Month__c = DepartureTime.Month();
	        flight.Departure_Day__c = DepartureTime.Day();
	        flight.Departure_Hour__c = DepartureTime.Hour();
	        flight.Departure_Minute__c = DepartureTime.Minute();
	        //Parse Arrival Time
	        flight.Arrival_Year__c = ArrivalTime.Year();
	        flight.Arrival_Month__c = ArrivalTime.Month();
	        flight.Arrival_Day__c = ArrivalTime.Day();
	        flight.Arrival_Hour__c = ArrivalTime.Hour();
	        flight.Arrival_Minute__c = ArrivalTime.Minute();
	        //Associate flight with travel plan
	        flight.Travel_Plan__c = travelPlan.Id;
	        flightList.add(flight);
	    }

	    // Save the flights
	    Database.SaveResult[] results = Database.insert(flightList);
	    for(Database.SaveResult sr : results)
	    {
		    if(!sr.isSuccess())
		    {
		        return sr.isSuccess();
		    }
		}
	    List<Application_Flight__c> appFlightsList = new List<Application_Flight__c>();
	    for(Flight__c flight: flightList)
	    {
	        //Create Application Flight Junction Object and associate with application and flight
	        Application_Flight__c appFlight = new Application_Flight__c();
	        appFlight.application__c = application.Id;
	        appFlight.Flight__c = flight.Id;
	        appFlightsList.add(appFlight);
	    }
		// Save the app-flight junction
	    results = Database.insert(appFlightsList);	    
	    for(Database.SaveResult sr : results)
	    {
		    if(!sr.isSuccess())
		    {
		        return sr.isSuccess();
		    }
		}
	    // Update the travel plan
	    application.Travel_Plan__c = travelPlan.Id;
	    appItem.Status__c = 'Complete';
	    
	    results = Database.update(new List<SObject>{appItem, application});
	    for(Database.SaveResult sr : results)
	    {
		    if(!sr.isSuccess())
		    {
		        return sr.isSuccess();
		    }
		}
	    return true;
	}
	/**
	 * @description Parse string to a DateTime object
	 * @param theDate - string to parse
	 * @return DateTime - The parsed DateTime
	 */
	public static Datetime parseDate(String theDate)
	{
		if(theDate == null || theDate.length() <19)
		{
            Return null;
		}
		Return Datetime.newInstance(Integer.valueOf(theDate.subString(0, 4)), Integer.valueOf(theDate.subString(5, 7)), Integer.valueOf(theDate.subString(8, 10)), Integer.valueOf(theDate.subString(11, 13)), Integer.valueOf(theDate.subString(14, 16)), 0);
	}
	/**
	 * @description Takes course registration information And submits it.
	 * @param serializedViewModel An instance of the studentOnSiteViewModel, serialized as a JSON String.
	 * @param appId The id of the student's application record
	 * @return boolean indicating whether Or Not the save was successful.
	 */
	@RemoteAction
	public static Boolean submitCourseRegistration(String serializedViewModel, String appId)
	{
	   return portalOnSiteRemotingMethods.submitCourseRegistration(serializedViewModel, appId);
	}

	/**
	 * @description Searches for courses given a student's host institution and search term.
	 * @param programTermId The Id of the program term.
	 * @param searchTerm The name of the course that the student has started typing
	 * @return the list of appropriate courses.
	 */
    @RemoteAction
    public static List<studentOnSiteCourseRegViewModel> searchForCourses(Id hostInstitutionId, String searchTerm) 
    {        
    	return portalOnSiteRemotingMethods.searchForCourses(hostInstitutionId, searchTerm);
    }

	/**
	 * @description Obtains the Id of the program approval (or null) on a student's application.
	 * @param applicationId The Id of the student application.
	 * @return The Id of the program approval application item.
	 */
	@RemoteAction
	public static Id getProgramApprovalId(Id applicationId)
	{
		List<Application_Item__c> appItems = [select Id FROM Application_Item__c WHERE Application__C =: applicationId AND RecordType.DeveloperName =: 'Program_Approval'];

		if(appItems.size() != 1)
		{
			return null;
		}
		
		return appItems.get(0).Id;
	}
	
	/**
	 * @description Retrieves all details about an application item.
	 * @param Id The application item id.
	 * @return The application item details view model.
	 */
	@RemoteAction
	public static studentApplyItemDetailsViewModel getApplicationItemDetails(String Id)
	{
	    Application_Item__c appItem;
	    Application__c application;
	    Account acct;
	    Contact studentContact;
	    Housing_Option__c housingOption;
	    Program_Term__c programTerm;
	    Program_Term__c parentProgramTerm;
	    String arrivalPlanSource = '';
	    Arrival_Plan__c plan;
	    List<Program_Term_Housing_Option__c> ptHousingOptions = new List<Program_Term_Housing_Option__c>();
	    List<Housing_Preference__c> hPrefs = new List<Housing_Preference__c>();
	    List<Housing_Option__c> housingOptionList = new List<Housing_Option__c>();
	    List<Flight__c> flights = new List<Flight__c>();
		List<Course__c> courses = new List<Course__c>();
		List<Recommendation__c> recommendations = new List<Recommendation__c>();
		List<Contact> emergencyContacts = new List<Contact>();
		List<String> attachments = new List<String>();
		List<Attachment> files = new List<Attachment>();
		List<FinancialAidItemViewModel> aidItemViewModel = new List<FinancialAidItemViewModel>();
		//ACARSON set integer for base price
		Integer base = 0 ;
		studentApplyItemDetailsViewModel viewModel = new studentApplyItemDetailsViewModel();
	    try
	    {
	    	appItem = (Application_Item__c) apexQueryUtility.selectAllFrom('Application_Item__c', 'Application__r.Applicant__r.Directory_Information_Opt_Out__c, Application__r.Owner.FirstName, Application__r.Owner.LastName, Application__r.Owner.Email, RecordType.DeveloperName, Application__r.Applicant__c, Application__r.Program_Term__c, Application__r.Program_Term__r.Is_Custom__c, Application__r.Program_Term__r.Program__r.Language_Of_Instruction__c, Application_Requirement__r.Hide_Study_Abroad_Wording__c, Application_Requirement__r.Dynamic_Form__c' , 'Id = \'' + Id + '\'').get(0);
	    	application = (Application__c) apexQueryUtility.selectAllFrom('Application__c', 'Program_Term__r.Parent_Program_Term__c', 'Id = \'' + appItem.Application__c + '\'').get(0);
	    	programTerm = (Program_Term__c) apexQueryUtility.selectAllFrom('Program_Term__c', 'Id = \'' + application.Program_Term__c + '\'').get(0);
	    	parentProgramTerm = programTerm.Parent_Program_Term__c != null ? (Program_Term__c) apexQueryUtility.selectAllFrom('Program_Term__c', 'Id = \'' + programTerm.Parent_Program_Term__c + '\'').get(0) : null;
	    	studentContact = [SELECT Id, Passport_Country_Of_Issuance__c, Passport_Expiration_Date__c, Passport_Number__c, FirstName, LastName, Directory_Information_Opt_Out__c FROM Contact WHERE Id =: application.Applicant__c];
	    	acct = [SELECT Id, Name, c2g__CODAAccountTradingCurrency__c FROM Account WHERE Id =: application.Account_ID__c];
	    	/*if(appItem.Housing_Option__c != null)
	    	{
	    		housingOption = [SELECT Id, Name FROM Housing_Option__c WHERE Id =: appItem.Housing_Option__c];
	    	}*/
	    	List<Program_Fee__c> baseHousing = new List<Program_Fee__c>();

	    	if(appItem.RecordType.DeveloperName == 'Housing_Preferences_Form')
	    	{
	    		if(appItem.Status__c == 'Incomplete')
	    		{
	    			List<Id> idList = new List<Id>();
	    		//ACARSON added field for supplemental cost on ptHousing otions and added new query to get the bas hosing fee
	    		if(application.Program_Term__r.Parent_Program_Term__c == null)
	    		{
					ptHousingOptions = [SELECT Id, Housing_Option__c, Housing_Option__r.Description__c, Housing_Option__r.Name, Supplemental_Housing_Price__c FROM Program_Term_Housing_Option__c WHERE Program_Term__c =: application.Program_Term__c ORDER BY Housing_Option__r.Name];
					baseHousing = [SELECT Id, Name, Amount__c FROM Program_Fee__c WHERE (Name = 'Housing Fee' OR Name='Accommodation') AND Program_Term__c =: application.Program_Term__c];
				}
				else
				{
		    		ptHousingOptions = [SELECT Id, Housing_Option__c, Housing_Option__r.Description__c, Housing_Option__r.Name, Supplemental_Housing_Price__c FROM Program_Term_Housing_Option__c WHERE Program_Term__c =: application.Program_Term__c ORDER BY Housing_Option__r.Name];
		    		baseHousing = [SELECT Id, Name, Amount__c FROM Program_Fee__c WHERE (Name = 'Housing Fee' OR Name='Accommodation') AND Program_Term__c =: application.Program_Term__c];
		    		if(ptHousingOptions.isEmpty())
		    		{
		    			ptHousingOptions = [SELECT Id, Housing_Option__c, Housing_Option__r.Description__c, Housing_Option__r.Name, Supplemental_Housing_Price__c FROM Program_Term_Housing_Option__c WHERE Program_Term__c =: application.Program_Term__r.Parent_Program_Term__c ORDER BY Housing_Option__r.Name];
		    			baseHousing = [SELECT Id, Name, Amount__c FROM Program_Fee__c WHERE (Name = 'Housing Fee' OR Name='Accommodation') AND Program_Term__c =: application.Program_Term__r.Parent_Program_Term__c];
		    		}
	    		}
	    		for(Program_Fee__c pf : baseHousing)
	    		{
	    			base += pf.Amount__c.intValue();
	    		}
	    		for(Program_Term_Housing_Option__c ptHousingOption : ptHousingOptions)
	    		{
	    			idList.add(ptHousingOption.Housing_Option__c);
	    		}
	    		housingOptionList = [SELECT Id, Name FROM Housing_Option__c WHERE Id IN: idList];	
	    		}
	    		else
	    		{
	    			hPrefs = [SELECT Id, Housing_Option_Name__c, Program_Term_Housing_Option__r.Housing_Option__r.Description__c, Rank__c FROM Housing_Preference__c WHERE Application__c =: appItem.Application__c];
	    		}
	    	}
			if(appItem.RecordType.DeveloperName == 'Personal_Essay')
			{
				for(Personal_Essay_Question__mdt eq: [SELECT MasterLabel, DeveloperName, Language__c, Question_Text__c FROM Personal_Essay_Question__mdt WHERE Is_Active__c = TRUE ORDER BY DeveloperName])
				{
					if(eq.Language__c == 'Spanish' && appItem.Application__r.Program_Term__r.Program__r.Language_Of_Instruction__c == 'Spanish' || eq.Language__c == 'English' && appItem.Application__r.Program_Term__r.Program__r.Language_Of_Instruction__c != 'Spanish')
					viewModel.essayQuestions.add(new model_Essay_Question(eq));
				}
			}
			if(appItem.RecordType.DeveloperName == 'Transcript')
			{
				courses = [SELECT Id, Name, Course_Code__c, Application_Item__c FROM Course__c WHERE Application_Item__c =: appItem.Id];
			}
			if(appItem.RecordType.DeveloperName == 'Recommendation')
			{
				recommendations = [SELECT Id, Name, Email_Address__c, Status__c FROM Recommendation__c WHERE Application_Item__c =: appItem.Id];
			}
			if(appItem.RecordType.DeveloperName == 'Addresses' || appItem.RecordType.DeveloperName == 'Update_Emergency_Contact')
			{
				try
				{
					emergencyContacts = [SELECT Id, Name, RecordTypeId, Email, Phone, MobilePhone, HomePhone, Do_Not_Contact__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, FirstName, LastName, Emergency_Contact__c, Send_Marketing_Materials__c, Relationship_With_Student__c, Student__c FROM Contact WHERE Student__c =: appItem.Application__r.Applicant__c AND (RecordType.Name = 'Other' OR RecordType.Name = 'Emergency Contact' OR RecordType.Name = 'Parent Contact')];
				}
				catch( ListException e)
				{
					system.debug('Student did not have any related contacts');
				}				
			}
			if(appItem.RecordType.DeveloperName == 'Signature' || appItem.RecordType.DeveloperName == 'Scholarships' || appItem.RecordType.DeveloperName == 'C_C_Form' || appItem.RecordType.DeveloperName == 'Medical_Form' || appItem.RecordType.DeveloperName == 'Custom_Medical_Form' || appItem.RecordType.DeveloperName == 'Spanish_Language_Evaluation' || appItem.RecordType.DeveloperName == 'Class_Interest_Form')
			{
				string query = 'SELECT Id, Name, Body FROM Attachment WHERE ParentID =: appItem.Id ORDER BY CreatedDate DESC';
				if(appItem.RecordType.DeveloperName == 'Class_Interest_Form'){
					query = query + ' LIMIT 1';
				}
				List<Attachment> attach = Database.query(query);
				for(Attachment a: attach)
				{
					attachments.add(EncodingUtil.Base64Encode(a.body));
				}
			}
			if(appItem.RecordType.DeveloperName == 'Free_Form_Upload' || appItem.RecordType.DeveloperName == 'Financial_Obligation_Form' || appItem.RecordType.DeveloperName == 'Download_Upload' || appItem.RecordType.DeveloperName == 'Upload' || appItem.RecordType.DeveloperName == 'Course_Preference_Form' || appItem.RecordType.DeveloperName == 'English_Language_Results' || appItem.RecordType.DeveloperName == 'Confidentiality_Disclosure_Form' || appItem.RecordType.DeveloperName == 'Visa_Form' || appItem.RecordType.DeveloperName == 'Tutorial_Request_Form' || (appItem.RecordType.DeveloperName == 'No_Action' && appItem.Name.contains('Transcript')) || appItem.RecordType.DeveloperName == 'Passport_Copy' || appItem.RecordType.DeveloperName == 'Class_Interest_Form')
			{
				string query = 'SELECT Id, Name, CreatedDate, ContentType, Description FROM Attachment WHERE ParentID =: appItem.Id ORDER BY CreatedDate DESC';
				if(appItem.RecordType.DeveloperName == 'Class_Interest_Form'){
					query = query + ' LIMIT 1';
				}
				List<Attachment> attach = Database.query(query); 
				if(attach.size() > 0)
				{
					files.addAll(attach);
				}
			}
			if(appItem.RecordType.DeveloperName == 'Scholarship')
			{
				List<Financial_Aid_Item__c> aidItems = [SELECT Id, Name, Disbursement_Amount__c, Disbursement_Date__c, Financial_Aid_Types__c FROM Financial_Aid_Item__c WHERE Application__c =: appItem.Application__c];
				for(Financial_Aid_Item__c aidItem: aidItems)
				{
					FinancialAidItemViewModel vm = new FinancialAidItemViewModel();
					vm.aidType = aidItem.Financial_Aid_Types__c;
    				vm.disbursmentAmount = aidItem.Disbursement_Amount__c;
    				vm.disbursmentDate = aidItem.Disbursement_Date__c;
    				aidItemViewModel.add(vm);
    				system.debug(vm.disbursmentAmount);
				}
			}
	    }
	    catch(Exception e)
	    {
	    	System.debug(LoggingLevel.ERROR, e.getMessage());
	    	return null;
	    }
	    List<Map<String,String>> housingOptions = new List<Map<String, String>>();
	    if(appItem.RecordType.DeveloperName == 'Housing_Preferences_Form' && appItem.Status__c == 'Incomplete')
	    {		    
		    for(Program_Term_Housing_Option__c option : ptHousingOptions)
		    {
		    	Map<String, String> housingOptionMap = new Map<String, String>();
		    	housingOptionMap.put('Description', option.Housing_Option__r.Description__c);
		    	housingOptionMap.put('Name', option.Housing_Option__r.Name);
		    	housingOptionMap.put('Id', option.Id);
		    	//ACARSON setting supplemental price ('Price') and base housing price (BasePrice) for the housing app item
		    	housingOptionMap.put('Price', String.valueOf(option.Supplemental_Housing_Price__c));
		    	housingOptionMap.put('BasePrice', String.valueOf(base));
		    	housingOptions.add(housingOptionMap);
		    }
		    viewModel.housingRankOptions = new List<Integer>();
			Integer maxPreferences = housingOptions.size() > 6 ? housingOptions.size() : 5;
			for(Integer i = 1; i <= housingOptions.size(); i++)
			{
                viewModel.housingRankOptions.add(i);
			}
		}
		else if(appItem.RecordType.DeveloperName == 'Housing_Preferences_Form' && appItem.Status__c == 'Complete')
		{
		    for(Housing_Preference__c pref : hPrefs)
		    {
		    	Map<String, String> housingOptionMap = new Map<String, String>();
		    	housingOptionMap.put('Description', pref.Program_Term_Housing_Option__r.Housing_Option__r.Description__c);
		    	housingOptionMap.put('Name', pref.Housing_Option_Name__c);
		    	housingOptionMap.put('Id', pref.Id);
		    	housingOptionMap.put('Rank', pref.Rank__c.toPlainString());
		    	housingOptions.add(housingOptionMap);
		    }
		}
	    
	    viewModel.applicationId = appItem.Application__c;
	    viewModel.academicProbation = appItem.Academic_Probation__c;
	    viewModel.academicProbationExplanation = appItem.Academic_Probation_Explanation__c;
	    viewModel.allergicTo = appItem.Allergic_To__c;
	    viewModel.approvalToStudy = appItem.Approval_to_Study__c;
	    viewModel.approvalToStudyExplanation = appItem.Approval_to_Study_Explanation__c;
	    viewModel.billingCity = appItem.billing_City__c;
	    viewModel.billingCountry = appItem.billing_Country__c;
	    viewModel.billingState = appItem.billing_State__c;
	    viewModel.billingStreet = appItem.billing_Street__c;
	    viewModel.billingZip = appItem.billing_ZIP_Code__c;
	    viewModel.catered = appItem.Prefers_Catered__c;
	    viewModel.ccParticipation = appItem.C_C_Participation__c;
	    viewModel.ceAuralComprehension = appItem.CE_Aural_Comprehension__c;
	    viewModel.ceReading = appItem.CE_Reading__c;
	    viewModel.ceSpeaking = appItem.CE_Speaking__c;
	    viewModel.ceWriting = appItem.CE_Writing__c;
	    viewModel.commercialTeachingRosettaStoneEtc = appItem.Commercial_Teaching_Rosetta_Stone_etc__c;
	    viewModel.communityCourses = appItem.Community_Courses__c;
	    viewModel.content = appItem.Content__c;
	    viewModel.contentLink = appItem.Content_Link_New__c!= null ? appItem.Content_Link_New__c : appItem.Content_Link_Old__c;
	    //viewModel.contentLink = viewModel.contentLink != null ?EncodingUtil.urlDecode(viewModel.contentLink, 'UTF-8') : '';
	    system.debug(viewModel.contentLink);
	    viewModel.currentTreatment = appItem.Current_Treatment__c;
	    viewModel.currentTreatmentDescription = appItem.Current_Treatment_Description__c;
	    viewModel.dietaryRestrictions = appItem.Dietary_Restrictions__c;
	    viewModel.directions = appItem.Directions__c;
	    viewModel.disciplinaryActionExplanation = appItem.Disciplinary_Action_Explanation__c;
	    viewModel.discipline = appItem.Discipline__c;
	    viewModel.displaycatered = appItem.Display_Catered_Option__c;
	    viewModel.displaydietaryrestrictions = appItem.Display_Dietary_Restrictions__c;
	    viewModel.displayfoodallergies = appItem.Display_Food_Allergies_Option__c;
	    viewModel.displayglutenfree = appItem.Display_Gluten_Free_Option__c;
	    viewModel.displayHalal = appItem.Display_Halal_Option__c;
	    viewModel.displaykosher = appItem.Display_Kosher_Option__c;
	    viewModel.displaylactoseintolerant = appItem.Display_Lactose_Intolerant_Option__c;
	    viewModel.displayneatnesslevel = appItem.Display_Neatness_Level_Option__c;
	    viewModel.displaynonsmoking = appItem.Display_NonSmoking_Option__c;
	    viewModel.displayoffcampus = appItem.Display_Off_Campus_Option__c;
	    viewModel.displayoncampus = appItem.Display_On_Campus_Option__c;
	    viewModel.displayother = appItem.Display_Other__c;
	    viewModel.displayprivatebathroom = appItem.Display_Private_Bathroom_Option__c;
	    viewModel.displayReligiousAccomodations = appItem.Display_Religious_Accomodations__c;
	    viewModel.displayroommaterequests = appItem.Display_Roommate_Requests__c;
	    viewModel.displayselfcatered = appItem.Display_Self_Catered_Option__c;
	    viewModel.displaysinglegender = appItem.Display_Single_Gender_Option__c;
	    viewModel.displaysingleroom = appItem.Display_Single_Room_Option__c;
	    viewModel.displaysmoking = appItem.Display_Smoking_Option__c;
	    viewModel.displayShabbat = appItem.Display_Shabbat__c;
	    viewModel.displaytypicalbedtime = appItem.Display_Typical_Bedtime_Option__c;
	    viewModel.displayVegan = appItem.Display_Vegan_Option__c;
	    viewModel.displayvegetarian = appItem.Display_Vegetarian_Option__c;
	    viewModel.emergencyTreatment = appItem.Emergency_Treatment__c;
	    viewModel.epiPen = appItem.Epi_Pen__c;
	    viewModel.evaluatorEmail = appItem.Evaluator_Email__c;
		viewModel.evaluatorName = appItem.Evaluator_Name__c;
		viewModel.fastFormsTemplateID = appItem.Form_Template_ID__c;
	    viewModel.fastFormsURL = appItem.Fast_Forms_URL__c;
	    viewModel.foodAllergies = appItem.Food_Allergies__c || appItem.Prefers_Food_Allergies__c;
	    viewModel.foodAllergyArrangementDescription = appItem.Food_Allergy_Arrangement_Description__c;
	    viewModel.foodAllergySpecialArrangments = appItem.Food_Allergy_Special_Arrangements__c;
	    viewModel.glutenFree = appItem.Prefers_Gluten_Free__c;
	    viewModel.goodStanding = appItem.Good_Standing__c;
	    viewModel.goodStandingExplanation = appItem.Good_Standing_Explanation__c;
	    viewModel.halal = appItem.Prefers_Halal__c;
	    viewModel.hAuralComprehension = appItem.H_Aural_Comprehension__c;
	    viewModel.heritageSpeaker = appItem.Heritage_Speaker__c;
	    viewModel.highSchoolCourses = appItem.High_School_Courses__c;
	    viewModel.housingOption = housingOption!= null ? housingOption.Name : null;
	    viewModel.housingOptions = housingOptions;
	    viewModel.housingRestrictions = appItem.Housing_Restrictions__c;
	    viewModel.housingRestrictionsDescription = appItem.Housing_Restrictions_Description__c;
	    viewModel.hReading = appItem.H_Reading__c;
	    viewModel.hSpeaking = appItem.H_Speaking__c;
	    viewModel.hWriting = appItem.H_Writing__c;
	    viewModel.id = appItem.Id;
	    viewModel.isComplete = appItem.Status__c == 'Complete';
        viewModel.isStarted = appItem.Status__c == 'Started';
        viewModel.isCustom = appItem.Application__r.Program_Term__r.Is_Custom__c;
	    viewModel.kosher = appItem.Prefers_Kosher__c;
	    viewModel.language = appItem.Application__r.Program_Term__r.Program__r.Language_Of_Instruction__c;
	    viewModel.lactoseIntolerant = appItem.Prefers_Lactose_Intolerant__c;
	    viewModel.learningDisability = appItem.Learning_Disability__c;
	    viewModel.learningDisabilityDescription = appItem.Learning_Disability_Description__c;	    
	    viewModel.mailingCity = appItem.Mailing_City__c;
	    viewModel.mailingCountry = appItem.Mailing_Country__c;
	    viewModel.mailingState = appItem.Mailing_State__c;
	    viewModel.mailingStreet = appItem.Mailing_Street__c;
	    viewModel.mailingZip = appItem.Mailing_ZIP_Code__c;
	    viewModel.medicalDietaryRestriction = appItem.Medical_Dietary_Restriction__c;
	    viewModel.medicalDietaryRestrictionDescription = appItem.Medical_Dietary_Restriction_Description__c;
	    viewModel.medicalPsychConditions = appItem.Medical_Psych_Conditions__c;
	    viewModel.medicalPsychConditionsExplanation = appItem.Medical_Psych_Conditions_Explanation__c;
	    viewModel.medicalPsychConditionsTreatment = appItem.Medical_Psych_Conditions_Treatment__c;
	    viewModel.medicationAllergies = appItem.Medication_Allergies__c;
	    viewModel.medicationAllergiesDescription = appItem.Medication_Allergies_Description__c;
	    viewModel.msaAuralComprehension = appItem.MSA_Aural_Comprehension__c;
	    viewModel.msaReading = appItem.MSA_Reading__c;
	    viewModel.msaSpeaking = appItem.MSA_Speaking__c;
	    viewModel.msaWriting = appItem.MSA_Writing__c;
	    viewModel.neatnesslevel = appItem.Neatness_Level__c;
	    viewModel.name = appItem.Name;
	    viewModel.nonSmoking = appItem.Prefers_Non_Smoking__c;
	    viewModel.offCampus = appItem.Prefers_Off_Campus__c;
	    viewModel.onCampus = appItem.Prefers_On_Campus__c;
	    viewModel.ongoingMedicalAttention = appItem.Ongoing_Medical_Attention__c;
	    viewModel.ongoingMedicalAttentionDescription = appItem.Ongoing_Medical_Attention_Description__c;
	    viewModel.other = appItem.Prefers_Other__c;
	    viewModel.otherMedicalData = appItem.Other_Medical_Data__c;
	    viewModel.otherMedicalDataDescription = appItem.Other_Medical_Data_Details__c;
	    viewModel.otherCity = appItem.other_City__c;
	    viewModel.otherCountry = appItem.other_Country__c;
	    viewModel.otherState = appItem.other_State__c;
	    viewModel.otherStreet = appItem.other_Street__c;
	    viewModel.otherZip = appItem.other_ZIP_Code__c;
	    viewModel.pAuralComprehension = appItem.P_Aural_Comprehension__c;
	    viewModel.phase = appItem.Phase__c;
	    viewModel.pendingHomeInstitutionFinalApproval = appItem.Pending_Home_Institution_Final_Approval__c;
	    viewModel.physActivityRestrictionsDescription = appItem.Phys_Activity_Restrictions_Description__c;
	    viewModel.physicalActivityRestrictions = appItem.Physical_Activity_Restrictions__c;
	    viewModel.pReading = appItem.P_Reading__c;
	    viewModel.privateBathroom = appItem.Prefers_Private_Bathroom__c;
	    viewModel.pSpeaking = appItem.P_Speaking__c;
	    viewModel.pWriting = appItem.P_Writing__c;
	    viewModel.recordType = appItem.RecordType.DeveloperName;
	    viewModel.regularlySpeak = appItem.Regularly_Speak__c;
	    viewModel.religiousAccomodations = appItem.Religious_Accomodations__c;
	    viewModel.requiredAcademicConditions = appItem.Required_Academic_Contitions__c;
	    viewModel.roommateRequests = appItem.Roommate_Requests__c;
	    viewModel.selfCatered = appItem.Prefers_Self_Catered__c;
	    viewModel.shabbat = appItem.Prefers_Shabbat__c;
	    viewModel.singleGender = appItem.Prefers_Single_Gender__c;
	    viewModel.singleRoom = appItem.Prefers_Single_Room__c;
	    viewModel.smoking = appItem.Prefers_Smoking__c;
	    viewModel.speaksArabic = appItem.Speaks_Arabic__c;
	    viewModel.speaksColloquialEgyptian = appItem.Speaks_Colloquial_Egyptian__c;
	    viewModel.speaksHebrew = appItem.Speaks_Hebrew__c;
	    viewModel.speaksPalestinian = appItem.Speaks_Palestinian__c;
	    viewModel.status = appItem.Status__c;
	    viewModel.studentFirstName = studentContact.FirstName;
	    viewModel.studentLastName = studentContact.LastName;
	    viewModel.textToSign = appItem.Text_to_Sign__c;
	    viewModel.typicalbedtime = appItem.Typical_Bedtime__c;
	    viewModel.typicalReaction = appItem.Typical_Reaction__c;
	    viewModel.universityCourses = appItem.University_Courses__c;
	    viewModel.vegan = appItem.Prefers_Vegan__c;
	    viewModel.vegetarian = appItem.Prefers_Vegetarian__c;
	    viewModel.ccParticipationOptions = apexConversionUtility.getPicklistStringValues(Application_Item__c.C_C_Participation__c);
	    viewModel.competencyOptions = apexConversionUtility.getPicklistStringValues(Application_Item__c.MSA_Reading__c);
	    viewModel.regularlySpeakOptions = apexConversionUtility.getPicklistStringValues(Application_Item__c.Regularly_Speak__c);
	    viewModel.willAttendReligiousService = appItem.Will_Attend_Religious_Service__c;
	    viewModel.personalInterests = appItem.Personal_Interests__c;
	    viewModel.musicPreferences = appItem.Music_Preferences__c;
	    viewModel.children = appItem.Prefers_Children__c;
		// Travel Plan
		if(appItem.RecordType.DeveloperName == 'Travel_Plan')
		{
			if(programTerm.Date_Approval_Status__c == 'Approved')
			{
				viewModel.arrivalCity = programTerm.Arrival_City__c;
				viewModel.arrivalDate = programTerm.Start_Date__c;
				viewModel.programEndDate = programTerm.End_Date__c;
			}
			else if(parentProgramTerm != null && parentProgramTerm.Date_Approval_Status__c == 'Approved')
			{
				viewModel.arrivalCity = parentProgramTerm.Arrival_City__c;
				viewModel.arrivalDate = parentProgramTerm.Start_Date__c;
				viewModel.programEndDate = parentProgramTerm.End_Date__c;
			}
			else
			{
				viewModel.willHaveGroupTravel = 'TBA';
			}
		}

		viewModel.courses = new List < studentHomeSchoolCourseViewModel > ();
	    viewModel.displaySignature = appItem.Display_Signature__c;
	    viewModel.sameBillingAddress = appItem.Billing_Street__c!= null && appItem.Billing_Street__c.equals(appItem.Mailing_Street__c);
	    viewModel.sameOtherAddress = appItem.Other_Street__c!= null && appItem.Other_Street__c.equals(appItem.Mailing_Street__c);
		viewModel.notCurrentlyEnrolled = appItem.Not_Currently_Enrolled__c;
		viewModel.recommendationWaived = appItem.Recommendation_Wavied__c;
		viewModel.evalWaived = appItem.Evaluation_Waived__c;
		viewModel.numberOfRecommendations = (Integer) appItem.Number_of_Recommendations__c;
		// Passport Copy
		if(appItem.RecordType.DeveloperName == 'Passport_Copy')
		{
			viewModel.passportCountry = studentContact.Passport_Country_Of_Issuance__c!= null ? studentContact.Passport_Country_Of_Issuance__c : appItem.Passport_Country_Of_Issuance__c;
			viewModel.passportCountryOptions = apexConversionUtility.getPicklistStringValues(Application_Item__c.Passport_Country_Of_Issuance__c);
			viewModel.passportExpirationDate = studentContact.Passport_Expiration_Date__c!= null ? studentContact.Passport_Expiration_Date__c : appItem.Passport_Expiration_Date__c;
			viewModel.passportNumber = studentContact.Passport_Number__c!= null ? studentContact.Passport_Number__c : appItem.Passport_Number__c;		
			viewModel.passportDoNotHave = appItem.Passport_Does_Not_Have__c; 
			viewModel.passportInRenewal = appItem.Passport_In_Renewal__c;
			viewModel.passportDataSubmitted = appItem.Passport_Country_Of_Issuance__c!= null && appItem.Passport_Expiration_Date__c!= null && appItem.Passport_Number__c!= null;
		}
		if(appItem.RecordType.DeveloperName == 'Medical_Form')
		{
			viewModel.question1Override = appItem.Question_1_Override__c;
			viewModel.question2Override = appItem.Question_2_Override__c;
			viewModel.question3Override = appItem.Question_3_Override__c;
			viewModel.question4Override = appItem.Question_4_Override__c;
			viewModel.question5Override = appItem.Question_5_Override__c;
			viewModel.question6Override = appItem.Question_6_Override__c;
			viewModel.question7Override = appItem.Question_7_Override__c;
			viewModel.question8Override = appItem.Question_8_Override__c;
			viewModel.question9Override = appItem.Question_9_Override__c;
			viewModel.question10Override = appItem.Question_10_Override__c;
			viewModel.question11Override = appItem.Question_11_Override__c;
			viewModel.question12Override = appItem.Question_12_Override__c;
			viewModel.question13Override = appItem.Question_13_Override__c;
			viewModel.question14Override = appItem.Question_14_Override__c;
			viewModel.question15Override = appItem.Question_15_Override__c;
			viewModel.question16Override = appItem.Question_16_Override__c;
			viewModel.question17Override = appItem.Question_17_Override__c;
			viewModel.question18Override = appItem.Question_18_Override__c;
			viewModel.question19Override = appItem.Question_19_Override__c;
			viewModel.question20Override = appItem.Question_20_Override__c;
			viewModel.question21Override = appItem.Question_21_Override__c;
			viewModel.question22Override = appItem.Question_22_Override__c;
			viewModel.question23Override = appItem.Question_23_Override__c;
			viewModel.question24Override = appItem.Question_24_Override__c;
			viewModel.question25Override = appItem.Question_25_Override__c;
			viewModel.question26Override = appItem.Question_26_Override__c;
		}
		viewModel.directoryOptOutStatus = appItem.Application__r.Applicant__r.Directory_Information_Opt_Out__c;
		// Learning Plan
		if(appItem.RecordType.DeveloperName == 'Learning_Plan')
		{
			viewModel.learningPlanDisclosure = appItem.Learning_Plan_Disclosure__c;
			viewModel.academicGoalsA = appItem.Learning_Plan_Academic_Goals_A_Long__c != null ? appItem.Learning_Plan_Academic_Goals_A_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.academicGoalsB = appItem.Learning_Plan_Academic_Goals_B_Long__c != null ? appItem.Learning_Plan_Academic_Goals_B_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.academicGoalsC = appItem.Learning_Plan_Academic_Goals_C_Long__c != null ? appItem.Learning_Plan_Academic_Goals_C_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.personalGoalsA = appItem.Learning_Plan_Personal_Goals_A_Long__c != null ? appItem.Learning_Plan_Personal_Goals_A_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.personalGoalsB = appItem.Learning_Plan_Personal_Goals_B_Long__c != null ? appItem.Learning_Plan_Personal_Goals_B_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.personalGoalsC = appItem.Learning_Plan_Personal_Goals_C_Long__c != null ? appItem.Learning_Plan_Personal_Goals_C_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.professionalGoalsA = appItem.LearningPlan_Professional_Goals_A_Long__c != null ? appItem.LearningPlan_Professional_Goals_A_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.professionalGoalsB = appItem.LearningPlan_Professional_Goals_B_Long__c != null ? appItem.LearningPlan_Professional_Goals_B_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.professionalGoalsC = appItem.LearningPlan_Professional_Goals_C_Long__c != null ? appItem.LearningPlan_Professional_Goals_C_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.specificActions1 = appItem.Learning_Plan_Specific_Actions_1_Long__c != null ? appItem.Learning_Plan_Specific_Actions_1_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.specificActions2 = appItem.Learning_Plan_Specific_Actions_2_Long__c != null ? appItem.Learning_Plan_Specific_Actions_2_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.specificActions3 = appItem.Learning_Plan_Specific_Actions_3_Long__c != null ? appItem.Learning_Plan_Specific_Actions_3_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.specificActions4 = appItem.Learning_Plan_Specific_Actions_4_Long__c != null ? appItem.Learning_Plan_Specific_Actions_4_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.specificActions5 = appItem.Learning_Plan_Specific_Actions_5_Long__c != null ? appItem.Learning_Plan_Specific_Actions_5_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.otherInformation = appItem.Learning_Plan_Other_Long__c != null ? appItem.Learning_Plan_Other_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.academicGoalsAOriginal = appItem.Learning_Plan_Academic_Goals_A__c != null ? appItem.Learning_Plan_Academic_Goals_A__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.academicGoalsBOriginal = appItem.Learning_Plan_Academic_Goals_B__c != null ? appItem.Learning_Plan_Academic_Goals_B__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.academicGoalsCOriginal = appItem.Learning_Plan_Academic_Goals_C__c != null ? appItem.Learning_Plan_Academic_Goals_C__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.personalGoalsAOriginal = appItem.Learning_Plan_Personal_Goals_A__c != null ? appItem.Learning_Plan_Personal_Goals_A__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.personalGoalsBOriginal = appItem.Learning_Plan_Personal_Goals_B__c != null ? appItem.Learning_Plan_Personal_Goals_B__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.personalGoalsCOriginal = appItem.Learning_Plan_Personal_Goals_C__c != null ? appItem.Learning_Plan_Personal_Goals_C__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.professionalGoalsAOriginal = appItem.Learning_Plan_Professional_Goals_A__c != null ? appItem.Learning_Plan_Professional_Goals_A__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.professionalGoalsBOriginal = appItem.Learning_Plan_Professional_Goals_B__c != null ? appItem.Learning_Plan_Professional_Goals_B__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.professionalGoalsCOriginal = appItem.Learning_Plan_Professional_Goals_C__c != null ? appItem.Learning_Plan_Professional_Goals_C__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.specificActions1Original = appItem.Learning_Plan_Specific_Actions_1__c != null ? appItem.Learning_Plan_Specific_Actions_1__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.specificActions2Original = appItem.Learning_Plan_Specific_Actions_2__c != null ? appItem.Learning_Plan_Specific_Actions_2__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.specificActions3Original = appItem.Learning_Plan_Specific_Actions_3__c != null ? appItem.Learning_Plan_Specific_Actions_3__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.specificActions4Original = appItem.Learning_Plan_Specific_Actions_4__c != null ? appItem.Learning_Plan_Specific_Actions_4__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.specificActions5Original = appItem.Learning_Plan_Specific_Actions_5__c != null ? appItem.Learning_Plan_Specific_Actions_5__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.otherInformationOriginal = appItem.Learning_Plan_Other_Long__c != null ? appItem.Learning_Plan_Other_Long__c.replaceAll('<[^>]+>',' ') : null;
			viewModel.learningPlanUpdate = false;
		}
		viewModel.advisorFirstName = appItem.Application__r.Owner.FirstName;
		viewModel.advisorLastName = appItem.Application__r.Owner.LastName;
		viewModel.advisorEmail = appItem.Application__r.Owner.Email;
		viewModel.attachments = attachments;
		viewModel.files = files;
		if(appItem.RecordType.DeveloperName == 'Scholarship')
		{
			if(aidItemViewModel.size() > 0)
			{
				viewModel.aidList.addAll(aidItemViewModel);
			}
			viewModel.FASFA = application.FASFA__c;
			viewModel.EFC = application.Expected_Family_Contribution__c;
			viewModel.TuitionRemission = application.Tuition_Remission__c;
			viewModel.TuitionDiscount = application.University_Discount__c;
			viewModel.CollegeSavingsPlan = application.College_Savings_Plan__c;
			viewModel.VABenefits = application.V_A_Benefits__c;
			viewModel.AmountStudentCanPay = application.AmountStudentCanPay__c;
			viewModel.AmountFamilyCanPay = application.AmountFamilyCanPay__c;
			viewModel.HomeTuition = application.Home_University_Tuition__c;
			viewModel.HomeStudyAbroadFees = application.Home_University_Study_Abroad_Fees__c;
			viewModel.IFSAGeneral = application.General_Need_Scholarship__c;
			viewModel.FirstGen = application.First_Gen__c;
			viewModel.GAPScholarship = application.GAP_Scholarship__c;
			viewModel.IFSAWorkStudy = application.Work_Study_Scholarship__c;
			viewModel.FinancialAidOfficersName = application.Financial_Aid_Officer_Name__c;
			viewModel.FinancialAidOfficersPhone = application.Financial_Aid_Officer_Phone__c;
			viewModel.FinancialAidOfficersEmail = application.Financial_Aid_Officer_Email__c;
		}
		viewModel.hideStudyAbroadWording = appItem.Application_Requirement__r.Hide_Study_Abroad_Wording__c;
		
		
		for(Course__c course: courses)
		{
			studentHomeSchoolCourseViewModel courseItem = new studentHomeSchoolCourseViewModel();
			courseItem.Id = course.Id;
			courseItem.courseCode = course.Course_Code__c;
			courseItem.courseName = course.Name;
			viewModel.courses.add(courseItem);
		}
		
		viewModel.recommendations = new List<studentRecommendationItemViewModel>();
		for(Recommendation__c recommendation : recommendations)
		{
			studentRecommendationItemViewModel recommendationItem = new studentRecommendationItemViewModel();
			recommendationItem.recommendationStatus = recommendation.Status__c;
			recommendationItem.recommendationUrl = recommendation.Status__c == 'Complete' && appItem.Recommendation_Wavied__c == 'No' ? 'SP_Recommendation?app=' + appItem.Id +  '&recommender=' + recommendation.Id : '';
			recommendationItem.recommenderEmail = recommendation.Email_Address__c;
			recommendationItem.recommenderName = recommendation.Name;
			viewModel.recommendations.add(recommendationItem);
		}
		if(appItem.RecordType.DeveloperName == 'Addresses' || appItem.RecordType.DeveloperName == 'Update_Emergency_Contact')
		{
			if(!emergencyContacts.isEmpty())
			{
				for(Contact c: emergencyContacts)
				{
					viewModel.relatedContacts.add(new model_contact(c, true));
				}
			}

			if(studentContact.Directory_Information_Opt_Out__c == 'Withheld')
			{
				viewModel.doNotContact = true;
				viewModel.doContact = false;
			}
			else if(studentContact.Directory_Information_Opt_Out__c == 'Released')
			{
				viewModel.doNotContact = false;
				viewModel.doContact = true;
			}
			else
			{
				viewModel.doNotContact = false;
				viewModel.doContact = false;	
			}
			
			viewModel.pContactRelationshipOptions = new List<String>{'Father', 'Mother', 'Guardian', 'Other'};
		}

		if(appItem.Application_Requirement__r.Dynamic_Form__c != null)
		{
			viewModel.form = new dynamicFormViewModel(appItem);
		}

	    return viewModel;	    
	}
	
	/**
	 * @description Creates an attachment of the image of the signature and attaches it to the application item record
	 * @param appItemId The application item id.
	 * @param appItemName The application item name.
	 * @param fileData The contents of the file.
	 * @param fileType The type of the file.
	 * @param fileName The name of the file.
	 * @return Success of the method
	 */
	@RemoteAction
	public static Boolean submitSignature(String appItemId, String appItemName, String fileData, String fileType, String fileName)
	{
		System.debug(appItemId);
		System.debug(appItemName);
		System.debug(fileType);
		System.debug(fileName);
		if(fileData != null && fileType != null && fileData != '' && fileType != '')
	    {
	    	try
	    	{
				String studentName = [SELECT Application__r.Applicant__r.Name FROM Application_Item__c WHERE Id =: appItemId].get(0).Application__r.Applicant__r.Name;
			    String fileExtension = fileName.substringAfterLast('.');
			    Attachment file = new Attachment(ParentId=appItemId, name=(studentName + ' ' + appItemName + '.' + fileExtension), ContentType=fileType, Body=EncodingUtil.base64Decode(fileData));	        
			    database.insert(file);
			    return true;
		    }
	    	catch(Exception e)
	    	{
			    System.debug(LoggingLevel.WARN, e.getMessage());
			    return false;
		    }
	    }
	    return false;
	}

	/**
	 * @description Searches for the host institutions that are part of a program
	 * @param SearchTerm - the search term
	 * @param ProgramID The application item name.
	 * @return List of schools
	 */
    @RemoteAction
    public static List<Host_Institution__c> searchHostInstitutions(String SearchTerm, String ProgramID) 
    {  		
        if(SearchTerm != null)
        	return convertProgramInstitutionToHostInstitution(Database.query('SELECT Host_Institution__r.Name, Host_Institution__c FROM Program_Institution__c WHERE (Host_Institution__r.Name Like \'%' + String.escapeSingleQuotes(searchTerm) + '%\') AND (Program__c = \'' + ProgramID +'\')'));
    	else
		{    		
			List<Id> hostInstIds = new List<Id>();
			for(Program_Institution__c pi: [SELECT Host_Institution__c FROM Program_Institution__c WHERE Program__c =: ProgramId])
			{
				hostInstIds.add(pi.Host_Institution__c);
			}

        	return [SELECT Id, Name, Uses_Oxbridge_Tutorials__c, (SELECT Id, Name FROM Location_of_Instructions__r) FROM Host_Institution__c WHERE Id IN: hostInstIds];
		}
    }      
    
	/**
	 * @description Gets the Host Institution records from Program Institution records
	 * @param programInstitutions - the search program institution records
	 * @return List of schools
	 */
    private static List<Host_Institution__c> convertProgramInstitutionToHostInstitution(List<Program_Institution__c> programInstitutions)
    {
        List<Host_Institution__c> schools = new List<Host_Institution__c>();

        for (Program_Institution__c current : programInstitutions)
        {
            Host_Institution__c school = new Host_Institution__c();
            school.Name = current.Host_Institution__r.Name;
            school.ID = current.Host_Institution__c;
            schools.add(school);
        }
        
        return schools;
    }

    /**
	 * @description Saves the students abroad phone number.
	 * @param phoneNumber The string of the phone number.
	 * @param studentId The string of the student's contact record Id
	 * @return A Boolean The results of the save.
	 */
	@RemoteAction
	public static Boolean updateAbroadPhoneNumber(String phoneNumber, String countryId, String studentId)
	{
		return portalOnSiteRemotingMethods.updateAbroadPhoneNumber(phoneNumber, countryId, studentId);
	}

	/**
	 * @description Saves the students address.
	 * @param serializedViewModel The viewModel class with addresses, but as a JSON String.
	 * @return A map<String, Object> with information on the save.
	 */
	@RemoteAction
	public static Map<String, object> saveAddresses(String serializedViewModel)
	{
		try
		{
			studentProfileViewModel viewModel = (studentProfileViewModel) JSON.createParser(serializedViewModel).readValueAs(Type.forName('studentProfileViewModel'));
			
			Contact studentContact = new Contact(
				Id = viewModel.contactId,
				MailingStreet = viewModel.mailingStreet,
				MailingCity = viewModel.mailingCity,
				MailingState = viewModel.mailingState,
				MailingCountry = viewModel.mailingCountry,
				MailingPostalCode = viewModel.mailingZip,
				OtherStreet = viewModel.otherStreet,
				OtherCity = viewModel.otherCity,
				OtherState = viewModel.otherState,
				OtherPostalCode = viewModel.otherZip,
				OtherCountry = viewModel.otherCountry);
			
			Account studentAccount = new Account(
				Id = viewModel.accountId,
				BillingStreet = viewModel.billingStreet,
				BillingCity = viewModel.billingCity,
				BillingState = viewModel.billingState,
				BillingPostalCode = viewModel.billingZip,
				BillingCountry = viewModel.billingCountry);
	
			List<Database.saveResult> updateResults = Database.update(new List<sObject>{studentAccount, studentContact});
	
			Boolean isSuccess = true;
			String message = 'Your information was updated successfully.';
			for(Database.saveResult result : updateResults)
			{
				if(!result.isSuccess())
				{
					isSuccess = false;
					message = 'There was a problem saving your information. Please try again. If you continue to have problems, please contact your program advisor.';
				}
			}
	
			Map<String, object> response = new Map<String, object>();
			response.put('isSuccess', isSuccess);
			response.put('message', message);
	
			return response;
		}
		catch (Exception e)
		{
			Map<String, object> response = new Map<String, object>();
			response.put('isSuccess', false);
			response.put('message', 'There was a problem saving your information. Please try again. If you continue to have problems, please contact your program advisor.');

			return response;
		}
	}
	/**
	 * @description Gets a list of the current students applications
	 * @param contactId - the student's contact id
	 * @return List of studentApplicationsViewModel
	 */
	@RemoteAction
	public static studentApplicationsViewModel getApplicationsJS(String contactId)
	{
		studentApplicationsViewModel viewModel = portalRemotingMethods.getApplications(contactId);
		if(viewModel.saveStudent)
		{
			try
			{
				viewModel.student.Active_Application__c = viewModel.activeAppId;
				database.update(viewModel.student);
			}
			catch(LimitException e)
			{
				System.debug(e.getMessage());
			}
		}
		return viewModel;
	}
	/**
	 * @description Gets a list of the current students applications
	 * @param contactId - the student's contact id
	 * @return List of studentApplicationsViewModel
	 */
	@RemoteAction
	public static studentApplicationsViewModel getApplications(String contactId)
	{
		Contact portalUser = [SELECT Id, Name, Active_Application__c, Contact.Compare_Name_to_Active_Application__c FROM Contact WHERE Id =: contactId];
		List<Application__c> applications = [SELECT Id, Name, Status__c FROM Application__c WHERE Applicant__c =: portalUser.Id];
		Application__c activeApp;
		studentApplicationsViewModel viewModel = new studentApplicationsViewModel();
		if(portalUser.Active_Application__c != null)
		{
			activeApp = [SELECT Id, Name, Status__c FROM Application__c WHERE Id =: portalUser.Active_Application__c];
			viewModel.saveStudent = false;
		}
		else
		{	
			viewModel.saveStudent = true;
			activeApp = studentBaseController.getActiveApplication(portalUser);			
		}		
				
		for(Application__c app : applications)
		{
			if(app.Id != activeApp.Id)
			{
				if(app.Status__c != 'Diverted' && app.Status__c != 'Dropped' && app.Status__c != 'Deferred' && app.Status__c != 'Withdraw' && app.Status__c != 'Unqualified' && app.Status__c != 'Deceased')
				{
					ApplicationViewModel vm = new ApplicationViewModel();
					vm.Id = app.Id;
					vm.Name = app.Name;				
					viewModel.applications.add(vm);
				}
			}
		}
		
		viewModel.activeApplication = activeApp.Name;	
		viewModel.activeAppId = activeApp.Id;
		viewModel.student = portalUser;	
		return viewModel;
	}
	/**
	 * @description Sets the active application for a student
	 * @param appId - the new active application's id
	 * @return success of the method
	 */
	@RemoteAction
	public static Boolean setApplication(String appId)
	{
		Boolean success = true;
		system.debug(appId);
		//Get selected application
		
		Application__c selectedApplication = [SELECT Id, Applicant__c FROM Application__c WHERE Id =: appId].get(0);		
		//Get Applicant
		Contact applicant = [SELECT Id, Active_Application__c FROM Contact WHERE Id =: selectedApplication.Applicant__c].get(0);		
		//Set selected application to applicant's active application 
		applicant.Active_Application__c = selectedApplication.Id;
		
		Database.SaveResult sr = database.update(applicant);
		
		if(sr.isSuccess())
		{
			success = true;
		}
		else
		{
			success = false;
		}
		
		return success;
	}
	/**
	 * @description Creates a new application for a student and diverts the previous application
	 * @param contactId - the student's contact id
	 * @return success of the method
	 */
	@RemoteAction
	public static Boolean switchProgram(String contactId)
	{
		Boolean success = true;
		
		Contact portalUser = [SELECT Id, Name, Active_Application__c FROM Contact WHERE Id =: contactId];
		Application__c activeApp = [SELECT Id, Name, OwnerId, Status__c FROM Application__c WHERE Id =: portalUser.Active_Application__c].get(0);
		Id ownerId = [SELECT OwnerId FROM Program__c WHERE Name =: 'Undecided'].get(0).OwnerId;
		
		Task changeProgramTask = new Task(WhoId = contactId, WhatId = activeApp.Id, Subject = 'Application Diverted');
		changeProgramTask.OwnerId = activeApp.OwnerId;
		database.insert(changeProgramTask);
		activeApp.Status__c = 'Diverted';
		activeApp.Designation__c = '';
		Database.update(activeApp);
		List<Application__c> newApps = [SELECT Id, Name FROM Application__c WHERE Name LIKE '%New Application%' AND Applicant__c =: portalUser.Id];
		Application__c newApplication;
		if(newApps.size() < 1)
		{
			//Associate our new application with the contact
			newApplication = new Application__c();		
		}
		else
		{
			//Restart an existing 'New Application' so as not to create another new application
			newApplication = newApps.get(0);
		}
        newApplication.Previous_Application__c = activeApp.Id;
		newApplication.Applicant__c = portalUser.Id;
	    newApplication.Name = portalUser.Name + ' New Application';
	    newApplication.Status__c = 'Registered';
		newApplication.OwnerId = ownerId;

		Database.upsert(newApplication);

        //Associate the new application as the active one
        portalUser.Active_Application__c = newApplication.Id;
        portalUser.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Database.update(portalUser);        		
		
		return success;
	}
	/**
	 * @description Creates a new secondary application for a student
	 * @param contactId - the student's contact id
	 * @return success of the method
	 */
	@RemoteAction
	public static Boolean createSecondaryApp(String contactId)
	{
		Boolean success = true;
		
		Contact portalUser = [SELECT Id, Name, Active_Application__c FROM Contact WHERE Id =: contactId];
		Application__c activeApp = [SELECT Id, Name, OwnerId, Status__c FROM Application__c WHERE Id =: portalUser.Active_Application__c].get(0);
		Id ownerId = [SELECT OwnerId FROM Program__c WHERE Name =: 'Undecided'].get(0).OwnerId;		
		
		Task createBackupTask = new Task(WhoId = contactId, WhatId = activeApp.Id, Subject = 'Secondary Application Created');
		createBackupTask.OwnerId = activeApp.OwnerId;
		database.insert(createBackupTask);
		List<Application__c> newApps = [SELECT Id, Name FROM Application__c WHERE Name LIKE '%New Secondary Application%'  AND Applicant__c =: portalUser.Id];
		Application__c newApplication;
		if(newApps.size() < 1)
		{
			//Associate our new application with the contact
			newApplication = new Application__c();		
		}
		else
		{
			//Restart an existing 'New Application' so as not to create another new application
			newApplication = newApps.get(0);
		}
		newApplication.Applicant__c = portalUser.Id;
	    newApplication.Previous_Application__c = activeApp.Id;
	    newApplication.Name = portalUser.Name + ' New Secondary Application';
	    if(activeApp.Status__c != 'Dropped' && [SELECT Id FROM Application__c WHERE Applicant__c =: portalUser.Id AND Status__c != 'Dropped' AND Status__c != 'Diverted' AND Status__c != 'Withdrawn' AND Status__c != 'Rejected' ].size() > 0)
	    {
	    	newApplication.Designation__c = 'Secondary';
	    }
	    newApplication.Status__c = 'Registered';
		newApplication.OwnerId = ownerId;
        Database.upsert(newApplication);
        
        //Associate the new application as the active one
        portalUser.Active_Application__c = newApplication.Id;
		portalUser.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Database.update(portalUser); 
		
		return success;
	}
	/**
	 * @description Creates a "scholarship" application item for the student's current application
	 * @param ApplicationId - the application id
	 * @return studentApplyItemViewModel of the new application item
	 */
	@RemoteAction
	public static studentApplyItemViewModel addScholarshipItem(String ApplicationId)
	{		
		Application__c application = (Application__c) apexQueryUtility.selectAllFrom('Application__c', 'Id = \'' + ApplicationId + '\'').get(0);
		Application_Item__c scholarship = new Application_Item__c(
			Name = 'Scholarship',
			Phase__c = 'Optional',
			Status__c = 'Started', 
			Application__c = application.Id, 
			RecordTypeId = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Download-Upload').getRecordTypeId(),
			Content_Link_Old__c = [SELECT URL__c FROM static_Link_URL__mdt WHERE DeveloperName = 'Scholarship_Link'].get(0).URL__c
		);
		
		database.insert(scholarship);

		studentApplyItemViewModel itemViewModel = new studentApplyItemViewModel();
		itemViewModel.id = scholarship.Id;
		itemViewModel.name = scholarship.Name;
		itemViewModel.status = scholarship.Status__c;
		itemViewModel.isStarted = (scholarship.Status__c == 'Started') ? true : false;
		
		return itemViewModel;
	}
	/**
	 * @description Clones specific completed application items when a student diverts or creates a new backup application
	 * @param oldApplication - the old application id
	 * @param newApplication - the new application record
	 */
	public static void cloneApplicationItems(Id oldApplication, Application__c newApplication)
	{			
		//RecordTypes of ApplicationItems that will be transfered
		//List<RecordType> appItemRecordTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Application_Item__c' AND (Name = 'Addresses' OR Name = 'Medical Form' OR Name = 'Personal Essay' OR Name = 'Recommendation' OR Name = 'Passport Copy' OR Name = 'No Action')];		
		Set<String> fieldNamesNotToTransfer = new Set<String>{'name', 'directions__c', 'application__c', 'application_requirement__c', 'createdbyid', 'createddate', 'lastmodifiedbyid', 'lastmodifieddbyid', 'ownerid', 'recordtypeid'};
		Map<String, SObjectField> objectFields = apexQueryUtility.getFieldMap('Application_Item__c');
		for(String fieldName: objectFields.keySet())
		{
			Schema.SObjectField f = objectFields.get(fieldName);
			Schema.DescribeFieldResult dfr = f.getDescribe();
			if(dfr.isCalculated() || !dfr.isUpdateable() || !dfr.isAccessible())
			{
				fieldNamesNotToTransfer.add(dfr.getName().toLowerCase());
			}
		}
		Map<String, Id> appItemRecordTypes = new Map<String, Id>();
		Map<Id, SObject> attachItems = new Map<Id, SObject>();
		Map<String, Set<String>> specificAppNames = new Map<String, Set<String>>();

		for(Cloned_Application_Item_Type__mdt type: [SELECT MasterLabel, Specific_Name__c FROM Cloned_Application_Item_Type__mdt])
		{
			appItemRecordTypes.put(type.MasterLabel, Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get(type.MasterLabel).getRecordTypeId());	
			if(type.Specific_Name__c != null)
			{
				if(!specificAppNames.containsKey(type.MasterLabel))
				{
					specificAppNames.put(type.MasterLabel, new Set<String>());
				}
				specificAppNames.get(type.MasterLabel).add(type.Specific_Name__c);
			}
		}
		if(appItemRecordTypes.isEmpty())
		{
			throw new dataException('List does not contain any values');
		}
		string whereClauseItemTypes = apexQueryUtility.buildInClause(appItemRecordTypes.values());
		List<Application_Item__c> completedAppItems = new List<Application_Item__c>();
		List<Application_Item__c> newAppItems = new List<Application_Item__c>();
		for(Application_Item__c appItem: (List<Application_Item__c>) apexQueryUtility.selectAllFrom('Application_Item__c', 'Application_Requirement__r.Program_Term__r.Parent_Program_Term__c, RecordType.Name', 'RecordTypeId IN ' + whereClauseItemTypes + ' AND ((Application__c = \'' + oldApplication + '\' AND Status__c = \'Complete\') OR Application__c = \'' + newApplication.Id + '\')'))
		{
			if(appItem.Application__c == oldApplication)
			{
				completedAppItems.add(appItem);
			}
			else if(appItem.Application__c == newApplication.Id)
			{
				newAppItems.add(appItem);
			}
		}

		//List of completed application items from old application
		Map<String, Application_Item__c> completedApplicationItems = new Map<String, Application_Item__c>();
		for(Application_Item__c appItem: completedAppItems)
		{
			if(specificAppNames.containsKey(appItem.RecordType.Name))
			{
				for(String appItemName: specificAppNames.get(appItem.RecordType.Name))
				{
					if(appItem.Name.contains(appItemName))
					{
						completedApplicationItems.put(appItem.RecordTypeId + '_' + appItem.Name, appItem);
					}
				}
			}
			else
			{
				completedApplicationItems.put(appItem.RecordTypeId, appItem);
			}
		}
		Map<String, Application_Item__c> newApplicationItems = new Map<String, Application_Item__c>();
		for(Application_Item__c appItem: newAppItems)
		{
			if(specificAppNames.containsKey(appItem.RecordType.Name))
			{
				for(String appItemName: specificAppNames.get(appItem.RecordType.Name))
				{
					if(appItem.Name.contains(appItemName))
					{
						newApplicationItems.put(appItem.RecordTypeId + '_' + appItem.Name, appItem);
					}
				}
			}
			else
			{
				newApplicationItems.put(appItem.RecordTypeId, appItem);
			}
		}
		//Holding List for application items to transfer to new application
		system.debug('Completed Items: ' + completedApplicationItems.size());
		system.debug('      New Items: ' + newApplicationItems.size());
		Map<Id, SObject> itemsToTransfer = new Map<Id, SObject>();
		Application_Item__c oldRecommendationItem;
		Application_Item__c newRecommendationItem;
		for(String key: completedApplicationItems.keySet())
		{
			Application_Item__c oldAppItem = completedApplicationItems.get(key);
			Application_Item__c appItem = newApplicationItems.get(key);
			if(appItem == null)
			{
				continue;
			}
			Boolean proceed = false;
			//System.debug(key);
			if(key.contains('_'))
			{
				String[] keyParts = key.split('_');
				System.debug('Keyparts: ' + keyParts);
				System.debug('oldAppItem.Name: ' + oldAppItem.Name);
				System.debug('appItem.Name: ' + appItem.Name);
				proceed = oldAppItem.Name.contains(keyParts[1]) && appItem.Name.contains(keyParts[1]);
			}
			else
			{
				proceed = true;
			}
			if(proceed)
			{
				if(oldAppItem.RecordTypeId == appItem.RecordTypeId)
				{
					//studentApplyItemDetailsViewModel viewModel = getApplicationItemDetails(oldAppItem.Id);												
					for(String fieldName: objectFields.keySet())
					{
						System.debug(fieldName);
						System.debug(fieldNamesNotToTransfer.contains(fieldName));
						if(!fieldNamesNotToTransfer.contains(fieldName))
						{
							appItem.put(fieldName, oldAppItem.get(fieldName));
						}
					}
					if(appItem.Application_Requirement__c == oldAppItem.Application_Requirement__c && appItem.Application_Requirement__c != null && appItem.Application_Requirement__r.Program_Term__r.Parent_Program_Term__c != oldAppItem.Application_Requirement__r.Program_Term__r.Parent_Program_Term__c)
					{
						throw new dataException('Application Requirement Lookup has been cloned');
					}
					if(appItem.RecordTypeId == appItemRecordTypes.get('Recommendation'))
					{
						
						//Make copy old appItem
						oldRecommendationItem = oldAppItem;
						newRecommendationItem = appItem;
					}
					attachItems.put(oldAppItem.Id, appItem);
					itemsToTransfer.put(appItem.Id, appItem);						
				}
			}
		}
		if(oldRecommendationItem != null)
		{

			//Get Recommendations
			List<Recommendation__c> recommendations = apexQueryUtility.selectAllFrom('Recommendation__c', 'Application_Item__c = \'' + oldRecommendationItem.Id + '\' AND Status__c = \'Complete\'');
			Map<Id, Recommendation__c> recMap = new Map<Id, Recommendation__c>(recommendations);
			//Clone Recommendations
			for(Recommendation__c rec: recMap.values())
			{
				rec.Id = null;
				rec.Application_Item__c = newRecommendationItem.Id;
			}
			database.insert(recMap.values());
			for(Id recId: recMap.keyset())
			{
				attachItems.put(recId, recMap.get(recId));
			}
		}
		system.debug(itemsToTransfer.size());
		database.upsert(itemsToTransfer.values());

		if(!attachItems.isEmpty())
		{
			List<SObject> newFiles = new List<SObject>();
			for(Attachment a: [SELECT Id, Name, Body, OwnerId, ContentType, ParentId FROM Attachment WHERE ParentId IN: attachItems.keySet()])
			{
				newFiles.add(new Attachment(
					parentId = attachItems.get(a.ParentId).Id,
					body = a.body,
					name = a.name,
					ContentType = a.ContentType,
					OwnerId = a.OwnerId
				));
			}
			system.debug(attachItems.keySet());
		
			for(ContentDocumentLink link: [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: attachItems.keySet()])
			{
				newFiles.add(new ContentDocumentLink(
					LinkedEntityId = attachItems.get(link.LinkedEntityId).Id,
					ContentDocumentId = link.ContentDocumentId
				));
			}
	
			newFiles.sort();
			database.insert(newFiles);
		}
	}

	// Start of Program Authorization Methods
	/**
	 * @description Saves a program authorization
	 * @param jsonData - JSON serialized program authorization object to save
	 * @param JSON serialized program authorization object that has been saved
	 */
	@RemoteAction
	public static string saveProgramAuthorization(String jsonData)
	{
		model_programAuthorization pAuth = new model_programAuthorization();
		if(jsonData == null)
		{
			return null;
		}
		try
		{
			pAuth = model_programAuthorization.convertFromJson(jsonData);
		  	return pAuth.save();
		}
		catch(Exception e)
		{
		  System.debug(LoggingLevel.ERROR, e.getMessage());
		  return e.getMessage();
		}
	}

	@RemoteAction
	public static List<model_program> getPrograms()
	{
		List<model_program> returnList = new List<model_program>();
		List<Program__c> programs = [SELECT Id, Name FROM Program__c WHERE Active__c = TRUE AND Category__c != 'Custom'];
		for (Program__c program: programs) {
			returnList.add(new model_program(program));
		}
		return returnList;
	}

	@RemoteAction
	public static List<String> getSections(String programId)
	{
		Set<String> returnList = new Set<String>();

		for(Program_Term__c pt: [SELECT Term__r.Section__c FROM Program_Term__c WHERE Program__c =: programId AND Term__r.Year__c >=: Date.today().year()])
		{
			returnList.add(pt.Term__r.Section__c);
		}
		
		return new List<String>(returnList);
	}


	// End of Program Authorizations

	// Start of Trip Methods
	/**
	 * @description Saves a new trip
	 * @param jsonData - JSON serialized trip object to save
	 * @param JSON serialized trip object that has been saved
	 */
	@RemoteAction
	public static string saveTrip(String jsonData)
	{
		return portalOnSiteRemotingMethods.saveTrip(jsonData);
	}
	
	/**
	 * @description Deletes a trip
	 * @param tripId - Id of the trip to delete
	 * @param Success of the method
	 */
	@RemoteAction
	public static Boolean deleteTrip(String tripId)
	{
		return portalOnSiteRemotingMethods.deleteTrip(tripId);
	}
	//End of Trip Methods
	//Start of Record Lookup Methods
	/**
	 * @description Searches for SObjects.
	 * @param objectName The object name being searched.
	 * @param searchTerm The name of the record that is being searched for
	 * @return the list of appropriate records.
	 */
	@RemoteAction
    public static List<ifsaRecordLookupViewModel> searchForRecord(String objectName, String searchTerm) 
    {
    	return ifsaRecordLookupMethods.searchForRecord(objectName, searchTerm);
    }
	/**
	 * @description Searches for SObjects.
	 * @param objectName The object name being searched.
	 * @param searchTerm The name of the record that is being searched for
	 * @param recordTypeDeveloperName The name of the recordtype that is being searched
	 * @return the list of appropriate records.
	 */
    @RemoteAction
    public static List<ifsaRecordLookupViewModel> searchForRecordWithRecordType(String objectName, String searchTerm, String recordTypeDeveloperName) 
    {
    	return ifsaRecordLookupMethods.searchForRecordWithRecordType(objectName, searchTerm, recordTypeDeveloperName);
    }
    //End of Record Lookup Methods
	/**
	* @description Submits an application item
	* @return Success of method
	*/
	@RemoteAction
	public static Boolean submitApplicationItem(String jsonData, String fileData, String fileType, String fileName)
	{
		studentApplyItemDetailsViewModel viewModel = new studentApplyItemDetailsViewModel();

		if(jsonData == null)
		{
			return false;
		}
		try
		{
			viewModel = (studentApplyItemDetailsViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('studentApplyItemDetailsViewModel'));
		}
		catch(Exception e)
		{
			System.debug(LoggingLevel.ERROR, e.getMessage());
			return false;
		}

		Application_Item__c appItem = (Application_Item__c) apexQueryUtility.selectAllFrom('Application_Item__c', 'Application__r.Applicant__c, Application_Requirement__r.Dynamic_Form__c', 'Id = \'' + viewModel.id + '\'').get(0);
		Contact studentContact = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Id = \'' + appItem.Application__r.Applicant__c + '\'').get(0);
		Account studentAccount = (Account) apexQueryUtility.selectAllFrom('Account', 'Id = \'' + studentContact.AccountId + '\'').get(0);
		Application__c studentApplication = (Application__c) apexQueryUtility.selectAllFrom('Application__c', 'Program_Term__r.Display_Name__c, Program_Term__r.Program__c, Owner.Name, Owner.Email, Owner.Title, Owner.Phone', 'Id = \'' + appItem.Application__c + '\'').get(0);
		studentContact.Active_Application__c =studentApplication.Id;
		List<Attachment> attmts = [SELECT Id FROM Attachment WHERE parentId =: viewModel.Id];
		List<sObject> sobjects = new List<sObject>();

		System.debug(logginglevel.INFO, viewModel.status);
		System.debug(logginglevel.INFO, viewModel.recordType);
		
		if(viewModel.recordType == 'Recommendation' || viewModel.recordType == 'Spanish_Language_Evaluation' || (viewmodel.recordType == 'Personal_Essay' && viewModel.status == 'Started'))
		{
			viewModel.status = 'Started';
		}
		else if(viewModel.RecordType == 'Medical_Form')
		{
			viewModel.status = 'Complete';
			appItem.Approval_Status__c = 'Pending Review';
		}
		else if(viewModel.RecordType == 'Transcript' && attmts.size() > 0)
		{
			if(viewModel.notCurrentlyEnrolled)
			{
				viewModel.status = 'Complete';
			}
			else if(viewModel.courses != null && viewModel.courses.size() > 0)
			{
				viewModel.status = 'Complete';
			}
		}    
		else if((viewModel.RecordType == 'No_Action' && (viewModel.Name.Contains('Transcript') || viewModel.Name.Contains('Academic Recommendation') || viewModel.Name.Contains('Plan of Study Letter') || viewModel.Name.Contains('Advising Call'))) || viewModel.recordType == 'Spanish_Language_Evaluation')
		{
			viewModel.status = 'Started';
			viewModel.displaySignature = false;
		}
		else if(viewModel.RecordType == 'Passport_Copy') 
		{
			if(viewModel.passportInRenewal == true)
			{
				viewModel.status = 'Started';
				System.debug('APP ITEM BEFORE: ' + viewModel.directions);
				viewModel.directions = viewModel.directions.replace('&amp;quot;', '"');
				viewModel.directions = viewModel.directions.replace('&quot;', '"');
				String renewalDirections = 'Please update your passport information once it has been renewed. Uncheck "Passport is being renewed" to continue.';
				System.debug('RENEWAL: ' + renewalDirections);
				System.debug('APP ITEM AFTER: ' + viewModel.directions);
				if(viewModel.directions != renewalDirections)
				{
					Task t = new Task(WhoId = studentApplication.Applicant__c, WhatId = appItem.Id, Subject = 'Passport is being renewed');
					t.OwnerId = studentApplication.OwnerId;
					t.ActivityDate = Date.Today().addDays(15);
					database.insert(t);
					viewModel.directions = renewalDirections;
				}
			}
			else if(viewModel.passportDoNotHave == true)
			{
				viewModel.status = 'Started';
				viewModel.directions = 'The host institution requires a copy of your passport. Upload a copy of the photo and signature pages of your passport and complete the form below. Uncheck "I don\'t have a passport" to continue';
			}
			else {
				viewModel.status = 'Started';
			}
			System.debug(viewModel.status);
		}
		else
		{
			if(viewModel.Name == 'IFSA-Butler Student Acceptance Agreement')
			{
				studentApplication.Status_Contract_Signed__c = DateTime.now();
			}
			viewModel.status = viewModel.status == 'Started' ? 'Started' : 'Complete';
		}
		System.debug(LoggingLevel.INFO, viewModel.status);

		appItem.Academic_Probation__c = viewModel.academicProbation;
		appItem.Academic_Probation_Explanation__c = viewModel.academicProbationExplanation;
		appItem.Allergic_To__c = viewModel.allergicTo;
		appItem.Approval_to_Study__c = viewModel.approvalToStudy;
		appItem.Approval_to_Study_Explanation__c = viewModel.approvalToStudyExplanation;
		appItem.Prefers_Catered__c = viewModel.catered == true;
		appItem.C_C_Participation__c = viewModel.ccParticipation;
		appItem.CE_Aural_Comprehension__c = viewModel.ceAuralComprehension;
		appItem.CE_Reading__c = viewModel.ceReading;
		appItem.CE_Speaking__c = viewModel.ceSpeaking;
		appItem.CE_Writing__c = viewModel.ceWriting;
		appItem.Commercial_Teaching_Rosetta_Stone_etc__c = viewModel.commercialTeachingRosettaStoneEtc == true;
		appItem.Community_Courses__c = viewModel.communityCourses == true;
		appItem.Content__c = viewModel.content != null ? viewModel.content.replaceAll('undefined', '') : null;
		//appItem.Content_Link_New__c = viewModel.contentLink;
		appItem.Current_Treatment__c = viewModel.currentTreatment == true;
		appItem.Current_Treatment_Description__c = viewModel.currentTreatmentDescription;
		appItem.Dietary_Restrictions__c = viewModel.dietaryRestrictions != null ? viewModel.dietaryRestrictions.unescapeHtml4() : null;
		appItem.Directions__c = viewModel.directions != null ? viewModel.directions.unescapeHtml4() : null;
		appItem.Disciplinary_Action_Explanation__c = viewModel.disciplinaryActionExplanation;
		appItem.Discipline__c = viewModel.discipline;
		appItem.Display_Catered_Option__c = viewModel.displaycatered == true;
		appItem.Display_Dietary_Restrictions__c = viewModel.displaydietaryrestrictions == true;
		appItem.Display_Food_Allergies_Option__c = viewModel.displayfoodallergies == true;
		appItem.Display_Gluten_Free_Option__c = viewModel.displayglutenfree == true;
		appItem.Display_Halal_Option__c = viewModel.displayHalal == true;
		appItem.Display_Kosher_Option__c = viewModel.displaykosher == true;
		appItem.Display_Lactose_Intolerant_Option__c = viewModel.displaylactoseintolerant == true;
		appItem.Display_Neatness_Level_Option__c = viewModel.displayneatnesslevel == true;
		appItem.Display_NonSmoking_Option__c = viewModel.displaynonsmoking == true;
		appItem.Display_Off_Campus_Option__c = viewModel.displayoffcampus == true;
		appItem.Display_On_Campus_Option__c = viewModel.displayoncampus == true;
		appItem.Display_Other__c = viewModel.displayother == true;
		appItem.Display_Private_Bathroom_Option__c = viewModel.displayprivatebathroom == true;
		appItem.Display_Religious_Accomodations__c = viewModel.displayReligiousAccomodations == true;
		appItem.Display_Roommate_Requests__c = viewModel.displayroommaterequests == true;
		appItem.Display_Self_Catered_Option__c = viewModel.displayselfcatered == true;
		appItem.Display_Shabbat__c = viewModel.displayShabbat == true;
		appItem.Display_Single_Gender_Option__c = viewModel.displaysinglegender == true;
		appItem.Display_Single_Room_Option__c = viewModel.displaysingleroom == true;
		appItem.Display_Smoking_Option__c = viewModel.displaysmoking == true;
		appItem.Display_Typical_Bedtime_Option__c = viewModel.displaytypicalbedtime == true;
		appItem.Display_Vegan_Option__c = viewModel.displayVegan == true;
		appItem.Display_Vegetarian_Option__c = viewModel.displayvegetarian == true;
		appItem.Emergency_Treatment__c = viewModel.emergencyTreatment;
		appItem.Epi_Pen__c = viewModel.epiPen == true;
		appItem.Evaluator_Email__c = viewModel.evaluatorEmail;
		appItem.Evaluator_Name__c = viewModel.evaluatorName;
		appItem.Food_Allergies__c = viewModel.foodAllergies == true;
		appItem.Prefers_Food_Allergies__c = viewModel.foodAllergies == true;
		appItem.Food_Allergy_Arrangement_Description__c = viewModel.foodAllergyArrangementDescription;
		appItem.Food_Allergy_Special_Arrangements__c = viewModel.foodAllergySpecialArrangments == true;
		appItem.Prefers_Gluten_Free__c = viewModel.glutenFree == true;
		appItem.Good_Standing__c = viewModel.goodStanding;
		appItem.Good_Standing_Explanation__c = viewModel.goodStandingExplanation;
		appItem.Prefers_Halal__c = viewModel.halal == true;
		appItem.H_Aural_Comprehension__c = viewModel.hAuralComprehension;
		appItem.Heritage_Speaker__c = viewModel.heritageSpeaker == true;
		appItem.High_School_Courses__c = viewModel.highSchoolCourses == true;
		appItem.Housing_Option__c = viewModel.housingOption != null ? [SELECT Id FROM Housing_Option__c WHERE Name =: viewModel.housingOption].Id : null;
		appItem.Housing_Restrictions__c = viewModel.housingRestrictions == true;
		appItem.Housing_Restrictions_Description__c = viewModel.housingRestrictionsDescription;
		appItem.H_Reading__c = viewModel.hReading;
		appItem.H_Speaking__c = viewModel.hSpeaking;
		appItem.H_Writing__c = viewModel.hWriting;
		appItem.Prefers_Kosher__c = viewModel.kosher == true;
		appItem.Prefers_Lactose_Intolerant__c = viewModel.lactoseIntolerant == true;
		appItem.Learning_Disability__c = viewModel.learningDisability == true;
		appItem.Learning_Disability_Description__c = viewModel.learningDisabilityDescription;
		appItem.Medical_Dietary_Restriction__c = viewModel.medicalDietaryRestriction == true;
		appItem.Medical_Dietary_Restriction_Description__c = viewModel.medicalDietaryRestrictionDescription;
		appItem.Medical_Psych_Conditions__c = viewModel.medicalPsychConditions == true;
		appItem.Medical_Psych_Conditions_Explanation__c = viewModel.medicalPsychConditionsExplanation;
		appItem.Medical_Psych_Conditions_Treatment__c = viewModel.medicalPsychConditionsTreatment == true;
		appItem.Medication_Allergies__c = viewModel.medicationAllergies == true;
		appItem.Medication_Allergies_Description__c = viewModel.medicationAllergiesDescription;
		appItem.MSA_Aural_Comprehension__c = viewModel.msaAuralComprehension;
		appItem.MSA_Reading__c = viewModel.msaReading;
		appItem.MSA_Speaking__c = viewModel.msaSpeaking;
		appItem.MSA_Writing__c = viewModel.msaWriting;
		appItem.Neatness_Level__c = viewModel.neatnesslevel;
		appItem.Prefers_Non_Smoking__c = viewModel.nonSmoking == true;
		appItem.Prefers_Off_Campus__c = viewModel.offCampus == true;
		appItem.Prefers_On_Campus__c = viewModel.onCampus == true;
		appItem.Ongoing_Medical_Attention__c = viewModel.ongoingMedicalAttention == true;
		appItem.Ongoing_Medical_Attention_Description__c = viewModel.ongoingMedicalAttentionDescription;
		appItem.Prefers_Other__c = viewModel.other == true;
		appItem.Other_Medical_Data__c = viewModel.otherMedicalData == true;
		appItem.Other_Medical_Data_Details__c = viewModel.otherMedicalDataDescription;
		appItem.P_Aural_Comprehension__c = viewModel.pAuralComprehension;
		appItem.Phase__c = viewModel.phase;
		appItem.Phys_Activity_Restrictions_Description__c = viewModel.physActivityRestrictionsDescription;
		appItem.Physical_Activity_Restrictions__c = viewModel.physicalActivityRestrictions == true;
		appItem.P_Reading__c = viewModel.pReading;
		appItem.Prefers_Private_Bathroom__c = viewModel.privateBathroom == true;
		appItem.P_Speaking__c = viewModel.pSpeaking;
		appItem.P_Writing__c = viewModel.pWriting;
		appItem.Regularly_Speak__c = viewModel.regularlySpeak;
		appItem.Religious_Accomodations__c = viewModel.religiousAccomodations != null ? viewModel.religiousAccomodations.unescapeHtml4() : null;
		appItem.Roommate_Requests__c = viewModel.roommateRequests != null ? viewModel.roommateRequests.unescapeHtml4() : null;
		appItem.Prefers_Self_Catered__c = viewModel.selfCatered == true;
		appItem.Prefers_Shabbat__c = viewModel.shabbat == true;
		appItem.Prefers_Single_Gender__c = viewModel.singleGender == true;
		appItem.Prefers_Single_Room__c = viewModel.singleRoom == true;
		appItem.Prefers_Smoking__c = viewModel.smoking == true;
		appItem.Speaks_Arabic__c = viewModel.speaksArabic == true;
		appItem.Speaks_Colloquial_Egyptian__c = viewModel.speaksColloquialEgyptian == true;
		appItem.Speaks_Hebrew__c = viewModel.speaksHebrew == true;
		appItem.Speaks_Palestinian__c = viewModel.speaksPalestinian == true;
		appItem.Status__c = viewModel.status;
		appItem.Text_to_Sign__c = viewModel.textToSign;
		appItem.Typical_Bedtime__c = viewModel.typicalbedtime;
		appItem.Typical_Reaction__c = viewModel.typicalReaction;
		appItem.University_Courses__c = viewModel.universityCourses == true;
		appItem.Prefers_Vegan__c = viewModel.vegan == true;
		appItem.Prefers_Vegetarian__c = viewModel.vegetarian == true;
		appItem.Will_Attend_Religious_Service__c = viewModel.willAttendReligiousService == true;
		appItem.Personal_Interests__c = viewModel.personalInterests;
		appItem.Music_Preferences__c = viewModel.musicPreferences;
		appItem.Prefers_Children__c = viewModel.children == true;
		appItem.Not_Currently_Enrolled__c = viewModel.notCurrentlyEnrolled == true;
		appItem.Recommendation_Wavied__c = viewModel.recommendationWaived != null && viewModel.recommendationWaived != '' ? viewModel.recommendationWaived : appItem.Recommendation_Wavied__c;
		appItem.Evaluation_Waived__c = viewModel.evalWaived != null && viewModel.evalWaived != '' ? viewModel.evalWaived : appItem.Evaluation_Waived__c;
		// Learning Plan
		appItem.Learning_Plan_Disclosure__c = viewModel.learningPlanDisclosure != null && viewModel.learningPlanDisclosure != '' ? viewModel.learningPlanDisclosure : appItem.Learning_Plan_Disclosure__c;
		appItem.Learning_Plan_Academic_Goals_A_Long__c = viewModel.academicGoalsA != null ? viewModel.academicGoalsA.replaceAll('&#39;', '\'') : null;
		appItem.Learning_Plan_Academic_Goals_B_Long__c = viewModel.academicGoalsB != null ? viewModel.academicGoalsB.replaceAll('&#39;', '\'') : null;
		appItem.Learning_Plan_Academic_Goals_C_Long__c = viewModel.academicGoalsC != null ? viewModel.academicGoalsC.replaceAll('&#39;', '\'') : null;
		appItem.Learning_Plan_Personal_Goals_A_Long__c = viewModel.personalGoalsA != null ? viewModel.personalGoalsA.replaceAll('&#39;', '\'') : null;
		appItem.Learning_Plan_Personal_Goals_B_Long__c = viewModel.personalGoalsB != null ? viewModel.personalGoalsB.replaceAll('&#39;', '\'') : null;
		appItem.Learning_Plan_Personal_Goals_C_Long__c = viewModel.personalGoalsC != null ? viewModel.personalGoalsC.replaceAll('&#39;', '\'') : null;
		appItem.LearningPlan_Professional_Goals_A_Long__c = viewModel.professionalGoalsA != null ? viewModel.professionalGoalsA.replaceAll('&#39;', '\'') : null;
		appItem.LearningPlan_Professional_Goals_B_Long__c = viewModel.professionalGoalsB != null ? viewModel.professionalGoalsB.replaceAll('&#39;', '\'') : null;
		appItem.LearningPlan_Professional_Goals_C_Long__c = viewModel.professionalGoalsC != null ? viewModel.professionalGoalsC.replaceAll('&#39;', '\'') : null;
		appItem.Learning_Plan_Specific_Actions_1_Long__c = viewModel.specificActions1 != null ? viewModel.specificActions1.replaceAll('&#39;', '\'') : null;
		appItem.Learning_Plan_Specific_Actions_2_Long__c = viewModel.specificActions2 != null ? viewModel.specificActions2.replaceAll('&#39;', '\'') : null;
		appItem.Learning_Plan_Specific_Actions_3_Long__c = viewModel.specificActions3 != null ? viewModel.specificActions3.replaceAll('&#39;', '\'') : null;
		appItem.Learning_Plan_Specific_Actions_4_Long__c = viewModel.specificActions4 != null ? viewModel.specificActions4.replaceAll('&#39;', '\'') : null;
		appItem.Learning_Plan_Specific_Actions_5_Long__c = viewModel.specificActions5 != null ? viewModel.specificActions5.replaceAll('&#39;', '\'') : null;
		appItem.Learning_Plan_Other_Long__c = viewModel.otherInformation != null ? viewModel.otherInformation.replaceAll('&#39;', '\'') : null;
		// Populate Origianl Values if learning plan is not being updated
		appItem.Learning_Plan_Professional_Goals_A__c = viewModel.learningPlanUpdate == false ? appItem.LearningPlan_Professional_Goals_A_Long__c : appItem.Learning_Plan_Professional_Goals_A__c;
		appItem.Learning_Plan_Professional_Goals_B__c = viewModel.learningPlanUpdate == false ? appItem.LearningPlan_Professional_Goals_B_Long__c : appItem.Learning_Plan_Professional_Goals_B__c;
		appItem.Learning_Plan_Professional_Goals_C__c = viewModel.learningPlanUpdate == false ? appItem.LearningPlan_Professional_Goals_C_Long__c : appItem.Learning_Plan_Professional_Goals_C__c;
		appItem.Learning_Plan_Specific_Actions_1__c = viewModel.learningPlanUpdate == false ? appItem.Learning_Plan_Specific_Actions_1_Long__c : appItem.Learning_Plan_Specific_Actions_1__c;
		appItem.Learning_Plan_Specific_Actions_2__c = viewModel.learningPlanUpdate == false ? appItem.Learning_Plan_Specific_Actions_2_Long__c : appItem.Learning_Plan_Specific_Actions_2__c;
		appItem.Learning_Plan_Specific_Actions_3__c = viewModel.learningPlanUpdate == false ? appItem.Learning_Plan_Specific_Actions_3_Long__c : appItem.Learning_Plan_Specific_Actions_3__c;
		appItem.Learning_Plan_Specific_Actions_4__c = viewModel.learningPlanUpdate == false ? appItem.Learning_Plan_Specific_Actions_4_Long__c : appItem.Learning_Plan_Specific_Actions_4__c;
		appItem.Learning_Plan_Specific_Actions_5__c = viewModel.learningPlanUpdate == false ? appItem.Learning_Plan_Specific_Actions_5_Long__c : appItem.Learning_Plan_Specific_Actions_5__c;
		appItem.Learning_Plan_Academic_Goals_A__c = viewModel.learningPlanUpdate == false ? appItem.Learning_Plan_Academic_Goals_A_Long__c : appItem.Learning_Plan_Academic_Goals_A__c;
		appItem.Learning_Plan_Academic_Goals_B__c = viewModel.learningPlanUpdate == false ? appItem.Learning_Plan_Academic_Goals_B_Long__c : appItem.Learning_Plan_Academic_Goals_B__c;
		appItem.Learning_Plan_Academic_Goals_C__c = viewModel.learningPlanUpdate == false ? appItem.Learning_Plan_Academic_Goals_C_Long__c : appItem.Learning_Plan_Academic_Goals_C__c;
		appItem.Learning_Plan_Personal_Goals_A__c = viewModel.learningPlanUpdate == false ? appItem.Learning_Plan_Personal_Goals_A_Long__c : appItem.Learning_Plan_Personal_Goals_A__c;
		appItem.Learning_Plan_Personal_Goals_B__c = viewModel.learningPlanUpdate == false ? appItem.Learning_Plan_Personal_Goals_B_Long__c : appItem.Learning_Plan_Personal_Goals_B__c;
		appItem.Learning_Plan_Personal_Goals_C__c = viewModel.learningPlanUpdate == false ? appItem.Learning_Plan_Personal_Goals_C_Long__c : appItem.Learning_Plan_Personal_Goals_C__c;
		appItem.Learning_Plan_Other__c = viewModel.learningPlanUpdate == false ? appItem.Learning_Plan_Other_Long__c : appItem.Learning_Plan_Other__c;

		appItem.Passport_Country_Of_Issuance__c = viewModel.passportCountry;
		appItem.Passport_Expiration_Date__c = viewModel.passportExpirationDate;
		appItem.Passport_Number__c = viewModel.passportNumber;
		appItem.Passport_Does_Not_Have__c = viewModel.passportDoNotHave == true;
		appItem.Passport_In_Renewal__c = viewModel.passportInRenewal == true;
		
		if(viewModel.recordType == 'Addresses' || viewModel.recordType == 'Update_Emergency_Contact')
		{
			studentContact.MailingCity = viewModel.mailingCity;
			studentContact.MailingCountry = viewModel.mailingCountry;
			studentContact.MailingPostalCode = viewModel.mailingZip;
			studentContact.MailingState = viewModel.mailingState;
			studentContact.MailingStreet = viewModel.mailingStreet;
			studentContact.OtherCity = viewModel.sameOtherAddress != null ? viewModel.sameOtherAddress ? viewModel.mailingCity : viewModel.otherCity : viewModel.otherCity;
			studentContact.OtherCountry = viewModel.sameOtherAddress != null ? viewModel.sameOtherAddress ? viewModel.mailingCountry : viewModel.otherCountry : viewModel.otherCountry;
			studentContact.OtherPostalCode = viewModel.sameOtherAddress != null ? viewModel.sameOtherAddress ? viewModel.mailingZip : viewModel.otherZip : viewModel.otherZip;
			studentContact.OtherState = viewModel.sameOtherAddress != null ? viewModel.sameOtherAddress ? viewModel.mailingState : viewModel.otherState : viewModel.otherState;
			studentContact.OtherStreet = viewModel.sameOtherAddress != null ? viewModel.sameOtherAddress ? viewModel.mailingStreet : viewModel.otherStreet : viewModel.otherStreet;
			studentAccount.BillingCity = viewModel.sameBillingAddress != null ? viewModel.sameBillingAddress ? viewModel.mailingCity : viewModel.billingCity : viewModel.billingCity;
			studentAccount.BillingCountry = viewModel.sameBillingAddress != null ? viewModel.sameBillingAddress ? viewModel.mailingCountry : viewModel.billingCountry : viewModel.billingCountry;        studentAccount.BillingPostalCode = viewModel.sameBillingAddress != null ? viewModel.sameBillingAddress ? viewModel.mailingZip : viewModel.billingZip : viewModel.billingZip;
			studentAccount.BillingState = viewModel.sameBillingAddress != null ? viewModel.sameBillingAddress ? viewModel.mailingState : viewModel.billingState : viewModel.billingState;
			studentAccount.BillingStreet = viewModel.sameBillingAddress != null ? viewModel.sameBillingAddress ? viewModel.mailingStreet : viewModel.billingStreet : viewModel.billingStreet;

			studentContact.Directory_Information_Opt_Out__c = viewModel.doNotContact ? 'Withheld' : 'Release';
			
			Id otherRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Other').getRecordTypeId();
			
			Boolean needsUpdateContactItem = false;
			Integer numberOfEcontacts = 0;
			List<Contact> relatedContacts = new List<Contact>();
			for(model_contact mc: viewModel.relatedContacts)
			{
				Contact contact1 = new Contact(
				Id = mc.ContactId,
				FirstName = mc.firstName,
				LastName = mc.lastName,
				Phone = mc.workPhone,
				HomePhone = mc.homePhone,
				MobilePhone = mc.mobilePhone,
				MailingStreet = mc.mailingStreet,
				MailingCity = mc.mailingCity,
				MailingState = mc.mailingState,
				MailingPostalCode = mc.mailingPostalCode,
				MailingCountry = mc.mailingCountry,
				Student__c = appItem.Application__r.Applicant__c,            
				Email = mc.email == '' ? null : mc.email,
				RecordTypeId = otherRecordType,            
				Relationship_With_Student__c = mc.relationshipWithStudent,
				Emergency_Contact__c = mc.isEmergencyContact,
				Send_Marketing_Materials__c = mc.sendMarketingMaterials == true,
				Do_Not_Contact__c = mc.sendMarketingMaterials == false,
				OwnerId = studentContact.OwnerId);
				system.debug(contact1.Email);
				if((contact1.Email != null)&& contact1.Emergency_Contact__c && viewModel.recordType == 'Addresses')
				{
					numberOfEcontacts = numberOfEcontacts + 1;
				}            
				relatedContacts.add(contact1);
			}
			studentApplication.Emergency_Contact__c = relatedContacts.get(0).Id; 
			database.upsert(relatedContacts);
			sObjects.add(studentContact);
			sObjects.add(studentAccount);
			system.debug(numberOfEcontacts);
			if(numberOfEcontacts < 1 && viewModel.recordType == 'Addresses')
			{
				Application_Item__c updateEmergencyContactItem = [SELECT Id FROM Application_Item__c WHERE Application__c =: studentApplication.Id AND RecordType.DeveloperName = 'Update_Emergency_Contact'].get(0);
				updateEmergencyContactItem.Phase__c = 'Post-Acceptance';
				sObjects.add(updateEmergencyContactItem);
			}
		}

		System.debug(appItem.Passport_Expiration_Date__c);
		if(viewModel.recordType == 'Scholarship')
		{
			/*
			if (viewModel.FASFA != true)
			{
				viewModel.FASFA = false;
			}
			studentApplication.FASFA__c = viewModel.FASFA;
			studentApplication.Expected_Family_Contribution__c = viewModel.EFC;
			studentApplication.Tuition_Remission__c = viewModel.TuitionRemission;
			studentApplication.University_Discount__c = viewModel.TuitionDiscount;
			studentApplication.College_Savings_Plan__c = viewModel.CollegeSavingsPlan;
			studentApplication.V_A_Benefits__c = viewModel.VABenefits;
			studentApplication.AmountStudentCanPay__c = viewModel.AmountStudentCanPay;
			studentApplication.AmountFamilyCanPay__c = viewModel.AmountFamilyCanPay;
			studentApplication.Home_University_Tuition__c = viewModel.HomeTuition;
			studentApplication.Home_University_Study_Abroad_Fees__c = viewModel.HomeStudyAbroadFees;
			if (viewModel.IFSAGeneral != true)
			{
				viewModel.IFSAGeneral = false;
			}
			studentApplication.General_Need_Scholarship__c = viewModel.IFSAGeneral;
			if (viewModel.FirstGen != true)
			{
				viewModel.FirstGen = false;
			}
			studentApplication.First_Gen__c = viewModel.FirstGen;
			if (viewModel.GAPScholarship != true)
			{
				viewModel.GAPScholarship = false;
			}
			studentApplication.GAP_Scholarship__c = viewModel.GAPScholarship;
			if (viewModel.IFSAWorkStudy != true)
			{
				viewModel.IFSAWorkStudy = false;
			}
			studentApplication.Work_Study_Scholarship__c = viewModel.IFSAWorkStudy;
			
			studentApplication.Work_Study_Scholarship__c = viewModel.IFSAWorkStudy;
			studentApplication.Financial_Aid_Officer_Name__c = viewModel.FinancialAidOfficersName;
			studentApplication.Financial_Aid_Officer_Phone__c = viewModel.FinancialAidOfficersPhone; 
			studentApplication.Financial_Aid_Officer_Email__c = viewModel.FinancialAidOfficersEmail;	
			
			if(viewModel.aidList != null)
			{
				List<Financial_Aid_Item__c> aidItems = new List<Financial_Aid_Item__c>();
				for(FinancialAidItemViewModel vmItem : viewModel.aidList)
				{
					Financial_Aid_Item__c item = new Financial_Aid_Item__c();
					item.Application__c = studentApplication.Id;
					item.Financial_Aid_Types__c = vmItem.aidType;
					item.Disbursement_Amount__c = vmItem.disbursmentAmount;
					DateTime dt = vmItem.disbursmentDate;
					item.Disbursement_Date__c = date.newInstance(dt.Year(), dt.Month(), dt.Day());
					aidItems.add(item);
				}
				database.insert(aidItems);

			}
			
			sObjects.add(studentApplication);
			*/
			}
		
		if(viewModel.RecordType == 'Agreements_and_Releases')
		{
			studentContact.Directory_Information_Opt_Out__c = viewModel.directoryOptOutStatus;
			sObjects.add(studentContact);
		}
		if(viewModel.recordType == 'Medical_Form')
		{
			appItem.Completed_By__c = studentContact.Id;
			appItem.Applicant_First_Name__c = studentContact.FirstName;
			appItem.Applicant_Owner_Name__c = studentApplication.Owner.Name;
			appItem.Applicant_Owner_Email__c = studentApplication.Owner.Email;
			appItem.Applicant_Owner_Phone__c = studentApplication.Owner.Phone;
			appItem.Applicant_Owner_Title__c = studentApplication.Owner.Title;
		}

		if(viewModel.recordType == 'Spanish_Language_Evaluation' && viewModel.evaluatorEmail != null && viewModel.evaluatorEmail.length() > 0)
		{
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setReplyTo('forms@ifsa-butler.org');
			mail.setSenderDisplayName('IFSA-Butler No Reply');
			mail.setToAddresses(new List<String> {viewModel.evaluatorEmail});
			mail.setSubject('IFSA Student Spanish Language Evaluation');
			//Message changed on 2/2/18 by @jayholt; added conditional for displaying different text depending on student's waiver choice + misc verbiage changes
			//mail.setHtmlBody('Hello ' + viewModel.evaluatorName + ',<br/><br/><p>Recently, a student attending your institution has requested that you fill out a Spanish Language Evaluation for them to study abroad at an IFSA-Butler intermediate or advanced Spanish program.</p><p>For more information or to complete the evaluation, please click this link <a href="https://portal.ifsa-butler.org/studentportal/SP_SpanishEvaluation?app=' + appItem.Application__c + '&appItem=' + viewModel.id + '">here.</a> If that does not work, you can copy and paste the following into your browser:</p>');
			appItem.Spanish_Language_Evaluation_URL__c = 'https://portal.ifsa-butler.org/studentportal/SP_SpanishEvaluation?app=' + appItem.Application__c + '&appItem=' + viewModel.id;
			String studentName = studentContact.FirstName + ' ' + studentContact.LastName;
			String waiverText = '';
			if(appItem.Evaluation_Waived__c == 'Yes')
				waiverText = 'Please note that the student waived their right to view your evaluation.';
			else
				waiverText = 'Please note that the student did not waive their right to view your evaluation.';
			mail.setHtmlBody('<p>Dear ' + viewModel.evaluatorName + ',</p><p>Recently ' + studentName + ', a student attending your institution, has requested that you fill out a Spanish Language Evaluation as part of their application to study abroad on the ' + studentApplication.Program_Term__r.Display_Name__c + ' program through the IFSA.</p><p>' + waiverText + '</p><p>Please click on the link below to complete ' + studentName + '\'s language evaluation.</p><p><a href="' + appItem.Spanish_Language_Evaluation_URL__c + '">Language Evaluation</a></p><p>If you encounter any problems with the evaluation, please contact us.</p><p>Thank you,<br><strong>IFSA</strong><br>U.S. Toll Free Telephone<br>(800) 858-0229<br><a href="mailto:admissions@ifsa-butler.org">admissions@ifsa-butler.org</a></p>');
			Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
		}
		if(viewModel.recordType == 'Class_Interest_Form' && appItem.Status__c == 'Complete')
		{
			formBuilderComponentController.Form form = formBuilderComponentController.initForm(appItem.Application_Requirement__r.Dynamic_Form__c, null);
			Map<Id, formBuilderComponentController.Rule> phaseRules = new Map<Id, formBuilderComponentController.Rule>();
			if(form.formRules != null)
			{
				for(formBuilderComponentController.Rule rule: form.formRules)
				{
					if(rule.ruleName == 'Change_Phase_of_App_Item_X')
					{
						phaseRules.put(rule.appReqId, rule);
					}
				}
			}
			if(!phaseRules.isEmpty())
			{
				Map<Id, Course_Registration__c> courseCourseRegMap = new Map<Id, Course_Registration__c>();
				for(Course_Registration__c courseReg: [SELECT Id, Course__c FROM Course_Registration__c WHERE Application__c =: appItem.Application__c])
				{
					courseCourseRegMap.put(courseReg.Course__c, courseReg);
				}
				List<Application_Item__c> itemsToUpdate = [SELECT Id, Phase__c, Application_Requirement__c FROM Application_Item__c WHERE Application__c =: studentApplication.Id AND Application_Requirement__c IN: phaseRules.keySet()];
				for(Application_Item__c itemToUpdate: itemsToUpdate)
				{
					formBuilderComponentController.Rule rule = phaseRules.get(itemToUpdate.Application_Requirement__c);
					for(formBuilderComponentController.RuleItem ri: rule.ruleItems)
					{
						if(courseCourseRegMap.containsKey(ri.relId))
						{
							itemToUpdate.Phase__c = rule.changeToPhase;
							sobjects.add(itemToUpdate);
						}
					}
				}
			}
		}
		sObjects.add(appItem);
		sObjects.add(studentApplication);
		
		List<Database.SaveResult> results = Database.update(sObjects);
		Boolean isSaved = true;
		
		for(Database.SaveResult result : results)
		{
		isSaved = isSaved && result.isSuccess();
		}

		if(viewModel.recordType == 'Program_Approval')
		{
			List<Application_Item__c> incompleteAppItems = [SELECT Id FROM Application_Item__c WHERE Application__c =: studentApplication.Id AND Status__c = 'Incomplete' AND Phase__c = 'Pre-Admit'];
			closeCompletionNotification(studentApplication.Id);
		}
		List<Housing_Preference__c> housingPreferences = new List<Housing_Preference__c>();
		if(viewModel.housingOptions != null)
		{
			for(Map<String,String> option : viewModel.housingOptions)
			{
				if(option.get('Rank') != null)
				{
					Housing_Preference__c preference = new Housing_Preference__c();
					preference.Application__c = appItem.Application__c;
					preference.Program_Term_Housing_Option__c = option.get('Id');
					preference.Rank__c = Decimal.valueOf(option.get('Rank'));
					housingPreferences.add(preference);
				}
			}
			if(housingPreferences.size() > 0)
			{
				Database.insert(housingPreferences);
			}
		}
		
		List<Course__c> courses = new List<Course__c>();
		Id courseRecordTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId();
		if(viewModel.courses != null && viewModel.courses.size() > 0)
		{
			for(studentHomeSchoolCourseViewModel courseItem : viewModel.courses)
			{
				if(courseItem.Id == null || ('').equals(String.valueOf(courseItem.Id)))
				{
					Course__c course = new Course__c();
					course.RecordTypeId = courseRecordTypeId;
					course.Name = courseItem.courseName;
					course.Course_Code__c = courseItem.courseCode;
					course.Application_Item__c = appItem.Id;
					courses.add(course);
				}
			}
			
			if(courses.size() > 0)
			{
				Database.insert(courses);
			}
		}
		System.debug('Status: ' + viewModel.status);
		System.debug(viewModel.status == 'Complete' || viewmodel.status == 'Started');
		return viewModel.status == 'Complete' || viewmodel.status == 'Started';
	}
	/**
    * @description Gets details about a travel plan
    */
    @RemoteAction
    public static List<Flight__c> getTravelDetails(String name)
    {
        return [SELECT Name, Arrival_Airport_Code__c, Arrival_Time__c, Departure_Airport_Code__C, Departure_Time__c FROM Flight__c WHERE Travel_Plan__r.Name =: name];
    }
	/**
    * @description Submits requests recommendations
    */
	@RemoteAction
    public static Boolean submitRecommender(String name, String email, String applicationItemId)
    {
        try
        {
            Id appItemId = Id.valueOf(applicationItemId);
            Application_Item__c appItem = [SELECT Id, Name, Application__r.Applicant__r.FirstName, Application__r.Applicant__r.LastName, Application__r.Program_Term__r.Display_Name__c FROM Application_Item__c WHERE Id =: applicationITemId].get(0);
            String studentName = appItem.Application__r.Applicant__r.FirstName + ' ' + appItem.Application__r.Applicant__r.LastName;
            Recommendation__c rcommendation = new Recommendation__c();
            rcommendation.Name = name;
            rcommendation.Recommender_Name__c = name;
            rcommendation.Application_Item__c = appItemId;
            rcommendation.Email_Address__c = email;
            if(Database.insert(rcommendation).isSuccess())
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setReplyTo('forms@ifsa-butler.org');
                mail.setSenderDisplayName('IFSA-Butler No Reply');
                mail.setToAddresses(new List<String> {email});
                mail.setSubject('IFSA-Butler Student Recommendation');
                mail.setHtmlBody('Dear ' + rcommendation.Name + ',<p>This is a request for recommendation letter for ' + studentName + '.</p><p>' + studentName + ' applied to study abroad at ' + appItem.Application__r.Program_Term__r.Display_Name__c + ' through IFSA.</p><p>In an effort to obtain an objective letter of recommendation from professors, IFSA does not disclose letters of recommendation to students.</p><p>Please click on the link below to write a recommendation letter for ' + studentName + '.</p><p><a href="https://portal.ifsa-butler.org/studentportal/SP_Recommendation?app=' + appItemId + '&recommender=' + rcommendation.Id + '">Recommendation Letter</a></p><p>If you encounter any problems with the online recommendation letter, please contact us.</p><p>Thank you,<br/>IFSA<br/>U.S. Toll Free Telephone<br/>800-858-0229<br/>admissions@ifsa-butler.org</p><p>CONFIDENTIALITY NOTICE: The materials enclosed with this facsimile transmission are private and confidential and are the property of the sender. The information contained in the material is privileged and is intended only for the use of the individual(s) or entity(ies) named below. If you are not the intended recipient, be advised that any unauthorized disclosure, copying, distribution or the taking of any action in reliance on the contents of this telecopied information is strictly prohibited. If you have received this facsimile transmission in error, please immediately notify us by telephone to arrange for return of the forwarded documents to us.</p>');
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
            }
            else
            {
                return false;
            }
        }
        catch(Exception e)
        {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            return false;
        }
        return true;
    }
	
	@RemoteAction
	public static Boolean uploadFile(String fileData, String fileType, String fileName, String recordId)
	{
		Application_Item__c appItem = [SELECT Id, Name FROM Application_Item__c WHERE Id =: recordId];
		return submitSignature(appItem.Id, appItem.Name, fileData, fileType, fileName);
	}
	@RemoteAction
	public static List<studentApplyItemViewModel> getApplicationItems(String appId)
	{
		Application__c application = [SELECT Id, Status__c, Status_Contract_Signed__c FROM Application__c WHERE Id =: appId];
		List<Application_Item__c> applicationItems = new List<Application_Item__c>();
		List<studentApplyItemViewModel> result = new List<studentApplyItemViewModel>();
		List<String> phase = new List<String>();    
		phase.add('Optional');
		if(application.Status__c == 'Program Selected' || application.Status__c.contains('Submit') || application.Status__c.contains('Accepted') || application.Status__c == 'Waitlisted' || application.Status__c == 'On Site' || application.Status__c == 'Program Completed')
		{
			phase.add('Pre-Admit');
		}
		if(application.Status__c.contains('Submit') || application.Status__c.contains('Accepted') || application.Status__c == 'Waitlisted' || application.Status__c == 'On Site' || application.Status__c == 'Program Completed')
		{
			phase.add('Pre-Acceptance');
		}
		if(application.Status__c.contains('Accepted') || application.Status__c == 'On Site' || application.Status__c == 'Program Completed')
		{
			phase.add('Post-Acceptance');
		}
		if(application.Status_Contract_Signed__c != null  || application.Status__c == 'On Site' || application.Status__c == 'Program Completed')
		{
			phase.add('Post-Contract');
		}
		System.debug(phase);
		if(applicationService.isActiveApplication(application.Status__c))
		{
			applicationItems = [SELECT Id, Name, Status__c, Phase__c, RecordType.Name, Deadline__c, Application_Requirement__r.Dynamic_Form__r.Status__c, Application_Requirement__r.Dynamic_Form__c FROM Application_Item__c WHERE Application__c =: application.Id AND Phase__c IN: phase];
		}		
		else
		{
			applicationItems = [SELECT Id, Name, Status__c, Phase__c, RecordType.Name, Deadline__c FROM Application_Item__c WHERE Application__c =: application.Id AND Status__c = 'Complete' AND Phase__c =: phase];
		}
		if(applicationItems.isEmpty() && applicationService.isActiveApplication(application.Status__c))
		{
			portalRemotingMethods.populateApplicationItems(application.Id);
			applicationItems = [SELECT Id, Name, Status__c, Phase__c, RecordType.Name, Deadline__c FROM Application_Item__c WHERE Application__c =: application.Id AND Status__c = 'Complete' AND Phase__c =: phase];
		}
		for(Application_Item__c applicationItem : applicationItems)
        {
            result.add(new studentApplyItemViewModel(applicationItem));
        }
		return result;
	}
	@RemoteAction
	public static Boolean saveDynamicForm(String jsonData, String fileData, String fileType, String fileName)
	{
		dynamicFormViewModel vm = new dynamicFormViewModel();
		System.debug(jsonData);
		if(jsonData.length() > 0)
		{
			vm = (dynamicFormViewModel) JSON.deserialize(jsonData, dynamicFormViewModel.class);
			if(submitPDF(vm.applicationItemId, fileData, fileType, fileName))
			{
				return vm.save();
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}
	public static Boolean submitPDF(Id recordId, String fileData, String fileType, String fileName)
	{
		if(fileData != null && fileType != null && fileData != '' && fileType != '')
	    {
	    	try
	    	{
			    String fileExtension = fileName.substringAfterLast('.');
			    Attachment file = new Attachment(ParentId=recordId, name=(fileName), ContentType='application/pdf', Body=EncodingUtil.base64Decode(fileData));	        
			    database.insert(file);
				return true;
		    }
	    	catch(Exception e)
	    	{
			    System.debug(LoggingLevel.WARN, e.getMessage());
			    return false;
		    }
	    }
	    return false;
	}
	@RemoteAction
	public static List<SObject> getRecords(String objectName, Id[] itemIds)
	{
		List<SObject> returnList = ApexQueryUtility.selectAllFrom(objectName, 'Id IN ' + apexQueryUtility.buildInClause(itemIds));

		return returnList;
	}

	@RemoteAction
	public static Application__c getApplication(String appId)
	{
		return (Application__c) apexQueryUtility.selectAllFrom('Application__c', 'Program_Term__r.Start_Of_Second_Term__c, Program_Term__r.Program__c', 'Id = \'' + appId + '\'').get(0);
	}

	@RemoteAction
	public static chartJSRemotingResponse getFavorites(String appId)
	{
		Application__c app = [SELECT Id, Program_Term__r.Program__c, Applicant__c, Program_Term_Section__c FROM Application__c WHERE Id =: appId];

		List<Favorite__c> favorites;
		if(app.Program_Term_Section__c == 'Fall' || app.Program_Term_Section__c == 'Spring')
		{
			 favorites  = [SELECT Id, Name, Contact__c, Course__c, Course__r.Course_Title_2__c, Course__r.Course_Code__c, Course__r.Course_Description_Short__c, CreatedDate, Course__r.Host_Credits__c, Course__r.Host_Institution__c, Course__r.Host_Institution__r.Name, Course__r.US_Semester_Credit_Hours__c, Course__r.US_Terms__c FROM Favorite__c WHERE Contact__c =: app.Applicant__c AND Course__c IN (SELECT Course__c FROM Program_Course__c WHERE Program__c =: app.Program_Term__r.Program__c AND Course__r.US_Terms__c includes ('Fall','Spring'))];
		}
		else if(app.Program_Term_Section__c.contains('Year'))
		{
			favorites  = [SELECT Id, Name, Contact__c, Course__c, Course__r.Course_Title_2__c, Course__r.Course_Code__c, Course__r.Course_Description_Short__c, CreatedDate, Course__r.Host_Credits__c, Course__r.Host_Institution__c, Course__r.Host_Institution__r.Name, Course__r.US_Semester_Credit_Hours__c, Course__r.US_Terms__c FROM Favorite__c WHERE Contact__c =: app.Applicant__c AND Course__c IN (SELECT Course__c FROM Program_Course__c WHERE Program__c =: app.Program_Term__r.Program__c AND Course__r.US_Terms__c != 'Summer')];
		}		
		else 
		{
			 favorites  = [SELECT Id, Name, Contact__c, Course__c, Course__r.Course_Title_2__c, Course__r.Course_Code__c, Course__r.Course_Description_Short__c, CreatedDate, Course__r.Host_Credits__c, Course__r.Host_Institution__c, Course__r.Host_Institution__r.Name, Course__r.US_Semester_Credit_Hours__c, Course__r.US_Terms__c FROM Favorite__c WHERE Contact__c =: app.Applicant__c AND Course__c IN (SELECT Course__c FROM Program_Course__c WHERE Program__c =: app.Program_Term__r.Program__c AND Course__r.US_Terms__c includes ('Summer'))];
		}

		return new chartJSRemotingResponse(favorites);
	}
	@RemoteAction
	public static studentResourcesViewModel getApplicationResources(String appId)
	{
		studentResourcesViewModel viewModel = new studentResourcesViewModel();
		ifsaApplicationWrapper application = new ifsaApplicationWrapper(appId);
		ifsaProgramTermWrapper programTerm = new ifsaProgramTermWrapper(application.getProgramTermId());

		// BBARLOW - Modified SOQL query so that the body of attachments does not get pulled into viewmodel
		// viewModel.attachments = apexQueryUtility.selectAllFrom('Attachment', 'ParentId IN (\'' + application.getProgramTermId() + '\', \'' + programTerm.getCountryId() + '\', \'' + programTerm.getProgramId() + '\', \'' + programTerm.getTermId() + '\')');
		
		List<Id> resourceGroupIds;
		if(!application.isCustom())
		{
			resourceGroupIds = new List<Id>{application.getProgramTermId(), programTerm.getCountryId(), programTerm.getProgramId(), programTerm.getTermId()};
		}
		else
		{
			//resourceGroupIds = new List<Id>{application.getProgramTermId(), programTerm.getProgramId(), application.getApplicantId(), Id.valueOf(appId)};
			resourceGroupIds = new List<Id>{application.getProgramTermId(), programTerm.getProgramId(), application.getApplicantId()};

		}

		if(application.getParentProgramTermId() != null) resourceGroupIds.add(application.getParentProgramTermId());
		// Get Files
		viewModel.files = apexQueryUtility.selectAllFrom('ContentDocumentLink', 'ContentDocument.Description, ContentDocument.Title, ContentDocument.LatestPublishedVersionId', 'LinkedEntityId IN' + apexQueryUtility.buildInClause(resourceGroupIds));
       //get application files
		viewModel.app_files = [SELECT Id, ContentDocument.Description, ContentDocument.Title, ContentDocument.LatestPublishedVersionId, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: appId];

		// Get Attachments
		viewModel.attachments = [SELECT Id, Name, Description FROM Attachment WHERE ParentId IN: resourceGroupIds];
        //get application attachments
        viewModel.app_attachments = [SELECT Id, Name, Description FROM Attachment WHERE ParentId =:appId];

		List<Schedule__c> schedules = apexQueryUtility.selectAllFrom('Schedule__c', 'RecordType.Name, Country__r.Name', 'Program_Term__c IN ' + apexQueryUtility.buildInClause(resourceGroupIds));
		for(Schedule__c schedule: schedules)
		{
			if(schedule.Status__c == 'Approved')
			{
				viewModel.scheduleList.add(new model_schedule(schedule));
			}
		}
		// Get Resource Items
		if(application.getParentProgramTermId() != null && !application.isCustom())
		{
			viewModel.resourceList = [SELECT Name, Category__c, Content__c FROM Resource_Item__c WHERE Country__c =: programTerm.getCountryId() OR Program__c =: programTerm.getProgramId() OR Program_Term__c =: application.getProgramTermId() OR Program_Term__r.Parent_Program_Term__c =: application.getParentProgramTermId()];
		}
		else if(application.getParentProgramTermId() == null && !application.isCustom())
		{
			viewModel.resourceList = [SELECT Name, Category__c, Content__c FROM Resource_Item__c WHERE Country__c =: programTerm.getCountryId() OR Program__c =: programTerm.getProgramId() OR Program_Term__c =: application.getProgramTermId()];
		}
		else
		{
			viewModel.resourceList = [SELECT Name, Category__c, Content__c FROM Resource_Item__c WHERE Program__c =: programTerm.getProgramId() OR Program_Term__c =: application.getProgramTermId()];
		}
		// Get Resource Categories
		Map<String, String> catMap = new Map<String, String>(); 
		for(Resource_Item__c r: viewModel.resourceList)
		{
			catMap.put(r.Category__c, r.Category__c);
		}
		for(String cat: catMap.values())
		{
			viewModel.categories.add(cat);
			system.debug(cat);
		}

		// Get Program Term Dates
		Program_Term__c pt = (Program_Term__c) apexQueryUtility.selectAllFrom('Program_Term__c', '(SELECT Id, OOPEX_Approval_Status__c FROM OOPEX__r)', 'Id = \'' + application.getProgramTermId() + '\'').get(0);
		Program_Term__c ppt =  programTerm.getParentProgramTermId() != null ? (Program_Term__c) apexQueryUtility.selectAllFrom('Program_Term__c', '(SELECT Id, OOPEX_Approval_Status__c FROM OOPEX__r)', 'Id = \'' + programTerm.getParentProgramTermId() + '\'').get(0) : new Program_Term__c();
		
		viewModel.applicationDeadline = pt.Application_Deadline__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Application_Deadline__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Application_Deadline__c);
		viewModel.assessmentsBegin = pt.Assessments_Begin__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Assessments_Begin__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Assessments_Begin__c);
		viewmodel.assessmentsEnd = pt.Assessments_End__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Assessments_End__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Assessments_End__c);
		viewModel.classesBegin = pt.Classes_Begin__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Classes_Begin__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Classes_Begin__c);
		viewModel.classesEnd = pt.Classes_End__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Classes_End__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Classes_End__c);
		viewModel.endDate = pt.End_Date__c != null ? isApproved(pt.Date_Approval_Status__c, pt.End_Date__c) : isApproved(ppt.Date_Approval_Status__c, ppt.End_Date__c);
		viewModel.examBegin = pt.Exam_End_Date__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Exam_End_Date__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Exam_End_Date__c);
		viewModel.examEnd = pt.Exam_Start_Date__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Exam_Start_Date__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Exam_Start_Date__c);
		viewModel.groupTransferToHostCity = pt.Group_Transfer_to_Host_City__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Group_Transfer_to_Host_City__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Group_Transfer_to_Host_City__c);
		viewModel.ifsaOrientationEndDate = pt.IFSA_Orientation_End_Date__c != null ? isApproved(pt.Date_Approval_Status__c, pt.IFSA_Orientation_End_Date__c) : isApproved(ppt.Date_Approval_Status__c, ppt.IFSA_Orientation_End_Date__c);
		viewModel.ifsaOrientationStartDate = pt.IFSA_Orientation_Start_Date__c != null ? isApproved(pt.Date_Approval_Status__c, pt.IFSA_Orientation_Start_Date__c) : isApproved(ppt.Date_Approval_Status__c, ppt.IFSA_Orientation_Start_Date__c);
		viewModel.moveIntoTermHousing = pt.Move_into_Term_Housing__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Move_into_Term_Housing__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Move_into_Term_Housing__c);
		viewModel.programDueDate = pt.Program_Due_Date__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Program_Due_Date__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Program_Due_Date__c);
		viewModel.startDate = pt.Start_Date__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Start_Date__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Start_Date__c);
		viewModel.startOfSecondTerm = pt.Start_Of_Second_Term__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Start_Of_Second_Term__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Start_Of_Second_Term__c);
		viewModel.suggestedDepartureFromUS = pt.Suggested_Departure_from_U_S__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Suggested_Departure_from_U_S__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Suggested_Departure_from_U_S__c);
		viewModel.universityOrientationEnds = pt.University_Orientation_Ends__c != null ? isApproved(pt.Date_Approval_Status__c, pt.University_Orientation_Ends__c) : isApproved(ppt.Date_Approval_Status__c, ppt.University_Orientation_Ends__c);
		viewModel.universityOrientationStarts = pt.University_Orientation_Starts__c != null ? isApproved(pt.Date_Approval_Status__c, pt.University_Orientation_Starts__c) : isApproved(ppt.Date_Approval_Status__c, ppt.University_Orientation_Starts__c);
		viewModel.arrivalWindowEndTime = pt.Arrival_Window_End_Time__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Arrival_Window_End_Time__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Arrival_Window_End_Time__c);
		viewModel.arrivalWindowStartTime = pt.Arrival_Window_Start_Time__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Arrival_Window_Start_Time__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Arrival_Window_Start_Time__c);

		
		//ACARSON Jun.25.2018 Setting viewModel variables based on what it states on the program term or parent program term
		List<Program_Fee__c> progFees = [SELECT Id, Name, Program_Term__c, Amount__c, Product__c, Product__r.Name FROM Program_Fee__c WHERE Program_Term__c =:pt.Id OR Program_Term__c =:ppt.Id];
		for(Program_Fee__c pf : progFees){
			if(pf.Name == 'Tuition')
			{
				viewModel.tuition = pf.Amount__c;
			}
			else if(pf.Name == 'Accommodation' || pf.Name == 'Housing Fee')
			{
				viewModel.baseHousing = pf.Amount__c;
			}
			else if(pf.Name == 'Non-Refundable Deposit')
			{
				viewmodel.deposit = pf.Amount__c;
			}

		}

		if((!pt.OOPEX__r.isEmpty() && pt.OOPEX__r.get(0).OOPEX_Approval_Status__c == 'Approved') || (!ppt.OOPEX__r.isEmpty() && ppt.OOPEX__r.get(0).OOPEX_Approval_Status__c == 'Approved'))
		{
			viewModel.airfare = pt.Airfare__c != null ? pt.Airfare__c : ppt.Airfare__c;
			viewmodel.startupCosts = pt.Startup_Costs__c != null ? pt.Startup_Costs__c : ppt.Startup_Costs__c;
			viewModel.meals = pt.Meals__c != null ? pt.Meals__c : ppt.Meals__c;
			// viewModel.visaUS = pt.Visa_United_States__c != null ? pt.Visa_United_States__c : ppt.Visa_United_States__c;
			// viewModel.visaAbroad = pt.Visa_Abroad__c != null ? pt.Visa_Abroad__c : ppt.Visa_Abroad__c;
			viewModel.visaTotal = pt.Visa_Cost__c != null ? pt.Visa_Cost__c : ppt.Visa_Cost__c;
			viewModel.booksAndSupplies = pt.Books_Supplies__c != null ? pt.Books_Supplies__c : ppt.Books_Supplies__c;
			viewModel.localTransport = pt.Local_Transportation__c != null ? pt.Local_Transportation__c : ppt.Local_Transportation__c;
			viewModel.miscellaneous = pt.Miscellaneous__c != null ? pt.Miscellaneous__c : ppt.Miscellaneous__c;
			viewModel.personalExpenses = pt.Personal_Expenses__c != null ? pt.Personal_Expenses__c : ppt.Personal_Expenses__c;
			viewModel.courseCharges = pt.Course_Related_Charges_Description__c != null ? pt.Course_Related_Charges_Description__c : ppt.Course_Related_Charges_Description__c;
		}

		
		//List<Program_Term_Housing_Option__c> suppList = new List<Program_Term_Housing_Option__c>();
		viewModel.suppHousing = [SELECT Id, Name, Program_Term__c, Supplemental_Housing_Price__c, Housing_Option__r.Name FROM Program_Term_Housing_Option__c WHERE Program_Term__c = :pt.Id OR Program_Term__c = :ppt.Id ORDER BY Housing_Option__r.Name];
		viewModel.displayHousingOptions = false;
		for(Program_Term_Housing_Option__c ptho : viewModel.suppHousing)
		{
			if(ptho.Supplemental_Housing_Price__c != null || ptho.Supplemental_Housing_Price__c > 0)
			{
				viewModel.displayHousingOptions = true;
			}
		}


		viewModel.totalBaseCosts = viewModel.tuition != null && viewmodel.baseHousing != null ? viewmodel.tuition + viewmodel.baseHousing : null;
		if(viewmodel.totalBaseCosts != null)
		{
			viewmodel.totalBaseCosts += viewModel.deposit != null ? viewmodel.deposit : 0;
		}
		/* viewModel.totalEstCosts = viewModel.airfare != null ? viewModel.airfare : 0;
		viewModel.totalEstCosts += viewmodel.startupCosts != null ? viewmodel.startupCosts : 0;
		viewModel.totalEstCosts += viewModel.meals != null ? viewModel.meals : 0;
		viewModel.totalEstCosts += viewModel.visaUS != null ? viewModel.visaUS : 0;
		viewModel.totalEstCosts += viewModel.visaAbroad != null ? viewModel.visaAbroad : 0;
		viewModel.totalEstCosts += viewModel.booksAndSupplies != null ? viewModel.booksAndSupplies : 0;
		viewModel.totalEstCosts += viewModel.localTransport != null ? viewModel.localTransport : 0;
		viewModel.totalEstCosts += viewModel.personalExpenses != null ? viewModel.personalExpenses : 0; */

		return viewModel;
	}

	/**
	* @description Returns the provided date if the dates on the program term are approved
	* param approvalStatus - The Date_Approval_Status__c value from the program term
	* param dateToReturn - The date to return if the program term dates are approved
	*/
	private static Date isApproved(String approvalStatus, Date dateToReturn)
	{
		if(approvalStatus == 'Approved')
		{
			return dateToReturn;
		}
		return null;
	}
	/**
	* @description Returns the provided string if the dates on the program term are approved
	* param approvalStatus - The Date_Approval_Status__c value from the program term
	* param stringToReturn - The string to return if the program term dates are approved
	*/
	private static String isApproved(String approvalStatus, String stringToReturn)
	{
		if(approvalStatus == 'Approved')
		{
			return stringToReturn;
		}
		return null;
	}
	/**
	* @description Returns the an instance of studentProfileViewModel
	* @return studentProfileViewModel - student profile information
	*/
	@RemoteAction
	public static studentProfileViewModel getProfileInfo()
	{
		studentProfileViewModel viewModel = new studentProfileViewModel();
		Contact studentContact = [SELECT MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, AccountId, Id FROM Contact WHERE Id =: chartRemoteMethods.getUserContactId()];
		viewModel.mailingStreet = studentContact.MailingStreet;
		viewModel.mailingCity = studentContact.MailingCity;
		viewModel.mailingState = studentContact.MailingState;
		viewModel.mailingZip = studentContact.MailingPostalCode;
		viewModel.mailingCountry = studentContact.MailingCountry;
		viewModel.otherStreet = studentContact.OtherStreet;
		viewModel.otherCity = studentContact.OtherCity;
		viewModel.otherState = studentContact.OtherState;
		viewModel.otherZip = studentContact.OtherPostalCode;
		viewModel.otherCountry = studentContact.OtherCountry;
		viewModel.billingStreet = studentContact.Account.BillingStreet;
		viewModel.billingCity = studentContact.Account.BillingCity;
		viewModel.billingState = studentContact.Account.BillingState;
		viewModel.billingZip = studentContact.Account.BillingPostalCode;
		viewModel.billingCountry = studentContact.Account.BillingCountry;

		viewModel.accountId = studentContact.AccountId;
		viewModel.contactId = studentContact.Id;

		return viewModel;
	}

	@RemoteAction
	public static chartJSRemotingResponse getCourses(String[] courseIds)
	{
		if(courseIds.isEmpty()) {
            return new chartJSRemotingResponse(new List<Course__c>());
        }
		return chartRemoteMethods.getCourses(courseIds, null);
	}

	@RemoteAction
	public static Boolean deleteCourseInterest(String courseRegId)
	{
		try {
			return database.delete(courseRegId).isSuccess();
		}
		catch (Exception e)
		{

		}

		return false;		
	}
	@RemoteAction
	public static studentAccountViewModel getAccountInfo()
	{
		studentAccountController c = new studentAccountController();
		return c.viewModel;
	}
	public static Boolean closeCompletionNotification(Id applicationId)
    {
        try
        {
            Application__c application = [SELECT Id, Completion_Notification_Received__c, Application_Items_Incomplete_Count__c FROM Application__c WHERE Id =: applicationId];
            if(application.Application_Items_Incomplete_Count__c < 1)            
            {
                application.Status__c = 'Ready To Submit';
                application.Completion_Notification_Received__c = true;

                Database.update(application);

                return true;
            }
        }
        catch(Exception e)
        {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return false;
    }
	@RemoteAction
	public static List<Host_Institution_Departement__c> getDepartments(String ProgramTermId, String ProgramOptionId)
	{
		Program__c p = [SELECT Id, Name, Host_Institution__r.Name FROM Program__c WHERE Id IN (SELECT Program__c FROM Program_Term__c WHERE Id =: ProgramTermId)].get(0);
		if(p.Host_Institution__r.Name == 'IFSA Worldwide')
		{
			return [SELECT Id, Name, Program__c, Program_Option__c, Program_Option__r.Name, Host_Institution__c FROM Host_Institution_Departement__c WHERE Host_Institution__c IN (SELECT Host_Institution__c FROM Program_Institution__c WHERE Program__c =: p.Id) ORDER BY Program_Option__c, Name];
		}
		else
		{
			return [SELECT Id, Name, Program__c, Program_Option__c, Program_Option__r.Name, Host_Institution__c FROM Host_Institution_Departement__c WHERE Host_Institution__c IN (SELECT Host_Institution__c FROM Program_Institution__c WHERE Program__c =: p.Id AND Host_Institution__r.Name != 'IFSA Worldwide' ) ORDER BY Program_Option__c, Name];
		}		
	}

	@RemoteAction
	public static List<Department_Application__c> getDepartmentApplications(String applicationId)
	{
		return [SELECT Id, Designation__c, Host_Institution_Departement__c, Host_Institution_Departement__r.Name, Host_Institution_Departement__r.Program__c, Host_Institution_Departement__r.Program_Option__c, Host_Institution_Departement__r.Program_Option__r.Name, Host_Institution_Departement__r.Host_Institution__c FROM Department_Application__c WHERE Application__c =: applicationId];
	}

	@RemoteAction
	public static Boolean deleteDepartmentApplication(String deptAppId)
	{
		Department_Application__c da = [SELECT Id, Application__c, Host_Institution_Departement__c FROM Department_Application__c WHERE Id =: deptAppId];
		List<Course_Registration__c> crs = [SELECT Id, Host_Institution_Departement__c FROM Course_Registration__c WHERE Application__c =: da.Application__c AND Host_Institution_Departement__c =: da.Host_Institution_Departement__c];
		for(Course_Registration__c cr: crs)
		{
			cr.Host_Institution_Departement__c = null;
		}

		database.update(crs);
		
		Database.DeleteResult dr = database.delete(deptAppId);
		return dr.isSuccess();
	}

	@RemoteAction
	public static Boolean saveDepartmentApplications(String jsonData)
	{
		system.debug(jsonData);
		List<Department_Application__c> data = (List<Department_Application__c>) JSON.deserialize(jsonData, List<Department_Application__c>.class);
		system.debug(data);
		
		Database.UpsertResult[] upResults = database.upsert(data);
		Boolean success = true;
		for(Database.UpsertResult result: upResults){
			if(!result.isSuccess())
			{
				success = false;
				break;
			}
		}

		return success;
	}
	@RemoteAction 
	public static studentRegisterViewModel getRegistrationViewModel()
	{
		//studentRegisterViewModel vm = 
		return new studentRegisterController().viewModel;
	}

	@RemoteAction
    public static List<Home_Institution__c> searchHomeInstitution(String SearchTerm) 
    {
        List<Home_Institution__c> schools = Database.query('Select Id, Name from Home_Institution__c where name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        return schools;
    }

	@RemoteAction
	public static Boolean saveRegistrationData(String jsonData, Boolean registrationComplete)
	{
		studentRegisterViewModel viewModel;
		if(jsonData == null)
		{
			return false;
		}
		system.debug(jsonData);
		try
		{
			viewModel = (studentRegisterViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('studentRegisterViewModel'));
		}
		catch(Exception e)
		{
			System.debug(LoggingLevel.WARN, e.getMessage());
			return false;
		}

		User studentUser = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];

		Contact studentContact = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Id = \'' + studentUser.ContactId + '\'').get(0);
		Account studentAccount = (Account) [SELECT Id, Name, c2g__CODAAccountTradingCurrency__c FROM Account WHERE Id =: studentContact.AccountId];
		Application__c activeApplication = studentBaseController.getActiveApplication(studentContact);
		studentContact.Active_Application__c = activeApplication.Id;
		
		List<Contact> guardianList = [SELECT Id, FirstName, LastName, Phone, Email FROM Contact WHERE Student__c =: studentContact.Id];
		List<sObject> toUpdate = new List<sObject>();
		Contact parent = guardianList.size() > 0 ? guardianList.get(0) : new Contact();
		System.debug(guardianList.size());

		studentContact.FirstName = viewModel.studentFirstName != null ? viewModel.studentFirstName.normalizeSpace() : null;
		studentContact.LastName = viewModel.studentLastName.normalizeSpace();
		//ACARSON Dec.05.2017 SW #5910 fixed issue of preferred name not autopopulating
		//studentContact.Preferred_Name__c = viewModel.PreferredName != null ? viewModel.PreferredName : studentContact.FirstName;
		studentContact.Preferred_Name__c = (!String.isBlank(viewModel.PreferredName)) ? viewModel.PreferredName : studentContact.FirstName;
		studentContact.Middle_Name__c = viewModel.MiddleName;
		studentContact.Suffix__c = viewModel.Suffix;
		studentContact.Email = viewModel.Email;
		studentContact.Personal_Email__c = viewModel.personalEmail;
		studentContact.Phone = viewModel.Phone;
		studentContact.Twitter_Handle__c = viewModel.TwitterHandle;
		//ACARSON
		//studentContact.Major__c = viewModel.Major;
		studentContact.First_Generation_PL__c = viewModel.FirstGeneration;
		studentContact.Sex__c = viewModel.Sex;
		studentContact.Citizenship_Details__c = viewModel.CitizenshipDetails;
		studentContact.Spoken_with_alumni__c = (!String.isBlank(viewModel.SpokenWithAlumni)) ? viewModel.SpokenWithAlumni : 'No';
		parent.Id = viewModel.GuardianId;
		parent.FirstName = viewModel.GuardianFirstName;
		parent.LastName = viewModel.GuardianLastName;
		parent.Email = viewModel.GuardianEmail;
		parent.Phone = viewModel.GuardianPhone;
		parent.Student__c = studentContact.Id;
		parent.Send_Marketing_Materials__c = true;
		parent.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Other'].Id;
		parent.OwnerId = studentContact.OwnerId;
		studentContact.Citizenship__c = viewModel.Citizenship;
		studentContact.Non_US_Citizenship__c = viewModel.NonUsCitizenship;
		studentContact.Grade_Level__c = viewModel.GradeLevel;
		studentContact.Degree__c = viewModel.Degree;
		studentContact.Multiple_Universities__c = viewModel.MultipleUniversities;
		studentContact.Birthdate = viewModel.Birthdate;
		studentContact.GPA__c = viewModel.GPA;
		//ACARSON
		studentContact.Major_New__c = viewModel.Major;
		studentContact.Major_Other__c = viewModel.OtherMajor;
		studentContact.Ethnicity__c = viewModel.Ethnicity;
		studentContact.Race__c = viewModel.Race;
		studentContact.FAFSA__c = viewModel.FAFSA;
		studentContact.Active_Duty_or_Veteran__c = viewModel.ActiveDutyVeteran;
		studentContact.Gender_Identity__c = viewModel.GenderIdentity;
		studentContact.Preferred_Pronouns_Other__c = viewModel.PreferredPronounsOther;
		studentContact.Classes_Required__c = (!String.isBlank(viewModel.ClassesReqd)) ? viewModel.ClassesReqd : 'No';
		studentContact.Division_of_Sport__c = viewModel.SportDivision;
		studentContact.LGBTQplus__c = viewModel.LGBTQplus;
		studentContact.Natl_Student_Success_Programs__c = viewModel.NatlStudentSuccess != null ? viewModel.NatlStudentSuccess.unescapeHtml4() : null;
		studentContact.Personal_Pronouns__c = viewModel.PreferredPronouns;
		studentContact.Student_Sport__c = viewModel.Sport;
		studentContact.Guardians_Not_Born_IN_US__c = viewModel.GuardiansNotUSBorn;
		studentContact.Second_Major__c = viewModel.SecondMajor;
		studentContact.Minor__c = viewModel.Minor;
		studentContact.Second_Minor__c = viewModel.SecondMinor;
		studentContact.Minor_Other__c = viewModel.MinorOther;
		studentContact.Working_Hours_per_Week__c = viewModel.WorkingHours;
		studentContact.Travel_Topics__c = viewModel.TravelTopics;
		studentContact.Travel_Concerns__c = viewModel.TravelConcerns;
		studentContact.Eligible_for_Pell_Grant__c = viewModel.PellGrant;
		studentContact.Gender_Identity_Other_2__c = viewModel.GenderIdentityOther;

		if(studentContact.FirstName + ' ' + studentContact.LastName != studentAccount.Name)
		{
			studentAccount.Name = studentContact.FirstName + ' ' + studentContact.LastName;
			toUpdate.add(studentAccount);
		}


		List<Home_Institution__c> schools = [SELECT Id FROM Home_Institution__c WHERE Name LIKE: viewModel.HomeInstitutionName];

		if(schools.size() > 0)
		{
			studentContact.Home_Institution__c = schools.get(0).Id;
			studentContact.Unlisted_School__c = null;
		}
		else
		{
			studentContact.Unlisted_School__c = viewModel.HomeInstitutionName;
			studentContact.Home_Institution__c = null;
		}

		if(!activeApplication.Is_Custom__c &&  registrationComplete || studentContact.Profile_Completed__c)
		{
			activeApplication.Status__c = activeApplication.Status__c == 'New' ? 'Registered' : activeApplication.Status__c;
			studentContact.Profile_Completed__c = true;
		}

		toUpdate.add(studentContact);			
		toUpdate.add(activeApplication);

		System.debug(logginglevel.WARN, parent.LastName);
		if(guardianList.size() > 0 && parent.Id != null)
		{
			toUpdate.add(parent);
		}
		else if(parent.LastName != null && parent.Id == null)
		{
			System.debug(LoggingLevel.WARN, 'Inserting parent');
			Database.insert(parent);
		}
		system.debug(toUpdate.size());
		try
		{
			system.debug(toUpdate.get(0).Id);
			system.debug(toUpdate.get(1).Id);
			system.debug(toUpdate.get(2).Id);
			system.debug(toUpdate.get(3));
		} catch (Exception e) {

		}
		Boolean isSuccess = Database.update(toUpdate).get(0).isSuccess();
		// this needs commented out to not cause duplicate records
		// if(activeApplication.Status__c == 'Program Selected' && registrationComplete)
		// {
		// 	applicationService.createPaWelcomeTaskAsync(new Set<Id>{activeApplication.Id});
		// }
		return isSuccess;
	}
	@RemoteAction 
	public static studentSelectViewModel getSelectViewModel()
	{
		studentSelectViewModel vm = new studentSelectController().viewModel;
		system.debug(vm);
		return vm;
	}
	/**
     * @description Searches for a list of valid terms based on valid program terms by country.
     * @return List<String>
     */
    @RemoteAction
    public static List<String> searchByCountry(String countryName)
    {   
        /*User studentUser = [SELECT Id, ContactId FROM User WHERE id =: userInfo.getUserId()];                
        Set<Id> duplicateTermIds = new Set<Id>();
        try 
        {
            LinkedList divertedTerms = new LinkedList();
            for(Application__c app : [SELECT Id, Program_Term__r.Term__c FROM Application__c WHERE Status__c = 'Diverted' AND Applicant__c =: studentUser.ContactId])
            {            
                divertedTerms.addToList(null, null, app.Program_Term__r.Term__c);
            }
            
            LinkedListNode compared = divertedTerms.head;
            LinkedListNode node = divertedTerms.head;
            while (node.getNext() != null)
            {            
                while (compared.getNext() != null)
                {
                    if(node.getIdValue() == compared.getIdValue() && !duplicateTermIds.contains(node.getIdValue()))
                    {
                        duplicateTermIds.add(node.getIdValue());
                    }
                    compared = compared.getNext();
                }
                node = node.getNext();
            }
        } 
        catch(NullPointerException e) 
        {
            system.debug(e);
        }
        List<Id> poRecordTypes = new List<Id>();
        poRecordTypes.add(Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option with Dates').getRecordTypeId());
        poRecordTypes.add(Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option without Dates').getRecordTypeId());

        Id standardPT = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();

		Date todayMinus7 = Date.today().addDays(-7);
        List<Program_Term__c> programTerms = [SELECT Id, Term__c, Program__r.Active__c, RecordTypeId, (SELECT Id FROM Program_Terms__r WHERE Application_Deadline__c >=: todayMinus7 OR Application_Deadline__c = null) FROM Program_Term__c WHERE Program__r.Host_Institution__r.Country__r.Name =: countryName AND (NOT Term__c IN: duplicateTermIds) AND ((Application_Deadline__c >=: todayMinus7 OR Application_Deadline__c = null) AND Program__r.Active__c = true)];
        // if(!duplicateTermIds.isEmpty())
        // {
        //     programTerms = [SELECT Id, Term__c, Program__r.Active__c, RecordTypeId, (SELECT Id FROM Program_Terms__r WHERE Application_Deadline__c >=: todayMinus7 OR Application_Deadline__c = null) FROM Program_Term__c WHERE Program__r.Host_Institution__r.Country__r.Name =: countryName AND (NOT Term__c IN: duplicateTermIds) AND ((Application_Deadline__c >=: todayMinus7 OR Application_Deadline__c = null) AND Program__r.Active__c = true)];
        // }
        // else
        // {
        //     programTerms = [SELECT Id, Term__c, Program__r.Active__c, RecordTypeId, (SELECT Id FROM Program_Terms__r WHERE Application_Deadline__c >=: todayMinus7 OR Application_Deadline__c = null) FROM Program_Term__c WHERE Program__r.Host_Institution__r.Country__r.Name =: countryName AND ((Application_Deadline__c >=: todayMinus7 OR Application_Deadline__c = null) AND Program__r.Active__c = true)];
		// }
		
        List<Id> progTermIds = new List<Id>();
        for(Program_Term__c progTerm : programTerms)
        {           
            //if(progTerm.Program__r.Active__c){
            if(progTerm.Program__r.Active__c && (progTerm.RecordTypeId == standardPT || progTerm.Program_Terms__r.size() > 0))
            {
                progTermIds.add(progTerm.Term__c);
            }
        }
        List<Term__c> terms = [SELECT Id, Name, Display_Name__c FROM Term__c WHERE Id IN: progTermIds AND Year__c >=: Date.today().year() ORDER By Name];

        List<String> termNames = new List<String>();
        for(Term__c term: terms)
        {
            termNames.add(term.Display_Name__c);
        }

		return termNames;
		*/
		
		List<Term__c> terms = programTermService.getTermsForProgramSelector([SELECT Id FROM Country__c WHERE Name =: countryName].get(0).Id);

        List<String> termNames = new List<String>();
        for(Term__c term: terms)
        {
            termNames.add(term.Display_Name__c);
        }

		return termNames;
    }

    /**
     * @description Searches for a list of valid program terms based on country and term.
     * @return List<String>
     */
    @RemoteAction
    public static List<Program_Term__c> searchByTerm(String country, String term)
    {
		User studentUser = [SELECT Id, ContactId, Contact.Home_Institution__r.Name FROM User WHERE id =: userInfo.getUserId()];       
		Id selectedCountry = [SELECT Id FROM Country__c WHERE Name =: country].get(0).Id;
		Id selectedSemester = [SELECT Id FROM Term__c WHERE Display_Name__c =: term].get(0).Id;
        List<Id> poRecordTypes = new List<Id>();
        poRecordTypes.add(Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option with Dates').getRecordTypeId());
        poRecordTypes.add(Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option without Dates').getRecordTypeId());
        List<Application__c> apps = [SELECT Program_Term__c, Program_Term__r.Parent_Program_Term__c, Program_Term__r.Name FROM Application__c WHERE Applicant__c =: studentUser.ContactId AND (NOT Program_Term__c = null)];
        Boolean oxfordOrCambridge = false;
        List<ID> hiddenPTIds = new List<ID>();
        for(Application__c app : apps)
        {
            hiddenPTIds.add(app.Program_Term__c);
            //ACARSON
            if(app.Program_Term__r.Parent_Program_Term__c != null){
                System.debug('### : ' + app.Program_Term__r.Parent_Program_Term__c);
                hiddenPTIds.add(app.Program_Term__r.Parent_Program_Term__c);
            }

            system.debug(app.Program_Term__r.Name);
            oxfordOrCambridge = app.Program_Term__r.Name.contains('Oxford') ? true : oxfordOrCambridge;
            oxfordOrCambridge = app.Program_Term__r.Name.contains('Cambridge') ? true : oxfordOrCambridge;
        }
        if(oxfordOrCambridge)
        {
            List<Program_Term__c> oxfordAndCambridge = [SELECT Id, Name FROM Program_Term__c WHERE Term__r.Display_Name__c =: term AND(Name LIKE '%Oxford%' OR Name LIKE '%Cambridge%') AND (NOT RecordTypeId IN: poRecordTypes)];
            for(Program_Term__c pt : oxfordAndCambridge)
            {
                hiddenPTIds.add(pt.Id);
            }
        }
        
        
        return programTermService.getProgramTermsForProgramSelector(selectedCountry, selectedSemester, studentUser.Contact.Home_Institution__r.Name, hiddenPTIds);
    }

    /**
     * @description Obtains data for a particular program.
     * @return Map<String, String>
     */
    @RemoteAction
    public static Map<String, String> getProgramTermInfo(String programTermId)
    {
        // String displayName = programTermName.unescapeHtml4();
        // system.debug(displayName);
        Program_Term__c programTerm = [SELECT Id, Display_Name__c, Description__c, Description_Long__c, Program__r.Host_Institution__r.Name, Program__r.Host_Institution__r.Picture_URL__c, Program__r.Host_Institution__r.Description__c, Program__r.Host_Institution__r.Country__r.Name, Apply_URL__c FROM Program_Term__c WHERE Id =: programTermId];
        List<Program_Term__c> programOptions = [SELECT ID FROM Program_Term__c WHERE Parent_Program_Term__c =: programTermId];

        Map<String, String> programTermData = new Map<String, String>();
        programTermData.put('programTermId', programTerm.Id);
        programTermData.put('displayName', programTerm.Display_Name__c);
        programTermData.put('description', programTerm.Description_Long__c == null ? programTerm.Description__c : programTerm.Description_Long__c);
        programTermData.put('hostInstitutionName', programTerm.Program__r.Host_Institution__r.Name);
        programTermData.put('pictureUrl', programTerm.Program__r.Host_Institution__r.Picture_URL__c);
        programTermData.put('hostInstitutionDescription', programTerm.Program__r.Host_Institution__r.Description__c);
        programTermData.put('country', programTerm.Program__r.Host_Institution__r.Country__r.Name);
        programTermData.put('noApply', programTerm.Apply_URL__c);        
        if (programOptions.size() > 0)
        {
            programTermData.put('hasOptions', 'true');          
        }
        else
        {
            programTermData.put('hasOptions', 'false');
        }

        return programTermData;
    }
    
    /**
     * @description Obtains program option data
     * @return List<Program_Term__c>
     */
    @RemoteAction
    public static List<Program_Term__c> getProgramOptions(String programTermId)
    {
        return [SELECT Id, Name, Program_Option_Name__c, Description__c, Description_Long__c FROM Program_Term__c WHERE Parent_Program_Term__r.Id =: programTermId];     
	}
	
	/**
     * @description Select a program for a student. The program-term field on the application is directed to this program-term, the application requirements are populated, and their data inserted into the application.
     * @return Boolean
     */
    @RemoteAction
    public static Boolean selectProgramTerm(String programTermId)
    {
		return createApp(programTermId, false);
	}
    /**
     * @description Select a program for a student. The program-term field on the application is directed to this program-term, the application requirements are populated, and their data inserted into the application.
     * @return Boolean
     */
    @RemoteAction
    public static Boolean createApp(String programTermId, Boolean startNewApp)
    {
        //String displayName = programTermName.unescapeHtml4();
        User studentUser = [SELECT Id, ContactId FROM User WHERE id =: userInfo.getUserId()];
        System.debug(LoggingLevel.WARN, studentUser.Id);
        Contact studentContact = [SELECT Id, Name, Preferred_Name__c, LastName, Active_Application__c, Compare_Name_to_Active_Application__c, Citizenship__c, Non_US_Citizenship__c, Home_Institution__r.Account__c FROM Contact WHERE Id =: studentUser.ContactId];
		Application__c activeApplication;
		if(startNewApp)
		{
			activeApplication = new Application__c(Applicant__c = studentContact.Id, Designation__c = 'Secondary');
		}
        else if(studentContact.Active_Application__c != null)
        {
            activeApplication = [SELECT Id, Applicant__c, Previous_Application__c FROM Application__c WHERE Id =: studentContact.Active_Application__c];
        }
        else
        {
            activeApplication = studentBaseController.getActiveApplication(studentContact);
            studentContact.Active_Application__c = activeApplication.Id;
        }
        Program_Term__c programTerm = [SELECT Id, Name, OwnerId, Program__c, Term__r.Section__c FROM Program_Term__c WHERE Id =: programTermId].get(0);
        activeApplication.Program_Term__c = programTerm.Id;
        activeApplication.Program_Option__c = null;
		activeApplication.Status__c = 'Program Selected';
		activeApplication.Source__c = 'Student Portal Select';
		activeApplication.Name = String.format('{0} {1} {2}', new List<Object>{studentContact.Preferred_Name__c, studentContact.LastName, programTerm.Name});
        activeApplication.OwnerId = programTerm.OwnerId;        
        Database.UpsertResult result = Database.upsert(activeApplication);

        // Generate Task for PA if student selects program that isn't authorized by their home institution
        if(result.isSuccess())
        {
			applicationService.checkProgramAuthorizations(new List<Application__c>{activeApplication});
			studentContact.Active_Application__c = activeApplication.Id;
        }
        try
        {
            studentContact.OwnerId = setContactOwner(studentContact).OwnerId;
        }
        catch (ListException e)
        {
            System.debug(LoggingLevel.WARN, 'Student does not have a primary application');
            studentContact.OwnerId = activeApplication.OwnerId;
        }
        
                
        if(activeApplication.Previous_Application__c != null)
        {
            portalRemotingMethods.cloneApplicationItems(activeApplication.Previous_Application__c, activeApplication);
        }
        else
        {
            applicationService.createPaWelcomeTask(new List<Application__c>{activeApplication});
        }
        //ACARSON Jul.09.2018
        //If the student is a non-u.s. citizen create a task for PA to review student citizenship
        if(studentContact.Citizenship__c == 'Non-U.S. Citizen'){
            Task t = new Task(WhoId = studentContact.Id, WhatId = activeApplication.Id, Subject='Review Student Citizenship', ActivityDate = Date.today().addDays(2), Description='Review Student Citizenship: ' + studentContact.Non_US_Citizenship__c);
            t.OwnerId = activeApplication.OwnerId;
            insert t;
        }
        Database.update(studentContact);
                

        return result.isSuccess();
    }
    /**
     * @description Select a program with program option for a student. The program-term field on the application is directed to this program-term, the application requirements are populated, and their data inserted into the application.
     * @return Boolean
     */
    /*
    @RemoteAction
    public static Boolean selectProgramOption(String programOptionName, String programTermName)
    {
        String displayName = programOptionName.unescapeHtml4();
        String ptDisplayName = programTermName.unescapeHtml4();
        User studentUser = [SELECT Id, ContactId FROM User WHERE id =: userInfo.getUserId()];
        System.debug(LoggingLevel.WARN, studentUser.Id);        
        Contact studentContact = [SELECT Id, Active_Application__c, Compare_Name_to_Active_Application__c FROM Contact WHERE Id =: studentUser.ContactId];
        Application__c activeApplication;
        if(studentContact.Active_Application__c != null)
        {
            activeApplication = [SELECT Id FROM Application__c WHERE Id =: studentContact.Active_Application__c];
        }
        else
        {
            activeApplication = studentBaseController.getActiveApplication(studentContact);
            studentContact.Active_Application__c = activeApplication.Id;
        }
        Program_Option__c programOption = [SELECT Id, Program_Term__c, Program_Advisor__c FROM Program_Option__c WHERE Name =: displayName AND Program_Term__r.Display_Name__c =: ptDisplayName];
        //Program_Term__c programTerm = [SELECT Id, OwnerId FROM Program_Term__c WHERE Id =: programOption.Program_Term__c];

        activeApplication.Program_Option__c = programOption.Id;
        activeApplication.Program_Term__c = programOption.Program_Term__c;
        activeApplication.Status__c = 'Program Selected';
        activeApplication.OwnerId = programOption.Program_Advisor__c;
        Database.SaveResult result = Database.update(activeApplication);
        studentContact.OwnerId = setContactOwner(studentContact).OwnerId;        
        
        if(activeApplication.Previous_Application__c != null)
        {
            portalRemotingMethods.cloneApplicationItems(activeApplication.Previous_Application__c, activeApplication);
        }
        else
        {
            createPaWelcomeTask(activeApplication);
        }
        Database.update(studentContact);        

        return result.isSuccess();
    }
    */
    /**
     * @description [DEPRECIATED - MOVED TO APPLICATION SERVICE] Assigns a "Welcome Task" task to the application's owner
     */
	/*
    private static void createPaWelcomeTask(Application__c application)
    {
        //Create task for PA to review            
        Task welcomeCall = new Task(WhoId = application.Applicant__c, WhatId = application.Id, Subject = 'Welcome Email', ActivityDate = Date.today().addDays(2));
        welcomeCall.OwnerId = application.OwnerId;

        Contact student = [SELECT Name, Id, Classes_Required__c, Travel_Concerns__c, Travel_Topics__c FROM Contact WHERE Active_Application__c =: application.Id];
        welcomeCall.Description = '';
        if(student.Classes_Required__c == 'Yes')
        {
            welcomeCall.Description += (student.Name + ' requires specific classes to be able to study abroad. \n\n');
        }
        if(!String.isBlank(student.Travel_Concerns__c)){
            welcomeCall.Description += (student.Name + ' has the following concerns about traveling:\n' + student.Travel_Concerns__c +'\n\n');
        }
        if(!String.isBlank(student.Travel_Topics__c)){
            List<String> topics = student.Travel_Topics__c.split(';');
            welcomeCall.Description += (student.Name +' is interested in recieving information on the following topics: \n');
            for(String topic : topics){
                welcomeCall.Description += (topic + '\n');
            }
        }

        database.insert(welcomeCall);            
	}
	*/
    private static Application__c setContactOwner(Contact studentContact)
    {
        //Find the student's oldest application with primary designation
        
        Application__c oldestPrimaryApp = [SELECT Id, OwnerId FROM Application__c WHERE Applicant__c =: studentContact.Id AND Designation__c = 'Primary' ORDER BY CreatedDate DESC LIMIT 1].get(0);     
        
        return oldestPrimaryApp;
    }
    private static List<Id> getRestrictedProgramTermIds(Id contactId, String country, String term)
    {
        List<Id> hiddenPTIds = new List<Id>();
        Contact studentContact = [SELECT Id, Name, Home_Institution__c FROM Contact WHERE id =: contactId];
        Boolean hasRestrictedProgams = [SELECT Id FROM Restricted_Program__c WHERE Home_Institution__c =: studentContact.Home_Institution__c AND Program_Country__c =: country].size() > 0;
        if(hasRestrictedProgams)
        {   
            List<Restricted_Program__c> restrictedPrograms = [SELECT Id, Name, Home_Institution__c, Program__c, Program_Country__c, Allows_Other_Programs_in_Country__c FROM Restricted_Program__c WHERE Home_Institution__c =: studentContact.Home_Institution__c AND Program_Country__c =: country];
            Boolean allowsOtherPrograms = false;
            List<Id> AllowedPrograms = new List<Id>();
            for(Restricted_Program__c restrictedProgram: restrictedPrograms)
            {
                if(restrictedProgram.Allows_Other_Programs_in_Country__c || allowsOtherPrograms)
                {
                    allowsOtherPrograms = true;
                }
                AllowedPrograms.add(restrictedProgram.Program__c);              
            }
            if(!allowsOtherPrograms)
            {
                
                List<Program_Term__c> programsInCountry = [SELECT Id, Name, Program__c FROM Program_Term__c WHERE Term__r.Display_Name__c =: term AND Program__r.Host_Institution__r.Country__r.Name =: country AND (NOT Program__c IN: AllowedPrograms)];
                for(Program_Term__c pt : programsInCountry)
                {
                    for(Restricted_Program__c restrictedProgram: restrictedPrograms)
                    {
                        if(restrictedProgram.Program__c != pt.Program__c)
                        {
                            hiddenPTIds.add(pt.Id);
                        }
                    }
                }               
            }
            else
            {
                restrictedPrograms = [SELECT Id, Name, Home_Institution__c, Program__c, Program_Country__c, Allows_Other_Programs_in_Country__c FROM Restricted_Program__c WHERE Program_Country__c =: country AND Home_Institution__c !=: studentContact.Home_Institution__c];
                List<Id> restrictedIdList = new List<Id>();
                for(Restricted_Program__c restrictedProgram: restrictedPrograms)
                {
                    restrictedIdList.add(restrictedProgram.Program__c);
                }
                List<Program_Term__c> programsInCountry = [SELECT Id, Name, Program__c FROM Program_Term__c WHERE Term__r.Display_Name__c =: term AND Program__c IN: restrictedIdList];
                for(Program_Term__c pt : programsInCountry)
                {
                    hiddenPTIds.add(pt.Id);
                } 
            }   
        }
        else
        {
            List<Restricted_Program__c> restrictedPrograms = [SELECT Id, Name, Home_Institution__c, Program__c, Program_Country__c, Allows_Other_Programs_in_Country__c FROM Restricted_Program__c WHERE Program_Country__c =: country];
            List<Id> restrictedIdList = new List<Id>();
            for(Restricted_Program__c restrictedProgram: restrictedPrograms)
            {
                restrictedIdList.add(restrictedProgram.Program__c);
            }
            List<Program_Term__c> programsInCountry = [SELECT Id, Name, Program__c FROM Program_Term__c WHERE Term__r.Display_Name__c =: term AND Program__c IN: restrictedIdList];
            for(Program_Term__c pt : programsInCountry)
            {
                hiddenPTIds.add(pt.Id);
            } 
        }
        return hiddenPTIds;
    }
	@RemoteAction
	public static Object populateApplicationItems(String appId)
	{
		try
		{
			Application__c app = [SELECT Id, Status__c, Program_Term__c FROM Application__c WHERE Id =: appId];
			if(app.Program_Term__c != null){
				app.Status__c = 'Program Selected';
				database.update(app);
			}
			else{
				return true;
			}
				
		} 
		catch (Exception e) {
			return e.getMessage();	
		}
		
		try
		{
			new ifsaApplicationWrapper(appId).populateApplicationItems();
			return true;
		}
		catch (Exception e) {
			return e.getMessage();
		}
	}
	@RemoteAction
	public static String checkForNewApplicationReqs(String appId)
	{
		// Get data
		Application__c app = [SELECT Id, Program_Term__c, Program_Term__r.Parent_Program_Term__c, (SELECT Id, Name, Application_Requirement__c FROM Application_Items__r WHERE Name != 'Scholarship') FROM Application__c WHERE Id =: appId];
		List<Id> ptIds = new List<Id>{app.Program_Term__c};
		if(app.Program_Term__r.Parent_Program_Term__c != null)
		{
			ptIds.add(app.Program_Term__r.Parent_Program_Term__c);
		}
		List<Application_Requirement__c> appReqs = apexQueryUtility.selectAllFrom('Application_Requirement__c', 'RecordType.DeveloperName', 'Program_Term__c IN ' + apexQueryUtility.buildInClause(ptIds));
		Map<Id, Application_Item__c> appReqIdAppItemMap = new Map<Id, Application_Item__c>();
		List<Application_Requirement__c> appReqsToMake = new List<Application_Requirement__c>();
		for(Application_Item__c appItem: app.Application_Items__r)
		{
			appReqIdAppItemMap.put(appItem.Application_Requirement__c, appItem);
		}
		// Check for missing app items
		for(Application_Requirement__c appReq: appReqs)
		{
			if(!appReqIdAppItemMap.containsKey(appReq.Id))
			{
				appReqsToMake.add(appReq);
			}
		}
		// If no missing app items, return true
		if(appReqsToMake.isEmpty())
		{
			return 'NONE_MISSING';
		}
		// If app items are missing, create app items from app reqs
		appReqsToMake.sort();
		List<Application_Item__c> applicationItems = new List<Application_Item__c>();
		List<String> appReqRecordTypeNames = new List<String>();
		for(Application_Requirement__c req: appReqsToMake)
		{
			appReqRecordTypeNames.add(req.RecordType.DeveloperName);					
		}
		system.debug(appReqRecordTypeNames);
		List<RecordType> appItemRecordTypes = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Application_Item__c' AND DeveloperName IN: appReqRecordTypeNames];
		Map<String, RecordType> appReqMap = new Map<String, RecordType>();
		for(RecordType rt: appItemRecordTypes)
		{
			appReqMap.put(rt.DeveloperName, rt);
			system.debug(rt.DeveloperName);
		}
		for(Application_Requirement__c requirement : appReqsToMake)
		{
			system.debug(requirement.RecordType.DeveloperName);
			system.debug(appReqMap.get(requirement.RecordType.DeveloperName));
			applicationItems.add(ifsaApplicationWrapper.AppReqToAppItem(requirement, app, appReqMap.get(requirement.RecordType.DeveloperName).Id));
		}
		try 
		{
			Database.insert(applicationItems);
			return 'MISSING_BUT_CREATED';
		}
		catch (Exception e) 
		{
			System.debug(e.getMessage());
			throw e;
		}
	}
}