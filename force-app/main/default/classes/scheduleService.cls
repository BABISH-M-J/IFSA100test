/**
 * @description Service class for Schedule__c records
 * @author Brock Barlow
 */
public with sharing class scheduleService {
	/**
	* @description Method to generate CSV file of the Schedule__c of a completed Program_Term__C and create a "File (ContentVersion/ContentDocument)" record and link with the Program_Term__c using a ContentDocumentLink record and then delete Schedule records
	*/
	public static void generateCSVandDeleteSchedule(List<Id> programTermIds)
	{
		// Get Schedule__C Records
		//List<Id> programTermIds = new List<Id>{'a0G61000002sK5T'};
		List<Schedule__c> scheduleRecordsToDelete = apexQueryUtility.selectAllFrom('Schedule__c', 'RecordType.Name, Program_Term__r.Name', 'Program_Term__c IN ' + apexQueryUtility.buildInClause(programTermIds));
		// [SELECT id, ownerid, isdeleted, name, currencyisocode, recordtypeid, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate, connectionreceivedid, connectionsentid, 
		// accommodation__c, country__c, description__c, end_date__c, end_time__c, location__c, meal_details__c, meal_included__c, name__c, program_term__c, start_date__c, start_time__c, status__c, 
		// suggested_return_date__c, transportation_details__c, waiver_required__c, RecordType.Name FROM Schedule__c WHERE Program_Term__c IN: programTermIds];
		
		// Create Map of Program Term Id and Schedule Records
		Map<Id, List<Schedule__c>> scheduleMap = new Map<Id, List<Schedule__c>>();
		for(Schedule__c sch: scheduleRecordsToDelete)
		{
			if(!scheduleMap.containsKey(sch.Program_Term__c))
				scheduleMap.put(sch.Program_Term__c, new List<Schedule__c>());
			scheduleMap.get(sch.Program_Term__c).add(sch);
		}
		// Create CSV file for each Program Term
		List<ContentVersion> csvFiles = new List<ContentVersion>();
		for(Id programTermId: scheduleMap.keySet())
		{
			ContentVersion ptSchedules = new ContentVersion();
			// Constant strings used to build csv file
			String newLine = '\r\n';
			String c = ',';
			// Header row of CSV file
			String csv = 'Accommodation__c, Country__c, Description__c, End_Date__c, End_Time__c, Location__c, Meal_Details__c, Meal_Included__c, Name__c, Program_Term__c, RSVP_Details__c, RSVP_Required__c, Start_Date__c, Start_Time__c, Status__c, Suggested_Return_Date__c, Transportation_Details__c, Waiver_Required__c, RecordType.Name, RecordTypeId' + newLine;
			// Data rows of CSV file
			for(Schedule__c sch: scheduleMap.get(programTermId))
			{
				csv = csv + sch.Accommodation__c + c + sch.Country__c + c + sch.Description__c + c + sch.End_Date__c + c + sch.End_Time__c + c + sch.Location__c + c + sch.Meal_Details__c + c + sch.Meal_Included__c + c + sch.Name__c + c + sch.Program_Term__c + c + sch.RSVP_Details__c + c + sch.RSVP_Required__c + c + sch.Start_Date__c + c + sch.Start_Time__c + c + sch.Status__c + c + sch.Suggested_Return_Date__c + c + sch.Transportation_Details__c + c + sch.Waiver_Required__c + c + sch.RecordType.Name + c + sch.RecordTypeId + newLine;
			}
			// Build file Name
			String dayNumber = Date.today().day() > 9 ? Date.today().day().format() : '0' + Date.today().day().format();
			String monthNumber = Date.today().month() > 9 ? Date.today().month().format() : '0' + Date.today().month().format();
			ptSchedules.Title = 'Schedule Backup ' + scheduleMap.get(programTermId).get(0).Program_Term__r.Name+ ' ' + monthNumber + '_' + dayNumber + '_' + Date.today().year();
			// Set Content Version properties
			ptSchedules.PathOnClient = '/'+ptSchedules.Title+'.csv';
			ptSchedules.TagCsv = programTermId;
			ptSchedules.VersionData = Blob.valueOf(csv);
			// Add Content Version to list
			csvFiles.add(ptSchedules);
		}
		Database.insert(csvFiles);
		// Link CSV files to Program Term Records records
		Map<Id, ContentVersion> csvMap = new Map<Id, ContentVersion>(csvFiles);
		csvFiles = [SELECT Id, ContentDocumentId, TagCsv FROM ContentVersion WHERE Id IN: csvMap.keySet()];
		List<ContentDocumentLink> links = new List<ContentDocumentLink>();
		for(ContentVersion file: csvFiles)
		{
			ContentDocumentLink cdl = new ContentDocumentLink();
    		cdl.Id = null;
            system.debug(file.ContentDocumentId);
    		cdl.ContentDocumentId = file.ContentDocumentId;
    		cdl.ShareType = 'V';
    		cdl.LinkedEntityId = file.TagCsv;

    		links.add(cdl);
		}
		database.insert(links);
		// Delete Schedule__c Records
		sObjectBatchUpdater.batchUpdate(scheduleRecordsToDelete, 200, sObjectBatchUpdater.dmlTypes.dmlDelete);
	}
}