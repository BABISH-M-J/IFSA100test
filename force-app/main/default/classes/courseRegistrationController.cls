/**
 * Controller for CourseRegistration pages
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
global with sharing class courseRegistrationController 
{	
	// Properties
	/**
	 * The <<courseRegistrationViewModel>> instance for the controller. Contains all of the data to make the visualforce pages and components work
	 */
	public courseRegistrationViewModel viewModel {get;set;}	
	/**
	 * Constructor, intiailized the view model
	 */
	public courseRegistrationController() 
	{
		viewModel = new courseRegistrationViewModel();
		// Values for Page Names      ----->    Values for pageActionType
		// courseApproveGrades					Course_Approval
		// courseEnterGrades					Grade_Report
		// courseReviewGrades					Review_Grades
		// courseCreateGradeReport				Create_Grade_Report

		string pageName = getVFPageName();
		if(pageName == 'courseApproveGrades')
			viewModel.pageActionType = 'Course_Approval';
		else if(pageName == 'courseEnterGrades')
			viewModel.pageActionType = 'Grade_Report';
		else if(pageName == 'courseReviewGrades')
			viewModel.pageActionType = 'Review_Grades';
		else if(pageName == 'courseCreateGradeReport')
			viewModel.pageActionType = 'Create_Grade_Report';
		
		system.debug(viewModel.pageActionType);
		viewModel.applicationId = ApexPages.currentPage().getParameters().get('appid');
		viewModel.programTermId = ApexPages.currentPage().getParameters().get('ptid');
		//viewModel.pageActionType = ApexPages.currentPage().getParameters().get('pageActionType');				
		//viewModel.pageActionType = viewModel.pageActionType != null ? viewModel.pageActionType : 'Course_Approval';
		//List<Application__c> apps = new List<Application__c>();
		//List<Id> appIds = new List<Id>();

		viewModel = populateViewModel(viewModel);
	}
	/**
	 * Gets the name of the current VF page
	 * @return Returns the name of the current VP page
	 */
	public String getVFPageName()
	{
		// THIS IS THE CLOSEST YOU CAN GET SO FAR
		String pageName = ApexPages.CurrentPage().getUrl();
		// IT ALWAYS STARTS WITH /APEX/ SO REMOVE IT
		pageName = pageName.replaceFirst('/apex/','');
		pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
		// %3F IS THE VALUE OF THE QUESTION MARK IN UTF-8 
		string[] pageNameExtra = pageName.split('%3F',0);
		// SO YOU MAY SPLIT THE STRING AT THAT POINT
		// FOR THIS PURPOSE YOU ONLY NEED THE FIRST
		// IN THE RESULTING ARRAY
		pageName = pageNameExtra[0];
		// HERE IS YOUR PRODUCT  
		system.debug('pageName-->'+pageName);
		return pageName;
	}
	/**
	 * Creates courseRegistrationViewModel from JSON string
	 * @param jsonData JSON data of courseRegistrationViewModel
	 * @return instance of courseRegistrationViewModel
	 */
	@RemoteAction
	public static courseRegistrationViewModel populateViewModel(String jsonData)
	{
		courseRegistrationViewModel viewModel = new courseRegistrationViewModel();
		if(jsonData == null)
		{
		  return null;
		}
		try
		{
			system.debug(jsonData);
			jsonData = jsonData.unescapeEcmaScript();
			system.debug(jsonData);
		  	viewModel = (courseRegistrationViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('courseRegistrationViewModel'));
		  	return populateViewModel(viewModel);
		}
		catch(Exception e)
		{
		  System.debug(LoggingLevel.ERROR, e.getMessage());
		  return null;
		}
	}
	/**
	 * Creates courseRegistrationViewModel from a courseRegistrationViewModel
	 * @param viewModel An existing courseRegistrationViewModel
	 * @return An updated courseRegistrationViewModel
	 */
	private static courseRegistrationViewModel populateViewModel(courseRegistrationViewModel viewModel)
	{
		List<Application__c> apps = new List<Application__c>();		
		List<String> myInstitutions = new List<String>();
		
		List<Support_Personnel__c> mySupportedInstitutions = [SELECT Id, Host_Institution__r.Name FROM Support_Personnel__c WHERE RecordType.Name = 'Host Institution' AND IFSA_Staff__c =: UserInfo.getUserId()];
		for(Support_Personnel__c thisHostSupport: mySupportedInstitutions)
		{
			myInstitutions.add(thisHostSupport.Host_Institution__r.Name);
		}
				
		//Adding IFSA Program Advisor so that people can temporarily help with grade reports
		User currentUser = [SELECT Id, Profile.Name, (SELECT Id FROM PermissionSetAssignments WHERE PermissionSet.Name = 'Academic_Affairs_Grade_Report') FROM User WHERE Id =: UserInfo.getUserId()];
		Boolean hasGradeReportPermission = currentUser.Profile.Name == 'System Administrator' || !currentUser.PermissionSetAssignments.isEmpty();
		if(viewModel.pageActionType == 'Course_Approval')
		{
			apps = [SELECT Id, Name, Host_Institution__c, Applicant__r.Home_Institution__r.Account__c, Home_Institution__c FROM Application__c WHERE Host_Institution__c IN: myInstitutions AND Count_Approval_Pending__c > 0 LIMIT 200];
		}
		else if(viewModel.pageActionType == 'Grade_Report' && hasGradeReportPermission)
		{
			if(viewModel.applicationId != null)
			{
				apps = [SELECT Id, Name, Host_Institution__c, Financial_Hold__c, Program_GPA__c, Applicant__r.Home_Institution__r.Account__c, Home_Institution__c FROM Application__c WHERE Id =: viewModel.applicationId AND Status__c IN ('On Site', 'Program Completed', 'Withdraw')  AND Course_Count__c > 0 AND Courseload_Approval__c = TRUE LIMIT 200];
			}
			else
			{
				apps = [SELECT Id, Name, Host_Institution__c, Financial_Hold__c, Program_GPA__c, Applicant__r.Home_Institution__r.Account__c, Home_Institution__c FROM Application__c WHERE Status__c IN ('On Site', 'Program Completed', 'Withdraw')   AND Course_Count__c > 0 AND Count_Empty_Grades__c > 0 LIMIT 200];
			}
		}
		else if(viewModel.pageActionType == 'Review_Grades' && hasGradeReportPermission)
		{
			apps = [SELECT Id, Name, Host_Institution__c, Financial_Hold__c, Program_GPA__c, Applicant__r.Home_Institution__r.Account__c, Home_Institution__c FROM Application__c WHERE Status__c IN ('On Site', 'Program Completed', 'Withdraw')   AND (Count_Revised__c > 0 OR Count_Grades_Entered__c > 0) AND Grades_Entered__c != NULL LIMIT 200];
		}
		else if(viewModel.pageActionType == 'Create_Grade_Report' && hasGradeReportPermission)
		{
			apps = [SELECT Id, Name, Host_Institution__c, Financial_Hold__c, Program_GPA__c, Applicant__r.Home_Institution__r.Account__c, Home_Institution__c FROM Application__c WHERE Status__c IN ('On Site', 'Program Completed', 'Withdraw')   AND Course_Count__c > 0 AND ((Grades_Verified__c != NULL AND Grades_Submitted__c = NULL) OR Count_Grades_Verified__c > 0)];
		}
		else
		{
			//Needs implementation
		}
		//Get a list of Course Registrations for the supplied list of applications		
		if(!apps.isEmpty())
		{
			Set<String> institutions = new Set<String>();
			Set<Id> homeInstitutions = new Set<Id>();
			List<Contact> transcriptContacts = new List<Contact>();

			for(Application__c app: apps)
			{
				institutions.add(app.Host_Institution__c);
				homeInstitutions.add(app.Applicant__r.Home_Institution__r.Account__c);
			}

			transcriptContacts = [SELECT Id, Name, AccountId, Account.Name, Account.Institution__c FROM Contact WHERE Transcript_Recipient__c = TRUE AND AccountId IN: homeInstitutions];
			Map<Id, Contact> homeInstitutionTranscriptContactsMap = new Map<Id, Contact>();
			for(Contact c: transcriptContacts)
			{
				homeInstitutionTranscriptContactsMap.put(c.AccountId, c);
			}

			String whereClause = apexQueryUtility.buildInClause(apps, 'Id');
			List<Course_Registration__c> courseRegistrations = new List<Course_Registration__c>();
			if(viewModel.pageActionType == 'Create_Grade_Report')
			{
				courseRegistrations = apexQueryUtility.selectAllFrom('Course_Registration__c', 'Host_Institution__r.Name, Butler_Department_Code__r.Name', 'Status__c = \'Grade Verified\' AND Application__c IN ' + whereClause);
				system.debug(courseRegistrations.size());
			}
			else if(viewModel.pageActionType == 'Course_Approval')
			{
				courseRegistrations = apexQueryUtility.selectAllFrom('Course_Registration__c', 'Host_Institution__r.Name, Butler_Department_Code__r.Name', 'Status__c IN (\'Approval Pending\') AND Application__c IN ' + whereClause);	
			}
			else if(viewModel.pageActionType == 'Review_Grades')
			{
				courseRegistrations = apexQueryUtility.selectAllFrom('Course_Registration__c', 'Host_Institution__r.Name, Butler_Department_Code__r.Name', 'Status__c IN (\'Grade Entered\',\'Grade Verified\',\'Grade Corrected\',\'Grade Revised\',\'Ready for Butler\') AND Final_Grade__c != NULL AND Application__c IN ' + whereClause);	
			}
			else if(viewModel.pageActionType == 'Grade_Report' && viewModel.applicationId == null)
			{
				courseRegistrations = apexQueryUtility.selectAllFrom('Course_Registration__c', 'Host_Institution__r.Name, Butler_Department_Code__r.Name', 'Status__c IN (\'Approval Pending\',\'Approved\',\'Grade Entered\',\'Grade Verified\',\'Grade Corrected\',\'Grade Revised\',\'Ready for Butler\',\'Course Omitted\') AND Final_Grade__c = NULL AND Application__c IN ' + whereClause);			
			}
			else if(viewModel.pageActionType == 'Grade_Report' && viewModel.applicationId != null)
			{
				courseRegistrations = apexQueryUtility.selectAllFrom('Course_Registration__c', 'Host_Institution__r.Name, Butler_Department_Code__r.Name', 'Application__c IN ' + whereClause + ' AND Status__c IN (\'Approval Pending\',\'Approved\',\'Grade Entered\',\'Grade Verified\',\'Grade Corrected\',\'Grade Revised\',\'Ready for Butler\',\'Course Omitted\')');
			}
			else
			{
				courseRegistrations = apexQueryUtility.selectAllFrom('Course_Registration__c', 'Host_Institution__r.Name, Butler_Department_Code__r.Name', 'Application__c IN ' + whereClause);
			}
			for(String institution: institutions)
			{
				hostInstitustionApplicationViewModel hiavm = new hostInstitustionApplicationViewModel();
				hiavm.institutionName = institution;
				for(Application__c app: apps)
				{
					if(app.Host_Institution__c == institution)
					{
						applicationCourseViewModel acvm = new applicationCourseViewModel();						
						if(homeInstitutionTranscriptContactsMap.containsKey(app.Applicant__r.Home_Institution__r.Account__c))
						{
							Contact tr = homeInstitutionTranscriptContactsMap.get(app.Applicant__r.Home_Institution__r.Account__c);
							acvm.transcriptRecipientName = tr.Name;
							acvm.transcriptRecipientId = tr.Id;
							acvm.transcriptRecipientAccountId = tr.AccountId;
							acvm.transcriptRecipientAccountName = tr.Account.Name;
						}
						else
						{
							acvm.transcriptRecipientName = null;
							acvm.transcriptRecipientId = null;
							acvm.transcriptRecipientAccountId = null;
							acvm.transcriptRecipientAccountName = app.Home_Institution__c;
						}

						acvm.application = app;
						for(Course_Registration__c courseReg: courseRegistrations)
						{
							if(courseReg.Application__c == app.Id)
							{
								acvm.courseRegistrations.add(populateCourseViewModel(courseReg));
							}
						}
						hiavm.applicationCourses.add(acvm);
					}
				}
				viewModel.hostInstViewModels.add(hiavm);
			}
		}
		return viewModel;
	}
	/**
	 * Gets a viewmodel instance of a Course Registration record
	 * @param courseReg Course_Registration__c
	 * @return An instance of studentOnSiteCourseRegViewModel
	 */
	private static studentOnSiteCourseRegViewModel populateCourseViewModel(Course_Registration__c courseReg)
	{
		studentOnSiteCourseRegViewModel courseRegVM = new studentOnSiteCourseRegViewModel();
		courseRegVM.courseCode = courseReg.Course_Code__c;
		courseRegVM.courseRegId = courseReg.Id;
        courseRegVM.courseId = courseReg.Course__c;
		courseRegVM.hostInstitutionGrade = courseReg.Host_Institution_Grade__c;
        courseRegVM.courseGrade = courseReg.Final_Grade__c;
        courseRegVM.courseName = courseReg.Name;
        courseRegVM.courseTitle = courseReg.Course_Title__c;
        courseRegVM.courseTerm = courseReg.Course_Term__c;
    	courseRegVM.credits = courseReg.Host_Credits__c;
        courseRegVM.departmentCode = courseReg.Butler_Department_Code__r.Name;
        //courseRegVM.instructorName = courseReg.Instructor_Name__c;
        courseRegVM.instructorFirstName = courseReg.Instructor_First_Name__c; 
        courseRegVM.instructorLastName = courseReg.Instructor_Last_Name__c;
    	courseRegVM.usCredits = courseReg.US_Semester_Credit_Hours__c;
    	courseRegVM.hostInstitutionName = courseReg.Host_Institution_Name__c;
    	courseRegVM.hostInstitutionId = courseReg.Host_Institution__c;
		courseRegVM.originalHostInstitutionName = courseReg.original_host_institution_name__c;
    	courseRegVM.isApproved = courseReg.Is_Approved__c;
    	courseRegVM.isDropped = courseReg.Is_Dropped__c;
    	courseRegVM.courseStatus = courseReg.Status__c;
    	courseRegVM.qualityPoints = courseReg.Raw_GPA__c;

        try
        {
        	courseRegVM.hostInstitutionName = courseReg.Host_Institution__r.Name;
        }
        catch(sObjectException e){}

        return courseRegVM;
	}

	/**
	 * Creates a Course_Registration__c object from studentOnSiteCourseRegViewModel
	 * @param courseRegVM studentOnSiteCourseRegViewModel
	 * @return A Course_Registration__c record
	 */
	private static Course_Registration__c populateCourseRegistration(studentOnSiteCourseRegViewModel courseRegVM)
	{
			Course_Registration__c courseReg = new Course_Registration__c();
			String shortenedName = courseRegVM.courseTitle.length() > 80 ? courseRegVM.courseTitle.left(80) : courseRegVM.courseTitle;			
			courseReg.Name = shortenedName;
			courseReg.Course_Title__c = courseRegVM.courseTitle;
			courseReg.Application__c = courseRegVM.applicationId;
			courseReg.Id = courseRegVM.courseRegId;
			courseReg.Course_Code__c = courseRegVM.courseCode;
	        courseReg.Course__c = courseRegVM.courseId;
	        courseReg.Course_Term__c = courseRegVM.courseTerm;
	        courseReg.Final_Grade__c = courseRegVM.courseGrade;	        
	    	courseReg.Host_Credits__c = courseRegVM.credits;
	        courseReg.Butler_Department_Code__c = [SELECT Id FROM Butler_Department_Code__c WHERE Name =: courseRegVM.departmentCode].get(0).Id;
	        courseReg.Instructor_First_Name__c = courseRegVM.instructorFirstName; 
        	courseReg.Instructor_Last_Name__c = courseRegVM.instructorLastName;
	    	//courseReg.US_Semester_Credit_Hours__c = courseRegVM.usCredits;
	    	system.debug(courseRegVM.hostInstitutionName);
	    	courseReg.Host_Institution__c = [SELECT Id FROM Host_Institution__c WHERE Name =: courseRegVM.hostInstitutionName].get(0).Id;	    	
	    	courseReg.Is_Approved__c = courseRegVM.isApproved ? true: false;
	    	courseReg.Is_Dropped__c = courseRegVM.isDropped ? true: false;
			
	    	return courseReg;
	}

	/**
	 * Commits updates to course registration records
	 * @param jsonData JSON string
	 * @return Success boolean
	 */
	@RemoteAction
	public static Boolean commitCourses(String jsonData)
	{
		applicationCourseViewModel viewModel = new applicationCourseViewModel();
		Boolean success = true;
		system.debug(jsonData);
		if(jsonData == null)
		{
		  return false;
		}
		try
		{		  
		  viewModel = (applicationCourseViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('applicationCourseViewModel'));
		}
		catch(Exception e)
		{
		  System.debug(LoggingLevel.ERROR, e.getMessage());
		  return false;
		}
		
		List<Course_Registration__c> courseRegistrations = new List<Course_Registration__c>();
		for(studentOnSiteCourseRegViewModel courseRegVM: viewModel.courseRegistrations)
		{
	        courseRegistrations.add(populateCourseRegistration(courseRegVM));
		}
		Database.SaveResult[] results = database.update(courseRegistrations);
		
		for(Database.SaveResult sr: results)
		{
			if(!sr.isSuccess())
			{
				success = false;
			}
		}

		if(success)
		{
			Application__c app = viewModel.application;			
			app.Courseload_Approval__c = true;
			app.Course_Load_Approved__c = Date.today();

			database.update(app);
		}
		
		return success;
	}
	/**
	 * Marks application timestamps when grades are entered and reviewd
	 * @param jsonData String - JSON data representing request
	 * @param pageActionType String - What action is happening with the application's course registrations
	 * @return Success boolean
	 */
	@RemoteAction
	public static Boolean applicationGradesEntered(String jsonData, String pageActionType)
	{
		applicationCourseViewModel viewModel = new applicationCourseViewModel();
		Boolean success = true;
		if(jsonData == null)
		{
		  return false;
		}
		try
		{
		  viewModel = (applicationCourseViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('applicationCourseViewModel'));
		}
		catch(Exception e)
		{
		  System.debug(LoggingLevel.ERROR, e.getMessage());
		  return false;
		}
		
		List<Course_Registration__c> courseRegistrations = new List<Course_Registration__c>();
		for(studentOnSiteCourseRegViewModel courseRegVM: viewModel.courseRegistrations)
		{
	        courseRegistrations.add(populateCourseRegistration(courseRegVM));
		}
		Database.SaveResult[] results = database.update(courseRegistrations);
		
		for(Database.SaveResult sr: results)
		{
			if(!sr.isSuccess())
			{
				success = false;
			}
		}
		if(success)
		{
			Application__c app = viewModel.application;

			if(pageActionType == 'Grade_Report')
			{				
				app.Grades_Entered__c = Date.today();
			}			
			if(pageActionType == 'Review_Grades')
			{
				app.Grades_Verified__c = Date.today();
				applicationService.gradesVerified(app);
			}			

			database.update(app);
		}
		
		return success;
	}
	/**
	 * Creates a course registration record from JSON data
	 * @param jsonData String - JSON data of new course registration
	 * @param createCourse Boolean - creating new record or saving existing
	 * @return An instance studentOnSiteCourseRegViewModel
	 */
	@RemoteAction
	public static studentOnSiteCourseRegViewModel createCourse(String jsonData, Boolean createCourse)
	{
		studentOnSiteCourseRegViewModel courseRegVM = new studentOnSiteCourseRegViewModel();

		if(jsonData == null)
		{
		  return null;
		}
		try
		{
		  courseRegVM = (studentOnSiteCourseRegViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('studentOnSiteCourseRegViewModel'));
		}
		catch(Exception e)
		{
		  System.debug(LoggingLevel.ERROR, e.getMessage());
		  return null;
		}
		Course_Registration__c courseReg = populateCourseRegistration(courseRegVM);

		Database.SaveResult dbResult;
		if(courseReg.Id == null)
		{
			dbResult = database.insert(courseReg);
		}
		else
		{
			 dbResult = database.update(courseReg);
		}
		if(dbResult.isSuccess())
		{
			String result = !createCourse ? 'The course(s) were created successfully. Please refresh the page.' : '';
			if(createCourse)
			{
				result = ifsaCourseRegDomainStatics.createCourseFromCourseReg(new List<Id>{courseReg.Id});
			}			
			if(result == 'The course(s) were created successfully. Please refresh the page.' || result.contains('There is already a course associated with '))
			{
				courseReg = (Course_Registration__c) apexQueryUtility.selectAllFrom('Course_Registration__c', 'Host_Institution__r.Name, Butler_Department_Code__r.Name', 'Id = \'' + courseReg.Id + '\'').get(0);				
				return populateCourseViewModel(courseReg);
			}		
		}		
		return null;
	}
	/**
	 * Searches for recod
	 * @param objectName String - Name of table to search
	 * @param searchTerm String - Term to search
	 * @return A list of ifsaRecordLookupViewModel
	 */
	@RemoteAction
    public static List<ifsaRecordLookupViewModel> searchForRecord(String objectName, String searchTerm) 
    {
    	return ifsaRecordLookupMethods.searchForRecord(objectName, searchTerm);
    }
    /**
	 * Searches for recod with record type
	 * @param objectName String - Name of table to search
	 * @param searchTerm String - Term to search
	 * @param recordTypeDeveloperName String - Name of record type to search
	 * @return A list of ifsaRecordLookupViewModel
	 */
    @RemoteAction
    public static List<ifsaRecordLookupViewModel> searchForRecordWithRecordType(String objectName, String searchTerm, String recordTypeDeveloperName) 
    {
    	return ifsaRecordLookupMethods.searchForRecordWithRecordType(objectName, searchTerm, recordTypeDeveloperName);
    }
    /**
	 * Searches for course records
	 * @param hostInstitutionId String - Id of host institution
	 * @param searchTerm String - Term to search
	 * @param fieldName String - The field to search
	 * @return A list of studentOnSiteCourseRegViewModel
	 */
    @RemoteAction
    public static List<studentOnSiteCourseRegViewModel> searchForCourses(String hostInstitutionId, String searchTerm, String fieldName) 
    {
    	return portalOnSiteRemotingMethods.searchForCourses(hostInstitutionId, searchTerm, fieldName);
    }
    /*
	 * Marks Course_Registrations related to a Butler_Grade_Report__c as submitted
	 * @param String - Id of Butler_Grade_Report__c
	 */
	 /*
    @RemoteAction
    public static void markCourseRegistrationsSubmitted(String bgrId)
    {
    	Butler_Grade_Report__c brg = [SELECT Id FROM Butler_Grade_Report__c WHERE Id =: bgrId];
    	List<Course_Registration_Grade__c> crgs = [SELECT Id, Course_Registration__c FROM Course_Registration_Grade__c WHERE Butler_Grade_Report__c =: bgrId];
    	List<Course_Registration__c> crs = new List<Course_Registration__c>();
    	for(Course_Registration_Grade__c crg: crgs)
    	{
    		Course_Registration__c cr = new Course_Registration__c(Id = crg.Course_Registration__c);
    		cr.Status__c = 'Grade Submitted';
    		crs.add(cr);
    	}
    	database.update(crs);
    }*/
    /**
	 * Generates Grade Report records and attaches a generated text file to the BGR record
	 * @param jsonData String - JSON data containing the applications and course registrations to create grade records for
	 * @return  Map<String, String> - Success or error of operation
	 */
    @RemoteAction
    public static Map<String, String> generateGradeDocuments(String jsonData)
    {
    	Map<String, String> returnMessage = new Map<String, String>();
		returnMessage.put('jobId', '');
		returnMessage.put('bgrId', '');
		returnMessage.put('messages', '');
    	courseRegistrationViewModel viewModel = (courseRegistrationViewModel) populateViewModel(jsonData.escapeEcmaScript());
		
		Butler_Grade_Report__c bgr = createBgrRecord();
    	
    	if(bgr != null)
    	{

			courseRegistrationQueueableService qs = new courseRegistrationQueueableService(viewModel, bgr);
			returnMessage.put('jobId', system.enqueueJob(qs));
			returnMessage.put('bgrId', bgr.Id);
    	}
    	else
    	{
    		returnMessage.put('messages', 'An error occured when saving');
    	}
    	
    	return returnMessage;
    }
    /**
	 * Method creates Butler_Grade_Report__c
	 * @return Butler_Grade_Report__c record
	 */
    private static Butler_Grade_Report__c createBgrRecord()
    {
    	Butler_Grade_Report__c bgr = new Butler_Grade_Report__c();
    	bgr.Date_Submitted__c = Date.today();
    	bgr.CurrencyIsoCode = 'USD';
    	Database.SaveResult success = Database.insert(bgr);
    	if(success.isSuccess())
    		return bgr;

    	return null;
    }
    /**
	 * Method creates Course_Registration_Grade__c and Grade_Report_Application__c records for the Butler_Grade_Report__c record
	 * @param courseRegIds
	 * @param bgrId
	 * @return List of Course_Registration_Grade__c
	 */
    public static List<Course_Registration_Grade__c> createCourseGrades(List<Id> courseRegIds, Id bgrId)
    {    	
    	Set<Id> appIds = new Set<Id>();
		List<SObject> records = new List<SObject>();
		List<Course_Registration__c> courseRegs = [SELECT Id, Final_Grade__c, Credits_Earned__c, US_Semester_Credit_Hours__c, Original_Host_Institution_Name__c, Application__c, Application__r.Transcript_Recipient__c, Host_Institution__r.Name FROM Course_Registration__c WHERE Id IN: courseRegIds AND Status__c IN ('Grade Verified')];
		for(Course_Registration__c courseReg: courseRegs)
		{
			// Set Original_Host_Institution_Name__c
			courseReg.Original_Host_Institution_Name__c = courseReg.Original_Host_Institution_Name__c == null ? courseReg.Host_Institution__r.Name : courseReg.Original_Host_Institution_Name__c;
			// Create Course_Registration_Grade__c
			records.add( new Course_Registration_Grade__c(
				Butler_Grade_Report__c = bgrId,
				Application__c = courseReg.Application__c,
				Course_Registration__c = courseReg.Id,
				Grade_When_Submitted__c = courseReg.Final_Grade__c,
				Credits_Attempted_When_Submitted__c = courseReg.US_Semester_Credit_Hours__c,
				Credits_Earned_When_Submitted__c = courseReg.Credits_Earned__c,
				Transcript_Recipient_Contact__c = courseReg.Application__r.Transcript_Recipient__c
			));
			// If application id is not in set, create Grade_Report_Application__c
			if(!appIds.contains(courseReg.Application__c))
			{
				appIds.add(courseReg.Application__c);
				records.add(new Grade_Report_Application__c(
					Application__c = courseReg.Application__c,
					Butler_Grade_Report__c = bgrId
				));
			}
		}
		records.sort();
		Database.update(courseRegs);
		Database.SaveResult[] sr = Database.Insert(records);
		Boolean success = true;
		for(Database.SaveResult s: sr)
		{
			if(!s.isSuccess())
				success = false;
		}

		if(success)
		{
			List<Course_Registration_Grade__c> courseGrades = new List<Course_Registration_Grade__c>();
			for(SObject obj: records)
			{
				if(obj instanceOf Course_Registration_Grade__c)
				{
					courseGrades.add((Course_Registration_Grade__c) obj);
				}
			}
			return courseGrades;
		}

		return null;
    }
    /**
	 * Method creates text file using button on record page
	 * @param bgrId Id of Butler_Grade_Report__c record
	 * @return Success boolean
	 */
    webservice static Boolean createTextFileFromButton(Id bgrId)
    {
    	Butler_Grade_Report__c bgr = (Butler_Grade_Report__c) apexQueryUtility.selectAllFrom('Butler_Grade_Report__c', 'Id = \'' + bgrId + '\'').get(0);
    	Boolean success = createTextFile(bgr);
    	return success;
    }
	@InvocableMethod(label='Create Text File' description='Generates a new text file to send to Butler')
	global static List<String> createTextFileFromFlow(List<Id> ids)
	{
		Butler_Grade_Report__c bgr = (Butler_Grade_Report__c) apexQueryUtility.selectAllFrom('Butler_Grade_Report__c', 'Id = \'' + ids.get(0) + '\'').get(0);
    	Boolean success = createTextFile(bgr);
		return new List<String>{ids.get(0)};
	}
    /**
	 * Method creates text file
	 * @param bgr Butler_Grade_Report__c record
	 * @return Success boolean
	 */
    public static Boolean createTextFile(Butler_Grade_Report__c bgr)
    {
    	String b = '';
		Attachment bgrTextFile = new Attachment();
		bgrTextFile.ContentType = 'text/plain';
		//bgrTextFile.Name = 'Butler Grade Report ' + Date.today().format();
		String dayNumber = Date.today().day() > 9 ? Date.today().day().format() : '0' + Date.today().day().format();
		String monthNumber = Date.today().month() > 9 ? Date.today().month().format() : '0' + Date.today().month().format();
		bgrTextFile.Name = monthNumber + '_' + dayNumber + '_' + Date.today().year() + '_IFSA';
		String buId = '';

		List<Course_Registration_Grade__c> courseGrades = apexQueryUtility.selectAllFrom('Course_Registration_Grade__c', 'Application__r.Program_Term_Program__c', 'Butler_Grade_Report__c = \'' + bgr.Id + '\' AND Application__r.Grades_Revised__c = NULL ORDER BY Application__r.Program_Term_Program__c, Application__r.Applicant__r.Butler_Id__c'); // 7/10/18: Added for BGR Sorting project
		// List<Course_Registration_Grade__c> courseGrades = apexQueryUtility.selectAllFrom('Course_Registration_Grade__c', 'Butler_Grade_Report__c = \'' + bgr.Id + '\' AND Application__r.Grades_Revised__c = NULL ORDER BY Application__r.Program_Country__c, Application__r.Program_Term_Program__c, Application__r.Student_Last_Name__c, Application__r.Student_First_Name__c'); // 7/10/18: Commented out for BGR Sorting project
		//List<Course_Registration_Grade__c> courseGrades = apexQueryUtility.selectAllFrom('Course_Registration_Grade__c', 'Butler_Grade_Report__c = \'' + bgr.Id + '\' AND Application__r.Grades_Revised__c = NULL ORDER BY Application__r.Program_Country__c, Application__r.Program_Term_Program__c, Application__r.Student_Last_Name__c');
		//List<Course_Registration_Grade__c> courseGrades = apexQueryUtility.selectAllFrom('Course_Registration_Grade__c', 'Butler_Grade_Report__c = \'' + bgr.Id + '\' AND Application__r.Grades_Revised__c = NULL ORDER BY Application__c');
		for(Course_Registration_Grade__c crg: courseGrades)
		{
			system.debug(crg.Course_Registration__c);
			if(buId == crg.Student_Butler_Id__c)
			{
				//Append course to the current student
				b = b + '\t' + crg.Butler_Department_Code__c + '\t' + crg.Course_Title__c + '\t' + crg.Credits_Attempted_When_Submitted__c + '\t' + crg.Grade_When_Submitted__c;
			}
			else 
			{
				buId = crg.Student_Butler_Id__c;
				if(b != '')
				{
					//Insert new line
					b = b + '\r\n';
				}    					
				String startDate = crg.Term_Start_Date__c.format();
				String endDate = crg.Term_End_Date__c.format();
				b = b + crg.Student_Butler_Id__c + '\t\t' + crg.Student_Home_Institution__c + '\t' + crg.Course_Term__c + '\t' + startDate + '\t' + endDate + '\t' + crg.Application__r.Program_Term_Program__c + '\t' + crg.Butler_Department_Code__c + '\t' + crg.Course_Title__c + '\t' + crg.Credits_Attempted_When_Submitted__c + '\t' + crg.Grade_When_Submitted__c;
			}
		}
		bgrTextFile.parentId = bgr.Id;
		bgrTextFile.Body = Blob.valueOf(apexTextUtility.removeDiacritics(b));
		if(configurationManager.isTestMode())		
		{
			system.debug(bgrTextFile.Body.toString().contains('é'));
		}
		Database.SaveResult sr = Database.Insert(bgrTextFile);

		return sr.isSuccess();
    }
	/**
	 * Checks the status of an AsyncApexJob
	 * @param jobId
	 * @return String AsyncApexJob status
	 */
	@RemoteAction
	public static String checkJobStatus(String jobId)
	{
		AsyncApexJob jobInfo = [SELECT Status FROM AsyncApexJob WHERE Id=:jobID];

		return jobInfo.Status;
	}
}