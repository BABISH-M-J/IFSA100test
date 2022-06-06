/**
 * Advisor Portal VisualForce page controller. Contains all of the server side logic.
 * @author Brock Barlow
 */
// ApexDoc updated 1/22/2021 Brock Barlow
public without sharing class advisorPortalController extends advisorBaseController
{
    /**
     * Container for all data needed on the page. See <<advisorPortalViewModel>>     
     */
    public advisorPortalViewModel viewModel {get;set;}
    /**
     * Google Anayltics Id
     */
    public String gaId {get;set;}
    /**
     * Google Tag Manager Id
     */
    public String gtmId {get;set;}
    /**
     * Constructor function. Only initializes a blank view model for this page.
     * @return void
     */
     public advisorPortalController() {
        super();
        GoogleAnalyticsUtility util = new GoogleAnalyticsUtility('AP');
        this.gaId = util.getAnalyticsId();
        this.gtmId = util.getTagManagerId();
        this.viewModel = this.populateViewModel(New advisorPortalViewModel());
        system.debug('welcomappitem'+apexPages.currentPage().getParameters().get('appItem'));
    }
    
    /** 
     * populated an <<advisorPortalViewModel>> object so the page will function
     */
    public advisorPortalViewModel populateViewModel(advisorPortalViewModel viewModel)
    {
        Id accountId = this.advisor.getAccountId();
        viewModel = (advisorPortalViewModel) super.populateAdvisorBaseViewModel(viewModel);
        User fd = [SELECT Id, FirstName, LastName, FullPhotoUrl, Phone, Email, Title FROM User WHERE Id IN (SELECT OwnerId FROM Account WHERE Id =: accountId)];
        viewModel.fieldDirectorFirstName = fd.FirstName;
        viewModel.fieldDirectorLastName = fd.LastName;
        viewModel.fieldDirectorProfileImageURL = fd.FullPhotoUrl;
        viewModel.fieldDirectorPhone = fd.Phone;
        viewModel.fieldDirectorEmail = fd.Email;
        viewModel.fieldDirectorTitle = fd.Title;

        return viewModel;
    }
    // Start Students Page
    /**
     * returns an <<advisorStudentsViewModel>> object for the students page
     * @return <<advisorStudentsViewModel>>
     */
    @RemoteAction
    public static advisorStudentsViewModel getStudentsViewModel()
    {
        return new advisorStudentsController().viewModel;
    }
    /**
     * Searches for the advisor students based on a number of parameters
     * @param section
     * @param year
     * @param country
     * @param status
     * @param onlyProgramApproval
     * @param nameToSearch
     * @return <<advisorStudentApplicationViewModel>> object with the results of the search query
     */
    @RemoteAction
    public static List<advisorStudentApplicationViewModel> searchForStudents(String section, String year, String country, String status, Boolean onlyProgramApproval, String nameToSearch)
    {
        //Get the current advisor
        User advisorUser = [SELECT Id, Name, ContactId, Contact.Id, Contact.Name, Contact.AccountId, Contact.Account.Institution__c, Custom_Program_Advisor__c FROM User WHERE Id =: UserInfo.getUserId()];
        //Only add the country id if the filter is set
        Id countryId;

        if(country != 'All' && country != 'null' && country != null)
        
        {
            countryId = [SELECT Id FROM Country__c WHERE Name =: country].Id;
        }

        List<Id> programTermIdList;

        //If the section or year filters are set, get the appropriate program terms
        if((section == 'All' || section == null) && (year == 'All' || year == null))
        {
            programTermIdList = null;
        }
        else
        {
            //Only add the necessary filters...if it is 'All' then we don't need a filter on that aspect
            String whereClause = (section != 'All' && section != null) ? 'Term__r.Section__c = \'' + section + '\'' : '';
            If(year != null && year != 'All')
            {
                whereClause += whereClause != '' ? ' AND Term__r.Year__c = ' + year : 'Term__r.Year__c = ' + year;
                //whereClause += whereClause != '' ? ' AND Term__r.Year__c = \'' + year + '\'' : '';
                //whereClause += whereClause != '' ? ' AND Term__r.Year__c = ' + year : 'Term__r.Year__c = ' + year;
            }

            List<Program_Term__c> programTermList = apexQueryUtility.selectAllFrom('Program_Term__c', whereClause);

            programTermIdList = new List<Id>();

            //There are no program terms..empty return
            if(programTermList.size() <1)
            {
                Return New List < advisorStudentApplicationViewModel > ();
            }

            //Build an Id list of all of these program terms
            For (Program_Term__c programTerm : programTermList)
            {
                programTermIdList.add(programTerm.Id);
            }
        }
        // If "All" Statuses are desired we need to show all, DO NOT HIDE Dropped, Diverted etc

        If (status == 'All')
        {
            status = null;
        }
        //Add program Term criteria
        String additionalCriteria = countryId!= null ? ' AND Program_Term__r.Program__r.Host_Institution__r.Country__c = \'' + countryId + '\'' : '';
        //ACARSON
        //additionalCriteria += status!= null ? ' AND Status__c = \'' + status + '\'' : '';
        //additionalCriteria += status!= null ? ' AND Status__c = \'' + status + '\'' : 'AND Status__c NOT IN (\'Dropped\', \'Diverted\')';
        additionalCriteria += status == null ? ' AND (NOT(Status__c = \'New\' OR Status__c = \'Housing Selected\' OR Status__c = \'Travel Approved\' OR Status__c = \'Unqualified\' OR Status__c = \'Deceased\'))' : ' AND Status__c = \'' + status + '\'';

        additionalCriteria += advisorUser.Custom_Program_Advisor__c ? ' AND Is_Custom__c = TRUE' : ' AND Is_Custom__c = FALSE';
        
        String programTermInClause = '';
        If(programTermIdList!= null)
        {
            For (String programTermId : programTermIdList)
            {
            programTermInClause += programTermInClause!= '' ? ', \'' + programTermId + '\'' : '(\'' + programTermId + '\'';
            }

            programTermInClause += programTermInClause!= '' ? ')' : '';
        }

        additionalCriteria += programTermInClause!= '' ? ' AND Program_Term__c IN ' + programTermInClause : '';
         // added by powerfluence based on Clayton req 03/29/2022 starts
        //Sort list by student name
        //additionalCriteria += ' ORDER BY Applicant__c Limit';
        additionalCriteria += ' ORDER BY Applicant__c';
        //Finally querying the list of applications that fall under the appropriate filters
         // added by powerfluence based on Clayton req 03/29/2022 ends
        List<Application__c> applicationList;
        if(nameToSearch == ' ')
        {
            //applicationList = apexQueryUtility.selectAllFrom('Application__c', '(select Id, Status__c, RecordType.DeveloperName FROM Application_Items__r)' , 'Applicant__r.Home_Institution__c = \'' + advisorUser.Contact.Account.Institution__c + '\'' + additionalCriteria);
            applicationList = apexQueryUtility.selectAllFrom('Application__c', '(select Id, Status__c, RecordType.DeveloperName FROM Application_Items__r WHERE RecordType.DeveloperName IN (\'Program_Approval\',\'Learning_Plan\'))' , 'Applicant__r.Home_Institution__c = \'' + advisorUser.Contact.Account.Institution__c + '\'' + additionalCriteria);
        }
        else
        {
            //applicationList = apexQueryUtility.selectAllFrom('Application__c', '(select Id, Status__c, RecordType.DeveloperName FROM Application_Items__r)' , 'Applicant__r.Name LIKE \'%' + nameToSearch + '%\' AND Applicant__r.Home_Institution__c = \'' + advisorUser.Contact.Account.Institution__c + '\'' + additionalCriteria);
            applicationList = apexQueryUtility.selectAllFrom('Application__c', '(select Id, Status__c, RecordType.DeveloperName FROM Application_Items__r WHERE RecordType.DeveloperName IN (\'Program_Approval\',\'Learning_Plan\'))' , 'Applicant__r.Name LIKE \'%' + nameToSearch + '%\' AND Applicant__r.Home_Institution__c = \'' + advisorUser.Contact.Account.Institution__c + '\'' + additionalCriteria);
        }
        
        List<advisorStudentApplicationViewModel> viewModelList = new List<advisorStudentApplicationViewModel>();

        //Populate view model data
        for(Application__c application : applicationList)
        {
            advisorStudentApplicationViewModel appViewModel = new advisorStudentApplicationViewModel();
            appViewModel.ApplicationId = application.Id;
            appViewModel.ApplicationProgramTermProgram = application.Program_Term_Program__c;
            appViewModel.ApplicationProgramTermSection = application.Program_Term_Section__c;
            appViewModel.ApplicationProgramTermYear = application.Program_Term_Year__c;
            appViewModel.ApplicationStatus = application.Status__c;
            appViewModel.ApplicationContracted = application.Status_Contract_Signed__c != null ? true : false;
            appViewModel.ApplicationDesignation = application.Designation__c;
            appViewModel.ApplicationStudentFirstName = application.Student_First_Name__c;
            appViewModel.ApplicationStudentLastName = application.Student_Last_Name__c;
            appViewModel.ProgramApprovalStatus = 'None';
            appViewModel.LearningPlanStatus = 'None';
            
            for(Application_Item__c appItem : application.Application_Items__r)
            
            {
               
                if(appItem.RecordType.DeveloperName == 'Program_Approval')
                {
                    appViewModel.ProgramApprovalStatus = appItem.Status__c;
                    appViewModel.ProgramApprovalId = appItem.Id;
                }
                if(appItem.RecordType.DeveloperName == 'Learning_Plan')
                {
                    appViewModel.LearningPlanStatus = appItem.Status__c;
                    appViewModel.LearningPlanId = appItem.Id;
                }
            }
            
            if(!onlyProgramApproval || (appViewModel.ProgramApprovalId != null && appViewModel.ProgramApprovalStatus != 'Complete' && (appViewModel.ApplicationStatus == 'Program Selected' || appViewModel.ApplicationStatus == 'Ready To Submit' || appViewModel.ApplicationStatus == 'Submitted')))
            {
                viewModelList.add(appViewModel);
            }

        }

        return viewModelList;
    }

    /**
     * Gets the application details for a selected student, including application items (Id and Name only). See <<advisorStudentsViewModel_ApplicationDetails>>
     * @param applicationId The Id of the application to retrieve details on.
     * @return <<advisorStudentsViewModel_ApplicationDetails>>
     */
    @RemoteAction
    public static advisorStudentsAppDetailsViewModel getApplicationDetails(String applicationId)
    {
        if(applicationId == null)
        {
            return null;
        }

        //Get the application, student, and home institution objects
        Application__c application = (Application__c) apexQueryUtility.selectAllFrom('Application__c', 'Id = \'' + applicationId + '\'').get(0);
        Contact studentContact = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Id = \'' + application.Applicant__c + '\'').get(0);
        Home_Institution__c homeInstitution = (Home_Institution__c) apexQueryUtility.selectAllFrom('Home_Institution__c', 'Id = \'' + studentContact.Home_Institution__c + '\'').get(0);

        //Populate view model data
        advisorStudentsAppDetailsViewModel viewModel = new advisorStudentsAppDetailsViewModel();
        viewModel.ApplicationId = application.Id;
        viewModel.ApplicationProgramTermProgram = application.Program_Term_Program__c;
        viewModel.ApplicationProgramTermSection = application.Program_Term_Section__c;
        viewModel.ApplicationProgramTermYear = application.Program_Term_Year__c;
        viewModel.ApplicationStatus = application.Status__c;
        viewModel.CustomApplication = application.Is_Custom__c;
        viewModel.HomeInstitutionName = homeInstitution.Name;
        viewModel.StudentBirthdate = studentContact.Birthdate;
        viewModel.StudentCitizenship = studentContact.Citizenship__c;
        viewModel.StudentDegree = studentContact.Degree__c;
        viewModel.StudentEmail = studentContact.Email;
        viewModel.StudentFirstGeneration = studentContact.First_Generation__c;
        viewModel.StudentFirstName = studentContact.FirstName;
        viewModel.StudentGPA = studentContact.GPA__c;
        viewModel.StudentGradeLevel = studentContact.Grade_Level__c;
        viewModel.StudentLastName = studentContact.LastName;
        viewModel.StudentMailingCity = studentContact.MailingCity;
        viewModel.StudentMailingCountry = studentContact.MailingCountry;
        viewModel.StudentMailingPostalCode = studentContact.MailingPostalCode;
        viewModel.StudentMailingState = studentContact.MailingState;
        viewModel.StudentMailingStreet = studentContact.MailingStreet;
        //ACARSON Jan.02.2018  conditional to determine major based on text or picklist major field
        //viewModel.StudentMajor = studentContact.Major__c;
        viewModel.StudentMajor = String.isBlank(studentContact.Major_New__c) ? studentContact.Major__c : studentContact.Major_New__c ;
        viewModel.StudentMiddleName = studentContact.Middle_Name__c;
        viewModel.StudentPhone = studentContact.Phone;
        viewModel.StudentPreferredName = studentContact.Preferred_Name__c;
        viewModel.StudentSex = studentContact.Sex__c;
        viewModel.StudentSuffix = studentContact.Suffix__c;
        viewModel.StudentTwitterHandle = studentContact.Twitter_Handle__c;

        viewModel.appItems = new List<advisorStudentsAppItemViewModel>();

        //Only get pre-admit app items
        String phase = 'Pre-Admit';
        if(application.Status__c == 'Accepted' && application.Is_Custom__c)
        {
            phase = 'Pre-Acceptance';
        }
        else if(viewModel.ApplicationStatus != 'Program Selected' && viewModel.ApplicationStatus != 'Registered' && viewModel.ApplicationStatus != 'New')
        {
            phase = 'Pre-Admit';    
        }
      
        //Query for the app items
        //List<Application_Item__c> applicationItems = apexQueryUtility.selectAllFrom('Application_Item__c', 'Application__r.Program_Term__r.Program__r.Language_Of_Instruction__c, Application__r.Program_Term__r.Arrival_Plan_Type__c, RecordType.DeveloperName, RecordType.Id', '(Application__c = \'' + application.Id + '\' AND Phase__c = \'' + phase + '\') OR RecordType.Name = \'Learning Plan\'');
        List<Application_Item__c> applicationItems = [SELECT Id, Name, Status__c FROM Application_Item__c WHERE Application__c =: applicationId AND (Phase__c =: phase OR RecordType.Name = 'Learning Plan' OR RecordType.Name = 'Program Approval')];
        //Populate view model app item data
        for(Application_Item__c appItem : applicationItems)
        {
            advisorStudentsAppItemViewModel appItemVm = new advisorStudentsAppItemViewModel();
            appItemVm.id = appItem.Id;
            appItemVm.name = appItem.Name;
            appItemVm.status = appItem.Status__c;
            appItemVm.isComplete = appItem.Status__c == 'Complete';
            viewModel.appItems.add(appItemVm);
        }

        return viewModel;
    }
    /**
     * Gets the application item details for a selected application item. See <<advisorStudentsAppItemViewModel>>
     * @param appItemId The Id of the application item to retrieve details on.
     * @return <<advisorStudentsAppItemViewModel>>
     */
    @RemoteAction
    public static advisorStudentsAppItemViewModel getApplicationItemDetails(String appItemId)
    {
        Application_Item__c appItem = (Application_Item__c) apexQueryUtility.selectAllFrom('Application_Item__c', 'Application__r.Program_Term__r.Program__r.Language_Of_Instruction__c, Application__r.Program_Term__r.Arrival_Plan_Type__c, RecordType.DeveloperName, RecordType.Id', 'Id = \'' + appItemId + '\'').get(0);
        
        advisorStudentsAppItemViewModel appItemVm = new advisorStudentsAppItemViewModel();
        appItemVm.academicProbation = appItem.Academic_Probation__c;
        appItemVm.academicProbationExplanation = appItem.Academic_Probation_Explanation__c;
        appItemVm.allergicTo = appItem.Allergic_To__c;
        appItemVm.approvalToStudy = appItem.Approval_to_Study__c;
        appItemVm.approvalToStudyExplanation = appItem.Approval_to_Study_Explanation__c;
        appItemVm.catered = appItem.Prefers_Catered__c;
        appItemVm.ccParticipation = appItem.C_C_Participation__c;
        appItemVm.ceAuralComprehension = appItem.CE_Aural_Comprehension__c;
        appItemVm.ceReading = appItem.CE_Reading__c;
        appItemVm.ceSpeaking = appItem.CE_Speaking__c;
        appItemVm.ceWriting = appItem.CE_Writing__c;
        appItemVm.commercialTeachingRosettaStoneEtc = appItem.Commercial_Teaching_Rosetta_Stone_etc__c;
        appItemVm.communityCourses = appItem.Community_Courses__c;
        appItemVm.content = appItem.Content__c;
        appItemVm.contentLink = appItem.Content_Link_New__c;
        appItemVm.currentTreatment = appItem.Current_Treatment__c;
        appItemVm.currentTreatmentDescription = appItem.Current_Treatment_Description__c;
        appItemVm.dietaryRestrictions = appItem.Dietary_Restrictions__c;
        appItemVm.directions = appItem.Directions__c;
        appItemVm.disciplinaryActionExplanation = appItem.Disciplinary_Action_Explanation__c;
        appItemVm.discipline = appItem.Discipline__c;
        appItemVm.displaycatered = appItem.Display_Catered_Option__c;
        appItemVm.displaydietaryrestrictions = appItem.Display_Dietary_Restrictions__c;
        appItemVm.displayfoodallergies = appItem.Display_Food_Allergies_Option__c;
        appItemVm.displayglutenfree = appItem.Display_Gluten_Free_Option__c;
        appItemVm.displayHalal = appItem.Display_Halal_Option__c;
        appItemVm.displaykosher = appItem.Display_Kosher_Option__c;
        appItemVm.displaylactoseintolerant = appItem.Display_Lactose_Intolerant_Option__c;
        appItemVm.displaynonsmoking = appItem.Display_NonSmoking_Option__c;
        appItemVm.displayoffcampus = appItem.Display_Off_Campus_Option__c;
        appItemVm.displayoncampus = appItem.Display_On_Campus_Option__c;
        appItemVm.displayother = appItem.Display_Other__c;
        appItemVm.displayprivatebathroom = appItem.Display_Private_Bathroom_Option__c;
        appItemVm.displayReligiousAccomodations = appItem.Display_Religious_Accomodations__c;
        appItemVm.displayroommaterequests = appItem.Display_Roommate_Requests__c;
        appItemVm.displayselfcatered = appItem.Display_Self_Catered_Option__c;
        appItemVm.displaysinglegender = appItem.Display_Single_Gender_Option__c;
        appItemVm.displaysingleroom = appItem.Display_Single_Room_Option__c;
        appItemVm.displaysmoking = appItem.Display_Smoking_Option__c;
        appItemVm.displayVegan = appItem.Display_Vegan_Option__c;
        appItemVm.displayvegetarian = appItem.Display_Vegetarian_Option__c;
        appItemVm.emergencyTreatment = appItem.Emergency_Treatment__c;
        appItemVm.epiPen = appItem.Epi_Pen__c;
        appItemVm.evaluatorEmail = appItem.Evaluator_Email__c;
        appItemVm.evaluatorName = appItem.Evaluator_Name__c;
        appItemVm.foodAllergies = appItem.Food_Allergies__c || appItem.Prefers_Food_Allergies__c;
        appItemVm.foodAllergyArrangementDescription = appItem.Food_Allergy_Arrangement_Description__c;
        appItemVm.foodAllergySpecialArrangments = appItem.Food_Allergy_Special_Arrangements__c;
        appItemVm.glutenFree = appItem.Prefers_Gluten_Free__c;
        appItemVm.goodStanding = appItem.Good_Standing__c;
        appItemVm.goodStandingExplanation = appItem.Good_Standing_Explanation__c;
        appItemVm.halal = appItem.Prefers_Halal__c;
        appItemVm.hAuralComprehension = appItem.H_Aural_Comprehension__c;
        appItemVm.heritageSpeaker = appItem.Heritage_Speaker__c;
        appItemVm.highSchoolCourses = appItem.High_School_Courses__c;
        appItemVm.housingRestrictions = appItem.Housing_Restrictions__c;
        appItemVm.housingRestrictionsDescription = appItem.Housing_Restrictions_Description__c;
        appItemVm.hReading = appItem.H_Reading__c;
        appItemVm.hSpeaking = appItem.H_Speaking__c;
        appItemVm.hWriting = appItem.H_Writing__c;
        appItemVm.id = appItem.Id;
        appItemVm.isComplete = appItem.Status__c == 'Complete';
        appItemVm.kosher = appItem.Prefers_Kosher__c;
        appItemVm.language = appItem.Application__r.Program_Term__r.Program__r.Language_Of_Instruction__c;
        appItemVm.lactoseIntolerant = appItem.Prefers_Lactose_Intolerant__c;
        appItemVm.learningDisability = appItem.Learning_Disability__c;
        appItemVm.learningDisabilityDescription = appItem.Learning_Disability_Description__c;
        appItemVm.medicalDietaryRestriction = appItem.Medical_Dietary_Restriction__c;
        appItemVm.medicalDietaryRestrictionDescription = appItem.Medical_Dietary_Restriction_Description__c;
        appItemVm.medicalPsychConditions = appItem.Medical_Psych_Conditions__c;
        appItemVm.medicalPsychConditionsExplanation = appItem.Medical_Psych_Conditions_Explanation__c;
        appItemVm.medicalPsychConditionsTreatment = appItem.Medical_Psych_Conditions_Treatment__c;
        appItemVm.medicationAllergies = appItem.Medication_Allergies__c;
        appItemVm.medicationAllergiesDescription = appItem.Medication_Allergies_Description__c;
        appItemVm.msaAuralComprehension = appItem.MSA_Aural_Comprehension__c;
        appItemVm.msaReading = appItem.MSA_Reading__c;
        appItemVm.msaSpeaking = appItem.MSA_Speaking__c;
        appItemVm.msaWriting = appItem.MSA_Writing__c;
        appItemVm.name = appItem.Name;
        appItemVm.nonSmoking = appItem.Prefers_Non_Smoking__c;
        appItemVm.offCampus = appItem.Prefers_Off_Campus__c;
        appItemVm.onCampus = appItem.Prefers_On_Campus__c;
        appItemVm.ongoingMedicalAttention = appItem.Ongoing_Medical_Attention__c;
        appItemVm.ongoingMedicalAttentionDescription = appItem.Ongoing_Medical_Attention_Description__c;
        appItemVm.other = appItem.Prefers_Other__c;
        appItemVm.otherMedicalData = appItem.Other_Medical_Data__c;
        appItemVm.otherMedicalDataDescription = appItem.Other_Medical_Data_Details__c;
        appItemVm.pAuralComprehension = appItem.P_Aural_Comprehension__c;
        appItemVm.pendingHomeInstitutionFinalApproval = appItem.Pending_Home_Institution_Final_Approval__c;
        appItemVm.phase = appItem.Phase__c;
        appItemVm.physActivityRestrictionsDescription = appItem.Phys_Activity_Restrictions_Description__c;
        appItemVm.physicalActivityRestrictions = appItem.Physical_Activity_Restrictions__c;
        appItemVm.pReading = appItem.P_Reading__c;
        appItemVm.privateBathroom = appItem.Prefers_Private_Bathroom__c;
        appItemVm.pSpeaking = appItem.P_Speaking__c;
        appItemVm.pWriting = appItem.P_Writing__c;
        appItemVm.recordType = appItem.RecordType.DeveloperName;
        appItemVm.regularlySpeak = appItem.Regularly_Speak__c;
        appItemVm.religiousAccomodations = appItem.Religious_Accomodations__c;
        appItemVm.requiredAcademicConditions = appItem.Required_Academic_Contitions__c;
        appItemVm.roommateRequests = appItem.Roommate_Requests__c;
        appItemVm.selfCatered = appItem.Prefers_Self_Catered__c;
        appItemVm.singleGender = appItem.Prefers_Single_Gender__c;
        appItemVm.singleRoom = appItem.Prefers_Single_Room__c;
        appItemVm.smoking = appItem.Prefers_Smoking__c;
        appItemVm.speaksArabic = appItem.Speaks_Arabic__c;
        appItemVm.speaksColloquialEgyptian = appItem.Speaks_Colloquial_Egyptian__c;
        appItemVm.speaksHebrew = appItem.Speaks_Hebrew__c;
        appItemVm.speaksPalestinian = appItem.Speaks_Palestinian__c;
        appItemVm.status = appItem.Status__c;
        appItemVm.textToSign = appItem.Text_to_Sign__c;
        appItemVm.typicalReaction = appItem.Typical_Reaction__c;
        appItemVm.universityCourses = appItem.University_Courses__c;
        appItemVm.vegan = appItem.Prefers_Vegan__c;
        appItemVm.vegetarian = appItem.Prefers_Vegetarian__c;
        appItemVm.ccParticipationOptions = apexConversionUtility.getPicklistStringValues(Application_Item__c.C_C_Participation__c);
        appItemVm.competencyOptions = apexConversionUtility.getPicklistStringValues(Application_Item__c.MSA_Reading__c);
        appItemVm.regularlySpeakOptions = apexConversionUtility.getPicklistStringValues(Application_Item__c.Regularly_Speak__c);
        appItemVm.willAttendReligiousService = appItem.Will_Attend_Religious_Service__c;
        appItemVm.personalInterests = appItem.Personal_Interests__c;
        appItemVm.musicPreferences = appItem.Music_Preferences__c;
        appItemVm.children = appItem.Prefers_Children__c;
        appItemVm.willHaveGroupTravel = appItem.Application__r.Program_Term__r.Arrival_Plan_Type__c;
        appItemVm.travelOptions = new List<String>();
        appItemVm.displaySignature = appItem.Display_Signature__c;
        appItemVm.isComplete = appItemVm.Status == 'Complete';
        appItemVm.learningPlanDisclosure = appItem.Learning_Plan_Disclosure__c;
        appItemVm.academicGoalsA = appItem.Learning_Plan_Academic_Goals_A_Long__c != null ? appItem.Learning_Plan_Academic_Goals_A_Long__c.replaceAll('<[^>]+>',' ') : null;
        appItemVm.academicGoalsB = appItem.Learning_Plan_Academic_Goals_B_Long__c != null ? appItem.Learning_Plan_Academic_Goals_B_Long__c.replaceAll('<[^>]+>',' ') : null;
        appItemVm.academicGoalsC = appItem.Learning_Plan_Academic_Goals_C_Long__c != null ? appItem.Learning_Plan_Academic_Goals_C_Long__c.replaceAll('<[^>]+>',' ') : null;
        appItemVm.personalGoalsA = appItem.Learning_Plan_Personal_Goals_A_Long__c != null ? appItem.Learning_Plan_Personal_Goals_A_Long__c.replaceAll('<[^>]+>',' ') : null;
        appItemVm.personalGoalsB = appItem.Learning_Plan_Personal_Goals_B_Long__c != null ? appItem.Learning_Plan_Personal_Goals_B_Long__c.replaceAll('<[^>]+>',' ') : null;
        appItemVm.personalGoalsC = appItem.Learning_Plan_Personal_Goals_C_Long__c != null ? appItem.Learning_Plan_Personal_Goals_C_Long__c.replaceAll('<[^>]+>',' ') : null;
        appItemVm.professionalGoalsA = appItem.LearningPlan_Professional_Goals_A_Long__c != null ? appItem.LearningPlan_Professional_Goals_A_Long__c.replaceAll('<[^>]+>',' ') : null;
        appItemVm.professionalGoalsB = appItem.LearningPlan_Professional_Goals_B_Long__c != null ? appItem.LearningPlan_Professional_Goals_B_Long__c.replaceAll('<[^>]+>',' ') : null;
        appItemVm.professionalGoalsC = appItem.LearningPlan_Professional_Goals_C_Long__c != null ? appItem.LearningPlan_Professional_Goals_C_Long__c.replaceAll('<[^>]+>',' ') : null;
        appItemVm.specificActions1 = appItem.Learning_Plan_Specific_Actions_1_Long__c != null ? appItem.Learning_Plan_Specific_Actions_1_Long__c.replaceAll('<[^>]+>',' ') : null;
        appItemVm.specificActions2 = appItem.Learning_Plan_Specific_Actions_2_Long__c != null ? appItem.Learning_Plan_Specific_Actions_2_Long__c.replaceAll('<[^>]+>',' ') : null;
        appItemVm.specificActions3 = appItem.Learning_Plan_Specific_Actions_3_Long__c != null ? appItem.Learning_Plan_Specific_Actions_3_Long__c.replaceAll('<[^>]+>',' ') : null;
        appItemVm.specificActions4 = appItem.Learning_Plan_Specific_Actions_4_Long__c != null ? appItem.Learning_Plan_Specific_Actions_4_Long__c.replaceAll('<[^>]+>',' ') : null;
        appItemVm.specificActions5 = appItem.Learning_Plan_Specific_Actions_5_Long__c != null ? appItem.Learning_Plan_Specific_Actions_5_Long__c.replaceAll('<[^>]+>',' ') : null;
        appItemVm.otherInformation = appItem.Learning_Plan_Other_Long__c != null ? appItem.Learning_Plan_Other_Long__c.replaceAll('<[^>]+>',' ') : null;

        return appItemVm;
    }

    /**
     * Completes an application item. Should only complete program approval, but the functionality is the same as the student portal version.
     * @param jsonData The app Item view model data as a JSON string.
     * @param fileData A Base-64 string of an attachment.
     * @param fileType A string indicating the type of file.
     * @param fileName The name of the file.
     * @return Boolean
     */
    @RemoteAction
    public static String submitApplicationItem(String jsonData, String fileData, String fileType, String fileName)
    {
        User advisorUser = [SELECT Id, Name, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        if(advisorUser.Name == 'Advisor Portal Site Guest User')
        {
            return 'ERROR: Your session has been corrupted, please log out and log back in to try again.';
        }
        //Convert the JSON string to a view model
        advisorStudentsAppItemViewModel viewModel = new advisorStudentsAppItemViewModel();

        if(jsonData == null)
        {
            return 'ERROR: You submission did not process correctly, please verify your responses and try again';
        }
        try
        {
            viewModel = (advisorStudentsAppItemViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('advisorStudentsAppItemViewModel'));
        }
        catch(Exception e)
        {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            return 'ERROR: You submission did not process correctly, please verify your responses and try again';
        }

        //Get all the application items for this application
        Application_Item__c appItem = (Application_Item__c) apexQueryUtility.selectAllFrom('Application_Item__c', 'Application__r.OwnerId, Application__r.Applicant__c' ,'Id = \'' + viewModel.id + '\'').get(0);

        //If the item is NOT a spanish evaluation mark as complete
        viewModel.status = viewModel.recordType == 'Spanish_Language_Evaluation' ? viewModel.status : 'Complete';

        Boolean attachmentSaved = true;

        //Save the file if not null
        if(fileData != null && fileType != null && fileData != '' && fileType != '')
        {
            try
            {
                String fileExtension = fileName.substringAfterLast('.');
                Attachment file = new Attachment(ParentId=viewModel.id, name=(viewModel.Name + '.' + fileExtension), ContentType=fileType, Body=EncodingUtil.base64Decode(fileData));
                attachmentSaved = Database.insert(file).isSuccess();
            }
            catch(Exception e)
            {
                System.debug(LoggingLevel.WARN, e.getMessage());
                return 'ERROR: You submission did not process correctly, please verify your responses and try again';
            }
        }       
    
        //Populate application item data from the view model
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
        appItem.Dietary_Restrictions__c = viewModel.dietaryRestrictions;
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
        appItem.Display_NonSmoking_Option__c = viewModel.displaynonsmoking == true;
        appItem.Display_Off_Campus_Option__c = viewModel.displayoffcampus == true;
        appItem.Display_On_Campus_Option__c = viewModel.displayoncampus == true;
        appItem.Display_Other__c = viewModel.displayother == true;
        appItem.Display_Private_Bathroom_Option__c = viewModel.displayprivatebathroom == true;
        appItem.Display_Religious_Accomodations__c = viewModel.displayReligiousAccomodations == true;
        appItem.Display_Roommate_Requests__c = viewModel.displayroommaterequests == true;
        appItem.Display_Self_Catered_Option__c = viewModel.displayselfcatered == true;
        appItem.Display_Single_Gender_Option__c = viewModel.displaysinglegender == true;
        appItem.Display_Single_Room_Option__c = viewModel.displaysingleroom == true;
        appItem.Display_Smoking_Option__c = viewModel.displaysmoking == true;
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
        appItem.Prefers_Non_Smoking__c = viewModel.nonSmoking == true;
        appItem.Prefers_Off_Campus__c = viewModel.offCampus == true;
        appItem.Prefers_On_Campus__c = viewModel.onCampus == true;
        appItem.Ongoing_Medical_Attention__c = viewModel.ongoingMedicalAttention == true;
        appItem.Ongoing_Medical_Attention_Description__c = viewModel.ongoingMedicalAttentionDescription;
        appItem.Prefers_Other__c = viewModel.other == true;
        appItem.Other_Medical_Data__c = viewModel.otherMedicalData == true;
        appItem.Other_Medical_Data_Details__c = viewModel.otherMedicalDataDescription;
        appItem.P_Aural_Comprehension__c = viewModel.pAuralComprehension;
        appItem.Pending_Home_Institution_Final_Approval__c = viewModel.pendingHomeInstitutionFinalApproval;
        appItem.Phase__c = viewModel.phase;
        appItem.Phys_Activity_Restrictions_Description__c = viewModel.physActivityRestrictionsDescription;
        appItem.Physical_Activity_Restrictions__c = viewModel.physicalActivityRestrictions == true;
        appItem.P_Reading__c = viewModel.pReading;
        appItem.Prefers_Private_Bathroom__c = viewModel.privateBathroom == true;
        appItem.P_Speaking__c = viewModel.pSpeaking;
        appItem.P_Writing__c = viewModel.pWriting;
        appItem.Regularly_Speak__c = viewModel.regularlySpeak;
        appItem.Religious_Accomodations__c = viewModel.religiousAccomodations;
        appItem.Required_Academic_Contitions__c = viewModel.requiredAcademicConditions;
        appItem.Roommate_Requests__c = viewModel.roommateRequests;
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
        appItem.Typical_Reaction__c = viewModel.typicalReaction;
        appItem.University_Courses__c = viewModel.universityCourses == true;
        appItem.Prefers_Vegan__c = viewModel.vegan == true;
        appItem.Prefers_Vegetarian__c = viewModel.vegetarian == true;
        appItem.Will_Attend_Religious_Service__c = viewModel.willAttendReligiousService == true;
        appItem.Personal_Interests__c = viewModel.personalInterests;
        appItem.Music_Preferences__c = viewModel.musicPreferences;
        appItem.Prefers_Children__c = viewModel.children == true;
        appItem.Completed_By__c = advisorUser.ContactId;                
        
        List<Task> relatedTasks = new List<Task>();
        programApprovalStatus pa;
        if(viewModel.RecordType == 'Program_Approval' && appItem.Status__c == 'Complete')
        {
            pa = setProgramApprovalStatus(appItem);
            ifsaApplicationWrapper appWrapper = new ifsaApplicationWrapper(appItem.Application__c);
            List<Application_Item__c> incompleteAppItems = [SELECT Id FROM Application_Item__c WHERE Application__c =: appItem.Application__c AND Status__c != 'Complete' AND Phase__c = 'Pre-Admit'];
            if(appItem.Phase__c == 'Pre-Admit' && ((incompleteAppItems.size() == 1 && incompleteAppItems.get(0).Id == appItem.Id) || incompleteAppItems.isEmpty()))            
            {
                portalRemotingMethods.closeCompletionNotification(appItem.Application__c);
            }
            else if(appItem.Phase__c == 'Pre-Acceptance')
            {
                // TODO This could be changed from a task to a custom notification if PA's start using Lightning
                Task approvalCompletedNotification = new Task(
                    Subject = 'Program Approval Completed', 
                    OwnerId = appWrapper.getOwnerId(),
                    Description = 'The program approval for ' + appItem.Applicant_Full_Name__c + ' has been completed by ' + advisorUser.Name,
                    WhoId = appWrapper.getApplicantId(), 
                    WhatId = appItem.Id
                );
                pa.tasks.add(approvalCompletedNotification);
            }
        }
        
        //Save
        Boolean isSaved = Database.update(pa.programApproval).isSuccess();
        if(isSaved)
        {
            Boolean needsSP = true;
            database.insert(pa.tasks);
            Application__c currentApp = [SELECT Id, Home_Institution_Advisor__c FROM Application__c WHERE Id =: appItem.Application__c].get(0);
            currentApp.Home_Institution_Advisor__c = advisorUser.ContactId;
            currentApp.Program_Approval_Completed_By__c = advisorUser.ContactId;

            Contact advisor = [SELECT Id, Emergency_Contact__c, Send_Marketing_Materials__c, AccountId, (SELECT Id, Support_Role_type__c FROM Support_Personnel__r) FROM Contact WHERE Id = :currentApp.Home_Institution_Advisor__c];
            
            for(Support_Personnel__c sp : advisor.Support_Personnel__r){
                if(sp.Support_Role_type__c == 'Advisor'){
                    needsSP = false;
                }
            }
            if(needsSp){
                Id spAccountRT = Schema.SObjectType.Support_Personnel__c.getRecordTypeInfosByName().get('Account').getRecordTypeId();
                Support_Personnel__c advisorSP = new Support_Personnel__c();
                advisorSP.Non_IFSA_Staff__c = advisor.Id;
                advisorSP.Emergency_Contact__c = advisor.Emergency_Contact__c;
                advisorSP.Type__c = 'Non IFSA Staff';
                advisorSP.Send_Marketing_Materials__c = advisor.Send_Marketing_Materials__c;
                advisorSP.Account__c = advisor.AccountId;
                advisorSP.Support_Role_Type__c = 'Advisor';
                advisorSP.RecordTypeId = spAccountRT;

                Database.insert(advisorSP);
            }

            Database.update(currentApp);
        }
        return isSaved && attachmentSaved ? 'Complete' : 'ERROR: You submission did not process correctly, please verify your responses and try again';
    }
    private static programApprovalStatus setProgramApprovalStatus(Application_Item__c appItem)
    {
        List<Task> approvalTasks = new List<Task>();
        Map<String, Id> taskOwnerMap = new Map<String, Id>{'AppOwner' => appItem.Application__r.OwnerId};
        Id simpleTaskRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Simple Task').getRecordTypeId();
        for(Group g: [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN ('Academic_Records','Health_Safety_Security')])
        {
            taskOwnerMap.put(g.DeveloperName, g.Id);
        }

        if(appItem.Good_Standing__c == 'No' || appItem.Approval_to_Study__c != 'Yes')
        {
            //Create task for PA to review
            Task goodStandingTask = new Task(WhoId = appItem.Application__r.Applicant__c, WhatId = appItem.Id, Subject = 'Review Program Approval');
            goodStandingTask.OwnerId = taskOwnerMap.get('AppOwner');
            appItem.PA_Following_Up__c = true;
            approvalTasks.add(goodStandingTask);
        }
        if(appItem.Academic_Probation__c == 'Yes')
        {
            //Create task for Academic records AD to review
            Task academicProbationTask = new Task(WhoId = appItem.Application__r.Applicant__c, WhatId = appItem.Id, Subject = 'Review Program Approval');
            academicProbationTask.OwnerId = taskOwnerMap.get('Academic_Records');
            appItem.AP_Following_Up__c = true;
            approvalTasks.add(academicProbationTask);           
        }
        if(appItem.Discipline__c == 'Yes')
        {
            //Create Task for Health and Safety AD to follow up
            Task disciplineTask = new Task(WhoId = appItem.Application__r.Applicant__c, WhatId = appItem.Id, Subject = 'Review Program Approval');          
            disciplineTask.OwnerId = taskOwnerMap.get('Health_Safety_Security');
            appItem.HS_Following_Up__c = true;
            approvalTasks.add(disciplineTask);
        }

        if(approvalTasks.isEmpty())
        {
            appItem.Approval_Status__c = 'No further action needed';
        }
        else
        {
            appItem.Approval_Status__c = 'Follow Up Needed';
        }

        programApprovalStatus pa = new programApprovalStatus(appItem, approvalTasks);
        return pa;
    }

    private class programApprovalStatus
    {
        public Application_Item__c programApproval {get;set;}
        public List<Task> tasks {get;set;}

        public programApprovalStatus(Application_Item__c item, List<Task> newTasks)
        {
            this.programApproval = item;
            tasks = newTasks;
        }
    }
    /**
     * Gets a list of student contacts at the advisor's institution with just the name field.
     * @param studentName
     * @return List<Contact>
     */
    @RemoteAction
    public static List<Contact> getStudentNames(String studentName)
    {
        Id accountId = [SELECT Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()].get(0).Contact.AccountId;
        System.Debug(accountId);
        studentName = studentName + '%';
        return [SELECT Name FROM Contact WHERE Home_Institution__r.Account__c =: accountId AND RecordType.Name = 'Student' AND Name LIKE: studentName];
    }
    // End Student Page
    // Start Institution Page
    /**
     * returns an <<advisorInstitutionViewModel>> object for the institution page
     * @return <<advisorInstitutionViewModel>>
     */
    @RemoteAction
    public static advisorInstitutionViewModel getInstitutionViewModel()
    {
        return new advisorInstitutionController().viewModel;
    }
    /**
     * Function used to add data to the view Model class.
     * @param homeInstitution String used to indicate the home Institution Id that we are using for search.
     * @param selectedCountry String that indicates the name of the country we are filtering on.
     * @param selectedTerm String that indicates the section we are using to filter terms - No Longer Used.
     * @param selectedYear String that indicates the year we are using to filter terms - No Longer Used.
     * @return List<Program_Authorization__c>
     */
    @RemoteAction
    public static List<model_program> getFilteredPrograms(String homeInstitution, String selectedCountry, String authType)
    {
        //If the home institution is null, we have no business here.
        if(homeInstitution == null)
        {
            return null;
        }
    
        Id homeInstitutionId = Id.valueOf(homeInstitution);
        System.debug('779 ' +[SELECT Account__c FROM Home_Institution__c WHERE Id =: homeInstitutionId]);
        Id homeAccountId = [SELECT Account__c FROM Home_Institution__c WHERE Id =: homeInstitutionId].get(0).Id;

        List<Program__c> progs = selectedCountry == 'All' ? [SELECT Id, Name, Host_Institution__c, Country__c, Country_Name__c, Locality__c FROM Program__c WHERE Category__c = 'Catalog' AND Active__c = TRUE AND (NOT(Name LIKE '%Undecided%'))] : [SELECT Id, Name, Host_Institution__c, Country__c, Country_Name__c, Locality__c FROM Program__c WHERE Category__c = 'Catalog' AND Active__c = TRUE AND Country_Name__c =: selectedCountry AND (NOT(Name LIKE '%Undecided%'))];
        if(progs.isEmpty())
        {
            return null;
        }
        Map<Id, model_program> programModelMap = model_program.modelMap(progs);
        
        //Get all the approved programs where the term matches up with our id list and the country name matches what we have (or no criteria if the selected country is all)
        String countryFilter = selectedCountry == 'All' ? '' : ' AND Program__r.Host_Institution__r.Country__r.Name = \'' + selectedCountry + '\'';
        Map<Id, model_programAuthorization> pAuths = new Map<Id, model_programAuthorization>();
        List<Program_Authorization__c> programAuthorization = apexQueryUtility.selectAllFrom('Program_Authorization__c','Program__r.Name, Program__r.Country__r.Name', 'Is_Active__c = TRUE AND Account__c = \'' + homeAccountId + '\' AND Program__c IN ' + apexQueryUtility.buildInClause(programModelMap.keyset()));
        
        for(Program_Authorization__c pAuth: programAuthorization)
        {
            programModelMap.get(pAuth.Program__c).activeProgramAuthorization =  new model_programAuthorization(pAuth);
        }
        List<Program_Term__c> programTerms = programTermService.getFutureCatalogProgramTerms(programModelMap.keyset());
        for(model_program prog: programModelMap.values())
        {
            model_programAuthorization pAuth = prog.activeProgramAuthorization;
            if(pAuth == null)
            {
                pAuth = new model_programAuthorization();
                pAuth.accountId = homeAccountId;
                pAuth.programId = prog.programId;
                pAuth.selectedTerms = '';
            }
            Set<String> availableTermsSet = new Set<String>();
            List<String> selectedTerms = new List<String>();
            for(Program_Term__c pt: programTerms)
            {
                if(pt.Program__c == pAuth.programId)
                {
                    switch on pt.Term__r.Section__c{
                        when 'Spring' {
                            pAuth.showSpringTerm = true;
                            availableTermsSet.add(pt.Term__r.Section__c);
                        }
                        when 'Fall'{
                            pAuth.showFallTerm = true;
                            availableTermsSet.add(pt.Term__r.Section__c);
                        }
                        when 'Summer' {
                            pAuth.showSummerTerm = true;
                            availableTermsSet.add(pt.Term__r.Section__c);
                        }
                        when 'Winter'{
                            pAuth.showWinterTerm = true;
                            availableTermsSet.add(pt.Term__r.Section__c);
                        }
                        when 'Academic Year' {
                            pAuth.showAcademicYear = true;
                            availableTermsSet.add(pt.Term__r.Section__c);
                        }
                        when 'Calendar Year'{
                            pAuth.showCalendarYear = true;
                            availableTermsSet.add(pt.Term__r.Section__c);
                        }
                    }
                }
            }
            pAuth.showNotApproved = true;
            availableTermsSet.add('Not Approved');
            Boolean isAuthorized = true;
            if(pAuth.selectedTerms == '' || pAuth.selectedTerms.contains('Not Approved'))
            {
                isAuthorized = false;
            }
            pAuth.availableTerms = new List<String>(availableTermsSet);
            if(pAuth.selectedTerms.contains('Spring'))
            {
                pAuth.springTerm = true;
                selectedTerms.add('Spring');
            }
            if(pAuth.selectedTerms.contains('Fall'))
            {
                pAuth.fallTerm = true;
                selectedTerms.add('Fall');
            }
            if(pAuth.selectedTerms.contains('Summer'))
            {
                pAuth.summerTerm = true;
                selectedTerms.add('Summer');
            }
            if(pAuth.selectedTerms.contains('Winter'))
            {
                pAuth.winterTerm = true;
                selectedTerms.add('Winter');
            }
            if(pAuth.selectedTerms.contains('Academic Year'))
            {
                pAuth.academicYear = true;
                selectedTerms.add('Academic Year');
            }
            if(pAuth.selectedTerms.contains('Calendar Year'))
            {
                pAuth.calendarYear = true;
                selectedTerms.add('Calendar Year');
            }
            if(pAuth.selectedTerms.contains('Not Approved'))
            {
                pAuth.notApproved = true;
                selectedTerms.add('Not Approved');
                isAuthorized = false;
            }
            
            pAuth.availableTerms.sort();
            selectedTerms.sort();
            if(selectedTerms == pAuth.availableTerms)
            {
                pAuth.selectAllAvalibleTerms = true;
            }
            System.debug(authType);
            System.debug(isAuthorized);
            if(authType == 'All' || (authType == 'Authorized' && isAuthorized) || (authType == 'Unauthorized' && !isAuthorized))
            {
                prog.activeProgramAuthorization = pAuth;
            }
            else
            {
                programModelMap.remove(pAuth.programId);
            }
        }
        
        return programModelMap.values();
    }

    /**
     * Get the billing details for the specified program and account
     * @param programId
     * @param accountId
     * @return List<model_billingArrangement>
     */
    @RemoteAction
    public static List<model_billingArrangement> getBillingArrangements(String programId, String accountId)
    {
        List<model_billingArrangement> listToReturn = new List<model_billingArrangement>();
        List<Program_Term__c> programTerms = [SELECT Id, Program__c, Term__r.Section__c FROM Program_Term__c WHERE Program__c =: programId AND Term__r.Year__c >=: Date.Today().year()];
        List<Billing_Arrangement__c> billingArrangments = apexQueryUtility.selectAllFrom('Billing_Arrangement__c', 'Program__r.Name', 'Program__c = \'' + programId + '\' AND Account__c = \'' + accountId + '\' AND Next__c = null');
        for (Billing_Arrangement__c ba: billingArrangments)
        {
            listToReturn.add(new model_billingArrangement(ba));
        }
        system.debug(listToReturn);
        return listToReturn;
    }

    /**
     * Saves the program authorization updates made by an adivsor in the Advisor Portal
     * @param jsonData
     * @return Boolean
     */
    @RemoteAction
    public static Boolean saveProgramAuthorizations(String jsonData)
    {
        List<model_programAuthorization> pAuths = model_programAuthorization.convertFromJsonToList(jsonData);

        return model_programAuthorization.saveList(pAuths);
    }

    /**
     * Authorizes all active catalog programs for the Host Institution
     * @param accountId
     * @return Id
     */
    @RemoteAction
    public static Id authorizeAllPrograms(String accountId)
    {   
        try
        {
            Account acct = new Account(
                Id = Id.valueOf(accountId), 
                Approves_All_Calendar_Programs__c = true,
                Approves_All_Summer_Programs__c = true,
                Approves_All_Winter_Programs__c = true
            );
            Database.update(acct);
            if(!Test.isRunningTest()){
                Id jobInfoId = [SELECT Id,Status,NumberOfErrors,CreatedDate FROM AsyncApexJob WHERE JobType='Queueable' AND CreatedById =: UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1].get(0).Id;
                return jobInfoId;
            }
            return accountId;
        }
        catch(Exception e)
        {
            return null;
        }       
    }

    /**
     * Retreives the status of an AsyncApexJob
     * @param jobId
     * @return AsyncApexJob
     */
    @RemoteAction
    public static AsyncApexJob checkJobStatus(string jobId)
    {
        return [SELECT Id,Status,NumberOfErrors,CreatedDate FROM AsyncApexJob WHERE Id =: jobId];
    }

    /**
     * Authorization function required to be implemented on every page. This action is called upon page load.
     * @return PageReference
     */
    public override virtual PageReference validateAccess()
    {
        //If the portal has been locked down redirect to message screen
        if(this.viewModel.isLockDownActive)
        {
            return new PageReference('/advisorportal/AP_PortalMessage');
        }
        // Otherwise run method in base class
        return super.validateAccess();
    }
    
    /**
     * Allows a head advisor to enable access for newly registered advisors.
     * @param targetId The user to approve.
     * @return Boolean
     */
    @RemoteAction
    public static Boolean approveUser(String targetId)
    {
        //If there isn't a target Id we have no business here
        if(targetId == null)
        {
            return false;
        }

        Id advisorId = Id.valueOf(targetId);

        //Get the advisor and set their approved flag to true
        Contact advisorContact = [SELECT Id, Name, Approved_For_Advising__c FROM Contact WHERE Id =: targetId];
        advisorContact.Approved_for_Advising__c = true;
    
        return Database.update(advisorContact).isSuccess();
    }
    
    /**
     * Allows a head advisor to completely disable access for newly registered advisors.
     * @param targetId The user to deny.
     * @return Boolean
     */
    @RemoteAction
    public static Boolean denyUser(String targetId)
    {
        //If there isn't a target Id we have no business here
        if(targetId == null)
        {
            return false;
        }
  
        Id advisorId = Id.valueOf(targetId);

        //Get the advisor and set their active flag to true
        User advisorUser = [SELECT Id, isActive, ContactId FROM User WHERE ContactId =: advisorId];
        advisorUser.IsActive = false;
    
        return Database.update(advisorUser).isSuccess();
    }
    // End Institution Page
    // Start Profile Page
    /**
     * returns an <<advisorProfileViewModel>> object for the institution page
     * @return <<advisorProfileViewModel>>
     */
    @RemoteAction
    public static advisorProfileViewModel getProfileViewModel()
    {
        return new advisorProfileController().viewModel;
    }
    
    /**
     * Function used to save changed data
     * @param jsonData JSON String representing the view model data.
     * @return Boolean
     */
    @RemoteAction
    public static Boolean saveData(String jsonData)
    {
        //try to coerce the json data into the view model, or fail
        advisorProfileViewModel viewModel;
        if(jsonData == null)
        {
            apexErrorUtility.debug(LoggingLevel.WARN, 'There was a null JSON String passed to the saveData method of the advisorProfileController.');
            return false;
        }
        try
        {
            viewModel = (advisorProfileViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('advisorProfileViewModel'));
        }
        catch(Exception e)
        {
            apexErrorUtility.throwException(new ifsaDataException('There was a problem coercing the JSON String into an instance of advisorProfileViewModel. The error: ' + e.getMessage()));
        }

        ifsaAdvisorWrapper advisor = new ifsaAdvisorWrapper(UserInfo.getUserId());
        return advisor.saveInformation(viewModel);
    }
    // End Profile Page
    
    // Start Advising Notes Page
    /**
     * Gets the user records for students at the advisor's institution who have saved notes from Global Wayfinder
     * @return List<User>
     */
    @RemoteAction
    public static List<User> getProspectiveStudents()
    {
        Id accountId = [SELECT Contact.AccountId FROM User WHERE Id =: userInfo.getUserId()].get(0).Contact.AccountId;
        if(accountId != null)
        {
            /* List<Toolbox_Notes__c> notes = [SELECT Id, User__r.Contact.Preferred_Name__c, User__r.Contact.LastName, User__r.Contact.Graduation_Year__c FROM Toolbox_Notes__c WHERE (Remove_Access_Advising_Topics__c = FALSE OR Remove_Access_Ifsa_Roadmap__c = FALSE) AND User__r.Contact.Home_Institution__r.Account__c = :accountId AND RecordType.Name IN ('My Advising Topics', 'My IFSA Roadmap')];
            return notes; */
            List<User> students = [SELECT Id, ContactId, Contact.FirstName, Contact.Preferred_Name__c, Contact.LastName, Contact.Graduation_Year__c FROM User WHERE Id IN (SELECT User__c FROM Toolbox_Notes__c WHERE ((Remove_Access_Advising_Topics__c = FALSE AND RecordType.Name = 'My Advising Topics') OR (Remove_Access_Ifsa_Roadmap__c = FALSE AND RecordType.Name = 'My IFSA Roadmap')) AND User__r.Contact.Home_Institution__r.Account__c = :accountId)];
            return students;
        }
        throw new advisorPortalException('Session has expired, please logout and log in to continue');
    }
    /**
     * Get advising notes that a specific student has saved and has allowed their home institution advisor to see
     * @param userId
     * @return List<Toolbox_Notes__c>
     */
    @RemoteAction
    public static List<Toolbox_Notes__c> getAdvisingNotes(String userId)
    {
        Id accountId = [SELECT Contact.AccountId FROM User WHERE Id =: userInfo.getUserId()].get(0).Contact.AccountId;
        if(accountId != null)
        {
            List<Toolbox_Notes__c> notes = [SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, LastModifiedDate FROM Toolbox_Notes__c WHERE User__c =: userId AND ((Remove_Access_Advising_Topics__c = FALSE AND RecordType.Name = 'My Advising Topics') OR (Remove_Access_Ifsa_Roadmap__c = FALSE AND RecordType.Name = 'My IFSA Roadmap')) AND User__r.Contact.Home_Institution__r.Account__c =: accountId];
            return notes;
        }
        throw new advisorPortalException('Session has expired, please logout and log in to continue');
    }

    // End Advising Notes Page

    // Start Advisor Resoures Page
    /**
     * Retrieves information about files that IFSA shares with it's advisor partners
     * @return Map<String, List<ContentDocument>>
     */
    @RemoteAction
    public static Map<String, List<ContentDocument>> getResourceFiles()
    {
        Id commDocLibId = [SELECT Id FROM Community_Document_Library__c WHERE Name = 'Advisor Portal'].get(0).Id;
        List<Id> linkIds = new List<Id>();
        for(ContentDocumentLink cdl: [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: commDocLibId])
        {
            linkIds.add(cdl.ContentDocumentId);
        }

        Map<String, List<ContentDocument>> results = new Map<String, List<ContentDocument>>();
        for(ContentDocument cd: [SELECT Id, Title, Description, ContentSize, FileType, FileExtension, LatestPublishedVersionId, LatestPublishedVersion.CreatedDate, LatestPublishedVersion.Advisor_Portal_Resource_Category__c FROM ContentDocument WHERE Id IN: linkIds AND LatestPublishedVersion.Advisor_Portal_Resource_Category__c != NULL ])
        {
            if(!results.containsKey(cd.LatestPublishedVersion.Advisor_Portal_Resource_Category__c))
            {
                results.put(cd.LatestPublishedVersion.Advisor_Portal_Resource_Category__c, new List<ContentDocument>());
            }
            results.get(cd.LatestPublishedVersion.Advisor_Portal_Resource_Category__c).add(cd);
        }
        
        return results;
    }
    
    // End Advisor Resources Page

    /**
     * an Exception class for <<advisorPortalController>>
     */
    public class advisorPortalException extends Exception {}

    // Start Combined Lead and Applicant Student Page

    @RemoteAction 
    public static advisorStudentHousingViewModel getHousingInfo(String appId)
    {
        Application__c app = [SELECT Id, Program_Term__c, Program_Term__r.Parent_Program_Term__c, Housing_Assignment__c FROM Application__c WHERE Id =: appId];
        List<Program_Term_Housing_Option__c> pthoptions = [SELECT Id, Housing_Option__c, Housing_Option__r.Name, Housing_Option__r.Description__c, Supplemental_Housing_Price__c FROM Program_Term_Housing_Option__c WHERE Program_Term__c =: app.Program_Term__c OR Program_Term__c =: app.Program_Term__r.Parent_Program_Term__c];
        // List<Housing_Option__c> options = [SELECT Id, Name, Description__c FROM Housing_Option__c WHERE Id IN (SELECT Housing_Option__c FROM Program_Term_Housing_Option__c WHERE Program_Term__c =: app.Program_Term__c OR Program_Term__c =: app.Program_Term__r.Parent_Program_Term__c)];
        Housing_Assignment__c assignment;
        try
        {
            assignment = [SELECT Id, Name, Description__c, Housing_Option__c, (SELECT Id FROM Attachments) FROM Housing_Assignment__c WHERE Id =: app.Housing_Assignment__c];
        }
        catch(Exception e)
        {

        }
        return new advisorStudentHousingViewModel(pthoptions, assignment);
    }

    @RemoteAction 
    public static List<CMS__c> getProgramCMS()
    {
        return apexQueryUtility.selectAllFrom('CMS__c', 'RecordType.Name = \'Program Data\'');
    }

    // End Combined Lead and Applicant Student Page

    public class advisorStudentAppViewModel
    {
        public List<Application_Item__c> appItems {get; private set;}
        public List<Course_Registration__c> classes {get; private set;}
        public String appId { get;private set; }
        public String ApplicantId { get;private set; }
        public String Name { get;private set; }
        public String Status { get;private set; }
        public String Program_Term_Name { get;private set; }
        public String Program_Country { get;private set; }
        public String Program_Term_Section { get;private set; }
        public String Program_Term_Year { get;private set; }
        public Date Application_Deadline { get;private set; }
        public Boolean Is_Custom { get;private set; }
        public String programApprovalStatus {get; private set;}
        public Date Grades_Submitted {get; private set;}
        public String Course_Load {get; private set;}
        public Boolean Course_Load_Approved_By_Resident_Staff {get; private set;}
        public Date Hold_Date {get; private set;}
        public Date Release_Date {get; private set;}
        public Date Host_Transcript_Received {get; private set;}
        public Date Butler_Transcript_Mailed {get; private set;}
        public Date Start_Date {get; private set;}
        public Date End_Date {get; private set;}
 ////added by powerfluence babish starts
        public Decimal Total_Credit {get; private set;}
 ////added by powerfluence babish ends
        public advisorStudentAppViewModel() {}
        public advisorStudentAppViewModel(Application__c app)
        {
            appItems = app.Application_Items__r;
            classes = app.Course_Registrations__r;
            appId = app.Id;
            ApplicantId = app.Applicant__c;
            Name = app.Name;
            Status = app.Status__c;
            Program_Term_Name = app.Program_Term__r.Name;
            Program_Country = app.Program_Country__c;
            Program_Term_Section = app.Program_Term_Section__c;
            Program_Term_Year = app.Program_Term_Year__c;
            Application_Deadline = app.Application_Deadline__c;
            Is_Custom = app.Is_Custom__c;
            Grades_Submitted = app.Grades_Submitted__c;
            Course_Load = app.Course_Load__c;
            Course_Load_Approved_By_Resident_Staff = app.Course_Load_Approved_By_Resident_Staff__c;
            Hold_Date = app.Hold_Date__c;
            Release_Date = app.Release_Date__c;
            Host_Transcript_Received = app.Host_Transcript_Received__c;
            Butler_Transcript_Mailed = app.Butler_Transcript_Mailed__c;
            Start_Date = app.Program_Term_Start_Date__c;
            End_Date = app.Program_Term_End_Date__c;
            ////added by powerfluence babish  starts
            
            Total_Credit =app.Total_US_Semester_Credit_Hours__c;

        
            ////added by powerfluence babish ends
          
            for(Application_Item__c ai: app.Application_Items__r)
            {
                if(ai.RecordType.Name == 'Program Approval')
                {
                    programApprovalStatus = ai.Status__c;
                    break;
                }
            }
             
        }
    }

    public class advisorStudentViewModel
    {
        public List<advisorStudentAppViewModel> applications {get; private set;}
        public List<Toolbox_Notes__c> toolBoxNotes {get; private set;}
        public List<Favorite_Program__c> favoritePrograms {get; private set;}
        public List<Saved_Searches__c> savedSearches {get; private set;}
        public Id StudentId {get; private set;}
        public String Name {get; private set;}
        public String FirstName {get; private set;}
        public String LastName {get; private set;}
        public String Preferred_Name {get; private set;}
        public String MailingStreet {get; private set;}
        public String MailingCity {get; private set;}
        public String MailingState {get; private set;}
        public String MailingPostalCode {get; private set;}
        public String MailingCountry {get; private set;}
        public String Email {get; private set;}
        public String Phone {get; private set;}
        public String Major_New {get; private set;}
        public Decimal GPA {get; private set;}
        public String Grade_Level {get; private set;}
        public Date Birthdate {get; private set;}
        public String Sex {get; private set;}
        public String Degree {get; private set;}

        public advisorStudentViewModel() {}

        public advisorStudentViewModel(Contact student)
        {
            toolBoxNotes = student.Toolbox_Notes__r;
            favoritePrograms = student.Favorite_Programs__r;
            savedSearches = student.Saved_Searches__r;
            StudentId = student.Id;
            Name = student.Name;
            FirstName = student.FirstName;
            LastName = student.LastName;
            Preferred_Name = student.Preferred_Name__c;
            MailingStreet = student.MailingStreet;
            MailingCity = student.MailingCity;
            MailingState = student.MailingState;
            MailingPostalCode = student.MailingPostalCode;
            MailingCountry = student.MailingCountry;
            Email = student.Email;
            Phone = student.Phone;
            Major_New = student.Major_New__c;
            GPA = student.GPA__c;
            Grade_Level = student.Grade_Level__c;
            Birthdate = student.Birthdate;
            Sex = student.Sex__c;
            Degree = student.Degree__c;
            this.applications = new List<advisorStudentAppViewModel>();
        }
    }

    public class advisorStudentHousingViewModel
    {
        List<Program_Term_Housing_Option__c> housingOptions {get; set;}
        Housing_Assignment__c housingAssignment {get; set;}

        public advisorStudentHousingViewModel() {}

        public advisorStudentHousingViewModel(List<Program_Term_Housing_Option__c> options, Housing_Assignment__c assignment)
        {
            housingOptions = options;
            housingAssignment = assignment;
        }
    }
    
    // added by Powerfluence team on 20-Aug-21
    
    
  @RemoteAction
    public static Integer getStudentsSearchCount(Id homeInstitutionId, String section, String year, String country, String status, Boolean onlyProgramApproval, String nameToSearch,String otherOptions)
    {

        String NameSearch1 = '%' + nameToSearch + '%';
        String section1 = '%' + section + '%';
        String year1 = '%' + year + '%';
        String country1 = '%' + country + '%';
        String status1 = '%' + status + '%';
        List<String> StatusValues = system.Label.AdvisorStudentStatus.Split(',');	
        List<advisorStudentViewModel> resultsq = new List<advisorStudentViewModel>();
        Map<Id, List<Application__c>> contactIdAppMap = new Map<Id, List<Application__c>>();
        String getVariablesCheck ='';
        String conQuery='';
        List<String> PendingApprovalStatus = system.Label.PendingApprovalStatus.Split(',');
     if( otherOptions == 'all' || otherOptions == '' || otherOptions==null)
	{
        if(section == '' && year == '' && country == ''  && status == ''  )
        { 
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
        GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
        (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
        (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
    FROM Contact WHERE  Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' AND (Contact_Source__c  ='Global Wayfinder' OR Contact_Source__c  ='Student Portal' OR (Contact_Source__c = 'CHART' AND (Number_of_applications__c !=0) AND Contact_Source__c = 'CHART' AND (Number_of_applications__c !=null)) OR (contact_source__C  ='' AND (Number_of_applications__c !=0) AND contact_source__C  ='' AND (Number_of_applications__c !=null))) Order by FirstName, LastName ]);
   
     //added Total_US_Semester_Credit_Hours__c by powerfluence based on req on 06/01/2022  
     for(Application__c app: [SELECT Id, Applicant__c, Name, Status__c, Program_Term__r.Name, Program_Country__c, Program_Term_Section__c, Program_Term_Year__c, Application_Deadline__c, Is_Custom__c, Grades_Submitted__c, Course_Load__c, Course_Load_Approved_By_Resident_Staff__c, Financial_Hold__c, Hold_Date__c, Release_Date__c, Host_Transcript_Received__c, Butler_Transcript_Mailed__c,Program_Term_Start_Date__c, Program_Term_End_Date__c,Total_US_Semester_Credit_Hours__c,
            (SELECT Id, Name, Status__c, RecordType.Name, RecordTypeId FROM Application_Items__r),
            (SELECT Id, Name, Course_Title__c, Host_Credits__c, Course__c, Course__r.Approved_for_CHART__c, Course__r.Course_Description__c, US_Semester_Credit_Hours__c, Course_Code__c, Status__c, Host_Institution__r.Name, Final_Grade__c FROM Course_Registrations__r WHERE Status__c IN ('Approval Pending','Approved','Grade Entered','Grade Verified','Grade Submitted','Grade Corrected','Course Omitted','Grade Revised','Ready for Butler','CIF - Submitted','CRF - Draft','Not Registered'))
        FROM Application__c WHERE Applicant__c IN:contactMap.Keyset() AND  (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1 Order by Name asc]) {
        
       
        if(!contactIdAppMap.containsKey(app.Applicant__c))
        {
            
            contactIdAppMap.put(app.Applicant__c, new List<Application__c>());
        }
        contactIdAppMap.get(app.Applicant__c).add(app);
    }

    for(Contact c: contactMap.values())
    {
        advisorStudentViewModel student = new advisorStudentViewModel(c);
        Boolean onlyCustom = false;
        if(contactIdAppMap.containsKey(c.Id))
        {
            onlyCustom = true;
            for(Application__c app: contactIdAppMap.get(c.Id))
            {
                //if(app.Is_Custom__c == false)
                //{
                    onlyCustom = false;
                    student.applications.add(new advisorStudentAppViewModel(app));
               // }                   
            }
       
            Boolean hasAnyApplication = (student.applications.size() > 0);
            Boolean haveNoApplication = (student.applications.size() == 0);
            if (
                   (
                    //    student.Grade_Level != null
                    // && 
                    hasAnyApplication 
                    ) 
                || (
                    //    student.Grade_Level == null
                    // && 
                    haveNoApplication)
                    )
             {
                    resultsq.add(student);
                
            }
    }
}
    Integer results = resultsq.size();
    return results;
    }
    else
    {
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
            GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
            (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
            (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
        FROM Contact WHERE Id in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' AND (Contact_Source__c  ='Student Portal' OR (Contact_Source__c = 'CHART' AND (Number_of_applications__c !=0) AND Contact_Source__c = 'CHART' AND (Number_of_applications__c !=null)) OR (contact_source__C  ='' AND (Number_of_applications__c !=0) AND contact_source__C  ='' AND (Number_of_applications__c !=null))) Order by FirstName, LastName]);
       
     //added Total_US_Semester_Credit_Hours__c by powerfluence based on req on 06/01/2022  
      for(Application__c app: [SELECT Id, Applicant__c, Name, Status__c, Program_Term__r.Name, Program_Country__c, Program_Term_Section__c, Program_Term_Year__c, Application_Deadline__c, Is_Custom__c, Grades_Submitted__c, Course_Load__c, Course_Load_Approved_By_Resident_Staff__c, Financial_Hold__c, Hold_Date__c, Release_Date__c, Host_Transcript_Received__c, Butler_Transcript_Mailed__c,Program_Term_Start_Date__c, Program_Term_End_Date__c,Total_US_Semester_Credit_Hours__c,
            (SELECT Id, Name, Status__c, RecordType.Name, RecordTypeId FROM Application_Items__r),
            (SELECT Id, Name, Course_Title__c, Host_Credits__c, Course__c, Course__r.Approved_for_CHART__c, Course__r.Course_Description__c, US_Semester_Credit_Hours__c, Course_Code__c, Status__c, Host_Institution__r.Name, Final_Grade__c FROM Course_Registrations__r WHERE Status__c IN ('Approval Pending','Approved','Grade Entered','Grade Verified','Grade Submitted','Grade Corrected','Course Omitted','Grade Revised','Ready for Butler','CIF - Submitted','CRF - Draft','Not Registered'))
        FROM Application__c WHERE Applicant__c IN:contactMap.Keyset() AND  (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1 Order by Name asc]) 
        {
           if(!contactIdAppMap.containsKey(app.Applicant__c))
            {
                contactIdAppMap.put(app.Applicant__c, new List<Application__c>());
            }
            contactIdAppMap.get(app.Applicant__c).add(app);
        }

    for(Contact c: contactMap.values())
    {
        advisorStudentViewModel student = new advisorStudentViewModel(c);
        Boolean onlyCustom = false;
        if(contactIdAppMap.containsKey(c.Id))
        {
            onlyCustom = true;
            for(Application__c app: contactIdAppMap.get(c.Id))
            {
                //if(app.Is_Custom__c == false)
                //{
                    onlyCustom = false;
                    student.applications.add(new advisorStudentAppViewModel(app));
                //}                   
            }
        }
        Boolean hasAnyApplication = (student.applications.size() > 0);
        Boolean haveNoApplication = (student.applications.size() == 0);
        if (
               (
                   student.Grade_Level != null
                && hasAnyApplication 
                ) 
            || (
                   student.Grade_Level == null
                && haveNoApplication)
                )
         {
                resultsq.add(student);
            
        }
    }
        //if(!onlyCustom){
          //  results.add(student);
        //}           
        Integer results = resultsq.size();
        return results;
    }
      
     }
else if(otherOptions == 'pending')
{
//application status = program selected, ready to submit, submitted, accepted, and accepted with conditions AND the program approval application item status = incomplete

        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, 
                (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
            FROM Contact WHERE Id  in (Select Applicant__c from Application__c where (Status__c IN: PendingApprovalStatus AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName ]);
         //added Total_US_Semester_Credit_Hours__c by powerfluence based on req on 06/01/2022  
          for(Application__c app: [SELECT Id, Applicant__c, Name, Status__c, Program_Term__r.Name, Program_Country__c, Program_Term_Section__c, Program_Term_Year__c, Application_Deadline__c, Is_Custom__c, Grades_Submitted__c, Course_Load__c, Course_Load_Approved_By_Resident_Staff__c, Financial_Hold__c, Hold_Date__c, Release_Date__c, Host_Transcript_Received__c, Butler_Transcript_Mailed__c,Program_Term_Start_Date__c, Program_Term_End_Date__c,Total_US_Semester_Credit_Hours__c,
                (SELECT Id, Name, Status__c, RecordType.Name, RecordTypeId FROM Application_Items__r WHERE Status__c = 'Incomplete' and RecordType.Name='Program Approval') ,
                (SELECT Id, Name, Course_Title__c, Host_Credits__c, Course__c, Course__r.Approved_for_CHART__c, Course__r.Course_Description__c, US_Semester_Credit_Hours__c, Course_Code__c, Status__c, Host_Institution__r.Name, Final_Grade__c FROM Course_Registrations__r WHERE Status__c IN ('Approval Pending','Approved','Grade Entered','Grade Verified','Grade Submitted','Grade Corrected','Course Omitted','Grade Revised','Ready for Butler','CIF - Submitted','CRF - Draft','Not Registered'))
            FROM Application__c WHERE id in (select application__c from application_item__C Where Status__c = 'Incomplete' and RecordType.Name='Program Approval') AND Applicant__c IN:contactMap.Keyset() AND  (Status__c LIKE : PendingApprovalStatus AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1 Order by Name asc]) {
            if(!contactIdAppMap.containsKey(app.Applicant__c))
            {
                
                contactIdAppMap.put(app.Applicant__c, new List<Application__c>());
            }
            contactIdAppMap.get(app.Applicant__c).add(app);
        }

        for(Contact c: contactMap.values())
        {
            advisorStudentViewModel student = new advisorStudentViewModel(c);
            Boolean onlyCustom = false;
            if(contactIdAppMap.containsKey(c.Id))
            {
                onlyCustom = true;
                for(Application__c app: contactIdAppMap.get(c.Id))
                {
                    // if(app.Is_Custom__c == false)
                    // {
                      
                        onlyCustom = false;
                        student.applications.add(new advisorStudentAppViewModel(app));
                    // }                   
                }
            Boolean hasAnyApplication = (student.applications.size() > 0);
            Boolean haveNoApplication = (student.applications.size() == 0);
            if (
                   (
                    //   student.Grade_Level != null
                     hasAnyApplication 
                    ) 
                || (
                    //   student.Grade_Level == null
                     haveNoApplication)
                    )
             {
                    resultsq.add(student);
                
            }
           // if(!onlyCustom){
            //     resultsq.add(student);
            // }           
           }         
        }
        system.debug('count method'+resultsq);
        Integer results = resultsq.size();

        return results;

}
else if ( otheroptions=='leads')
{
    Map<Id, Contact> contactMap = null;
    if(section == '' && year == '' && country == ''  && status == ''  )
    { 
        contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                      GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                      (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                      (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
                  FROM Contact WHERE contact_source__C  ='Global Wayfinder' AND Id not in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName ]);
    } else {
        contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                      GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                      (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                      (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
                  FROM Contact WHERE  contact_source__C  ='Global Wayfinder' AND contact_source__C  !='Global Wayfinder' AND Id in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName ]);
    }
            
         //added Total_US_Semester_Credit_Hours__c by powerfluence based on req on 06/01/2022  
          for(Application__c app: [SELECT Id, Applicant__c, Name, Status__c, Program_Term__r.Name, Program_Country__c, Program_Term_Section__c, Program_Term_Year__c, Application_Deadline__c, Is_Custom__c, Grades_Submitted__c, Course_Load__c, Course_Load_Approved_By_Resident_Staff__c, Financial_Hold__c, Hold_Date__c, Release_Date__c, Host_Transcript_Received__c, Butler_Transcript_Mailed__c,Program_Term_Start_Date__c, Program_Term_End_Date__c,Total_US_Semester_Credit_Hours__c,
                (SELECT Id, Name, Status__c, RecordType.Name, RecordTypeId FROM Application_Items__r),
                (SELECT Id, Name, Course_Title__c, Host_Credits__c, Course__c, Course__r.Approved_for_CHART__c, Course__r.Course_Description__c, US_Semester_Credit_Hours__c, Course_Code__c, Status__c, Host_Institution__r.Name, Final_Grade__c FROM Course_Registrations__r WHERE Status__c IN ('Approval Pending','Approved','Grade Entered','Grade Verified','Grade Submitted','Grade Corrected','Course Omitted','Grade Revised','Ready for Butler','CIF - Submitted','CRF - Draft','Not Registered'))
            FROM Application__c WHERE Applicant__c IN:contactMap.Keyset() AND  (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1 Order by Name asc]) {
            
            if(!contactIdAppMap.containsKey(app.Applicant__c))
            {
                contactIdAppMap.put(app.Applicant__c, new List<Application__c>());
            }
            contactIdAppMap.get(app.Applicant__c).add(app);
        }

        for(Contact c: contactMap.values())
        {
            advisorStudentViewModel student = new advisorStudentViewModel(c);
            Boolean onlyCustom = false;
            if(contactIdAppMap.containsKey(c.Id))
            {
                onlyCustom = true;
                for(Application__c app: contactIdAppMap.get(c.Id))
                {
                    // if(app.Is_Custom__c == false)
                    // {
                        onlyCustom = false;
                        student.applications.add(new advisorStudentAppViewModel(app));
                    // }                   
                }
            }
            Boolean hasAnyApplication = (student.applications.size() > 0);
            Boolean haveNoApplication = (student.applications.size() == 0);
            if (
                   (
                    //   student.Grade_Level == null
                     haveNoApplication)
                    )
             {
                    resultsq.add(student);
                
            }
            // if(!onlyCustom){
            //     resultsq.add(student);
            // }           
        }
        Integer results = resultsq.size();

        return results;
}
else if( otherOptions== 'searches')
{
    Map<Id, Contact> contactMap = null;
    if(section == '' && year == '' && country == ''  && status == ''  )
    { 
        contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
            FROM Contact WHERE contact_source__C  !='Global Wayfinder' AND Id in (Select Contact__C from Saved_Searches__C) AND Id not in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName ]);
        } else {
        contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
            FROM Contact WHERE contact_source__C  !='Global Wayfinder' AND contact_source__C  ='Global Wayfinder' AND  Id in (Select Contact__C from Saved_Searches__C) AND Id not in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName ]);
    }
            
         //added Total_US_Semester_Credit_Hours__c by powerfluence based on req on 06/01/2022  
          for(Application__c app: [SELECT Id, Applicant__c, Name, Status__c, Program_Term__r.Name, Program_Country__c, Program_Term_Section__c, Program_Term_Year__c, Application_Deadline__c, Is_Custom__c, Grades_Submitted__c, Course_Load__c, Course_Load_Approved_By_Resident_Staff__c, Financial_Hold__c, Hold_Date__c, Release_Date__c, Host_Transcript_Received__c, Butler_Transcript_Mailed__c,Program_Term_Start_Date__c, Program_Term_End_Date__c,Total_US_Semester_Credit_Hours__c,
                (SELECT Id, Name, Status__c, RecordType.Name, RecordTypeId FROM Application_Items__r),
                (SELECT Id, Name, Course_Title__c, Host_Credits__c, Course__c, Course__r.Approved_for_CHART__c, Course__r.Course_Description__c, US_Semester_Credit_Hours__c, Course_Code__c, Status__c, Host_Institution__r.Name, Final_Grade__c FROM Course_Registrations__r WHERE Status__c IN ('Approval Pending','Approved','Grade Entered','Grade Verified','Grade Submitted','Grade Corrected','Course Omitted','Grade Revised','Ready for Butler','CIF - Submitted','CRF - Draft','Not Registered'))
            FROM Application__c WHERE Applicant__c IN:contactMap.Keyset() AND  (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1 Order by Name asc]) {
            
            if(!contactIdAppMap.containsKey(app.Applicant__c))
            {
                contactIdAppMap.put(app.Applicant__c, new List<Application__c>());
            }
            contactIdAppMap.get(app.Applicant__c).add(app);
        }

        for(Contact c: contactMap.values())
        {
            advisorStudentViewModel student = new advisorStudentViewModel(c);
            Boolean onlyCustom = false;
            if(contactIdAppMap.containsKey(c.Id))
            {
                onlyCustom = true;
                for(Application__c app: contactIdAppMap.get(c.Id))
                {
                    // if(app.Is_Custom__c == false)
                    // {
                        onlyCustom = false;
                        student.applications.add(new advisorStudentAppViewModel(app));
                    // }                   
                }
            }
            Boolean hasAnyApplication = (student.applications.size() > 0);
            Boolean haveNoApplication = (student.applications.size() == 0);
            if (
                    (
                      // student.Grade_Level == null
                    haveNoApplication)
                    )
             {
                    resultsq.add(student);
                
            }
        //     if(!onlyCustom){
        //         resultsq.add(student);
        //     }           
        }
        Integer results = resultsq.size();

        return results;
}
else if( otherOptions== 'favorites')
{

    Map<Id, Contact> contactMap = null;
    if(section == '' && year == '' && country == ''  && status == ''  )
    { 
        contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                   GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                   (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                   (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
               FROM Contact WHERE contact_source__C  ='Global Wayfinder' AND Id in (Select Contact__C from Favorite_Program__C) AND Id not in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName ]);
    } else {
        contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                   GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                   (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                   (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
               FROM Contact WHERE contact_source__C  !='Global Wayfinder' AND contact_source__C  ='Global Wayfinder' AND  Id in (Select Contact__C from Favorite_Program__C) AND Id not in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName ]);
    }
            
         //added Total_US_Semester_Credit_Hours__c by powerfluence based on req on 06/01/2022  
          for(Application__c app: [SELECT Id, Applicant__c, Name, Status__c, Program_Term__r.Name, Program_Country__c, Program_Term_Section__c, Program_Term_Year__c, Application_Deadline__c, Is_Custom__c, Grades_Submitted__c, Course_Load__c, Course_Load_Approved_By_Resident_Staff__c, Financial_Hold__c, Hold_Date__c, Release_Date__c, Host_Transcript_Received__c, Butler_Transcript_Mailed__c,Program_Term_Start_Date__c, Program_Term_End_Date__c,Total_US_Semester_Credit_Hours__c,
                (SELECT Id, Name, Status__c, RecordType.Name, RecordTypeId FROM Application_Items__r),
                (SELECT Id, Name, Course_Title__c, Host_Credits__c, Course__c, Course__r.Approved_for_CHART__c, Course__r.Course_Description__c, US_Semester_Credit_Hours__c, Course_Code__c, Status__c, Host_Institution__r.Name, Final_Grade__c FROM Course_Registrations__r WHERE Status__c IN ('Approval Pending','Approved','Grade Entered','Grade Verified','Grade Submitted','Grade Corrected','Course Omitted','Grade Revised','Ready for Butler','CIF - Submitted','CRF - Draft','Not Registered'))
            FROM Application__c WHERE Applicant__c IN:contactMap.Keyset() AND  (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1 Order by Name asc]) {
            
            if(!contactIdAppMap.containsKey(app.Applicant__c))
            {
                contactIdAppMap.put(app.Applicant__c, new List<Application__c>());
            }
            contactIdAppMap.get(app.Applicant__c).add(app);
        }

        for(Contact c: contactMap.values())
        {
            advisorStudentViewModel student = new advisorStudentViewModel(c);
            Boolean onlyCustom = false;
            if(contactIdAppMap.containsKey(c.Id))
            {
                onlyCustom = true;
                for(Application__c app: contactIdAppMap.get(c.Id))
                {
                    // if(app.Is_Custom__c == false)
                    // {
                        onlyCustom = false;
                        student.applications.add(new advisorStudentAppViewModel(app));
                    // }                   
                }
            }
            Boolean hasAnyApplication = (student.applications.size() > 0);
            Boolean haveNoApplication = (student.applications.size() == 0);
            if (
                   (
                    //   student.Grade_Level == null
                     haveNoApplication)
                    )
             {
                    resultsq.add(student);
                
            }
            // if(!onlyCustom){
            //     resultsq.add(student);
            // }           
        }
        Integer results = resultsq.size();
        
        return results;
}
else if(otherOptions == 'notes')
{
  
    Map<Id, Contact> contactMap = null;
    if(section == '' && year == '' && country == ''  && status == ''  )
    { 
        contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                   GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                   (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                   (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
               FROM Contact WHERE contact_source__C  ='Global Wayfinder' AND Id in (Select Contact__C from Toolbox_Notes__C) AND  Id not in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName ]);
    } else {
        contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                   GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                   (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                   (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
               FROM Contact WHERE contact_source__C  !='Global Wayfinder' AND contact_source__C  ='Global Wayfinder' AND  Id in (Select Contact__C from Toolbox_Notes__C) AND  Id not in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName ]);
    }
            
         //added Total_US_Semester_Credit_Hours__c by powerfluence based on req on 06/01/2022   
         for(Application__c app: [SELECT Id, Applicant__c, Name, Status__c, Program_Term__r.Name, Program_Country__c, Program_Term_Section__c, Program_Term_Year__c, Application_Deadline__c, Is_Custom__c, Grades_Submitted__c, Course_Load__c, Course_Load_Approved_By_Resident_Staff__c, Financial_Hold__c, Hold_Date__c, Release_Date__c, Host_Transcript_Received__c, Butler_Transcript_Mailed__c,Program_Term_Start_Date__c, Program_Term_End_Date__c,Total_US_Semester_Credit_Hours__c,
                (SELECT Id, Name, Status__c, RecordType.Name, RecordTypeId FROM Application_Items__r),
                (SELECT Id, Name, Course_Title__c, Host_Credits__c, Course__c, Course__r.Approved_for_CHART__c, Course__r.Course_Description__c, US_Semester_Credit_Hours__c, Course_Code__c, Status__c, Host_Institution__r.Name, Final_Grade__c FROM Course_Registrations__r WHERE Status__c IN ('Approval Pending','Approved','Grade Entered','Grade Verified','Grade Submitted','Grade Corrected','Course Omitted','Grade Revised','Ready for Butler','CIF - Submitted','CRF - Draft','Not Registered'))
            FROM Application__c WHERE Applicant__c IN:contactMap.Keyset() AND  (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1 Order by Name asc]) {
            
            if(!contactIdAppMap.containsKey(app.Applicant__c))
            {
                contactIdAppMap.put(app.Applicant__c, new List<Application__c>());
            }
            contactIdAppMap.get(app.Applicant__c).add(app);
        }

        for(Contact c: contactMap.values())
        {
            advisorStudentViewModel student = new advisorStudentViewModel(c);
            Boolean onlyCustom = false;
            if(contactIdAppMap.containsKey(c.Id))
            {
                onlyCustom = true;
                for(Application__c app: contactIdAppMap.get(c.Id))
                {
                    // if(app.Is_Custom__c == false)
                    // {
                        onlyCustom = false;
                        student.applications.add(new advisorStudentAppViewModel(app));
                    // }                   
                }
            }
            Boolean hasAnyApplication = (student.applications.size() > 0);
            Boolean haveNoApplication = (student.applications.size() == 0);
            if (
                   (
                    //   student.Grade_Level == null
                     haveNoApplication)
                    )
             {
                    resultsq.add(student);
                
            }
            // if(!onlyCustom){
            //     resultsq.add(student);
            // }           
        }
        Integer results = resultsq.size();
        return results;
} 
Integer results = resultsq.size();
return results;
    }
    
    @RemoteAction
    public static List<advisorStudentViewModel> getStudentsSearch(Id homeInstitutionId, String section, String year, String country, String status, Boolean onlyProgramApproval, String nameToSearch,Integer currentPage,Integer pageSize, String otherOptions)
    {

        String NameSearch1 = '%' + nameToSearch + '%';
        String section1 = '%' + section + '%';
        String year1 = '%' + year + '%';
        String country1 = '%' + country + '%';
        String status1 = '%' + status + '%';
        List<String> StatusValues = system.Label.AdvisorStudentStatus.Split(',');	
        List<advisorStudentViewModel> results = new List<advisorStudentViewModel>();
        Map<Id, List<Application__c>> contactIdAppMap = new Map<Id, List<Application__c>>();
        String getVariablesCheck ='';
        String conQuery='';
        List<String> PendingApprovalStatus = system.Label.PendingApprovalStatus.Split(',');
     if( otherOptions == 'all' || otherOptions == '' || otherOptions==null)
	{
        if(section == '' && year == '' && country == ''  && status == ''  )
        {
            Integer currentPageIncr = (currentPage+1);
            Integer offSetPageSize = (currentPageIncr*pageSize)-pageSize;
            Integer recordCount = 0;
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
            GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
            (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
            (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
        FROM Contact WHERE  Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' AND (Contact_Source__c  ='Global Wayfinder' OR Contact_Source__c  ='Student Portal' OR (Contact_Source__c = 'CHART' AND (Number_of_applications__c !=0) AND Contact_Source__c = 'CHART' AND (Number_of_applications__c !=null)) OR (contact_source__C  ='' AND (Number_of_applications__c !=0) AND contact_source__C  ='' AND (Number_of_applications__c !=null))) Order by FirstName, LastName /*Limit :pageSize OFFSET :offSetPageSize*/]);
       
         //added Total_US_Semester_Credit_Hours__c by powerfluence based on req on 06/01/2022  
          for(Application__c app: [SELECT Id, Applicant__c, Name, Status__c, Program_Term__r.Name, Program_Country__c, Program_Term_Section__c, Program_Term_Year__c, Application_Deadline__c, Is_Custom__c, Grades_Submitted__c, Course_Load__c, Course_Load_Approved_By_Resident_Staff__c, Financial_Hold__c, Hold_Date__c, Release_Date__c, Host_Transcript_Received__c, Butler_Transcript_Mailed__c,Program_Term_Start_Date__c, Program_Term_End_Date__c,Total_US_Semester_Credit_Hours__c,
                (SELECT Id, Name, Status__c, RecordType.Name, RecordTypeId FROM Application_Items__r),
                (SELECT Id, Name, Course_Title__c, Host_Credits__c, Course__c, Course__r.Approved_for_CHART__c, Course__r.Course_Description__c, US_Semester_Credit_Hours__c, Course_Code__c, Status__c, Host_Institution__r.Name, Final_Grade__c FROM Course_Registrations__r WHERE Status__c IN ('Approval Pending','Approved','Grade Entered','Grade Verified','Grade Submitted','Grade Corrected','Course Omitted','Grade Revised','Ready for Butler','CIF - Submitted','CRF - Draft','Not Registered'))
            FROM Application__c WHERE Applicant__c IN:contactMap.Keyset() AND  (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1 Order by Name asc]) {
            
           
            if(!contactIdAppMap.containsKey(app.Applicant__c))
            {
                
                contactIdAppMap.put(app.Applicant__c, new List<Application__c>());
            }
            contactIdAppMap.get(app.Applicant__c).add(app);
        }

        for(Contact c: contactMap.values())
        {
            advisorStudentViewModel student = new advisorStudentViewModel(c);
            Boolean onlyCustom = false;
            if(contactIdAppMap.containsKey(c.Id))
            {
                onlyCustom = true;
                for(Application__c app: contactIdAppMap.get(c.Id))
                {
                    //if(app.Is_Custom__c == false)
                    //{
                        onlyCustom = false;
                        student.applications.add(new advisorStudentAppViewModel(app));
                   // }                   
                }
            
            // Powerfluence Team
            // Date of Modification 09/30/2021
            //if(!onlyCustom){
            Boolean hasAnyApplication = (student.applications.size() > 0);
            Boolean haveNoApplication = (student.applications.size() == 0);
            if (
                   (
                       // student.Grade_Level != null
                    // && 
                    hasAnyApplication 
                    ) 
                || (
                       // student.Grade_Level == null
                    // && 
                    haveNoApplication)
                    )
             {
                 recordCount += 1;
                 if (recordCount > offSetPageSize)
                 {
                    results.add(student);
                 }
                 if (results.size() == pageSize)
                 {
                     break; // for loop
                 }
                
            }
        }
    }
        return results;
        }
        else
        {
            Integer currentPageIncr = (currentPage+1);
            Integer offSetPageSize = (currentPageIncr*pageSize)-pageSize;  
            Integer recordCount = 0;
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
            FROM Contact WHERE Id in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' AND (Contact_Source__c  ='Student Portal' OR (Contact_Source__c = 'Global Wayfinder' AND (Number_of_applications__c !=0)) OR (Contact_Source__c = 'CHART' AND (Number_of_applications__c !=0) AND Contact_Source__c = 'CHART' AND (Number_of_applications__c !=null)) OR (contact_source__C  ='' AND (Number_of_applications__c !=0) AND contact_source__C  ='' AND (Number_of_applications__c !=null))) Order by FirstName, LastName /*Limit :pageSize OFFSET :offSetPageSize*/]);
           
         //added Total_US_Semester_Credit_Hours__c by powerfluence based on req on 06/01/2022  
          for(Application__c app: [SELECT Id, Applicant__c, Name, Status__c, Program_Term__r.Name, Program_Country__c, Program_Term_Section__c, Program_Term_Year__c, Application_Deadline__c, Is_Custom__c, Grades_Submitted__c, Course_Load__c, Course_Load_Approved_By_Resident_Staff__c, Financial_Hold__c, Hold_Date__c, Release_Date__c, Host_Transcript_Received__c, Butler_Transcript_Mailed__c,Program_Term_Start_Date__c, Program_Term_End_Date__c,Total_US_Semester_Credit_Hours__c,
                (SELECT Id, Name, Status__c, RecordType.Name, RecordTypeId FROM Application_Items__r),
                (SELECT Id, Name, Course_Title__c, Host_Credits__c, Course__c, Course__r.Approved_for_CHART__c, Course__r.Course_Description__c, US_Semester_Credit_Hours__c, Course_Code__c, Status__c, Host_Institution__r.Name, Final_Grade__c FROM Course_Registrations__r WHERE Status__c IN ('Approval Pending','Approved','Grade Entered','Grade Verified','Grade Submitted','Grade Corrected','Course Omitted','Grade Revised','Ready for Butler','CIF - Submitted','CRF - Draft','Not Registered'))
            FROM Application__c WHERE Applicant__c IN:contactMap.Keyset() AND  (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1 Order by Name asc]) 
            {
               if(!contactIdAppMap.containsKey(app.Applicant__c))
                {
                    contactIdAppMap.put(app.Applicant__c, new List<Application__c>());
                }
                contactIdAppMap.get(app.Applicant__c).add(app);
            }

        for(Contact c: contactMap.values())
        {
            advisorStudentViewModel student = new advisorStudentViewModel(c);
            Boolean onlyCustom = false;
            if(contactIdAppMap.containsKey(c.Id))
            {
                onlyCustom = true;
                for(Application__c app: contactIdAppMap.get(c.Id))
                {
                    //if(app.Is_Custom__c == false)
                    //{
                        onlyCustom = false;
                        student.applications.add(new advisorStudentAppViewModel(app));
                    //}                   
                }
            }
            Boolean hasAnyApplication = (student.applications.size() > 0);
            Boolean haveNoApplication = (student.applications.size() == 0);
            if (
                   (
                       // student.Grade_Level != null
                    // && 
                    hasAnyApplication 
                    ) 
                || (
                       // student.Grade_Level == null
                    // && 
                    haveNoApplication)
                    )
             {
                 recordCount += 1;
                 if (recordCount > offSetPageSize)
                 {
                   	
                    results.add(student);
                 }
                 if (results.size() == pageSize)
                 {
                     break; // for loop
                 }
                
            }
        }
            //if(!onlyCustom){
              //  results.add(student);
            //}           
        
            return results;
        }
        
}
else if(otherOptions == 'pending')
{
        //application status = program selected, ready to submit, submitted, accepted, and accepted with conditions AND the program approval application item status = incomplete
        Integer currentPageIncr = (currentPage+1);
        Integer offSetPageSize = (currentPageIncr*pageSize)-pageSize;
        Integer recordCount = 0;
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, 
                (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
            FROM Contact WHERE Id  in (Select Applicant__c from Application__c where (Status__c IN: PendingApprovalStatus AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName /*Limit :pageSize OFFSET :offSetPageSize*/]);
    
    		
    
         //added Total_US_Semester_Credit_Hours__c by powerfluence based on req on 06/01/2022  
          for(Application__c app: [SELECT Id, Applicant__c, Name, Status__c, Program_Term__r.Name, Program_Country__c, Program_Term_Section__c, Program_Term_Year__c, Application_Deadline__c, Is_Custom__c, Grades_Submitted__c, Course_Load__c, Course_Load_Approved_By_Resident_Staff__c, Financial_Hold__c, Hold_Date__c, Release_Date__c, Host_Transcript_Received__c, Butler_Transcript_Mailed__c,Program_Term_Start_Date__c, Program_Term_End_Date__c,Total_US_Semester_Credit_Hours__c,
                (SELECT Id, Name, Status__c, RecordType.Name, RecordTypeId FROM Application_Items__r WHERE  Status__c = 'Incomplete' and RecordType.Name='Program Approval') ,
                (SELECT Id, Name, Course_Title__c, Host_Credits__c, Course__c, Course__r.Approved_for_CHART__c, Course__r.Course_Description__c, US_Semester_Credit_Hours__c, Course_Code__c, Status__c, Host_Institution__r.Name, Final_Grade__c FROM Course_Registrations__r WHERE Status__c IN ('Approval Pending','Approved','Grade Entered','Grade Verified','Grade Submitted','Grade Corrected','Course Omitted','Grade Revised','Ready for Butler','CIF - Submitted','CRF - Draft','Not Registered'))
            FROM Application__c WHERE id in (select application__c from application_item__C Where Status__c = 'Incomplete' and RecordType.Name='Program Approval') AND Applicant__c IN:contactMap.Keyset() AND  (Status__c LIKE : PendingApprovalStatus AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1 Order by Name asc]) {
            
             
                
            if(!contactIdAppMap.containsKey(app.Applicant__c))
            {
                contactIdAppMap.put(app.Applicant__c, new List<Application__c>());
            }
            contactIdAppMap.get(app.Applicant__c).add(app);
        }

        for(Contact c: contactMap.values())
        {
            advisorStudentViewModel student = new advisorStudentViewModel(c);
            Boolean onlyCustom = false;
            if(contactIdAppMap.containsKey(c.Id))
            {
                onlyCustom = true;
                for(Application__c app: contactIdAppMap.get(c.Id))
                {
                    // if(app.Is_Custom__c == false)
                    // {
                        onlyCustom = false;                        
                        student.applications.add(new advisorStudentAppViewModel(app));
                    // }                   
                }
           
                Boolean hasAnyApplication = (student.applications.size() > 0);
                Boolean haveNoApplication = (student.applications.size() == 0);
                if (
                       (
                           //student.Grade_Level != null
                         hasAnyApplication 
                        ) 
                    || (
                        //   student.Grade_Level == null
                         haveNoApplication)
                        )
                 {
                     recordCount += 1;
                     system.debug('details method'+student);
                     system.debug('recordCount'+recordCount);
                     if (recordCount > offSetPageSize)
                     {
                        results.add(student);
                     }
                     if (results.size() == pageSize)
                     {
                         break; // for loop
                     }
                    
                }
               // if(!onlyCustom){
                //     results.add(student);
                // }           
    
         }             
        }
        return results;

}
else if ( otheroptions=='leads')
{
    Integer currentPageIncr = (currentPage+1);
    Integer offSetPageSize = (currentPageIncr*pageSize)-pageSize;
    Integer recordCount = 0;
    Map<Id, Contact> contactMap = null;
    if(section == '' && year == '' && country == ''  && status == ''  )
    {
        contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                    GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                    (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                    (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
                FROM Contact WHERE contact_source__C  ='Global Wayfinder' AND Id NOT IN (Select Applicant__c from Application__c) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName /* Limit :pageSize OFFSET :offSetPageSize */ ]);
    } else {
        contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                    GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                    (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                    (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
                FROM Contact WHERE contact_source__C  ='Global Wayfinder' AND contact_source__C  !='Global Wayfinder' AND  Id IN (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName /* Limit :pageSize OFFSET :offSetPageSize */ ]);
    }
         //added Total_US_Semester_Credit_Hours__c by powerfluence based on req on 06/01/2022  
          for(Application__c app: [SELECT Id, Applicant__c, Name, Status__c, Program_Term__r.Name, Program_Country__c, Program_Term_Section__c, Program_Term_Year__c, Application_Deadline__c, Is_Custom__c, Grades_Submitted__c, Course_Load__c, Course_Load_Approved_By_Resident_Staff__c, Financial_Hold__c, Hold_Date__c, Release_Date__c, Host_Transcript_Received__c, Butler_Transcript_Mailed__c,Program_Term_Start_Date__c, Program_Term_End_Date__c,Total_US_Semester_Credit_Hours__c,
                (SELECT Id, Name, Status__c, RecordType.Name, RecordTypeId FROM Application_Items__r),
                (SELECT Id, Name, Course_Title__c, Host_Credits__c, Course__c, Course__r.Approved_for_CHART__c, Course__r.Course_Description__c, US_Semester_Credit_Hours__c, Course_Code__c, Status__c, Host_Institution__r.Name, Final_Grade__c FROM Course_Registrations__r WHERE Status__c IN ('Approval Pending','Approved','Grade Entered','Grade Verified','Grade Submitted','Grade Corrected','Course Omitted','Grade Revised','Ready for Butler','CIF - Submitted','CRF - Draft','Not Registered'))
            FROM Application__c WHERE Applicant__c IN:contactMap.Keyset() AND  (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1 Order by Name asc]) {
            
            if(!contactIdAppMap.containsKey(app.Applicant__c))
            {
                contactIdAppMap.put(app.Applicant__c, new List<Application__c>());
            }
            contactIdAppMap.get(app.Applicant__c).add(app);
        }

        for(Contact c: contactMap.values())
        {
            advisorStudentViewModel student = new advisorStudentViewModel(c);
            Boolean onlyCustom = false;
            if(contactIdAppMap.containsKey(c.Id))
            {
                onlyCustom = true;
                for(Application__c app: contactIdAppMap.get(c.Id))
                {
                    // if(app.Is_Custom__c == false)
                    // {
                    //     onlyCustom = false;
                        student.applications.add(new advisorStudentAppViewModel(app));
                    // }                   
                }
            }
            Boolean hasAnyApplication = (student.applications.size() > 0);
            Boolean haveNoApplication = (student.applications.size() == 0);
            if (
                 (
                    // student.Grade_Level == null
                   haveNoApplication)
                  )
             {
                 recordCount += 1;
                 if (recordCount > offSetPageSize)
                 {
                    results.add(student);
                 }
                 if (results.size() == pageSize)
                 {
                     break; // for loop
                 }
                
            }
           // if(!onlyCustom){
            //     results.add(student);
            // }           
        }
        return results;
}
else if( otherOptions== 'searches')
{
    Integer currentPageIncr = (currentPage+1);
    Integer offSetPageSize = (currentPageIncr*pageSize)-pageSize;
    Integer recordCount = 0;
    Map<Id, Contact> contactMap = null;
    if(section == '' && year == '' && country == ''  && status == ''  )
    {
        contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                    GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                    (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                    (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
                FROM Contact WHERE contact_source__C  ='Global Wayfinder' AND Id in (Select Contact__C from Saved_Searches__C) AND Id not in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName /*Limit :pageSize OFFSET :offSetPageSize*/]);
    } else {
        contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                    GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                    (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                    (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
                FROM Contact WHERE contact_source__C  !='Global Wayfinder' AND  contact_source__C  ='Global Wayfinder' AND  Id in (Select Contact__C from Saved_Searches__C) AND Id not in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName /*Limit :pageSize OFFSET :offSetPageSize*/]);
    }
         //added Total_US_Semester_Credit_Hours__c by powerfluence based on req on 06/01/2022   
         for(Application__c app: [SELECT Id, Applicant__c, Name, Status__c, Program_Term__r.Name, Program_Country__c, Program_Term_Section__c, Program_Term_Year__c, Application_Deadline__c, Is_Custom__c, Grades_Submitted__c, Course_Load__c, Course_Load_Approved_By_Resident_Staff__c, Financial_Hold__c, Hold_Date__c, Release_Date__c, Host_Transcript_Received__c, Butler_Transcript_Mailed__c,Program_Term_Start_Date__c, Program_Term_End_Date__c,Total_US_Semester_Credit_Hours__c,
                (SELECT Id, Name, Status__c, RecordType.Name, RecordTypeId FROM Application_Items__r),
                (SELECT Id, Name, Course_Title__c, Host_Credits__c, Course__c, Course__r.Approved_for_CHART__c, Course__r.Course_Description__c, US_Semester_Credit_Hours__c, Course_Code__c, Status__c, Host_Institution__r.Name, Final_Grade__c FROM Course_Registrations__r WHERE Status__c IN ('Approval Pending','Approved','Grade Entered','Grade Verified','Grade Submitted','Grade Corrected','Course Omitted','Grade Revised','Ready for Butler','CIF - Submitted','CRF - Draft','Not Registered'))
            FROM Application__c WHERE Applicant__c IN:contactMap.Keyset() AND  (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1 Order by Name asc]) {
            
            if(!contactIdAppMap.containsKey(app.Applicant__c))
            {
                contactIdAppMap.put(app.Applicant__c, new List<Application__c>());
            }
            contactIdAppMap.get(app.Applicant__c).add(app);
        }

        for(Contact c: contactMap.values())
        {
            advisorStudentViewModel student = new advisorStudentViewModel(c);
            Boolean onlyCustom = false;
            if(contactIdAppMap.containsKey(c.Id))
            {
                onlyCustom = true;
                for(Application__c app: contactIdAppMap.get(c.Id))
                {
                    // if(app.Is_Custom__c == false)
                    // {
                        onlyCustom = false;
                        student.applications.add(new advisorStudentAppViewModel(app));
                    // }                   
                }
            }
            Boolean hasAnyApplication = (student.applications.size() > 0);
            Boolean haveNoApplication = (student.applications.size() == 0);
            if (
                (
                 //   student.Grade_Level == null
                  haveNoApplication)
                )
             {
                 recordCount += 1;
                 if (recordCount > offSetPageSize)
                 {
                    results.add(student);
                 }
                 if (results.size() == pageSize)
                 {
                     break; // for loop
                 }
                
            }
           // if(!onlyCustom){
            //     results.add(student);
            // }           

        }
        return results;
}
else if( otherOptions== 'favorites')
{
    Integer currentPageIncr = (currentPage+1);
    Integer offSetPageSize = (currentPageIncr*pageSize)-pageSize;
    Integer recordCount = 0;
    Map<Id, Contact> contactMap = null;
    if(section == '' && year == '' && country == ''  && status == ''  )
    {
        contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                    GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                    (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                    (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
                FROM Contact WHERE contact_source__C  ='Global Wayfinder' AND Id in (Select Contact__C from Favorite_Program__C) AND Id not in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName /*Limit :pageSize OFFSET :offSetPageSize*/]);
    } else {
        contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                    GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                    (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                    (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
                FROM Contact WHERE contact_source__C  !='Global Wayfinder' AND contact_source__C  ='Global Wayfinder' AND  Id in (Select Contact__C from Favorite_Program__C) AND Id not in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName /*Limit :pageSize OFFSET :offSetPageSize*/]);
    }
         //added Total_US_Semester_Credit_Hours__c by powerfluence based on req on 06/01/2022  
          for(Application__c app: [SELECT Id, Applicant__c, Name, Status__c, Program_Term__r.Name, Program_Country__c, Program_Term_Section__c, Program_Term_Year__c, Application_Deadline__c, Is_Custom__c, Grades_Submitted__c, Course_Load__c, Course_Load_Approved_By_Resident_Staff__c, Financial_Hold__c, Hold_Date__c, Release_Date__c, Host_Transcript_Received__c, Butler_Transcript_Mailed__c,Program_Term_Start_Date__c, Program_Term_End_Date__c,Total_US_Semester_Credit_Hours__c,
                (SELECT Id, Name, Status__c, RecordType.Name, RecordTypeId FROM Application_Items__r),
                (SELECT Id, Name, Course_Title__c, Host_Credits__c, Course__c, Course__r.Approved_for_CHART__c, Course__r.Course_Description__c, US_Semester_Credit_Hours__c, Course_Code__c, Status__c, Host_Institution__r.Name, Final_Grade__c FROM Course_Registrations__r WHERE Status__c IN ('Approval Pending','Approved','Grade Entered','Grade Verified','Grade Submitted','Grade Corrected','Course Omitted','Grade Revised','Ready for Butler','CIF - Submitted','CRF - Draft','Not Registered'))
            FROM Application__c WHERE Applicant__c IN:contactMap.Keyset() AND  (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1 Order by Name asc]) {
            
            if(!contactIdAppMap.containsKey(app.Applicant__c))
            {
                contactIdAppMap.put(app.Applicant__c, new List<Application__c>());
            }
            contactIdAppMap.get(app.Applicant__c).add(app);
        }

        for(Contact c: contactMap.values())
        {
            advisorStudentViewModel student = new advisorStudentViewModel(c);
            Boolean onlyCustom = false;
            if(contactIdAppMap.containsKey(c.Id))
            {
                onlyCustom = true;
                for(Application__c app: contactIdAppMap.get(c.Id))
                {
                    // if(app.Is_Custom__c == false)
                    // {
                        onlyCustom = false;
                        student.applications.add(new advisorStudentAppViewModel(app));
                    // }                   
                }
            }
            Boolean hasAnyApplication = (student.applications.size() > 0);
            Boolean haveNoApplication = (student.applications.size() == 0);
            if (
                 (
                   //  student.Grade_Level == null
                  haveNoApplication)
                 )
             {
                 recordCount += 1;
                 if (recordCount > offSetPageSize)
                 {
                    results.add(student);
                 }
                 if (results.size() == pageSize)
                 {
                     break; // for loop
                 }
                
            }
           // if(!onlyCustom){
            //     results.add(student);
            // }           
        }
        return results;
}
else if(otherOptions == 'notes')
{
          Integer currentPageIncr = (currentPage+1);
        Integer offSetPageSize = (currentPageIncr*pageSize)-pageSize;
        Integer recordCount = 0;
        Map<Id, Contact> contactMap = null;

        if(section == '' && year == '' && country == ''  && status == ''  )
        {
            contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
            FROM Contact WHERE contact_source__C  ='Global Wayfinder' AND Id in (Select Contact__C from Toolbox_Notes__C) AND  Id not in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName /*Limit :pageSize OFFSET :offSetPageSize*/]);
        } else {
            contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
                GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
                (SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
                (SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)                 
            FROM Contact WHERE contact_source__C  !='Global Wayfinder' AND contact_source__C  ='Global Wayfinder' AND  Id in (Select Contact__C from Toolbox_Notes__C) AND  Id not in (Select Applicant__c from Application__c where (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1) AND Home_Institution__c =: homeInstitutionId AND (Name like : NameSearch1) AND RecordType.Name = 'Student' Order by FirstName, LastName /*Limit :pageSize OFFSET :offSetPageSize*/]);
        }
         //added Total_US_Semester_Credit_Hours__c by powerfluence based on req on 06/01/2022  
          for(Application__c app: [SELECT Id, Applicant__c, Name, Status__c, Program_Term__r.Name, Program_Country__c, Program_Term_Section__c, Program_Term_Year__c, Application_Deadline__c, Is_Custom__c, Grades_Submitted__c, Course_Load__c, Course_Load_Approved_By_Resident_Staff__c, Financial_Hold__c, Hold_Date__c, Release_Date__c, Host_Transcript_Received__c, Butler_Transcript_Mailed__c,Program_Term_Start_Date__c, Program_Term_End_Date__c,Total_US_Semester_Credit_Hours__c,
                (SELECT Id, Name, Status__c, RecordType.Name, RecordTypeId FROM Application_Items__r),
                (SELECT Id, Name, Course_Title__c, Host_Credits__c, Course__c, Course__r.Approved_for_CHART__c, Course__r.Course_Description__c, US_Semester_Credit_Hours__c, Course_Code__c, Status__c, Host_Institution__r.Name, Final_Grade__c FROM Course_Registrations__r WHERE Status__c IN ('Approval Pending','Approved','Grade Entered','Grade Verified','Grade Submitted','Grade Corrected','Course Omitted','Grade Revised','Ready for Butler','CIF - Submitted','CRF - Draft','Not Registered'))
            FROM Application__c WHERE Applicant__c IN:contactMap.Keyset() AND  (Status__c LIKE : status1 AND Status__c not IN:StatusValues) AND Program_Term_Year__c  LIKE : year1 and Program_Term_Section__c LIKE : section1  and Program_Country__c like: country1 Order by Name asc]) {
            
            if(!contactIdAppMap.containsKey(app.Applicant__c))
            {
                contactIdAppMap.put(app.Applicant__c, new List<Application__c>());
            }
            contactIdAppMap.get(app.Applicant__c).add(app);
        }

        for(Contact c: contactMap.values())
        {
            advisorStudentViewModel student = new advisorStudentViewModel(c);
            Boolean onlyCustom = false;
            if(contactIdAppMap.containsKey(c.Id))
            {
                onlyCustom = true;
                for(Application__c app: contactIdAppMap.get(c.Id))
                {
                    // if(app.Is_Custom__c == false)
                    // {
                        onlyCustom = false;
                        student.applications.add(new advisorStudentAppViewModel(app));
                    // }                   
                }
            }
            Boolean hasAnyApplication = (student.applications.size() > 0);
            Boolean haveNoApplication = (student.applications.size() == 0);
            if (
                (
                 //   student.Grade_Level == null
                  haveNoApplication)
                )
             {
                 recordCount += 1;
                 if (recordCount > offSetPageSize)
                 {
                    results.add(student);
                 }
                 if (results.size() == pageSize)
                 {
                     break; // for loop
                 }
                
            }
           // if(!onlyCustom){
            //     results.add(student);
            // }           
        }
        return results;
} 
return results;   
} 
    
    @RemoteAction
	public static Integer getStudentsCount(String homeInstitutionId)
	{
       Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Preferred_Name__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, Major_New__c, 
				GPA__c, Grade_Level__c, Birthdate, Sex__c, Degree__c, (SELECT Id, My_Note__c, My_IFSA_Roadmap__c, My_Advising_Topics__c, RecordType.Name, RecordTypeId, LastModifiedDate FROM Toolbox_Notes__r WHERE Remove_Access_Advising_Topics__c = FALSE AND Remove_Access_Ifsa_Roadmap__c = FALSE), 
				(SELECT Id, Program_Name__c, Remove_Access_Favorite_Programs__c, CMS__c FROM Favorite_Programs__r),
				(SELECT Id, Name, Element_1__c, Element_2__c, Element_3__c, Element_4__c, Element_5__c, Element_6__c, Element_7__c, Element_8__c, Element_9__c, Element_10__c FROM Saved_Searches__r)
			FROM Contact WHERE Home_Institution__c =: homeInstitutionId  AND RecordType.Name = 'Student']);
        
        Integer resultreturn = contactMap.keyset().Size();        
        return resultreturn;
     }
 
    }