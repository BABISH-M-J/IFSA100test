/**
 * Holds common @RemoteAction annotated static methods used by CHART
 * All Javascript Remoting Methods for CHART should be located in this class. All methods should return an 
 * instance of <<chartJSRemotingResponse>>. Please look at the class <<chartJSRemotingResponse>> to understand how 
 * it works. There are a number of different constructors to use based on the situation.
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public without sharing class chartRemoteMethods 
{	
	/**
	 * Constructor to enable use with any IFSA controllers.
	 */
	public chartRemoteMethods(ifsaBaseController controller){}

	/**
	 * Gets CMPs for a user. If the user is a student, this will be limited to just their CMPs, otherwise adivsor users can see all CMPs for their home institution and CMPs requested by students at their institution
	 * @return  <<chartJSRemotingResponse>> with either the queried CMP records in the payload or an error code
	 */
	@RemoteAction
	public static chartJSRemotingResponse getCMPs() 
	{
		try
		{
			List<CMP__c> cmps = new List<CMP__c>();
			User u = [SELECT Id, Name, Profile.Name, ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()];

			if(u.Profile.Name.contains('Student'))
			{
				cmps = [SELECT Id, Name, Title__c, Status__c, RecordTypeId, RecordType.Name, Home_Institution_Account__r.Name, Home_Institution_Account__c, Major__c, Completed_Date__c, Last_Viewed_Date__c, CreatedDate FROM CMP__c WHERE Contact__c =: u.ContactId AND Status__c != 'Canceled'];
			}
			else if(u.Profile.Name.contains('Advisor'))
			{
				cmps = [SELECT Id, Name, Title__c, Status__c, RecordTypeId, RecordType.Name, Home_Institution_Account__r.Name, Home_Institution_Account__c, Major__c, Completed_Date__c, Last_Viewed_Date__c, CreatedDate FROM CMP__c WHERE Home_Institution_Account__c =: u.Contact.AccountId AND ((RecordType.Name = 'Curriculum Integration' AND Status__c != 'Canceled') OR (RecordType.Name = 'Course Equivalency' AND Status__c = 'Completed'))];
			}

			return new chartJSRemotingResponse(cmps);
		}
		catch(Exception e)
		{
			return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_2002, e);
		}
	}

	/**
	 * Saves a CMP request
	 * @param  jsonData JSON string representing the CMP request
	 * @return          <<chartJSRemotingResponse>> with either success marked true or an error code
	 */
	@RemoteAction
	public static chartJSRemotingResponse saveCMPRequest(String jsonData)
	{
		if(jsonData == null || jsonData == '')
		{
			return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_2003);
		}
		
		try
		{
			system.debug(jsonData);
			model_courseMatchingProject model = (model_courseMatchingProject) JSON.createParser(jsonData).readValueAs(Type.forName('model_courseMatchingProject'));
			system.debug(model);
			try
			{
				model.convertToCMP(true);
			}
			catch (Exception e)
			{
				System.debug(e.getMessage());
				return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_2003, e);
			}
		}
		catch (Exception e)
		{
			System.debug(e.getMessage());
			return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_2003, e);
		}
		return new chartJSRemotingResponse(true);
	}
    /**
	 * Gets the details of a course record
	 * @param  courseId  The Id of the course to get the details of
	 * @param  accountId The Id of the Account record. This is passed only when an internal user is researching courses
	 * @return           <<chartJSRemotingResponse>> with either the course record in the payload or an error code
	 */
	 @RemoteAction
    public static chartJSRemotingResponse getCourse(String courseId, String accountId)
    {
		try 
		{
			// When an internal user is getting course's detail, in the context of a CMP, the home school account id will not be null
			if(accountId != null && accountId != '')
			{
				return new chartJSRemotingResponse(new model_course(courseId, accountId));
			}
			return new chartJSRemotingResponse(new model_course(courseId));
		}
		catch (Exception e) 
		{
		   return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_1002, e);
		}
    }
	@RemoteAction
    /**
	 * Gets minimum course details for an array of course Ids, passes null for cmpId for backwards compatability
	 * @param  courseIds                The course record Ids to retreive
	 * @param  homeInstitutionAccountId The current user's home institution's account Id or the home institution in which an internal user is doing CI/CE research
	 * @return                          <<chartJSRemotingResponse>> with either the course records in the payload or an error code
	 */
    public static chartJSRemotingResponse getCourses(String[] courseIds, String homeInstitutionAccountId)
    {
		return getCoursesExtended(courseIds, homeInstitutionAccountId, null);
	}
    @RemoteAction
    /**
	 * Gets minimum course details for an array of course Ids
	 * @param  courseIds                The course record Ids to retreive
	 * @param  homeInstitutionAccountId The current user's home institution's account Id or the home institution in which an internal user is doing CI/CE research
	 * @param  cmpId 					The the Id of the current cmp project, can be null
	 * @return                          <<chartJSRemotingResponse>> with either the course records in the payload or an error code
	 */
    public static chartJSRemotingResponse getCoursesExtended(String[] courseIds, String homeInstitutionAccountId, String cmpId)
    {
		// Get courses
		if(courseIds.isEmpty()){
			return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_1001, new NullPointerException());
		}
        try 
		{
			User u = getUserRecord();
			CMP__c cmp;
			if(cmpId != null)
			{
				cmp = [SELECT Id, Home_Institution_Account__c, Contact__c, Home_Institution_Account__r.Name, Home_Institution_Account__r.Course_Equivalency_Search__c FROM CMP__c WHERE Id =: cmpId];
			}
			if(homeInstitutionAccountId == null)
			{
				homeInstitutionAccountId = getHomeInstitutionAccount();
			}
			List<Course__c> courses = [
				SELECT Id, Name, Course_Description_Short__c, Is_Expired__c, Expiration_Reason__c, Is_IFSA_Class__c, Is_Top_20_Most_Popular__c, Popular_Class__c, Course_Title_2__c, Untranslated_Course_Title__c, Host_Institution__c, Host_Institution__r.Name, Host_Institution__r.Country__c, Host_Institution__r.Country__r.Name, Host_Institution__r.Country__r.Marketing_Region__c, Host_Institution__r.Locality__c, Host_Institution__r.Locality__r.Name, Course_Code__c, US_Terms__c, Host_Credits__c, US_Semester_Credit_Hours__c, Capstone_Course_or_Project__c, Community_Based_Learning__c, Directed_Research__c, e_Portfolio__c, Field_Study_Visits__c, Internship__c, Laboratory_Component__c, Learning_Communities__c, Professional_Development_Project__c, Service_Learning__c, Studio_Art__c, Teaching_Practicum__c, Volunteering__c, Writing_Intensive__c, Known_Pre_requisites_and_Restrictions__c, Language_of_Instruction__c,
					(SELECT Id, Location_of_Instruction__c, Location_of_Instruction__r.Name, Location_of_Instruction__r.City__r.Name, Location_of_Instruction__r.Country__c FROM Course_Locations__r ORDER BY Location_of_Instruction__r.City__r.Name),
					(SELECT Id, Course__c, Name, Area_Of_Study__c, Department__c FROM Tags__r), 
					(SELECT Id, Course__c, Program__c, Program__r.Name, Program_Academic_URL_Semester__c, Program_Academic_URL_Summer__c, Program_Option__r.Name, Program_Option__c FROM Program_Courses__r WHERE Program__c IN: chartRemoteMethods.getApprovedPrograms(homeInstitutionAccountId, cmpId != null ? cmp : null) AND Program__r.Active__c = TRUE),
					(SELECT Id, Status__c, Home_Institution_Course__c FROM Course_Equivalencies__r WHERE Status__c != 'Not a Match' AND Home_Institution_Course__r.Home_Institution_Account__c =: homeInstitutionAccountId),
					(SELECT Id, Course__c FROM Favorites__r WHERE Contact__c =: u.ContactId)
				FROM Course__c 
				WHERE Id IN: courseIds
			];
			return new chartJSRemotingResponse(courses);
		} 
		catch (Exception e) 
		{
			   return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_1001, e);
		}
    }
	/**
	 * Gets the Ids of all of the programs that a home institution approves by default passes false for second parameter (isCMP)
	 * @param  homeInstAccountId The Id of the home institution
	 * @return                   List of program ids that the home school approves
	 */
	public static List<Id> getApprovedPrograms(Id homeInstAccountId)
	{
		return getApprovedPrograms(homeInstAccountId, null);
	}

    /**
	 * Gets the Ids of all of the programs that a home institution approves
	 * @param  homeInstAccountId The Id of the home institution
	 * @param  isCMP			 True when an internal user is searching courses for CMP, otherwise should be false
	 * @return                   List of program ids that the home school approves
	 */
    public static List<Id> getApprovedPrograms(Id homeInstAccountId, CMP__c cmp)
    {
        Set<Id> programIds = new Set<Id>();
		User u = getUserRecord();
		if(cmp != null || homeInstAccountId == null || u.Profile.Name == 'IFSA Student User')
		{
			if(u.Profile.Name == 'IFSA Student User' || cmp != null)
			{
				Id contactId = u.ContactId;
				
				if(cmp != null)
				{
					contactId = cmp.Contact__c;
				}
				else if(homeInstAccountId == null)
				{
					homeInstAccountId = getHomeInstitutionAccount();
				}
				for(Application__c app: [SELECT Program_Term__r.Program__c FROM Application__c WHERE Applicant__c =: contactId AND Status__c IN ('Program Selected', 'Ready To Submit', 'Submitted', 'Accepted', 'Accepted (with Conditions)', 'On Site')])
				{
					programIds.add(app.Program_Term__r.Program__c);
				}
			}
			else
			{
				homeInstAccountId = getHomeInstitutionAccount();
			}			
		}
        for(Program_Authorization__c pa : [SELECT Id, Program__c, Account__c, Term__c, Show_Unauthorized_Program_In_CHART__c FROM Program_Authorization__c WHERE Account__c =: homeInstAccountId AND Is_Active__c = TRUE])
        {
            
            if(pa.Term__c != 'Not Approved' || (pa.Term__c == 'Not Approved' && pa.Show_Unauthorized_Program_In_CHART__c && !u.Profile.Name.contains('Student')))
            {
                programIds.add(pa.Program__c);
            }
        }
        return new List<Id>(programIds);
    }
	
	/**
	 * Gets the details of a course matching program
	 * @param  projectId Id of the course matching project to retrieve
	 * @return           <<chartJSRemotingResponse>> with either the CMP record in the payload or an error code
	 */
	 @RemoteAction
	public static chartJSRemotingResponse getCMPDetails(Id projectId)
	{
		try 
		{
			model_courseMatchingProject project = new model_courseMatchingProject(projectId);
			if(project.status == 'Completed')
			{
				//Update the last view date
				CMP__c cmp = new CMP__c(Id = projectId, Last_Viewed_Date__c = DateTime.now());
				database.update(cmp);
			}
			return new chartJSRemotingResponse(project);
		}
		catch (Exception e) 
		{
			return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_2002, e);
		}
		
	}

	
	/**
	 * Adds a course to a course matching project, used by internal users doing CI/CE research. This creates a course 
	 * equivalency record if one does not already exist for the host institution course and the account and then creates 
	 * a CMP_Course_Equivalency__c record between the new or existing Course_Equivalency__c record and the CMP__c record
	 * @param  courseId The Id of the host institution course to add to the project
	 * @param  cmpId    The Id of the course matching project
	 * @return          <<chartJSRemotingResponse>> with either success marked true or an error code
	 */
	 @RemoteAction
	public static chartJSRemotingResponse addCourseToCMP(String courseId, String cmpId)
	{
		CMP__c cmp = [SELECT Id, Home_Institution_Account__c FROM CMP__c WHERE Id =: cmpId];
		List<Course_Equivalency__c> ces = [SELECT Id, Host_Institution_Course__c FROM Course_Equivalency__c WHERE Host_Institution_Course__c =: courseId AND Home_Institution_Course__r.Home_Institution_Account__c =: cmp.Home_Institution_Account__c];
		Course_Equivalency__c ce;
		if(ces.isEmpty())
		{
			ce = new Course_Equivalency__c(Host_Institution_Course__c = courseId);
			try {
				database.insert(ce);
			} catch (Exception e) {
			return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_3004, e);
			}
		}
		else
		{
			ce = ces.get(0);  
		}
		CMP_Course_Equivalency__c cmpCE = new CMP_Course_Equivalency__c(Course_Matching_Project__c = cmpId, Course_Equivalency__c = ce.Id);
		try {
			database.insert(cmpCE);
			return new chartJSRemotingResponse(true);
		} catch (Exception e) {
			return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_3006, e);
		}
		
	}
	
	/**
	 * Adds multiple courses to a course matching project, used by internal users doing CI/CE research. This creates a course 
	 * equivalency records if one does not already exist for the host institution course and the account and then creates a 
	 * CMP_Course_Equivalency__c record between the new or existing Course_Equivalency__c record and the CMP__c record
	 * @param  courseIds The Ids of host institution courses to add to a CMP__c
	 * @param  cmpId     The Id of the CMP__c to add the courses to/
	 * @return           <<chartJSRemotingResponse>> with either success marked true or an error code
	 */
	 @RemoteAction
	public static chartJSRemotingResponse addCoursesToCMP(String[] courseIds, String cmpId)
	{
		System.debug(courseIds);
		Set<String> courseIdsSet = new Set<String>(courseIds);
		CMP__c cmp = [SELECT Id, Home_Institution_Account__c FROM CMP__c WHERE Id =: cmpId];
		List<Course_Equivalency__c> ces = [SELECT Id, Host_Institution_Course__c FROM Course_Equivalency__c WHERE Host_Institution_Course__c IN: courseIds AND Home_Institution_Course__r.Home_Institution_Account__c =: cmp.Home_Institution_Account__c];
		List<CMP_Course_Equivalency__c> cmpCEs = new List<CMP_Course_Equivalency__c>();
		List<Course_Equivalency__c> newCEs = new List<Course_Equivalency__c>();
		for(Course_Equivalency__c ce: ces)
		{
			if(courseIdsSet.contains(ce.Host_Institution_Course__c))
			{
				cmpCEs.add(new CMP_Course_Equivalency__c(Course_Matching_Project__c = cmpId, Course_Equivalency__c = ce.Id));
				courseIdsSet.remove(ce.Host_Institution_Course__c);
			}			
		}
		for(String courseId: courseIdsSet)
		{
			newCEs.add(new Course_Equivalency__c(Host_Institution_Course__c = courseId));
		}
		try {
		   database.insert(newCEs);
		   for(Course_Equivalency__c ce: newCEs)
		   {
			   cmpCEs.add(new CMP_Course_Equivalency__c(Course_Matching_Project__c = cmpId, Course_Equivalency__c = ce.Id));
		   }
		} catch (Exception e) {
		   return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_3005, e);
		}
		try {
		   database.insert(cmpCEs);
		   return new chartJSRemotingResponse(true);
		} catch (Exception e) {
		   return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_3007, e);
		}
	}
	/**
	 * Updates the field 'Status__c' on a Course_Equivalency__c record. The update is timestamped with the user who made the change
	 * @param  jsonData JSON string representing the Course_Equivalency__c record
	 * @return          <<chartJSRemotingResponse>> with either success marked true or an error code
	 */
	@RemoteAction
	public static chartJSRemotingResponse saveCourseEquivalents(String jsonData)
	{
		List<model_courseEquivalency> ceModels = new List<model_courseEquivalency>();
		List<Course_Equivalency__c> ceRecords = new List<Course_Equivalency__c>();
		// Convert jsonData to List of model_courseEquivalency
		System.debug(jsonData);
		ceModels = (List<model_courseEquivalency>) JSON.deserialize(jsonData, List<model_courseEquivalency>.class);

		// Convert each model_courseEquivalency to Course_Equivalency__c record
		for(model_courseEquivalency ceModel: ceModels)
		{
			System.debug(ceModel);
			Course_Equivalency__c ce = new Course_Equivalency__c(Id = ceModel.recordId, Status__c = ceModel.status, Denied_Reason__c = ceModel.deniedReason , Denied_Reason_Other__c = ceModel.deniedReasonOther, Last_Approved_Rejected__c = Datetime.now(), Last_Approved_Rejected_By__c = UserInfo.getUserId());

			System.debug(ce);
			ceRecords.add(ce);
		}
		// Attempt to update Course_Equivalency__c records
		System.debug(ceRecords);
		try {
			if(ceRecords.isEmpty())
			{
				throw new System.ListException();
			}
			Database.update(ceRecords);
			return new chartJSRemotingResponse(true);
		}
		catch(Exception e) {
			return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_2005, e);
		}
	}

	/**
	 * Retrieves all course equivalency records for a home institution
	 * @return   <<chartJSRemotingResponse>> with either the retreived course equivalency records in the payload or an error code
	 */
	@RemoteAction
	public static chartJSRemotingResponse getAllCourseEquivalents(String[] courseIds) 
	{
		try 
		{
			List<Course_Equivalency__c> aces = new List<Course_Equivalency__c>();
			User u = [SELECT Id, Name, Profile.Name, ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()];

			if(u.Profile.Name.contains('Advisor'))
			{
				//
				//aces = [SELECT Id, Home_Institution_Course__c, Home_Institution_Course__r.Name, Home_Institution_Course__r.Course_Code__c, Home_Institution_Course__r.Home_Institution_Account__c, Host_Institution_Course__c, Host_Institution_Course__r.Name, Host_Institution_Course__r.Course_Code__c, Host_Institution_Course__r.US_Terms__c, Host_Institution_Course__r.Host_Institution__r.Name, Status__c FROM Course_Equivalency__c WHERE Home_Institution_Course__r.Home_Institution_Account__c =: u.Contact.AccountId];
				aces = apexQueryUtility.selectAllFrom('Course_Equivalency__c', 'Home_Institution_Course__r.Course_Title_2__c, Home_Institution_Course__r.Course_Code__c, Home_Institution_Course__r.Home_Institution_Account__c, Home_Institution_Course__r.US_Terms__c, Host_Institution_Course__r.Course_Title_2__c, Host_Institution_Course__r.Course_Code__c, Host_Institution_Course__r.US_Terms__c, Host_Institution_Course__r.Host_Institution__r.Name, Host_Institution_Course__r.Host_Institution__r.Country__r.Name, Last_Approved_Rejected_By__r.Name', 'Home_Institution_Course__r.Home_Institution_Account__c = \'' +  u.Contact.AccountId + '\' AND Host_Institution_Course__c IN ' + apexQueryUtility.buildInClause(courseIds));
			}

			return new chartJSRemotingResponse(model_courseEquivalency.getModelsFromList(aces));
		} 
		catch (Exception e) 
		{
		   return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_2006, e);
		}
		
	}

	/**
	 * Updates field 'Course_Equivalency_Search__c' on Account. Changes are timestamped with the user who made the change.
	 * @param  ceSearch              The updated value for Course_Equivalency_Search__c
	 * @param  userId                The Id of the user making the change
	 * @param  userHomeInstitutionId The Id of the home insitution account to make the change to
	 * @return                       <<chartJSRemotingResponse>> with either the updated account record in the payload or an error code
	 */
	@RemoteAction
	public static chartJSRemotingResponse updateCESearch(Boolean ceSearch, Id userId, Id userHomeInstitutionId)
	{
		// Account a = [SELECT Id, Course_Equivalency_Search__c, CE_Search_Last_Updated__c, CE_Search_Last_Updated_By__c, CE_Search_Last_Updated_By__r.Name FROM Account WHERE Id =: userHomeInstitutionId LIMIT 1];
		// if(a != null)
		// {
		// 	try 
		// 	{
		// 		a.Course_Equivalency_Search__c = ceSearch;
		// 		a.CE_Search_Last_Updated__c = datetime.now();
		// 		a.CE_Search_Last_Updated_By__c = userId;
		// 		Database.update(a);
		// 		return new chartJSRemotingResponse(a);
		// 	} 
		// 	catch (Exception e) 
		// 	{
		// 	   	return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_2004, e);
		// 	}
		// }

		// return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_2004);

		// Use userHomeInstitutionId to update ceToggle values on the Home Institution Account
		try
		{
			Account a  = new Account();
			a.Id = userHomeInstitutionId;
			a.Course_Equivalency_Search__c = ceSearch;
			a.CE_Search_Last_Updated__c = datetime.now();
			a.CE_Search_Last_Updated_By__c = userId;
			Database.update(a);
			return new chartJSRemotingResponse(a);
		}
		catch (Exception e) 
		{
			return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_2004, e);
		}
	}

	/**
	 * Gets the Id of the current user's Home Institution Account
	 * @return   The Id of the current user's Home Institution Account
	 */
	public static Id getHomeInstitutionAccount()
	{
		User u = getUserRecord();
		if(u.IsPortalEnabled)
		{
			if(u.Profile.Name.contains('Student')){
				return [SELECT Home_Institution__r.Account__c FROM Contact WHERE Id =: getUserRecord().ContactId].get(0).Home_Institution__r.Account__c;
			} else /*if(u.Profile.Name.contains('Advisor'))*/{
				return [SELECT AccountId FROM Contact WHERE Id =: getUserRecord().ContactId].get(0).AccountId;
			}	
		}
		else
		{
			
		}
		return null;
	}
	
	/**
	 * Gets the current user's user record
	 * @return   The User record
	 */
	public static User getUserRecord()
	{
		return [SELECT Id, UserName, Name, ContactId, Profile.Name, IsPortalEnabled  FROM User WHERE Id =: UserInfo.getUserId()].get(0);
	}

	public static Id getUserContactId()
	{
		User u = getUserRecord();
		return u.ContactId;
	}
	
	/**
	 * Creates a new home instituiton course record and links it to a host institution course record with a course equivalency record. If an
	 * internal user is working on a CMP, the Id of the CMP will be provided and CMP_Course_Equivalancy__c record will be created. The status 
	 * of the CE record will be 'Potential Match' when created by an internal user and 'Match' when created by a home insitution advisor
	 * @param  jsonData     JSON string representing a new Home Insitution course
	 * @param  hostCourseId The Id of the host institution course that the new course will be equivalent too
	 * @param  cmpId        The Id of the CMP project, this will be null unless the user is an internal user.
	 * @return              <<chartJSRemotingResponse>> with either success marked true or an error code
	 */
	@RemoteAction
	public static chartJSRemotingResponse createNewHomeInstitutionCourseEquivalency(String jsonData, String hostCourseId, String cmpId)
	{
		// Convert JSON to Map<String, Object>
		Map<String, Object> newHomeCourseData = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
		System.debug(newHomeCourseData);
		// Create Course__c record from converted map data
		String courseName = (String) newHomeCourseData.get('CourseTitle');
		courseName = courseName.length() < 40 ? courseName : courseName.substring(0, 39);
		Course__c newHomeCourse = new Course__c();
		newHomeCourse.RecordTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId();
		newHomeCourse.Name = courseName;
		newHomeCourse.Course_Title_2__c = (String) newHomeCourseData.get('CourseTitle');
		newHomeCourse.Course_Description__c = (String) newHomeCourseData.get('CourseDescription');
		newHomeCourse.Course_Code__c = (String) newHomeCourseData.get('CourseCode');
		newHomeCourse.Home_Institution_Account__c = (String) newHomeCourseData.get('HomeInstitutionAccount');
		// Create Course_Equivalency__c record
		Course_Equivalency__c ce = new Course_Equivalency__c();
		// Query Course__c table for an existing record
		List<Course__c> existingCourse = [SELECT Id FROM Course__c WHERE Course_Title_2__c =: newHomeCourse.Course_Title_2__c AND Course_Code__c =: newHomeCourse.Course_Code__c AND Home_Institution_Account__c =: newHomeCourse.Home_Institution_Account__c AND RecordTypeId =: newHomeCourse.RecordTypeId];
		Database.SaveResult srNewHomeCourse;
		if(existingCourse.isEmpty())
		{
			// No existing records attempt to insert new record
			srNewHomeCourse = Database.insert(newHomeCourse);
			if(!srNewHomeCourse.isSuccess())
			{
				return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_3001);
			}
			// Assign new Course__c record Id to new Course_Equivalency__c record
			ce.Home_Institution_Course__c = srNewHomeCourse.getId();	
		}
		else
		{	
			// Existing record exists, assign it's Id to Course_Equivalency__c record
			ce.Home_Institution_Course__c = existingCourse.get(0).Id;
		}
		// Finish populating Course_Equivalency__c fields
		ce.Host_Institution_Course__c = hostCourseId;
		if(getUserRecord().Profile.Name.contains('Advisor'))
		{
			// If the user is an advisor user, then the CE is a full match
			ce.Status__c = 'Match';
			ce.Last_Approved_Rejected__c = Datetime.now();
			ce.Last_Approved_Rejected_By__c = UserInfo.getUserId();
		}		
		else
		{
			ce.Status__c = 'Potential Match';
		}

		// Attempt to insert new Course_Equivalency__c record
		Database.SaveResult srNewCe = Database.insert(ce);

		if(!srNewCe.isSuccess() && existingCourse.isEmpty())
		{
			// If we created a new home institution Course__c, delete it since the Course_Equivalency__c record failed
			Database.delete(srNewHomeCourse.getId());
			return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_3002);
		}
		else if(cmpId == null)
		{
			return new chartJSRemotingResponse(true);

		}

		//If cmpId != null link new Course_Equivalency__c with CMP__c record
		CMP_Course_Equivalency__c cmpCE = new CMP_Course_Equivalency__c();
		cmpCE.Course_Matching_Project__c = cmpId;
		cmpCE.Course_Equivalency__c = srNewCe.getId();
		// Atempt to insert new CMP_Course_Equivalency__c record

		Database.SaveResult srNewCMPCe = Database.insert(cmpCE);
		if(!srNewCMPCe.isSuccess())
		{
			// CMP_Course_Equivalency__c did not save, but the other objects did, let user know outcome
			return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_3003);
		}

		return new chartJSRemotingResponse(true);

	}
	/**
	 * Uploads a file containing class equivalencies
	 * @param fileData
	 * @param fileType
	 * @param fileName
	 * @return <<chartJSRemotingResponse
	 */
	@RemoteAction
	public static chartJSRemotingResponse uploadCEFile(String fileData, String fileType, String fileName)
	{
		if(fileData != null && fileType != null && fileData != '' && fileType != '')
	    {
			// Create task related to home institution account
			User u = [SELECT Id, Name, ContactId, Contact.Account.Name, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()];
			Task t = new Task(RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Uploaded File Task').getRecordTypeId());
			t.WhatId = u.Contact.AccountId;
			
			t.OwnerId = [SELECT User_Id__c FROM IFSA_Default_User__mdt WHERE DeveloperName = 'File_Upload_Task_Recipient'].get(0).User_Id__c;
			t.Subject = u.Name + ' at ' + u.Contact.Account.Name + ' has uploaded a course equivalency file';
			t.Status = 'Not Started';
			t.WhoId = u.ContactId;
	    	try
			{
				Database.insert(t);	
			}
			catch(Exception e)
			{
				System.debug(LoggingLevel.WARN, e.getMessage());
			    return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_4002);
			}
			try
	    	{
				// Convert file data from String
			    String fileExtension = fileName.substringAfterLast('.');
				String fileTitle = fileName.substringBeforeLast('.');
			    Attachment file = new Attachment(ParentId=t.Id, name=(fileTitle + '.' + fileExtension), ContentType=fileType, Body=EncodingUtil.base64Decode(fileData), OwnerId=t.OwnerId);
			    database.insert(file);
			    return new chartJSRemotingResponse(true);
		    }
	    	catch(Exception e)
	    	{
			    System.debug(LoggingLevel.WARN, e.getMessage());
				// If the attachment does not save, delete the task
				Database.delete(t.Id);
			    return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_4003);
		    }
	    }
	    return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_4001);
	}
	/**
	 * Gets a users favorite courses
	 * @return <<chartJSRemotingResponse
	 */
	@RemoteAction
	public static chartJSRemotingResponse getFavorites() 
	{
		try   
		{
			List<Favorite__c> favorites = new List<Favorite__c>();
			favorites = [SELECT Id, Name, Contact__c, Course__c, Course__r.Course_Title_2__c, Course__r.Course_Description_Short__c, CreatedDate FROM Favorite__c WHERE Contact__c =: getUserContactId()];

			return new chartJSRemotingResponse(favorites);
		}
		catch(Exception e)
		{
			return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_5000, e);
		}
	}
	/**
	 * Updates a users course favorite
	 * @param contactId
	 * @param courseId
	 * @param favoriteId
	 * @param isFavorite
	 * @return <<chartJSRemotingResponse
	 */
	@RemoteAction
	public static chartJSRemotingResponse updateFavorite(String contactId, String courseId, String favoriteId, Boolean isFavorite){

		if(isFavorite){
			// Delete existing favorite record
			try{
				Database.delete(favoriteId);
				return new chartJSRemotingResponse(true);
			}
			catch(Exception e)
			{
				System.debug(LoggingLevel.WARN, e.getMessage());
				return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_5000, e);
			}
		} else {
			// Create new favorite record
			Favorite__c fav = new Favorite__c();
			fav.Course__c = courseId;
			fav.Contact__c = contactId;
			
			try{
				System.debug(fav);
				Database.insert(fav);
				return new chartJSRemotingResponse(fav);
			}
			catch(Exception e)
			{
				System.debug(LoggingLevel.WARN, e.getMessage());
			    return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_5000, e);
			}
		}
	}
	/**
	 * Updates course equivalents for a specific course based on the users home institution
	 * @param courseId
	 * @param accountId
	 * @return <<chartJSRemotingResponse
	 */
	@RemoteAction
	public static chartJSRemotingResponse getCourseEquivalents(String courseId, String accountId)
	{
		try {
			if(accountId == null){
				accountId = getHomeInstitutionAccount();
			}
			
			List<Course_Equivalency__c> ces = apexQueryUtility.selectAllFrom('Course_Equivalency__c', 'Home_Institution_Course__r.Course_Title_2__c, Home_Institution_Course__r.Course_Code__c, Home_Institution_Course__r.Home_Institution_Account__c', 'Home_Institution_Course__r.Home_Institution_Account__c = \'' +  accountId + '\' AND Host_Institution_Course__c = \'' + courseId + '\'');	
            
			List<model_courseEquivalency> payload = model_courseEquivalency.getModelsFromList(ces);
			
			return new chartJSRemotingResponse(payload);
		} catch (Exception e) {
			System.debug(LoggingLevel.WARN, e.getMessage());
			return new chartJSRemotingResponse(chartJSRemotingResponse.errorCodes.CHART_ERROR_3008);
		}

	}
}