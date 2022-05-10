/**
 * Viewmodel for Cases primarily used by <<ifsaCaseController>> but also used by <<affectedComponentController>>
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class ifsaCaseViewModel extends portalBaseViewModel
{	
	// Properties
	@AuraEnabled public String accountId {get;set;}
	@AuraEnabled public String applicationId {get;set;}
	@AuraEnabled public model_Application application {get;set;}
	@AuraEnabled public String assetId {get;set;}
	@AuraEnabled public List<model_contact> affectedStudents {get;set;}
	@AuraEnabled public List<model_city> affectedCities {get;set;}
	@AuraEnabled public List<model_country> affectedCountries {get;set;}
	@AuraEnabled public List<model_hostInstitution> affectedHostInstitutions {get;set;}
	@AuraEnabled public List<model_homeInstitution> affectedHomeInstitutions {get;set;}
	@AuraEnabled public List<model_program> affectedPrograms {get;set;}
	@AuraEnabled public Boolean alcoholInvolved {get;set;}
	@AuraEnabled public List<model_task> activityHistory {get;set;}
	@AuraEnabled public List<String> categories {get;set;}
	@AuraEnabled public List<model_caseComment> caseComments {get;set;}
	@AuraEnabled public DateTime caseIncidentDateTime {get;set;}	
	@AuraEnabled public List<model_caseHistory> caseHistory {get;set;}
	@AuraEnabled public String caseId {get;set;}
	@AuraEnabled public String caseNumber {get;set;}
	@AuraEnabled public String caseOrigin {get;set;}
	@AuraEnabled public List<model_CaseTeamMember> caseTeam {get;set;}
	@AuraEnabled public List<String> caseTypes {get;set;}
	@AuraEnabled public List<model_country> countries {get;set;}
	@AuraEnabled public model_country country {get;set;}
	@AuraEnabled public DateTime createdDate {get;set;}
	@AuraEnabled public Boolean clearyAct {get;set;}
	@AuraEnabled public Boolean contactBoardOfDirectors {get;set;}
	@AuraEnabled public Boolean contactButlerPresident {get;set;}
	@AuraEnabled public Boolean contactHomeInstitution {get;set;}
	@AuraEnabled public Boolean contactNAC {get;set;}
	@AuraEnabled public String contactOther {get;set;}
	@AuraEnabled public Boolean contactParentEmergencyContact {get;set;}	
	@AuraEnabled public Boolean contactTitleIX {get;set;}
	@AuraEnabled public List<model_contactSupport>  homeInstitutionEmergencyContacts {get;set;}
	@AuraEnabled public List<model_contactSupport> contactSupportPersonnel {get;set;}
	@AuraEnabled public String closeComment {get;set;}
	@AuraEnabled public String closedReason {get;set;}
	@AuraEnabled public Datetime closedDate {get;set;}
	@AuraEnabled public Boolean closedWhenCreated {get;set;}
	@AuraEnabled public model_User createdBy {get;set;}
	@AuraEnabled public String currentUserEmail {get;set;}
	@AuraEnabled public String description {get;set;}
	@AuraEnabled public Boolean drugsInvolved {get;set;}
	@AuraEnabled public Boolean edit {get;set;}
	@AuraEnabled public List<ContentDocumentLink> files {get;set;}
	@AuraEnabled public model_hostInstitution hostInstitution {get;set;}
	@AuraEnabled public model_homeInstitution homeInstitution {get;set;}
	@AuraEnabled public Boolean hostUniversityProperty {get;set;}
	@AuraEnabled public Boolean ifsaProgramProperty {get;set;}	
	@AuraEnabled public Boolean ifsaInsuranceInvolved {get;set;}
	@AuraEnabled public String ifsaInsuranceCaseNumber {get;set;}
	@AuraEnabled public String incidentCategory {get;set;}
	@AuraEnabled public Boolean isClosed {get;set;}
	@AuraEnabled public model_city incidentCity {get;set;}
	@AuraEnabled public model_picklist incidentSeverity {get;set;}	
	@AuraEnabled public String incidentSubCategory {get;set;}
	@AuraEnabled public String incidentSubSubCategory {get;set;}
	@AuraEnabled public String incidentSubCategoryOther {get;set;}
	@AuraEnabled public String incidentSubSubCategoryOther {get;set;}
	@AuraEnabled public Boolean isEscalated {get;set;}
	@AuraEnabled public Boolean isIncident {get;set;}
	@AuraEnabled public Datetime lastModifiedDate {get;set;}
	@AuraEnabled public model_User lastModifiedBy {get;set;}
	@AuraEnabled public Boolean legalCounsel {get;set;}
	@AuraEnabled public Boolean liabilityInsuranceInvolved {get;set;}
	@AuraEnabled public String incidentLocation {get;set;}
	@AuraEnabled public List<String> incidentLocations {get;set;}	
	@AuraEnabled public Boolean mediaInvolved {get;set;}
	@AuraEnabled public Boolean minnesota {get;set;}
	@AuraEnabled public Boolean multipleStudents {get;set;}
	@AuraEnabled public model_caseComment newComment {get;set;}
	@AuraEnabled public List<model_task> openActivities {get;set;}
	@AuraEnabled public Boolean otherLocation {get;set;}
	@AuraEnabled public String otherLocationDetails {get;set;}
	@AuraEnabled public model_User owner {get;set;}
	@AuraEnabled public String ownerId {get;set;}
	@AuraEnabled public String parentCaseId {get;set;}
	@AuraEnabled public model_case parentCase {get;set;}
	@AuraEnabled public String priority {get;set;}
	@AuraEnabled public Boolean programExcursionsHotelLodging {get;set;}
	@AuraEnabled public model_program program {get;set;}
	@AuraEnabled public model_recordType recordType {get;set;}
	@AuraEnabled public List<model_recordType> recordTypes {get;set;}
	@AuraEnabled public List<model_Case> relatedCases {get;set;}
	@AuraEnabled public String status {get;set;}
	@AuraEnabled public List<String> statuses {get;set;}
	@AuraEnabled public List<model_picklist> severities {get;set;}
	@AuraEnabled public model_contact student {get;set;}
	@AuraEnabled public Boolean studentHousingHostFamily {get;set;}
	@AuraEnabled public String subject {get;set;}
	@AuraEnabled public List<String> subCategories {get;set;}
	@AuraEnabled public List<String> subSubCategories {get;set;}
	@AuraEnabled public String caseType {get;set;}
	@AuraEnabled public Boolean titleIX {get;set;}
	@AuraEnabled public Boolean vawa {get;set;}
	@AuraEnabled public Boolean weaponsInvolved {get;set;}
	@AuraEnabled public String workId {get;set;}
	@AuraEnabled public Boolean canChangeOwner {get;set;}
	@AuraEnabled public String caseTeamJobId {get;set;}

	// Constructors
	/**
	* Basic Constructor, initializes lists and sets default values
	*/
	public ifsaCaseViewModel()
	{
		//initialize lists
		affectedStudents = new List<model_contact>();
		affectedCountries = new List<model_country>();
		affectedCities = new List<model_city>();
		affectedHostInstitutions = new List<model_hostInstitution>();
		affectedHomeInstitutions = new List<model_homeInstitution>();
		affectedPrograms = new List<model_program>();
		activityHistory = new List<model_task>();
		caseHistory = new List<model_caseHistory>();
		openActivities = new List<model_task>();
		recordTypes = new List<model_recordType>();		
		caseComments = new List<model_caseComment>();
		caseTeam = new List<model_CaseTeamMember>();
		countries = new List<model_country>();
		files = new List<ContentDocumentLink>();
		relatedCases = new List<model_case>();
		contactSupportPersonnel = new List<model_contactSupport>();
		homeInstitutionEmergencyContacts = new List<model_contactSupport>();
		categories = apexConversionUtility.getPicklistStringValues(Case.Incident_Category__c);		
		statuses = apexConversionUtility.getPicklistStringValues(Case.Status);
		severities = apexConversionUtility.getPicklistModelValues(Case.Incident_Severity__c);
		caseTypes = apexConversionUtility.getPicklistStringValues(Case.Type);
		incidentLocations = apexConversionUtility.getPicklistStringValues(Case.Location__c);

		//initialize object models
		createdby = new model_User();
		country = new model_country();
		homeInstitution = new model_homeInstitution();
		hostInstitution = new model_hostInstitution();
		incidentCity = new model_city();
		lastModifiedBy = new model_User();
		parentCase = new model_case();
		owner = new model_User();
		program = new model_program();
		student = new model_contact();
		newComment = new model_caseComment();

		//Set default values
		this.status = 'New';
		this.edit = true;
		this.createdDate = null;
		this.currentUserEmail = UserInfo.getUserEmail();		

		Set<String> avalibleRecordTypes = new Set<String>(apexRecordTypeUtility.GetAvailableRecordTypeNamesForSObject(Case.SObjectType));

		List<RecordType> recordTypeList = [SELECT Id, Name, DeveloperName, Description FROM RecordType WHERE SObjectType = 'Case' AND IsActive = True];		
		for(RecordType rt: recordTypeList)
		{
			model_recordType recordType = new model_recordType(rt);
			/*recordType.recordTypeId = rt.Id;
			recordType.name = rt.Name;
			recordType.developerName = rt.DeveloperName;
			recordType.description = rt.Description;
			*/
			if(avalibleRecordTypes.contains(recordType.name))
				recordTypes.add(recordType);
		}
		
		Id regionId = [SELECT Id FROM Region__c WHERE Name = 'International Support' LIMIT 1].Id;		
		List<Country__c> countryRecords = [SELECT Id, Name FROM Country__c WHERE Region__c =: regionId AND Active__c = true ORDER BY Name];
		for(Country__c c: countryRecords)
		{
			model_country ctry = new model_country(c);
			this.countries.add(ctry);
		}
		canChangeOwner = false;
		Integer permset = [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name = 'Cases_Admin'];
		Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
		if(permset == 1 || userProfile.Name == 'System Administrator' || userProfile.Name == 'IFSA Health and Safety User')
		{
			canChangeOwner = true;
		}
	}
	/**
	* Constructor with case Id, initializes view model based on the selected case
	*/
	public ifsaCaseViewModel(String caseId)
	{
		// Start with the basic contstuctor
		this();
		//Get the case from Case ID
		this.caseId = caseId;		
		Case selectedCase = (Case) apexQueryUtility.selectAllFrom('Case', 'Parent.CaseNumber, Owner.Name', 'ID = \'' + caseId + '\'').get(0);
		// Determine the record type id
		if(selectedCase.RecordTypeId != null)
			this.getRecordTypeById(selectedCase.RecordTypeId);
		if(this.recordType.developerName == 'Academic_Appeal')
			this.getApplicationById(selectedCase.Application__c);
		// Determine if the case is closed
		this.isClosed = selectedCase.Status == 'Closed' ? true : false;
		// Related Lists
		// Get the Affected Students
		List<Case_Student__c> studentCases = [SELECT Id, Student__c, Reason_Affected__c, Student__r.Home_Institution__r.Account__c FROM Case_Student__c WHERE Case__c =: caseId];
		String inClause = apexQueryUtility.buildInClause(studentCases, 'Student__c');
		List<Id> hiAccounts = new List<Id>();
		Map<Id, Case_Student__c> studentIdAffectedStudent = new Map<Id, Case_Student__c>();
		for(Case_Student__c studentCase: studentCases)
		{
			hiAccounts.add(studentCase.Student__r.Home_Institution__r.Account__c);
			studentIdAffectedStudent.put(studentCase.Student__c, studentCase);
		}

		List<Contact> relatedContacts =  new List<Contact>();
		Boolean isPredeparture = false;
		if(inClause != null && (this.recordType.developerName != 'Pre_Departure' && this.recordType.developerName != 'Academic_Appeal'))
		{
			relatedContacts = apexQueryUtility.selectAllFrom('Contact', 
				'Home_Institution__r.Name, On_Site_Application__r.Program_Term__c, On_Site_Application__r.Is_Custom__c, On_Site_Application__r.Program_Term__r.Name, On_Site_Application__r.Program_Country__c, On_Site_Application__r.First_Departure__c, On_Site_Application__r.Program_Term__r.Start_Date__c, On_Site_Application__r.Program_Term__r.Parent_Program_Term__r.Start_Date__c, On_Site_Application__r.Program_Term__r.End_Date__c, On_Site_Application__r.Program_Term__r.Parent_Program_Term__r.End_Date__c, ' +
				'Active_Application__r.Program_Term__c, Active_Application__r.Is_Custom__c, Active_Application__r.Program_Term__r.Name, Active_Application__r.Program_Country__c, Active_Application__r.First_Departure__c, Active_Application__r.Program_Term__r.Start_Date__c, Active_Application__r.Program_Term__r.Parent_Program_Term__r.Start_Date__c, Active_Application__r.Program_Term__r.End_Date__c, Active_Application__r.Program_Term__r.Parent_Program_Term__r.End_Date__c', 'Id IN ' + inClause);
		}
		else if(inClause != null && this.recordType.developerName == 'Pre_Departure')			
		{
			relatedContacts = apexQueryUtility.selectAllFrom('Contact', 'Home_Institution__r.Name, Active_Application__r.Program_Term__c, Active_Application__r.Is_Custom__c, Active_Application__r.Program_Term__r.Name, Active_Application__r.Program_Country__c', 'Id IN ' + inClause);
			isPredeparture = true;
		}		
		Map<Id, Id> studentApplicationMap = new Map<Id,Id>();
		// Create a model_contact object for each affected student
		for(Contact c: relatedContacts)
		{
			model_contact mc = new model_contact(c);
			mc.tags.add(studentIdAffectedStudent.get(c.Id).Reason_Affected__c);
			if(!isPredeparture && c.On_Site_Application__r.Is_Custom__c)
				mc.tags.add('Custom');
			else if(isPredeparture && c.Active_Application__r.Is_Custom__c)
				mc.tags.add('Custom');
			else
				mc.tags.add('Catalog');

			this.affectedStudents.add(mc);
			if(this.recordType.developerName == 'Pre_Departure')
				studentApplicationMap.put(c.Id,c.Active_Application__c);
			else
				studentApplicationMap.put(c.Id,c.On_Site_Application__c);
		}
		// Other affected related objects
		if(this.recordType.developerName != 'Incident_Student' || this.recordType.developerName != 'Pre_Departure')
		{
			this.getRelatedObjects();
		}
		// Case Comments
		List<CaseComment> caseCommentRecords = apexQueryUtility.selectAllFrom('CaseComment', 'CreatedBy.FirstName, CreatedBy.LastName, LastModifiedBy.FirstName, LastModifiedBy.LastName', 'ParentId = \'' + caseId + '\'');
		for(CaseComment cc: caseCommentRecords)
		{
			this.caseComments.add(new model_caseComment(cc));
		}
		// Case Team
		List<CaseTeamMember> caseTeamRecords = apexQueryUtility.selectAllFrom('CaseTeamMember', 'TeamRole.Name, TeamRole.accesslevel, Member.Email, Member.FirstName, Member.LastName' , 'ParentId = \'' + caseId + '\' AND Member.IsActive = TRUE');
		for(CaseTeamMember ctm: caseTeamRecords)
		{
			this.caseTeam.add(new model_CaseTeamMember(ctm));
		}
		List<Case> relatedCaseRecords = apexQueryUtility.selectAllFrom('Case', 'Owner.Name', 'ParentId =\'' + caseId + '\'');
		for(Case c: relatedCaseRecords)
		{
			this.relatedCases.add(new model_Case(c));
			for(model_contact student: affectedStudents)
			{
				if(c.Student__c == student.contactId)
				{
					student.relatedCaseId = c.Id;
					student.relatedCaseNumber = c.CaseNumber;
				}
			}
		}
		// Student Parent/Guardian and Home Institution Emergency Contacts
		// Parent Guardian SELECT
		// SELECT id, name, support_personnel__c, account__c, cs_contact_support_personnel_id__c, contact__c, email__c, emergency_contact__c, home_institution__c, host_institution__c, phone__c, program_option__c, program_term__c, program__c, sp_plain_text_name__c, support_personnel_name__c, support_role_type_name__c, support_type_name__c, support_type__c, application__c, Contact__r.Name, Contact__r.Home_Institution__r.Name, Support_Personnel__r.Non_IFSA_Staff__c, Support_Personnel__r.Non_IFSA_Staff__r.Phone, Support_Personnel__r.Non_IFSA_Staff__r.Email FROM Contact_Support_Personnel__c WHERE Emergency_Contact__c = True AND Account__c = NULL AND Contact__c INnull
		// Home Institution SELECT
		// SELECT id, name, support_personnel__c, account__c, cs_contact_support_personnel_id__c, contact__c, email__c, emergency_contact__c, home_institution__c, host_institution__c, phone__c, program_option__c, program_term__c, program__c, sp_plain_text_name__c, support_personnel_name__c, support_role_type_name__c, support_type_name__c, support_type__c, application__c, Contact__r.Name, Contact__r.Created_for_Custom__c, Contact__r.Home_Institution__r.Name, Support_Personnel__r.Non_IFSA_Staff__c, Support_Personnel__r.Non_IFSA_Staff__r.Phone, Support_Personnel__r.Non_IFSA_Staff__r.Email FROM Contact_Support_Personnel__c WHERE (Emergency_Contact__c = True OR Account__c != NULL) AND Support_Personnel__r.Support_Role_Type__c != 'Parent/Guardian' AND Contact__c INnull
		//List<Contact_Support_Personnel__c> relatedCSP = apexQueryUtility.selectAllFrom('Contact_Support_Personnel__c', 'Contact__r.Name, Contact__r.Home_Institution__r.Name, Support_Personnel__r.Non_IFSA_Staff__c, Support_Personnel__r.Non_IFSA_Staff__r.Phone, Support_Personnel__r.Non_IFSA_Staff__r.Email' , 'Emergency_Contact__c = True AND Account__c = NULL AND Contact__c IN' + inClause);
		// Get the CSP records
		List<Contact_Support_Personnel__c> relatedCSP = [SELECT Id, Name, Support_Personnel__c, Support_Personnel__r.Account__r.Name, Contact__c, Support_Personnel__r.Email__c, 
															Support_Personnel__r.Emergency_contact__c, Support_Personnel__r.Home_institution__c, Support_Personnel__r.Host_institution__c, 
															Support_Personnel__r.Phone__c, Support_Personnel__r.Program_option__c, Support_Personnel__r.Program_Term__c, Support_Personnel__r.Program__c, 
															Support_Personnel__r.SP_Plain_Text_Name__c, Support_Personnel__r.Support_Personnel_Name__c, 
															Support_Personnel__r.Support_Role_Type__c, Support_Personnel__r.RecordType.Name, Support_Personnel__r.Support_Type__c, 
															Application__c, Contact__r.Name, Contact__r.Created_for_Custom__c, 
															Contact__r.Active_Application__r.Is_Custom__c, Contact__r.Active_Application__r.Program_Term__r.Name,
															Contact__r.Active_Application__r.Program_Country__c,
															Contact__r.On_Site_Application__r.Is_Custom__c, Contact__r.On_Site_Application__r.Program_Term__r.Name,
															Contact__r.On_Site_Application__r.Program_Country__c, Contact__r.On_Site_Application__c,
															Contact__r.Traveling_Status__c, Contact__r.Home_Institution__r.Name, 
															Support_Personnel__r.Non_IFSA_Staff__c, 
															Support_Personnel__r.Non_IFSA_Staff__r.Phone, 
															Support_Personnel__r.Non_IFSA_Staff__r.Email 
															FROM Contact_Support_Personnel__c
															WHERE Contact__c IN: studentApplicationMap.keySet() AND Support_Personnel__r.Type__c = 'Non IFSA Staff' AND
															(
																((Support_Personnel__r.RecordType.Name = 'Contact' OR Support_Personnel__r.RecordType.Name = 'Account') AND Support_Personnel__r.Emergency_Contact__c = TRUE) 
																OR
																((Support_Personnel__r.RecordType.Name = 'Account' OR Support_Personnel__r.RecordType.Name = 'Program Term' OR Support_Personnel__r.RecordType.Name = 'Program Option' OR Support_Personnel__r.RecordType.Name = 'Program') 
																	AND Application__c IN: studentApplicationMap.values())
															)
														];
		Map<String, model_contactSupport> filteredCSP = new Map<String, model_contactSupport>();
		// Determine which support bucket the csp goes in
		for(Contact_Support_Personnel__c csp: relatedCSP)
		{
			// Parent / Guardain / Emergency Contact CSPs
			if(csp.Support_Personnel__r.RecordType.Name == 'Contact' && csp.Support_Personnel__r.Emergency_Contact__c)
			{
				model_contactSupport mc = new model_contactSupport(csp);
				mc.tags.add(studentIdAffectedStudent.get(csp.Contact__c).Reason_Affected__c);
				system.debug(csp.Contact__r.On_Site_Application__r.Is_Custom__c);
				if(csp.Contact__r.On_Site_Application__c != null)
				{
					if(csp.Contact__r.On_Site_Application__r.Is_Custom__c)
					{
						mc.tags.add('Custom');
					}
					else
					{
						mc.tags.add('Catalog');
					}
					mc.tags.add(csp.Contact__r.On_Site_Application__r.Program_Term__r.Name);
					mc.tags.add(csp.Contact__r.On_Site_Application__r.Program_Country__c);
				}
				else
				{
					if(csp.Contact__r.Active_Application__r.Is_Custom__c)
					{
						mc.tags.add('Custom');
					}
					else
					{
						mc.tags.add('Catalog');
					}
					mc.tags.add(csp.Contact__r.Active_Application__r.Program_Term__r.Name);
					mc.tags.add(csp.Contact__r.Active_Application__r.Program_Country__c);
				}

				system.debug(mc.tags);

				this.contactSupportPersonnel.add(mc);
			}
			// Home Institution Advisors & Emergency Contact CSPs
			else if((csp.Contact__r.On_Site_Application__r.Is_Custom__c && csp.Application__c != NULL) || !csp.Contact__r.On_Site_Application__r.Is_Custom__c)
			{
				if(!filteredCSP.containsKey(csp.Support_Personnel__r.Non_IFSA_Staff__c))
				{
					filteredCSP.put(csp.Support_Personnel__r.Non_IFSA_Staff__c, new model_contactSupport(csp));
				}
				filteredCSP.get(csp.Support_Personnel__r.Non_IFSA_Staff__c).tags.add(csp.Contact__r.Name);
				filteredCSP.get(csp.Support_Personnel__r.Non_IFSA_Staff__c).tags.add(studentIdAffectedStudent.get(csp.Contact__c).Reason_Affected__c);

				if(csp.Contact__r.On_Site_Application__c != null)
				{
					if(csp.Contact__r.On_Site_Application__r.Is_Custom__c)
					{
						filteredCSP.get(csp.Support_Personnel__r.Non_IFSA_Staff__c).tags.add('Custom');
					}
					else
					{
						filteredCSP.get(csp.Support_Personnel__r.Non_IFSA_Staff__c).tags.add('Catalog');
					}
					filteredCSP.get(csp.Support_Personnel__r.Non_IFSA_Staff__c).tags.add(csp.Contact__r.On_Site_Application__r.Program_Term__r.Name);
					filteredCSP.get(csp.Support_Personnel__r.Non_IFSA_Staff__c).tags.add(csp.Contact__r.On_Site_Application__r.Program_Country__c);
				}
				else
				{
					if(csp.Contact__r.Active_Application__r.Is_Custom__c)
					{
						filteredCSP.get(csp.Support_Personnel__r.Non_IFSA_Staff__c).tags.add('Custom');
					}
					else
					{
						filteredCSP.get(csp.Support_Personnel__r.Non_IFSA_Staff__c).tags.add('Catalog');
					}
					filteredCSP.get(csp.Support_Personnel__r.Non_IFSA_Staff__c).tags.add(csp.Contact__r.Active_Application__r.Program_Term__r.Name);
					filteredCSP.get(csp.Support_Personnel__r.Non_IFSA_Staff__c).tags.add(csp.Contact__r.Active_Application__r.Program_Country__c);
				}
				for(model_contact s: affectedStudents)
				{
					if(s.Name == csp.Contact__r.Name)
					{
						s.tags.add(csp.Support_Personnel__r.SP_Plain_Text_Name__c);
					}
				}
			}
		}
		homeInstitutionEmergencyContacts.addAll(filteredCSP.values());
		
		// Gets SF files related to the case
		this.files = [SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, ContentDocument.CreatedById, ContentDocument.CreatedBy.Name, ContentDocument.LastModifiedDate FROM ContentDocumentLink WHERE LinkedEntityId =: this.caseId];

		// Get Case History
		List<CaseHistory> caseHistoryRecords = apexQueryUtility.selectAllFrom('CaseHistory', 'Case.CaseNumber, CreatedBy.FirstName, CreatedBy.LastName', 'CaseId = \'' + this.caseId + '\'');
		for(CaseHistory chr: caseHistoryRecords)
		{
			this.caseHistory.add(new model_caseHistory(chr, selectedCase));
		}
		// Get Open Activities and Activity History
		List<Task> taskRecords = apexQueryUtility.selectAllFrom('Task', 'Owner.FirstName, Owner.LastName, Who.Name', 'WhatId = \'' + this.caseId + '\'');
		for(Task t: taskRecords)
		{
			if(t.Status == 'Completed')
			{
				this.activityHistory.add(new model_task(t));
			}
			else
			{
				this.openActivities.add(new model_task(t));
			}
		}

		// Emails

		//End of Related Lists
		//Set View Model Values from the case record
		this.accountId = selectedCase.AccountId;
		this.applicationId = selectedCase.Application__c;
		this.assetId = selectedCase.AssetId;
		this.alcoholInvolved = selectedCase.Alchohol_Involved__c;
		this.caseIncidentDateTime = selectedCase.Date_Time_of_Incident__c;
		this.caseNumber = selectedCase.CaseNumber;
		this.caseOrigin = selectedCase.Origin;		
		this.clearyAct = selectedCase.Cleary_Act__c;
		this.closedDate = selectedCase.ClosedDate;
		this.closedWhenCreated = selectedCase.IsClosedOnCreate;
		this.contactBoardOfDirectors = selectedCase.Contact_Board_of_Directors__c;
		this.contactButlerPresident = selectedCase.Contact_Butler_University_President__c;
		this.contactHomeInstitution = selectedCase.Contact_Home_Institution__c;
		this.contactNAC = selectedCase.Contact_NAC__c;
		this.contactOther = selectedCase.Contact_Other__c;
		this.contactParentEmergencyContact = selectedCase.Contact_Parent_Emergency_Contact__c;
		this.contactTitleIX = selectedCase.Contact_Title_IX_Coordinator__c;
		this.createdDate = selectedCase.CreatedDate;
		try
		{
			this.createdBy = new model_User(selectedCase.CreatedById);
		}
		catch(Exception e)
		{
			this.createdBy = null;
		}
		
		this.description = selectedCase.Description;
		this.drugsInvolved = selectedCase.Drugs_Involved__c;		
		if(selectedCase.New_Home_Institution__c != null)
			this.getHomeInstitution(selectedCase.New_Home_Institution__c);			
		if(selectedCase.Student__c != null)
		{
			this.getStudentById(selectedCase.Student__c);				
		}
		this.hostUniversityProperty = selectedCase.Host_University_Property__c;
		this.ifsaProgramProperty = selectedCase.IFSA_Program_Property__c;
		this.ifsaInsuranceInvolved = selectedCase.IFSA_Student_Insurance_Involved__c;
		this.ifsaInsuranceCaseNumber = selectedCase.IFSA_Student_Insurance_Case_Number__c;
		this.incidentCategory = selectedCase.Incident_Category__c;
		this.incidentSeverity = model_picklist.getModelFromList(this.severities, selectedCase.Incident_Severity__c);
		this.incidentSubCategory = selectedCase.Incident_Sub_Category__c;
		this.incidentSubCategoryOther = selectedCase.Incident_Sub_Category_Other__c;
		this.incidentSubSubCategory = selectedCase.Incident_Sub_Subcategory__c;
		this.incidentSubSubCategoryOther = selectedCase.Incident_Sub_Subcategory_Other__c;
		this.isEscalated = selectedCase.IsEscalated;
		this.lastModifiedDate = selectedCase.LastModifiedDate;
		this.lastModifiedBy = selectedCase.LastModifiedById == selectedCase.CreatedById ? this.CreatedBy : new model_User(selectedCase.LastModifiedById);
		this.legalCounsel = selectedCase.Legal_Counsel__c;
		this.liabilityInsuranceInvolved = selectedCase.Liability_Insurance_Involved__c;
		this.incidentLocation = selectedCase.Location__c;
		this.mediaInvolved = selectedCase.Media_Involved__c;
		this.minnesota = selectedCase.Minnesota__c;
		this.multipleStudents = selectedCase.Multiple_Students__c;
		this.otherLocation = selectedCase.Other_Location__c;
		this.otherLocationDetails = selectedCase.Other_Location_Details__c;
		this.ownerId = selectedCase.OwnerId;
		system.debug(selectedCase.OwnerId);
		this.owner = new model_User(selectedCase.OwnerId);
		if(selectedCase.ParentId != null)
		{
			this.getParentCase(selectedCase);
		}
		this.programExcursionsHotelLodging = selectedCase.Program_Excursions_Hotel_Lodging__c;
		this.priority = selectedCase.Priority;
		this.status = selectedCase.Status;
		this.subject = selectedCase.Subject;
		this.subCategories = ifsaCaseController.getDependentPicklist('Case', 'Incident_Category__c', 'Incident_Sub_Category__c', this.incidentCategory);
		List<String> mySubSubCategories = ifsaCaseController.getDependentPicklist('Case', 'Incident_Sub_Category__c', 'Incident_Sub_Subcategory__c', this.incidentSubCategory);
		this.subSubCategories = mySubSubCategories != null ? mySubSubCategories: null;
		this.caseType = selectedCase.Type;
		this.titleIX = selectedCase.Title_IX__c;
		this.vawa = selectedCase.VAWA__c;
		this.weaponsInvolved = selectedCase.Weapons_Involved__c;
		this.caseTeamJobId = selectedCase.Case_Team_Job_Id__c;
		//this.workId = selectedCase.agf__ADM_Work__c;
		//Enf of set view model values
		//Override default values
		this.edit = false;	
	}
	/**
	* Gets the non-student case junction objects based on the record type of the case
	*/
	private void getRelatedObjects()
	{
		String inClause;
		if(this.recordType.developerName == 'Incident_Country')
		{
			List<Case_Country__c> caseCountries = [SELECT Id, Country__c FROM Case_Country__c WHERE Case__c =: this.caseId];
			inClause = apexQueryUtility.buildInClause(caseCountries, 'Country__c');
			List<Country__c> countries = apexQueryUtility.selectAllFrom('Country__c', 'Id IN ' + inClause);
			for(Country__c c: countries)
			{
				this.affectedCountries.add(new model_country(c));
			}
		}
		else if(this.recordType.developerName == 'Incident_Host_Institution')
		{
			List<Case_Host_Institution__c> caseHostInstitutions = [SELECT Id, Host_Institution__c FROM Case_Host_Institution__c WHERE Case__c =: this.caseId];
			inClause = apexQueryUtility.buildInClause(caseHostInstitutions, 'Host_Institution__c');
			List<Host_Institution__c> hostInstitutions = apexQueryUtility.selectAllFrom('Host_Institution__c', 'Id IN ' + inClause);
			for(Host_Institution__c c: hostInstitutions)
			{
				this.affectedHostInstitutions.add(new model_hostInstitution(c));
			}
		}
		else if(this.recordType.developerName == 'Incident_City')
		{
			List<Case_City__c> caseCities = [SELECT Id, City__c FROM Case_City__c WHERE Case__c =: this.caseId];
			inClause = apexQueryUtility.buildInClause(caseCities, 'City__c');
			List<Locality__c> cities = apexQueryUtility.selectAllFrom('Locality__c', 'Id IN ' + inClause);
			for(Locality__c c: cities)
			{
				this.affectedCities.add(new model_city(c));
			}
		}
		else if(this.recordType.developerName == 'Incident_Program')
		{
			List<Case_Program__c> casePrograms = [SELECT Id, Program__c FROM Case_Program__c WHERE Case__c =: this.caseId];
			inClause = apexQueryUtility.buildInClause(casePrograms, 'Program__c');
			List<Program__c> programs = apexQueryUtility.selectAllFrom('Program__c', 'Id IN ' + inClause);
			for(Program__c c: programs)
			{
				this.affectedPrograms.add(new model_program(c));
			}
		}
	}
	/**
	* Sets the parentCase property of the case has a parent case
	* @param caseId - the id of the parent case
	*/
	public void getParentCaseById(String caseId)
	{
		Case c = [SELECT Id, CaseNumber, ParentId, Parent.CaseNumber FROM Case WHERE Id =: caseId].get(0);
		this.getParentCase(c);
	}
	/**
	* Sets the parentCase property of the case has a parent case
	* @param c - The case object of the parent case
	*/
	public void getParentCase(Case c)
	{
		this.parentCase = new model_case();
		this.parentCase.caseId = c.ParentId;
		this.parentCase.caseNumber = c.Parent.CaseNumber;
	}
	/**
	* Sets the parentCase property of the case has a parent case
	* @param caseName - The case number of the parent case
	*/
	public void getParentCaseByName(String caseName)
	{
		Case c = [SELECT Id, CaseNumber, ParentId, Parent.CaseNumber FROM Case WHERE CaseNumber =: caseName].get(0);
		this.getParentCase(c);
	}
	/**
	* Sets the recordType property of the case
	* @param recordTypeId - The id of the cases record type
	*/
	public void getRecordTypeById(String recordTypeId)
	{
		RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Id =: recordTypeId].get(0);
		this.getRecordType(rt);
	}
	/**
	* Sets the recordType property of the case
	* @param recordTypeDeveloperName - The developer name of the cases record type
	*/
	public void getRecordTypeByName(String recordTypeDeveloperName)
	{
		RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName =: recordTypeDeveloperName].get(0);
		this.getRecordType(rt);
	}
	/**
	* Sets the recordType property of the case
	* @param rt - Record of the record type
	*/
	public void getRecordType(RecordType rt)
	{
		this.recordType = new model_recordType();
		this.recordType.recordTypeId = rt.Id;
		this.recordType.name = rt.Name;
		this.recordType.developerName = rt.DeveloperName;
	}
	/**
	* Sets the city property of the case
	* @param cityId - Id of the affected city
	*/
	public void getCityById(String cityId)
	{
		Locality__c c = [SELECT Id, Name FROM Locality__c WHERE Id =: cityId].get(0);
		this.incidentCity = new model_city();		
		this.incidentCity.localityId = c.Id;
		this.incidentCity.name = c.Name;
	}
	/**
	* Sets the program property of the case
	* @param programId - Id of the affected program
	*/
	public void getProgramById(String programId)
	{
		Program__c c = [SELECT Id, Name FROM Program__c WHERE Id =: programId].get(0);
		this.program = new model_program();		
		this.program.programId = c.Id;
		this.program.name = c.Name;
	}
	/**
	* Sets the country property of the case
	* @param countryId - Id of the affected country
	*/
	public void getCountryById(String countryId)
	{
		Country__c c = [SELECT Id, Name FROM Country__c WHERE Id =: countryId].get(0);
		this.getCountry(c);
	}
	/**
	* Sets the country property of the case
	* @param countryName - Name of the affected country
	*/
	public void getCountryByName(String countryName)
	{
		Country__c c = [SELECT Id, Name FROM Country__c WHERE Name =: countryName].get(0);
		this.getCountry(c);
	}
	/**
	* Sets the country property of the case
	* @param Country__c c - Country record of the affected country
	*/
	public void getCountry(Country__c c)
	{
		this.country = new model_country();		
		this.country.countryId = c.Id;
		this.country.name = c.Name;
	}
	/**
	* Sets the home institution property of the case
	* @param homeInstitutionName - Name of the affected home institution
	*/
	public void getHomeInstitution(String homeInstitutionName)
	{
		Home_Institution__c homeInst = [SELECT Id, Name FROM Home_Institution__c WHERE Name =: homeInstitutionName].get(0);
		this.homeInstitution = new model_homeInstitution();		
		this.homeInstitution.homeInstitutionId = homeInst.Id;
		this.homeInstitution.name = homeInst.Name;
	}
	/**
	* Sets the country property of the case
	* @param hostInstitutionId - Id of the affected host institution
	*/
	public void getHostInstitutionById(String hostInstitutionId)
	{
		Host_Institution__c h = [SELECT Id, Name FROM Host_Institution__c WHERE Id =: hostInstitutionId].get(0);
		this.getHostInstitution(h);
	}	
	/**
	* Sets the host institution property of the case
	* @param hostInstitutionName - Name of the host institution
	*/
	public void getHostInstitutionByName(String hostInstitutionName)
	{
		Host_Institution__c h = [SELECT Id, Name FROM Host_Institution__c WHERE Name =: hostInstitutionName].get(0);
		this.getHostInstitution(h);
	}
	/**
	* Sets the host institution property of the case
	* @param h - SObject of the host institution
	*/
	public void getHostInstitution(Host_Institution__c h)
	{
		this.hostInstitution = new model_hostInstitution();
		this.hostInstitution.hostInstitutionId = h.Id;
		this.hostInstitution.name = h.Name;
	}
	/**
	* Sets the student property of the case
	* @param studentId - Id of the affected student
	*/
	public void getStudentById(String studentId)
	{
		Contact c = [SELECT Id, FirstName, LastName, Address_Abroad_Cell_Phone__c, Home_Institution__r.Name, RecordTypeId FROM Contact WHERE Id =: studentId].get(0);
		this.student = new model_contact(c);		
	}
	/**
	* Sets the application property of the case
	* @param applicationId - Id of the application
	*/
	public void getApplicationById(String applicationId)
	{
		Application__c app = (Application__c) apexQueryUtility.selectAllFrom('Application__c', 'Id = \'' + applicationId + '\'').get(0);
		this.applicationId = app.Id;
		this.application = new model_Application(app);
	}
	/**
	* Converts the view model back into a case record
	* @return Case - The Case SObject genereated from the viewModel
	*/
	public Case convertViewModelToCase()
	{
		Case convertedCase = new Case();
		convertedCase.Id = this.caseId;
		convertedCase.AccountId = this.accountId;
		convertedCase.AssetId = this.assetId;
		convertedCase.Application__c = this.applicationId;
		convertedCase.Alchohol_Involved__c = this.alcoholInvolved == true ? true: false;
		//convertedCase.City__c = this.incidentCity;
		convertedCase.Cleary_Act__c = this.clearyAct == true ? true: false;
		convertedCase.Reason = this.closedReason;
		convertedCase.Contact_Board_of_Directors__c = this.contactBoardOfDirectors == true ? true: false;
		convertedCase.Contact_Butler_University_President__c = this.contactButlerPresident == true ? true: false;
		convertedCase.Contact_Home_Institution__c = this.contactHomeInstitution == true ? true: false;
		convertedCase.Contact_NAC__c = this.contactNAC == true ? true: false;
		convertedCase.Contact_Other__c = this.contactOther;
		convertedCase.Contact_Parent_Emergency_Contact__c = this.contactParentEmergencyContact == true ? true: false;
		convertedCase.Contact_Title_IX_Coordinator__c = this.contactTitleIX == true ? true: false;
		//convertedCase.Country__c = this.country != null ? this.country.countryId : null;
		convertedCase.Date_Time_of_Incident__c = this.caseIncidentDateTime;		
		convertedCase.Description = this.description;
		convertedCase.Drugs_Involved__c = this.drugsInvolved == true ? true: false;		
		convertedCase.New_Home_Institution__c = this.homeInstitution != null ? this.homeInstitution.homeInstitutionId : null;
		//convertedCase.Host_Institution__c = this.hostInstitution != null ? this.hostInstitution.hostInstitutionId : null;
		convertedCase.Host_University_Property__c = this.hostUniversityProperty == true ? true: false;
		convertedCase.IFSA_Program_Property__c = this.ifsaProgramProperty == true ? true: false;
		convertedCase.IFSA_Student_Insurance_Case_Number__c = this.ifsaInsuranceCaseNumber;
		convertedCase.IFSA_Student_Insurance_Involved__c = this.ifsaInsuranceInvolved == true ? true : false;
		convertedCase.Incident_Category__c = this.incidentCategory;		
		convertedCase.Incident_Sub_Category__c = this.incidentSubCategory;
		convertedCase.Incident_Sub_Category_Other__c = this.incidentSubCategoryOther;
		convertedCase.Incident_Sub_Subcategory__c = this.incidentSubSubCategory;
		convertedCase.Incident_Sub_Subcategory_Other__c = this.incidentSubSubCategoryOther;
		convertedCase.Incident_Severity__c = this.incidentSeverity != null ? this.incidentSeverity.apiName : null ;
		//convertedCase.IsClosedOnCreate = this.closedWhenCreated;
		convertedCase.IsEscalated = this.isEscalated == true ? true: false;
		convertedCase.Legal_Counsel__c = this.legalCounsel == true ? true: false;
		convertedCase.Liability_Insurance_Involved__c = this.liabilityInsuranceInvolved == true ? true: false;
		convertedCase.Location__c = this.incidentLocation;
		convertedCase.Media_Involved__c = this.mediaInvolved == true ? true: false;
		convertedCase.Minnesota__c = this.minnesota == true ? true: false;
		convertedCase.Multiple_Students__c = this.multipleStudents == true ? true: false;
		convertedCase.Other_Location__c = this.otherLocation  == true ? true: false;
		convertedCase.Other_Location_Details__c = this.otherLocationDetails;
		system.debug(this.owner.userId)	;
		system.debug(convertedCase.OwnerId);
		if(this.owner.userId != null)
			convertedCase.OwnerId = this.owner.userId;
		system.debug(this.owner.userId)	;
		system.debug(convertedCase.OwnerId);
		convertedCase.ParentId = this.parentCase.caseId;
		convertedCase.Priority = this.priority;
		convertedCase.Program_Excursions_Hotel_Lodging__c = this.programExcursionsHotelLodging == true ? true: false;
		convertedCase.RecordTypeId = this.recordType != null ? this.recordType.recordTypeId : null;
		convertedCase.Status = this.status;
		convertedCase.Student__c = this.student != null ? this.student.contactId : null;
		convertedCase.Subject = this.subject;
		convertedCase.Type = this.caseType;
		convertedCase.Title_IX__c = this.titleIX == true ? true: false;
		convertedCase.VAWA__c = this.vawa == true ? true: false;
		convertedCase.Weapons_Involved__c = this.weaponsInvolved == true ? true: false;
		//convertedCase.agf__ADM_Work__c = this.workId;

		return convertedCase;
	}
}