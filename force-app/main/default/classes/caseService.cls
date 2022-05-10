/**
 * Service clas to be used by <<caseTriggerHandler>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public without sharing class caseService {

	public static final Set<Id> legacyHSRT = new Set<Id>{
		Schema.SObjectType.Case.getRecordTypeInfosByName().get('Pre-Departure').getRecordTypeId(),
		Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident City').getRecordTypeId(),
		Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Country').getRecordTypeId(),
		Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Global').getRecordTypeId(),
		Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Host Institution').getRecordTypeId(),
		Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Program').getRecordTypeId(),
		Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId()
	};
	public static final Set<Id> hsRT = new Set<Id>{
		Schema.SObjectType.Case.getRecordTypeInfosByName().get('City Incident').getRecordTypeId(),
		Schema.SObjectType.Case.getRecordTypeInfosByName().get('Country Incident').getRecordTypeId(),
		Schema.SObjectType.Case.getRecordTypeInfosByName().get('Global Incident').getRecordTypeId(),
		Schema.SObjectType.Case.getRecordTypeInfosByName().get('Program Incident').getRecordTypeId(),
		Schema.SObjectType.Case.getRecordTypeInfosByName().get('Student Incident').getRecordTypeId()
	};
	/**
	 * Generates case team Health & Safety Cases.
	 * THIS IS FOR LEGACY HSS CASES
	 */
	public static void generateCaseTeam(List<Case> newRecords)
    {
        for(Case c: newRecords)
        {
            if(legacyHSRT.contains(c.RecordTypeId) && c.Generate_Case_Team__c == true)
            {
                c.Case_Team_Job_Id__c = Database.executeBatch(new batchCaseTeamGenerator(c));   
            }            
        }
    }
	/**
	 * Sets the reason a student is affected by a HSS case
	 * THIS IS FOR LEGACY HSS CASES
	 */
	public static void setReasonAffected(List<Case_Student__c> newRecords)
	{
		for(Case_Student__c caseStudent : newRecords)
		{
			if(caseStudent.Reason_Affected__c == null)
			{
				caseStudent.Reason_Affected__c = 'Manually Included';
			}
		}
	}

	/**
	 * Links student contact records to a student incident case
	 * THIS IS FOR LEGACY HSS CASES
	 */
	public static relatedToCase studentCase(Case theCase, Boolean isNewCase, List<String> affectedStatuses)
	{
		relatedToCase rtc = new relatedToCase();
		
		Case_Student__c studentCase = new Case_Student__c();
		if(isNewCase)
		{
			studentCase.Student__c = theCase.Student__c;
			studentCase.Case__c = theCase.Id;
		}
		else
		{
			studentCase = [SELECT Id, Student__c, Case__c FROM Case_Student__c WHERE Case__c =: theCase.Id AND Student__c =: theCase.Student__c];				
		}
		// Determine the reason the student is affected by the case
		if(theCase.recordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId())
		{
			rtc.affectedApplications.add([SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c, Is_Custom__c FROM Application__c WHERE Applicant__c =: theCase.Student__c AND (Status__c IN ('On Site', 'Program Completed') OR (Status__c IN: affectedStatuses AND Applicant__r.Traveling_Status__c != 'Not Traveling')) ORDER BY Status_Program_Completed__c DESC NULLS FIRST LIMIT 1]);
			Application__c app = rtc.affectedApplications.get(0);
			if(app.Applicant__r.Traveling_Status__c != 'Not Traveling')
			{
				studentCase.Reason_Affected__c = 'Traveling';
			}
			else if(app.Status__c == 'Program Completed')
			{
				studentCase.Reason_Affected__c = 'Program Completed';
			}
			else
			{
				studentCase.Reason_Affected__c = 'On Site';
			}
			studentCase.Is_Custom__c = app.Is_Custom__c;
		}
		else if(theCase.recordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Pre-Departure').getRecordTypeId())
		{
			studentCase.Reason_Affected__c = 'Pre-Departure';
			List<String> preStatuses = new List<String>{'Program Selected', 'Ready To Submit', 'Submitted', 'Accepted', 'Deceased'};
			preStatuses.add('Accepted (with Conditions)');

			rtc.affectedApplications = [SELECT Id, Applicant__c FROM Application__c WHERE Applicant__c =: theCase.Student__c AND Status__c IN: preStatuses];
		}
		rtc.relatedStudents.add(studentCase);

		return rtc;
	}
	/**
	 * Links student contact records to a student incident case
	 * THIS IS FOR LEGACY HSS CASES
	 */
	public static void linkStudentsToStudentCase(List<Case> newRecords)
	{
		Map<Id, Case_Student__c> newCaseStudents = new Map<Id, Case_Student__c>();
		for(Case c: newRecords)
		{
			if(c.Student__c != null)
			{
				Case_Student__c studentCase = new Case_Student__c();
				studentCase.Student__c = c.Student__c;
				studentCase.Case__c = c.Id;	

				newCaseStudents.put(c.Student__c, studentCase);
			}
		}
		if(!newCaseStudents.isEmpty())
		{
			Map<Id, List<Application__c>> appMap = new Map<Id, List<Application__c>>();
			for(Application__c app: [SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c, Is_Custom__c FROM Application__c WHERE Applicant__c IN: newCaseStudents.keySet() AND (Status__c IN ('On Site', 'Program Completed') OR (Status__c IN ('Accepted', 'Accepted (with Conditions)') AND Applicant__r.Traveling_Status__c != 'Not Traveling') OR (Status__c IN ('Program Selected', 'Ready To Submit', 'Submitted', 'Accepted', 'Deceased', 'Accepted (with Conditions)') AND Applicant__r.Traveling_Status__c = 'Not Traveling')) ORDER BY Status_Program_Completed__c])
			{
				if(!appMap.containsKey(app.Applicant__c))
				{
					appMap.put(app.Applicant__c, new List<Application__c>());
				}
				appMap.get(app.Applicant__c).add(app);
			}

			for(Case c: newRecords)
			{
				Case_Student__c studentCase = newCaseStudents.get(c.Student__c);
				if(c.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId())
				{
					for(Application__c app: appMap.get(c.Student__c))
					{
						if(app.Applicant__r.Traveling_Status__c != 'Not Traveling')
						{
							studentCase.Reason_Affected__c = 'Traveling';						
						}
						else if(app.Status__c == 'Program Completed')
						{
							studentCase.Reason_Affected__c = 'Program Completed';
						}
						else
						{
							studentCase.Reason_Affected__c = 'On Site';
						}
						studentCase.Is_Custom__c = app.Is_Custom__c;
					}
				}
				else if(c.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Pre-Departure').getRecordTypeId())
				{
					for(Application__c app: appMap.get(c.Student__c))
					{
						studentCase.Reason_Affected__c = 'Pre-Departure';
						studentCase.Is_Custom__c = app.Is_Custom__c;
					}
				}
			}
		}
		database.insert(newCaseStudents.values());
	}

	/**
	 * Links student contact records to a city incident case
	 * THIS IS FOR LEGACY HSS CASES
	 */
	public static void linkStudentsToCityCase(List<Case_City__c> newRecords)
	{
		List<String> affectedItems = new List<String>();
		List<String> statuses = new List<String>{'On Site'};
		for(Case_City__c cc: newRecords)
		{
			affectedItems.add(cc.City__c);
		}
		List<Application__c> affectedApplications = [SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c, Is_Custom__c, Program_Term__r.Program__r.Host_Institution__r.Locality__c FROM Application__c WHERE Program_Term__r.Program__r.Host_Institution__r.Locality__c IN: affectedItems AND (Status__c IN: statuses OR (Status__c = 'Program Completed' AND (Program_Term__r.End_Date__c >= LAST_N_DAYS:7 OR Program_Term__r.Parent_Program_Term__r.End_Date__c >= LAST_N_DAYS:7)) OR (Status__c IN ('Accepted (with Conditions)', 'Accepted') AND Applicant__r.Traveling_Status__c != 'Not Traveling'))];
		List<Case_Student__c> affectedStudents = new List<Case_Student__c>();
		for(Case_City__c cc: newRecords)
		{
			Case c = new Case(Id = cc.Case__c);
			for(Application__c app: affectedApplications)
			{
				if(app.Program_Term__r.Program__r.Host_Institution__r.Locality__c == cc.City__c)
				{
					affectedStudents.addAll(getAffectedStudents(new List<Application__c>{app}, c));
				}
			}
		}
		database.insert(affectedStudents);
	}
	/**
	 * Links student contact records to a country incident case
	 * THIS IS FOR LEGACY HSS CASES
	 */
	public static void linkStudentsToCountryCase(List<Case_Country__c> newRecords)
	{
		List<String> affectedItems = new List<String>();
		List<String> statuses = new List<String>{'On Site'};
		for(Case_Country__c cc: newRecords)
		{
			affectedItems.add(cc.Country__c);
		}
		List<Application__c> affectedApplications = [SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c, Is_Custom__c, Program_Country__c FROM Application__c WHERE Program_Term__r.Program__r.Country__c IN: affectedItems AND (Status__c IN: statuses OR (Status__c = 'Program Completed' AND (Program_Term__r.End_Date__c >= LAST_N_DAYS:7 OR Program_Term__r.Parent_Program_Term__r.End_Date__c >= LAST_N_DAYS:7)) OR (Status__c IN ('Accepted (with Conditions)', 'Accepted') AND Applicant__r.Traveling_Status__c != 'Not Traveling'))];
		List<Case_Student__c> affectedStudents = new List<Case_Student__c>();
		for(Case_Country__c cc: newRecords)
		{
			Case c = new Case(Id = cc.Case__c);
			for(Application__c app: affectedApplications)
			{
				if(app.Program_Country__c == cc.Country_Name__c)
				{
					affectedStudents.addAll(getAffectedStudents(new List<Application__c>{app}, c));
				}
			}
		}
		database.insert(affectedStudents);
	}
	/**
	 * Links student contact records to a global incident case
	 * THIS IS FOR LEGACY HSS CASES
	 */
	public static void linkStudentsToGlobalCase(List<Case> newRecords)
	{
		List<String> affectedItems = new List<String>();
		List<String> statuses = new List<String>{'On Site'};
		List<Case_Student__c> affectedStudents = new List<Case_Student__c>();
		List<Application__c> affectedApplications = [SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c, Is_Custom__c, Program_Country__c FROM Application__c WHERE Program_Term__r.Program__r.Country__c IN: affectedItems AND (Status__c IN: statuses OR (Status__c = 'Program Completed' AND (Program_Term__r.End_Date__c >= LAST_N_DAYS:7 OR Program_Term__r.Parent_Program_Term__r.End_Date__c >= LAST_N_DAYS:7)) OR (Status__c IN ('Accepted (with Conditions)', 'Accepted') AND Applicant__r.Traveling_Status__c != 'Not Traveling'))];
		Id globalRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Global').getRecordTypeId();
		
		for(Case c: newRecords)
		{
			if(c.RecordTypeId == globalRT)
			{
				for(Application__c app: affectedApplications)
				{
					affectedStudents.addAll(getAffectedStudents(new List<Application__c>{app}, c));
				}
			}
		}
		if(!affectedStudents.isEmpty())
		{
			sObjectBatchUpdater.batchUpdate(affectedStudents, 200, sObjectBatchUpdater.dmlTypes.dmlInsert);
		}	
	}
	/**
	 * Links student contact records to a host institution incident case
	 * THIS IS FOR LEGACY HSS CASES
	 */
	public static void linkStudentsToHostInstitutionCase(List<Case_Host_Institution__c> newRecords)
	{
		List<String> affectedItems = new List<String>();
		List<String> statuses = new List<String>{'On Site'};
		for(Case_Host_Institution__c ch: newRecords)
		{
			affectedItems.add(ch.Host_Institution__c);
		}
		List<Application__c> affectedApplications = [SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c, Is_Custom__c, Program_Term__r.Program__r.Host_Institution__c FROM Application__c WHERE Program_Term__r.Program__r.Host_Institution__c IN: affectedItems AND (Status__c IN: statuses OR (Status__c = 'Program Completed' AND (Program_Term__r.End_Date__c >= LAST_N_DAYS:7 OR Program_Term__r.Parent_Program_Term__r.End_Date__c >= LAST_N_DAYS:7)) OR (Status__c IN ('Accepted (with Conditions)', 'Accepted') AND Applicant__r.Traveling_Status__c != 'Not Traveling'))];
		List<Case_Student__c> affectedStudents = new List<Case_Student__c>();
		for(Case_Host_Institution__c ch: newRecords)
		{
			Case c = new Case(Id = ch.Case__c);
			for(Application__c app: affectedApplications)
			{
				if(app.Program_Term__r.Program__r.Host_Institution__c == ch.Host_Institution__c)
				{
					affectedStudents.addAll(getAffectedStudents(new List<Application__c>{app}, c));
				}
			}
		}
		database.insert(affectedStudents);
	}
	/**
	 * Links student contact records to a program incident case
	 * THIS IS FOR LEGACY HSS CASES
	 */
	public static void linkStudentsToProgramCase(List<Case_Program__c> newRecords)
	{
		List<String> affectedItems = new List<String>();
		List<String> statuses = new List<String>{'On Site'};
		for(Case_Program__c ch: newRecords)
		{
			affectedItems.add(ch.Program__c);
		}
		List<Application__c> affectedApplications = [SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c, Is_Custom__c, Program_Term__r.Program__c FROM Application__c WHERE Program_Term__r.Program__c IN: affectedItems AND (Status__c IN: statuses OR (Status__c = 'Program Completed' AND (Program_Term__r.End_Date__c >= LAST_N_DAYS:7 OR Program_Term__r.Parent_Program_Term__r.End_Date__c >= LAST_N_DAYS:7)) OR (Status__c IN ('Accepted (with Conditions)', 'Accepted') AND Applicant__r.Traveling_Status__c != 'Not Traveling'))];
		List<Case_Student__c> affectedStudents = new List<Case_Student__c>();
		for(Case_Program__c ch: newRecords)
		{
			Case c = new Case(Id = ch.Case__c);
			for(Application__c app: affectedApplications)
			{
				if(app.Program_Term__r.Program__c == ch.Program__c)
				{
					affectedStudents.addAll(getAffectedStudents(new List<Application__c>{app}, c));
				}
			}
		}
		database.insert(affectedStudents);
	}

	/**
	 * Gets and creates the related countries for a case
	 * THIS IS FOR LEGACY HSS CASES
	 * @param theCase - the case record that is being inserted / updated
	 * @param countries - the related city models
	 * @param affectedStatuses - list of application statuses
	 * @return relatedToCase records related to the case that need updated or inserted
	*/
	public static relatedToCase countryCase(Case theCase, list<model_country> countries, List<String> affectedStatuses)
	{
		relatedToCase rtc = new relatedToCase();
		List<String> affectedItems = new List<String>();
		List<String> statuses = new List<String>{'On Site'};

		// Gets the affected countries
		List<Case_Country__c> caseCountries = [SELECT Id, Country__c, Case__c FROM Case_Country__c WHERE Case__c =: theCase.Id];
		for(model_country country: countries)
		{
			Boolean hasCountry = false;
			for(Case_Country__c cc: caseCountries)
			{
				if(cc.Country__c == country.countryId)
				{
					hasCountry = true;
					break;
				}
			}
			if(!hasCountry)
			{
				Case_Country__c thisCountry = new Case_Country__c();
				thisCountry.Case__c = theCase.Id;
				system.debug(country.countryId);
				thisCountry.Country__c = country.countryId;
				rtc.objectsToInsert.add(thisCountry);
				affectedItems.add(country.Name);
			}				
		}
		// Get the students that are in the countries
		//rtc.affectedApplications = [SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c, Is_Custom__c FROM Application__c WHERE Program_Country__c IN: affectedItems AND (Status__c IN: statuses OR (Status__c = 'Program Completed' AND (Program_Term__r.End_Date__c >= LAST_N_DAYS:7 OR Program_Term__r.Parent_Program_Term__r.End_Date__c >= LAST_N_DAYS:7)) OR (Status__c IN: affectedStatuses AND Applicant__r.Traveling_Status__c != 'Not Traveling'))];
		//rtc.relatedStudents.addAll(getAffectedStudents(rtc.affectedApplications, theCase));

		return rtc;
	}
	/**
	 * Gets and creates the related countries for a case
	 * THIS IS FOR LEGACY HSS CASES
	 * @param theCase - the case record that is being inserted / updated
	 * @param countries - the related country models
	 * @param affectedStatuses - list of application statuses
	 * @return relatedToCase records related to the case that need updated or inserted
	*/
	public static relatedToCase cityCase(Case theCase, List<model_city> cities, List<String> affectedStatuses)
	{
		relatedToCase rtc = new relatedToCase();
		List<String> affectedItems = new List<String>();
		List<String> statuses = new List<String>{'On Site'};

		// Gets the affected cities
			List<Case_City__c> caseCity = [SELECT Id, City__c, Case__c FROM Case_City__c WHERE Case__c =: theCase.Id];
			for(model_city city: cities)
			{
				Boolean hasCity = false;
				for(Case_City__c cc: caseCity)
				{
					if(cc.City__c == city.localityId)
					{
						hasCity = true;
						break;
					}
				}
				if(!hasCity)
				{
					Case_City__c thisCity = new Case_City__c();
					thisCity.Case__c = theCase.Id;
					system.debug(city.localityId);
					thisCity.City__c = city.localityId;
					rtc.objectsToInsert.add(thisCity);
					affectedItems.add(city.localityId);
				}				
			}
			// Get the students that are in the cities
			///rtc.affectedApplications = [SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c, Is_Custom__c FROM Application__c WHERE Program_Term__r.Program__r.Host_Institution__r.Locality__c IN: affectedItems AND (Status__c IN: statuses OR (Status__c = 'Program Completed' AND (Program_Term__r.End_Date__c >= LAST_N_DAYS:7 OR Program_Term__r.Parent_Program_Term__r.End_Date__c >= LAST_N_DAYS:7)) OR (Status__c IN: affectedStatuses AND Applicant__r.Traveling_Status__c != 'Not Traveling'))];
			//rtc.relatedStudents.addAll(getAffectedStudents(rtc.affectedApplications, theCase));

		return rtc;
	}
	/**
	 * Gets and creates the related host institutions for a case
	 * THIS IS FOR LEGACY HSS CASES
	 * @param theCase - the case record that is being inserted / updated
	 * @param hosts - the related host institutions models
	 * @param affectedStatuses - list of application statuses
	 * @return relatedToCase records related to the case that need updated or inserted
	*/
	public static relatedToCase hostCase(Case theCase, List<model_hostInstitution> hosts, List<String> affectedStatuses)
	{
		relatedToCase rtc = new relatedToCase();
		List<String> affectedItems = new List<String>();
		List<String> statuses = new List<String>{'On Site'};

		// Gets the affected Host Institutions
		List<Case_Host_Institution__c> caseHost = [SELECT Id, Host_Institution__c, Case__c FROM Case_Host_Institution__c WHERE Case__c =: theCase.Id];
		for(model_hostInstitution host: hosts)
		{
			Boolean hasHost = false;
			for(Case_Host_Institution__c cc: caseHost)
			{
				if(cc.Host_Institution__c == host.hostInstitutionId)
				{
					hasHost = true;
					break;
				}
			}
			if(!hasHost)
			{
				Case_Host_Institution__c thisHost = new Case_Host_Institution__c();
				thisHost.Case__c = theCase.Id;
				system.debug(host.hostInstitutionId);
				thisHost.Host_Institution__c = host.hostInstitutionId;
				rtc.objectsToInsert.add(thisHost);
				affectedItems.add(host.hostInstitutionId);
			}				
		}
		// Get the students that are at the host institutions
		//rtc.affectedApplications = [SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c, Is_Custom__c FROM Application__c WHERE Program_Term__r.Program__r.Host_Institution__c IN: affectedItems AND (Status__c IN: statuses OR (Status__c = 'Program Completed' AND (Program_Term__r.End_Date__c >= LAST_N_DAYS:7 OR Program_Term__r.Parent_Program_Term__r.End_Date__c >= LAST_N_DAYS:7)) OR (Status__c IN: affectedStatuses AND Applicant__r.Traveling_Status__c != 'Not Traveling'))];
		//rtc.relatedStudents.addAll(getAffectedStudents(rtc.affectedApplications, theCase));

		return rtc;
	}
	/**
	 * Gets and creates the related programs for a case
	 * THIS IS FOR LEGACY HSS CASES
	 * @param theCase - the case record that is being inserted / updated
	 * @param programs - the related programs models
	 * @param affectedStatuses - list of application statuses
	 * @return relatedToCase records related to the case that need updated or inserted
	*/
	public static relatedToCase programCase(Case theCase, List<model_program> programs, List<String> affectedStatuses)
	{
		relatedToCase rtc = new relatedToCase();
		List<String> affectedItems = new List<String>();
		List<String> statuses = new List<String>{'On Site'};

		// Gets the affected programs
		List<Case_Program__c> caseProgram = [SELECT Id, Program__c, Case__c FROM Case_Program__c WHERE Case__c =: theCase.Id];
		for(model_program program: programs)
		{
			Boolean hasProgram = false;
			for(Case_Program__c cc: caseProgram)
			{
				if(cc.Program__c == program.programId)
				{
					hasProgram = true;
					break;
				}
			}
			if(!hasProgram)
			{
				Case_Program__c thisProgram = new Case_Program__c();
				thisProgram.Case__c = theCase.Id;
				system.debug(program.programId);
				thisProgram.Program__c = program.programId;
				rtc.objectsToInsert.add(thisProgram);
				affectedItems.add(program.programId);
			}
		}
		// Get the students that are on the programs
		//rtc.affectedApplications = [SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c, Is_Custom__c FROM Application__c WHERE Program_Term__r.Program__c IN: affectedItems AND (Status__c IN: statuses OR (Status__c = 'Program Completed' AND (Program_Term__r.End_Date__c >= LAST_N_DAYS:7 OR Program_Term__r.Parent_Program_Term__r.End_Date__c >= LAST_N_DAYS:7)) OR (Status__c IN: affectedStatuses AND Applicant__r.Traveling_Status__c != 'Not Traveling'))];
		//rtc.relatedStudents.addAll(getAffectedStudents(rtc.affectedApplications, theCase));

		return rtc;
	}
	/**
	* Generate a list of Case_Student__c records for the students that are affected by the case and the reason they are affected by the case
	* THIS IS FOR LEGACY HSS CASES
	* @param List<Application__c> apps - the applications/students that are affected by the case
	* @param Case newCase - the case that is being created or updated
	* @return List<Case_Student__c> - List of generated Case_Student__c records
	*/
	public static List<Case_Student__c> getAffectedStudents(List<Application__c> apps, Case newCase)
	{		
		List<Case_Student__c> studentCases = new List<Case_Student__c>();
		for(Application__c app: apps)
		{
			Case_Student__c studentCase = new Case_Student__c();
			studentCase.Student__c = app.Applicant__c;
			studentCase.Case__c = newCase.Id;
			studentCase.Is_Custom__c = app.Is_Custom__c;
			if(app.Applicant__r.Traveling_Status__c != 'Not Traveling')
			{
				studentCase.Reason_Affected__c = 'Traveling';
			}
			else if(app.Status__c == 'Program Completed')
			{
				studentCase.Reason_Affected__c = 'Program Completed';
			}
			else
			{
				studentCase.Reason_Affected__c = 'On Site';
			}
			studentCases.add(studentCase);
		}
		return studentCases;
	}
	/**
	 * Generates a case team from Case_Student__c records
	 * THIS IS FOR LEGACY HSS CASES
	 */
	public static void generateCaseTeam(List<Case_Student__c> newRecords)
	{
		Set<Id> caseIds = new Set<Id>();
		for(Case_Student__c cs: newRecords)
		{
			caseIds.add(cs.Case__c);
		}
		for(Case c: [SELECT Id, Status, Incident_Category__c, Incident_Sub_Category__c, Incident_Sub_Subcategory__c, Incident_Severity__c,RecordType.Name FROM Case WHERE Id IN: caseIds])
		{
			List<Id> appIds = new List<Id>();
			List<Case_Student__c> studentCases = new List<Case_Student__c>();
			for(Case_Student__c cs: newRecords)
			{
				if(cs.Case__c == c.Id)
				{
					studentCases.add(cs);
					appIds.add(cs.Affected_Application_Id__c);
				}
			}
			caseTeamQueueable job = new caseTeamQueueable(c, studentCases, appIds);
			Id caseTeamJobId = system.enqueueJob(job);
			system.debug(caseTeamJobId);
		}

	}

	/**
	 * Method to perform lookups with TypeAhead on VF pages
	 * THIS IS FOR LEGACY HSS CASES
	 * @param Case objectName - The table to do a lookup on
	 * @param List<Case_Student__c> studentCases - The affected students related to the case
	 * @param List<Id> applicationIds - The IDs of the affected students applications
	 * @return Boolean - Success of the method
	 */
	public static Boolean generateCaseTeam(Case theCase, List<Case_Student__c> studentCases, List<Id> applicationIds)	
	{
		// If the case has been closed we do not need to update the case team
		if(theCase.Status == 'Closed')
		{
			return true;
		}
		// Create a map of the case team roles
		Map<String, CaseTeamRole> roleMap = new Map<String, CaseTeamRole>();
		for(CaseTeamRole role: [SELECT Id, Name FROM CaseTeamRole])
		{
			roleMap.put(role.Name, role);
		}
		// Create a list of the affected student Ids
		List<ID> studentIds = new List<ID>();
		for(Case_Student__c studentCase: studentCases)
		{
			studentIds.add(studentCase.Student__c);
		}
		system.debug(studentIds.size());
		// Get the CSP records related to the students and their applications
		List<Contact_Support_Personnel__c> cspList = [SELECT Id, Contact__c, Support_Personnel__c FROM Contact_Support_Personnel__c WHERE Contact__c IN: studentIds AND (Application__c = NULL OR Application__c IN: applicationIds)];
		// Create "IN" clause to get the Support Personnel records
		String inClause = apexQueryUtility.buildInClause(cspList, 'Support_Personnel__c');
		// Get all row in support personnel records related to the students
		List<Support_Personnel__c> supportPersonnel = apexQueryUtility.selectAllFrom('Support_Personnel__c', 'ifsa_staff__r.Name', 'ID IN ' + inClause + ' AND Type__c = \'IFSA Staff\' AND ifsa_staff__r.IsActive = TRUE');
		// Map to group IFSA staff user id's with their SP records
		Map<Id, List<Support_Personnel__c>> userSPMap = new Map<Id, List<Support_Personnel__c>>();
		List<Incident_Matrix__c> matrices;
		// Get the IM records depending on if the case has a sub sub category or not
		if(theCase.Incident_Sub_Subcategory__c != null)
			matrices = [SELECT id, support_role_type__c, ifsa_staff__c, ifsa_staff__r.Name FROM Incident_Matrix__c 
				WHERE Severity__c =: theCase.Incident_Severity__c
				AND IFSA_Staff__r.IsActive = TRUE
				AND Incident_Category__c =:  theCase.Incident_Category__c 
				AND Incident_Sub_Category__c =: theCase.Incident_Sub_Category__c
				AND Incident_Sub_Subcategory__c = : theCase.Incident_Sub_Subcategory__c];
		else
			matrices = [SELECT id, support_role_type__c, ifsa_staff__c, ifsa_staff__r.Name FROM Incident_Matrix__c 
				WHERE Severity__c =: theCase.Incident_Severity__c 
				AND IFSA_Staff__r.IsActive = TRUE
				AND Incident_Category__c =:  theCase.Incident_Category__c 
				AND Incident_Sub_Category__c =: theCase.Incident_Sub_Category__c];
		// Map to group IFSA staff user id's with their IM records				
		Map<Id, List<Incident_Matrix__c>> userMatrixMap = new Map<Id, List<Incident_Matrix__c>>();
		for(Incident_Matrix__c matrix: matrices)
		{
			if(!userMatrixMap.containsKey(matrix.IFSA_Staff__c))
			{				
				userMatrixMap.put(matrix.IFSA_Staff__c, new List<Incident_Matrix__c>());
			}
			userMatrixMap.get(matrix.IFSA_Staff__c).add(matrix);
		}
		// Get the existing case team members
		List<CaseTeamMember> membersList = apexQueryUtility.selectAllFrom('CaseTeamMember', 'ParentId = \'' + theCase.Id + '\'');
		Set<Id> ctmUserIds = new Set<Id>();
		for(CaseTeamMember ctm: membersList)
		{
			ctmUserIds.add(ctm.MemberId);
		}
		// Create sets and lists to hold case team members, and entitysubscriptions(Chatter Follows)
		Set<CaseTeamMember> members = new Set<CaseTeamMember>();
		List<EntitySubscription> subscriptions = new List <EntitySubscription>();
		List<EntitySubscription> existingSubs = [SELECT Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentId =: theCase.Id LIMIT 200];		
		Set<Id> existingSubsriberIds = new Set<Id>();
		for(EntitySubscription es: existingSubs)
		{
			existingSubsriberIds.add(es.SubscriberId);
		}
		// make current user follow case in chatter if they are not following it
		if(!existingSubsriberIds.contains(UserInfo.getUserId()))
		{			
			subscriptions.add(new EntitySubscription(ParentId = theCase.Id, SubscriberId = UserInfo.getUserId()));
			existingSubsriberIds.add(UserInfo.getUserId());
			system.debug(UserInfo.getUserId());
		}
		if(!membersList.isEmpty())
		{
			members = new Set<CaseTeamMember>(membersList);
		}
		// Iterate over SP and IM records to see if the IFSA staff members should be added to the case team
		for(Support_Personnel__c sp: supportPersonnel)	
		{
			if(userMatrixMap.containsKey(sp.IFSA_Staff__c))
			{				
				for(Incident_Matrix__c matrix: userMatrixMap.get(sp.IFSA_Staff__c))
				{					
					if(matrix.Support_Role_Type__c == sp.Support_Role_Type__c && !ctmUserIds.contains(sp.IFSA_Staff__c))
					{
						// Create the Case Team Member record
						system.debug(matrix.ifsa_staff__r.Name);
						CaseTeamMember ctm = new CaseTeamMember();
						ctm.ParentId = theCase.Id;
						ctm.MemberId = matrix.IFSA_Staff__c;					
						ctm.TeamRoleId = roleMap.get(matrix.Support_Role_Type__c).Id;
						members.add(ctm);
						ctmUserIds.add(matrix.IFSA_Staff__c);
						// Make the case team member follow the case in Chatter if the do not already
						if(!existingSubsriberIds.contains(matrix.IFSA_Staff__c))
						{							
							subscriptions.add(new EntitySubscription(ParentId = theCase.Id, SubscriberId = matrix.IFSA_Staff__c));
							existingSubsriberIds.add(matrix.IFSA_Staff__c);
							system.debug(matrix.IFSA_Staff__c);
						}
					}
				}
			}
		}
		// Cleanup
		membersList.clear();
		membersList.addAll(members);
		// Possible unneeded debugging
		system.debug(existingSubsriberIds);
		for(EntitySubscription es: subscriptions)
		{
			system.debug(es.subscriberId);
		}
		// Upsert the case team members
		Database.UpsertResult[] results = database.upsert(membersList);
		for(Database.UpsertResult result: results)
		{
			if(!result.isSuccess())
			{
				// Return false if something goes wrong
				return false;
			}
		}
		// Insert the EntitySubscription (Chatter Follows)
		try
		{
			database.insert(subscriptions, false);
		}
		catch (DMLException dmlEx) 
		{
            //if we get an error because this user is already following this object, it's okay.
            if (dmlEx.getDmlType(0) == statusCode.DUPLICATE_VALUE) 
            {
                System.Debug('OrgTeamSubscribeOrg: subscription already exists');
            } 
            else 
            {
                //otherwise we have a more serious error that we need to throw.
                throw dmlEx;
            }
        }
		// Operation successful, return true
        return true;
	}
	/** 
	 * This class to be deleted once cases are fully implemented in standard Salesforce (So not using the ifsaCase VF page)
	 * THIS IS FOR LEGACY HSS CASES
	 * @author Brock Barlow
	*/
	public class relatedToCase
	{
		public List<SObject> objectsToInsert {get;set;}
		public List<SObject> objectsToUpdate {get;set;}
		public List<Case_Student__c> relatedStudents {get;set;}
		public List<Application__c> affectedApplications {get;set;}

		public relatedToCase()
		{
			this.objectsToInsert = new List<SObject>();
			this.objectsToUpdate = new List<SObject>();
			this.relatedStudents = new List<Case_Student__c>();
			this.affectedApplications = new List<Application__c>();
		}

		public relatedToCase import(relatedToCase imported)
		{
			this.objectsToInsert = imported.objectsToInsert;
			this.objectsToUpdate = imported.objectsToUpdate;
			this.relatedStudents = imported.relatedStudents;
			this.affectedApplications = imported.affectedApplications;

			return this;
		}
	}
	/**
	 * Finds a contact that is related to an internal user when they create a Help Ticket case from Email to Case
	 * @param newRecords New case records
	 */
	public static void setEmailToCaseUser(List<Case> newRecords)
	{
		List<String> emailAddresses = new List<String>();
		Set<Id> itCases = new Set<Id>{Schema.SObjectType.Case.getRecordTypeInfosByName().get('Help Ticket').getRecordTypeId(),Schema.SObjectType.Case.getRecordTypeInfosByName().get('Desktop & Network Support').getRecordTypeId(),Schema.SObjectType.Case.getRecordTypeInfosByName().get('Salesforce Support').getRecordTypeId()};

		for(Case c: newRecords)
		{
			if(c.SuppliedEmail != null && itCases.contains(c.RecordTypeId))
			{
				emailAddresses.add(c.SuppliedEmail);
			}
		}
		if(emailAddresses.isEmpty())
		{
			return;
		}
		Map<Id, User> users = new Map<Id, User>([SELECT Id, Name, Email FROM User WHERE Email IN: emailAddresses]);

		system.debug(users);
		for(Case c: newRecords)
		{
			for(User u: users.values())
			{
				if(c.SuppliedEmail == u.Email)
				{
					c.Email_to_Case_User__c = u.Id;
				}
			}
		}
	}
	/**
	 * Creates a help ticket for the Saleforce team to add a picklist value when a new program, city or country record is created. Ideally it would be awesome to use the Metadata API to automatically create the field, but the
	 * effort to do so is too high at this moment.
	 * @param objectName The name of the object that has a new record
	 * @param field The name of the field to get the value from
	 * @param value The new picklist value to create
	 */
	@future
	public static void createSFTicketToAddValueToPicklist (String objectName, String field, String value)
	{
		Case c = new Case(
			RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Salesforce Support').getRecordTypeId(),
			Subject = string.Format('Update {0} {1} picklist with {2} value', new List<Object>{objectName, field, value}),
			Priority = 'High',
			Description = string.Format('A new {0} record with the name {1} has been created. For Incident Management to continue to work, the value "{1}" needs added to the {0} picklist', new List<Object>{field, value})
		);

		// Uses assignment rules to properly assign case to proper queue
		AssignmentRule AR = new AssignmentRule(); 
		//Assignment Rule Query
		AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
		//Creating DML Options
		Database.DMLOptions dmlOpts = new Database.DMLOptions();
		if(AR != null){
			dmlOpts.assignmentRuleHeader.assignmentRuleID = AR.ID;
			c.setOptions(dmlOpts);
			Database.SaveResult success = Database.insert(c);
		}
	}
	/**
	 * Creates records to link Case with Multi-Student Cases, run on case after insert
	 * THIS IS FOR LEGACY HSS CASES
	 * @param newRecords - Cases being inserted
	*/
	public static void linkCaseToAffected(List<Case> newRecords)
	{
		// Get Record Type Ids
		Id cityCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident City').getRecordTypeId();
		Id countryCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Country').getRecordTypeId();
		Id hostInstitutionCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Host Institution').getRecordTypeId();
		Id programCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Program').getRecordTypeId();
		// List to hold affected case records to be created
		List<SObject> recordsToInsert = new List<SObject>();
		List<SObject> caseCities = new List<SObject>();
		List<SObject> caseCountries = new List<SObject>();
		List<SObject> caseHosts = new List<SObject>();
		List<SObject> casePrograms = new List<SObject>();
		// Map to hold related records to build affected case records
		Map<String, Locality__c> cities = new Map<String, Locality__c>();
		Map<String, Country__c> countries = new Map<String, Country__c>();
		Map<String, Host_Institution__c> hosts = new Map<String, Host_Institution__c>();
		Map<String, Program__c> programs = new Map<String, Program__c>();

		for(Locality__c l: [SELECT Id, Name FROM Locality__c WHERE RecordType.Name = 'City/Town' AND Country__r.Active__c = TRUE])
		{
			cities.put(l.Name, l);
		}

		for(Country__c c: [SELECT Id, Name FROM Country__c WHERE Active__c = TRUE])
		{
			countries.put(c.Name, c);
		}

		for(Host_Institution__c h: [SELECT Id, Name FROM Host_Institution__c WHERE Country__r.Active__c = TRUE])
		{
			hosts.put(h.Name, h);
		}

		for(Program__c p: [SELECT Id, Name FROM Program__c WHERE Active__c = TRUE])
		{
			programs.put(p.Name, p);
		}

		for(Case c: newRecords)
		{
			if(c.RecordTypeId == cityCase) 
			{
				for(String cityName: c.Affected_Cities__c.split(';'))
				{
					caseCities.add(new Case_City__c(
						City__c = cities.get(cityName).Id,
						Case__c = c.Id
					));
				}
			}
			else if(c.RecordTypeId == countryCase)
			{
				for(String countryName: c.Affected_Countries__c.split(';'))
				{
					caseCountries.add(new Case_Country__c(
						Country__c = countries.get(countryName).Id,
						Case__c = c.Id
					));
				}
			}
			else if(c.RecordTypeId == hostInstitutionCase)
			{
				for(String hostInstitutionName: c.Affected_Host_Institutions__c.split(';'))
				{
					caseHosts.add(new Case_Host_Institution__c(
						Host_Institution__c = hosts.get(hostInstitutionName).Id,
						Case__c = c.Id
					));
				}
			}
			else if(c.RecordTypeId == programCase)
			{
				for(String programName: c.Affected_Programs__c.split(';'))
				{
					casePrograms.add(new Case_Program__c(
						Program__c = programs.get(programName).Id,
						Case__c = c.Id
					));
				}
			}
		}
		recordsToInsert.addAll(caseCities);
		recordsToInsert.addAll(caseCountries);
		recordsToInsert.addAll(caseHosts);
		recordsToInsert.addAll(casePrograms);

		database.insert(recordsToInsert);

	}
	/**
	 * This creates a promise chain using <<promiseHealthSafetyCase>> to work with new case records
	 * @param newRecords The new case records
	 */
	public static void processNewIncidents(List<Case> newRecords)
	{
		for(Case c: newRecords)
		{
			new promiseHealthSafetyCase(c);
		}
	}
	/**
	 * This creates a promise chain using <<promiseHealthSafetyCase>> to work with updated case records.
	 * This will not allow the Queueable Jobs Limit to be exceeded.
	 * @param newRecords The updated case records
	 */
	public static void processIncidentUpdates(List<Case> newRecords)
	{
		for(Case c: newRecords)
		{
			// If this call returns 1 or 0 then most likely the case has already been updated and it the record does not need go through processing again.
			if(Limits.getLimitQueueableJobs() > 1)
			{
				new promiseHealthSafetyCase(c);
			}			
		}
	}
	/**
	 * Ensures that assignment rules are followed for cases.
	 * @param newRecordIds The Ids of new cases
	 */
	public static void useAssignmentRule(Set<Id> newRecordIds)
	{
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.AssignmentRuleHeader.useDefaultRule = true;
		List<Case> cases = new List<Case>();
		for(Id cId : newRecordIds) {
			Case c = new Case(Id = cId);
			c.setOptions(dmo);
			cases.add(c);
		}
		BaseTriggerHandler.bypass('caseTriggerHandler');
		update cases;
	}
	/**
	 * Ensures that the case creator is a part of a case team.
	 * @param newRecords The new case records
	 */
	public static void addCaseCreatorToCaseTeam(List<Case> newRecords)
	{
		Set<Id> userIds = new Set<Id>();
		List<CaseTeamMember> teamMembers = new List<CaseTeamMember>();
		for(Case c: newRecords)
		{
			userIds.add(c.CreatedById);
		}
		Map<String, CaseTeamRole> roleMap = new Map<String, CaseTeamRole>();
		for(CaseTeamRole role: [SELECT Id, Name FROM CaseTeamRole])
		{
			roleMap.put(role.Name, role);
		}
		Map<Id, User> users = new Map<Id, User>([SELECT Id, Incident_Management_Case_Team_Role__c FROM User WHERE (Id IN: userIds OR Id =: UserInfo.getUserId()) AND IsActive = TRUE]);
		for(Case c: newRecords)
		{
			User u = users.get(c.CreatedById);
			teamMembers.add(new CaseTeamMember(
				ParentId = c.Id,
				MemberId = u.Id,
				TeamRoleId = u.Incident_Management_Case_Team_Role__c != null ? roleMap.get(u.Incident_Management_Case_Team_Role__c).Id : roleMap.get('Other').Id
			));
		}

		Database.insert(teamMembers);
	}

}