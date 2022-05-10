/**
 * Service class for Account.
 * @author Brock Barlow
 */
// ApexDoc updated 1/22/2021 Brock Barlow
public without sharing class accountService 
{
	/**
	 * Updates Home Institution records with their Account Id after the account is inserted
	 * @param newRecords The account records that have been inserted
	 */
	public static void afterInsertHomeInstitutionAccount(List<Account> newRecords)
	{
		Map<Id, Id> homeInstIds = new Map<Id, Id>();
		for(Account a: newRecords)
		{
			if(a.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId())
			{
				homeInstIds.put(a.Institution__c, a.Id);
			}
		}
		List<Home_Institution__c> homeInsts = [SELECT Id FROM Home_Institution__c WHERE Id IN: homeInstIds.keyset()];
		for(Home_Institution__c home: homeInsts)
		{
			home.Account__c= homeInstIds.get(home.Id);
		}
		database.update(homeInsts);
	}
	
 /**
   * Generates Progarm Authorization and Billing Arrangement records for new Home Institution Accounts
   * @param newRecords The account records that have been inserted
   */
   	public static void generateEmptyPAuthsAndBillingArrangements(List<Account> newRecords)
	{
		// Get all program terms for the current year and beyond
		List<Program_Term__c> programTerms = programTermService.getFutureCatalogProgramTerms(null);
		Set<Id> programIDs = new Set<Id>();
		//List<Program_Authorization__c> newPAuths = new List<Program_Authorization__c>();
		List<Billing_Arrangement__c> newBillingArrangements = new List<Billing_Arrangement__c>();
		/*for (Account acct: newRecords)
		{
			if(acct.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId())
			{
				for (Program_Term__c pt: programTerms)
				{
					if(!programIds.contains(pt.Program__c))
					{
						programIds.add(pt.Program__c);
						// Program_Authorization__c newPAuth = new Program_Authorization__c();
						// newPAuth.Account__c = acct.Id;
						// newPAuth.Program__c = pt.Program__c;
						// newPAuths.add(newPAuth);
						Billing_Arrangement__c newBillingA = new Billing_Arrangement__c();
						newBillingA.Account__c = acct.Id;
						newBillingA.Program__c = pt.Program__c;
						newBillingA.Status__c = 'Unverified';
						newBillingArrangements.add(newBillingA);
					}					
				}
			}
		}*/
		List<SObject> newObjects = new List<SObject>();
		//newObjects.addAll(newPAuths);
		newObjects.addAll(newBillingArrangements);
		if(!newObjects.isEmpty())
		{
			// Regular use we could be creating hundreds of records so we need to insert asynchronusly, but in tests the number will be less than 200
			// and we want access to the records instantly so we insert synchronusly.
			if(!configurationManager.isTestMode())
			{
				system.enqueueJob(new sObjectQueueableUpdater(newObjects, sObjectQueueableUpdater.dmlOperation.isInsert, 200));		
			}
			else
			{
				database.insert(newObjects);
			}
		}
	}

	/**
     * If an "Approves_All_*_Programs__c" checkbox has been checked and it was not before
	 * 		this method will check Updating_Program_Authorizations__c
     * @param oldMap Map<Id, Account> of the records before the record was updated
     * @param newRecords List<Account> of the records after the record was updated
     */
	public static void checkApprovesChangedBefore(Map<Id, Account> oldMap, List<Account> newRecords)
	{
		for(Account a: newRecords)
		{
			if(a.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId())
			{
				if((a.Id != null && a.Approves_All_Calendar_Programs__c != oldMap.get(a.Id).Approves_All_Calendar_Programs__c) || (a.Id == null && a.Approves_All_Calendar_Programs__c))
				{
					a.Calendar_Approval_Changed_By__c = UserInfo.getUserId();
					a.Calendar_Approval_Changed_Date__c	= Datetime.now();
				}
				if((a.Id != null && a.Approves_All_Summer_Programs__c != oldMap.get(a.Id).Approves_All_Summer_Programs__c) || (a.Id == null && a.Approves_All_Summer_Programs__c))
				{
					a.Summer_Approval_Changed_By__c = UserInfo.getUserId();
					a.Summer_Approval_Changed_Date__c	= Datetime.now();
				} 
				if((a.Id != null && a.Approves_All_Winter_Programs__c != oldMap.get(a.Id).Approves_All_Winter_Programs__c) || (a.Id == null && a.Approves_All_Winter_Programs__c))
				{
					a.Winter_Approval_Changed_By__c = UserInfo.getUserId();
					a.Winter_Approval_Changed_Date__c	= Datetime.now();
				}
			}
		}
		// If an acccount is in this list, Updating_Program_Authorizations__c, then it possibly need Program Authorizations created which happens in async apex, this field is checked to notify the users that processing is happening
		for(Account a: getAccountsToProcess(oldMap, newRecords))
		{
			a.Updating_Program_Authorizations__c = true;
		}
	}

	/**
     * Ensures that program authorization records for the appropriate sections exist for 
	 * 		all programs the correspond with the checked "Approves_All_*_Programs__c" checkboxes.
	 * 		This will start an async process to generate the program approval records
     * @param oldMap Map<Id, Account> of the records before the record was updated
     * @param newRecords List<Account> of the records after the record was updated
     */
	public static void checkApprovesChangedAfter(Map<Id, Account> oldMap, List<Account> newRecords)
	{
		// Get only Home Institution Accounts that have had an Approves_All_*_Programs__c checkbox checked in this insert/update
		List<Account> homeInstAccounts = getAccountsToProcess(oldMap, newRecords);
		if(homeInstAccounts.isEmpty())
		{
			return;
		}
		// If not in a unit test, ensure that Program_Authorizations__c records exisit for programs that match the Approve_All_*_Program__c checkboxes
		if(!Test.isRunningTest())
		{
			new PromiseAccountProgAuth(homeInstAccounts);
		}
	}
	/**
	 * Gets only Home Institution Accounts that have had an Approves_All_*_Programs__c checkbox checked in this insert/update operation
	 * @param oldMap Map<Id, Account> of the records before the record was updated
     * @param newRecords List<Account> of the records after the record was updated
	 * @return List<Account> of the records that meet the condition
	 */
	private static List<Account> getAccountsToProcess(Map<Id, Account> oldMap, List<Account> newRecords)
	{
		Id homeInstRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId();
		List<Account> homeInstAccounts = new List<Account>();
		for(Account a: newRecords)
		{
			// Only process Home Instituiton Accounts AND ensure that Approves_All_Calendar_Programs__c OR Approves_All_Summer_Programs__c is checked and it was not before
			if(a.RecordTypeId == homeInstRT && oldMap != null && oldMap.containsKey(a.Id))
			{
				if(!oldMap.get(a.Id).Updating_Program_Authorizations__c && (a.Approves_All_Calendar_Programs__c && !oldMap.get(a.Id).Approves_All_Calendar_Programs__c) || (a.Approves_All_Summer_Programs__c && !oldMap.get(a.Id).Approves_All_Summer_Programs__c ) || (a.Approves_All_Winter_Programs__c && !oldMap.get(a.Id).Approves_All_Winter_Programs__c ))
				{
					homeInstAccounts.add(a);
				}				
			}
			else if(a.RecordTypeId == homeInstRT && (oldMap == null || !oldMap.containsKey(a.Id)))
			{
				if(a.Approves_All_Calendar_Programs__c || a.Approves_All_Summer_Programs__c || a.Approves_All_Winter_Programs__c)
				{
					homeInstAccounts.add(a);
				}
			}
		}
		return homeInstAccounts;
	}
	/**
	 * Ensures that "Approves_All_*_Programs__c" checkboxes are checked
	 * @param oldMap Map<Id, Account> of the records before the record was updated
	 * @param newMap Map<Id, Account> of the records after the record was updated
	 */
	/*
	public static void checkApprovesChanged(Map<Id, Account> oldMap, Map<Id, Account> newMap)
	{
		Id homeInstRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId();
		List<Id> homeInstAccounts = new List<Id>();
		for(Id acctId: newMap.keyset())
		{
			// Only process Home Instituiton Accounts AND ensure that Approves_All_Calendar_Programs__c OR Approves_All_Summer_Programs__c is checked and it was not before
			if(newMap.get(acctId).RecordTypeId == homeInstRT && ((newMap.get(acctId).Approves_All_Calendar_Programs__c && !oldMap.get(acctId).Approves_All_Calendar_Programs__c) || (newMap.get(acctId).Approves_All_Summer_Programs__c && !oldMap.get(acctId).Approves_All_Summer_Programs__c ) || (newMap.get(acctId).Approves_All_Winter_Programs__c && !oldMap.get(acctId).Approves_All_Winter_Programs__c )))
			{
				homeInstAccounts.add(acctId);
			}
		}
		if(homeInstAccounts.isEmpty())
		{
			return;
		}
		// Get all active programs
		Map<Id, Program__c> activePrograms = new Map<Id, Program__c>([SELECT Id, Name, Has_Academic_Year_Program_Terms__c, Has_Calendar_Year_Program_Terms__c, Has_Fall_Program_Terms__c, Has_Spring_Program_Terms__c, Has_Summer_Program_Terms__c, Has_Winter_Program_Terms__c FROM Program__c WHERE Active__c = TRUE AND Category__c = 'Catalog' AND Name != 'Undecided']);
		// Split program terms into summer, winter and calendar terms
		Set<Id> programsWithSummerTerm = new Set<Id>();
		Set<Id> programsWithWinterTerm = new Set<Id>();
		Map<Id, List<String>> programsWithCalendarTerms = new Map<Id, List<String>>();
		for (Program__c p: activePrograms.values())
		{
			if(p.Has_Summer_Program_Terms__c)
			{
				programsWithSummerTerm.add(p.Id);
			}
			if(p.Has_Winter_Program_Terms__c)
			{
				programsWithWinterTerm.add(p.Id);
			}
			if(p.Has_Spring_Program_Terms__c || p.Has_Fall_Program_Terms__c || p.Has_Calendar_Year_Program_Terms__c || p.Has_Academic_Year_Program_Terms__c)
			{
				if(!programsWithCalendarTerms.containsKey(p.Id))
				{
					programsWithCalendarTerms.put(p.Id, new List<String>());
				}
				if(p.Has_Spring_Program_Terms__c)
				{
					programsWithCalendarTerms.get(p.Id).add('Spring');
				}
				if(p.Has_Fall_Program_Terms__c)
				{
					programsWithCalendarTerms.get(p.Id).add('Fall ');
				}
				if(p.Has_Calendar_Year_Program_Terms__c)	
				{
					programsWithCalendarTerms.get(p.Id).add('Spring');
				}
				if(p.Has_Academic_Year_Program_Terms__c)
				{
					programsWithCalendarTerms.get(p.Id).add('Academic Year');
				}
			}
		}
		// Get current Program_Authorization__c records for the accounts being saved, and put them in the map "accountPAuthMap"
		// Map Definition - Map<Id(AccountId), Map<Id(ProgramId, Program_Authorization__c)
		Map<Id, Map<Id, Program_Authorization__c>> accountPAuthMap = new Map<Id, Map<Id, Program_Authorization__c>>();
		for (Program_Authorization__c pAuth: [SELECT Id, Program__c, Program_Name__c, Account__c, Term__c FROM Program_Authorization__c WHERE Account__c IN: homeInstAccounts AND Is_Active__c = TRUE AND Program__r.Active__c = TRUE])
		{
			if(!accountPAuthMap.containsKey(pAuth.Account__c))
				accountPAuthMap.put(pAuth.Account__c, new Map<Id, Program_Authorization__c>());
			
			accountPAuthMap.get(pAuth.Account__c).put(pAuth.Program__c, pAuth);
		}
		List<Program_Authorization__c> recordsToUpsert = new List<Program_Authorization__c>();
		// Iterate over the account record Ids
		for(Id acctId: homeInstAccounts)
		{
			// Create vars to hold the new and old version of the record
			Account newRecord = newMap.get(acctId);
			Account oldRecord = oldMap.get(acctId);
			
			// Ensure that accountPAuthMap contains a key
			if(!accountPAuthMap.containsKey(acctId))
				//If it does not add the key and a new Map<Id, Program_Authorization__c>
				accountPAuthMap.put(acctId, new Map<Id, Program_Authorization__c>());
			// If Approves_All_Calendar_Programs__c is now checked and wasn't before 
			if(newRecord.Approves_All_Calendar_Programs__c == true && oldRecord.Approves_All_Calendar_Programs__c == false)
			{
				// Iterate over programs with calendar terms
				for(Id programId: programsWithCalendarTerms.keyset())
				{
					//If the program doesn't have a Program_Authorization__c for the program create it
					if(!accountPAuthMap.get(acctId).containsKey(programId))
					{
						Program_Authorization__c newPAuth = new Program_Authorization__c(Account__c = acctId, Program__c = programId);
						accountPAuthMap.get(acctId).put(programId, newPAuth);
					}
					//Ensure that all non-summer terms are authorized
					string existingTerms = accountPAuthMap.get(acctId).get(programId).Term__c != null ? accountPAuthMap.get(acctId).get(programId).Term__c : '';
					for (String sectionName: programsWithCalendarTerms.get(programId))
					{
						if(existingTerms.contains('Not Approved'))
							existingTerms = '';
						if(!existingTerms.contains(sectionName))
							existingTerms = existingTerms != '' ? existingTerms + ';' + sectionName : sectionName;
							if(activePrograms.get(programId).Name == 'Career Accelerator')
							{
								System.debug('Current Prog Auth: ' + accountPAuthMap.get(acctId).get(programId));
								System.debug('Current Terms: ' + accountPAuthMap.get(acctId).get(programId).Term__c);
								System.debug('New Terms: ' + existingTerms);
							}
					}
					accountPAuthMap.get(acctId).get(programId).Term__c = existingTerms;
				}
			}
			// If Approves_All_Summer_Programs__c is now checked and wasn't before
			if(newRecord.Approves_All_Summer_Programs__c == true && oldRecord.Approves_All_Summer_Programs__c == false)
			{
				// Iterate over programs with summer terms
				for(Id programId: programsWithSummerTerm)
				{
					//If the program doesn't have a Program_Authorization__c for the program create it
					if(!accountPAuthMap.get(acctId).containsKey(programId))
					{
						Program_Authorization__c newPAuth = new Program_Authorization__c(Account__c = acctId, Program__c = programId);
						accountPAuthMap.get(acctId).put(programId, newPAuth);
					}
					//Ensure that summer terms are authorized
					string existingTerms = accountPAuthMap.get(acctId).get(programId).Term__c != null ? accountPAuthMap.get(acctId).get(programId).Term__c : '';
					system.debug(accountPAuthMap.get(acctId).get(programId).Program_Name__c + ' Existing Terms: ' + existingTerms);
					if(existingTerms.contains('Not Approved'))
						existingTerms = '';
					if(!existingTerms.contains('Summer'))
						existingTerms = existingTerms != '' ? existingTerms + ';' + 'Summer' : 'Summer';
					system.debug(accountPAuthMap.get(acctId).get(programId).Program_Name__c + ' Existing Terms: ' + existingTerms);
					accountPAuthMap.get(acctId).get(programId).Term__c = existingTerms;
				}
				// If Approves_All_Winter_Programs__c is now checked and wasn't before
			}
			if(newRecord.Approves_All_Winter_Programs__c == true && oldRecord.Approves_All_Winter_Programs__c == false)
			{
				// Iterate over programs with summer terms
				for(Id programId: programsWithWinterTerm)
				{
					//If the program doesn't have a Program_Authorization__c for the program create it
					if(!accountPAuthMap.get(acctId).containsKey(programId))
					{
						Program_Authorization__c newPAuth = new Program_Authorization__c(Account__c = acctId, Program__c = programId);
						accountPAuthMap.get(acctId).put(programId, newPAuth);
					}
					//Ensure that summer terms are authorized
					string existingTerms = accountPAuthMap.get(acctId).get(programId).Term__c != null ? accountPAuthMap.get(acctId).get(programId).Term__c : '';
					system.debug(accountPAuthMap.get(acctId).get(programId).Program_Name__c + ' Existing Terms: ' + existingTerms);
					if(existingTerms.contains('Not Approved'))
						existingTerms = '';
					if(!existingTerms.contains('Winter'))
						existingTerms = existingTerms != '' ? existingTerms + ';' + 'Winter' : 'Winter';
					system.debug(accountPAuthMap.get(acctId).get(programId).Program_Name__c + ' Existing Terms: ' + existingTerms);
					accountPAuthMap.get(acctId).get(programId).Term__c = existingTerms;
				}
			}
			// Add all of the account program authorizations to list to be updated
			recordsToUpsert.addAll(accountPAuthMap.get(acctId).values());
		}
		//database.upsert(recordsToUpsert);
		// Upsert recordsToUpsert via Queueable Batch process since the number of records maybe greater than 200 as long as there are records to update
		
		if(!recordsToUpsert.isEmpty())
		{
			if(!Test.isRunningTest() && recordsToUpsert.size() >= 200)
			{
				system.enqueueJob(new sObjectQueueableUpdater(recordsToUpsert, sObjectQueueableUpdater.dmlOperation.isUpsert, 200));	
			}
			else
			{
				database.upsert(recordsToUpsert);
			}
		}
	}
	*/
	/**
	 * Populates FinancialForce fields when a new Student account is created
	 * @param newRecords The account records that are being inserted
	 */
	public static void beforeAccountInsert(List<Account> newRecords)
	{
		for(Account a : newRecords)
		{
			if(a.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId())
			{
				a.Make_Check_Payable_To__c = a.Name;
				// Commented on 14-Feb-2022 by Powerfluence to fix the TradingCurrency availability.
				//a.c2g__CODAAccountTradingCurrency__c = 'USD';
				a.c2g__CODABaseDate1__c = 'Invoice Date';
				a.c2g__CODADaysOffset1__c = 30;
				a.c2g__CODADescription1__c = 'Net 30';
				a.c2g__CODADiscount1__c = 0;
				a.c2g__CODASalesTaxStatus__c = 'Exempt';
				a.c2g__CODATaxCalculationMethod__c = 'Gross';
				List<c2g__codaGeneralLedgerAccount__c> glAccounts = [SELECT Id, Name FROM c2g__codaGeneralLedgerAccount__c WHERE Name IN ('2099 - Accounts Payable', '1110 - Student Receivables')];
				for(c2g__codaGeneralLedgerAccount__c gl: glAccounts)
				{
					if(gl.Name == '2099 - Accounts Payable')	
					{
						a.c2g__CODAAccountsPayableControl__c = gl.Id;
					}
					else if(gl.Name == '1110 - Student Receivables')
					{
						a.c2g__CODAAccountsReceivableControl__c = gl.Id;
					}
				}
			}
		}
	}

	/**
	 * Sends a Task to the account owner when Course_Equivalency_Search__c is disabled
	 * @param oldMap the state of the records before they were updated
	 * @param newMap the state of the records after the update
	 */
	public static void checkCESearch(Map<Id, Account> oldMap, Map<Id, Account> newMap)
	{
		Map<Id, Task> tasks = new Map<Id, Task>();
		Task original = new Task(Subject = 'CE Search Disabled', Status = 'Not Started', ActivityDate = Date.today().addDays(5), Description = 'An advisor has turned off home institution equivalents in CHART for this institution');
		for(Account a: newMap.values())
		{
			if(!a.Course_Equivalency_Search__c && oldMap.get(a.Id).Course_Equivalency_Search__c)
			{
				Task t = original.clone(false, false, false, false);
				t.WhatId = a.Id;
				tasks.put(a.Institution__c, t);
			}
		}
		for(Home_Institution__c hi: [SELECT Id, Field_Director__c FROM Home_Institution__c WHERE Id IN: tasks.keyset()])
		{
			tasks.get(hi.Id).OwnerId = hi.Field_Director__c;
		}

		database.insert(tasks.values());
	}

	/**
	 * Ensures that the three Approves All * Program checkboxes are correct.
	 * @param oldMap the state of the records before they were updated
	 * @param newMap the state of the records after the update
	 */
	
	public static void verifyApprovesAll(Map<Id,Account> oldMap, Map<Id,Account> newMap)
	{
		Id homeInstRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId();
		List<Id> homeInstAccounts = new List<Id>();
		for(Id acctId: newMap.keyset())
		{
			// Only process Home Instituiton Accounts
			if(newMap.get(acctId).RecordTypeId == homeInstRT && (newMap.get(acctId).Approves_All_Calendar_Programs__c || newMap.get(acctId).Approves_All_Summer_Programs__c || newMap.get(acctId).Approves_All_Winter_Programs__c))
			{
				homeInstAccounts.add(acctId);
			}
		}
		if(homeInstAccounts.isEmpty())
		{
			return;
		}
		// Get all active programs
		Map<Id, Program__c> activePrograms = new Map<Id, Program__c>([SELECT Id, Name, Has_Academic_Year_Program_Terms__c, Has_Calendar_Year_Program_Terms__c, Has_Fall_Program_Terms__c, Has_Spring_Program_Terms__c, Has_Summer_Program_Terms__c, Has_Winter_Program_Terms__c FROM Program__c WHERE Category__c = 'Catalog' AND Active__c = TRUE AND Name != 'Undecided']);

		// Get current Program_Authorization__c records for the accounts being saved, and put them in the map "accountPAuthMap"
		// Map Definition - Map<Id(AccountId), Map<Id(ProgramId, Program_Authorization__c)
		Map<Id, Map<Id, Program_Authorization__c>> accountPAuthMap = new Map<Id, Map<Id, Program_Authorization__c>>();
		for (Program_Authorization__c pAuth: [SELECT Id, Program__c, Program_Name__c, Account__c, Term__c FROM Program_Authorization__c WHERE Account__c IN: homeInstAccounts AND Is_Active__c = TRUE])
		{
			if(!accountPAuthMap.containsKey(pAuth.Account__c))
				accountPAuthMap.put(pAuth.Account__c, new Map<Id, Program_Authorization__c>());
			
			accountPAuthMap.get(pAuth.Account__c).put(pAuth.Program__c, pAuth);
		}
		// Iterate over the account record Ids
		for(Id acctId: homeInstAccounts)
		{
			// Create vars to hold the new and old version of the record
			Account newRecord = newMap.get(acctId);
			Account oldRecord = oldMap.get(acctId);
			System.debug('accountPAuthMap => ' + accountPAuthMap);
			
			// Ensure that accountPAuthMap contains a key
			if(!accountPAuthMap.containsKey(acctId)){
				//If it does not add the key and a new Map<Id, Program_Authorization__c>
				accountPAuthMap.put(acctId, new Map<Id, Program_Authorization__c>());
			}
            Boolean summer = true;
			Boolean calendar = true;
			Boolean winter = true;
			if(accountPAuthMap.get(acctId).values().isEmpty())
			{
				summer = false;
				calendar = false;
				winter = false;
			}
			else
			{
				for(Program__c p: activePrograms.values())
				{
					Program_Authorization__c pa = accountPAuthMap.get(acctId).get(p.Id);
					if(pa != null)
						system.debug(pa);
					String terms = pa?.Term__c != null ? pa.Term__c : '';
					if((pa == null && p.Has_Summer_Program_Terms__c) || (summer && p.Has_Summer_Program_Terms__c && !terms.contains('Summer')))
					{
						summer = false;
					}
					if((pa == null && p.Has_Winter_Program_Terms__c) || (winter && p.Has_Winter_Program_Terms__c && !terms.contains('Winter')))
					{
						winter = false;
					}
					if((pa == null && p.Has_Spring_Program_Terms__c) || (calendar && p.Has_Spring_Program_Terms__c && !terms.contains('Spring')))
					{
						calendar = false;
					}
					if((pa == null && p.Has_Fall_Program_Terms__c) || (calendar && p.Has_Fall_Program_Terms__c && !terms.contains('Fall')))
					{
						calendar = false;
					}
					if((pa == null && p.Has_Academic_Year_Program_Terms__c) || (calendar && p.Has_Academic_Year_Program_Terms__c && !terms.contains('Academic Year')))
					{
						calendar = false;
					}
					if((pa == null && p.Has_Calendar_Year_Program_Terms__c) || (calendar && p.Has_Calendar_Year_Program_Terms__c && !terms.contains('Calendar Year')))
					{
						calendar = false;
					}
				}
			}
			
			summer = oldRecord.Approves_All_Summer_Programs__c == false && newRecord.Approves_All_Summer_Programs__c == true ? true : summer;
			calendar = oldRecord.Approves_All_Calendar_Programs__c == false && newRecord.Approves_All_Calendar_Programs__c == true ? true : calendar;
			winter = oldRecord.Approves_All_Winter_Programs__c == false && newRecord.Approves_All_Winter_Programs__c == true ? true : winter;

			newRecord.Approves_All_Summer_Programs__c = summer;
			newRecord.Approves_All_Calendar_Programs__c = calendar;
			newRecord.Approves_All_Winter_Programs__c = winter;
		}
	}
	

	public static void parseBillingAddress(List<Account> newRecords)
	{
		for(Account a: newRecords)
		{
			System.debug(a.BillingStreet);
			if(a.BillingStreet != null)
			{
				a.Billing_Address_1__c = null;
				a.Billing_Address_2__c = null;
				a.Billing_Address_3__c = null;
				a.Billing_Address_4__c = null;
				String[] lines = a.BillingStreet.split('\r\n');
				a.Billing_Address_1__c = lines[0];
				if(lines.size() > 1)
				{
					a.Billing_Address_2__c = lines[1];
					if(lines.size() > 2)
					{
						a.Billing_Address_3__c = lines[2];
						if(lines.size() > 3)
						{
							a.Billing_Address_4__c = lines[3];
						}
					}
				}
			}
		}
	}
}