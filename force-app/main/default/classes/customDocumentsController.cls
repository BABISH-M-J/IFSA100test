/**
 * Controller for the my documents page of the custom portal.
 * THE CUSTOM PORTAL IS POWERD BY THE CATALOG STUDENT PORTAL SO THAT EFFORTS ARE NOT DUPLICATED AS OF SUMMER 2020.
 * @author Cameron Ames
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class customDocumentsController extends customBaseController
{
	/**
	 * @description view model for the page.
	 */
	public customDocumentsViewModel viewModel {get;set;}

	/**
	 * @description application object
	 */
	private ifsaApplicationWrapper application {get;set;}

	/**
	 * @description application item objects
	 */
	private List<ifsaApplicationItemWrapper> applicationItemList {get;set;}

	/**
	 * @description Constructor function.
	 */
	public customDocumentsController()
	{
		super();
		this.viewModel = new customDocumentsViewModel();

		this.application = new ifsaApplicationWrapper(this.student.getActiveApplicationId());

		if(!this.application.isCustom())
		{
			this.application = null;
			return;
		}

		List<Application_Item__c> appItemList = this.application.getApplicationItems(null);
		this.applicationItemList = new List<ifsaApplicationItemWrapper>();
		for(Application_Item__c appItem : appItemList)
		{
			this.applicationItemList.add(new ifsaApplicationItemWrapper(appItem));
		}

		this.viewModel = this.populateViewModel(this.viewModel);
	}

	/**
	 * @description Ensures that the user actually has access to this page, beyond profile permissions and portal pages.
	 * @return A Pagereference redirect, or, if access is valid, null.
	 */
	public override PageReference validateAccess()
	{
		//If the portal has been locked down redirect to message screen
		if(this.viewModel.isLockDownActive)
		{
			return new PageReference('/advisorportal/CP_PortalMessage');
		}
    else if(this.application != null)
		{
			apexErrorUtility.debug(LoggingLevel.INFO, this.application + ' ' + this.viewModel.getSerializedViewModel());
			return null;
		}
		return new PageReference('CP_NoApp');
	}

	/**
	 * @description Takes a view model and populates it with data that can be provided by the application item.
	 * @param viewModel A pre-existing view model instance.
	 * @return The same view model instance, populated with application item data.
	 */
	private customDocumentsViewModel populateViewModel(customDocumentsViewModel viewModel)
	{
		viewModel = (customDocumentsViewModel) super.populateCustomBaseViewModel(viewModel);

		for(ifsaApplicationItemWrapper applicationItem : this.applicationItemList)
		{
			viewModel = applicationItem.populateViewModel(viewModel);
		}
        Program_Term__c pt = [SELECT Owner.Name, Owner.Email, Custom_Portal_Introduction__c, Program__r.Display_Account_Tab__c FROM Program_Term__c WHERE Id =: this.application.getProgramTermId()].get(0);
        viewModel.customIntroduction = pt.Custom_Portal_Introduction__c;
        viewModel.paName = pt.Owner.Name;
        viewModel.paEmailAddress = pt.Owner.Email;
        viewModel.displayAccountTab = pt.Program__r.Display_Account_Tab__c == 'Yes';
		viewModel = (customDocumentsViewModel) this.application.populateViewModel(viewModel);
		return viewModel;
	}
  // MOVED TO PORTALREMOTINGMETHODS
  /*
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

    Application_Item__c appItem = (Application_Item__c) apexQueryUtility.selectAllFrom('Application_Item__c', 'Application__r.Applicant__c', 'Id = \'' + viewModel.id + '\'').get(0);
    Contact studentContact = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Id = \'' + appItem.Application__r.Applicant__c + '\'').get(0);
    Account studentAccount = (Account) apexQueryUtility.selectAllFrom('Account', 'Id = \'' + studentContact.AccountId + '\'').get(0);
    Application__c studentApplication = (Application__c) apexQueryUtility.selectAllFrom('Application__c',  'Id = \'' + viewModel.applicationId + '\'').get(0);
	List<Attachment> attmts = [SELECT Id FROM Attachment WHERE parentId =: viewModel.Id];

	System.debug(logginglevel.ERROR, viewModel.status);
	if(viewModel.RecordType != 'Spanish_Language_Evaluation' && viewModel.RecordType != 'Transcript' && viewModel.recordType != 'Recommendation' && viewModel.recordType != 'Passport_Copy' && viewModel.RecordType != 'Medical_Form' && (viewModel.RecordType != 'No_Action' && (!viewModel.Name.Contains('Transcript') || !viewModel.Name.Contains('Flight'))))
	{
		viewModel.status = 'Complete';
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
	else if(viewModel.RecordType == 'No_Action' && (viewModel.Name.Contains('Transcript') || viewModel.Name.Contains('Flight')))
	{
		viewModel.status = 'Started';
	}
	else if(viewModel.RecordType == 'Passport_Copy')
	{
		if(viewModel.passportInRenewal == true)
		{
			viewModel.status = 'Started';
			viewModel.directions = 'Please update your Passport once it has been renewed.';
		}
		else if(viewModel.passportDoNotHave == true)
		{
			viewModel.status = 'Started';
			viewModel.directions = 'The host institution requires a copy of your passport. Upload a copy of the photo and signature pages of your passport and complete the following:';
		}
	}
	System.debug(LoggingLevel.ERROR, viewModel.status);

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
    appItem.Content__c = viewModel.content;
    //appItem.Content_Link__c = viewModel.contentLink;
    appItem.Current_Treatment__c = viewModel.currentTreatment == true;
    appItem.Current_Treatment_Description__c = viewModel.currentTreatmentDescription;
    if (viewModel.dietaryRestrictions != null)
    {
    	appItem.Dietary_Restrictions__c = viewModel.dietaryRestrictions.unescapeHTML4();
    }
    appItem.Directions__c = viewModel.directions;
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
    if (viewModel.religiousAccomodations != null)
    {
    	appItem.Religious_Accomodations__c = viewModel.religiousAccomodations.unescapeHtml4();
    }
    if (viewModel.roommateRequests != null)
    {
    	appItem.Roommate_Requests__c = viewModel.roommateRequests.unescapeHtml4();
    }
    appItem.Prefers_Self_Catered__c = viewModel.selfCatered == true;
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
	appItem.Passport_Country_Of_Issuance__c = viewModel.passportCountry;
	appItem.Passport_Expiration_Date__c = viewModel.passportExpirationDate;
	appItem.Passport_Number__c = viewModel.passportNumber;
    appItem.Passport_Does_Not_Have__c = viewModel.passportDoNotHave == true;
    appItem.Passport_In_Renewal__c = viewModel.passportInRenewal == true;
	
	System.debug(viewModel.passportExpirationDate);
	System.debug(appItem.Passport_Expiration_Date__c);
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
    studentAccount.BillingCountry = viewModel.sameBillingAddress != null ? viewModel.sameBillingAddress ? viewModel.mailingCountry : viewModel.billingCountry : viewModel.billingCountry;
    studentAccount.BillingPostalCode = viewModel.sameBillingAddress != null ? viewModel.sameBillingAddress ? viewModel.mailingZip : viewModel.billingZip : viewModel.billingZip;
    studentAccount.BillingState = viewModel.sameBillingAddress != null ? viewModel.sameBillingAddress ? viewModel.mailingState : viewModel.billingState : viewModel.billingState;
    studentAccount.BillingStreet = viewModel.sameBillingAddress != null ? viewModel.sameBillingAddress ? viewModel.mailingStreet : viewModel.billingStreet : viewModel.billingStreet;

	if(viewModel.RecordType == 'Agreements_and_Releases')
	{
		studentContact.Directory_Information_Opt_Out__c = viewModel.directoryOptOutStatus;
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

    List<sObject> sobjects = new List<sObject> {appItem, studentAccount, studentContact};
    List<Database.SaveResult> results = Database.update(sObjects);
    Boolean isSaved = true;
    
    for(Database.SaveResult result : results)
    {
      isSaved = isSaved && result.isSuccess();
    }

    if(viewModel.recordType == 'Spanish_Language_Evaluation')
    {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setReplyTo('forms@ifsa-butler.org');
      mail.setSenderDisplayName('IFSA-Butler No Reply');
      mail.setToAddresses(new List<String> {viewModel.evaluatorEmail});
      mail.setSubject('IFSA-Butler Student Recommendation');
      mail.setHtmlBody('Hello ' + viewModel.evaluatorName + ',<br/><br/><p>Recently, a student attending your institution has requested that you fill out a Spanish Language Evaluation for them to study abroad at an IFSA-Butler intermediate or advanced Spanish program.</p><p>For more information or to complete the evaluation, please click this link <a href="https://ifsa.force.com/studentportal/SP_SpanishEvaluation?app=' + appItem.Application__c + '&appItem=' + viewModel.id + '">here.</a> If that does not work, you can copy and paste the following into your browser:</p>');
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
    }

    List<Housing_Preference__c> housingPreferences = new List<Housing_Preference__c>();
    if(viewModel.housingOptions != null)
    {
    	for(Map<String,String> option : viewModel.housingOptions)
	    {
		    Housing_Preference__c preference = new Housing_Preference__c();
		    preference.Application__c = appItem.Application__c;
		    preference.Program_Term_Housing_Option__c = option.get('Id');
		    preference.Rank__c = Decimal.valueOf(option.get('Rank'));
		    housingPreferences.add(preference);
	    }
	    if(housingPreferences.size() > 0)
		{
	    	Database.insert(housingPreferences);
	    }
    }
	
	List<Course__c> courses = new List<Course__c>();
	Id courseRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType =: 'Course__c' AND DeveloperName =: 'Home_Institution'].Id;
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

    return viewModel.status == 'Complete' || viewmodel.status == 'Started';
  }
  // MOVED TO PORTALREMOTINGMETHODS
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
        mail.setHtmlBody('Dear ' + rcommendation.Name + ',<p>This is a request for recommendation letter for ' + studentName + '.</p><p>' + studentName + ' applied to study abroad at ' + appItem.Application__r.Program_Term__r.Display_Name__c + ' through the Institute for Study Abroad, Butler University (IFSA-Butler).</p><p>In an effort to obtain an objective letter of recommendation from professors, IFSA-Butler does not disclose letters of recommendation to students.</p><p>Please click on the link below to write a recommendation letter for ' + studentName + '.</p><p><a href="https://ifsa.force.com/studentportal/SP_Recommendation?app=' + appItemId + '&recommender=' + rcommendation.Id + '">Recommendation Letter</a></p><p>If you encounter any problems with the online recommendation letter, please contact us.</p><p>Thank you,<br/>Institute for Study Abroad, Butler University<br/>U.S. Toll Free Telephone<br/>800-858-0229<br/>studyabroad@ifsa-butler.org</p><p>MORE CULTURE. LESS SHOCK.</p><p>CONFIDENTIALITY NOTICE: The materials enclosed with this facsimile transmission are private and confidential and are the property of the sender. The information contained in the material is privileged and is intended only for the use of the individual(s) or entity(ies) named below. If you are not the intended recipient, be advised that any unauthorized disclosure, copying, distribution or the taking of any action in reliance on the contents of this telecopied information is strictly prohibited. If you have received this facsimile transmission in error, please immediately notify us by telephone to arrange for return of the forwarded documents to us.</p>');
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
  // MOVED TO PORTALREMOTINGMETHODS
  @RemoteAction
  public static List<Flight__c> getTravelDetails(String name)
  {    
    return [SELECT Name, Arrival_Airport_Code__c, Arrival_Time__c, Departure_Airport_Code__C, Departure_Time__c FROM Flight__c WHERE Travel_Plan__r.Name =: name];
  }
  */ 
  @RemoteAction
  public static void closeCompletionNotification(String applicationId)
  {
    try
    {
      Id appId = Id.valueOf(applicationId);
      Application__c application = [SELECT Id, Completion_Notification_Received__c FROM Application__c WHERE Id =: appId];
      application.Completion_Notification_Received__c = true;
      Database.update(application);
    }
    catch(Exception e)
    {
      System.debug(LoggingLevel.ERROR, e.getMessage());
    }
  }
}