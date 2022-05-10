/**
 * @description Service class for Program_Authorization__c
 * @author Brock Barlow
 */
public without sharing class programAuthorizationService
{
	/**
	 * @description Before Insert Method - Ensures that only one record is active for an account/program combination
	 * @param List<Program_Authorization__c> newRecords - records being inserted
	*/
	public static void beforeInsertProgramAuthorizations(List<Program_Authorization__c> newRecords)
	{
		if(programAuthorizationTriggerHandler.newProgramAuthorizations.isEmpty())
		{
			// Look for existing records with the account and program
			Set<Id> accountIds = new Set<Id>();
			Set<Id> programIds = new Set<Id>();

			Map<String, Program_Authorization__c> existingRecordsMap = new Map<String, Program_Authorization__c>();
			for(Program_Authorization__c newRecord: newRecords)
			{
				accountIds.add(newRecord.Account__c);
				programIds.add(newRecord.Program__c);
			}

		//	Commented  by  Power Fluence - Vinod Date - 2/17/2022 starts 
			/*for(Program_Authorization__c existingRecord: [SELECT Id, Account__c, Program__c FROM Program_Authorization__c WHERE Account__c IN: accountIds AND Program__c IN: programIds AND Is_Active__c = TRUE  ])*/
		//	Commented  by  Power Fluence - Vinod Date - 2/17/2022 ends


			//	Modified  by  Power Fluence - Vinod Date - 2/17/2022 starts
			for(Program_Authorization__c existingRecord: [SELECT Id, Account__c, Program__c FROM Program_Authorization__c WHERE Account__c IN: accountIds AND Program__c IN: programIds AND Is_Active__c = TRUE Order By CreatedDate DESC Limit 1 ])
			{
				//	Modified  by  Power Fluence - Vinod Date - 2/17/2022 ends

				String key = String.format('{0}{1}', new List<Object>{existingRecord.Account__c, existingRecord.Program__c});
				existingRecordsMap.put(key, existingRecord);
			}
			if(!existingRecordsMap.isEmpty())
			{
				for(Program_Authorization__c newRecord: newRecords)
				{
					String key = String.format('{0}{1}', new List<Object>{newRecord.Account__c, newRecord.Program__c});
					System.debug('Previous PA: ' + newRecord.Previous__c);
					Boolean hasRecord = false;
					Program_Authorization__c existingRecord = existingRecordsMap.get(key);
                    System.debug('EX: ' + existingRecord);
                    System.debug('New: ' + newRecord);
					if(existingRecord != null && programAuthorizationTriggerHandler.newProgramAuthorizations.containsKey(existingRecord.Id) == false && existingRecord.Account__c == newRecord.Account__c && existingRecord.Program__c == newRecord.Program__c)
					{
						hasRecord = true;
						break;
					}
					
					if(hasRecord)
					{
						/*
						 Apex / SOQL best practices state that you should not have DML inside a loop, but if this code is run
						 an exception is about to be thrown and it will not matter because execution is about to end anyway.
						*/
						String acctName = [SELECT Name FROM Account WHERE Id =: newRecord.Account__c].get(0).Name;
						String prgName = [SELECT Name FROM Program__c WHERE Id =: newRecord.Program__c].get(0).Name;
						throw new programAuthorizationServiceException('A Program Authorization Record already exists for Account: ' + acctName + ' and Program: ' + prgName + '. Existing Record Id: ' + existingRecord.Id);	
					}
				}
			}
		}
	}
	
	/**
	 * @description Before Update Method
	 * @param Map<Id, Program_Authorization__c> newMap - updated record
	 * @param Map<Id, Program_Authorization__c> oldMap - record before update
	*/
	public static void updateProgramAuthorizationsBefore(Map<Id, Program_Authorization__c> newMap, Map<Id, Program_Authorization__c> oldMap)
	{
		Map<Id, Program_Authorization__c> newPAs = new  Map<Id, Program_Authorization__c>();
		List<Id> previousVersionIds = new List<Id>();
		for(Program_Authorization__c newRecord: newMap.values())
		{
			if(newRecord.Term__c == null)
			{
				newRecord.Term__c = 'Not Approved';
			}
			if(newRecord.Previous__c != null)
			{
				previousVersionIds.add(newRecord.Previous__c);
			}
		}
		Map<Id, Program_Authorization__c> previousVersion = new Map<Id, Program_Authorization__c>([SELECT Id, Term__c FROM Program_Authorization__c WHERE Id IN: previousVersionIds Order By CreatedDate DESC Limit 1 ]);
		for(Program_Authorization__c updatedRecord: newMap.values())
		{
			Id recordId = updatedRecord.Id;
			Program_Authorization__c oldRecord = oldMap.get(recordId);
			// modified by power fluence - req no.7 & 8 - 001 starts here
			// if((updatedRecord.Term__c != oldRecord.Term__c || updatedRecord.Show_Unauthorized_Program_In_CHART__c != oldRecord.Show_Unauthorized_Program_In_CHART__c ) && updatedRecord.CreatedDate.date() != Date.today())
			if((updatedRecord.Term__c != oldRecord.Term__c || updatedRecord.Show_Unauthorized_Program_In_CHART__c != oldRecord.Show_Unauthorized_Program_In_CHART__c ) ) 
			// removed the condition && updatedRecord.CreatedDate.date() != Date.today() as per the requirements all the updation to be tracked
			// the program control will never pass to the else if condition as the above modification removed the today's updation condition
			// modified by power fluence - req no.7 & 8 - 001 ends here
			{
				Program_Authorization__c newPA = new Program_Authorization__c();
				apexSectionDifference difference = new apexSectionDifference(updatedRecord.Term__c, oldRecord.Term__c);
				newPA.Account__c = updatedRecord.Account__c;
				newPA.Program__c = updatedRecord.Program__c;
				newPA.Term__c = updatedRecord.Term__c;
				newPA.Show_Unauthorized_Program_In_CHART__c = newPA.Term__c == 'Not Approved' && updatedRecord.Show_Unauthorized_Program_In_CHART__c;
				newPA.Added_Sections__c = difference.addedSections();
				newPA.Removed_Sections__c = difference.removedSections();
				newPA.Previous__c = null;
				//newPA.Previous__c = updatedRecord.Id;
				newPAs.put(recordId, newPA);
				System.debug(newPA.Term__c);
				updatedRecord.Term__c = oldRecord.Term__c;
				updatedRecord.Show_Unauthorized_Program_In_CHART__c = oldRecord.Show_Unauthorized_Program_In_CHART__c;
			}
			else if(updatedRecord.Term__c != oldRecord.Term__c && updatedRecord.CreatedDate.date() == Date.today() && updatedRecord.Previous__c != null)
			{
				apexSectionDifference difference = new apexSectionDifference(updatedRecord.Term__c, previousVersion.get(updatedRecord.Previous__c).Term__c);

				if(difference.hasNoDifference())
				{
					programAuthorizationTriggerHandler.recordsToDelete.add(updatedRecord);
				}				
			}
		}
		programAuthorizationTriggerHandler.newProgramAuthorizations = newPAs;
	}
	/**
	 * @description Before Update Method
	 * @param Map<Id, Program_Authorization__c> newMap - updated record
	 * @param Map<Id, Program_Authorization__c> oldMap - record before update
	 * @param Map<Id, Program_Authorization__c> newPAs - from TriggerHandler, if new records are created in this method then they will be passed back to the trigger handler
	*/
	public static void updateProgramAuthorizationsAfter(Map<Id, Program_Authorization__c> newMap, Map<Id, Program_Authorization__c> oldMap, Map<Id, Program_Authorization__c> newPAs)
	{
		database.insert(newPAs.values());
		List<Program_Authorization__c> PAsToUpdate = new List<Program_Authorization__c>();
		for(Id oldPaId: newPAs.keySet())
		{
			System.debug(newPAs.get(oldPaId).Id);
			PAsToUpdate.add(new Program_Authorization__c(Id = oldPaId, Next__c = newPAs.get(oldPaId).Id));
			newPAs.get(oldPaId).Previous__c = oldPaId;
			PAsToUpdate.add(newPAs.get(oldPaId));
			newPAs.remove(oldPaId);
		}

		//system.enqueueJob(new sObjectQueueableUpdater(PAsToUpdate, sObjectQueueableUpdater.dmlOperation.isUpdate, 200));		
		database.update(PAsToUpdate);
	}

	// Updates Accounts to ensure that Approves_All_*_Programs__c checkboxes are not checked if a home institution account does not approve all
	// catalog summer programs or does not approve all catalog semester/year programs
	public static void updateAccountApproved(Map<Id, Program_Authorization__c> newMap)
	{
		// Get all future program terms for the updated programs authorization's programs
		List<Id> programIds = new List<Id>();
		Set<Id> accountIds = new Set<Id>();
		for(Program_Authorization__c pAuth: newMap.values())
		{
			programIds.add(pAuth.Program__c);
			accountIds.add(pAuth.Account__c);
		}
		Map<Id, Program__c> activePrograms = new Map<Id, Program__c>([SELECT Id, Name, Has_Academic_Year_Program_Terms__c, Has_Calendar_Year_Program_Terms__c, Has_Fall_Program_Terms__c, Has_Spring_Program_Terms__c, Has_Summer_Program_Terms__c, Has_Winter_Program_Terms__c FROM Program__c WHERE Category__c = 'Catalog' AND Active__c = TRUE AND Name != 'Undecided']);
		// Holding var for account records to update
		Map<Id, Account> accts = new Map<Id, Account>([SELECT Id, Approves_All_Summer_Programs__c, Approves_All_Calendar_Programs__c, Approves_All_Winter_Programs__c FROM Account WHERE Id IN: accountIds AND Updating_Program_Authorizations__c = FALSE]);
		// Iterate over the updated records
		system.debug(newMap.values());
		for (Program_Authorization__c newRecord: newMap.values()) 
		{
			Account currentAcct = accts.get(newRecord.Account__c);
			Boolean accountUpdated = false;
			if(activePrograms.containsKey(newRecord.Program__c) && newRecord.Is_Active__c && currentAcct != null && (currentAcct.Approves_All_Calendar_Programs__c || currentAcct.Approves_All_Summer_Programs__c || currentAcct.Approves_All_Winter_Programs__c))
			{
				Program__c p = activePrograms.get(newRecord.Program__c);
				// Determine if section is not authorized
				if(newRecord.Term__c != null)
				{
					// If the program has a summer section but it is not authorized ensure that "Approves_All_Summer_Programs__c" = false
					if(p.Has_Summer_Program_Terms__c && !newRecord.Term__c.contains('Summer') && currentAcct.Approves_All_Summer_Programs__c)
					{
						currentAcct.Approves_All_Summer_Programs__c = false;
						accountUpdated = true;
						System.debug(p.Name + ' - Summer');
					}
					if(p.Has_Winter_Program_Terms__c && !newRecord.Term__c.contains('Winter') && currentAcct.Approves_All_Winter_Programs__c)
					{
						currentAcct.Approves_All_Winter_Programs__c = false;
						accountUpdated = true;
						System.debug(p.Name + ' - Winter');
					}
					if(p.Has_Spring_Program_Terms__c && !newRecord.Term__c.contains('Spring') && currentAcct.Approves_All_Calendar_Programs__c)
					{
						currentAcct.Approves_All_Calendar_Programs__c = false;
						accountUpdated = true;
						System.debug(p.Name + ' - Spring');
					}
					if(p.Has_Fall_Program_Terms__c && !newRecord.Term__c.contains('Fall') && currentAcct.Approves_All_Calendar_Programs__c)
					{
						currentAcct.Approves_All_Calendar_Programs__c = false;
						accountUpdated = true;
						System.debug(p.Name + ' - Fall');
					}
					if(p.Has_Academic_Year_Program_Terms__c && !newRecord.Term__c.contains('Academic Year') && currentAcct.Approves_All_Calendar_Programs__c)
					{
						currentAcct.Approves_All_Calendar_Programs__c = false;
						accountUpdated = true;
						System.debug(p.Name + ' - Academic Year');
					}
					if(p.Has_Calendar_Year_Program_Terms__c && !newRecord.Term__c.contains('Calendar Year') && currentAcct.Approves_All_Calendar_Programs__c)
					{
						currentAcct.Approves_All_Calendar_Programs__c = false;
						accountUpdated = true;
						System.debug(p.Name + ' - Calendar Year');
					}
				}
			}
			if(accountUpdated)
			{
				accts.put(newRecord.Account__c, currentAcct);
			}
		}
		if(!accts.isEmpty()) 
		{
			//BaseTriggerHandler.bypass('accountTriggerHandler');
			database.update(accts.values());
			//BaseTriggerHandler.clearBypass('accountTriggerHandler');
		}		
	}

	// Creates a notification task for FD's when a home institution advisor updates Program_Authorization__c
	public static void createProgramAuthorizationUpdatedTask (List<Program_Authorization__c> newRecords)
	{
		// Get the current user (Id, ContactId, ProfileId) and compare the user's profile with "IFSA Advisor User"
		User currentUser = [SELECT Id, Name, ContactId, ProfileId FROM User WHERE Id =: UserInfo.getUserId()].get(0);
		Id homeInstAdvisorProfileId = [SELECT Id FROM Profile WHERE Name = 'IFSA Advisor User'].get(0).Id;
		// If the current user is "IFSA Advisor User" try to generate a task for the Field Director
		if(currentUser.ProfileId == homeInstAdvisorProfileId)
		{
			// Get the current user's contact
			Contact c = [SELECT Id, Home_Institution__c, Account.Name, AccountID, Account.Institution__c, Account.OwnerId FROM Contact WHERE Id =: currentUser.ContactId].get(0);
			// Create an empty string to be the task decription
			String description = '';
			for(Program_Authorization__c pAuth: newRecords)
			{				
				// If the updated program authorization's account matches the user's account add the program and terms to the task decription
				if(pAuth.Account__c == c.AccountID && (pAuth.Added_Sections__c != null && pAuth.Removed_Sections__c != null))
				{
					String current = pAuth.Program_Name__c; //+ ' - Currently Authorized Sections: ' + pAuth.Term__c;
					//String added = pAuth.Added_Sections__c != null ? pAuth.Added_Sections__c : ' - ';
					//String removed = pAuth.Removed_Sections__c != null ? pAuth.Removed_Sections__c : ' - ';
					description = description + current + /* '\r\n Added: ' + added + '\r\n Removed: ' + removed +*/ '\r\n\r\n';
				}
			}
			// Create task if description is not empty string
			if(description != '')
			{
				Task t = new Task();
				t.OwnerId = c.Account.OwnerId;
				t.Subject = currentUser.Name + ' at ' + c.Account.Name + ' has updated program authorization(s)';
				t.Description = 'Updated Program Authorizations \r\n' + description;
				t.WhatId = c.AccountID;
				t.WhoId = c.Id;
				t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Simple Task').getRecordTypeId();

				Database.insert(t);
			}
		}
	}

	public class programAuthorizationServiceException extends Exception	{ }

	/*
	public class programAuthorizationQueueable implements Queueable
	{
		private Map<Id, Account> accounts;
		public programAuthorizationQueueable(List<Account> accts)
		{
			this.accounts = new Map<Id, Account>(accts);
		}
		
		public void execute(QueueableContext context) 
		{
			List<Program_Term__c> programTerms = programTermService.getFutureCatalogProgramTerms(null);
			// Split program terms into summer and calendar terms
			Set<Id> programsWithSummerTerm = new Set<Id>();
			Map<Id, List<String>> programsWithCalendarTerms = new Map<Id, List<String>>();
			for (Program_Term__c pt: programTerms)
			{
				if(pt.Term__r.Section__c == 'Summer')
				{
					programsWithSummerTerm.add(pt.Program__c);
				}
				else
				{
					if(!programsWithCalendarTerms.containsKey(pt.Program__c))
						programsWithCalendarTerms.put(pt.Program__c, new List<String>());
					
					programsWithCalendarTerms.get(pt.Program__c).add(pt.Term__r.Section__c);
				}
			}
			// Get current Program_Authorization__c records for the accounts being saved, and put them in the map "accountPAuthMap"
			// Map Definition - Map<Id(AccountId), Map<Id(ProgramId, Program_Authorization__c)
			Map<Id, Map<Id, Program_Authorization__c>> accountPAuthMap = new Map<Id, Map<Id, Program_Authorization__c>>();
			for (Program_Authorization__c pAuth: [SELECT Id, Program__c, Program_Name__c, Account__c, Term__c FROM Program_Authorization__c WHERE Account__c IN: this.accounts.keyset()])
			{
				if(!accountPAuthMap.containsKey(pAuth.Account__c))
					accountPAuthMap.put(pAuth.Account__c, new Map<Id, Program_Authorization__c>());
				
				accountPAuthMap.get(pAuth.Account__c).put(pAuth.Program__c, pAuth);
			}
			List<Account> recordsToUpdate = new List<Account>();
			// Iterate over the account record Ids
			for(Id acctId: this.accounts.keyset())
			{
				// Create vars to hold the new and old version of the record
				Account acct = accounts.get(acctId);
				Boolean approvesCalendar = true;
				Boolean approvesSummer = true;
				// Ensure Approves_All_Calendar_Programs__c should not be checked
				if(acct.Approves_All_Calendar_Programs__c == false)
				{
					// Iterate over programs with calendar terms
					for(Id programId: programsWithCalendarTerms.keyset())
					{
						// Ensure that all non-summer terms are authorized
						string existingTerms = accountPAuthMap.get(acctId).get(programId).Term__c != null ? accountPAuthMap.get(acctId).get(programId).Term__c : '';
						for (String sectionName: programsWithCalendarTerms.get(programId))
						{
							if(existingTerms.contains('Not Approved') || !existingTerms.contains(sectionName))
								approvesCalendar = false;
						}
						if(!approvesCalendar)
						{
							break;
						}
					}
				}
				// Ensure Approves_All_Summer_Programs__c should not be checked
				if(acct.Approves_All_Summer_Programs__c == false)
				{
					// Iterate over programs with summer terms
					for(Id programId: programsWithSummerTerm)
					{
						// Ensure that summer terms are authorized
						string existingTerms = accountPAuthMap.get(acctId).get(programId).Term__c != null ? accountPAuthMap.get(acctId).get(programId).Term__c : '';
						if(existingTerms.contains('Not Approved') || !existingTerms.contains('Summer'))
							approvesSummer = false;
					}
					if(!approvesSummer)
					{
						break;
					}
				}
				if(approvesCalendar || approvesSummer)
				{
					acct.Approves_All_Calendar_Programs__c = approvesCalendar;
					acct.Approves_All_Summer_Programs__c = approvesSummer;
					// Add account to records to be updated
					recordsToUpdate.add(acct);
				}
				
			}
			Database.update(recordsToUpdate);
		}
	}
	*/
}