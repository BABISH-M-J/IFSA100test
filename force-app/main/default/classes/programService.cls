/**
 * @description Service class for Program__c.
 * @author Brock Barlow
 */
public with sharing class programService {
	//If this Is an insert, we add the appropriate program-institution records.
	public static void createProgramInsitutionRecords(List<Program__c> newRecords)
	{
		List<Program_Institution__c> progUs = new List<Program_Institution__c>();
		//For each program, see if the host institution is null, otherwise create a program institution record
		for(Program__c program : newRecords)
		{
			if(program.Host_Institution__c != null)
			{
				Program_Institution__c progU = new Program_Institution__c();
				progU.Program__c = program.Id;
				progU.Host_Institution__c = program.Host_Institution__c;
				progUs.add(progU);
			}
		}

		Database.insert(progUs);
	}

	//If this is an update, we need to propagate the name down to program terms.
	//Which just means that we need to get the affected records and set their display name to true.
	public static void renameProgramTermsApplications(Map<Id, Program__c> newMap, Map<Id, Program__c> oldMap)
	{
		//Use trigger old map and trigger new maps to examin if the name field has actually changed. If it has then add the program to the list of Ids to update
		List<Id> idList = new List<Id>();
		for( Id programId : Trigger.newMap.keySet() )
		{
		  if( oldMap.get( programId ).Name != newMap.get( programId ).Name )
		  {
		     idList.add(newMap.get( programId ).Id);
		  }
		}		
		if(idList.isEmpty())
		{
			return;
		}
		Date today = System.today();
		List<SObject> objectsToUpdate = new List<SObject>();
		//Get the list of program terms. Start date must be greater than today, don't rename historical data.
		Map<Id, Program_Term__c> programTerms = new Map<Id, Program_Term__c>([SELECT Id, Display_Name__c, Name FROM Program_Term__c WHERE Program__c IN: idList AND (Start_Date__c >: today OR Start_Date__c =: null)]);
		//Set name to = the display name formula field
		for(Program_Term__c programTerm : programTerms.values())
		{
			programTerm.Name = programTerm.Display_Name__c.replace('University of ', '').replace('University Of ','');
			programTerm.Name = programTerm.Name.replace('(July-the following June/July) ', '');
            programTerm.Name = programTerm.Name.replace('(February-November/December) ', '');
            programTerm.Name = programTerm.Name.replace('(February-June/July) ', '');
			programTerm.Name = programTerm.Name.replace('(July-November/December) ', '');
			objectsToUpdate.add(programTerm);
		}
		//Database.update(programTerms);
		
		//Get the list of applications.		
		//Set name to = the display name formula field
		for(Application__c application : [SELECT Id, Display_Name__c, Name FROM Application__c WHERE Program_Term__c IN: programTerms.keySet()])
		{
			Integer subString = 79;
			if(application.Display_Name__c.length() <79)
			{
				subString = application.Display_Name__c.length();
			}
			application.Name = application.Display_Name__c.Substring(0,subString);
			objectsToUpdate.add(application);
		}

		//Database.update(applications);
		sObjectBatchUpdater.batchUpdate(objectsToUpdate, 20);
	}
	// Generate program authorization And billing arrangement records for existing accounts
	public static void createPAandBARecords(Map<Id, Program__c> newMap)
	{
		List<Account> accounts = [
			SELECT Id, Approves_All_Calendar_Programs__c, Approves_All_Summer_Programs__c,Approves_All_Winter_Programs__c, Direct_Bill__c, Direct_Bill_Summer__c, Direct_Bill_Semester_Year__c,
			Pays_Accommodation__c, Pays_Deposit__c, Pays_Late_Withdraw_Fees__c, Pays_Supplemental_Accommodation_Fees__c, Pays_Supplemental_Tuition_Fees__c, Pays_Tuition__c
			FROM Account WHERE RecordType.Name = 'Home Institution'
		];
		Set<Id> countryIds = new Set<Id>();
		for(Program__c program: newMap.values())
		{
			countryIds.add(program.Country__c);
		}
		Map<Id, Set<Id>> accountCountries = new Map<Id, Set<Id>>();
		Map<String, Billing_Arrangement_Country__c> bacs = new Map<String, Billing_Arrangement_Country__c>();
		List<Billing_Arrangement_Country__c> bacList = [SELECT Id, Account__c, Country__c, Discount_Amount__c, Discount_Recipient__c FROM Billing_Arrangement_Country__c WHERE Country__c IN: countryIds ORDER BY Account__c, Country__c];
		system.debug(bacList.size());
		for(Billing_Arrangement_Country__c bac: bacList)
		{
			if(!accountCountries.containsKey(bac.Account__c))
			{
				accountCountries.put(bac.Account__c, new Set<Id>());
			}
			accountCountries.get(bac.Account__c).add(bac.Country__c);
			bacs.put(bac.Account__c + ',' + bac.Country__c, bac);
		}
		//New Records
		List<SObject> newBArranges = new List<SObject>();
		List<SObject> newPAuths = new List<SObject>();
		List<SObject> newProgramTasks = new List<SObject>();
		Id financeUserID = Id.valueOf([SELECT User_Id__c FROM IFSA_Default_User__mdt WHERE DeveloperName = 'Finance_User'].get(0).User_Id__c);
		for(Program__c p: newMap.values())
		{
			if(p.Category__c == 'Catalog')
			{
				for(Account a: accounts)
				{
					System.debug(a);
					if(a.Approves_All_Summer_Programs__c ||  a.Approves_All_Calendar_Programs__c || a.Approves_All_Winter_Programs__c)
					{
						// Create Program Authorization
						Set<String> authorizedSections = new Set<String>();
						Program_Authorization__c newPAuth = new Program_Authorization__c(Account__c = a.Id, Program__c = p.Id);
						for(String sectionName: p.Available_Sections__c.split(';'))
						{
							if(sectionName == 'Summer' && a.Approves_All_Summer_Programs__c)
							{
								authorizedSections.add(sectionName);
							}
							if(sectionName == 'Winter' && a.Approves_All_Winter_Programs__c)
							{
								authorizedSections.add(sectionName);
							}
							else if(sectionName != 'Summer' && sectionName != 'Winter' && a.Approves_All_Calendar_Programs__c)
							{
								authorizedSections.add(sectionName);
							}
						}
						
						if(!authorizedSections.isEmpty())
						{
							for(String sectionName: authorizedSections)
							{
								newPAuth.Term__c = newPAuth.Term__c + sectionName + ';';
							}
							if(newPAuth.Term__c != null)
							{
								newPAuth.Term__c = newPAuth.Term__c.substringBeforeLast(';');
								newPAuth.Term__c = newPAuth.Term__c.replace('null', '');
							}					
							newPAuths.add(newPAuth);
						}
					}
					// Create Billing Arrangements
					System.debug(accountCountries.get(a.Id));
					if(accountCountries.get(a.Id) != null)
					{
						if(accountCountries.get(a.Id).contains(p.Country__c) || accountCountries.get(a.Id).isEmpty())
						{
							Billing_Arrangement__c newBArrange = new Billing_Arrangement__c(Account__c = a.Id, Program__c = p.Id);
							Set<String> sections = new Set<String>();
							if(p.Possible_Terms__c != null)
							{
								if((a.Direct_Bill_Summer__c && p.Possible_Terms__c.contains('Summer')) && a.Direct_Bill_Semester_Year__c)
								{
									sections = new Set<String>(p.Possible_Terms__c.split(';'));
									newBArrange = setComponentFees(newBArrange, a);
								}
								else if(a.Direct_Bill_Semester_Year__c && !a.Direct_Bill_Summer__c)
								{
									sections = new Set<String>(p.Possible_Terms__c.split(';'));
									sections.remove('Summer');
									newBArrange = setComponentFees(newBArrange, a);
								}
								else if(a.Direct_Bill_Summer__c && !a.Direct_Bill_Semester_Year__c)
								{
									sections.add('Summer');
									newBArrange = setComponentFees(newBArrange, a);
								}
							}
							for(String sectionName: sections)
							{
								newBArrange.Term__c = newBArrange.Term__c + sectionName + ';';
							}
							if(bacs.get(a.Id + ',' + p.Country__c) != null)
							{
								newBArrange.Discount_Amount__c = bacs.get(a.Id + ',' + p.Country__c).Discount_Amount__c;
								newBArrange.Discount_Recipient__c = bacs.get(a.Id + ',' + p.Country__c).Discount_Recipient__c;
							}
							System.debug(newBArrange.Term__c);
							newBArrange.Term__c = newBArrange.Term__c != null && newBArrange.Term__c.endsWith(';') ? newBArrange.Term__c.substringBeforeLast(';') : newBArrange.Term__c;
							newBArrange.Term__c = newBArrange.Term__c != null ? newBArrange.Term__c.replace('null', '') : newBArrange.Term__c;
							newBArrange.Pays_Accomodation__c = a.Pays_Accommodation__c;
							newBArrange.Pays_Deposit__c = a.Pays_Deposit__c;
							newBArrange.Pays_Late_Withdraw_Fees__c = a.Pays_Late_Withdraw_Fees__c;
							newBArrange.Pays_Supplemental_Accommodation_Fees__c = a.Pays_Supplemental_Accommodation_Fees__c;
							newBArrange.Pays_Supplemental_Tuition_Fees__c = a.Pays_Supplemental_Tuition_Fees__c;
							newBArrange.Pays_Tuition__c = a.Pays_Tuition__c;
							newBArrange.Status__c = 'Unverified';
							system.debug(newBArrange);
							newBArranges.add(newBArrange);
						}
					}
				}
				/*Task newProgramTask = new Task(OwnerId = financeUserID);
				newProgramTask.WhatId = p.Id;
				newProgramTask.Subject = 'New Program Created';
				newProgramTask.Description = 'A new program, ' + p.Name +  ' has been created. Please check the system generated Billing Arrangements and once verified change the status to "Verified".';
				newProgramTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Simple Task').getRecordTypeId();

				newProgramTasks.add(newProgramTask);*/
			}
			if(p.Category__c == 'Custom')
			{
				Billing_Arrangement__c newBArrange = new Billing_Arrangement__c(Account__c = p.Custom_Program_Home_Instituiton_Account__c, Program__c = p.Id);
				newBArrange.Direct_Bill__c = true;
				newBArrange.Pays_Accomodation__c = true;
				newBArrange.Pays_Deposit__c = true;
				newBArrange.Pays_Late_Withdraw_Fees__c = true;
				newBArrange.Pays_Supplemental_Accommodation_Fees__c = true;
				newBArrange.Pays_Supplemental_Tuition_Fees__c = true;
				newBArrange.Pays_Tuition__c = true;
				newBArrange.Status__c = 'Verified';
				newBArrange.Term__c = 'Spring;Summer;Fall;Academic Year;Calendar Year;Winter';

				newBArranges.add(newBArrange);
			}
		}
		List<SObject> objectsToInsert = new List<SObject>();
		objectsToInsert.addAll(newPAuths);
		objectsToInsert.addAll(newBArranges);
		objectsToInsert.addAll(newProgramTasks);

		/* database.insert(newPAuths);
		database.insert(newBArranges);
		database.insert(newProgramTasks); */

		sObjectBatchUpdater.batchUpdate(objectsToInsert, 200, sObjectBatchUpdater.dmlTypes.dmlInsert);
	}
	private static Billing_Arrangement__c setComponentFees(Billing_Arrangement__c newBArrangement, Account a)
	{
		newBArrangement.Direct_Bill__c = a.Direct_Bill__c;
		newBArrangement.Pays_Accomodation__c = a.Pays_Accommodation__c;
		newBArrangement.Pays_Deposit__c = a.Pays_Deposit__c;
		newBArrangement.Pays_Late_Withdraw_Fees__c = a.Pays_Late_Withdraw_Fees__c;
		newBArrangement.Pays_Supplemental_Accommodation_Fees__c = a.Pays_Supplemental_Accommodation_Fees__c;
		newBArrangement.Pays_Supplemental_Tuition_Fees__c = a.Pays_Supplemental_Tuition_Fees__c;
		newBArrangement.Pays_Tuition__c = a.Pays_Tuition__c;

		return newBArrangement;
	}

	public static void newProgram(List<Program__c> newRecords)
    {
        for(Program__c p: newRecords)
        {
            Set<String> picklistValues = new Set<String>(apexConversionUtility.getPicklistStringValues(Case.Affected_Programs__c));
            if(!picklistValues.contains(p.Name))
            {
                caseService.createSFTicketToAddValueToPicklist('Case', 'Affected_Programs__c', p.Name);
            }
        }
    }
	//Updated by Vinod Power Fluence "5a" Starting
	public static void updateProgramAvailableSections( Map<Id,Program__c> oldMap, List<Program__c> newRecords, Map<Id, Program__c> newMap )
	{
        Map<Id,Program__c> availableSectionChangedProgList = new Map<Id,Program__c>();
	
		List<Program_Authorization__c> progAuthList = new List<Program_Authorization__c>();
        for(Program__c newRecord : newRecords){
			
            if(newRecord.Available_Sections__c != oldMap.get(newRecord.Id).Available_Sections__c){
				
				availableSectionChangedProgList.put(newRecord.Id, newRecord);
				
			}
		}
        if(availableSectionChangedProgList.size()>0){
           
           progAuthList=[select Id, Term__c,Is_Active__c,Program__c from Program_Authorization__c where Program__c IN : availableSectionChangedProgList.keyset() AND Is_Active__c = true  ];
		
            for(Program_Authorization__c progAuth :progAuthList){
				
                progAuth.Term__c = availableSectionChangedProgList.get(progAuth.Program__c).Available_Sections__c;
				
            }
			sObjectBatchUpdater.batchUpdate(progAuthList, 200, sObjectBatchUpdater.dmlTypes.dmlUpdate);
        }
    }
       //Power Fluence added by vinod "5a" Ended  
}