/**
 * @description The remoting methods used for on site pages in the portals.
 * @author Brock Barlow
 */
public without sharing class portalOnSiteRemotingMethods {
    /**
	 * @description Constructor to enable use with any IFSA controllers.
	 */
    public portalOnSiteRemotingMethods(ifsaBaseController controller){}
    // START OF COURSE METHODS
    /**
	 * @description Takes course registration information And submits it.
	 * @param serializedViewModel An instance of the studentOnSiteViewModel, serialized as a JSON String.
	 * @param appId The id of the student's application record
	 * @return boolean indicating whether Or Not the save was successful.
	 */
	@RemoteAction
	public static Boolean submitCourseRegistration(String serializedViewModel, String appId)
	{
		Application__c app = [SELECT Id, Name, Program_Term__r.Name, Program_Term__r.Program__c, Program_Term__r.Program_Option__c, Program_Term__r.RecordType.Name, Status__c, CRF_Status__c FROM Application__c WHERE Id =: appId];
		Application_Item__c cifItem;
		List<studentOnSiteCourseRegViewModel> courses;
		List<Id> courseIds = new List<Id>();
		Boolean submitCRF = false;
	    if (serializedViewModel == null)
	    {
	    	return false;
	    }
	    try
	    {
            system.debug(serializedViewModel);
			courses = (List<studentOnSiteCourseRegViewModel>) JSON.deserialize(serializedViewModel, List<studentOnSiteCourseRegViewModel>.class);
			if(courses.get(0).courseStatus == 'CIF - Submitted')
			{
				cifItem = [SELECT Id FROM Application_Item__c WHERE Application__c =: app.Id AND RecordType.Name = 'Class Interest Form'].get(0);
				// string json = serializedViewModel.escapeEcmaScript();
				// cifItem.CIF_JSON__c = json.replaceAll('&quot;', '"');
				cifItem.CIF_JSON__C = JSON.serialize(courses);

				Database.update(cifItem);
			}
			for(studentOnSiteCourseRegViewModel c: courses)
			{
				if(c.courseStatus == 'Approval Pending')
				{
					submitCRF = true;
				}
			}
	    }
	    catch(Exception e)
	    {
	    	System.debug(LoggingLevel.ERROR, e.getMessage());
	    	return false;
	    }
		
		List<Course_Registration__c> courseRegList = new List<Course_Registration__c>();
		Map<Id, studentOnSiteCourseRegViewModel> alternates = new Map<Id, studentOnSiteCourseRegViewModel>();
		for(studentOnSiteCourseRegViewModel subViewModel : courses)
		{
			if(subViewModel.alternateFor != null && subViewModel.courseRegId == null)
			{
				alternates.put(subViewModel.alternateFor, subViewModel);
			}
			else
			{
				if(subViewModel.courseId != null)
				{
					courseIds.add(subViewModel.courseId);
				}
				courseRegList.add(populateCourseRegistration(subViewModel, app));
			}
		}
		
		List<Database.UpsertResult> resultList = Database.upsert(courseRegList);
		
		Boolean isSuccess = true;
		List<Id> crfIds = new List<Id>();
		for(Database.UpsertResult result : resultList)
		{
			if(!result.isSuccess())
			{
				isSuccess = false;
				apexEmailUtility.sendErrorEmail('There was an error submitting course registration for application ' + appId + '. There error was: ' + result.getErrors().get(0).getMessage());
				return isSuccess;
			}
			crfIds.add(result.getId());
		}
		
		if(isSuccess && app.Status__c == 'On Site' && submitCRF)
		{	
			if(app.CRF_Status__c == 'Not Started')
				app.CRF_Status__c = 'Round 1 Complete';
			else if(app.CRF_Status__c == 'Round 1 Complete')
				app.CRF_Status__c = 'Round 2 Complete';

			createCRFSubmission(appId, crfIds);

			app.Courseload_Approval__c = false;	
			
			database.update(app);
		}
		else if(isSuccess && app.Status__c != 'On Site')
		{
			// Create Course_Registration__c for Alternate Courses
			if(!alternates.isEmpty())
			{
				List<Course_Registration__c> alternateRegList = new List<Course_Registration__c>();
				for(Course_Registration__c cr: courseRegList)
				{
					if(alternates.containsKey(cr.Course__c))
					{
						if(alternates.get(cr.Course__c).courseId != null)
						{
							courseIds.add(alternates.get(cr.Course__c).courseId);
						}
						alternates.get(cr.Course__c).alternateFor = cr.Id;
						alternateRegList.add(populateCourseRegistration(alternates.get(cr.Course__c), app));
					}
				}

				resultList = Database.upsert(alternateRegList);
				for(Database.UpsertResult result : resultList)
				{
					if(!result.isSuccess())
					{
						isSuccess = false;
						apexEmailUtility.sendErrorEmail('There was an error submitting course registration for application ' + appId + '. There error was: ' + result.getErrors().get(0).getMessage());
						return isSuccess;
					}
				}
			}
		}

		populateProgramCourses(app.Id, courseIds);
		
		return isSuccess;
	}

	// modified by powerfluence - extended req dt.02/02/2022 - 003 - starts
	// to return the newly created registrations course id
	// public static void createCourseRegistration(String courseName, String courseCode, Integer credits, String instructorFirstName, String instructorLastName, Id hostInstitution, String appId)
	// modified by powerfluence - extended req dt.02/02/2022 - 003 - endts
	@RemoteAction
	public static Id createCourseRegistration(String courseName, String courseCode, Integer credits, String instructorFirstName, String instructorLastName, Id hostInstitution, String appId)
	{
		// Test
		List<Course_Registration__c> newCRList = new List<Course_Registration__c>();
		Course_Registration__c newCR = new Course_Registration__c();
			newCR.Course_Title__c = courseName;
			newCR.Course_Code__c = courseCode;
			newCR.Host_Credits__c = credits;

			// modified by powerfluence - extended req dt.02/02/2022 - 001- starts
			newCR.Name = courseName;
			// modified by powerfluence - extended req dt.02/02/2022 - 001- ends

			// modified by powerfluence - req dt.01/28/2022 - 001- starts
			newCR.Instructor_First_Name__c = instructorFirstName;
			newCR.Instructor_Last_Name__c = instructorLastName;
			// modified by powerfluence - req dt.01/28/2022 - 001- ends
			newCR.Host_Institution__c = hostInstitution;
			newCR.Application__c = appId;
			newCR.Status__c = 'CRF - Draft';
		newCRList.add(newCR);

	
		// modified by powerfluence - extended req dt.02/09/2022 - 001 - starts
		/**
		 * Course ID is mandatory to upload Syllabus file. Hence, course will be created and the id will be
		 * added in the newCR object before inserting to the course registration object
		 * */
		Course__c course = new Course__c();
			course.Name = courseName;
			course.Course_Title_2__c = courseName;
			course.Host_Institution__c = hostInstitution;
			course.Host_Credits__c = credits;
			//c.US_Semester_Credit_Hours__c = cr.US_Semester_Credit_Hours__c;
			course.Course_Code__c = courseCode;
			Id hostCourseRTId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Host Institution').getRecordTypeId();
			course.RecordTypeId = hostCourseRTId;

			Database.SaveResult courseInsertResult = Database.insert(course,true);

			if (courseInsertResult.isSuccess()) {
				newCR.Course__c = courseInsertResult.getId();
			}

		Database.SaveResult courseRegistrationResult = Database.insert(newCR,true);
		if (courseRegistrationResult.isSuccess()) {
			return newCR.Course__c;
		} else {
			return null;
		}
		
		// modified by powerfluence - extended req dt.02/09/2022 - 001 - starts
	}

	@future
	private static void createCRFSubmission(Id appId, List<Id> crfIds)
	{
		// Load "Approval Pending" Course_Registration__c records
		List<Course_Registration__c> crfs = [SELECT Id FROM Course_Registration__c WHERE Status__c = 'Approval Pending' AND Application__c =: appId];
		if(crfs.isEmpty())
		{
			return;
		}
		// Create "Approval Pending" Class_Registration_Form_Submission__c record
		Class_Registration_Form_Submission__c crfSub = new Class_Registration_Form_Submission__c(Application__c = appId);
		Database.insert(crfSub);
		// Link Course_Registration__c to new Class_Registration_Form_Submission__c
		for(Course_Registration__c crf: crfs)
		{
			crf.Class_Registration_Form_Submission__c = crfSub.Id;
		}
		Database.update(crfs);
		// Find Queue to assign approval request to

		// Create an approval request for the Class_Registration_Form_Submission__c
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically using Trigger');
        req1.setObjectId(crfSub.id);

        // Submit the approval request for the Class_Registration_Form_Submission__c
        Approval.ProcessResult result = Approval.process(req1);
	}

	@future
	private static void populateProgramCourses(Id appId, List<Id> courseIds)
	{
		List<Course__c> courses = [SELECT Id, Name, (SELECT Program__c, Program_Option__c, Program_Option__r.Name FROM Program_Courses__r) FROM Course__c WHERE Id IN: courseIds];
		Application__c app = [SELECT Id, Name, Program_Term__r.Name, Program_Term__r.Program__c, Program_Term__r.Program_Option__c, Program_Term__r.RecordType.Name FROM Application__c WHERE Id =: appId];
		Boolean isProgramOption = false;
		if(app.Program_Term__r.RecordType.Name.contains('Program Option'))
		{
			isProgramOption = true;
		}
		List<Program_Course__c> newPCs = new List<Program_Course__c>();
		for(Course__c c: courses)
		{
			Boolean hasPC = false;
			
			for(Program_Course__c pc: c.Program_Courses__r)
			{
				if(!isProgramOption && app.Program_Term__r.Program__c == pc.Program__c)
				{
					hasPC = true;
				}
				if(isProgramOption && app.Program_Term__r.Program_Option__c == pc.Program_Option__c)
				{
					hasPC = true;
				}
			}
			if(!hasPC && !isProgramOption)
			{
				newPCs.add(new Program_Course__c(Program__c = app.Program_Term__r.Program__c, Course__c = c.Id));
			}
			else if(!hasPC && isProgramOption)
			{
				newPCS.add(new Program_Course__c(Program__c = app.Program_Term__r.Program__c, Course__c = c.Id, Program_Option__c = app.Program_Term__r.Program_Option__c));
			}
		}

		if(!newPCs.isEmpty()){
			Database.insert(newPCs);
		}
	}

	private static Course_Registration__c populateCourseRegistration(studentOnSiteCourseRegViewModel subViewModel, Application__c app)
	{
		Course_Registration__c courseReg = new Course_Registration__c();
		system.debug(subViewModel);
		subViewModel.courseTitle = subViewModel.courseTitle.unescapeHtml4();
		courseReg.Name = subViewModel.courseTitle.length() > 80 ? subViewModel.courseTitle.left(80) : subViewModel.courseTitle;
		courseReg.Course_Title__c = subViewModel.courseTitle;
		courseReg.Id = subViewModel.courseRegId;
		if(subViewModel.courseRegId == null) {
			system.debug(app.Id);
			courseReg.Application__c = app.Id;
		}		
		courseReg.Course_Code__c = subViewModel.courseCode;
		courseReg.Course__c = subViewModel.courseId;
		courseReg.Host_Credits__c = subViewModel.credits;
		courseReg.Butler_Department_Code__c = subViewModel.departmentCode != null ? [SELECT Id FROM Butler_Department_Code__c WHERE Id =: subViewModel.departmentCode].get(0).Id : null;
		courseReg.Instructor_First_Name__c = subViewModel.instructorFirstName != null ? subViewModel.instructorFirstName.unescapeHTML4() : null;
		courseReg.Instructor_Last_Name__c = subViewModel.instructorLastName != null ? subViewModel.instructorLastName.unescapeHTML4() : null;
		//courseReg.US_Semester_Credit_Hours__c = subViewModel.usCredits;
		courseReg.Host_Institution__c = subViewModel.hostInstitutionId;
		courseReg.Status__c = subViewModel.courseStatus;
		courseReg.Alternate_For__c = subViewModel.alternateFor;
		courseReg.Rank__c = subViewModel.rank;
		courseReg.Not_Registered_Reason__c = subViewModel.notRegisteredReason != null ? subViewModel.notRegisteredReason.unescapeHTML4() : null;
		courseReg.Not_Registered_Reason_Other__c = subViewModel.notRegisteredReasonOther != null ? subViewModel.notRegisteredReason.unescapeHTML4() : null;
		courseReg.Other_Class_Reason__c = subViewModel.otherClassReason != null ? subViewModel.otherClassReason.unescapeHTML4() : null;
		courseReg.Other_Class_Reason_Other__c = subViewModel.otherClassReasonOther != null ? subViewModel.otherClassReasonOther.unescapeHTML4() : null;
		courseReg.Untranslated_Course_Title__c = subViewModel.untranslatedTitle != null ? subViewModel.untranslatedTitle.unescapeHTML4() : null;
		courseReg.Fulfills_Degree_Requirement__c = subViewModel.fulfillsDegreeRequirement != null && subViewModel.fulfillsDegreeRequirement == true ? true : false;
		courseReg.Required_Class__c = subViewModel.required == true ? true : false;
		courseReg.Location_Of_Instruction__c = subViewModel.locationId;
		courseReg.Host_Institution_Departement__c = subViewModel.selectedDepartment;

		return courseReg;
	}

	/**
	 * @description Searches for courses given a student's host institution and search term.
	 * @param programTermId The Id of the program term.
	 * @param searchTerm The name of the course that the student has started typing
	 * @return the list of appropriate courses.
	 */
	//@RemoteAction
    public static List<studentOnSiteCourseRegViewModel> searchForCourses(Id hostInstitutionId, String searchTerm) 
    {       
		return searchForCourses(hostInstitutionId, searchTerm, 'Name');
	}
    @RemoteAction
    public static List<studentOnSiteCourseRegViewModel> searchForCourses(Id hostInstitutionId, String searchTerm, String fieldName)
    {        
    	List<Course__c> courses = Database.query('Select Id, Name, Course_Title_2__c, Course_Title__c, Untranslated_Course_Title__c, Course_Code__c, Host_Credits__c, US_Semester_Credit_Hours__c, Butler_Department_Code__c, Host_Institution__r.Id, Host_Institution__r.Name from Course__c where '+ fieldName + ' like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'and Host_Institution__c = \'' + hostInstitutionId + '\'');
		List<studentOnSiteCourseRegViewModel> viewModels = new List<studentOnSiteCourseRegViewModel>();
		for(Course__c course : courses)
		{
			ifsaHostCourseWrapper courseWrapper = new ifsaHostCourseWrapper(course);
			viewModels.add(courseWrapper.populateViewModel(new studentOnSiteCourseRegViewModel()));
		}
        return viewModels;
    }
	/**
	 * @description Searches for courses given a student's host institution and search term.
	 * @param programTermId The Id of the program term.
	 * @param searchTerm The name of the course that the student has started typing
	 * @return the list of appropriate courses.
	 */
    @RemoteAction
    public static List<Course__c> searchForCoursesByProgram(Id appId, String searchTerm) 
    {
		Application__c app = [SELECT Program_Term__r.Program__c, Program_Term_Section__c FROM Application__c WHERE Id =: appId];
		Id programId = app.Program_Term__r.Program__c;
		List<List<SObject>> records;
		if(app.Program_Term_Section__c == 'Fall' || app.Program_Term_Section__c == 'Spring')
		{
			 records = [FIND :searchTerm IN NAME FIELDS RETURNING Course__c(Id WHERE Id IN (SELECT Course__c FROM Program_Course__c WHERE Program__c =: programId)  AND US_Terms__c includes ('Fall','Spring'))];
		}
		else if(app.Program_Term_Section__c.contains('Year'))
		{
			records = [FIND :searchTerm IN NAME FIELDS RETURNING Course__c(Id WHERE Id IN (SELECT Course__c FROM Program_Course__c WHERE Program__c =: programId)  AND US_Terms__c != 'Summer')];
		}		
		else 
		{
			 records = [FIND :searchTerm IN NAME FIELDS RETURNING Course__c(Id WHERE Id IN (SELECT Course__c FROM Program_Course__c WHERE Program__c =: programId) AND US_Terms__c includes ('Summer'))];
		}
    	//List<Course__c> courses = Database.query('Select Id, Name, Course_Title_2__c, Course_Code__c, Course_Description_Short__c, Host_Credits__c, US_Semester_Credit_Hours__c, Butler_Department_Code__c, Host_Institution__c, Host_Institution__r.Id, Host_Institution__r.Name from Course__c where Name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'and Id IN (SELECT Course__c FROM Program_Course__c WHERE Program__c = \'' + programId  + '\')');
		List<Course__c> courses = [SELECT Id, Name, Course_Title_2__c, Course_Code__c, Course_Description_Short__c, Host_Credits__c, US_Semester_Credit_Hours__c, US_Terms__c, Butler_Department_Code__c, Host_Institution__c, Host_Institution__r.Id, Host_Institution__r.Name, (SELECT Id, Location_of_Instruction__r.Name FROM Course_Locations__r) FROM Course__c WHERE Approved_for_CHART__c = TRUE AND Id IN: records[0]];
        return courses;
    }
	/**
	 * @description Retrieves course registrations for the student' application.
	 * @param applicationId The Id of the application
	 * @return the list of appropriate course registrations.
	 */
	@RemoteAction
	public static List<studentOnSiteCourseRegViewModel> getCourseRegistrations(String applicationId)
	{
		List<studentOnSiteCourseRegViewModel> courses = new List<studentOnSiteCourseRegViewModel>();
		ifsaApplicationWrapper studentApplication = new ifsaApplicationWrapper(applicationId);
        List<ifsaCourseRegistrationWrapper> courseRegistrations = studentApplication.getCourseRegistrations();

		for(ifsaCourseRegistrationWrapper courseRegistration : courseRegistrations)
        {
            courses.add(courseRegistration.populateViewModel(new studentOnSiteCourseRegViewModel()));
        }

		return courses;
	}
	
	@RemoteAction
	public static List<Course__c> getChildClasses(String courseId)
	{
		List<Course__c> courses = [SELECT Id, Course_Title_2__c, Host_Institution__c, Host_Credits__c, US_Semester_Credit_Hours__c FROM Course__c WHERE Parent_Generic_Course__c =: courseId];
		if(courses.isEmpty())
		{
			return null;
		}
		return courses;
	}
	
	@RemoteAction
	public static Map<String, Object> checkForExistingCourse(String jsonData)
	{
		System.debug('jsonData => ' + jsonData);
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
		Map<String, Object> response = new map<String, Object>();
		List<List<sObject>> courseSOSL = new List<List<sObject>>();
		List<Course__c> coursesFromCode = new List<Course__c>();
		Boolean checkCodeFlag = true;
		
		response.put('Payload', new List<Object>());
		response.put('ErrMsg', null);
		response.put('Status', null);
		// Need to search for course matches using SOSL on course name and SOQL on course code
		String courseTitle = (String) m.get('courseTitle');
		String searchParam = courseTitle.length() > 80 ? courseTitle.left(80) : courseTitle;
		String courseCode = (String) m.get('courseCode');
		checkCodeFlag = courseCode != null;
		Id hostInstitutionId = (Id) m.get('hostInstitutionId');
		courseSOSL = [FIND :searchParam IN NAME FIELDS RETURNING Course__c(Id, Name, Course_Title_2__c, Course_Code__c, Host_Credits__c, Host_Institution__c, Host_Institution__r.Name, Course_Description_Short__c, US_Semester_Credit_Hours__c, US_Terms__c WHERE Host_Institution__c =: hostInstitutionId)];
		system.debug(courseSOSL);
		//If courseCode provided already exists in the returned SOSL no need to query for it.
		for(Course__c course : (List<Course__c>)courseSOSL[0]){
			if(course.Course_Code__c == courseCode){
				checkCodeFlag = false;
			}
		}
		//check checkCodeFlag to avoid duplication in list
		if(checkCodeFlag){
			coursesFromCode = [SELECT Id, Name, Course_Title_2__c, Course_Code__c, Host_Credits__c, Host_Institution__c, Course_Description_Short__c, US_Semester_Credit_Hours__c FROM Course__c WHERE Course_Code__c = :courseCode AND Host_Institution__c =: hostInstitutionId];
			system.debug(coursesFromCode);
		}
		if(!courseSOSL.isEmpty()){
			response.put('Payload', (List<Course__c>)courseSOSL[0]);
			response.put('Status', 'Found Courses');
		}

		List<Course__c> tempList = (List<Course__c>)response.get('Payload');
		if(!coursesFromCode.isEmpty() && checkCodeFlag){
			if(tempList.isEmpty()){
				response.put('Payload', coursesFromCode);
				response.put('Status', 'Found Courses');
			}
			else{
				//List<Course__c> tempList = (List<Course__c>)response.get('Payload');
				tempList.addAll(coursesFromCode);
				response.put('Payload', tempList);
				response.put('Status', 'Found Courses');
			}
		}
		// If neither queries return results run the method below. Otherwise return results in map.
		tempList = (List<Course__c>)response.get('Payload');
		if(tempList.isEmpty()){
			response = submitCourse(jsonData);
		}

		return response;
	}
	@RemoteAction
	public static Map<String, Object> submitCourse(String jsonData)
	{
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
		Map<String, Object> response = new map<String, Object>();
		response.put('Status', null);
		response.put('Payload', null);
		response.put('ErrMsg', null);
		response.put('ExtraInfo', null);
		Course__c newCourse = new Course__c();		
		
		newCourse.Course_Title_2__c = (String) m.get('courseTitle');
		newCourse.Name = newCourse.Course_Title_2__c.length() > 80 ? newCourse.Course_Title_2__c.left(80) : newCourse.Course_Title_2__c;
		newCourse.Course_Code__c = (String) m.get('courseCode');
		newCourse.Host_Credits__c = (Decimal) m.get('courseCredits');
		newCourse.Host_Institution__c = (Id) m.get('hostInstitutionId');
		newCourse.Course_Description_Short__c = 'Description coming soon';
		newCourse.OwnerId = [SELECT User_Id__c FROM IFSA_Default_User__mdt WHERE Label = 'Course Owner'].get(0).User_Id__c;
		newCourse.RecordTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Host Institution').getRecordTypeId();
		try {
			if(Database.insert(newCourse).isSuccess()){
				response.put('Status', 'Success');
				response.put('Payload', newCourse);
				// Attempt to create Program_Course__c record
				try {
					List<Program_Option__c> programOptions = [SELECT Id, Name, Program__c FROM Program_Option__c WHERE Program__c =: (Id) m.get('programId')];
					if(programOptions.isEmpty())
					{
						Database.insert(new Program_Course__c(Course__c = newCourse.Id, Program__c = (Id) m.get('programId')));
						response.put('ExtraInfo', 'Save Program Course for Course: ' + newCourse.Course_Title_2__c + ' Program ID: ' + (String) m.get('programId'));
					}
					else
					{
						Application__c app = [SELECT Name, Program_Term__r.Name FROM Application__c WHERE Id =: (Id) m.get('applicationId')];
						for(Program_Option__c po: programOptions)
						{
							if(app.Program_Term__r.Name.containsIgnoreCase(po.Name))
							{
								Database.insert(new Program_Course__c(Course__c = newCourse.Id, Program__c = po.Program__c, Program_Option__c = po.Id));
								response.put('ExtraInfo', 'Save Program Course for Course: ' + newCourse.Course_Title_2__c + ' Program ID: ' + (String) m.get('programId') + 'Program Option ID: ' + po.Id);
							}
						}
					}
				}
				catch (Exception e) {
					response.put('ExceptionMessage', e.getMessage());
					response.put('ExtraInfo', 'Unable to create Program_Course__c record for' + newCourse.Course_Title_2__c);
				}
				// Attempt to create Course_Location__c record
				
				try {
					Id locationId = (Id) m.get('locationId');
					if(locationId != null)
					{
						Database.insert(new Course_Location__c(Course__c = newCourse.Id, Location_Of_Instruction__c = locationId));
						response.put('ExtraInfo_CourseLocation', 'Saved Course Location for Course: ' + newCourse.Course_Title_2__c + ' Location of Instruction ID: ' + locationId);
					}
				} catch (Exception e) {
					response.put('ExceptionMessage_CourseLocation', e.getMessage());
					response.put('ExtraInfo', 'Unable to create Course_Location__c record for' + newCourse.Course_Title_2__c);
				}
			}
			else
			{
				response.put('Status', 'Failed');
				response.put('ExtraInfo', 'Unable to save course');
			}
		} catch (DmlException e) {
			response.put('Status', 'Failed');
			response.put('ErrMsg', e.getMessage());
		}
		System.debug(response);
		return response;
	}

	@RemoteAction 
	public static Boolean submitSyllabus(String courseId, String fileData, String fileType, String fileName)
	{
		if(fileData != null && fileName != null && fileType != null && fileData != '' && fileName != '' && fileType != '')
	    {
	    	try
	    	{
				// Create the Content Version
				Course__c c = [SELECT Id, Course_Title_2__c FROM Course__c WHERE Id =: courseId];
				Blob file = EncodingUtil.base64Decode(fileData);
				ContentVersion v = new ContentVersion();
				v.versionData = file;
				v.title = 'Syllabus - ' + c.Course_Title_2__c;
				v.pathOnClient = '\\' + v.title + '.' + fileName.subStringAfterLast('.');
				v.FirstPublishLocationId = courseId;
				v.NetworkId = [SELECT Id FROM Network WHERE Name = 'Student Portal'].get(0).Id;
				insert(v);
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
	public static Map<String, Object> getCRFConfiguration(String programTermName)
	{	
		Map<String, Object> results = new Map<String, Object>();
		try{
			
			Program_Term__c pt = [SELECT Id, RecordType.Name, Parent_Program_Term__c, CRF_Cutoff_Date__c, Is_CRF_Editable__c, Program__r.Request_Syllabi__c, Program__r.CRF_Require_Spanish_Title__c FROM Program_Term__c WHERE Name =: programTermName];
			Boolean poWithoutDates = pt.RecordType.Name == 'Program Option without Dates' ? true : false;
			Boolean poWithDates = pt.RecordType.Name == 'Program Option with Dates' ? true : false;
			System.debug('poWithDates: ' + poWithDates);
			Id pptId = pt.Parent_Program_Term__c;
			System.debug('pptId: ' + pptId);
			// Prgram Option without Dates
			if(poWithoutDates && pptId != null){
				System.debug('Record Type: Program Option without Dates');
				// Pull dates and Program fields from Parent Program Term
				Program_Term__c ppt = [SELECT CRF_Cutoff_Date__c, Is_CRF_Editable__c, Program__r.Request_Syllabi__c, Program__r.CRF_Require_Spanish_Title__c FROM Program_Term__c WHERE Id = :pptId];
				results.put('Request_Syllabi__c', ppt.Program__r.Request_Syllabi__c);
				results.put('CRF_Require_Spanish_Title__c', ppt.Program__r.CRF_Require_Spanish_Title__c);
				results.put('CRF_Cutoff_Date__c', ppt.CRF_Cutoff_Date__c);
				results.put('CRF_Editable__c', ppt.Is_CRF_Editable__c);
			}
			// Program Option with Dates
			else if(poWithDates && pptId != null){
				System.debug('Record Type: Program Option with Dates');
				// Pull dates from PO and pull Program fields from Parent Program Term
				Program_Term__c ppt = [SELECT Program__r.Request_Syllabi__c, Program__r.CRF_Require_Spanish_Title__c FROM Program_Term__c WHERE Id = :pptId];
				results.put('Request_Syllabi__c', ppt.Program__r.Request_Syllabi__c);
				results.put('CRF_Require_Spanish_Title__c', ppt.Program__r.CRF_Require_Spanish_Title__c);
				results.put('CRF_Cutoff_Date__c', pt.CRF_Cutoff_Date__c);
				results.put('CRF_Editable__c', pt.Is_CRF_Editable__c);
			}
			// Standard Program Term
			else {
				System.debug('Record Type: Standard Program Term');
				// Pull dates from Program Term
				results.put('Request_Syllabi__c', pt.Program__r.Request_Syllabi__c);
				results.put('CRF_Require_Spanish_Title__c', pt.Program__r.CRF_Require_Spanish_Title__c);
				results.put('CRF_Cutoff_Date__c', pt.CRF_Cutoff_Date__c);
				results.put('CRF_Editable__c', pt.Is_CRF_Editable__c);
			}
			results.put('Success', true);
			results.put('Not_Registered_Reason__c', apexConversionUtility.getPicklistStringValues(Course_Registration__c.Not_Registered_Reason__c));
			results.put('Other_Class_Reason__c', apexConversionUtility.getPicklistStringValues(Course_Registration__c.Other_Class_Reason__c));
			
		}
		catch(Exception e) {
			results.put('Success', false);
			results.put('Error_Message', e.getMessage());
		}		
		return results;
	}

	@RemoteAction
	public static Course__c modifyCourseRegistration(String CId) {
		Course__c childCourse = new Course__c();
		if (CId != null) {
			childCourse = [SELECT Id, 
								  Course_Title_2__c, 
								  Course_Code__c, 
								  Host_Institution__r.Name, 
								  Host_Credits__c, 
								  US_Semester_Credit_Hours__c
							 FROM Course__c
				 		    WHERE Id = :CId];
			
		} 
		return childCourse;
	}




    // END OF COURSE METHODS
    // START OF CONTACT INFO METHODS
    /**
	 * @description Saves the students abroad phone number.
	 * @param phoneNumber The string of the phone number.
	 * @param studentId The string of the student's contact record Id
	 * @return A Boolean The results of the save.
	 */
	@RemoteAction
	public static Boolean updateAbroadPhoneNumber(String phoneNumber, String countryId, String studentId)
	{
		Map<String, String> result = new Map<String, String>();
		Contact c = new Contact(Id = studentId, Address_Abroad_Cell_Phone__c = phoneNumber, Abroad_Cell_Phone_Country__c = countryId);
		try
		{
			database.update(c);
			return true;
		}
		catch (Exception e)
		{
			return false;
		}
		//return false;
	}
    // END OF CONTACT INFO METHODS
    // Start of Trip Methods
	/**
	 * @description Saves a new trip
	 * @param jsonData - JSON serialized trip object to save
	 * @param JSON serialized trip object that has been saved
	 */
	@RemoteAction
	public static string saveTrip(String jsonData)
	{
		model_trip trip = new model_trip();
		if(jsonData == null)
		{
			return null;
		}
		try
		{
			//Unescape the json string
			jsonData = jsonData.unescapeEcmaScript();
			//Remove leading and trailing '"' characters			
			jsonData = jsonData.removeStart('"');
			jsonData = jsonData.removeEnd('"');
			jsonData = jsonData.replace('\n', '\\n');
			//jsonData = jsonData.replaceAll('T04:00:00.000Z', '');
			system.debug(jsonData);			
		  	trip = (model_trip) JSON.createParser(jsonData).readValueAs(Type.forName('model_trip'));

		  	return trip.save();
		}
		catch(Exception e)
		{
		  System.debug(LoggingLevel.ERROR, e.getMessage());
		  return e.getMessage();
		}
	}
	
	/**
	 * @description Deletes a trip
	 * @param tripId - Id of the trip to delete
	 * @param Success of the method
	 */
	@RemoteAction
	public static Boolean deleteTrip(String tripId)
	{
		try
		{
			Trip__c t = new Trip__c();
			t.Id = tripId;
			Database.delete(t);
			return true;
		}
		catch(Exception e)
		{
		  System.debug(LoggingLevel.ERROR, e.getMessage());
		  return false;
		}
	}
	@RemoteAction
	public static List<model_trip> getTrips(String applicationId)
	{
		List<model_trip> returnList = new List<model_trip>();
		List<Trip__c> trips = apexQueryUtility.selectAllFrom('Trip__c', 'Trip_Phone_Country__r.Name', 'Application__c=\'' + applicationId + '\' AND Status__c != \'Canceled\'');
		for(Trip__c t: trips)
        {
			returnList.add(new model_trip(t));
        }
		return returnList;
	}
	// End of Trip Methods
	// Start of Housing Methods
	@RemoteAction
	public static studentOnSiteViewModel getHousingInfo(String applicationId)
	{
		studentOnSiteViewModel viewModel = new studentOnSiteViewModel();
		ifsaApplicationWrapper studentApplication = new ifsaApplicationWrapper(applicationId);
		Housing_Assignment__c housingAssignment = (Housing_Assignment__c) apexQueryUtility.selectAllFrom('Housing_Assignment__c', 'Country__r.Country_Code__c', 'Id = \'' + studentApplication.getHousingAssignmentId() + '\'').get(0);
		viewModel.cellPhone = housingAssignment.Cell_Phone__c;
        viewModel.country = housingAssignment.Country__r.Country_Code__c;
        viewModel.dependentLocality = housingAssignment.Dependent_Locality__c;
        viewModel.description = housingAssignment.Description__c;
        viewModel.displayName = housingAssignment.Display_Name__c;
        viewModel.email = housingAssignment.Email__c;
        viewModel.housingAssignmentId = housingAssignment.Id;
        viewModel.housingOption = housingAssignment.Housing_Option__c;
        viewModel.landline = housingAssignment.Landline__c;
        viewModel.locality = housingAssignment.Locality__c;
        viewModel.street1 = housingAssignment.Street_1__c;
        viewModel.street2 = housingAssignment.Street_2__c;
        viewModel.zipCode = housingAssignment.Zip_Code__c;
        viewModel.photos = getHousingPhotos(housingAssignment.Id);    

        return viewModel;        
    }

    private static List<studentOnSitePhotosViewModel> getHousingPhotos(Id housingAssignmentId)
    {
        List<studentOnSitePhotosViewModel> photos = new List<studentOnSitePhotosViewModel>();

        List<Attachment> attach = [SELECT Id, Name, Body, BodyLength, Description FROM Attachment WHERE ParentID =: housingAssignmentId];
        for(Attachment a: attach)
        {
            studentOnSitePhotosViewModel photo = new studentOnSitePhotosViewModel();
            //photo.image = EncodingUtil.Base64Encode(a.body);
            photo.text = a.Description;
            //https://c.na34.content.force.com/servlet/servlet.FileDownload?file=00P61000004vO3C
            photo.url = a.Id;
            //system.debug(photo.url);
            photos.add(photo);
        }

        return photos;
	}
	// End of Housing Methods
}