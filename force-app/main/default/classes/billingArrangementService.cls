/**
 * Service class for Billing_Arrangement__c, methods in this class are executed by <<billingArrangementCountryTriggerHandler>> and <<billingArrangementTriggerHandler>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/26/2021 Brock Barlow
public with sharing class billingArrangementService
{
	/**
	 * Before Update Method
	 * @param Map<Id, Billing_Arrangement__c> newMap - updated record
	 * @param Map<Id, Billing_Arrangement__c> oldMap - record before update
	*/
	public static void updateBillingArrangementBefore(Map<Id, Billing_Arrangement__c> newMap, Map<Id, Billing_Arrangement__c> oldMap)
	{
		Map<Id, Billing_Arrangement__c> newBAs = new  Map<Id, Billing_Arrangement__c>();
		List<Id> previousVersionIds = new List<Id>();
		List<Billing_Arrangement__c> PVs = new List<Billing_Arrangement__c>();
		for(Billing_Arrangement__c newRecord: newMap.values())
		{
			if(newRecord.Previous__c != null)
			{
				previousVersionIds.add(newRecord.Previous__c);
			}
		}
		if(!previousVersionIds.isEmpty())
		{
			PVs = apexQueryUtility.selectAllFrom('Billing_Arrangement__c', 'Id IN ' + apexQueryUtility.buildInClause(previousVersionIds));
		}
		Map<Id, Billing_Arrangement__c> previousVersion = new Map<Id, Billing_Arrangement__c>(PVs);
		for(Billing_Arrangement__c newRecord: newMap.values())
		{
			Id recordId = newRecord.Id;
			Billing_Arrangement__c oldRecord = oldMap.get(recordId);
			Boolean recordUpdated = (newRecord.Term__c != oldMap.get(newRecord.Id).Term__c || 
				newRecord.Discount_Amount__c != oldMap.get(newRecord.Id).Discount_Amount__c ||
				newRecord.Discount_Recipient__c != oldMap.get(newRecord.Id).Discount_Recipient__c ||
				newRecord.Pays_Accomodation__c != oldMap.get(newRecord.Id).Pays_Accomodation__c ||
				newRecord.Pays_Deposit__c != oldMap.get(newRecord.Id).Pays_Deposit__c ||
				newRecord.Pays_Tuition__c != oldMap.get(newRecord.Id).Pays_Tuition__c ||
				newRecord.Pays_Supplemental_Accommodation_Fees__c != oldMap.get(newRecord.Id).Pays_Supplemental_Accommodation_Fees__c ||
				newRecord.Pays_Supplemental_Tuition_Fees__c != oldMap.get(newRecord.Id).Pays_Supplemental_Tuition_Fees__c ||
				newRecord.Pays_Late_Withdraw_Fees__c != oldMap.get(newRecord.Id).Pays_Late_Withdraw_Fees__c);
			if(recordUpdated && newRecord.CreatedDate.date() != Date.today())
			{
				Billing_Arrangement__c updatedBA = new Billing_Arrangement__c();
				apexSectionDifference difference = new apexSectionDifference(newRecord.Term__c, oldRecord.Term__c);
				System.debug(difference);
				updatedBA.Account__c = newRecord.Account__c;
				updatedBA.Program__c = newRecord.Program__c;
				updatedBA.Term__c = newRecord.Term__c;
				updatedBA.Added_Sections__c = difference.addedSections();
				updatedBA.Removed_Sections__c = difference.removedSections();
				updatedBA.Previous__c = null;
				updatedBA.Status__c = newRecord.Status__c != 'Verified' ? 'Unverified' : 'Verified';
				newBAs.put(recordId, updatedBA);
				System.debug(updatedBA.Term__c);
				newRecord.Term__c = oldRecord.Term__c;
				newRecord.Direct_Bill__c = oldRecord.Direct_Bill__c;
				newRecord.Discount_Amount__c = oldRecord.Discount_Amount__c;
				newRecord.Discount_Recipient__c = oldRecord.Discount_Recipient__c;
				newRecord.Pays_Accomodation__c = oldRecord.Pays_Accomodation__c;
				newRecord.Pays_Deposit__c = oldRecord.Pays_Deposit__c;
				newRecord.Pays_Tuition__c = oldRecord.Pays_Tuition__c;
				newRecord.Pays_Late_Withdraw_Fees__c = oldRecord.Pays_Late_Withdraw_Fees__c;
				newRecord.Pays_Supplemental_Accommodation_Fees__c = oldRecord.Pays_Supplemental_Accommodation_Fees__c;
				newRecord.Pays_Supplemental_Tuition_Fees__c = oldRecord.Pays_Supplemental_Tuition_Fees__c;
				
			}
			else if(recordUpdated && newRecord.CreatedDate.date() == Date.today() && newRecord.Previous__c != null)
			{
				Billing_Arrangement__c pv = previousVersion.get(newRecord.Previous__c);
				apexSectionDifference difference = new apexSectionDifference(newRecord.Term__c, pv.Term__c);
				Boolean sameValues = ( 
					newRecord.Discount_Amount__c == pv.Discount_Amount__c ||
					newRecord.Discount_Recipient__c == pv.Discount_Recipient__c ||
					newRecord.Pays_Accomodation__c == pv.Pays_Accomodation__c ||
					newRecord.Pays_Deposit__c == pv.Pays_Deposit__c ||
					newRecord.Pays_Tuition__c == pv.Pays_Tuition__c ||
					newRecord.Pays_Supplemental_Accommodation_Fees__c == pv.Pays_Supplemental_Accommodation_Fees__c ||
					newRecord.Pays_Supplemental_Tuition_Fees__c == pv.Pays_Supplemental_Tuition_Fees__c ||
					newRecord.Pays_Late_Withdraw_Fees__c == pv.Pays_Late_Withdraw_Fees__c) && difference.hasNoDifference();
				if(sameValues)
				{
					billingArrangementTriggerHandler.recordsToDelete.add(newRecord);
				}				
			}
		}
		billingArrangementTriggerHandler.newBillingArrangements = newBAs;
	}
	/**
	 * Before Update Method
	 * @param Map<Id, Billing_Arrangement__c> newMap - updated record
	 * @param Map<Id, Billing_Arrangement__c> oldMap - record before update
	 * @param Map<Id, Billing_Arrangement__c> newBAs - from TriggerHandler, if new records are created in this method then they will be passed back to the trigger handler
	*/
	public static void updateBillingArrangementAfter(Map<Id, Billing_Arrangement__c> newMap, Map<Id, Billing_Arrangement__c> oldMap, Map<Id, Billing_Arrangement__c> newBAs)
	{
		for(Billing_Arrangement__c ba: newBAs.values())
		{
			System.debug(ba.Status__c);
		}
		database.insert(newBAs.values());
		List<Billing_Arrangement__c> BAsToUpdate = new List<Billing_Arrangement__c>();
		for(Id oldPaId: newBAs.keySet())
		{
			System.debug(newBAs.get(oldPaId).Id);
			BAsToUpdate.add(new Billing_Arrangement__c(Id = oldPaId, Next__c = newBAs.get(oldPaId).Id));
			newBAs.get(oldPaId).Previous__c = oldPaId;
			BAsToUpdate.add(newBAs.get(oldPaId));
			newBAs.remove(oldPaId);
		}

		database.update(BAsToUpdate);
	}

	/**
	* when Billing Arrangement record created for a new custom program, mark all of the component fee fields "true"
	* @param List<Billing_Arrangement__c> - newRecords the current values of the records
	*/
	public static void checkCustomProgram(List<Billing_Arrangement__c> newRecords)
	{
		Set<Id> programIds = new Set<Id>();
		for(Billing_Arrangement__c bA: newRecords)
		{
			programIds.add(bA.Program__c);
		}
		Map<Id, Program__c> customPrograms = new Map<Id, Program__c>([SELECT Id FROM Program__c WHERE Id IN: programIds AND Category__c = 'Custom']);
		for(Billing_Arrangement__c bA: newRecords)
		{
			for(Id programId: customPrograms.keySet())
			{
				if(bA.Program__c == programId)
				{
					bA.Pays_Accomodation__c = true;
					bA.Pays_Deposit__c = true;
					bA.Pays_Tuition__c = true;
					bA.Pays_Supplemental_Accommodation_Fees__c = true;
					bA.Pays_Supplemental_Tuition_Fees__c = true;
					bA.Pays_Late_Withdraw_Fees__c = true;
				}
			}
		}
	}
	/**
	* when Billing Arrangement Country record is created, create billing arrangement records for all of the non-custom programs in the country using the defaults on the account record
	* @param List<Billing_Arrangement_Country__c> - newRecords the current values of the records
	*/
	public static void createForCountries(List<Billing_Arrangement_Country__c> newRecords)
	{
		Map<Id, Billing_Arrangement_Country__c> countries = new Map<Id, Billing_Arrangement_Country__c>();
		Set<Id> accountIds = new Set<Id>();
		
		for(Billing_Arrangement_Country__c bac: newRecords)
		{
			countries.put(bac.Country__c, bac);
			accountIds.add(bac.Account__c);
		}

		List<Billing_Arrangement__c> bas = [SELECT Id, Program__c, Account__c FROM Billing_Arrangement__c WHERE Account__c IN: accountIds];
		List<Account> accounts = apexQueryUtility.selectAllFrom('Account', 'Id IN ' + apexQueryUtility.buildInClause(accountIds));
		List<Program__c> programs = [SELECT Id, Name, Possible_Terms__c, Country__c, Category__c FROM Program__c WHERE Country__c IN: countries.keySet() AND Category__c = 'Catalog'];
		List<Billing_Arrangement__c> newBAs = new List<Billing_Arrangement__c>();

		for(Program__c program: programs)
		{
			for(Account acct: accounts)
			{
				/* This was not desired functionality
				//If new BAC Discount_Recipient__c field is null, set it to either school or student depending on the value on account's Scholarship_Discount_Recipient__c
				if(countries.get(program.Country__c).Discount_Recipient__c == null && program.Category__c != 'Custom')
				{
					countries.get(program.Country__c).Discount_Recipient__c = acct.Scholarship_Discount_Recipient__c == 'School' ? 'School' : 'Student';
				}*/
				Boolean hasBillingArrangement = false;
				for(Billing_Arrangement__c ba: bas)
				{
					if(ba.Account__c == acct.Id && ba.Program__c == program.Id)
					{
						hasBillingArrangement = true;
					}
				}

				if(!hasBillingArrangement)
				{
					Billing_Arrangement__c newBA = new Billing_Arrangement__c(Account__c = acct.Id, Program__c = program.Id);
					newBA.Direct_Bill__c = acct.Direct_Bill__c;
					newBA.Pays_Accomodation__c = acct.Pays_Accommodation__c;
					newBA.Pays_Deposit__c = acct.Pays_Deposit__c;
					newBA.Pays_Late_Withdraw_Fees__c = acct.Pays_Late_Withdraw_Fees__c;
					newBA.Pays_Supplemental_Accommodation_Fees__c = acct.Pays_Supplemental_Accommodation_Fees__c;
					newBA.Pays_Supplemental_Tuition_Fees__c = acct.Pays_Supplemental_Tuition_Fees__c;
					newBA.Pays_Tuition__c = acct.Pays_Tuition__c;
					if(acct.Direct_Bill_Summer__c && acct.Direct_Bill_Semester_Year__c)
					{
						newBA.Term__c = program.Possible_Terms__c;
					}
					else if(acct.Direct_Bill_Summer__c && !acct.Direct_Bill_Semester_Year__c && program.Possible_Terms__c.contains('Summer'))
					{
						newBA.Term__c = 'Summer';
					}
					else if(!acct.Direct_Bill_Summer__c && acct.Direct_Bill_Semester_Year__c)
					{
						newBA.Term__c = program.Possible_Terms__c.remove('Summer');
					}
					newBA.Status__c = 'Unverified';
					if(!program.Name.contains('Engage '))
					{
						newBA.Discount_Amount__c = countries.containsKey(program.Country__c) ? countries.get(program.Country__c).Discount_Amount__c : null;
						newBA.Discount_Recipient__c = countries.containsKey(program.Country__c) ? countries.get(program.Country__c).Discount_Recipient__c : null;
					}
					newBAs.add(newBA);
				}
			}
		}
		sObjectBatchUpdater.batchUpdate(newBAs, 200, sObjectBatchUpdater.dmlTypes.dmlInsert);
		newRecords = countries.values();
	}
	/*
	* when Billing Arrangement record is created, ensure that Discount_Recipient__c is set to 'School' or 'Student' if the account Scholarship_Discount_Recipient__c is null the value defaults to 'Student'
	* @param List<Billing_Arrangement__c> - newRecords the current values of the records
	*/
	/* This was not desired functionality
	public static void setDiscountRecipient(List<Billing_Arrangement__c> newRecords)
	{
		List<Id> accountIds = new List<Id>();
		List<Id> programIds = new List<Id>();
		for(Billing_Arrangement__c ba: newRecords)
		{
			if(ba.Discount_Recipient__c == null)
			{
				accountIds.add(ba.Account__c);
				programIds.add(ba.Program__c);
			}
		}
		Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Scholarship_Discount_Recipient__c FROM Account WHERE Id IN: accountIds]);
		Map<Id, Program__c> programs = new Map<Id, Program__c>([SELECT Id, Name, Category__c FROM Program__c WHERE Id IN: programIds]);
		for(Billing_Arrangement__c ba: newRecords)
		{
			if(ba.Discount_Recipient__c == null)
			{
				system.debug('Not Custom: ' + programs.get(ba.Program__c).Category__c != 'Custom');
				system.debug('Not Engage: ' + !programs.get(ba.Program__c).Name.contains('Engage'));
				if(programs.get(ba.Program__c).Category__c != 'Custom' && !programs.get(ba.Program__c).Name.contains('Engage'))
				{
					ba.Discount_Recipient__c = accounts.get(ba.Account__c).Scholarship_Discount_Recipient__c == 'School' ? 'School' : 'Student';
				}
			}
		}
	}
	*/
}