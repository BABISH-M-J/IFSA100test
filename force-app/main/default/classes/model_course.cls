public without sharing class model_course extends model_base
{
	private Course__c courseRecord;
	public Boolean approvedForChart { get; set; }
	public String butlerDepartmentCodeId { get; set; }
	public String butlerDepartmentCode { get; set; }
	public Boolean capstoneCourseOrProject { get; set; }
	public String city { get; set; }
	public Boolean communityBasedLearning { get; set; }
	public String contactHours { get; set; }
	public String country { get; set; }
	public String courseCode { get; set; }
	public String courseDeliveryMethod { get; set; }
	public String courseDescription { get; set; }
	public String courseDescriptionShort { get; set; }
	public List<Course_Equivalency__c> courseMatches { get; set; }
	public String courseOutline { get; set; }
	public String courseTitle { get; set; }
	public String createdById { get; set; }
	public DateTime createdDate { get; set; }
	public String credits { get; set; }
	public String departmentCode { get; set; }
	public Boolean directedResearch { get; set; }
	public Boolean ePortfoilio { get; set; }
	public String evaluationMethod { get; set; }
	public String expirationReason { get; set; }
	public String externalNotes { get; set; }
	public Boolean fieldStudyVisits { get; set; }
	public List<ContentDocumentLink> files { get; set; }
	public Decimal hostCredits { get; set; }
	public String hostInstitutionId { get; set; }
	public String hostInstitutionName { get; set; }
	public Boolean internship { get; set; }
	public Boolean isExpired { get; set; }
	public Boolean isIFSAClass { get; set; }
	public Boolean isTop20 { get; set; }
	public String knownPreReqsAndRestrictions {get;set;}
	public String labHours { get; set; }
	public Boolean labComponent { get; set; }
	public String languageOfInstruction { get; set; }
	public String languageOfInstructionOther { get; set; }
	public String lastModifiedById { get; set; }
	public DateTime lastModifiedDate { get; set; }
	public DateTime lastRegisteredDate { get; set; }
	public String lastRenewed { get; set; }
	public String lastRenewedById { get; set; }
	public DateTime lastRenewedDate { get; set; }
	public Boolean learningCommunities { get; set; }
	public String marketingRegion { get; set; }
	public String ownerId { get; set; }
	public Boolean popularClass {get; set; }
	public Boolean professionalDevelopmentProject { get; set; }
	public List<model_program> programs { get; set; }
	public String recordTypeId { get; set; }
	public String recordTypeName { get; set; }
	public String resourcesReadings { get; set; }
	public Boolean serviceLearning { get; set; }
	public Boolean specialPermissionRequired { get; set; }
	public String studentLearningObjectives { get; set; }
	public Boolean studioArt { get; set; }
	public String syllabusLink { get; set; }
	public String syllabusType { get; set; }
	public Set<model_tag> tags { get; set; }
	public Boolean teachingPracticum { get; set; }
	public String untranslatedCourseTitle { get; set; }
	public String usCredits { get; set; }
	public Decimal usSemesterCreditHours { get; set; }
	public String usTerms { get; set; }
	public Boolean volunteering { get; set; }
	public Boolean writingIntensive { get; set; }
	public String yearInForeignDegreePlan { get; set; }
	public String yearInForeignDegreePlanOther { get; set; }
	public List<Course_Location__c> courseLocations { get; set; }
	

	public model_course() 
	{
		this.programs = new List<model_program>();
		this.tags = new Set<model_tag>();
		this.files = new List<ContentDocumentLink>();
		this.courseMatches = new List<Course_Equivalency__c>();
		this.courseLocations = new List<Course_Location__c>();
	}
	public model_course(String courseId)
	{
		this(courseId, chartRemoteMethods.getHomeInstitutionAccount());
	}
	public model_course(String courseId, String accountId)
	{
		this((Course__c) apexQueryUtility.selectAllFrom('Course__c', 'Butler_Department_Code__r.Name, Host_Institution__r.Name, Host_Institution__r.Country__r.Name, Host_Institution__r.Country__r.Marketing_Region__c, Host_Institution__r.Locality__r.Name, RecordType.Name, (SELECT Id, Location_of_Instruction__c, Location_of_Instruction__r.Name, Location_of_Instruction__r.City__r.Name, Location_of_Instruction__r.Country__c FROM Course_Locations__r ORDER BY Location_of_Instruction__r.City__r.Name), (SELECT Id, Course__c, Program__c, Program__r.Name, Program_Option__c, Program_Option__r.Name, Program_Academic_URL_Semester__c, Program_Academic_URL_Summer__c FROM Program_Courses__r WHERE Program__c IN '+ apexQueryUtility.buildInClause(chartRemoteMethods.getApprovedPrograms(accountId)) + ' ORDER BY Program__r.Name, Program_Option__r.Name), (SELECT Id, ContentDocument.Description, ContentDocument.Title, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLinks WHERE ContentDocument.Title LIKE \'%Syllabus%\' ORDER BY ContentDocument.ContentModifiedDate LIMIT 1), (SELECT Id, Status__c, Last_Approved_Rejected_By__r.Name, Last_Approved_Rejected__c, Home_Institution_Course__c, Home_Institution_Course__r.Name, Home_Institution_Course__r.Home_Institution_Account__c, Home_Institution_Course__r.Course_Code__c FROM Course_Equivalencies__r WHERE Status__c != \'Not a Match\' AND Home_Institution_Course__r.Home_Institution_Account__c = \'' + accountId + '\' ORDER BY Status__c DESC)', 'Id = \'' + courseId + '\'').get(0));
	}
	
	public model_course(Course__c c)
	{
		this();
		courseRecord = c;
		approvedForChart = (Boolean) populateField('Approved_For_CHART__c');
		butlerDepartmentCodeId = (String) populateField('Butler_Department_Code__c');
		butlerDepartmentCode = (String) populateField('Butler_Department_Code__r.Name');
		capstoneCourseOrProject = (Boolean) populateField('Capstone_Course_or_Project__c');
		city = (String) populateField('Host_Institution__r.Locality__r.Name');
		communityBasedLearning = (Boolean) populateField('Community_Based_Learning__c');
		contactHours = (String) populateField('Contact_Hours__c');
		country = (String) populateField('Host_Institution__r.Country__r.Name');
		courseCode = (String) populateField('Course_Code__c');
		courseDeliveryMethod = (String) populateField('Course_Delivery_Method__c');
		courseDescription = (String) populateField('Course_Description__c');
		courseDescriptionShort = (String) populateField('Course_Description_Short__c');
		courseOutline = (String) populateField('Course_Outline__c');
		courseTitle = (String) populateField('Course_Title_2__c');
		createdById = (String) populateField('CreatedById');
		createdDate = (DateTime) populateField('CreatedDate');
		credits = (String) populateField('Credits__c');
		departmentCode = (String) populateField('Department_Code__c');
		directedResearch = (Boolean) populateField('Directed_Research__c');
		ePortfoilio = (Boolean) populateField('e_Portfolio__c');
		evaluationMethod = (String) populateField('Evaluation_Method__c');
		expirationReason = (String) populateField('Expiration_Reason__c');
		externalNotes = (String) populateField('External_Notes__c');
		fieldStudyVisits = (Boolean) populateField('Field_Study_Visits__c');
		hostCredits = (Decimal) populateField('Host_Credits__c');
		hostInstitutionId = (String) populateField('Host_Institution__c');
		hostInstitutionName = (String) populateField('Host_Institution__r.Name');
		internship = (Boolean) populateField('Internship__c');
		isExpired = (Boolean) populateField('Is_Expired__c');
		isIFSAClass = (Boolean) populateField('Is_IFSA_Class__c');
		isTop20 = (Boolean) populateField('Is_Top_20_Most_Popular__c');
		knownPreReqsAndRestrictions = (String) populateField('Known_Pre_requisites_and_Restrictions__c');
		labHours = (String) populateField('Lab_Hours__c');
		labComponent = (Boolean) populateField('Laboratory_Component__c');
		languageOfInstruction = (String) populateField('Language_of_Instruction__c');
		languageOfInstructionOther = (String) populateField('Language_of_Instruction_Other__c');
		lastModifiedById = (String) populateField('LastModifiedById');
		lastModifiedDate = (DateTime) populateField('LastModifiedDate');
		lastRegisteredDate = (DateTime) populateField('Last_Registered_Date__c');
		lastRenewed = (String) populateField('Last_Renewed__c');
		lastRenewedById = (String) populateField('Last_Renewed_By__c');
		lastRenewedDate = (DateTime) populateField('Last_Renewed_Date__c');
		learningCommunities = (Boolean) populateField('Learning_Communities__c');
		marketingRegion = (String) populateField('Host_Institution__r.Country__r.Marketing_Region__c');
		ownerId = (String) populateField('OwnerId');
		popularClass = (Boolean) populateField('Popular_Class__c');
		professionalDevelopmentProject = (Boolean) populateField('Professional_Development_Project__c');
		recordTypeId = (String) populateField('RecordTypeId');
		recordTypeId = (String) populateField('RecordType.Name');
		resourcesReadings = (String) populateField('Resources_Readings__c');
		serviceLearning = (Boolean) populateField('Service_Learning__c');
		specialPermissionRequired = (Boolean) populateField('Special_Permission_Required__c');
		studentLearningObjectives = (String) populateField('Student_Learning_Objectives__c');
		studioArt = (Boolean) populateField('Studio_Art__c');
		syllabusLink = (String) populateField('Syllabus_Link__c');
		syllabusType = (String) populateField('Syllabus_Type__c');
		teachingPracticum = (Boolean) populateField('Teaching_Practicum__c');
		untranslatedCourseTitle = (String) populateField('Untranslated_Course_Title__c');
		usCredits = (String) populateField('US_Credits__c');
		usSemesterCreditHours = (Decimal) populateField('US_Semester_Credit_Hours__c');
		usTerms = (String) populateField('US_Terms__c');
		volunteering = (Boolean) populateField('Volunteering__c');
		writingIntensive = (Boolean) populateField('Writing_Intensive__c');
		yearInForeignDegreePlan = (String) populateField('Year_in_Degree_Plan__c');
		yearInForeignDegreePlanOther = (String) populateField('Year_in_Degree_Plan_Other__c');

		System.debug(courseRecord.Program_Courses__r.size());
		for(Program_Course__c pc: courseRecord.Program_Courses__r)
		{
			Program__c p = new Program__c(Id = pc.Program__c, Name = pc.Program__r.Name);
			model_program mp = new model_program(p);
			mp.programOptionId = pc.Program_Option__c;
			mp.programOptionName = pc.Program_Option__r.Name;
			mp.academicURLSemester = pc.Program_Academic_URL_Semester__c;
			mp.academicURLSummer = pc.Program_Academic_URL_Summer__c;
			mp.selectedInSearch = true;
			programs.add(mp);

		}
		for(Tag__c t: courseRecord.Tags__r)
		{
			model_tag mt = new model_tag(t);
			mt.selectedInSearch = true;
			tags.add(mt);
		}
		courseLocations = courseRecord.Course_Locations__r;
		if(!c.ContentDocumentLinks.isEmpty())
		{
			files = c.ContentDocumentLinks;
		}
		if(!c.Course_Equivalencies__r.isEmpty())
		{
			courseMatches = c.Course_Equivalencies__r;
		}

		setBaseValues();
	}
	/**
	 * @description Dynamically populates property in model
	 * @param fieldName - The field name from Course__c
	 * @return Object - The value from the field
	 */
	private Object populateField(String fieldName)
	{
		try
		{
			system.debug('FieldName: ' + fieldName);
			switch on fieldName
			{
				when 'Butler_Department_Code__r.Name'
				{
					return courseRecord.Butler_Department_Code__r.Name;
				}
				when 'Host_Institution__r.Locality__r.Name'
				{
					return courseRecord.Host_Institution__r.Locality__r.Name;
				}
				when 'Host_Institution__r.Country__r.Name'
				{
					return courseRecord.Host_Institution__r.Country__r.Name;
				}
				when 'Host_Institution__r.Country__r.Marketing_Region__c'
				{
					return courseRecord.Host_Institution__r.Country__r.Marketing_Region__c;
				}
				when 'Host_Institution__r.Name'
				{
					return courseRecord.Host_Institution__r.Name;
				}
				when 'RecordType.Name'
				{
					return courseRecord.RecordType.Name;
				}
				when else
				{
					Object field = courseRecord.get(fieldName);
					if(field instanceof String)
					{
						String output = (String) field;
						field = output.unescapeHtml4();
					}
					return field;
				}
			}
		}
		catch (SObjectException ex)
		{
			super.consoleErrorMessage(ex);
		}
		return null;
	}

	private void setBaseValues() 
	{
		this.recordId = courseRecord.Id;
		this.recordName = courseRecord.Name;
		this.sObjectName = 'Course__c';
	}

	public override Boolean equals(Object o)
	{
		if(o instanceof model_course)
		{
			model_course obj = (model_course)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
	public String getJSONSerializedModel()
	{
		return JSON.serialize(this);
	}

	public static List<model_course> convertCoursesToModel(List<Course__c> courses)
	{
		List<model_course> results = new List<model_course>();

		for(Course__c c: courses)
		{
			results.add(new model_course(c));
		}
		system.debug(results[0]);
		return results;
	}
}