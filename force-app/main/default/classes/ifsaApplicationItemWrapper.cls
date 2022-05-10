/**
 * Wrapper class for the application item sObject.
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class ifsaApplicationItemWrapper
{
	/**
	 * Application Item sObject.
	 */
	private Application_Item__c appItem {get;set;}

	/**
	 * Constructor. Takes the Id and propagates the application item.
	 * @param appItemId The Id of the application Item
	 */
	public ifsaApplicationItemWrapper(Id appItemId)
	{
		this.appItem = (Application_Item__c) apexQueryUtility.selectAllFrom('Application_Item__c', 'Application__r.Applicant__c, Application__r.Program_Term__r.Program__r.Language_Of_Instruction__c, Application__r.Program_Term__r.Arrival_Plan_Type__c, RecordType.DeveloperName' , 'Id = \'' + appItemId + '\'').get(0);
	}

	/**
	 * Constructor. Takes the sObject and assigns it.
	 * @param appItemId The application item sObject.
	 */
	public ifsaApplicationItemWrapper(Application_Item__c anAppItem)
	{
		this.appItem = anAppItem;
	}

	/**
	 * Commits the sObject changes to the database.
	 * @return Boolean indicating if the items were saved.
	 */
	public Boolean save()
	{
		List<Database.SaveResult> results = Database.update(new List<sObject>{this.appItem});

		Boolean isSaved = true;
		for(Database.SaveResult result : results)
		{
			if(!result.isSuccess())
			{
				isSaved = false;
				for(Database.Error error : result.getErrors())
				{
					apexErrorUtility.debug(LoggingLevel.ERROR, error.getMessage());
				}
			}
		}

		return isSaved;
	}

	/**
	 * commits the information in the view model to the database.
	 * @param viewModel The information to be saved
	 * @return Boolean indicating whether the save was good or not
	 */
	public Boolean saveInformation(studentApplyItemDetailsViewModel viewModel)
	{
		this.appItem.Academic_Probation__c = viewModel.academicProbation;
	    this.appItem.Academic_Probation_Explanation__c = viewModel.academicProbationExplanation;
	    this.appItem.Allergic_To__c = viewModel.allergicTo;
	    this.appItem.Approval_to_Study__c = viewModel.approvalToStudy;
	    this.appItem.Approval_to_Study_Explanation__c = viewModel.approvalToStudyExplanation;
	    this.appItem.Prefers_Catered__c = viewModel.catered == true;
	    this.appItem.C_C_Participation__c = viewModel.ccParticipation;
	    this.appItem.CE_Aural_Comprehension__c = viewModel.ceAuralComprehension;
	    this.appItem.CE_Reading__c = viewModel.ceReading;
	    this.appItem.CE_Speaking__c = viewModel.ceSpeaking;
	    this.appItem.CE_Writing__c = viewModel.ceWriting;
	    this.appItem.Commercial_Teaching_Rosetta_Stone_etc__c = viewModel.commercialTeachingRosettaStoneEtc == true;
	    this.appItem.Community_Courses__c = viewModel.communityCourses == true;
	    this.appItem.Content__c = viewModel.content;
	    //this.appItem.Content_Link__c = viewModel.contentLink;
	    this.appItem.Current_Treatment__c = viewModel.currentTreatment == true;
	    this.appItem.Current_Treatment_Description__c = viewModel.currentTreatmentDescription;
	    this.appItem.Dietary_Restrictions__c = viewModel.dietaryRestrictions;
	    this.appItem.Directions__c = viewModel.directions;
	    this.appItem.Disciplinary_Action_Explanation__c = viewModel.disciplinaryActionExplanation;
	    this.appItem.Discipline__c = viewModel.discipline;
	    this.appItem.Display_Catered_Option__c = viewModel.displaycatered == true;
	    this.appItem.Display_Dietary_Restrictions__c = viewModel.displaydietaryrestrictions == true;
	    this.appItem.Display_Food_Allergies_Option__c = viewModel.displayfoodallergies == true;
	    this.appItem.Display_Gluten_Free_Option__c = viewModel.displayglutenfree == true;
	    this.appItem.Display_Halal_Option__c = viewModel.displayHalal == true;
	    this.appItem.Display_Kosher_Option__c = viewModel.displaykosher == true;
	    this.appItem.Display_Lactose_Intolerant_Option__c = viewModel.displaylactoseintolerant == true;
	    this.appItem.Display_NonSmoking_Option__c = viewModel.displaynonsmoking == true;
	    this.appItem.Display_Off_Campus_Option__c = viewModel.displayoffcampus == true;
	    this.appItem.Display_On_Campus_Option__c = viewModel.displayoncampus == true;
	    this.appItem.Display_Other__c = viewModel.displayother == true;
	    this.appItem.Display_Private_Bathroom_Option__c = viewModel.displayprivatebathroom == true;
	    this.appItem.Display_Religious_Accomodations__c = viewModel.displayReligiousAccomodations == true;
	    this.appItem.Display_Roommate_Requests__c = viewModel.displayroommaterequests == true;
	    this.appItem.Display_Self_Catered_Option__c = viewModel.displayselfcatered == true;
	    this.appItem.Display_Single_Gender_Option__c = viewModel.displaysinglegender == true;
	    this.appItem.Display_Single_Room_Option__c = viewModel.displaysingleroom == true;
	    this.appItem.Display_Smoking_Option__c = viewModel.displaysmoking == true;
	    this.appItem.Display_Vegan_Option__c = viewModel.displayVegan == true;
	    this.appItem.Display_Vegetarian_Option__c = viewModel.displayvegetarian == true;
	    this.appItem.Emergency_Treatment__c = viewModel.emergencyTreatment;
	    this.appItem.Epi_Pen__c = viewModel.epiPen == true;
	    this.appItem.Evaluator_Email__c = viewModel.evaluatorEmail;
	    this.appItem.Evaluator_Name__c = viewModel.evaluatorName;
	    this.appItem.Food_Allergies__c = viewModel.foodAllergies == true;
	    this.appItem.Prefers_Food_Allergies__c = viewModel.foodAllergies == true;
	    this.appItem.Food_Allergy_Arrangement_Description__c = viewModel.foodAllergyArrangementDescription;
	    this.appItem.Food_Allergy_Special_Arrangements__c = viewModel.foodAllergySpecialArrangments == true;
	    this.appItem.Prefers_Gluten_Free__c = viewModel.glutenFree == true;
	    this.appItem.Good_Standing__c = viewModel.goodStanding;
	    this.appItem.Good_Standing_Explanation__c = viewModel.goodStandingExplanation;
	    this.appItem.Prefers_Halal__c = viewModel.halal == true;
	    this.appItem.H_Aural_Comprehension__c = viewModel.hAuralComprehension;
	    this.appItem.Heritage_Speaker__c = viewModel.heritageSpeaker == true;
	    this.appItem.High_School_Courses__c = viewModel.highSchoolCourses == true;
	    this.appItem.Housing_Option__c = viewModel.housingOption != null ? [SELECT Id FROM Housing_Option__c WHERE Name =: viewModel.housingOption].Id : null;
	    this.appItem.Housing_Restrictions__c = viewModel.housingRestrictions == true;
	    this.appItem.Housing_Restrictions_Description__c = viewModel.housingRestrictionsDescription;
	    this.appItem.H_Reading__c = viewModel.hReading;
	    this.appItem.H_Speaking__c = viewModel.hSpeaking;
	    this.appItem.H_Writing__c = viewModel.hWriting;
	    this.appItem.Prefers_Kosher__c = viewModel.kosher == true;
	    this.appItem.Prefers_Lactose_Intolerant__c = viewModel.lactoseIntolerant == true;
	    this.appItem.Learning_Disability__c = viewModel.learningDisability == true;
	    this.appItem.Learning_Disability_Description__c = viewModel.learningDisabilityDescription;
	    this.appItem.Medical_Dietary_Restriction__c = viewModel.medicalDietaryRestriction == true;
	    this.appItem.Medical_Dietary_Restriction_Description__c = viewModel.medicalDietaryRestrictionDescription;
	    this.appItem.Medical_Psych_Conditions__c = viewModel.medicalPsychConditions == true;
	    this.appItem.Medical_Psych_Conditions_Explanation__c = viewModel.medicalPsychConditionsExplanation;
	    this.appItem.Medical_Psych_Conditions_Treatment__c = viewModel.medicalPsychConditionsTreatment == true;
	    this.appItem.Medication_Allergies__c = viewModel.medicationAllergies == true;
	    this.appItem.Medication_Allergies_Description__c = viewModel.medicationAllergiesDescription;
	    this.appItem.MSA_Aural_Comprehension__c = viewModel.msaAuralComprehension;
	    this.appItem.MSA_Reading__c = viewModel.msaReading;
	    this.appItem.MSA_Speaking__c = viewModel.msaSpeaking;
	    this.appItem.MSA_Writing__c = viewModel.msaWriting;
	    this.appItem.Prefers_Non_Smoking__c = viewModel.nonSmoking == true;
	    this.appItem.Prefers_Off_Campus__c = viewModel.offCampus == true;
	    this.appItem.Prefers_On_Campus__c = viewModel.onCampus == true;
	    this.appItem.Ongoing_Medical_Attention__c = viewModel.ongoingMedicalAttention == true;
	    this.appItem.Ongoing_Medical_Attention_Description__c = viewModel.ongoingMedicalAttentionDescription;
	    this.appItem.Prefers_Other__c = viewModel.other == true;
	    this.appItem.Other_Medical_Data__c = viewModel.otherMedicalData == true;
	    this.appItem.Other_Medical_Data_Details__c = viewModel.otherMedicalDataDescription;
	    this.appItem.P_Aural_Comprehension__c = viewModel.pAuralComprehension;
	    this.appItem.Phase__c = viewModel.phase;
	    this.appItem.Phys_Activity_Restrictions_Description__c = viewModel.physActivityRestrictionsDescription;
	    this.appItem.Physical_Activity_Restrictions__c = viewModel.physicalActivityRestrictions == true;
	    this.appItem.P_Reading__c = viewModel.pReading;
	    this.appItem.Prefers_Private_Bathroom__c = viewModel.privateBathroom == true;
	    this.appItem.P_Speaking__c = viewModel.pSpeaking;
	    this.appItem.P_Writing__c = viewModel.pWriting;
	    this.appItem.Regularly_Speak__c = viewModel.regularlySpeak;
	    this.appItem.Religious_Accomodations__c = viewModel.religiousAccomodations;
	    this.appItem.Roommate_Requests__c = viewModel.roommateRequests;
	    this.appItem.Prefers_Self_Catered__c = viewModel.selfCatered == true;
	    this.appItem.Prefers_Single_Gender__c = viewModel.singleGender == true;
	    this.appItem.Prefers_Single_Room__c = viewModel.singleRoom == true;
	    this.appItem.Prefers_Smoking__c = viewModel.smoking == true;
	    this.appItem.Speaks_Arabic__c = viewModel.speaksArabic == true;
	    this.appItem.Speaks_Colloquial_Egyptian__c = viewModel.speaksColloquialEgyptian == true;
	    this.appItem.Speaks_Hebrew__c = viewModel.speaksHebrew == true;
	    this.appItem.Speaks_Palestinian__c = viewModel.speaksPalestinian == true;
	    this.appItem.Status__c = viewModel.status;
	    this.appItem.Text_to_Sign__c = viewModel.textToSign;
	    this.appItem.Typical_Reaction__c = viewModel.typicalReaction;
	    this.appItem.University_Courses__c = viewModel.universityCourses == true;
	    this.appItem.Prefers_Vegan__c = viewModel.vegan == true;
	    this.appItem.Prefers_Vegetarian__c = viewModel.vegetarian == true;
	    this.appItem.Will_Attend_Religious_Service__c = viewModel.willAttendReligiousService == true;
	    this.appItem.Personal_Interests__c = viewModel.personalInterests;
	    this.appItem.Music_Preferences__c = viewModel.musicPreferences;
	    this.appItem.Prefers_Children__c = viewModel.children == true;
		this.appItem.Not_Currently_Enrolled__c = viewModel.notCurrentlyEnrolled == true;
		this.appItem.Recommendation_Wavied__c = viewModel.recommendationWaived != null && viewModel.recommendationWaived != '' ? viewModel.recommendationWaived : appItem.Recommendation_Wavied__c;

		Boolean otherItemsSaved = true;

		//Only add if this is a housing preference form
		if(viewModel.recordType == 'Housing_Preferences_Form' && viewModel.housingOptions != null)
		{
			List<Housing_Preference__c> housingPreferences = new List<Housing_Preference__c>();
		    for(Map<String,String> option : viewModel.housingOptions)
		    {
			    Housing_Preference__c preference = new Housing_Preference__c();
			    preference.Application__c = appItem.Application__c;
			    preference.Program_Term_Housing_Option__c = option.get('Id');
			    preference.Rank__c = Decimal.valueOf(option.get('Rank'));
			    housingPreferences.add(preference);
		    }

      		List<Database.SaveResult> results = Database.insert(housingPreferences);

			for(Database.SaveResult result : results)
			{
				if(!result.isSuccess())
				{
					for(Database.Error error : result.getErrors())
					{
						otherItemsSaved = false;
						apexErrorUtility.debug(LoggingLevel.ERROR, 'A housing preference failed to save from the form. The error is as follows: ' + error.getMessage());
					}
				}
			}
		}

		//Only add if this is a transcript
		if(otherItemsSaved && viewModel.recordType == 'Transcript' && viewModel.courses != null && viewModel.courses.size() > 0)
		{	
			List<Course__c> courses = new List<Course__c>();
			Id courseRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType =: 'Course__c' AND DeveloperName =: 'Home_Institution'].Id;
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
			//At this point we still could have 0 courses...so don't submit!
			if(courses.size() > 0)
			{
				List<Database.SaveResult> results = Database.insert(courses);
				
				for(Database.SaveResult result : results)
				{
					if(!result.isSuccess())
					{
						for(Database.Error error : result.getErrors())
						{
							apexErrorUtility.debug(LoggingLevel.ERROR, 'A course failed to save from the course transcript form. The error is as follows: ' + error.getMessage());
						}
					}
				}
			}
		}
	
		//Only attempt to save if we have success up to this point
		return otherItemsSaved ? this.save() : otherItemsSaved;
	}

	/**
	 * Populates the application item general view model
	 * @param viewModel the pre-existing view model to populate.
	 * @return the same view model instance, now populated with data.
	 */
	public customDocumentsViewModel populateViewModel(customDocumentsViewModel viewModel)
	{
		if(viewModel.appItems == null)
		{
			viewModel.appItems = new List<studentApplyItemViewModel>();
		}
		
		studentApplyItemViewModel subViewModel = new studentApplyItemViewModel();
    	subViewModel.id = this.appItem.Id;
      	subViewModel.name = this.appItem.Name;
      	subViewModel.status = this.appItem.Status__c;
		
		viewModel.appItems.add(subViewModel);

		return viewModel;
	}

	/**
	 * Populates the application item general view model
	 * @param viewModel the pre-existing view model to populate.
	 * @return the same view model instance, now populated with data.
	 */
	public studentApplyItemViewModel populateViewModel(studentApplyItemViewModel viewModel)
	{
    	viewModel.id = this.appItem.Id;
      	viewModel.name = this.appItem.Name;
      	viewModel.status = this.appItem.Status__c;

		return viewModel;
	}
	
	/**
	 * Populates the application item specific view model
	 * @param viewModel the pre-existing view model to populate.
	 * @return the same view model instance, now populated with data.
	 */
	public studentApplyItemDetailsViewModel populateViewModel(studentApplyItemDetailsViewModel viewModel)
	{
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
	    viewModel.ccParticipationOptions = apexConversionUtility.getPicklistStringValues(Application_Item__c.C_C_Participation__c);
    	viewModel.ceAuralComprehension = appItem.CE_Aural_Comprehension__c;
    	viewModel.ceReading = appItem.CE_Reading__c;
    	viewModel.ceSpeaking = appItem.CE_Speaking__c;
    	viewModel.ceWriting = appItem.CE_Writing__c;
	    viewModel.children = appItem.Prefers_Children__c;
    	viewModel.commercialTeachingRosettaStoneEtc = appItem.Commercial_Teaching_Rosetta_Stone_etc__c;
	    viewModel.competencyOptions = apexConversionUtility.getPicklistStringValues(Application_Item__c.MSA_Reading__c);
    	viewModel.communityCourses = appItem.Community_Courses__c;
	    viewModel.content = appItem.Content__c;
	    viewModel.contentLink = appItem.Content_Link_New__c;
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
	    viewModel.displaynonsmoking = appItem.Display_NonSmoking_Option__c;
	    viewModel.displayoffcampus = appItem.Display_Off_Campus_Option__c;
	    viewModel.displayoncampus = appItem.Display_On_Campus_Option__c;
	    viewModel.displayother = appItem.Display_Other__c;
	    viewModel.displayprivatebathroom = appItem.Display_Private_Bathroom_Option__c;
	    viewModel.displayReligiousAccomodations = appItem.Display_Religious_Accomodations__c;
	    viewModel.displayroommaterequests = appItem.Display_Roommate_Requests__c;
	    viewModel.displayselfcatered = appItem.Display_Self_Catered_Option__c;
	    viewModel.displaySignature = appItem.Display_Signature__c;
	    viewModel.displaysinglegender = appItem.Display_Single_Gender_Option__c;
	    viewModel.displaysingleroom = appItem.Display_Single_Room_Option__c;
	    viewModel.displaysmoking = appItem.Display_Smoking_Option__c;
	    viewModel.displayVegan = appItem.Display_Vegan_Option__c;
	    viewModel.displayvegetarian = appItem.Display_Vegetarian_Option__c;
	    viewModel.emergencyTreatment = appItem.Emergency_Treatment__c;
	    viewModel.epiPen = appItem.Epi_Pen__c;
	    viewModel.evaluatorEmail = appItem.Evaluator_Email__c;
	    viewModel.evaluatorName = appItem.Evaluator_Name__c;
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
	    viewModel.housingRestrictions = appItem.Housing_Restrictions__c;
	    viewModel.housingRestrictionsDescription = appItem.Housing_Restrictions_Description__c;
	    viewModel.hReading = appItem.H_Reading__c;
	    viewModel.hSpeaking = appItem.H_Speaking__c;
	    viewModel.hWriting = appItem.H_Writing__c;
	    viewModel.id = appItem.Id;
	    viewModel.isComplete = appItem.Status__c == 'Complete';
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
	    viewModel.musicPreferences = appItem.Music_Preferences__c;
	    viewModel.name = appItem.Name;
	    viewModel.nonSmoking = appItem.Prefers_Non_Smoking__c;
		viewModel.notCurrentlyEnrolled = appItem.Not_Currently_Enrolled__c;
		viewModel.numberOfRecommendations = (Integer) appItem.Number_of_Recommendations__c;
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
	    viewModel.personalInterests = appItem.Personal_Interests__c;
	    viewModel.phase = appItem.Phase__c;
	    viewModel.physActivityRestrictionsDescription = appItem.Phys_Activity_Restrictions_Description__c;
	    viewModel.physicalActivityRestrictions = appItem.Physical_Activity_Restrictions__c;
	    viewModel.pReading = appItem.P_Reading__c;
	    viewModel.privateBathroom = appItem.Prefers_Private_Bathroom__c;
	    viewModel.pSpeaking = appItem.P_Speaking__c;
	    viewModel.pWriting = appItem.P_Writing__c;
		viewModel.recommendationWaived = appItem.Recommendation_Wavied__c;
	    viewModel.recordType = appItem.RecordType.DeveloperName;
	    viewModel.regularlySpeak = appItem.Regularly_Speak__c;
	    viewModel.regularlySpeakOptions = apexConversionUtility.getPicklistStringValues(Application_Item__c.Regularly_Speak__c);
	    viewModel.willAttendReligiousService = appItem.Will_Attend_Religious_Service__c;
	    viewModel.religiousAccomodations = appItem.Religious_Accomodations__c;
	    viewModel.roommateRequests = appItem.Roommate_Requests__c;
	    viewModel.sameBillingAddress = appItem.Billing_Street__c != null && appItem.Billing_Street__c.equals(appItem.Mailing_Street__c);
	    viewModel.sameOtherAddress = appItem.Other_Street__c != null && appItem.Other_Street__c.equals(appItem.Mailing_Street__c);
	    viewModel.selfCatered = appItem.Prefers_Self_Catered__c;
	    viewModel.singleGender = appItem.Prefers_Single_Gender__c;
	    viewModel.singleRoom = appItem.Prefers_Single_Room__c;
	    viewModel.smoking = appItem.Prefers_Smoking__c;
	    viewModel.speaksArabic = appItem.Speaks_Arabic__c;
	    viewModel.speaksColloquialEgyptian = appItem.Speaks_Colloquial_Egyptian__c;
	    viewModel.speaksHebrew = appItem.Speaks_Hebrew__c;
	    viewModel.speaksPalestinian = appItem.Speaks_Palestinian__c;
	    viewModel.status = appItem.Status__c;
	    viewModel.textToSign = appItem.Text_to_Sign__c;
	    viewModel.typicalReaction = appItem.Typical_Reaction__c;
	    viewModel.universityCourses = appItem.University_Courses__c;
	    viewModel.vegan = appItem.Prefers_Vegan__c;
	    viewModel.vegetarian = appItem.Prefers_Vegetarian__c;
	    viewModel.willHaveGroupTravel = appItem.Application__r.Program_Term__r.Arrival_Plan_Type__c;
	    viewModel.displaySignature = appItem.Display_Signature__c;
	    viewModel.sameBillingAddress = appItem.Billing_Street__c != null && appItem.Billing_Street__c.equals(appItem.Mailing_Street__c);
	    viewModel.sameOtherAddress = appItem.Other_Street__c != null && appItem.Other_Street__c.equals(appItem.Mailing_Street__c);
		viewModel.notCurrentlyEnrolled = appItem.Not_Currently_Enrolled__c;
		viewModel.recommendationWaived = appItem.Recommendation_Wavied__c;
		viewModel.numberOfRecommendations = (Integer) appItem.Number_of_Recommendations__c;
		

		return viewModel;
	}

	/**
	 * Getter for the Id
	 * @return The Id of the application item
	 */
	public Id getId()
	{
		return this.appItem.Id;
	}
	

	/**
	 * Getter for the Id of the housing option
	 * @return The Id of the selected housing option
	 */
	public Id getHousingOptionId()
	{
    	return this.appItem.Housing_Option__c;
	}
	
	/**
	 * Getter for the Record type name
	 * @return The name of the application item record type
	 */
	public String getRecordTypeName()
	{
		return this.appItem.RecordType.DeveloperName;
	}

	/**
	 * Getter for the Id of the program term
	 * @return The Id of the application item's application's program term.
	 */
	public Id getProgramTermId()
	{
		return this.appItem.Application__r.Program_Term__c;
	}

	/**
	 * Getter for the Id of the student's contact
	 * @return The Id of the application's applicant
	 */
	public Id getApplicantId()
	{
		return this.appItem.Application__r.Applicant__c;
	}
	
	/**
	 * Getter for the Id of the application
	 * @return The Id of the application item's application
	 */
	public Id getApplicationId()
	{
		return this.appItem.Application__c;
	}
}