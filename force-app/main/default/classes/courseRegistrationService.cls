/**
 * Service class for interacting with Course_Registration__c records and Course_Registration_Grade__c records
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public with sharing class courseRegistrationService 
{
	/**
	 * Method run before update of Course_Registration__c records
	 * @param newMap Map of Id, Course_Registration__c that have been updated
	 * @param oldMap Map of Id, Course_Registration__c before they have been updated
	 */
	public static void gradeEnteredOrChanged(Map<Id, Course_Registration__c> newMap, Map<Id, Course_Registration__c> oldMap)
	{
		for(Id crId: newMap.keySet())
		{
			Course_Registration__c oldRecord = oldMap.get(crId);
			Course_Registration__c newRecord = newMap.get(crId);
			if(newRecord.Final_Grade__c != null && oldRecord.Status__c == 'Grade Submitted' && oldRecord.Final_Grade__c != newRecord.Final_Grade__c)
			{
				newRecord.Status__c = 'Grade Revised';
				newRecord.Changed_After_Submission__c = true;
			}			
			else if(oldRecord.Status__c == 'Approved' && (oldRecord.Final_Grade__c == null && newRecord.Final_Grade__c != null))
			{
				newRecord.Status__c = 'Grade Entered';
				newRecord.Changed_After_Submission__c = false;
			}
			else if((oldRecord.Status__c == 'Grade Entered' || oldRecord.Status__c == 'Grade Verified') && oldRecord.Final_Grade__c != newRecord.Final_Grade__c && newRecord.Final_Grade__c != null)
			{
				newRecord.Status__c = 'Grade Corrected';
			}
		}
	}

	/**
	 * Method run before update of Course_Registration__c records
	 * @param newMap Map of Id, Course_Registration__c that have been updated
	 * @param oldMap Map of Id, Course_Registration__c before they have been updated
	 */
	public static void checkCourseforApprovalOrOmmision(Map<Id, Course_Registration__c> newMap, Map<Id, Course_Registration__c> oldMap)
	{
		for(Id crId: newMap.keySet())
		{
			Course_Registration__c oldRecord = oldMap.get(crId);
			Course_Registration__c newRecord = newMap.get(crId);
			if(oldRecord.Status__c == 'Approval Pending' && newRecord.Is_Approved__c)
			{
				newRecord.Status__c = 'Approved';				
			}			
		}
	}

	/**
	 * Method run after insert of Course_Registration_Grade__c records
	 * @param newRecords List of Course_Registration_Grade__c that have been inserted
	 */
	public static void courseGradeCreated(List<Course_Registration_Grade__c> newRecords)
	{
		List<Id> crIds = new List<Id>();
		for(Course_Registration_Grade__c crg: newRecords)
		{
			crIds.add(crg.Course_Registration__c);
		}
		List<Course_Registration__c> crList = [SELECT Id, Application__c FROM Course_Registration__c WHERE Id IN: crIds];
		List<SObject> sobjects = new List<SObject>();
		Set<Id> appIds = new Set<Id>();
		for(Course_Registration__c cr: crList)
		{			
			cr.Status__c = 'Ready for Butler';
			cr.Changed_After_Submission__c = false;
			sobjects.add(cr);
			appIds.add(cr.Application__c);
		}
		for(Id appId: appIds)
		{
			Application__c app = new Application__c(Id = appId);
			app.Grades_Submitted__c = Date.today();
			sobjects.add(app);
		}
		Database.update(sobjects);
	}
	/**
	 * Marks courses related to a butler grade report as "Grade Submitted"
	 * @param bgrId
	 */
	public static void markCourseSubmitted(String bgrId)
	{
		List<Course_Registration_Grade__c> crgs = [SELECT Id, Course_Registration__c FROM Course_Registration_Grade__c WHERE Butler_Grade_Report__c =: bgrId];		
		List<Course_Registration__c> crs = new List<Course_Registration__c>();
		for(Course_Registration_Grade__c crg: crgs)
		{
			Course_Registration__c cr = new Course_Registration__c(Id = crg.Course_Registration__c);
			cr.Status__c = cr.Status__c =='Ready for Butler' ? 'Grade Submitted' : cr.Status__c;
			crs.add(cr);
		}
		Database.update(crs);
	}

	/**
	 * Method run before update of Course_Registration__c records
	 * @param newRecords List of course registrations that have been updated
	 */
	public static void markOmitted(List<Course_Registration__c> newRecords)
	{
		for(Course_Registration__c cr: newRecords)
		{
			if(cr.Is_Dropped__c == true)
			{
				cr.Status__c = 'Course Omitted';
			}
		}
	}

	/**
	 * Method run from applicationService when grade entered time stamp is filled with a value
	 * @param records List of course registrations that need to be marked grade verified
	 */
	public static void courseRegistrationGradesVerified(List<Course_Registration__c> records)
	{
		for(Course_Registration__c cr: records)
		{
			cr.Status__c = 'Grade Verified';
		}
		Database.update(records);
	}
	/**
	 * Sets Course_Term__c on Course_Registration__c
	 * @param newRecords
	 */
	public static void courseRegistrationEntered(List<Course_Registration__c> newRecords)
	{
		Set<Id> appIds = new Set<Id>();		
		for(Course_Registration__c cr: newRecords)
		{
			appIds.add(cr.Application__c);
		}
		Map<Id, Application__c> apps = new Map<Id, Application__c>([SELECT Id, Status__c, Program_Term__r.Start_Of_Second_Term__c FROM Application__c WHERE Id IN: appIds]);

		for(Course_Registration__c cr: newRecords)
		{
			Application__c app = apps.get(cr.Application__c);
			System.debug(app);

			System.debug('cr.Name => ' + cr.Name);
			System.debug('cr.Status__c => ' + cr.Status__c);
			if(cr.Status__c != null && cr.Status__c.contains('CIF'))
			{
				cr.Created_Via_CIF__c = true;
			}
			else
			{
				cr.Status__c = app.Status__c == 'On Site' && cr.Status__c == 'New' && cr.Is_Approved__c ? 'Approved' : cr.Status__c;				
			}			
			
			if(cr.Course_Term__c == null)
			{
				switch on cr.Program_Term_Section__c {
					when 'Spring', 'Winter' {
						cr.Course_Term__c = 'Spring';
					}
					when 'Fall' {
						cr.Course_Term__c = 'Fall';
					}
					when 'Summer' {
						cr.Course_Term__c = 'Summer';
					}
					when 'Calendar Year' {
						if(app.program_term__r.Start_Of_Second_Term__c > Date.today())
						{
							cr.Course_Term__c = 'Spring';
						}	
						else
						{
							cr.Course_Term__c = 'Fall';
						}					
					}
					when 'Academic Year' {
						if(app.program_term__r.Start_Of_Second_Term__c > Date.today())
						{
							cr.Course_Term__c = 'Fall';
						}
						else
						{
							cr.Course_Term__c = 'Spring';
						}
					}
				}
			}
		}
	}
	/**
	 * Creates new Course__c records for Course_Registration__c that are not linked with one
	 * @param recordIds
	 */
	@future
	public static void createNewCourseRecords(List<Id> recordIds)
	{
		List<Course_Registration__c> newRecords = [SELECT Id, Name, Course__c, Course_Title__c, Host_Institution__c, Host_Credits__c, US_Semester_Credit_Hours__c, Course_Code__c FROM Course_Registration__c WHERE Id IN: (recordIds)];
		Map<Course_Registration__c, Course__c> newCourses = new Map<Course_Registration__c, Course__c>();
		Id HostCourseRTId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Host Institution').getRecordTypeId();
		for(Course_Registration__c cr: newRecords)
		{
			if(cr.Course__c == null)
			{
				Course__c c = new Course__c();
				c.Name = cr.Name;
				c.Course_Title_2__c = cr.Course_Title__c;
				c.Host_Institution__c = cr.Host_Institution__c;
				c.Host_Credits__c = cr.Host_Credits__c;
				//c.US_Semester_Credit_Hours__c = cr.US_Semester_Credit_Hours__c;
				c.Course_Code__c = cr.Course_Code__c;
				c.RecordTypeId = HostCourseRTId;

				newCourses.put(cr, c);
			}
		}

		if(!newCourses.isEmpty())
		{
			Database.SaveResult[] results = Database.insert(newCourses.values(), false);
			for(Course_Registration__c cr : newCourses.keySet())
			{
				if(newCourses.get(cr).Id != null){
					cr.Course__c = newCourses.get(cr).Id;
				}
			}

			System.enqueueJob(new sObjectQueueableUpdater(new List<Course_Registration__c>(newCourses.keySet()), sObjectQueueableUpdater.dmlOperation.isUpdate));
		}
	}
    public static void gradeConversion(List<Course_Registration__c> newRecords)
    {
		// Get Grade Conversion Records
		Map<Id, List<Grade_Conversion__c>> hostInstGradeConversionMap = new Map<Id, List<Grade_Conversion__c>>();
		Set<Id> hostInstitutionIds = new Set<Id>();
		Set<Id> appIds = new Set<Id>();
		Set<Id> gradeConversionIds = new Set<Id>();
		List<Course_Registration__c> gradedRegs = new List<Course_Registration__c>();
		for(Course_Registration__c cr: newRecords)
		{
			if(cr.Host_Institution_Grade__c != null)
			{
				gradedRegs.add(cr);
				hostInstitutionIds.add(cr.Host_Institution__c);
				appIds.add(cr.Application__c);
				if(cr.Grade_Conversion__c != null)
				{
					gradeConversionIds.add(cr.Grade_Conversion__c);
				}
			}

		}
		if(gradedRegs.isEmpty())
		{
			return;
		}
		Map<Id, Grade_Conversion__c> gradeConversions = new Map<Id, Grade_Conversion__c>([SELECT Id, Type__c, Host_Institution__c, Grade_A__c, Grade_A_Minus__c, Grade_B_Plus__c, Grade_B__c, Grade_B_Minus__c, Grade_C_Plus__c, Grade_C__c, Grade_C_Minus__c, Grade_D_Plus__c, Grade_D__c, Grade_D_Minus__c, Grade_F__c, Sections__c FROM Grade_Conversion__c WHERE Id IN: gradeConversionIds]);
		Map<Id, Host_Institution__c> hostInstitutions = new Map<Id, Host_Institution__c>([SELECT Id, Name FROM Host_Institution__c WHERE Id IN: hostInstitutionIds]);
		Map<Id, Application__c> applications = new Map<Id, Application__c>([SELECT Id, Grades_Verified__c FROM Application__c WHERE Id IN: appIds]);
		for(Grade_Conversion__c gr : [SELECT Id, Type__c, Host_Institution__c, Grade_A__c, Grade_A_Minus__c, Grade_B_Plus__c, Grade_B__c, Grade_B_Minus__c, Grade_C_Plus__c, Grade_C__c, Grade_C_Minus__c, Grade_D_Plus__c, Grade_D__c, Grade_D_Minus__c, Grade_F__c, Sections__c, Start_Date__c, End_Date__c FROM Grade_Conversion__c WHERE Host_Institution__c IN: hostInstitutionIds AND Active__c = TRUE])
		//SELECT Id, Type__c, Host_Institution__c, Grade_A__c, Grade_A_Minus__c, Grade_B_Plus__c, Grade_B__c, Grade_B_Minus__c, Grade_C_Plus__c, Grade_C__c, Grade_C_Minus__c, Grade_D_Plus__c, Grade_D__c, Grade_D_Minus__c, Grade_F__c, Sections__c FROM Grade_Conversion__c WHERE Host_Institution__c = 'a0C2h0000014NIr' AND Active__c = TRUE
		{
			if(!hostInstGradeConversionMap.containsKey(gr.Host_Institution__c))
			{
				hostInstGradeConversionMap.put(gr.Host_Institution__c, new List<Grade_Conversion__c>());
			}
			hostInstGradeConversionMap.get(gr.Host_Institution__c).add(gr);
		}
		// Calculate Grade Conversion
        for(Course_Registration__c cr: gradedRegs)
		{
			Application__c app = applications.get(cr.Application__c);
			if(app.Grades_Verified__c == null)
            {
				Grade_Conversion__c gr;
				if(cr.Grade_Conversion__c != null)
				{
					gr = gradeConversions.get(cr.Grade_Conversion__c);
				}
				else if(hostInstGradeConversionMap.containsKey(cr.Host_Institution__c))
				{
					for(Grade_Conversion__c conv: hostInstGradeConversionMap.get(cr.Host_Institution__c))
					{
						Set<String> sections = new Set<String>(conv.Sections__c.split(';'));
						if(sections.contains(cr.Course_Term__c))
						{
							gr = conv;
						}
					}
					if(gr == null)
					{
						String errorMessage = String.format('Could not find Grade_Conversion__c for {0}, {1} term, Ensure that a record exists for the host institution and try again.', new List<Object>{hostInstitutions.get(cr.Host_Institution__c), cr.Course_Term__c});
						throw new courseRegistrationServiceException(errorMessage);
					}
				}
				else
				{
					throw new courseRegistrationServiceException('Could not find Grade_Conversion__c for ' + hostInstitutions.get(cr.Host_Institution__c).Name + ' Ensure that a record exists for the host institution and try again.');
				}
				// Execute conversion
				switch on gr.Type__c {
					when 'Number Range' {
						cr = calculateNumberRangeConversion(cr, gr);		
					}
					when 'Letter Grade' {
						cr = calculateLetterGradeConversion(cr, gr);
					}
					when else {
						throw new courseRegistrationServiceException(gr.Type__c + ' is not yet supported by courseRegistrationService.gradeConversion');
					}
				}
				cr.Grade_Conversion__c = gr.Id;
            }
		}
	}
	
	private static Course_Registration__c calculateNumberRangeConversion(Course_Registration__c cr, Grade_Conversion__c gr)
	{
		final String[] aVals = gr.Grade_A__c != null ? gr.Grade_A__c.remove(' ').split('-') : null;
		final String[] aMinusVals = gr.Grade_A_Minus__c != null ? gr.Grade_A_Minus__c.remove(' ').split('-') : null;
		final String[] bPlusVals = gr.Grade_B_Plus__c != null ? gr.Grade_B_Plus__c.remove(' ').split('-') : null;
		final String[] bVals = gr.Grade_B__c != null ? gr.Grade_B__c.remove(' ').split('-') : null;
		final String[] bMinusVals = gr.Grade_B_Minus__c != null ? gr.Grade_B_Minus__c.remove(' ').split('-') : null;
		final String[] cPlusVals = gr.Grade_C_Plus__c != null ? gr.Grade_C_Plus__c.remove(' ').split('-') : null;
		final String[] cVals = gr.Grade_C__c != null ? gr.Grade_C__c.remove(' ').split('-') : null;
		final String[] cMinusVals = gr.Grade_C_Minus__c != null ? gr.Grade_C_Minus__c.remove(' ').split('-') : null;
		final String[] dPlusVals = gr.Grade_D_Plus__c != null ? gr.Grade_D_Plus__c.remove(' ').split('-') : null;
		final String[] dVals = gr.Grade_D__c != null ? gr.Grade_D__c.remove(' ').split('-') : null;
		final String[] dMinusVals = gr.Grade_D_Minus__c != null ? gr.Grade_D_Minus__c.remove(' ').split('-') : null;
		final String[] fVals = gr.Grade_F__c != null ? gr.Grade_F__c.remove(' ').split('-') : null;
		final Decimal aMin = aVals != null ? Decimal.valueOf(aVals[0]) : null;
		final Decimal aMax = aVals != null ? Decimal.valueOf(aVals[aVals.size()-1]) : null;
		final Decimal aMinusMin = aMinusVals != null ? Decimal.valueOf(aMinusVals[0]) : null;
		final Decimal aMinusMax = aMinusVals != null ? Decimal.valueOf(aMinusVals[aMinusVals.size()-1]) : null;
		final Decimal bPlusMin = bPlusVals != null ? Decimal.valueOf(bPlusVals[0]) : null;
		final Decimal bPlusMax = bPlusVals != null ? Decimal.valueOf(bPlusVals[bPlusVals.size()-1]) : null;
		final Decimal bMin = bVals != null ? Decimal.valueOf(bVals[0]) : null;
		final Decimal bMax = bVals != null ? Decimal.valueOf(bVals[bVals.size()-1]) : null;
		final Decimal bMinusMin = bMinusVals != null ? Decimal.valueOf(bMinusVals[0]) : null;
		final Decimal bMinusMax = bMinusVals != null ? Decimal.valueOf(bMinusVals[bMinusVals.size()-1]) : null;
		final Decimal cPlusMin = cPlusVals != null ? Decimal.valueOf(cPlusVals[0]) : null;
		final Decimal cPlusMax = cPlusVals != null ? Decimal.valueOf(cPlusVals[cPlusVals.size()-1]) : null;
		final Decimal cMin = cVals != null ? Decimal.valueOf(cVals[0]) : null;
		final Decimal cMax = cVals != null ? Decimal.valueOf(cVals[cVals.size()-1]) : null;
		final Decimal cMinusMin = cMinusVals != null ? Decimal.valueOf(cMinusVals[0]) : null;
		final Decimal cMinusMax = cMinusVals != null ? Decimal.valueOf(cMinusVals[cMinusVals.size()-1]) : null;
		final Decimal dPlusMin = dPlusVals != null ? Decimal.valueOf(dPlusVals[0]) : null;
		final Decimal dPlusMax = dPlusVals != null ? Decimal.valueOf(dPlusVals[dPlusVals.size()-1]) : null;
		final Decimal dMin = dVals != null ? Decimal.valueOf(dVals[0]) : null;
		final Decimal dMax = dVals != null ? Decimal.valueOf(dVals[dVals.size()-1]) : null;
		final Decimal dMinusMin = dMinusVals != null ? Decimal.valueOf(dMinusVals[0]) : null;
		final Decimal dMinusMax = dMinusVals != null ? Decimal.valueOf(dMinusVals[dMinusVals.size()-1]) : null;
		final Decimal fMin = fVals != null ? Decimal.valueOf(fVals[0]) : null;
		final Decimal fMax = fVals != null ? Decimal.valueOf(fVals[fVals.size()-1]) : null;

		Decimal grade;
		try {
			grade = Decimal.valueOf(cr.Host_Institution_Grade__c);	
		} catch (TypeException e) {
			// If Host Institution Grade can not be converted to a Decimal type, then
			// the Host Institution Grade will be transfrered to Final Grade
			cr.Final_Grade__c = cr.Host_Institution_Grade__c;
			return cr;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
		}
		
		if(grade >= aMin && grade <= aMax)
		{
			cr.Final_Grade__c = 'A';
		}
		else if(grade >= aMinusMin && grade <= aMinusMax)
		{
			cr.Final_Grade__c = 'A-';
		}
		else if(grade >= bPlusMin && grade <= bPlusMax)
		{
			cr.Final_Grade__c = 'B+';
		}
		else if(grade >= bMin && grade <= bMax)
		{
			cr.Final_Grade__c = 'B';
		}
		else if(grade >= bMinusMin && grade <= bMinusMax)
		{
			cr.Final_Grade__c = 'B-';
		}
		else if(grade >= cPlusMin && grade <= cPlusMax)
		{
			cr.Final_Grade__c = 'C+';
		}
		else if(grade >= cMin && grade <= cMax)
		{
			cr.Final_Grade__c = 'C';
		}
		else if(grade >= cMinusMin && grade <= cMinusMax)
		{
			cr.Final_Grade__c = 'C-';
		}
		else if(grade >= dPlusMin && grade <= dPlusMax)
		{
			cr.Final_Grade__c = 'D+';
		}
		else if(grade >= dMin && grade <= dMax)
		{
			cr.Final_Grade__c = 'D';
		}
		else if(grade >= dMinusMin && grade <= dMinusMax)
		{
			cr.Final_Grade__c = 'D-';
		}
		else if(grade >= fMin && grade <= fMax)
		{
			cr.Final_Grade__c = 'F';
		}

		return cr;
	}

	private static Course_Registration__c calculateLetterGradeConversion(Course_Registration__c cr, Grade_Conversion__c gr)
	{	
		if(gr.Grade_A__c != null){
			for(String g: gr.Grade_A__c.split(','))
			{
				if(cr.Host_Institution_Grade__c == g.trim())
				{
					cr.Final_Grade__c = 'A';
					return cr;
				}
			}
		}
		if(gr.Grade_A_Minus__c != null){
			for(String g: gr.Grade_A_Minus__c.split(','))
			{
				if(cr.Host_Institution_Grade__c == g.trim())
				{
					cr.Final_Grade__c = 'A-';
					return cr;
				}
			}
		}
		if(gr.Grade_B_Plus__c != null){
			for(String g: gr.Grade_B_Plus__c.split(','))
			{
				if(cr.Host_Institution_Grade__c == g.trim())
				{
					cr.Final_Grade__c = 'B+';
					return cr;
				}
			}
		}
		if(gr.Grade_B__c != null){
			for(String g: gr.Grade_B__c.split(','))
			{
				if(cr.Host_Institution_Grade__c == g.trim())
				{
					cr.Final_Grade__c = 'B';
					return cr;
				}
			}
		}
		if(gr.Grade_B_Minus__c != null){
			for(String g: gr.Grade_B_Minus__c.split(','))
			{
				if(cr.Host_Institution_Grade__c == g.trim())
				{
					cr.Final_Grade__c = 'B-';
					return cr;
				}
			}
		}
		if(gr.Grade_C_Plus__c != null){
			for(String g: gr.Grade_C_Plus__c.split(','))
			{
				if(cr.Host_Institution_Grade__c == g.trim())
				{
					cr.Final_Grade__c = 'C+';
					return cr;
				}
			}
		}
		if(gr.Grade_C__c != null){
			for(String g: gr.Grade_C__c.split(','))
			{
				if(cr.Host_Institution_Grade__c == g.trim())
				{
					cr.Final_Grade__c = 'C';
					return cr;
				}
			}
		}
		if(gr.Grade_C_Minus__c != null){
			for(String g: gr.Grade_C_Minus__c.split(','))
			{
				if(cr.Host_Institution_Grade__c == g.trim())
				{
					cr.Final_Grade__c = 'C-';
					return cr;
				}
			}
		}
		if(gr.Grade_D_Plus__c != null){
			for(String g: gr.Grade_D_Plus__c.split(','))
			{
				if(cr.Host_Institution_Grade__c == g.trim())
				{
					cr.Final_Grade__c = 'D+';
					return cr;
				}
			}
		}
		if(gr.Grade_D__c != null){
			for(String g: gr.Grade_D__c.split(','))
			{
				if(cr.Host_Institution_Grade__c == g.trim())
				{
					cr.Final_Grade__c = 'D';
					return cr;
				}
			}
		}
		if(gr.Grade_D_Minus__c != null){
			for(String g: gr.Grade_D_Minus__c.split(','))
			{
				if(cr.Host_Institution_Grade__c == g.trim())
				{
					cr.Final_Grade__c = 'D-';
					return cr;
				}
			}
		}
		if(gr.Grade_F__c != null){
			for(String g: gr.Grade_F__c.split(','))
			{
				if(cr.Host_Institution_Grade__c == g.trim())
				{
					cr.Final_Grade__c = 'F';
					return cr;
				}
			}
		}
		// Any other Host Institution Grade will be transfrered to Final Grade
		cr.Final_Grade__c = cr.Host_Institution_Grade__c;
		return cr;
		//throw new courseRegistrationServiceException(cr.Host_Institution_Grade__c + ' is not yet supported by courseRegistrationService.calculateLetterGradeConversion');
	}

	public class courseRegistrationServiceException extends Exception {}
}