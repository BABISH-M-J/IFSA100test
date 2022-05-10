public without sharing class model_courseMatchingProject extends model_base
{
	private CMP__c projectRecord;
	public String academicAdvisorEmail { get; set; }
	public String additionalDetails { get; set; }
	public String additionalInformation { get; set; }
	public String contactId { get; set; }
	public DateTime completedDate { get; set; }
	public DateTime lastViewedDate { get;set; }
	public String degreeReqs { get; set; }
	public String facultyNames { get; set; }
	public String firstName { get; set; }
	public String lastName { get; set; }
	public String email { get; set; }
	public String homeInstitutionAccountId { get; set; }
	public String homeInstitutionName { get; set; }
	public Boolean includeDirectedResearch { get; set; }
	public Boolean includeInternshipOptions { get; set; }
	public Boolean includeNonApprovedPrograms { get; set; }
	public String major { get; set; }
	public List<String> regionsOfInterest { get; set; }
	public String specificCountriesYesNo { get; set; }
	public List<String> specificCountries { get; set; }
	public List<String> specificPrograms { get; set; }
	public String status { get; set; }
	public DateTime submittedDate { get; set; }
	public String summaryOfResults { get; set; }
	public List<String> termsAbroad { get; set; }
	public String yearInSchool { get; set; }
	public List<String> yearsAbroad { get; set; }
	public String type { get; set; }
	public String description { get; set; }
	public List<model_courseEquivalency> courseEquivalencies { get; set; }
	public String title { get; set; }
	public List<model_course> homeClasses {get;set;}

	public model_courseMatchingProject() 
	{
		regionsOfInterest = new List<String>();
		specificCountries = new List<String>();
		specificPrograms = new List<String>();
		yearsAbroad = new List<String>();
		termsAbroad = new List<String>();
		includeDirectedResearch = false;
		includeInternshipOptions = false;
		homeClasses = new List<model_course>();
	}
	
	public model_courseMatchingProject(Id projectId)
	{
		this((CMP__c) apexQueryUtility.selectAllFrom('CMP__c', 'RecordType.Name, Home_Institution_Account__r.Name, (SELECT Id, Course_Equivalency__c FROM CMP_Course_Equivalencies__r), (SELECT Id, Country__r.Name FROM CMP_Countries__r), (SELECT Id, Program__r.Name FROM CMP_Programs__r)', 'Id = \'' + projectId + '\'').get(0));
		List<Id> ceIds = new List<Id>();
		for(CMP_Course_Equivalency__c cmpCE: projectRecord.CMP_Course_Equivalencies__r)
		{
			ceIds.add(cmpCE.Course_Equivalency__c);
		}
		List<Course_Equivalency__c> CEs = [SELECT Id, Name, Home_Institution_Course__c, Home_Institution_Course__r.Course_Code__c, Home_Institution_Course__r.Course_Title_2__c, Host_Institution_Course__c, Host_Institution_Course__r.Course_Title_2__c, Host_Institution_Course__r.Course_Code__c, Host_Institution_Course__r.US_Terms__c, Host_Institution_Course__r.Host_Institution__r.Name, Host_Institution_Course__r.Host_Institution__r.Country__r.Name, Status__c, Denied_Reason__c, Denied_Reason_Other__c, Home_Institution_Course__r.Year_in_Degree_Plan__c, Home_Institution_Course__r.US_Terms__c, CMP_of_Home_Course_Request__c, Last_Approved_Rejected_By__r.Name, Last_Approved_Rejected__c FROM Course_Equivalency__c WHERE Id IN: ceIds];
		courseEquivalencies = model_courseEquivalency.getModelsFromList(CEs);
	}
	
	public model_courseMatchingProject(CMP__c cmp)
	{
		this();
		System.debug(cmp);
		projectRecord = cmp;
		academicAdvisorEmail = cmp.Academic_Advisor_Email__c;
		additionalDetails = cmp.Additional_Details__c;
		additionalInformation = cmp.Additional_Information__c;
		completedDate = cmp.Completed_Date__c;
		lastViewedDate = cmp.Last_Viewed_Date__c;
		contactId = cmp.Contact__c;
		degreeReqs = cmp.Degree_Requirements__c;
		facultyNames = cmp.Faculty_Names__c;
		homeInstitutionAccountId = cmp.Home_Institution_Account__c;
		homeInstitutionName = cmp.Home_Institution_Account__r.Name;
		includeDirectedResearch = cmp.Include_Directed_Research__c;
		includeInternshipOptions = cmp.Include_Internship_Options__c;
		includeNonApprovedPrograms = cmp.Include_Non_Approved_Programs__c;
		major = cmp.Major__c;
		regionsOfInterest = cmp.Regions__c != null ? cmp.Regions__c.split(';') : null;
		for(CMP_Country__c c: cmp.CMP_Countries__r)
		{
			specificCountries.add(c.Country__r.Name);
		}
		for(CMP_Program__c p: cmp.CMP_Programs__r)
		{
			specificPrograms.add(p.Program__r.Name);
		}
		status = cmp.Status__c;
		submittedDate = cmp.CreatedDate;
		summaryOfResults = cmp.Summary_of_Results__c;
		termsAbroad = cmp.Terms_Abroad__c != null ? cmp.Terms_Abroad__c.split(';') : null;
		yearInSchool = cmp.Year_in_School__c;
		yearsAbroad = cmp.Years_Abroad__c != null ? cmp.Years_Abroad__c.split(';') : null;
		switch on cmp.RecordType.Name
		{
			when 'Course Equivalency'
			{
				type = 'CE';
			}
			when 'Curriculum Integration'
			{
				type = 'CI';
			}
		}
		//courseEquivalencies = model_courseEquivalency.getModelsFromList(cmp.Course_Equivalencies__r);
		title = cmp.Title__c;
		setBaseValues();
		
	}
	
	public String getJSONSerializedModel()
	{
		return JSON.serialize(this);
	}
	public void convertToCMP(Boolean isInsert)
	{
		CMP__c cmp = new CMP__c();
		if(!isInsert)
		{
			cmp.Id = recordId;
		}
		else
		{
			cmp.Contact__c = contactId;
			Account a = [SELECT Id, Name FROM Account WHERE Name =: homeInstitutionName].get(0);
			switch on type
			{
				when 'CE'
				{
					cmp.RecordTypeId = Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Course Equivalency').getRecordTypeId();
					//cmp.Name = 'New Class Equivalency for ' + cmp.Contact__c;
					cmp.Home_Institution_Account__c = a.Id;
				}
				when 'CI'
				{
					cmp.RecordTypeId = Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Curriculum Integration').getRecordTypeId();
					//cmp.Name = 'New Curriculum Integration for ' + major + ' at ' + a.Name;
					cmp.Home_Institution_Account__c = a.Id;
				}
			}
		}
		cmp.Academic_Advisor_Email__c = academicAdvisorEmail;
		cmp.Additional_Information__c = additionalInformation;
		cmp.Degree_Requirements__c = degreeReqs;
		cmp.Faculty_Names__c = facultyNames;
		cmp.Include_Directed_Research__c = includeDirectedResearch ? true : false;
		cmp.Include_Internship_Options__c = includeInternshipOptions ? true : false;
		cmp.Include_Non_Approved_Programs__c = includeNonApprovedPrograms ? true : false;
		cmp.Major__c = major;
		String roi = '';
		for(string region: regionsOfInterest)
		{
			if(roi.length() < 1)
			{
				roi = region;
			}
			else
			{
				roi = roi + ';' + region;
			}
		}
		cmp.Regions__c = roi;
		cmp.Status__c = status;
		cmp.Summary_of_Results__c = summaryOfResults;
		system.debug(termsAbroad);
		for(String t: termsAbroad)
		{
			if(cmp.Terms_Abroad__c != null)
			{
				cmp.Terms_Abroad__c = cmp.Terms_Abroad__c + ';' + t;
			}
			else
			{
				cmp.Terms_Abroad__c = t;
			}
		}
		cmp.Year_in_School__c = yearInSchool;
		system.debug(yearsAbroad);
		for(String y: yearsAbroad)
		{
			if(cmp.Years_Abroad__c != null)
			{
				cmp.Years_Abroad__c = cmp.Years_Abroad__c + ';' + y;
			}
			else
			{
				cmp.Years_Abroad__c = y;
			}
		}
		switch on type
		{
			when 'CE'
			{
				cmp.RecordTypeId = Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Course Equivalency').getRecordTypeId();
			}
			when 'CI'
			{
				cmp.RecordTypeId = Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Curriculum Integration').getRecordTypeId();
			}
		}

		System.debug(cmp);

		Database.UpsertResult uResult = Database.upsert(cmp);
		cmp = (CMP__c) apexQueryUtility.selectAllFrom('CMP__c', 'Id = \'' + uResult.getId() + '\'').get(0);
		Id homeClassRT = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId();
		if(uResult.isSuccess() && isInsert)
		{
			recordId = uResult.getId();
			List<Country__c> countries = [SELECT Id, Name FROM Country__c WHERE Name IN: specificCountries];
			List<Program__c> programs = [SELECT Id, Name FROM Program__c WHERE Name IN: specificprograms];
			List<SObject> objects = new List<SObject>();
			for(Country__c c: countries)
			{
				objects.add(new CMP_Country__c(Course_Matching_Project__c = uResult.getId(), Country__c = c.Id));
			}
			for(Program__c p: programs)
			{
				objects.add(new CMP_Program__c(Course_Matching_Project__c = uResult.getId(), Program__c = p.Id));
			}
			List<String> courseNames = new List<String>();
			List<String> courseCodes = new List<String>();
			for(model_course c: homeClasses)
			{
				courseNames.add(c.courseTitle);
				courseCodes.add(c.courseCode);
			}
			List<Course__c> existingCourses = [SELECT Id, Name, Course_Title_2__c, Course_Code__c, (SELECT Id FROM Course_Equivalencies1__r) FROM Course__c WHERE RecordTypeId =: homeClassRT AND Home_Institution_Account__c =: cmp.Home_Institution_Account__c AND Name IN: courseNames AND Course_Code__c IN: courseCodes];
			for(model_course c: homeClasses)
			{
				Boolean hasCourse = false;
				for(Course__c course: existingCourses)
				{
					hasCourse = c.courseTitle == course.Course_Title_2__c && c.courseCode == course.Course_Code__c ? true : hasCourse;
				}
				if(!hasCourse)
				{
					objects.add(new Course__c(RecordTypeId = homeClassRT, Name = c.courseTitle, Course_Title_2__c = c.courseTitle, Course_Code__c = c.courseCode, Home_Institution_Account__c = cmp.Home_Institution_Account__c));
				}					
			}
			Database.SaveResult[] srs = database.insert(objects);
			List<Course_Equivalency__c> newCEs = new List<Course_Equivalency__c>();
			for(Database.SaveResult sr: srs)
			{
				if(sr.isSuccess() && sr.getId().getSobjectType().getDescribe().getName() == 'Course__c')
				{
					newCEs.add(new Course_Equivalency__c(Home_Institution_Course__c = sr.getId()));
				}
			}
			List<CMP_Course_Equivalency__c> newCMPCEs = new List<CMP_Course_Equivalency__c>();
			if(!newCEs.isEmpty())
			{
				Database.SaveResult[] ceSR = Database.insert(newCEs);
				
				if(ceSR[0].isSuccess())
				{
					for(Course_Equivalency__c ce: newCEs)
					{
						newCMPCEs.add(new CMP_Course_Equivalency__c(Course_Matching_Project__c = cmp.Id, Course_Equivalency__c = ce.Id));
					}
				}
			}
			if(!existingCourses.isEmpty())
			{
				for(Course__c c: existingCourses)
				{
					for(Course_Equivalency__c ce: c.Course_Equivalencies1__r)
					{
						newCMPCEs.add(new CMP_Course_Equivalency__c(Course_Matching_Project__c = cmp.Id, Course_Equivalency__c = ce.Id));
					}
				}
			}
			if(!newCMPCEs.isEmpty())
			{
				Database.SaveResult[] cmpCESR = Database.insert(newCMPCEs);
			}		
		}
	}

	private void setBaseValues() 
	{
		this.recordId = projectRecord.Id;
		this.recordName = projectRecord.Title__c;
		this.sObjectName = 'CMP__c';
		
	}

	public override Boolean equals(Object o)
	{
		if(o instanceof model_courseMatchingProject)
		{
			model_courseMatchingProject obj = (model_courseMatchingProject)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}