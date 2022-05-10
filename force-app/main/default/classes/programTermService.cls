/**
* @description Service class for interacting with Program Term
* @author Brock Barlow
*/
public without sharing class programTermService {
	public enum triggerType
	{
		isInsert,isUpdate,isDelete,isBefore,isAfter
	}

	/**
	 * @description Sets the program term name when the program term is created
	 * @param newRecords The newly inserted records
	 */
	public static void setProgramTermName(List<Program_Term__c> newRecords)
	{
		//system.debug('--- setProgramTermName Start ---');
		
		Set<Id> programIds = new Set<Id>();
		Set<Id> termIds = new Set<Id>();
		for(Program_Term__c programTerm : newRecords)
		{
			programIds.add(programTerm.Program__c);
			termIds.add(programTerm.Term__c);
		}
		
		Map<Id, Program__c> programMap = new Map<Id, Program__c>([SELECT Id, Abbreviated_Program_Name__c FROM Program__c WHERE Id IN: programIds]);
		Map<Id, Term__c> termMap = new Map<Id, Term__c>([SELECT Id, Name FROM Term__c WHERE Id IN: termIds]);

		for(Program_Term__c programTerm : newRecords)
		{
			string ptName = '';
			// Remove "University of " from program term name
			ptName = programTerm.Display_Name__c.startsWithIgnoreCase('University of ') ? String.valueOf(programTerm.Display_Name__c.substring(14)) : String.valueOf(programTerm.Display_Name__c);
			// Remove IFSA * in
			ptName = ptName.replace('IFSA Study in ', '');
			// Use abbreviation if display name is > 60 characters and the program term is a child program term
			ptName = programTerm.Display_Name__c.length() > 60 && programTerm.Program_Option_Name__c != null && programMap.get(programTerm.Program__c).Abbreviated_Program_Name__c != null ? programMap.get(programTerm.Program__c).Abbreviated_Program_Name__c + ' ' + termMap.get(programTerm.Term__c).Name + ' ' + programTerm.Program_Option_Name__c : ptName;
            ptName = ptName.replace('(July-the following June/July) ', '');
            ptName = ptName.replace('(February-November/December) ', '');
            ptName = ptName.replace('(February-June/July) ', '');
            ptName = ptName.replace('(July-November/December) ', '');
			programTerm.Name = ptName;
		}
		//system.debug('--- setProgramTermName End ---');
	}
	/**
	 * @description Gets all future catalog program terms
	 * @return List<Program_Term__c> - future catalog program terms
	 */
	public static List<Program_Term__c> getFutureCatalogProgramTerms(Set<Id> programIds)
	{
		List<Program_Term__c> pts = new List<Program_Term__c>();
		if(programIds == null || programIds.isEmpty())
		{
			pts = [SELECT Id, Term__r.Section__c, Program__c, Start_Date__c FROM Program_Term__c WHERE Program__r.Active__c = TRUE AND Program__r.Category__c = 'Catalog' AND Term__r.Year__c >=: Date.today().year() AND Program__r.Name != 'Undecided' ORDER BY Start_Date__c NULLS LAST];
		}
		else
		{
			//system.debug(LoggingLevel.INFO, programIds);
			pts = [SELECT Id, Program__c, Term__r.Section__c FROM Program_Term__c WHERE Program__c IN: programIds AND Term__r.Year__c >=: Date.Today().year()];
		}
		//system.debug(LoggingLevel.INFO, String.valueOf(pts.size()));
		return pts;
	}

	/**
	 * @description Populates program and term lookups for child program terms
	 * @param newRecords The newly inserted records
	 */
	public static void assignProgramAndTerm(List<Program_Term__c> newRecords)
	{
		//system.debug('--- assignProgramAndTerm Start ---');
		Id poWithDates = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option with Dates').getRecordTypeId();
		Id poWithoutDates = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option without Dates').getRecordTypeId();
		Set<Id> parentIds = new Set<Id>();
		for(Program_Term__c pt: newRecords)
		{
			if(pt.Parent_Program_Term__c != null)
			{
				parentIds.add(pt.Parent_Program_Term__c);
			}
		}
		Map<Id, Program_Term__c> parentPTs = new Map<Id, Program_Term__c>([SELECT Id, Program__c, Term__c FROM Program_Term__c WHERE Id IN: parentIds]);
		for(Program_Term__c pt: newRecords)
		{
			if(pt.Parent_Program_Term__c != null && (pt.RecordTypeId == poWithDates || pt.RecordTypeId == poWithoutDates))
			{
				pt.Program__c = parentPTs.get(pt.Parent_Program_Term__c).Program__c;
				pt.Term__c = parentPTs.get(pt.Parent_Program_Term__c).Term__c;
			}
		}
		//system.debug('--- assignProgramAndTerm End ---');
	}

	/**
	 * @description Updates the owner of the applications that belong to a program term. Runs in a batches of 20 because of CSP genernation that happens when a application is updated
	 * @param newMap The newly updated program option records
	 * @param oldMap The records before they were updated
	 */
	public static void updateApplicationOwner(Map<Id, Program_Term__c> newMap, Map<Id, Program_Term__c> oldMap)
	{
		List<Id> programTermIds = new List<Id>();
		for(Program_Term__c pt: newMap.values())
		{
			if(pt.OwnerId != oldMap.get(pt.Id).OwnerId)
			{
				programTermIds.add(pt.Id);
			}
		}
		if(!programTermIds.isEmpty())
		{
			string inClause = apexQueryUtility.buildInClause(programTermIds);
			//string query = 'SELECT Id FROM Application__c WHERE Program_Term__c IN ' + inClause;
			applicationOwnerUpdateService updateService = new applicationOwnerUpdateService('SELECT Id FROM Application__c WHERE Program_Term__c IN ' + inClause);
			Id batchId = Database.executeBatch(updateService, 20);
		}
	}
	public static void setDescription(List<Program_Term__c> newRecords)
	{
		//system.debug('setDescription Start ---');
		for(Program_Term__c pt: newRecords)
		{
			pt.Description_Long__c = (pt.Description__c != null && pt.Description_Long__c == null) ? pt.Description__c : pt.Description_Long__c;
		}
		//system.debug('setDescription End ---');
	}
	/**
	 * @description When a CMS record is updated, this process will check the Program_Term__c records for approved dates
	 *		to sync with the CMS record
	 * @param cmsIds The Ids of the updated CMS records
	 */
	@InvocableMethod(label='Update CMS Dates' description='Updates the date fields on CMS__c records')
	public static void updateCMS(List<Id> cmsIds)
	{
		// Get the CMS__c records from the passed in Ids
		List<CMS__c> updatedCMS = [SELECT Id, Spring_Program_Term__c, Summer_Program_Term__c, Fall_Program_Term__c FROM CMS__c WHERE Id IN: cmsIds];
		// Get Program_Term__c Ids from CMS records
		Set<Id> programTermIds = new Set<Id>();
		for(CMS__c cms: updatedCMS)
		{
			if(cms.Spring_Program_Term__c != null) programTermIds.add(cms.Spring_Program_Term__c);
			if(cms.Summer_Program_Term__c != null) programTermIds.add(cms.Summer_Program_Term__c);
			if(cms.Fall_Program_Term__c != null) programTermIds.add(cms.Fall_Program_Term__c);
		}
		// Call updateCMS(programTermIds) to update the CMS__c records' date fields
		if(!programTermIds.isEmpty()) updateCMS(programTermIds);	
	}
	/**
	 * @description Updates the CMS record for the program term's program with the program terms start and end date.
	 * @param newRecords The newly updated program term records
	 */
	public static void updateCMS(Set<Id> ptIds)
	{
		List<Program_Term__c> newRecords = apexQueryUtility.selectAllFrom('Program_Term__c', 'Term__r.Name', 'Id IN ' + apexQueryUtility.buildInClause(ptIds));
		// Get program ids from program terms
		Map<Id, List<Program_Term__c>> programIdProgramTermMap = new Map<Id, List<Program_Term__c>>();
		for(Program_Term__c pt: newRecords)
		{
			if(pt.Date_Approval_Status__c == 'Approved')
			{
				if(!programIdProgramTermMap.containsKey(pt.Program__c))
					programIdProgramTermMap.put(pt.Program__c, new List<Program_Term__c>());
				programIdProgramTermMap.get(pt.Program__c).add(pt);
			}
		}
		// Get CMS__c records for the collected program ids
		Map<Id, List<CMS__c>> programIdCMSMap = new Map<Id, List<CMS__c>>();
		List<CMS__c> cmsRecords = [SELECT Id, Name__c, SF_Program__c, Spring_Program_Term__c, Summer_Program_Term__c, Fall_Program_Term__c FROM CMS__c WHERE SF_Program__c IN: programIdProgramTermMap.keySet()];
		for(CMS__c cms: cmsRecords)
		{
			if(!programIdCMSMap.containsKey(cms.SF_Program__c))
				programIdCMSMap.put(cms.SF_Program__c, new List<CMS__c>());
			programIdCMSMap.get(cms.SF_Program__c).add(cms);
		}
		Map<Id, CMS__c> recordsToUpdate = new Map<Id, CMS__c>();
		for(Id cmsProgramId: programIdCMSMap.keySet())
		{
			for(CMS__c cms: programIdCMSMap.get(cmsProgramId))
			{
				for(Program_Term__c pt: programIdProgramTermMap.get(cmsProgramId))
				{
					if(cms.Spring_Program_Term__c == pt.Id || cms.Summer_Program_Term__c == pt.Id || cms.Fall_Program_Term__c == pt.Id)
					{
						cms = fillInDates(pt, cms);
						recordsToUpdate.put(cms.Id, cms);
					}
				}
				
			}
		}
		Database.update(recordsToUpdate.values());
	}
	private static CMS__c fillInDates(Program_Term__c pt, CMS__c cms)
	{
		if(pt.Term__r.Name.contains('Academic') || pt.Term__r.Name.contains('Calendar'))
		{
			//system.debug('DO NOTHING!');
		}
		// Spring
		else if(pt.Term__r.Name.contains('Spring'))
		{
			cms.Spring_2017_Program_End_Date__c = apexTextUtility.formatDate(pt.End_Date__c);
			cms.SPRING_Program_Start_Date__c = apexTextUtility.formatDate(pt.Start_Date__c);
		}
		// Fall
		else if(pt.Term__r.Name.contains('Fall'))
		{
			cms.Fall_2017_Program_End_Date__c = apexTextUtility.formatDate(pt.End_Date__c);
			cms.Fall_2017_Program_Start_Date__c = apexTextUtility.formatDate(pt.Start_Date__c);
		}
		// Summer
		else if(pt.Term__r.Name.contains('Summer'))
		{
			cms = fillInSummerDates(pt, cms);
		}
		return cms;
	}
	private static CMS__c fillInSummerDates(Program_Term__c pt, CMS__c cms)
	{
		//system.debug(pt.Name);
		// Need to look at what summer session
		if(!pt.Name.contains('Session'))
		{
			cms.Summer_1_Program_End_Date__c = apexTextUtility.formatDate(pt.End_Date__c);
			cms.Summer_1_Program_Start_Date__c = apexTextUtility.formatDate(pt.Start_Date__c);
		}
		else if(pt.Name.contains('Session 1'))
		{
			cms.Summer_1_Program_End_Date__c = apexTextUtility.formatDate(pt.End_Date__c);
			cms.Summer_1_Program_Start_Date__c = apexTextUtility.formatDate(pt.Start_Date__c);
		}
		else if(pt.Name.contains('Sessions 1 & 2'))
		{
			cms.Summer_1_2_Program_End_Date__c = apexTextUtility.formatDate(pt.End_Date__c);
			cms.Summer_1_2_Program_Start_Date__c = apexTextUtility.formatDate(pt.Start_Date__c);
		}
		else if(pt.Name.contains('Sessions 1, 2, & 3'))
		{
			cms.Summer_123_Program_End_Date__c = apexTextUtility.formatDate(pt.End_Date__c);
			cms.Summer_123_Program_Start_Date__c = apexTextUtility.formatDate(pt.Start_Date__c);
		}
		else if(pt.Name.contains('Session 2'))
		{
			cms.Summer_2_Program_Start_Date__c = apexTextUtility.formatDate(pt.End_Date__c);
			cms.Summer_2_Program_Start_Date__c = apexTextUtility.formatDate(pt.Start_Date__c);
		}
		else if(pt.Name.contains('Sessions 2 & 3'))
		{
			cms.Summer_2_3_Program_End_Date__c = apexTextUtility.formatDate(pt.End_Date__c);
			cms.Summer_2_3_Program_Start_Date__c = apexTextUtility.formatDate(pt.Start_Date__c);
		}
		return cms;
	}
	/**
	 * @description On Before Update checks Ready_for_Billing_Checked__c, on After Update processes Program Fees and generates Application Line Items
	 * @param newMap The newly updated program option records
	 * @param oldMap The records before they were updated
	 */
	public static void markReadyToBill(Map<Id, Program_Term__c> newMap, Map<Id, Program_Term__c> oldMap, triggerType tType)
	{
		List<Id> billPtIds = new List<Id>();
		for(Id ptId: newMap.keySet())
		{
			Program_Term__c oldRecord = oldMap.get(ptId);
			Program_Term__c newRecord = newMap.get(ptId);

			if(!oldRecord.Ready_For_Billing__c && newRecord.Ready_For_Billing__c)
			{
				if(tType == triggerType.isBefore)
				{
					// Check "Ready_for_Billing_Checked__c"
					newRecord.Ready_for_Billing_Checked__c = true;	
				}
				else if(tType == triggerType.isAfter)
				{
					// Generate "Application_Line_Item__c records for qualified applications
					billPtIds.add(ptId);
				}
			}
		}
        if(!billPtIds.isEmpty())
        {
         	ifsaLineItemPopulator.populateApplicationLineItems(billPtIds);   
        }
	}
	/**
	 * @description Creates tasks for the PT owner when dates have been approved OR when approved dates have been changed
	 * @param newMap The newly updated program term records
	 * @param oldMap The records before they were updated
	*/
	public static void datesChangedAfterApproved(Map<Id, Program_Term__c> newMap, Map<Id, Program_Term__c> oldMap)
	{
		// Method Setup
		List<Task> dateTasks = new List<Task>();
		Id rtId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Simple Task').getRecordTypeId();
		Id websiteUpdateUserId = [SELECT User_Id__c FROM IFSA_Default_User__mdt WHERE DeveloperName = 'Website_Update'].get(0).User_Id__c;
		// Loop over updated Ids
		for(Id ptID: newMap.keySet())
		{
			// Create vars to hold updated and original record
			Program_Term__c updated = newMap.get(ptID);
			Program_Term__c original = oldMap.get(ptID);
			// Unapproved dates have now been verified - Send PT owner task
			if(original.Date_Approval_Status__c != 'Approved' && updated.Date_Approval_Status__c == 'Approved')
			{
				Task pat = new Task();
				pat.RecordTypeId = rtId;
				pat.Subject = updated.Name + ' - Dates have approved';
				pat.WhatId = updated.Id;
				pat.Type = 'Other';
				pat.ActivityDate = Date.Today().addDays(1);
				pat.Description = 'Program term dates have been approved by PMD';
				pat.OwnerId = updated.OwnerId;
				pat.Status = 'Not Started';
				dateTasks.add(pat);

				// Clone task for user that updates dates on the website
				Task website = pat.clone(false,false,false,false);
				website.OwnerId = websiteUpdateUserId;
				dateTasks.add(website);

			} // Approved Dates have been modified - Send PT owner task
			else if(updated.Date_Approval_Status__c != original.Date_Approval_Status__c && original.Date_Approval_Status__c == 'Approved')
			{
				Task pat = new Task();
				pat.RecordTypeId = rtId;
				pat.Subject = updated.Name + ' - Dates have changed';
				pat.WhatId = updated.Id;
				pat.Type = 'Other';
				pat.ActivityDate = Date.Today().addDays(1);
				pat.Description = 'Changed dates:\r\n';
				pat.OwnerId = updated.OwnerId;
				pat.Status = 'Not Started';
				
				pat.Description = pat.Description + compareDates(original.Start_Date__c, updated.Start_Date__c, Program_Term__c.Start_Date__c.getDescribe());
				pat.Description = pat.Description + compareDates(original.End_Date__c, updated.End_Date__c, Program_Term__c.End_Date__c.getDescribe());
				pat.Description = pat.Description + compareDates(original.Classes_Begin__c, updated.Classes_Begin__c, Program_Term__c.Classes_Begin__c.getDescribe());
				pat.Description = pat.Description + compareDates(original.Classes_End__c, updated.Classes_End__c, Program_Term__c.Classes_End__c.getDescribe());
				pat.Description = pat.Description + compareDates(original.Suggested_Departure_from_U_S__c, updated.Suggested_Departure_from_U_S__c, Program_Term__c.Suggested_Departure_from_U_S__c.getDescribe());
				pat.Description = pat.Description + compareDates(original.IFSA_Orientation_Start_Date__c, updated.IFSA_Orientation_Start_Date__c, Program_Term__c.IFSA_Orientation_Start_Date__c.getDescribe());
				pat.Description = pat.Description + compareDates(original.IFSA_Orientation_End_Date__c, updated.IFSA_Orientation_End_Date__c, Program_Term__c.IFSA_Orientation_End_Date__c.getDescribe());
				pat.Description = pat.Description + compareDates(original.Arrival_Window_Start_Time__c, updated.Arrival_Window_Start_Time__c, Program_Term__c.Arrival_Window_Start_Time__c.getDescribe());
				pat.Description = pat.Description + compareDates(original.Arrival_Window_End_Time__c, updated.Arrival_Window_End_Time__c, Program_Term__c.Arrival_Window_End_Time__c.getDescribe());
				dateTasks.add(pat);

				// Clone task for user that updates dates on the website
				Task website = pat.clone(false,false,false,false);
				website.OwnerId = websiteUpdateUserId;
				dateTasks.add(website);
			}
		}
		// Insert date tasks
		Database.insert(dateTasks);
	}
	/**
	 * @description Compares Date values and concatanates a string with the fields name and the two values
	 * @param prevValue - the date value before the record was updated
	 * @param newValue - the date value after the record was updated
	 * @param field - Schema.DescribeFieldResult representing the field
	 * @return String - concatanated string containing the field name, previous value and current value
	*/
	private static String compareDates(Date prevValue, Date newValue, Schema.DescribeFieldResult field)
	{
		if(newValue != prevValue)
		{
			return field.getLabel() + ' - Previous: ' + prevValue + ' Updated: ' + newValue + '\r\n';
		}
		return '';
	}
	/**
	 * @description Compares String values and concatanates a string with the fields name and the two values
	 * @param prevValue - the string value before the record was updated
	 * @param newValue - the string value after the record was updated
	 * @param field - Schema.DescribeFieldResult representing the field
	 * @return String - concatanated string containing the field name, previous value and current value
	*/
	private static String compareDates(String prevValue, String newValue, Schema.DescribeFieldResult field)
	{
		if(newValue != prevValue)
		{
			return field.getLabel() + ' - Previous: ' + prevValue + ' Updated: ' + newValue + '\r\n';
		}
		return '';
	}

	public static void programRollup(Map<Id, Program_Term__c> oldMap, Map<Id, Program_Term__c> newMap)
	{
		//system.debug(' --- programRollup Start ---');
		// Get record types
		List<Id> recordTypeIds = new List<Id>{
			Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId(),
			Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Parent Program Term with Dates').getRecordTypeId(),
			Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Parent Program Term without Dates').getRecordTypeId()
		};
		
		// Work from old map, if it isn't empty (Will be empty for new or undeleted records)
		Map<Id, Program_Term__c> ptsMap;
		if(oldMap != null) 
		{
			ptsMap = oldMap;
		}
		else
		{
			ptsMap = newMap;
			oldMap = new Map<Id, Program_Term__c>();
		}
		// Get programs for which program terms are being updated
		Set<Id> programIds = new Set<Id>();		
		for(Program_Term__c pt: ptsMap.values())
		{
			programIds.add(pt.Program__c);
		}
		Map<Id, Program__c> programs = new Map<Id, Program__c>([SELECT Id, Number_of_Academic_Year_Program_Terms__c, Number_of_Calendar_Year_Program_Terms__c, Number_of_Fall_Program_Terms__c, Number_of_Spring_Program_Terms__c, Number_of_Summer_Program_Terms__c, Number_of_Winter_Program_Terms__c FROM Program__c WHERE Id IN: programIds]);
		// Get all future program terms for the programs in Set 'programIds'
		List<Program_Term__c> programTerms = [SELECT Id, Name, Program__c, Term__r.Section__c FROM Program_Term__c WHERE Program__c IN: programs.keySet() AND Term__r.Year__c >=: Date.today().year() AND RecordTypeId IN: RecordTypeIds];
		// Create map to hold current Number_of_*_Program_Terms__c values for each program
		// Added by PowerFluence for experimental req 3/29/2022 starts
		System.debug('programTerms '+ programTerms);
		// Added by PowerFluence for experimental req 3/29/2022 ends
		Map<String, Decimal> ptCountMap = new Map<String, Decimal>();
		for(Program__c p: programs.values())
		{
			for(String s: apexConversionUtility.getPicklistStringValues(Term__c.Section__c))
			{
				// We don't care about 'Not Approved' Sections
				if(s != 'Not Approved')
				{
					// Concatenate program Id with Section name, and set value to 0
					ptCountMap.put(p.Id + ',' + s, 0);
				}				
			}
		}
		// Iterate over retreived program terms
		for(Program_Term__c pt: programTerms)
		{
			Decimal value = ptCountMap.get(pt.Program__c + ',' + pt.Term__r.Section__c);
			if(value != null)
			{
				// If a program term is deleted, we need to decrement the value, otherwise we increment
				if(oldMap.containsKey(pt.Id) && !newMap.containsKey(pt.Id))
				{
					value = value - 1;
				}
				else
				{
					value = value + 1;
				}
				ptCountMap.put(pt.Program__c + ',' + pt.Term__r.Section__c, value > 0 ? value : 0);
			}			
		}
		// Populate fields on Program__c record
		for(String s: ptCountMap.keySet())
		{
			String[] values = s.split(',');
			Id programId = values[0];
			string fieldName = 'Number_of_' + values[1].replace(' ', '_') + '_Program_Terms__c';

			programs.get(programId).put(fieldName, ptCountMap.get(s));
		}
		// Update Program__c records
		database.update(programs.values());
		//system.debug('--- programRollup End ---');
	}

	public static List<Country__c> getCountriesForProgramSelector()
	{
		List<Country__c> results = [SELECT Id, Name, Country_Code__c FROM Country__c WHERE Active__c = true AND Id IN (SELECT Country__c FROM Program__c WHERE Active__c = TRUE) AND Name NOT IN ('Undecided','United States','Canada') ORDER BY Name];

		return results;
	}

	@testVisible
	public static List<Term__c> getTermsForProgramSelector(Id countryId)
	{
		Date todayMinus7 = Date.today().addDays(-7);
		List<Term__c> result = new List<Term__c>();
        Set<Id> termIds = new Set<Id>();
        List<Id> ptRecordTypeIds = new List<Id>();
        ptRecordTypeIds.add(Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId());
        ptRecordTypeIds.add(Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Parent Program Term with Dates').getRecordTypeId());
        ptRecordTypeIds.add(Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option with Dates').getRecordTypeId());
        List<String> remainingSections = new List<String>();
        if(Date.today().month() <= 3)
        {
            remainingSections.add('Spring');
            remainingSections.add('Calendar Year');
        }
        if(Date.today().month() <= 5)
        {
            remainingSections.add('Summer');
        }
        if(Date.today().month() <= 8)
        {
            remainingSections.add('Fall');
            remainingSections.add('Academic Year');
        }
        if(Date.today().month() < 11)
        {
            remainingSections.add('Winter');
        }
        List<Program_Term__c> pts = [SELECT Id, Name, Term__c, RecordType.Name, Application_Deadline__c , Parent_Program_Term__r.Application_Deadline__c , Term__r.Year__c, Term__r.Section__c FROM Program_Term__c WHERE Is_Custom__c = FALSE AND Hidden__c = False AND RecordTypeId IN: ptRecordTypeIds AND Program__r.Country__c =: countryId AND ((Application_Deadline__c  >=: todayMinus7 OR Application_Deadline__c  = null) AND (Term__r.Year__c >: Date.today().year() OR (Term__r.Year__c =: Date.today().year() AND Term__r.Section__c IN :remainingSections)) AND Program__r.Active__c = true) ORDER BY Term__r.Year__c, Term__r.Section__c];
        for(Program_Term__c pt: pts)
        {
            termIds.add(pt.Term__c);
        }
        Map<Id, Term__c> terms = new Map<Id, Term__c>([SELECT Id, Name, Display_Name__c FROM Term__c WHERE Id IN: termIds ORDER BY Year__c, Section__c]);
        for(Program_Term__c pt: pts)
        {
            Boolean validTerm = false;
            Term__c t = terms.get(pt.Term__c);
            if(result.indexOf(t) > -1)
            {
                continue;
            }    
            if((pt.Application_Deadline__c  != null && pt.Application_Deadline__c  >= todayMinus7) || (pt.Parent_Program_Term__r.Application_Deadline__c  != null && pt.Parent_Program_Term__r.Application_Deadline__c  >= todayMinus7) ||  (pt.Application_Deadline__c  == null && pt.Term__r.Year__c >= Date.today().year()) || (pt.Parent_Program_Term__r.Application_Deadline__c  == null && pt.Parent_Program_Term__r.Term__r.Year__c >= Date.today().year()))
            {
                result.add(t);
            }
        }
        return result;
	}
	public static List<Program_Term__c> getProgramTermsForProgramSelector(String selectedCountry, String selectedSemester, String homeInstitutionName)
	{
		return getProgramTermsForProgramSelector(selectedCountry, selectedSemester, homeInstitutionName, new List<Id>());
	}
	
	public static List<Program_Term__c> getProgramTermsForProgramSelector(String selectedCountry, String selectedSemester, String homeInstitutionName, List<Id> hiddenIds)
	{
		Date todayMinus7 = Date.today().addDays(-7);
		List<String> pts = new List<String>{'Standard Program Term', 'Parent Program Term with Dates', 'Parent Program Term without Dates'};
        Id homeInstitutionId = null;
        try
        {
            homeInstitutionId = [SELECT Id FROM Home_Institution__c WHERE Name =: homeInstitutionName].get(0).Id;
        }
        catch (Exception ex)
        {
            system.debug('A record for the home institution provided could not be found');
		}
		
		hiddenIds.addAll(getRestrictedProgramTermIds(homeInstitutionId, selectedCountry, selectedSemester));
        //
        List<Program_Term__c> results = new List<Program_Term__c>();
        for(Program_Term__c pt: [
            SELECT Id, Name, Program__r.Name, Country__r.Name, Term__r.Name, Display_Name__c, Description_Long__c, Program__r.Host_Institution__r.Picture_URL__c, RecordType.Name, OwnerId, Application_Deadline__c, Term__r.Year__c, Parent_Program_Term__r.Application_Deadline__c,
                (
                    SELECT Id, Name, Program__r.Name, Country__r.Name, Term__r.Name, Description_Long__c, Parent_Program_Term__r.Application_Deadline__c, Program__r.Host_Institution__r.Picture_URL__c, RecordType.Name, OwnerId, Application_Deadline__c, Term__r.Year__c
					FROM Program_Terms__r
					WHERE Hidden__c = FALSE
                ) 
            FROM Program_Term__c WHERE Program__r.Active__c = true AND Is_Custom__c = FALSE AND Hidden__c = False AND RecordType.Name IN :pts AND Country__c =: selectedCountry AND Term__c =: selectedSemester AND (NOT ID IN : hiddenIds)])
        {
            if(pt.RecordType.Name == 'Parent Program Term without Dates')
            {
                for(Program_Term__c po: pt.Program_Terms__r)
                {
                    if((po.Application_Deadline__c != null && po.Application_Deadline__c >= todayMinus7) || (po.Application_Deadline__c == null && po.Term__r.Year__c >= Date.today().year()))
                    {
                        results.add(pt);
                        break;
                    }
                }
            }
            else if((pt.Application_Deadline__c != null && pt.Application_Deadline__c >= todayMinus7) || (pt.Parent_Program_Term__r.Application_Deadline__c != null && pt.Parent_Program_Term__r.Application_Deadline__c >= todayMinus7) || (pt.Application_Deadline__c == null && pt.Term__r.Year__c >= Date.today().year()) || (pt.Parent_Program_Term__r.Application_Deadline__c == null && pt.Parent_Program_Term__r.Term__r.Year__c >= Date.today().year()))
            {
                results.add(pt);
            }
        }
        return results;
	}

	@TestVisible
    private static List<Id> getRestrictedProgramTermIds(Id homeInstId, String country, String term)
    {
        List<Id> hiddenPTIds = new List<Id>();
        Boolean hasRestrictedProgams = [SELECT Id FROM Restricted_Program__c WHERE Home_Institution__c =: homeInstId AND Program__r.Country__c =: country].size() > 0;
        if(hasRestrictedProgams)
        {   
            List<Restricted_Program__c> restrictedPrograms = [SELECT Id, Name, Home_Institution__c, Program__c, Program_Country__c, Allows_Other_Programs_in_Country__c FROM Restricted_Program__c WHERE Home_Institution__c =: homeInstId AND Program__r.Country__c =: country];
            Boolean allowsOtherPrograms = false;
            List<Id> AllowedPrograms = new List<Id>();
            for(Restricted_Program__c restrictedProgram: restrictedPrograms)
            {
                if(restrictedProgram.Allows_Other_Programs_in_Country__c || allowsOtherPrograms)
                {
                    allowsOtherPrograms = true;
                }
                AllowedPrograms.add(restrictedProgram.Program__c);              
            }
            if(!allowsOtherPrograms)
            {
                
                List<Program_Term__c> programsInCountry = [SELECT Id, Name, Program__c FROM Program_Term__c WHERE Term__c =: term AND Program__r.Country__c =: country AND (NOT Program__c IN: AllowedPrograms)];
                for(Program_Term__c pt : programsInCountry)
                {
                    for(Restricted_Program__c restrictedProgram: restrictedPrograms)
                    {
                        if(restrictedProgram.Program__c != pt.Program__c)
                        {
                            hiddenPTIds.add(pt.Id);
                        }
                    }
                }               
            }
            else
            {
                restrictedPrograms = [SELECT Id, Name, Home_Institution__c, Program__c, Program_Country__c, Allows_Other_Programs_in_Country__c FROM Restricted_Program__c WHERE Program__r.Country__c =: country AND Home_Institution__c !=: homeInstId];
                List<Id> restrictedIdList = new List<Id>();
                for(Restricted_Program__c restrictedProgram: restrictedPrograms)
                {
                    restrictedIdList.add(restrictedProgram.Program__c);
                }
                List<Program_Term__c> programsInCountry = [SELECT Id, Name, Program__c FROM Program_Term__c WHERE Term__c =: term AND Program__c IN: restrictedIdList];
                for(Program_Term__c pt : programsInCountry)
                {
                    hiddenPTIds.add(pt.Id);
                } 
            }   
        }
        else
        {
            List<Restricted_Program__c> restrictedPrograms = [SELECT Id, Name, Home_Institution__c, Program__c, Program_Country__c, Allows_Other_Programs_in_Country__c FROM Restricted_Program__c WHERE Program__r.Country__c =: country];
            List<Id> restrictedIdList = new List<Id>();
            for(Restricted_Program__c restrictedProgram: restrictedPrograms)
            {
                restrictedIdList.add(restrictedProgram.Program__c);
            }
            List<Program_Term__c> programsInCountry = [SELECT Id, Name, Program__c FROM Program_Term__c WHERE Term__c =: term AND Program__c IN: restrictedIdList];
            for(Program_Term__c pt : programsInCountry)
            {
                hiddenPTIds.add(pt.Id);
            } 
        }
        //System.debug(hiddenPTIds);
        return hiddenPTIds;
	}
	public static void updateProgramAvailableSections(List<Program_Term__c> newRecords)
	{
		//system.debug('--- updateProgramAvailableSections Start ---');

		List<Program_Term__c> defaultProgramTerms = [SELECT Term__c, Term__r.Section__c FROM Program_Term__c WHERE Term__r.Section__c = 'Spring' LIMIT 1];
				
		Set<Id> programIds = new Set<Id>();
		Set<Id> termIds = new Set<Id>();
		for(Program_Term__c pt: newRecords)
		{
			programIds.add(pt.Program__c);
			termIds.add(pt.Term__c);
		}

		Map<Id, Program__c> programMap = new Map<Id, Program__c>([SELECT Id, Available_Sections__c FROM Program__c WHERE Id IN: programIds]);
		Map<Id, Term__c> termMap = new Map<Id, Term__c>([SELECT Id, Section__c FROM Term__c WHERE Id IN: termIds]);
		Set<Id> programIdsToUpdate = new Set<Id>();
		for(Program_Term__c pt: newRecords)
		{
			Set<String> aSections = new Set<String>();
			String temp = programMap.get(pt.Program__c)?.Available_Sections__c;
			if(temp != null)
			{
				for(String section: temp.split(';'))
				{
					aSections.add(section);
				}
			}
			if(!aSections?.contains(termMap.get(pt.Term__c).Section__c))
			{
				programIdsToUpdate.add(pt.Program__c);
				programMap.get(pt.Program__c).Available_Sections__c = programMap.get(pt.Program__c).Available_Sections__c + ';' + termMap.get(pt.Term__c).Section__c;
			}
		}

		List<Program__c> programs = new List<Program__c>();
		for(Id programId: programIdsToUpdate)
		{
			Program__c p = programMap.get(programId);
			p.Available_Sections__c = p.Available_Sections__c.replace('null', '');
			programs.add(p);
		}
		Database.update(programs);
		//system.debug('--- updateProgramAvailableSections End ---');
	}
	// Disabled while Academic Programs reaches out to other part of IFSA to talk about application statuses
	/*
	public static void changeRelatedApplicationStatuses(List<Program_Term__c> newRecords, Map<Id, Program_Term__c> oldMap)
	{
		final string PROGRAM_OPERATED = 'Program Operated';
		final string PROGRAM_NOT_OPERATED = 'Program Did Not Operate';
		final string PROGRAM_CANCEL_MID_TERM = 'Program Canceled Mid-Term';

		final string APP_STATUS_NOT_OPERATED = 'Diverted';
		final string APP_STATUS_CANCEL = 'Withdraw';

		final List<String> appStatuses = new List<String>{'Program Selected', 'Ready to Submit', 'Submitted', 'Accepted', 'Accepted (with Conditions)', 'On Site'};

		Map<Id, Program_Term__c> records = new Map<Id, Program_Term__c>();

		for(Program_Term__c pt: newRecords)
		{
			System.debug(pt.Program_Operation_Status__c);
			if(pt.Program_Operation_Status__c != PROGRAM_OPERATED && oldMap.get(pt.Id).Program_Operation_Status__c == PROGRAM_OPERATED)
			{
				records.put(pt.Id, pt);
			}
		}
		if(!records.isEmpty())
		{
			List<Application__c> toUpdate = new List<Application__c>();
			for(List<Application__c> apps : [SELECT Id, Status__c, Program_Term__c, Program_Term__r.Parent_Program_Term__c FROM Application__c WHERE (Program_Term__c IN: records.keySet() OR Program_Term__r.Parent_Program_Term__c IN: records.keySet()) AND Status__c IN: appStatuses])
			{
				for(Application__c app: apps)
				{
					if((app.Program_Term__r.Parent_Program_Term__c != null && records.get(app.Program_Term__r.Parent_Program_Term__c).Program_Operation_Status__c == PROGRAM_NOT_OPERATED) || records.get(app.Program_Term__c).Program_Operation_Status__c == PROGRAM_NOT_OPERATED)
					{
						app.Status__c = APP_STATUS_NOT_OPERATED;
						toUpdate.add(app);
					}
					else if((app.Program_Term__r.Parent_Program_Term__c != null && records.get(app.Program_Term__r.Parent_Program_Term__c).Program_Operation_Status__c == PROGRAM_CANCEL_MID_TERM) || records.get(app.Program_Term__c).Program_Operation_Status__c == PROGRAM_CANCEL_MID_TERM)
					{
						app.Status__c = APP_STATUS_CANCEL;
						toUpdate.add(app);
					}
				}
			}

			if(!toUpdate.isEmpty())
			{
				sObjectBatchUpdater.batchUpdate(toUpdate, 20);
			}
		}
	}
	*/
	public static void deleteRelatedRecords(Map<Id, Program_Term__c> oldMap)
	{
		List<SObject> objectsToDelete = new List<SObject>();
		// Get Application_Requirement__c
		for(Application_Requirement__c ar: [SELECT Id FROM Application_Requirement__c WHERE Program_Term__c IN: oldMap.keySet() OR Program_Term__r.Parent_Program_Term__c IN: oldMap.keySet()])
		{
			objectsToDelete.add(ar);
		}
		// Get Program_Term_Housing_Option__c
		for(Program_Term_Housing_Option__c ptho: [SELECT Id FROM Program_Term_Housing_Option__c WHERE Program_Term__c IN: oldMap.keySet() OR Program_Term__r.Parent_Program_Term__c IN: oldMap.keySet()])
		{
			objectsToDelete.add(ptho);
		}
		// Resource_Item__c
		for(Resource_Item__c ri: [SELECT Id FROM Resource_Item__c WHERE Program_Term__c IN: oldMap.keySet() OR Program_Term__r.Parent_Program_Term__c IN: oldMap.keySet()])
		{
			objectsToDelete.add(ri);
		}
		// Support_Personnel__c
		for(Support_Personnel__c ri: [SELECT Id FROM Support_Personnel__c WHERE Program_Term__c IN: oldMap.keySet() OR Program_Term__r.Parent_Program_Term__c IN: oldMap.keySet()])
		{
			objectsToDelete.add(ri);
		}
		database.delete(objectsToDelete);
	}
} // Class end