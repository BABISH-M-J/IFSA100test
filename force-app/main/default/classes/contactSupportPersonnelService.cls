/**
 * Service class for Contact Support Personnel with Batchable methods, Batch method primarily used to delete.
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class contactSupportPersonnelService implements Queueable
{
	private Map<Id, Application__c> newAppsMap {get;set;}
	private Map<Id, Application__c> oldAppsMap {get;set;}
	private List<Application__c> newApplications {get;set;}
	private Map<Id, Contact> newContactsMap {get;set;}
	private Map<Id, Contact> oldContactsMap {get;set;}
	private List<Contact> newContacts {get;set;}
	private String objectName {get;set;}
	private Set<Id> contactIds {get;set;}

	/**
	 * Basic construtor
	 */
	public contactSupportPersonnelService()
	{
		this.contactIds = new Set<Id>();
	}
	/**
	 * Constructor, updates CSP records when applications have been updated
	 * @param newApps
	 * @param oldApps
	 */
	public contactSupportPersonnelService(Map<Id, Application__c> newApps, Map<Id, Application__c> oldApps)
	{
		this();
		this.newAppsMap = newApps;
		this.oldAppsMap = oldApps;
		this.objectName = 'Application__c';
		for(Application__c app: newApps.values())
		{
			this.contactIds.add(app.Applicant__c);
		}
	}
	/**
	 * Constructor, updates CSP records when contacts have been updated
	 * @param newContactRecords
	 * @param newContacts
	 * @param oldContacts
	 */
	public contactSupportPersonnelService(List<Contact> newContactRecords, Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts)
	{
		this();
		this.newContactsMap = newContacts;
		this.oldContactsMap = oldContacts;
		this.newContacts = newContactRecords;
		this.objectName = 'Contact';
		this.contactIds = newContacts.keySet();
	}
	/**
	 * Constructor, Dedups CSP records for contacts
	 * @param cIds contact ids to dedup CSP records
	 */
	public contactSupportPersonnelService(Set<Id> cIds)
	{
		this.objectName = 'Deduplicate';
		this.contactIds = cIds;
	}

	/**
	 * Queuable execute method
	 */
   	public void execute(QueueableContext context) {
		List<Contact_Support_Personnel__c> cspRecordsToAdd = new List<Contact_Support_Personnel__c>();
		// Deduplicates CSP records for provided contact ids
		if(this.objectName == 'Deduplicate')
		{			
			Set<String> cspKey = new Set<String>();
			List<Id> cspToDelete = new List<Id>();
			for(Contact_Support_Personnel__c csp: [SELECT Id, Contact__c, Support_Personnel__c FROM Contact_Support_Personnel__c WHERE Contact__c IN: this.contactIds FOR UPDATE])
			{
				String key = String.format('{0}{1}', new List<object>{csp.Contact__c, csp.Support_Personnel__c});
				system.debug(key);
				if(!cspKey.contains(key))
				{
					system.debug('Adding key: ' + key);
					cspKey.add(key);
					system.debug(cspKey.size());
				}
				else
				{
					system.debug('Deleting: ' + csp);
					cspToDelete.add(csp.Id);
				}
			}			
			database.delete(cspToDelete);
		}
		else 
		{
			//ACARSON 05.29.2018 Added set to prevent duplication of CSP records on a student
			Set<Contact_Support_Personnel__c> cspRecords = new Set<Contact_Support_Personnel__c>();
			if(this.objectName == 'Application__c')
			{
				cspRecords.addAll(applicaitonCSPGeneration(this.oldAppsMap, newAppsMap));
				this.newContacts = apexQueryUtility.selectAllFrom('Contact', 'Id IN ' + apexQueryUtility.buildInClause(newAppsMap.values(), 'Applicant__c'));
				this.oldContactsMap = new Map<Id, Contact>(this.newContacts);
				this.newContactsMap = this.oldContactsMap;
			}
			this.newContacts = removeNonStudentsFromList(this.newContacts);
			this.oldContactsMap = this.oldContactsMap != null ? removeNonStudentsFromMap(this.oldContactsMap) : null;
			this.newContactsMap = this.newContactsMap != null ? removeNonStudentsFromMap(this.newContactsMap) : null;

			cspRecords.addAll(contactCSPGeneration(oldContactsMap, newContactsMap));
			//ACARSON 05.29.2018 Add values from the set to the list to update/insert
			cspRecordsToAdd.addAll(cspRecords);

			if(!cspRecordsToAdd.isEmpty())
			{
				updateCSP(cspRecordsToAdd);
			}
			// Run async job to ensure that CSP records are not duplicated.
			if(!Test.isRunningTest())
			{
				system.enqueueJob(new contactSupportPersonnelService(this.contactIds));
			}			
		}		
	}	
	/**
	 * Method that removes non student contacts from a list
	 * @param contacts List of Contacts
	 * @return List of Contacts without non-student contacts
	 */	
	private static List<Contact> removeNonStudentsFromList(List<Contact> contacts)
	{
		List<Contact> tempNew = new List<Contact>();		
		for(Contact c: contacts)
		{
			if(c.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId())
			{
				tempNew.add(c);
			}
		}
		return tempNew;
	}
	/**
	 * Method that removes non student contacts from a map
	 * @param contacts Map of Id, Contact
	 * @return Map of Id, Contact without non-student contacts
	 */	
	private static Map<Id, Contact> removeNonStudentsFromMap(Map<Id, Contact> contacts)
	{
		Map<Id, Contact> tempMap = new Map<Id, Contact>();

		for(Contact c: contacts.values())
		{
			if(c.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId())
			{
				tempMap.put(c.Id, c);
			}
		}
		return tempMap;
	}
	/**
	 * Gets student CSPs wtihout using applications id's
	 * @param studentMap Map of Id, Contact
	 * @return Map<Id, Set<Contact_Support_Personnel__c>> Map of Id, Set of Contact Support Personnel
	 */
	public static Map<Id, Set<Contact_Support_Personnel__c>> getStudentCSPMap(Map<Id, Contact> studentMap)
	{		
		return getStudentCSPMap(studentMap, null);
	}
	/**
	 * Gets student CSPs
	 * @param studentMap Map of Id, Contact
	 * @param applicationIds Set of Application__c Id
	 * @return Map<Id, Set<Contact_Support_Personnel__c>> Map of Id, Set of Contact Support Personnel
	 */
	public static Map<Id, Set<Contact_Support_Personnel__c>> getStudentCSPMap(Map<Id, Contact> studentMap, Set<Id> applicationIds)
	{
		Map<Id, Set<Contact_Support_Personnel__c>> studentCSPMap = new Map<Id, Set<Contact_Support_Personnel__c>>();		
		List<Contact_Support_Personnel__c> cspList = new List<Contact_Support_Personnel__c>();
		if(applicationIds == null)
			cspList = [SELECT Id, Contact__c, Support_Personnel__c, Application__c FROM Contact_Support_Personnel__c WHERE Contact__c IN: studentMap.keySet()];
		else
			cspList = [SELECT Id, Contact__c, Support_Personnel__c, Application__c FROM Contact_Support_Personnel__c WHERE Contact__c IN: studentMap.keySet() AND (Application__c = NULL OR Application__c IN: applicationIds)];
		for(Id studentId: studentMap.keySet())
		{
			if(!studentCSPMap.containsKey(studentId))
			{
				studentCSPMap.put(studentId, new Set<Contact_Support_Personnel__c>());
			}
			for(Contact_Support_Personnel__c csp: cspList)
			{
				if(csp.Contact__c == studentId)
				{
					studentCSPMap.get(studentId).add(csp);
				}
			}
		}
		return studentCSPMap;
	}
	/**
	 * gets CSP Records to add
	 * @param studentCSPOldMap - Map of Id, Set of Contact Support Personnel
	 * @param studentCSPMap - Map of Id, Set of Contact Support Personnel
	 * @param isUpdate - Boolean
	 * @return List<Contact_Support_Personnel__c> List of Contact Support Personnel
	 */

	public static List<Contact_Support_Personnel__c> getCSPRecordsToAdd(Map<Id, Set<Contact_Support_Personnel__c>> studentCSPOldMap, Map<Id, Set<Contact_Support_Personnel__c>> studentCSPMap, Boolean isUpdate)
	{
		Set<Contact_Support_Personnel__c> cspRecordsToAdd = new Set<Contact_Support_Personnel__c>();
		if(!isUpdate)
		{
			for(Id studentId: studentCSPMap.keySet())
			{
				cspRecordsToAdd.addAll(studentCSPMap.get(studentId));
			}
			return new List<Contact_Support_Personnel__c>(cspRecordsToAdd);
		}
		else
		{
			for(Id studentId: studentCSPMap.keySet())
			{
				Set<Contact_Support_Personnel__c> updateCSP = studentCSPMap.get(studentId);
				//Set<Contact_Support_Personnel__c> currentCSP = studentCSPOldMap.get(studentId);
				Map<Id, Contact_Support_Personnel__c> currentCSP = new Map<Id, Contact_Support_Personnel__c>();
				if(studentCSPOldMap.get(studentId) != null)
				{
					for(Contact_Support_Personnel__c csp: studentCSPOldMap.get(studentId))
					{
						currentCSP.put(csp.Support_Personnel__c, csp);
					}
				}
				system.debug(updateCSP.size());
				system.debug(currentCSP.size());
				for(Contact_Support_Personnel__c uCSP: updateCSP)
				{
					if(!currentCSP.containsKey(uCSP.Support_Personnel__c))
					{
						cspRecordsToAdd.add(uCSP);
					}
					/*else
					{
						for(Contact_Support_Personnel__c csp: )
					}*/
				}
			}

			return new List<Contact_Support_Personnel__c>(cspRecordsToAdd);
		}
	}
	/**
	 * Creates CSP record
	 * @param studentId - Id of student record new CSP record is related to
	 * @param applicationId - Id of student's application record new CSP record is related to
	 * @param supportPersonnel - SP record from which CSP record is created from
	 * @return Contact_Support_Personnel__c
	 */
	public static Contact_Support_Personnel__c createCSP(Id studentId, Id applicationId, Support_Personnel__c supportPersonnel)
	{
		Contact_Support_Personnel__c csp = new Contact_Support_Personnel__c();
		csp.Contact__c = studentId;
		csp.Support_Personnel__c = supportPersonnel.Id;
		if(supportPersonnel.Region__c == null && applicationId != null)
		{
			csp.Application__c = applicationId;
		}
		return csp;
	}
	/**
	 * Deletes CSP records in phases.
	 * Ten days after an application status is changed to Deferred, Diverted, Dropped, Rejected or Unqualified delete the application CSP records.
	 * 180 days after an application status is changed to Program Completed or Withdraw delete the application CSP records.
	 * One year after an application status is changed to Program Completed or Withdraw delete the contact CSP records.
	 */
	public static void purgeCSP()
	{
		// Create Datetime vars to hold the dates used in the SOQL queries
		Datetime yesterday = Datetime.now().addDays(-1);
		Datetime tenDays = Datetime.now().addDays(-10);
		Datetime oneHundredEightyDays = Datetime.now().addDays(-180);
		Datetime oneYear = Datetime.now().addYears(-1);
		// Query for applications that need CSP records purged
		Map<Id, Application__c> completedApps = new Map<Id, Application__c>([SELECT Id FROM Application__c WHERE Override_CSP_Purge_Schedule__c = FALSE 
			AND (Status_Deferred__c <: tenDays  OR Status_Diverted__c <: tenDays OR Status_Dropped__c <: tenDays 
			OR Status_Rejected__c <: tenDays OR Status_Unqualified__c <: yesterday OR Status_Program_Completed__c <: oneHundredEightyDays 
			OR Status_Withdraw__c <: oneHundredEightyDays OR Status_Deceased__c <: oneHundredEightyDays)]);
		// Query for contacts that need CSP records purged		
		Map<Id, Contact> completedStudents = new Map<Id, Contact>([SELECT Id FROM Contact WHERE Active_Application__r.Override_CSP_Purge_Schedule__c = FALSE
			AND (Active_Application__r.Status_Dropped__c <: tenDays OR Active_Application__r.Status_Rejected__c <: oneYear 
			OR Active_Application__r.Status_Unqualified__c <: yesterday OR Active_Application__r.Status_Program_Completed__c <: oneYear 
			OR Active_Application__r.Status_Withdraw__c <: oneYear OR Active_Application__r.Status_Deceased__c <: oneYear)]);
		system.debug(completedApps);
		system.debug(completedStudents);
		// Get the CSP records to be deleted
		List<Contact_Support_Personnel__c> cspsToDelete = new List<Contact_Support_Personnel__c>();
		cspsToDelete.addAll([SELECT Id FROM Contact_Support_Personnel__c WHERE Application__c IN: completedApps.keySet() LIMIT :50000 - Limits.getQueryRows()]);
		cspsToDelete.addAll([SELECT Id FROM Contact_Support_Personnel__c WHERE Contact__c IN: completedStudents.keySet() LIMIT :50000 - Limits.getQueryRows()]);
		// Delete CSP records in batchs of 200
		system.debug(cspsToDelete.size()*2 + 'KB freed by deleting these ' + cspsToDelete.size() + ' rows');
		sObjectBatchUpdater.batchUpdate(cspsToDelete, 200, sObjectBatchUpdater.dmlTypes.dmlDelete);
	}
	/**
	 * Method to generate CSP records for Contacts
	 * @param oldMap
	 * @param newMap
	 * @return List<Contact_Support_Personnel__c>
	 */	
	private static List<Contact_Support_Personnel__c> contactCSPGeneration(Map<Id, Contact> oldMap, Map<Id, Contact> newMap)
	{
		//Get existing CSP Records
		Boolean isUpdate = false;
		Map<Id, Set<Contact_Support_Personnel__c>> studentCSPOldMap = new Map<Id, Set<Contact_Support_Personnel__c>>();
		if(oldMap != null && !oldMap.isEmpty())
		{			
			studentCSPOldMap = contactSupportPersonnelService.getStudentCSPMap(oldMap);
			isUpdate = true;
		}

		Map<Id, Set<Contact_Support_Personnel__c>> studentCSPMap = new Map<Id, Set<Contact_Support_Personnel__c>>();
		Map<Id, Id> studentsWithHomeInstitutions = new Map<Id, Id>();
		List<Contact> studentContacts = [SELECT Id, Active_Application__c, Active_Application__r.Create_CSP_Records__c, Home_Institution__c, Home_Institution__r.Account__c, Created_For_Custom__c FROM Contact WHERE Id IN: newMap.keySet()]; // AND RecordType.DeveloperName = 'Student'];
		system.debug(studentContacts.size());
		for(Contact c: studentContacts)
		{
			if(c.Active_Application__c == null || c.Active_Application__r.Create_CSP_Records__c)
			{
				studentCSPMap.put(c.Id, new Set<Contact_Support_Personnel__c>());
				if(c.Home_Institution__c != null) 
				{
					studentsWithHomeInstitutions.put(c.Id, c.Home_Institution__r.Account__c);
				}
			}
		}

		List<Support_Personnel__c> spList = getContactSupportPersonnel(studentsWithHomeInstitutions.values(), studentsWithHomeInstitutions.keySet());				
		system.debug(spList.size());
		system.debug(studentContacts.size());
		for(Support_Personnel__c sp: spList)
		{
			for(Contact c: studentContacts)
			{
				if(studentCSPMap.containsKey(c.Id))
				{
					if(c.Id == sp.Contact__c)
					{
						Boolean hasCSP = false;
						for(Contact_Support_Personnel__c csp: studentCSPMap.get(c.Id))
						{
							if(csp.Support_Personnel__c == sp.Id)
							{
								hasCSP = true;
							}
						}
						if(!hasCSP)
						{
							system.debug('Student Id: ' + c.Id + ' SP.Contact__c: ' + sp.Contact__c);
							studentCSPMap.get(c.Id).add(contactSupportPersonnelService.createCSP(c.Id, null, sp));
						}
					}
					else if(sp.World__c != null)
					{

						studentCSPMap.get(c.Id).add(contactSupportPersonnelService.createCSP(c.Id, null, sp));
					}
					else if(sp.Region__c != null)
					{
						studentCSPMap.get(c.Id).add(contactSupportPersonnelService.createCSP(c.Id, null, sp));
					}
					//ACARSON May.23.2018 Changed logic to check for value in account to prevent superfluous Support personnel records and added logic to grab from Home Institution record
					//else if(c.Home_Institution__r.Account__c == sp.Account__c && (sp.Support_Role_Type__c == 'Advisor' || sp.Support_Role_Type__c == 'Other' || sp.Support_Role_Type__c == 'Faculty/Staff' || sp.Support_Role_Type__c == 'Field Director') && sp.Non_IFSA_Staff__r.Created_For_Custom__c == c.Created_for_Custom__c)
					else if(sp.Account__c != null && c.Home_Institution__r.Account__c == sp.Account__c && ((sp.Support_Role_Type__c == 'Advisor' || sp.Support_Role_Type__c == 'Other' || sp.Support_Role_Type__c == 'Faculty/Staff' && sp.Non_IFSA_Staff__r.Created_For_Custom__c == false)|| sp.Support_Role_Type__c == 'Field Director'))
					{
						studentCSPMap.get(c.Id).add(contactSupportPersonnelService.createCSP(c.Id, null, sp));
					}
					else if(sp.Home_Institution__c != null && c.Home_Institution__c == sp.Home_Institution__c && sp.Support_Type__c == 'Home Institution' && (sp.Support_Role_Type__c == 'Field Director' || sp.Non_IFSA_Staff__r.Created_For_Custom__c == false))
					{
						studentCSPMap.get(c.Id).add(contactSupportPersonnelService.createCSP(c.Id, null, sp));
					}
				}
			}
		}

		return contactSupportPersonnelService.getCSPRecordsToAdd(studentCSPOldMap, studentCSPMap, isUpdate);
	}

	/**
	 * Method to generate Contact Support Personnel for Applications
	 * @param oldMap
	 * @param newMap
	 * @return List<Contact_Support_Personnel__c>
	 */
	private static List<Contact_Support_Personnel__c> applicaitonCSPGeneration(Map<Id, Application__c> oldMap, Map<Id, Application__c> newMap)
	{
		Boolean isUpdate = false;
		Map<Id, Set<Contact_Support_Personnel__c>> studentCSPOldMap = new Map<Id, Set<Contact_Support_Personnel__c>>();
		if(oldMap != null)
		{
			List<Id> studentIds = new List<Id>();
			for(Application__c app: oldMap.values())
			{
				studentIds.add(app.Applicant__c);
			}

			Map<Id, Contact> currentContactMap = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id IN: studentIds]);
			studentCSPOldMap = getStudentCSPMap(currentContactMap, oldMap.keySet());
			isUpdate = true;
		}
		Map<Id, Application__c> newMapWithRelatedFieleds = new Map<Id, Application__c>(
			[SELECT Id, Applicant__c, Create_CSP_Records__c, Home_Institution_Advisor_SP__c, Program_Term__c, Program_Term__r.Parent_Program_Term__c, Program_Term__r.Program__r.Host_Institution__r.Locality__c, 
				Program_Term__r.Program__r.Host_Institution__r.Country__c, Program_Term__r.Program__c, Program_Term__r.Program__r.Host_Institution__c, Applicant__r.Created_For_Custom__c
				FROM Application__c WHERE Id IN: newMap.keySet()]);

		Map<Id, Set<Contact_Support_Personnel__c>> studentCSPMap = new Map<Id, Set<Contact_Support_Personnel__c>>();
		Map<Id, Id> studentsHostInstitutions = new Map<Id, Id>();
		Map<Id, Id> studentCountries = new Map<Id, Id>();
		Map<Id, Id> studentLocalities = new Map<Id, Id>();
		Map<Id, Id> studentPrograms = new Map<Id, Id>();
		Map<Id, Id> studentProgramTerms = new Map<Id, Id>();
		Map<Id, Id> studentParentProgramTerms = new Map<Id, Id>();
		Map<Id, Id> studentHomeInstitutionAdvisorSP = new Map<Id, Id>();
		List<Contact_Support_Personnel__c> cspRecordsToAdd = new List<Contact_Support_Personnel__c>();		
		Map<Id, Id> deleteSPAppMap = new Map<Id, Id>();

		for(Application__c app: newMapWithRelatedFieleds.values())
		{
			if(app.Create_CSP_Records__c)
			{
				studentCSPMap.put(app.Applicant__c, new Set<Contact_Support_Personnel__c>());
				if(app.Program_Term__r.Program__r.Host_Institution__c != null) studentsHostInstitutions.put(app.Applicant__c, app.Program_Term__r.Program__r.Host_Institution__c);
				if(app.Program_Term__r.Program__r.Host_Institution__r.Country__c != null) studentCountries.put(app.Applicant__c, app.Program_Term__r.Program__r.Host_Institution__r.Country__c);
				if(app.Program_Term__r.Program__r.Host_Institution__r.Locality__c != null) studentLocalities.put(app.Applicant__c, app.Program_Term__r.Program__r.Host_Institution__r.Locality__c);
				if(app.Program_Term__r.Program__c != null) studentPrograms.put(app.Applicant__c, app.Program_Term__r.Program__c);
				if(app.Program_Term__c != null) studentProgramTerms.put(app.Applicant__c, app.Program_Term__c);
				if(app.Program_Term__r.Parent_Program_Term__c != null) studentParentProgramTerms.put(app.Applicant__c, app.Program_Term__r.Parent_Program_Term__c);
				if(app.Home_Institution_Advisor_SP__c != null)
				{
					Application__c oldApp = oldmap.get(app.Id);
					if(oldApp.Home_Institution_Advisor_SP__c != null && oldApp.Home_Institution_Advisor_SP__c != app.Home_Institution_Advisor_SP__c)
					{
						deleteSPAppMap.put(oldApp.Id, oldApp.Home_Institution_Advisor_SP__c);
					}
					studentHomeInstitutionAdvisorSP.put(app.Applicant__c, app.Home_Institution_Advisor_SP__c);
				}
			}
		}
																							//, studentCSPMap.keySet() Taken out of call below
		List<Support_Personnel__c> spList = getContactSupportPersonnel(studentsHostInstitutions.values(), studentCountries.values(), studentLocalities.values(), studentPrograms.values(), studentProgramTerms.values(), studentParentProgramTerms.values(), studentHomeInstitutionAdvisorSP.values());
		for(Support_Personnel__c sp: spList)
		{
			for(Application__c app: newMapWithRelatedFieleds.values())
			{
				if(studentCSPMap.containsKey(app.Applicant__c))
				{
					//ACARSON 05.29.2018 Added null checks to prevent superfluous CSPs from being created.
					if(sp.Region__c != null ) //|| sp.Contact__c == app.Applicant__c
					{
						studentCSPMap.get(app.Applicant__c).add(createCSP(app.Applicant__c, app.Id, sp));
					}
					else if(app.Program_Term__r.Program__r.Host_Institution__c != null && sp.Host_Institution__c == app.Program_Term__r.Program__r.Host_Institution__c && sp.RecordType.Name == 'Host Institution')
					{
						studentCSPMap.get(app.Applicant__c).add(createCSP(app.Applicant__c, app.Id, sp));
					}
					else if(app.Program_Term__r.Program__r.Host_Institution__r.Country__c != null && sp.Country__c == app.Program_Term__r.Program__r.Host_Institution__r.Country__c && sp.RecordType.Name == 'Country')
					{
						studentCSPMap.get(app.Applicant__c).add(createCSP(app.Applicant__c, app.Id, sp));
					}
					else if(app.Program_Term__r.Program__r.Host_Institution__r.Locality__c != null && sp.Locality__c == app.Program_Term__r.Program__r.Host_Institution__r.Locality__c && sp.RecordType.Name == 'Locality')
					{
						studentCSPMap.get(app.Applicant__c).add(createCSP(app.Applicant__c, app.Id, sp));
					}
					else if(app.Program_Term__r.Program__c != null && sp.Program__c == app.Program_Term__r.Program__c && sp.RecordType.Name == 'Program')
					{
						studentCSPMap.get(app.Applicant__c).add(createCSP(app.Applicant__c, app.Id, sp));
					}
					else if(app.Program_Term__c != null && sp.Program_Term__c == app.Program_Term__c && sp.RecordType.Name == 'Program Term')
					{
						studentCSPMap.get(app.Applicant__c).add(createCSP(app.Applicant__c, app.Id, sp));
					}
					else if(sp.Program_Term__r.Parent_Program_Term__c != null && sp.Program_Term__r.Parent_Program_Term__c == app.Program_Term__r.Parent_Program_Term__c && sp.RecordType.Name == 'Program Term')
					{
						studentCSPMap.get(app.Applicant__c).add(createCSP(app.Applicant__c, app.Id, sp));
					}
					else if(sp.Id == app.Home_Institution_Advisor_SP__c && sp.RecordType.Name == 'Account' && sp.Non_IFSA_Staff__r.Created_For_Custom__c == false)
					{
						studentCSPMap.get(app.Applicant__c).add(createCSP(app.Applicant__c, app.Id, sp));
					}
				}
			}
		}

		if(!deleteSPAppMap.isEmpty())
			deleteCSP(deleteSPAppMap);

		return getCSPRecordsToAdd(studentCSPOldMap, studentCSPMap, isUpdate);
	}

	/**
	 * Method to get Support Personnel Records for Applications
	 * @param hostInstitutionIds
	 * @return List<Support_Personnel__c>
	 */
	private static List<Support_Personnel__c> getContactSupportPersonnel(List<Id> hostInstitutionIds, 
		List<Id> countryIds, List<Id> localityIds, List<Id> programIds, List<Id> programTermIds, List<Id> parentProgramTermIds, List<Id> homeAdvisorSPIds) //Set<Id> contactIds,
	{
		return [SELECT Id, IFSA_Staff__c, Non_IFSA_Staff__c, Support_Role_Type__c, Host_Institution__c, Program__c, Program_Term__c,
				Region__c, Country__c, Program_Term__r.Parent_Program_Term__c, Locality__c, RecordType.Name, Non_IFSA_Staff__r.Created_For_Custom__c, Non_IFSA_Staff__r.Name //Contact__c,
				FROM Support_Personnel__c WHERE Region__r.Name = 'International Support' OR Host_Institution__c IN: hostInstitutionIds 
				OR Country__c IN: countryIds OR Locality__c IN: localityIds OR Program__c IN: programIds OR Program_Term__c IN: programTermIds 
				OR Program_Term__r.Parent_Program_Term__c IN: parentProgramTermIds OR Id IN: homeAdvisorSPIds]; //OR Contact__c IN: contactIds];
	}
	/**
	 * Method to get Support Personnel for a contact
	 * @param homeInstitutionIds
	 * @param studentsIds
	 * @return List<Support_Personnel__c>
	 */	
	private static List<Support_Personnel__c> getContactSupportPersonnel(List<Id> homeInstitutionIds, Set<Id> studentsIds)
	{
		return [SELECT Id, IFSA_Staff__c, Non_IFSA_Staff__c, Non_IFSA_Staff__r.Created_For_Custom__c, Support_Role_Type__c, Support_Type__c, Account__c, Contact__c, World__c, Region__c, Home_Institution__c, Home_Institution__r.Account__c 
			FROM Support_Personnel__c 
			WHERE World__r.Name = 'Global' 
			OR Region__r.Name = 'Local Support' 
			OR (Account__c IN: homeInstitutionIds AND (Emergency_Contact__c = TRUE OR Support_Role_Type__c = 'Field Director')) 
			OR Contact__c IN: studentsIds];
	}
	
	/**
	 * Method to delete CSP records
	 * @param delMap
	 */
	private static void deleteCSP(Map<Id, Id> delMap)	
	{
		/*List<Contact_Support_Personnel__c> cspToDelete = [SELECT Id, Support_Personnel__c, Application__c FROM Contact_Support_Personnel__c WHERE Application__c IN: delMap.keySet() AND Support_Personnel__c IN: delMap.values()];
		if(cspToDelete.isEmpty())
			throw new QueryException();*/
		List<Contact_Support_Personnel__c> csps = [SELECT Id FROM Contact_Support_Personnel__c WHERE Application__c IN: delMap.keySet() AND Support_Personnel__c IN: delMap.values()];
		sObjectBatchUpdater cspJob = new sObjectBatchUpdater(csps, sObjectBatchUpdater.dmlTypes.dmlDelete);
		Id batchId = Database.executeBatch(cspJob);
	}

	/**
	 * Method to update/insert CSP records.
	 * @param cspRecords
	 */
	private static void updateCSP(List<Contact_Support_Personnel__c> cspRecords)
	{
		Id jobId = Database.executeBatch(new sObjectBatchUpdater(cspRecords, sObjectBatchUpdater.dmlTypes.dmlUpsert));
		system.debug(jobId);
	}
}