/**
 * Service class for Application, Business logic executed by <<applicationTriggerHandler>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public without sharing class applicationService
{
	/**
	 * DML Operations
	 */
	public enum triggerType
	{
		isInsert,isUpdate,isDelete,isBefore,isAfter
	}
	/**
	 * Method to update the application owner.
	 * @param oldMap
	 * @param newRecords
	 * @param type Determines in what context this method is running
	 */
	public static void updateApplicationOwner (Map<Id, Application__c> oldMap, List<Application__c> newRecords, triggerType type)
	{
		if(type == triggerType.isBefore)
		{
			Set<Id> programTermIds = new Set<Id>();
			Set<Id> programOptionsIds = new Set<Id>();
			for(Application__c app: newRecords)
			{
				programTermIds.add(app.Program_Term__c);
				// if(app.Program_Option__c != null)
				// 	programOptionsIds.add(app.Program_Option__c);
			}
			Map<Id, Program_Term__c> programTermMap = !programTermIds.isEmpty() ? new Map<Id, Program_Term__c>([SELECT Id, OwnerId FROM Program_Term__c WHERE Id IN: programTermIds]) : null;
			//Map<Id, Program_Option__c> programOptionsMap = !programOptionsIds.isEmpty() ? new Map<Id, Program_Option__c>([SELECT Id, Program_Advisor__c FROM Program_Option__c WHERE Id IN: programOptionsIds]) : null;

			for(Application__c app: newRecords)
			{
				Application__c currentApp = oldMap != null ? oldMap.get(app.Id) : new Application__c();
				/*if(app.Program_Option__c != null)
				{
					if(currentApp.OwnerId != programOptionsMap.get(app.Program_Option__c).Program_Advisor__c)
					{
						app.OwnerId = programOptionsMap.get(app.Program_Option__c).Program_Advisor__c;
					}
				} else*/ 
				if(app.Program_Term__c != null)			
				{
					if(currentApp.OwnerId != programTermMap.get(app.Program_Term__c).OwnerId)
					{
						app.OwnerId = programTermMap.get(app.Program_Term__c).OwnerId;
					}
				}
			}
		}
		else if(type == triggerType.isAfter)
		{
			Set<Contact> contacts = new Set<Contact>();
			for(Application__c app: newRecords)
			{
				contacts.add(new Contact(Id = app.Applicant__c));
			}
			system.debug(contacts.size());
			database.update(new List<Contact>(contacts));
		}
	}
	/**
	 * Method to mark application and eligible grades as verified
	 * @param app The application to mark as "Grades Verified"
	 */
	public static void gradesVerified(Application__c app)
	{		
		List<Course_Registration__c> courses = [SELECT Id, Course_Term__c, Status__c, Application__c, LastModifiedDate, Final_Grade__c FROM Course_Registration__c WHERE Status__c IN ('Grade Entered','Grade Revised','Grade Submitted','Grade Corrected') AND Application__c =: app.Id];
		Map<Id, List<Course_Registration__c>> applicationCourses = new Map<Id, List<Course_Registration__c>>();
		List<Course_Registration__c> verifiedCourseRegistrations = new List<Course_Registration__c>();
		for(Course_Registration__c cr: courses)
		{
			if(!applicationCourses.containsKey(cr.Application__c))
				applicationCourses.put(cr.Application__c, new List<Course_Registration__c>());
			applicationCourses.get(cr.Application__c).add(cr);
		}

		for(Id appId: applicationCourses.keySet())
		{
			Set<String> courseTerms = new Set<String>();
			List<Course_Registration__c> appCourses = applicationCourses.get(appId);
			for(Course_Registration__c cr: appCourses)
			{
				courseTerms.add(cr.Course_Term__c);
			}
			if(courseTerms.size() > 2)
			{
				verifiedCourseRegistrations.addAll(appCourses);
			}
			else
			{
				String termToSelect;
				Map<String, List<Course_Registration__c>> termCoursesMap = new Map<String, List<Course_Registration__c>>();
				for(String name: courseTerms)
				{
					termCoursesMap.put(name, new List<Course_Registration__c>());
				}
				for(Course_Registration__c cr: appCourses)
				{
					termCoursesMap.get(cr.Course_Term__c).add(cr);					
				}
				for(String termName: termCoursesMap.keySet())
				{
					Boolean allSubmitted = true;
					Boolean allHaveGrade = true;
					List<Course_Registration__c> crList = termCoursesMap.get(termName);
					for(Course_Registration__c cr: crList)
					{
						if(cr.Status__c != 'Grade Submitted')
						{
							allSubmitted = false;
						}
						if(cr.Final_Grade__c == null)
						{
							allHaveGrade = false;
						}
					}
					if(!allSubmitted && allHaveGrade)
					{
						verifiedCourseRegistrations.addAll(crList);
					}					
				}				
			}
		}

		courseRegistrationService.courseRegistrationGradesVerified(verifiedCourseRegistrations);
	}
	/**
	 * Method to update application item phase of incomplete application items when an application changes to submitted status. 
	 * Also used when application is "Accepeted" to start the process of creating application line items
	 * @param newMap
	 * @param oldMap
	 * @param newRecords
	 */
	public static void updateAppItemsPhase (Map<Id, Application__c> newMap, Map<Id, Application__c> oldMap, List<Application__c> newRecords)
	{
		//Get applications //[SELECT Id, Status__c,Application_Home_Institution__c, Program_Term__c, Program_Term__r.Parent_Program_Term__c FROM Application__c WHERE Id IN: newMap.keySet()];
		List<Application__c> appList = new List<Application__c>();
		List<Id> idList = new List<Id>();
		
		//Add application Id's to list of application ids
		for(Application__c application : newMap.values())
		{
			if(oldMap.get(application.Id).Status__c != newMap.get(application.Id).Status__c && (application.Status__c == 'Accepted' || application.Status__c == 'Accepted (With Conditions)' || application.Status__c == 'Ready To Submit' || application.Status__c == 'Submitted'))
			{
				idList.add(application.Id);
			}
		}
			
		//If we have an Id, get the application items and mark incomplete pre-admits as pre-acceptance
		if(idList.size() >= 1)
		{
			appList = apexQueryUtility.selectAllFrom('Application__c', 'Program_Term__r.Parent_Program_Term__c', 'Id IN ' + apexQueryUtility.buildInClause(idList));
			//Get all application items pertaining to our application
			//List<Application_Item__c> appItems = apexQueryUtility.selectAllFrom('Application_Item__c',whereClause);
			List<Application_Item__c> appItems = [SELECT Id, Status__c, Phase__c FROM Application_Item__c WHERE Application__c IN: idLIst];
			//If our application item is incomplete pre-admit, move it to pre-acceptance
			for(Application_Item__c appItem : appItems)
			{
				if(appItem.Status__c == 'Incomplete' && appItem.Phase__c == 'Pre-Admit')
				{
					appItem.Phase__c = 'Pre-Acceptance';
				}
			}
			
			Database.update(appItems);
		}

		List<Application__c> acceptedApps = new List<Application__c>();
		List<String> homeInstituitionNames = new List<String>();
		List<Id> progTermIds = new List<Id>();
		List<Id> appIds = new List<Id>();
		for(Application__c app: appList)
        {
            if(newMap.get(app.Id).Status__c != oldMap.get(app.Id).Status__c && newMap.get(app.Id).Status__c.contains('Accepted') && newMap.get(app.Id).Application_Line_Item_Count__c < 1)
            {
            	acceptedApps.add(app);
	            progTermIds.add(app.Program_Term__c);
				progTermIds.add(app.Program_Term__r.Parent_Program_Term__c);
	            homeInstituitionNames.add(app.Application_Home_Institution__c);
	            //appIds.add(app.Id);
            }
        }
        
        if(!acceptedApps.isEmpty())
	    {
	    	//applicationService.generateDepositLineItem(appIds);
	    	system.debug(acceptedApps.size());
	    	//ifsaLineItemPopulator.populateApplications(appIds);
	    	/* This needs commented out for future development for finance but needs to be used still in production. Remove the end comment tag -> */
	    	List<Program_Term__c> progTerms = [SELECT Id, Term__c, Term__r.Name FROM Program_Term__c WHERE (Id IN: progTermIds OR Parent_Program_Term__c IN: progTermIds)  AND Ready_For_Billing__c = true];
	    	/*List<Home_Instituition_Term__c> homeTerms = [SELECT Id, Term__c FROM Home_Instituition_Term__c WHERE Home_Institution__r.Name IN: homeInstituitionNames];
            List<Home_Institution__c> homeInstituitions = [SELECT Id, Name FROM Home_Institution__c WHERE Name IN: homeInstituitionNames];
            Map<String, Home_Institution__c> homeInstituitionsMap = new Map<String, Home_Institution__c>();
            for(Home_Institution__c hi : homeInstituitions)
            {
				homeInstituitionsMap.put(hi.Name, hi);
            }                
	    	List<Home_Instituition_Term__c> toInserthomeInstTerm = new List<Home_Instituition_Term__c>();*/
	    	if(!progTerms.isEmpty())
	    	{
		    	for(Program_Term__c pt: progTerms)
		    	{
		    		for(Application__c app: acceptedApps)
		    		{
		    			if(app.Program_Term__c == pt.Id || app.Program_Term__r.Parent_Program_Term__c == pt.Id)
		    			{
		    				appIds.add(app.Id);
							/* This needs commented out for future development for finance but needs to be used still in production. Remove the end comment tag -> 
                            Boolean hasTerm = false;
                            for(Home_Instituition_Term__c hit: homeTerms)
                            {
                                if(hit.Term__c == pt.Term__c)
                                {
                                    hasTerm = true;
                                }
                            }
                            if(hasTerm == false)
                            {
                                Home_Instituition_Term__c newHit = new Home_Instituition_Term__c();
                                newHit.Home_Institution__c = homeInstituitionsMap.get(app.Application_Home_Institution__c).Id;
                                newHit.Term__c = pt.Term__c;
                                newHit.Name = app.Application_Home_Institution__c + ' ' + pt.Term__r.Name;
                                toInserthomeInstTerm.add(newHit);
                            }
                             <- Remove this begin comment tag  */
		    			}
		    		}
		    	}
		    	ifsaLineItemPopulator.populateApplications(appIds);
		    	/* This needs commented out for future development for finance but needs to be used still in production. Remove the end comment tag -> 
		    	if(!toInserthomeInstTerm.isEmpty())
		        {
		         	database.insert(toInserthomeInstTerm);
		        }
		        /* <- Remove this begin comment tag  */		    	
		    }
		    /* <- Remove this begin comment tag */ 
	    }
	}
	/**
	 * Method used to create deposit line items. Currently not used
	 */
	/*
	private static void generateDepositLineItem(List<Application__c> apps)
    {        
        Set<Id> ptIds = new Set<Id>();
        Set<Id> hiIds = new Set<Id>();
        for(Application__c app: apps)
        {
            ptIds.add(app.Program_Term__c);
            hiIds.add(app.Applicant__r.Home_Institution__c);
        }
        Map<String, Approved_Program__c> hiApprovedProgramMap = new Map<String, Approved_Program__c>();
        for(Approved_Program__c approvedProgram: [SELECT Id, Home_Institution__c, Program_Term__c, Pays_Advanced_Deposit__c FROM Approved_Program__c WHERE Home_Institution__c IN: hiIds AND Program_Term__c IN: ptIds])
        {
            hiApprovedProgramMap.put(approvedProgram.Home_Institution__c + ' ' + approvedProgram.Program_Term__c, approvedProgram);
        }
        List<Application_Line_Item__c> linesToInsert = new List<Application_Line_Item__c>();
        Id depositProductId = [SELECT Id FROM Product2 WHERE Name = 'Non-Refundable Deposit'].get(0).Id;
        for(Application__c app: apps)
        {
            try
            {
                Approved_Program__c approvedProgram = hiApprovedProgramMap.get(app.Applicant__r.Home_Institution__c + ' ' + app.Program_Term__c);
                Application_Line_Item__c appLineItem = new Application_Line_Item__c(
                    Product__c = depositProductId,
                    Charge__c = app.Program_Term__r.Program__r.Non_Refundable_Advance_Deposit__c,
                    Name = 'Non-Refundable Advance Deposit',
                    Type__c = 'Charge Account',
                    Application__c = app.Id,
                    Responsible_Party__c = approvedProgram.Pays_Advanced_Deposit__c ? 'School' : 'Student'
                );
                linesToInsert.add(appLineItem);
            }
            catch(Exception e)
            {
                //This student's home institiution does not have an approved program for this program term
            }
        }
        database.insert(linesToInsert);
    }
	*/
	/**
	 * Method to set field defaults of a new application
	 * @param newRecords
	 * @param type Determines in what context this method is running
	 */
	public static void setApplicationDefaults (List<Application__c> newRecords, triggerType type)
	{
		List<Application__c> progSelectedApps = new List<Application__c>();
    	for(Application__c app: newRecords)
    	{
			if(type == triggerType.isBefore)
			{
				app.Status_New__c = DateTime.Now();
				app.Accepted_Alert_Status__c = 'Not Ready';
				app.Completion_Notification_Received__c = false;
				app.Program_Approval_Completed_By__c = null;
				app.Home_Institution_Advisor__c = null;
				app.Last_Application_Update__c = null;
				app.Housing_Assignment__c = null;
				app.Housing_Option__c = null;
				app.Travel_Plan__c = null;
				app.Accepted_With_Conditions__c = false;
				app.Conditions_Met__c = false;
				app.Appreciative_Advising_Call_Completed__c = false;
				app.Status_Ready_To_Submit__c = null;
				app.Status_Submitted__c = null;
				app.Status_Accepted__c = null;
				app.Status_Accepted_With_Conditions__c = null;
				app.Status_On_Site__c = null;
				app.Status_Program_Completed__c = null;
				app.Status_Deferred__c = null;
				app.Status_Diverted__c = null;
				app.Status_Dropped__c = null;
				app.Status_Rejected__c = null;
				app.Status_Withdraw__c = null;
				app.Status_Deceased__c = null;
				app.Printable_Statement__c = app.Designation__c == 'Primary' ? true : false;
			}
			if(app.Status__c == 'New' && app.Program_Term__c != null && type == triggerType.isBefore)
			{
				app.Status__c = 'Program Selected';
				app.Status_Program_Selected__c = DateTime.Now();
			}
			else if(app.Status__c == 'Program Selected' && app.Program_Term__c != null)
			{
				if(type == triggerType.isBefore)
				{
					app.Status_Program_Selected__c = DateTime.Now();
				}
				if(type == triggerType.isAfter)
				{
					progSelectedApps.add(app);
				}
			}
			if(!progSelectedApps.isEmpty())
			{
				createPaWelcomeTask(progSelectedApps);
			}
		}
		
	}
	/**
	 * Creates PA Welcome Task
	 * @param applications
	 */
	public static void createPaWelcomeTask(List<Application__c> applications)
    {
		final String taskName = [SELECT Value__c FROM Apex_String_Constant__mdt WHERE DeveloperName = 'Welcome_Task'].get(0).Value__c;
		final String taskNameOld = [SELECT Value__c FROM Apex_String_Constant__mdt WHERE DeveloperName = 'Welcome_Task_Old'].get(0).Value__c;
		List<Id> contactIds = new List<Id>();
		List<Id> appIds = new List<Id>();
		for(Application__c app: applications)
		{
			appIds.add(app.Id);
			contactIds.add(app.Applicant__c);
		}
		System.debug(appIds);
		System.debug(contactIds);
		Map<Id, Contact> students = new Map<Id, Contact>([SELECT Name, Id, Classes_Required__c, Travel_Concerns__c, Travel_Topics__c FROM Contact WHERE Id IN: contactIds]);
		List<Task> tasks = [SELECT Id, Description, Subject, ActivityDate, WhoId, WhatId FROM Task WHERE (Subject =: taskNameOld OR Subject =: taskName) AND WhoId IN: contactIds AND WhatId IN: appIds];
		for(Application__c application: applications)
		{
			//Create task for PA to review            
			if(application.Designation__c == 'Primary')
			{
				Task welcomeCall = null;
				for(Task t: tasks)
				{
					if(t.WhatId == application.Id && t.WhoId == application.Applicant__c)
					{
						welcomeCall = t;
						break;
					}
				}
				if(welcomeCall == null)
				{
					Id taskRTId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Simple Task').getRecordTypeId();
					welcomeCall = new Task(RecordTypeId = taskRTId, IsVisibleInSelfService = true, WhoId = application.Applicant__c, WhatId = application.Id, Subject = taskName, ActivityDate = Date.today().addDays(2), OwnerId = application.OwnerId, Description = '');
					// The newly created object needs added to the list
					tasks.add(welcomeCall);
				}
				Contact student = students.get(application.Applicant__c);
				welcomeCall.Description = welcomeCall.Description == null ? '' : '\r\n' + welcomeCall.Description;
				if(student.Classes_Required__c == 'Yes')
				{
					welcomeCall.Description += (student.Name + ' requires specific classes to be able to study abroad. \n\n');
				}
				if(!String.isBlank(student.Travel_Concerns__c)){
					welcomeCall.Description += (student.Name + ' has the following concerns about traveling:\n' + student.Travel_Concerns__c +'\n\n');
				}
				if(!String.isBlank(student.Travel_Topics__c)){
					List<String> topics = student.Travel_Topics__c.split(';');
					welcomeCall.Description += (student.Name +' is interested in recieving information on the following topics: \n');
					for(String topic : topics){
						welcomeCall.Description += (topic + '\n');
					}
				}
				// welcomeCall is already pointing to a Task in the tasks list, it was added above
				//tasks.add(welcomeCall);
			}
		}
		if(!tasks.isEmpty())
		{
			System.debug('Insert Welcome Email Tasks');
			
			database.upsert(tasks);
			
			System.debug(tasks[0]);
		}
    }
	/**
	 * Future method to call the createPaWelcomeTask method in a separate context
	 * @param applicationIds
	 **/
	@future
	public static void createPaWelcomeTaskAsync(set<Id> applicationIds)
	{
		List<Application__c> applications = [select Id, OwnerId, Applicant__c from Application__c where Id in :applicationIds];
		if(!applications.isEmpty())
		{
			createPaWelcomeTask(applications);
		}  // End if applications is not empty
	}  // End createPaWelcomeTaskAsync method
	/**
	 * Method to update application name, only uses new records
	 * @param newRecords
	 */
	public static void updateApplicationName(List<Application__c> newRecords)
	{
		Set<Id> ptIds = new Set<Id>();
		Set<Id> poIds = new Set<Id>();
		for(Application__c app: newRecords)
		{
			if(app.Program_Term__c != null)
				ptIds.add(app.Program_Term__c);
			/*if(app.Program_Option__c != null)
				poIds.add(app.Program_Option__c);*/
		}

		Map<Id, Program_Term__c> programTermNames = new Map<Id, Program_Term__c>([SELECT Id, Name FROM Program_Term__c WHERE Id IN: ptIds]);
		//Map<Id, Program_Option__c> programOptionNames = new Map<Id, Program_Option__c>([SELECT Id, Name FROM Program_Option__c WHERE Id IN: poIds]);
		
		for(Application__c app: newRecords)
		{
			Application__c oldApp = new Application__c();
			//app = updateAppName(oldApp, app, programTermNames, programOptionNames);
			app = updateAppName(oldApp, app, programTermNames);
		}
	}
	/**
	 * Method to update application name, uses oldMap and newMap
	 * @param newMap
	 * @param oldMap
	 */
	public static void updateApplicationName(Map<Id, Application__c> newMap, Map<Id, Application__c> oldMap)
	{		
		Set<Id> ptIds = new Set<Id>();
		Set<Id> poIds = new Set<Id>();
		for(Application__c app: newMap.values())
		{
			if(app.Program_Term__c != null)
				ptIds.add(app.Program_Term__c);
			/*if(app.Program_Option__c != null)
				poIds.add(app.Program_Option__c);*/
		}

		Map<Id, Program_Term__c> programTermNames = new Map<Id, Program_Term__c>([SELECT Id, Name FROM Program_Term__c WHERE Id IN: ptIds]);
		//Map<Id, Program_Option__c> programOptionNames = new Map<Id, Program_Option__c>([SELECT Id, Name FROM Program_Option__c WHERE Id IN: poIds]);

		for(Application__c app: newMap.values())
		{
			Application__c currentApp = oldMap != null ? oldMap.get(app.Id) : new Application__c();
			Application__c updatedApp = newMap.get(app.Id);
			//app = updateAppName(currentApp, updatedApp, programTermNames, programOptionNames);
			app = updateAppName(currentApp, updatedApp, programTermNames);
		}
	}

	/**
	 * Method to update application name, called from the two methods above
	 * @param currentApp
	 * @param updatedApp
	 * @param programTermNames
	 */
	private static Application__c updateAppName(Application__c currentApp, Application__c updatedApp, Map<Id, Program_Term__c> programTermNames)
	{
		Boolean updateFromProgramTerm = currentApp.Program_Term__c != updatedApp.Program_Term__c || updatedApp.Program_Term__c == null;
		Boolean updateFromName = updatedApp.Preferred_Name__c != null && !updatedApp.Name.startsWith(updatedApp.Preferred_Name__c + ' ');
		if(updateFromProgramTerm || updateFromName)
		{				
			String appName = '';

			String ptName = updatedApp.Program_Term__c != null ?programTermNames.get(updatedApp.Program_Term__c).Name: '';
			String studentName;
			if(updatedApp.Preferred_Name__c != null){
				studentName = updatedApp.Preferred_Name__c + ' ' + updatedApp.Student_Last_Name__c;
			}
			else {
				studentName = updatedApp.Student_First_Name__C + ' ' + updatedApp.Student_Last_Name__C;
			}
			if(updatedApp.Program_Term__c != null)
			{
				appName = studentName + ' ' + ptName;
			}
			else
			{
				updatedApp.Name = studentName + ' Undecided Application';
			}
			if(appName != '')
			{
				updatedApp.Name = appName.length() > 80 ? appName.substring(0, 79) : appName;
			}
		}
		return updatedApp;
	}
	
	/**
	 * Method to get the SP record of the person who approved the application at th home institution
	 * @param newRecords
	 */
	public static void updateHomeInstitutionAdvisorSP(List<Application__c> newRecords)
	{
		Set<Id> homeAdvisorContactIds = new Set<Id>();
		for(Application__c app: newRecords)
		{
			if(app.Home_Institution_Advisor__c != null)
			{
				homeAdvisorContactIds.add(app.Home_Institution_Advisor__c);
			}
		}
		List<Support_Personnel__c> homeAdvisorSPs = [SELECT Id, Non_IFSA_Staff__c FROM Support_Personnel__c WHERE RecordType.Name = 'Account' AND Non_IFSA_Staff__c IN: homeAdvisorContactIds];
		//Map<Non_IFSA_Staff__c, Id>
		Map<Id, Id> homeAdvisorSPMap = new Map<Id, Id>();
		for(Support_Personnel__c sp: homeAdvisorSPs)
		{
			homeAdvisorSPMap.put(sp.Non_IFSA_Staff__c, sp.Id);
		}
		for(Application__c app: newRecords)
		{
			if(app.Home_Institution_Advisor__c != null)
			{
				app.Home_Institution_Advisor_SP__c = homeAdvisorSPMap.get(app.Home_Institution_Advisor__c);
			}
		}
	}

	/**
	 * Method to set application status timestamps
	 * @param newMap
	 * @param oldMap
	 */
	public static void setStatusTimeStampsUpdate (Map<Id, Application__c> newMap, Map<Id, Application__c> oldMap)
	{
		List<Id> contactIds = new List<Id>();
		List<Id> homeInstitutions = new List<Id>();
		List<Id> programTermIds = new List<Id>();
		for(Application__c app: newMap.values())
		{
			contactIds.add(app.Applicant__c);
			homeInstitutions.add(app.Home_Institution_Account__c);
			programTermIds.add(app.Program_Term__c);
		}
		Map<Id, Program_Term__c> programTerms = new Map<Id, Program_Term__c>([SELECT Id, Owner.Email, Program__c, Program__r.Create_IFSA_Butler_NET_Email__c FROM Program_Term__c WHERE Id IN: programTermIds]);
		Map<Id, Contact> contacts = New Map<Id, Contact>([SELECT Id, Active_Application__c, IFSA_Butler_NET_Email__c, Transcript_Recipient__c, Home_Institution__r.Account__c, AccountId, Traveling_Status__c FROM Contact WHERE Id IN: contactIds OR (Transcript_Recipient__c = TRUE AND AccountId IN: homeInstitutions)]);
		Map<Id, Contact> homeInstitutionTranscriptContactsMap = new Map<Id, Contact>();
		for(Contact c: contacts.values())
		{
			if(c.Transcript_Recipient__c)
			{
				homeInstitutionTranscriptContactsMap.put(c.AccountId, c);
			}
		}
		List<Task> readyToSubmitTasks = new List<Task>();
		for(Application__c app: newMap.values())
		{
			// Spiceworks Ticket #6546 - Sets lookup to Home Institution Account
            app.Home_Institution_Account__c = contacts.get(app.Applicant__c).Home_Institution__r.Account__c;
			// Set the application's account lookup to match that of the applicant's account to deactivate Process Builder "Populate Account on Application" which was causing test failures
			app.Account__c = contacts.get(app.Applicant__c).AccountId;
            if(!app.Override_Transcript_Recipient__c && (app.Status__c == 'On Site' || app.Status__c == 'Program Completed'))
	        {
                if(homeInstitutionTranscriptContactsMap.containsKey(app.Home_Institution_Account__c ))
				{
					newMap.get(app.Id).Transcript_Recipient__c = homeInstitutionTranscriptContactsMap.get(app.Home_Institution_Account__c).Id;
				}
	        }
			if(app.Status_Contract_Signed__c != null && oldMap.get(app.Id).Status_Contract_Signed__c == null)
			{
				app.Designation__c = 'Primary';
			}
		}
		setStatusTimeStampsNew(newMap.values(), contacts, programTerms);
	}
	/**
	 * Sets the status time stamps on Application when the application status changes
	 * @param newRecords List<Application__c>
	 * @param contacts Map<Id, Contact>
	 * @param programTerms Map<Id, Program_Term__c>
	 */
	public static void setStatusTimeStampsNew(List<Application__c> newRecords, Map<Id, Contact> contacts, Map<Id, Program_Term__c> programTerms)
	{
		Boolean runProxyEmailService = Test.isRunningTest() ? true : ![SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
		List<Id> contactIds = new List<Id>();
		List<Id> programTermIds = new List<Id>();
		for(Application__c app: newRecords)
		{
			contactIds.add(app.Applicant__c);
			programTermIds.add(app.Program_Term__c);
		}
		if(contacts == null)
		{
			contacts = New Map<Id, Contact>([SELECT Id, Active_Application__c, IFSA_Butler_NET_Email__c, Transcript_Recipient__c, Home_Institution__r.Account__c, AccountId, Traveling_Status__c FROM Contact WHERE Id IN: contactIds]);
		}
		if(programTerms == null)
		{
			programTerms = new Map<Id, Program_Term__c>([SELECT Id, Owner.Email, Program__c, Program__r.Create_IFSA_Butler_NET_Email__c FROM Program_Term__c WHERE Id IN: programTermIds]);
		}

		Map<Id, Contact> affectedContacts = new Map<Id, Contact>();
		List<Task> readyToSubmitTasks = new List<Task>();
		for(Application__c app: newRecords)
		{
			// SW-9670 - Set Home Institution Lookup on Insert
			app.Home_Institution_Account__c = contacts.get(app.Applicant__c).Home_Institution__r.Account__c;            
			//Status == Accepted
			if(app.Status__c == 'Accepted' && app.Status_Accepted__c == null)
			{
				app.Status_Accepted__c = DateTime.Now();            
				app.Accepted_Alert_Status__c = 'Ready';		            
			}
			//Status == Accepted (with Conditions)
			else if(app.Status__c == 'Accepted (with Conditions)' && app.Status_Accepted_with_Conditions__c == null)
			{
				app.Status_Accepted_with_Conditions__c = DateTime.Now();
				app.Accepted_With_Conditions__c = true;
				app.Conditions_Met__c = false;
				app.Accepted_Alert_Status__c = 'Ready';
			}
			//Status == Deferred
			else if(app.Status__c == 'Deferred' && app.Status_Deferred__c == null)
			{
				app.Status_Deferred__c = DateTime.Now();
				Contact c = contacts.get(app.Applicant__c);
				if(c.Active_Application__c == app.Id)
				{
					c.Active_Application__c = null;
				}
				affectedContacts.put(c.Id, c);
				contacts.put(c.Id, c);
			}
			//Status == Diverted
			else if(app.Status__c == 'Diverted' && app.Status_Diverted__c == null)
			{
				app.Status_Diverted__c = DateTime.Now();
				app.Designation__c = null;
				Contact c = contacts.get(app.Applicant__c);
				if(c.Active_Application__c == app.Id)
				{
					c.Active_Application__c = null;
				}
				affectedContacts.put(c.Id, c);
				contacts.put(c.Id, c);
			}
			//Status == Dropped
			else if(app.Status__c == 'Dropped' && app.Status_Dropped__c == null)
			{
				app.Status_Dropped__c = DateTime.Now();
			}
			//Status == On Site
			else if((app.Status__c == 'On Site' || app.Resident_Staff_Checked_In__c ) && app.Status_On_Site__c == null)
			{
				app.Status_On_Site__c = DateTime.Now();
				app.Status__c = 'On Site';
				Contact c = contacts.get(app.Applicant__c);
				c.Traveling_Status__c = app.Final_Arrival__c < DateTime.now() ? 'Not Traveling' : c.Traveling_Status__c;
				c.On_Site_Application__c = app.Id;
				affectedContacts.put(c.Id, c);
				contacts.put(c.Id, c);		            
			}
			//Status == Program Completed
			else if(app.Status__c == 'Program Completed' && app.Status_Program_Completed__c == null)
			{
				app.Status_Program_Completed__c = DateTime.Now();
				scheduledContactTravelingUpdate.updateEmailAddresses(new List<Id>{app.Applicant__c});
			}		        
			//Status == Program Selected
			else if(app.Status__c == 'Program Selected' && trigger.isInsert)
			{
				app.Status_Program_Selected__c = DateTime.Now();
				app.Accepted_Alert_Status__c = 'Not Ready';
				app.Completion_Notification_Received__c = false;
				Program_Term__c pt = programTerms.get(app.Program_Term__c);
				Contact c = contacts.get(app.Applicant__c);
				if(pt.Program__r.Create_IFSA_Butler_NET_Email__c && app.Designation__c == 'Primary')
				{
					try
					{
						if(c.IFSA_Butler_NET_Email__c == null && runProxyEmailService)
						{
							contactService.createIFSAButlerNETEmail(app.Student_First_Name__c, app.Student_Last_Name__c, pt.Owner.Email, String.valueOf(app.Applicant__c));
						}
						else
						{
							contactService.updateIFSAButlerNETEmail(c.IFSA_Butler_NET_Email__c, pt.Owner.Email, String.valueOf(app.Applicant__c));
						}
						c.Updating_IFSA_Butler_NET_Email__c = true;
						affectedContacts.put(c.Id, c);
						contacts.put(c.Id, c);
					}						
					catch(AsyncException e)
					{
						System.debug('Tried to run future method from batch or future method');
					}
				}
			}
			else if(app.Status__c == 'Program Selected' && app.Status_Ready_To_Submit__c != null)
			{
				app.Accepted_Alert_Status__c = 'Not Ready';
				app.Completion_Notification_Received__c = false;
			}
			//Status == Ready To Submit
			else if(app.Status__c == 'Ready To Submit' && app.Status_Ready_To_Submit__c == null)
			{
				app.Status_Ready_To_Submit__c = DateTime.Now();
				app.Accepted_Alert_Status__c = 'Not Ready';
				readyToSubmitTasks.add(new Task(
					Priority = 'Normal',
					Status = 'Not Started',
					ActivityDate = Date.today().addDays(3),
					OwnerId = app.OwnerId,
					Subject = 'Review Application for Submission',
					WhatId = app.Id,
					WhoId = app.Applicant__c
				));
			}
			//Status == Registered
			else if(app.Status__c == 'Registered' && app.Status_Registered__c == null)
			{
				app.Status_Registered__c = DateTime.Now();
				app.Accepted_Alert_Status__c = 'Not Ready';		            
			}
			//Status == Rejected
			else if(app.Status__c == 'Rejected' && app.Status_Rejected__c == null)
			{
				app.Status_Rejected__c = DateTime.Now();
				app.Accepted_Alert_Status__c = 'Not Ready';
			}
			//Status == Submitted
			else if(app.Status__c == 'Submitted' && app.Status_Submitted__c == null)
			{
				app.Status_Submitted__c = DateTime.Now();
				app.Accepted_Alert_Status__c = 'Not Ready';
			}
			//Status == Withdraw
			else if(app.Status__c == 'Withdraw' && app.Status_Withdraw__c == null)
			{
				app.Status_Withdraw__c = DateTime.Now();
			}
			//Status == Unqualified
			else if(app.Status__c == 'Unqualified' && app.Status_Unqualified__c == null)
			{
				app.Status_Unqualified__c = DateTime.Now();
			}
			//Status == Deceased
			else if(app.Status__c == 'Deceased' && app.Status_Deceased__c == null)
			{
				app.Status_Deceased__c = DateTime.Now();        	
			}
			else if(app.Status__c == 'Waitlisted' && app.Status_Waitlisted__c == null)
			{
				app.Status_Waitlisted__c = DateTime.Now();
				app.Waitlisted_Message__c = 'Your application has been reviewed by the host university.  There were a number of strong applications this cycle and ' + app.Program_Term_Program__c + ' has placed you on a waiting list. I will be in touch if your position on the waiting list changes.  If you have any questions or concerns, don\'t hesitate to reach out!';
			}
		}
		if(!affectedContacts.isEmpty())
		{
			database.update(affectedContacts.values());
		}
		if(!readyToSubmitTasks.isEmpty())
		{
			database.insert(readyToSubmitTasks);
		}
	}
	/**
	 * Method used to verifiy Contact Support Personnel, called from trigger handler
	 * @param newRecords
	 * @param oldMap
	 * @param newMap
	 * @param type Determines in what context this method is running
	 */
	public static void verifyContactSupportPersonnelRecords(List<Application__c> newRecords, Map<Id, Application__c> oldMap, Map<Id, Application__c> newMap, triggerType type)
	{
		/*
		List<Contact_Support_Personnel__c> cspRecordsToAdd = new List<Contact_Support_Personnel__c>();		
		String strType = '';

		if(type == triggerType.isInsert) 			
			strType = 'isInsert';
		else if(type == triggerType.isUpdate)
			strType = 'isUpdate';

		cspRecordsToAdd.addAll(applicaitonCSPGeneration(oldmap, newMap));

		if(!cspRecordsToAdd.isEmpty())
		{
			updateCSP(strType, cspRecordsToAdd);
		}
		*/
		if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs() - 1){
   			ID jobID = system.enqueueJob(new contactSupportPersonnelService(newMap, oldMap));
		}
	}

	/**
	 * Method used with validating printable statement.  CASE - FFAccounting consultant
	 * @param newRecords
	 * @param oldMap
	 * @param type Determines in what context this method is running
	 */
	public static void validatePrintibleSatement(List<Application__c> newRecords, Map<Id, Application__c> oldMap, triggerType type)
{
    //If designation changed to "Primary", then set Printible Statement to true
    if(type == triggerType.isUpdate) 
    {
        for (Application__c a : newRecords) 
        {
            if (a.Designation__c != oldMap.get(a.Id).Designation__c)  
            {
                a.Printable_Statement__c = a.Designation__c == 'Primary' ? true : false;
            }
        }
    }
    
    //Taken from FFPartial ValidatePrintibleStatment Trigger
    //Modified for applicationService by Brock Barlow 3-14-2017
    
    Set<Id> accId = new Set<Id>();
    List<Application__c> apps = new List<Application__c>();
    List<Account> listAcc = new List<Account>();
    // Map<Id,Application__c> mapCon=new Map<Id,Application__c>();
    Set<String> appIds = new Set<String>();

    for(Application__c app : newRecords) 
    {
        if(app.Printable_Statement__c) 
        {
            if( accId.contains(app.Account__c) ) 
            {
                app.Printable_Statement__c = false;
            }
            else if(trigger.isUpdate) 
            {
                appIds.add(app.Id);    
            }
            accId.add(app.Account__c);
        }            
    }
        
    if(!accId.isEmpty() && Limits.getLimitQueueableJobs() > 2)
    {    
        apps = [SELECT id,Printable_Statement__c FROM Application__c WHERE Account__r.id IN: accId AND Id not IN: appIds AND Printable_Statement__c = TRUE];
        for(Application__c con: apps)
        {
            if(con.Printable_Statement__c)
            {
                con.Printable_Statement__c = false;   
            }
        }
		System.enqueueJob(new sObjectQueueableUpdater(apps, sObjectQueueableUpdater.dmlOperation.isUpdate));
    }
}

	/**
	 * Method used to divert other applications when a student signs a contract for one.
	 * @param newMap
	 * @param oldMap
	 */
	public static void divertOtherApps(Map<Id,Application__c> newMap, Map<Id,Application__c> oldMap){
		//Set<Id> appIdList = new Set<Id>();
		Map<Id, String> appIdList = new Map<Id,String>();
		Map<Id, String> appDropMap = new Map<Id,String>();
		List<Application__c> appList = new List<Application__c>();
		List<Application__c> updateApps = new List<Application__c>();

		for(Application__c app : newMap.values())
		{
			if(app.Status_Contract_Signed__c != null && oldMap.get(app.Id).Status_Contract_Signed__c != app.Status_Contract_Signed__c && (app.Status__c == 'Accepted' || app.Status__c == 'Accepted (with Conditions)') )
			{
				appIdList.put(app.Applicant__c, ''+ app.Program_Term_Section__c + ' ' + app.Program_Term_Year__c);
			} else if(app.Status__c == 'Dropped' && oldMap.get(app.Id).Status__c != 'Dropped' && app.Designation__c == 'Primary') {
				appDropMap.put(app.Applicant__c, ''+ app.Program_Term_Section__c + ' ' + app.Program_Term_Year__c);
			}
		}
		//added null check
		if(!appIdList.values().isEmpty() || !appDropMap.values().isEmpty())
		{
			appList = [SELECT Id, Name, Status__c, Applicant__c, Program_Term_Section__c, Program_Term_Year__c, OwnerId FROM Application__c 
						WHERE (Applicant__c IN :appIdList.keySet() 
						OR Applicant__c IN :appDropMap.keySet())
						AND Status__c IN ('New', 'Registered', 'Program Selected', 'Ready To Submit', 'Submitted', 'Accepted', 'Accepted (with Conditions)') 
						AND (Program_Term__r.Term__r.Name IN :appIdList.values()
						OR Program_Term__r.Term__r.Name IN :appDropMap.values())
						AND Id NOT IN: newMap.keyset()];
			System.debug('appList: ' + appList);

			List<Task> newTasks = new List<Task>();
			for(Application__c app : appList)
			{
				if(!newMap.containsKey(app.Id) && appIdList.get(app.Applicant__c) == (''+ app.Program_Term_Section__c + ' ' + app.Program_Term_Year__c)){
					app.Status__c = 'Diverted';
					app.Status_Reason_Explianation__c = 'Student accepted offer on other IFSA application';
					app.Designation__c = null;
					updateApps.add(app);
					Task t = new Task(OwnerId = app.OwnerId, Subject = 'Student Committed to Another Application', WhatId = app.Id, WhoId = app.Applicant__c);
					t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Simple Task').getRecordTypeId();
					newTasks.add(t);
				} else if (!newMap.containsKey(app.Id) && appDropMap.get(app.Applicant__c) == (''+ app.Program_Term_Section__c + ' ' + app.Program_Term_Year__c)) {
					app.Status__c = 'Diverted';
					app.Status_Reason_Explianation__c = 'Student\'s primary application was dropped';
					app.Designation__c = null;
					updateApps.add(app);
					Task t = new Task(OwnerId = app.OwnerId, Subject = 'Student\'s primary application was dropped', WhatId = app.Id, WhoId = app.Applicant__c);
					t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Simple Task').getRecordTypeId();
					newTasks.add(t);
				}
			}

			if(!updateApps.isEmpty())
			{
				update updateApps;
			}
			if(!newTasks.isEmpty())
			{
				database.insert(newTasks);
			}
		}
	}
	/**
	 * Checks student's home institution to see if the school approves the student's selected program.
	 * If the program is not on the schools approved list, then a task is genereated for the Application__c record's owner (Program Advisor)
	 * @param newRecords
	 */
	public static void checkProgramAuthorizations(List<Application__c> newRecords)
	{
		Set<Id> contactIds = new Set<Id>();
		Set<Id> programTermIds = new Set<Id>();
		for(Application__c app: newRecords)
		{
			contactIds.add(app.Applicant__c);
			programTermIds.add(app.Program_Term__c);
		}
		List<Task> notAuthorizedTasks = new List<Task>();
		Map<Id, Contact> studentContacts = new Map<Id, Contact>([SELECT Id, Name, Home_Institution__r.Account__c FROM Contact WHERE Id IN: contactIds]);
		Map<Id, Program_Term__c> programTerms = new Map<Id, Program_Term__c>([SELECT Id, OwnerId, Program__c, Term__r.Section__c FROM Program_Term__c WHERE Id IN: programTermIds]);
		for(Application__c app: newRecords)
		{
			if(app.Program_Term__c != null)
			{
				Boolean programAuthorized = false;
				if(studentContacts.get(app.Applicant__c).Home_Institution__r.Account__c != null)
				{
					List<Program_Authorization__c> pAuths = [SELECT Id, Term__c FROM Program_Authorization__c WHERE Account__c =: studentContacts.get(app.Applicant__c).Home_Institution__r.Account__c AND Program__c =: programTerms.get(app.Program_Term__c).Program__c AND Is_Active__c = TRUE];
					if(pAuths.isEmpty())
					{
						programAuthorized = true;
					}
					for(Program_Authorization__c pAuth: pAuths)
					{
						if(pAuth.Term__c != null && pAuth.Term__c.contains(programTerms.get(app.Program_Term__c).Term__r.Section__c))
						{
							programAuthorized = true;
						}
					}
				}
				if(!programAuthorized)
				{
					Task notAuthorizedTask = new Task(OwnerID = programTerms.get(app.Program_Term__c).OwnerId);
					notAuthorizedTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Simple Task').getRecordTypeId();
					notAuthorizedTask.Subject = 'Home Institution has not authorized this program';
					notAuthorizedTask.Description = studentContacts.get(app.Applicant__c).Name + ' has selected a program that their home instituion has not authorized.';
					notAuthorizedTask.WhatId = app.Id;
					notAuthorizedTask.WhoId = studentContacts.get(app.Applicant__c).Id;

					notAuthorizedTasks.add(notAuthorizedTask);
				}
			}
		}
		Database.insert(notAuthorizedTasks);
	}
	/**
	 * This method marks "Is_Approved__c" on Course_Registration__c records related to an applications where a related Class_Registration_Form_Submission__r record has been marked approved.
	 * @param newMap
	 */
	public static void approveCourseRegistrations(Map<Id, Application__c> newMap)
	{
		
		List<Course_Registration__c> regs = new List<Course_Registration__c>(); 
		for(Course_Registration__c reg: [SELECT Id, Class_Registration_Form_Submission__r.CRF_Status__c FROM Course_Registration__c WHERE Status__c = 'Approval Pending' AND Application__c IN: newMap.keySet()])
		{
			if(reg.Class_Registration_Form_Submission__r.CRF_Status__c == 'Approved')
			{
				reg.Is_Approved__c = true;
				regs.add(reg);
			}
		}

		database.update(regs);
	}
	/**
	 * Determines if the parameter string matches an active application status
	 * @param status The string to test
	 */
	public static Boolean isActiveApplication(String status)
	{
		if(status == 'Program Selected' || status.contains('Submit') || status.contains('Accepted') || status == 'On Site' || status == 'Program Completed' || status == 'Waitlisted')
		{
			return true;
		}
		return false;
	}
	/**
	 * Sends the CRF Approved Email when Courseload_Approval__c has changed from false to true
	 * @param oldMap
	 * @param newMap
	 */
	public static void sendCRFApprovalEmail(Map<Id, Application__c> oldMap, Map<Id, Application__c> newMap)
	{
		List<Id> contactIds = new List<Id>();
		for(Id appId: newMap.keySet())
		{
			Application__c oldApp = oldMap.get(appId);
			Application__c newApp = newMap.get(appId);

			if(!oldApp.Courseload_Approval__c && newApp.Courseload_Approval__c)
			{
				contactIds.add(newApp.Applicant__c);
			}
		}

		if(!contactIds.isEmpty())
		{
			Id orgWideEmailAddressId = [SELECT Id FROM orgWideEmailAddress WHERE DisplayName = 'IFSA-Butler No-Reply'].get(0).Id;
			Id templateId = [SELECT Id FROM EmailTemplate WHERE Name = 'CRF Approved Email'].get(0).Id;
			List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
			for(Id contactId: contactIds)
			{
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				email.setTargetObjectId(contactId);
				email.setTemplateId(templateId);
				email.setOrgWideEmailAddressId(orgWideEmailAddressId);
				emails.add(email);
			}

			Messaging.sendEmail(emails);
		}
	}

	/**
	 * Creates application item records for an application
	 * @param oldMap
	 * @param newRecords
	 */
	public static void populateApplicationItems(Map<Id, Application__c> oldMap, List<Application__c> newRecords)
	{
		List<Application__c> appsToUpdate = new List<Application__c>();
		for(Application__c app: newRecords)
		{
			// bugfix - 03/17/2022 - powerfluence - application items not generated - 001 -- start
			// existing code commented as part of the bugfix - 03/17/2022 - powerfluence - application items not generated - 001 -- start
			//  if((oldMap == null || oldMap.get(app.Id).Program_Term__c == null) && app.Program_Term__c != null)
			//  { 
			// existing code commented as part of the bugfix - 03/17/2022 - powerfluence - application items not generated - 001 -- end
			if(
				(
					(
						(oldMap == null || oldMap.get(app.Id).Program_Term__c == null) && app.Program_Term__c != null
					) 
					||
					(
						(oldMap == null || oldMap.get(app.Id).Program_Term__c != null) && applicationItemsCount(app.Id) == 0
					)	
				)
				&& !applicationTriggerContextUtility.isRequestedPopulateApplicationItems()
			)
			{
			// bugfix - 03/17/2022 - powerfluence - application items not generated - 001 -- end
			applicationTriggerContextUtility.setRequestedPopulateApplicationItems(true);
				appsToUpdate.add(app);
			}
			// added - powerfluence - application items not generated - 003 - starts
			// bugfix - powerfluence - application items not generated - 001 -- start
			// if((oldMap == null || oldMap.get(app.Id).Program_Term__c != null) && app.Application_Items__r.size() == 0 && !applicationTriggerContextUtility.isRequestedPopulateApplicationItems())
			if((oldMap == null || oldMap.get(app.Id).Program_Term__c != null) && applicationItemsCount(app.Id) == 0 && !applicationTriggerContextUtility.isRequestedPopulateApplicationItems())
			{
				// bugfix - powerfluence - application items not generated - 001 -- end
				// existing code commented as part of the bugfix - 03/17/2022 - powerfluence - application items not generated - 002 -- start
				// applicationTriggerContextUtility.setRequestedPopulateApplicationItems(true);
				// appsToUpdate.add(app);
				// existing code commented as part of the bugfix - 03/17/2022 - powerfluence - application items not generated - 002 -- end
			}
			// added - powerfluence - application items not generated - 003 - ends
		}
		if(!appsToUpdate.isEmpty())
		{
			ifsaApplicationWrapper.populateApplicationItems(appsToUpdate);
		}
	}

	public static Integer applicationItemsCount(Id appId)
	{
		Map<Id, Application_Item__c> appItemMap = new Map<Id, Application_Item__c>([SELECT Id
																					FROM Application_Item__c WHERE Application__c =: appId]);

		Integer resultreturn = appItemMap.keyset().Size();
		return resultreturn;
	}
}