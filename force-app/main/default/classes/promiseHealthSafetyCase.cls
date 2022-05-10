public without sharing class promiseHealthSafetyCase 
{
    public enum CaseTeamLevel {SEVERITY_0, SEVERITY_1, 
        SEVERITY_2_MACRO, SEVERITY_2_STUDENT_NON_HEALTH, SEVERITY_2_STUDENT_HEALTH, SEVERITY_2_STUDENT_NON_HEALTH_SENSITIVE, SEVERITY_2_STUDENT_HEALTH_SENSITIVE,
        SEVERITY_3_MACRO, SEVERITY_3_STUDENT_NON_HEALTH, SEVERITY_3_STUDENT_HEALTH, SEVERITY_3_STUDENT_NON_HEALTH_SENSITIVE, SEVERITY_3_STUDENT_HEALTH_SENSITIVE
    }
    private enum CampaignType {ON_SITE, TRAVELING, PROGRAM_COMPLETED, PRE_ARRIVAL}
    
    public static final Set<Id> dynamicGroupCases = new Set<Id>{
        Schema.SObjectType.Case.getRecordTypeInfosByName().get('City Incident').getRecordTypeId(),
        Schema.SObjectType.Case.getRecordTypeInfosByName().get('Country Incident').getRecordTypeId(),		
        Schema.SObjectType.Case.getRecordTypeInfosByName().get('Program Incident').getRecordTypeId()
    };

    public static final String ACADEMIC_TEAM = 'Academic Support Team';
    public static final String HSS_TEAM = 'Health Safety Team';
    public static final String EXEC_TEAM_S2_MACRO = 'Executive Team S2 Macro';
    public static final String EXEC_TEAM_S2_S3_STUDENT = 'Executive Team S2, S3 Student';
    public static final String EXEC_TEAM_S3_MACRO = 'Executive Team S3 Macro';
    public static final String FIELD_DIRECTORS = 'Field Directors';
    public static final String CUSTOM_PROGRAM_MGMT = 'Custom Programs Management';
    
    public promiseHealthSafetyCase(Case c) 
    {
        System.debug('Creating new promiseHealthSafetyCase object');
        if(!Test.isRunningTest()){
            new Promise(new findAffectedLocations())
            .then(new findAffectedStudents())
            .then(new generateCaseTeam())
            .then(new createCampaign())
            .error(new insertIncidentPromiseError())
            .done(new insertIncidentPromiseDone())
            .execute(c);
        }

        // Also run if test
        if(Test.isRunningTest()){
            new Promise(new findAffectedLocations())
            .then(new findAffectedStudents())
            .then(new generateCaseTeam())
            .then(new createCampaign())
            .error(new insertIncidentPromiseError())
            .done(new insertIncidentPromiseDone())
            .execute(c);
        }

    }

    public virtual class casePromiseBase
    {
        @TestVisible
        private Case c;
        private Exception e;

        public virtual void checkInput(Object incomingObject)
        {
            system.debug('casePromiseBase - checkInput - incomingObject' + incomingObject);
            // Ensure incoming object is not null
            if(incomingObject == null)
            {
                throw new NullPointerException();
            }
            // Ensure incoming object is a Case
            if(incomingObject instanceOf Case)
            {
                c = (Case) incomingObject;
            }
            else if (incomingObject instanceOf Exception)
            {
                e = (Exception) incomingObject;
            }
            else
            {
                System.debug('A different object was supplied and cannot be cast to Case or Exception');
                throw new IllegalArgumentException('A different object was supplied and cannot be cast to Case or Exception');
            }
        }
    }

    public class findAffectedLocations extends casePromiseBase implements Promise.Deferred 
    {   
        public object resolve(Object incomingObject)
        {
            super.checkInput(incomingObject);
            // If case record type is not in dynamicGroupCases set allow further processing to continue
            if(!promiseHealthSafetyCase.dynamicGroupCases.contains(c.RecordTypeId))
            {
                return c;
            }
            try
            {
                Set<Id> existingAeIds = new Set<Id>();
                for(List<Affected_Entity__c> existingAEs: [SELECT Id, Country__c, Locality__c, Program__c, RecordType.Name FROM Affected_Entity__c WHERE Case__c =: c.Id AND RecordType.Name != 'Student'])
                {
                    for(Affected_Entity__c ae: existingAEs)
                    {
                        switch on ae.RecordType.Name {
                            when 'City' {
                                existingAeIds.add(ae.Locality__c);
                            }
                            when 'Country' {
                                existingAeIds.add(ae.Country__c);
                            }
                            when 'Program'{
                                existingAeIds.add(ae.Program__c);
                            }
                        }
                    }
                }
                // Otherwise we need to find out what locations are affected by this case and create junctions records
                List<Affected_Entity__c> recordsToInsert = new List<Affected_Entity__c>();
                // City Case
                if(c.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('City Incident').getRecordTypeId())
                {
                    List<String> affectedCities = c.Affected_Cities__c.split(';');
                    for(Locality__c record: [SELECT Id FROM Locality__c WHERE Name IN: affectedCities AND RecordType.Name = 'City/Town' AND Country__r.Active__c = TRUE])
                    {
                        if(!existingAeIds.contains(record.Id))
                        {
                            recordsToInsert.add(new Affected_Entity__c(
                                RecordTypeId = Schema.SObjectType.Affected_Entity__c.getRecordTypeInfosByName().get('City').getRecordTypeId(),
                                Locality__c = record.Id,
                                Case__c = c.Id
                            ));
                        }
                    }
                }
                else if(c.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Country Incident').getRecordTypeId())
                {
                    List<String> affectedCountries = c.Affected_Countries__c.split(';');
                    for(Country__c record: [SELECT Id FROM Country__c WHERE Name IN: affectedCountries AND Active__c = TRUE])
                    {
                        if(!existingAeIds.contains(record.Id))
                        {
                                recordsToInsert.add(new Affected_Entity__c(
                                RecordTypeId = Schema.SObjectType.Affected_Entity__c.getRecordTypeInfosByName().get('Country').getRecordTypeId(),
                                Country__c = record.Id,
                                Case__c = c.Id
                            ));
                        }
                    }
                }
                else if(c.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Program Incident').getRecordTypeId())
                {
                    List<String> affectedPrograms = c.Affected_Programs__c.split(';');
                    for(Program__c record: [SELECT Id FROM Program__c WHERE Name IN: affectedPrograms AND Active__c = TRUE])
                    {
                        if(!existingAeIds.contains(record.Id))
                        {
                            recordsToInsert.add(new Affected_Entity__c(
                                RecordTypeId = Schema.SObjectType.Affected_Entity__c.getRecordTypeInfosByName().get('Program').getRecordTypeId(),
                                Program__c = record.Id,
                                Case__c = c.Id
                            ));
                        }
                    }
                }
                if(recordsToInsert.isEmpty() && existingAeIds.isEmpty())
                {
                    throw new promiseHealthSafetyCaseException('No affected entities', c);
                }
                if(!recordsToInsert.isEmpty()){
                    database.insert(recordsToInsert);
                }
                return c;
            }
            catch (Exception e)
            {
                if(e instanceOf promiseHealthSafetyCaseException)
                {
                    throw e;
                }
                else
                {
                    throw new promiseHealthSafetyCaseException('An unexpected error has occured processing affected locations', c, e);
                }
            }
        }
    }

    public class findAffectedStudents extends casePromiseBase implements Promise.Deferred 
    {
        Set<Id> studentIds;
        public object resolve(Object incomingObject)
        {
            super.checkInput(incomingObject);
            try
            {
                system.debug('--- findAffectedStudents start ---');
                Map<String, Id> aeRecordTypes = new Map<String, Id>();
                aeRecordTypes.put('City', Schema.SObjectType.Affected_Entity__c.getRecordTypeInfosByName().get('City').getRecordTypeId());
                aeRecordTypes.put('Country', Schema.SObjectType.Affected_Entity__c.getRecordTypeInfosByName().get('Country').getRecordTypeId());
                aeRecordTypes.put('Program', Schema.SObjectType.Affected_Entity__c.getRecordTypeInfosByName().get('Program').getRecordTypeId());
                aeRecordTypes.put('Student', Schema.SObjectType.Affected_Entity__c.getRecordTypeInfosByName().get('Student').getRecordTypeId());
                
                Set<Id> countryIds = new Set<Id>();
                Set<Id> localityIds = new Set<Id>();
                Set<Id> programIds = new Set<Id>();
                studentIds = new Set<Id>();
                for(List<Affected_Entity__c> affectedEntities: [SELECT Id, RecordTypeId, RecordType.Name, Country__c, Locality__c, Program__c, Student__c FROM Affected_Entity__c WHERE Case__c =: c.Id AND RecordTypeId IN: aeRecordTypes.values()])
                {
                    for(Affected_Entity__c ae: affectedEntities)
                    {
                        switch on ae.RecordType.Name {
                            when 'City' {
                                localityIds.add(ae.Locality__c);
                            }
                            when 'Country' {
                                countryIds.add(ae.Country__c);
                            }
                            when 'Program' {
                                programIds.add(ae.Program__c);
                            }
                            when 'Student' {
                                studentIds.add(ae.Student__c);
                            }
                        }
                    }
                }
                system.debug('localityIds: ' + localityIds.size());
                system.debug('countryIds: ' + countryIds.size());
                system.debug('programIds: ' + programIds.size());
                system.debug('studentIds: ' + studentIds.size());

                List<Affected_Entity__c> affectedStudents = new List<Affected_Entity__c>();
                if(promiseHealthSafetyCase.dynamicGroupCases.contains(c.RecordTypeId))
                {
                    if(countryIds.isEmpty() && localityIds.isEmpty() && programIds.isEmpty())             
                    {
                        throw new promiseHealthSafetyCaseException('No affected entities', c);
                    }
                    if(!countryIds.isEmpty())
                    {
                        if(!c.Case_Initiated_Pre_Arrival__c)
                        {
                            affectedStudents.addAll(getAffectedStudents([SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c FROM Application__c WHERE Program_Term__r.Program__r.Country__c IN: countryIds AND (Status__c = 'On Site' OR (Status__c = 'Program Completed' AND (Program_Term__r.End_Date__c >= LAST_N_DAYS:7 OR Program_Term__r.Parent_Program_Term__r.End_Date__c >= LAST_N_DAYS:7)) OR (Status__c IN ('Accepted (with Conditions)', 'Accepted') AND (Program_Term__r.Start_Date__c <= LAST_N_DAYS:3 OR Program_Term__r.Parent_Program_Term__r.Start_Date__c <= LAST_N_DAYS:3) ))], c));
                        }
                        else
                        {
                            affectedStudents.addAll(getAffectedStudents([SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c FROM Application__c WHERE Program_Term__r.Program__r.Country__c IN: countryIds AND Status__c IN ('Accepted', 'Accepted (with Conditions)') AND Status_Contract_Signed__c != NULL AND Program_Term_Start_Date__c = NEXT_N_DAYS:30], c));
                        }
                    }
                    if(!localityIds.isEmpty())
                    {
                        if(!c.Case_Initiated_Pre_Arrival__c)
                        {
                            affectedStudents.addAll(getAffectedStudents([SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c FROM Application__c WHERE Program_Term__r.Program__r.Locality__c IN: localityIds AND (Status__c = 'On Site' OR (Status__c = 'Program Completed' AND (Program_Term__r.End_Date__c >= LAST_N_DAYS:7 OR Program_Term__r.Parent_Program_Term__r.End_Date__c >= LAST_N_DAYS:7)) OR (Status__c IN ('Accepted (with Conditions)', 'Accepted') AND (Program_Term__r.Start_Date__c <= LAST_N_DAYS:3 OR Program_Term__r.Parent_Program_Term__r.Start_Date__c <= LAST_N_DAYS:3) ))], c));
                        }
                        else
                        {
                            affectedStudents.addAll(getAffectedStudents([SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c FROM Application__c WHERE Program_Term__r.Program__r.Locality__c IN: localityIds AND Status__c IN ('Accepted', 'Accepted (with Conditions)') AND Status_Contract_Signed__c != NULL AND Program_Term_Start_Date__c = NEXT_N_DAYS:30], c));
                        }
                    }
                    if(!programIds.isEmpty())
                    {
                        if(!c.Case_Initiated_Pre_Arrival__c)
                        {
                            affectedStudents.addAll(getAffectedStudents([SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c FROM Application__c WHERE Program_Term__r.Program__c IN: programIds AND (Status__c = 'On Site' OR (Status__c = 'Program Completed' AND (Program_Term__r.End_Date__c >= LAST_N_DAYS:7 OR Program_Term__r.Parent_Program_Term__r.End_Date__c >= LAST_N_DAYS:7)) OR (Status__c IN ('Accepted (with Conditions)', 'Accepted') AND (Program_Term__r.Start_Date__c <= LAST_N_DAYS:3 OR Program_Term__r.Parent_Program_Term__r.Start_Date__c <= LAST_N_DAYS:3) ))], c));
                        }
                        else
                        {
                            affectedStudents.addAll(getAffectedStudents([SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c FROM Application__c WHERE Program_Term__r.Program__c IN: programIds AND Status__c IN ('Accepted', 'Accepted (with Conditions)') AND Status_Contract_Signed__c != NULL AND Program_Term_Start_Date__c = NEXT_N_DAYS:30], c));
                        }
                    }
                }
                else if(c.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Global Incident').getRecordTypeId())
                {
                    affectedStudents.addAll(getAffectedStudents([SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c, /*Is_www__c,*/ Program_Country__c FROM Application__c WHERE (Status__c = 'On Site' OR (Status__c = 'Program Completed' AND (Program_Term__r.End_Date__c >= LAST_N_DAYS:7 OR Program_Term__r.Parent_Program_Term__r.End_Date__c >= LAST_N_DAYS:7)) OR (Status__c IN ('Accepted (with Conditions)', 'Accepted') AND (Program_Term__r.Start_Date__c >= LAST_N_DAYS:3 OR Program_Term__r.Parent_Program_Term__r.Start_Date__c >= LAST_N_DAYS:3) ))], c));
                }
                else if(c.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Student Incident').getRecordTypeId() && !c.Case_Initiated_Pre_Arrival__c)
                {
                    affectedStudents.addAll(getAffectedStudents([SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c, Is_Custom__c FROM Application__c WHERE Applicant__c =: c.Student__c AND (Status__c IN ('On Site', 'Program Completed') OR (Status__c IN ('Accepted', 'Accepted (with Conditions)') )) ORDER BY Status_Program_Completed__c], c));
                }
                else if(c.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Student Incident').getRecordTypeId() && c.Case_Initiated_Pre_Arrival__c)
                {
                    affectedStudents.addAll(getAffectedStudents([SELECT Id, Applicant__c, Status__c, Applicant__r.Traveling_Status__c, Is_Custom__c FROM Application__c WHERE Applicant__c =: c.Student__c AND Status__c IN ('Program Selected', 'Ready To Submit', 'Submitted', 'Accepted', 'Deceased', 'Accepted (with Conditions)') ORDER BY Status_Program_Completed__c], c));
                }
                if(affectedStudents.isEmpty() && studentIds.isEmpty())             
                {
                    throw new promiseHealthSafetyCaseException('No related students', c);
                }
                database.insert(affectedStudents);
                Map<Id, Affected_Entity__c> affectedStudentsMap = new Map<Id, Affected_Entity__c>(affectedStudents);
                Case theCase = new Case(Id = c.Id);
                for(List<Affected_Entity__c> affectedStudentsList: [SELECT Id, Reason_Affected__c, Application__r.Is_Custom__c FROM Affected_Entity__c WHERE Id IN: affectedStudentsMap.keyset()])
                {
                    for(Affected_Entity__c ae: affectedStudentsList)
                    {
                        system.debug('Before Has Custom Students => ' + theCase.Has_Custom_Students__c);
                        theCase.Has_Catalog_Students__c = theCase.Has_Catalog_Students__c || !ae.Application__r.Is_Custom__c;
                        theCase.Has_Custom_Students__c = theCase.Has_Custom_Students__c || ae.Application__r.Is_Custom__c;
                        theCase.Has_Pre_Arrival_Students__c = theCase.Has_Pre_Arrival_Students__c || ae.Reason_Affected__c == 'Pre-Arrival';
                        theCase.Has_On_Site_Students__c = theCase.Has_On_Site_Students__c || ae.Reason_Affected__c == 'On Site';
                        theCase.Has_Traveling_Students__c = theCase.Has_Traveling_Students__c || ae.Reason_Affected__c == 'Traveling';
                        theCase.Has_Program_Completed_Students__c = theCase.Has_Program_Completed_Students__c || ae.Reason_Affected__c == 'Program Completed';
                        system.debug('After Has Custom Students => ' + theCase.Has_Custom_Students__c);
                    }
                }
                BaseTriggerHandler.bypass('caseTriggerHandler');
                database.update(theCase);
                BaseTriggerHandler.clearBypass('caseTriggerHandler');
                system.debug('--- findAffectedStudents end ---');
                return c;
            }
            catch (Exception e)
            {
                if(e instanceOf promiseHealthSafetyCaseException)
                {
                    throw e;
                }
                else
                {
                    throw new promiseHealthSafetyCaseException('An unexpected error has occured processing affected students', c, e);
                }
            }
        }

        private List<Affected_Entity__c> getAffectedStudents(List<Application__c> apps, Case newCase)
	    {
            List<Affected_Entity__c> newRecords = new List<Affected_Entity__c>();
            if(apps.isEmpty())
            {
                System.debug(LoggingLevel.WARN, 'getAffectedStudents did not receive any applications');
                return newRecords;
            }            
            for(Application__c app: apps)
            {
                if(studentIds.contains(app.Applicant__c)){
                    System.debug(LoggingLevel.WARN, 'This Case already has an Affected_Entity__c record for this student');
                    continue;
                }
                Affected_Entity__c ae = new Affected_Entity__c();
            
                ae.Student__c = app.Applicant__c;
                ae.Application__c = app.Id;
                ae.Case__c = newCase.Id;
                ae.RecordTypeId = Schema.SObjectType.Affected_Entity__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
                
                if(app.Applicant__r.Traveling_Status__c != 'Not Traveling')
                {
                    ae.Reason_Affected__c = 'Traveling';
                }
                else if(app.Status__c == 'Program Completed')
                {
                    ae.Reason_Affected__c = 'Program Completed';
                }
                else if(newCase.Case_Initiated_Pre_Arrival__c)
                {
                    ae.Reason_Affected__c = 'Pre-Arrival';
                }
                else
                {
                    ae.Reason_Affected__c = 'On Site';
                }
                newRecords.add(ae);
            }
		    return newRecords;
	    }
    }

    public class generateCaseTeam extends casePromiseBase implements Promise.Deferred 
    {
        public object resolve(Object incomingObject)
        {
            super.checkInput(incomingObject);
            try
            {
                system.debug('--- generateCaseTeam start ---');
                CaseTeamLevel ctLevel;
                Id GlobalCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Global Incident').getRecordTypeId();
                Id StudentCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Student Incident').getRecordTypeId();
                // Determine Case Team Level
                switch on c.Severity__c {
                    when 'Level 0 Incident' {
                        ctLevel = CaseTeamLevel.SEVERITY_0;
                    }
                    when 'Level 1 Incident' {
                        ctLevel = CaseTeamLevel.SEVERITY_1;
                    }
                    when 'Level 2 Incident' {
                        if(c.RecordTypeId == StudentCaseRT && c.Category__c.contains('Health') && (c.Title_IX__c || c.Sensitive_Case__c == 'Yes'))
                        {
                            ctLevel = CaseTeamLevel.SEVERITY_2_STUDENT_HEALTH_SENSITIVE;
                        }
                        else if(c.RecordTypeId == StudentCaseRT && !c.Category__c.contains('Health') && (c.Title_IX__c || c.Sensitive_Case__c == 'Yes'))
                        {
                            ctLevel = CaseTeamLevel.SEVERITY_2_STUDENT_NON_HEALTH_SENSITIVE;
                        }
                        // Added else here
                        else if(c.RecordTypeId == StudentCaseRT && c.Category__c.contains('Health') && !(c.Title_IX__c || c.Sensitive_Case__c == 'Yes'))
                        {
                            ctLevel = CaseTeamLevel.SEVERITY_2_STUDENT_HEALTH;
                        }
                        else if(c.RecordTypeId == StudentCaseRT && !c.Category__c.contains('Health') && !(c.Title_IX__c || c.Sensitive_Case__c == 'Yes'))
                        {
                            ctLevel = CaseTeamLevel.SEVERITY_2_STUDENT_NON_HEALTH;
                        }
                        else
                        {
                            ctLevel = CaseTeamLevel.SEVERITY_2_MACRO;
                        }
                    }
                    when 'Level 3 Incident' {
                        if(c.RecordTypeId == StudentCaseRT && c.Category__c.contains('Health') && (c.Title_IX__c || c.Sensitive_Case__c == 'Yes'))
                        {
                            ctLevel = CaseTeamLevel.SEVERITY_3_STUDENT_HEALTH_SENSITIVE;
                        }
                        else if(c.RecordTypeId == StudentCaseRT && !c.Category__c.contains('Health') && (c.Title_IX__c || c.Sensitive_Case__c == 'Yes'))
                        {
                            ctLevel = CaseTeamLevel.SEVERITY_3_STUDENT_NON_HEALTH_SENSITIVE;
                        }
                        // Added else here
                        else if(c.RecordTypeId == StudentCaseRT && c.Category__c.contains('Health') && !(c.Title_IX__c || c.Sensitive_Case__c == 'Yes'))
                        {
                            ctLevel = CaseTeamLevel.SEVERITY_3_STUDENT_HEALTH;
                        }
                        else if(c.RecordTypeId == StudentCaseRT && !c.Category__c.contains('Health') && !(c.Title_IX__c || c.Sensitive_Case__c == 'Yes'))
                        {
                            ctLevel = CaseTeamLevel.SEVERITY_3_STUDENT_NON_HEALTH;
                        }
                        else
                        {
                            ctLevel = CaseTeamLevel.SEVERITY_3_MACRO;
                        }
                    }
                    when else {
                        throw new promiseHealthSafetyCaseException('Invalid Case Severity', c);
                    }
                }

                //Map<Id, Country__c> countries = new Map<Id, Country__c>([SELECT Id, Name FROM Country__c WHERE Active__c = TRUE]);
                //system.debug(countries);
                Set<Id> caseTeamMemberIds = new Set<Id>();
                Set<String> addedGroups = new Set<String>();
                for(List<Affected_Entity__c> affectedStudents: [SELECT Id, Student__c, Application__c, Application__r.Program_Country__c, Application__r.Program_Term__r.Country__r.Regional_Director__c FROM Affected_Entity__c WHERE Case__c =: c.Id AND RecordType.Name = 'Student'])
                {
                    for(Affected_Entity__c ae: affectedStudents)
                    {
                        system.debug('generateCaseTeam ae: ' + ae);
                        String countryName = ae.Application__r.Program_Country__c;
                        String groupName;
                        //System.debug(ctLevel);
                        switch on ctLevel {
                            when SEVERITY_0 { //Country Team, HSS Team
                                groupName = countryName + ' Support';
                                // Add Country Team
                                if(!addedGroups.contains(groupName))
                                {
                                    addedGroups.add(groupName);
                                }
                                // Add Academic Team
                                if(c.Category__c == 'Academic' && !addedGroups.contains(ACADEMIC_TEAM))
                                {
                                    addedGroups.add(ACADEMIC_TEAM);
                                }
                                // Add HSS Team
                                else if(c.Category__c != 'Academic' && !addedGroups.contains(HSS_TEAM))
                                {
                                    addedGroups.add(HSS_TEAM);
                                }
                            }
                            when SEVERITY_1 { //Regional Director, Country Team, HSS Team
                                groupName = countryName + ' Support';
                                // Add Country Team
                                if(!addedGroups.contains(groupName))
                                {
                                    addedGroups.add(groupName);
                                }
                                // Add Academic Team
                                if(c.Category__c == 'Academic' && !addedGroups.contains(ACADEMIC_TEAM))
                                {
                                    addedGroups.add(ACADEMIC_TEAM);
                                }
                                // Add HSS Team
                                else if(c.Category__c != 'Academic' && !addedGroups.contains(HSS_TEAM))
                                {
                                    addedGroups.add(HSS_TEAM);
                                }
                                // Add Regional Director
                                caseTeamMemberIds.add(ae.Application__r.Program_Term__r.Country__r.Regional_Director__c);
                            }
                            when SEVERITY_2_MACRO { // Regional Director, Country Team, HSS Team, Field Directors, Exec Team (Vicky, MT, HBH)
                                groupName = countryName + ' Support';
                                // Add Country Team
                                if(!addedGroups.contains(groupName))
                                {
                                    addedGroups.add(groupName);
                                }
                                // Add Academic Team
                                if(c.Category__c == 'Academic' && !addedGroups.contains(ACADEMIC_TEAM))
                                {
                                    addedGroups.add(ACADEMIC_TEAM);
                                }
                                // Add HSS Team
                                else if(c.Category__c != 'Academic' && !addedGroups.contains(HSS_TEAM))
                                {
                                    addedGroups.add(HSS_TEAM);
                                }
                                // Add Field Directors
                                if(!addedGroups.contains(FIELD_DIRECTORS))
                                {
                                    addedGroups.add(FIELD_DIRECTORS);
                                }
                                // Add Exec Team
                                if(!addedGroups.contains(EXEC_TEAM_S2_MACRO))
                                {
                                    addedGroups.add(EXEC_TEAM_S2_MACRO);
                                }
                                // Add Regional Director
                                caseTeamMemberIds.add(ae.Application__r.Program_Term__r.Country__r.Regional_Director__c);
                            }
                            when SEVERITY_2_STUDENT_NON_HEALTH { // Regional Director, Country Team, HSS Team, Field Directors, Exec Team (Vicky, MT)
                                groupName = countryName + ' Support';
                                // Add Country Team
                                if(!addedGroups.contains(groupName))
                                {
                                    addedGroups.add(groupName);
                                }
                                // Add Academic Team
                                if(c.Category__c == 'Academic' && !addedGroups.contains(ACADEMIC_TEAM))
                                {
                                    addedGroups.add(ACADEMIC_TEAM);
                                }
                                // Add HSS Team
                                else if(c.Category__c != 'Academic' && !addedGroups.contains(HSS_TEAM))
                                {
                                    addedGroups.add(HSS_TEAM);
                                }
                                // Add Field Directors
                                if(!addedGroups.contains(FIELD_DIRECTORS))
                                {
                                    addedGroups.add(FIELD_DIRECTORS);
                                }
                                // Add Exec Team
                                if(!addedGroups.contains(EXEC_TEAM_S2_S3_STUDENT))
                                {
                                    addedGroups.add(EXEC_TEAM_S2_S3_STUDENT);
                                }
                                // Add Regional Director
                                caseTeamMemberIds.add(ae.Application__r.Program_Term__r.Country__r.Regional_Director__c);
                            }
                            when SEVERITY_2_STUDENT_HEALTH { // Regional Director, Country Team, HSS Team 
                                groupName = countryName + ' Support';
                                // Add Country Team
                                if(!addedGroups.contains(groupName))
                                {
                                    addedGroups.add(groupName);
                                }
                                // Add HSS Team
                                if(!addedGroups.contains(HSS_TEAM))
                                {
                                    addedGroups.add(HSS_TEAM);
                                }
                                // Add Regional Director
                                caseTeamMemberIds.add(ae.Application__r.Program_Term__r.Country__r.Regional_Director__c);
                                System.debug('generateCaseTeams - addedGroups: ' + addedGroups);
                            }
                            when SEVERITY_2_STUDENT_NON_HEALTH_SENSITIVE, SEVERITY_2_STUDENT_HEALTH_SENSITIVE, SEVERITY_3_STUDENT_NON_HEALTH_SENSITIVE  { // HSS team, Regional Director
                                // Add Academic Team
                                if(c.Category__c == 'Academic' && !addedGroups.contains(ACADEMIC_TEAM))
                                {
                                    addedGroups.add(ACADEMIC_TEAM);
                                }
                                // Add HSS Team
                                else if(c.Category__c != 'Academic' && !addedGroups.contains(HSS_TEAM))
                                {
                                    addedGroups.add(HSS_TEAM);
                                }
                                // Add Regional Director
                                caseTeamMemberIds.add(ae.Application__r.Program_Term__r.Country__r.Regional_Director__c);
                            }
                            when SEVERITY_3_MACRO { // Regional Director, Country Team, HSS Team, Field Directors, Exec Team (Vicky, MT, HBH, EH)
                                groupName = countryName + ' Support';
                                // Add Country Team
                                if(!addedGroups.contains(groupName))
                                {
                                    addedGroups.add(groupName);
                                }
                                // Add Academic Team
                                if(c.Category__c == 'Academic' && !addedGroups.contains(ACADEMIC_TEAM))
                                {
                                    addedGroups.add(ACADEMIC_TEAM);
                                }
                                // Add HSS Team
                                else if(c.Category__c != 'Academic' && !addedGroups.contains(HSS_TEAM))
                                {
                                    addedGroups.add(HSS_TEAM);
                                }
                                // Add Exec Team
                                if(!addedGroups.contains(EXEC_TEAM_S3_MACRO))
                                {
                                    addedGroups.add(EXEC_TEAM_S3_MACRO);
                                }
                                // Add Regional Director
                                caseTeamMemberIds.add(ae.Application__r.Program_Term__r.Country__r.Regional_Director__c);
                            }
                            when SEVERITY_3_STUDENT_NON_HEALTH, SEVERITY_3_STUDENT_HEALTH { // Regional Director, Country Team, HSS Team, Field Directors, Exec Team - Vicky, MT
                                groupName = countryName + ' Support';
                                // Add Country Team
                                if(!addedGroups.contains(groupName))
                                {
                                    addedGroups.add(groupName);
                                }
                                // Add Academic Team
                                if(c.Category__c == 'Academic' && !addedGroups.contains(ACADEMIC_TEAM))
                                {
                                    addedGroups.add(ACADEMIC_TEAM);
                                }
                                // Add HSS Team
                                else if(c.Category__c != 'Academic' && !addedGroups.contains(HSS_TEAM))
                                {
                                    addedGroups.add(HSS_TEAM);
                                }
                                // Add Exec Team
                                if(!addedGroups.contains(EXEC_TEAM_S2_S3_STUDENT))
                                {
                                    addedGroups.add(EXEC_TEAM_S2_S3_STUDENT);
                                }
                                // Add Regional Director
                                caseTeamMemberIds.add(ae.Application__r.Program_Term__r.Country__r.Regional_Director__c);
                            }
                        }
                    }
                }

                system.debug('--- c.Has_Custom_Students__c => ' + c.Has_Custom_Students__c + ' ---');
                if(c.Has_Custom_Students__c){
                    addedGroups.add(CUSTOM_PROGRAM_MGMT);
                    system.debug('--- Added CUSTOM_PROGRAM_MGMT group ---');
                }
                
                Set<Id> existingCaseTeamMembers = new Set<Id>();
                for(CaseTeamMember ctm: [SELECT MemberId FROM CaseTeamMember WHERE ParentId =: c.Id])
                {
                    existingCaseTeamMembers.add(ctm.MemberId);
                }
                System.debug('addedGroups: ' + addedGroups);
                for(Group g: [SELECT Id FROM Group WHERE Name IN: addedGroups])
                {
                    caseTeamMemberIds.addAll(GetUserIdsFromGroup(g.Id));    
                }            
                Map<String, CaseTeamRole> roleMap = new Map<String, CaseTeamRole>();
                for(CaseTeamRole role: [SELECT Id, Name FROM CaseTeamRole])
                {
                    roleMap.put(role.Name, role);
                }
                Map<Id, CaseTeamMember> members = new Map<Id, CaseTeamMember>();
                List<EntitySubscription> subscriptions = new List <EntitySubscription>();
                List<EntitySubscription> existingSubs = [SELECT Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentId =: c.Id LIMIT 200];		
                Set<Id> existingSubsriberIds = new Set<Id>();
                for(EntitySubscription es: existingSubs)
                {
                    existingSubsriberIds.add(es.SubscriberId);
                }
                for(List<User> caseTeamUsers: [SELECT Id, Incident_Management_Case_Team_Role__c FROM User WHERE (Id IN: caseTeamMemberIds OR Id =: UserInfo.getUserId()) AND IsActive = TRUE])
                {
                    for(User u: caseTeamUsers)
                    {
                        if(c.Status != 'Closed')
                        {
                            // Make the case team member follow the case in Chatter if the do not already
                            if(!existingSubsriberIds.contains(u.Id))
                            {							
                                subscriptions.add(new EntitySubscription(ParentId = c.Id, SubscriberId = u.Id));
                                existingSubsriberIds.add(u.Id);
                            }
                        }
                        if(existingCaseTeamMembers.contains(u.Id))
                        {
                            continue;
                        }
                        CaseTeamMember ctm = new CaseTeamMember();
                        ctm.ParentId = c.Id;
                        ctm.MemberId = u.Id;					
                        ctm.TeamRoleId = u.Incident_Management_Case_Team_Role__c != null ? roleMap.get(u.Incident_Management_Case_Team_Role__c).Id : roleMap.get('Other').Id;
                        members.put(u.Id, ctm);
                    }
                }
                if(members.isEmpty() && existingCaseTeamMembers.isEmpty())
                {
                    throw new promiseHealthSafetyCaseException('No Case Team Members', c);
                }
                if(!members.isEmpty()){
                    database.insert(members.values());
                    Case theCase = new Case(Id = c.Id, Case_Team_Added__c = true);

                    BaseTriggerHandler.bypass('caseTriggerHandler');
                    database.update(theCase);
                    BaseTriggerHandler.clearBypass('caseTriggerHandler');
                }
                if(!subscriptions.isEmpty())
                {
                    database.insert(subscriptions);
                }
                if(c.Status == 'Closed')
                {
                    database.delete([SELECT Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentId =: c.Id]);
                }
                system.debug('--- generateCaseTeam end ---');
                return c;
            }
            catch (Exception e)
            {
                if(e instanceOf promiseHealthSafetyCaseException)
                {
                    throw e;
                }
                else
                {
                    throw new promiseHealthSafetyCaseException('An unexpected error has occured processing case team', c, e);
                }
            }
        }

        private Set<id> GetUserIdsFromGroup(Id groupId)
        {
            // store the results in a set so we don't get duplicates
            Set<Id> result=new Set<Id>();
            String userType = Schema.SObjectType.User.getKeyPrefix();
            String groupType = Schema.SObjectType.Group.getKeyPrefix();

            // Loop through all group members in a group
            for (GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId = :groupId])
            {
                // If the user or group id is a user
                if (((String)m.UserOrGroupId).startsWith(userType))
                {
                    result.add(m.UserOrGroupId);
                }
                // If the user or group id is a group
                // Note: there may be a problem with governor limits if this is called too many times
                else if (((String)m.UserOrGroupId).startsWith(groupType))
                {
                    // Call this function again but pass in the group found within this group
                    result.addAll(GetUSerIdsFromGroup(m.UserOrGroupId));
                }
            }

            return result;  
        }
    }

    public class createCampaign extends casePromiseBase implements Promise.Deferred 
    {
        private Campaign baseCampaign;
        private Map<String, Campaign> campaigns;
        private Map<Id, Affected_Entity__c> students;
        private Map<Id, List<Contact_Support_Personnel__c>> eContacts;
        // Ths Set will be a concatenated string of the campaign key and the contact id
        private Map<String, CampaignMember> newCampaignMembers;
        private Map<String, CampaignMember> existingCampaignMembers;
        
        public object resolve(Object incomingObject)
        {
            // Boilerplate code
            super.checkInput(incomingObject);
            try
            {
                // Ensure that we have the most recent version of the case
                c = (Case) apexQueryUtility.selectAllFrom('Case', '(SELECT Id FROM Campaigns__r)', 'Id =\'' + c.Id + '\'').get(0);
                // Ensure campaigns need to be created
                if(c.Create_Campaigns_YN__c == 'No'){
                    return c;
                }
                // Create the base campaign
                createBaseCampaign();
                // Create the child campaigns
                createChildCampaigns();
                // Get the students
                getAffectedStudents();
                // Get the student's emergency contacts
                getEmergencyContacts(students.keySet());
                // Check for existing Campaign Members
                getExistingCampaignMembers();
                // Add CampaignMembers to Campaigns
                addCampaignMembers(c);

                return c;
            }
            catch (Exception e)
            {
                if(e instanceOf promiseHealthSafetyCaseException)
                {
                    throw e;
                }
                else
                {
                    throw new promiseHealthSafetyCaseException('An unexpected error has occured processing campaigns', c, e);
                }
            }
        }
        /**
         * @description Creates the campaign record that relates to the case and other campaigns will relate to this campaign.
         */
        private void createBaseCampaign()
        {
            
            if(c.Campaigns__r.isEmpty())
            {
                baseCampaign = new Campaign(Name = 'Health & Safety Case ' + c.CaseNumber, Case__c = c.Id, Type = 'Case Campaign', RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Health & Safety Campaign').getRecordTypeId());
                Database.insert(baseCampaign);
            }
            else
            {
                baseCampaign = [SELECT Id, Name, Case__c, Type, RecordTypeId, RecordType.Name, (SELECT Id, Name, Case__c, Type, RecordTypeId, RecordType.Name, Program_Type__c, Contact_Status__c FROM ChildCampaigns) FROM Campaign WHERE Id =: c.Campaigns__r.get(0).Id];
            }
        }
        /**
         * @description Creates child campaign records for each bucket of students and emergency contacts based on program type and application status
         */
        private void createChildCampaigns()
        {
            campaigns = new Map<String, Campaign>();
            Boolean hasOnSite = false;
            Boolean hasTraveling = false;
            Boolean hasProgCompleted = false;
            Boolean hasPreArrival = false;
            // Check for existing campaigns
            if(baseCampaign.ChildCampaigns != null && !baseCampaign.ChildCampaigns.isEmpty())
            {
                for(Campaign childCampaign: baseCampaign.ChildCampaigns)
                {
                    String recipient;
                    if(childCampaign.Name.contains('Student'))
                    {
                        recipient = 'Student';
                    }
                    if(childCampaign.Name.contains('Emergency Contact'))
                    {
                        recipient = 'Emergency Contact';
                    }
                    if(childCampaign.Name.contains('Home Institution'))
                    {
                        recipient = 'Home Institution';
                    }
                    // Build the key
                    String key = String.format('{0} {1} {2}', new List<Object>{childCampaign.Program_Type__c, recipient, childCampaign.Contact_Status__c});
                    // Put campaign in map with key
                    campaigns.put(key, childCampaign);
                    // Set flags so that duplicate campaign types are not created
                    hasOnSite = hasOnSite == true || childCampaign.Contact_Status__c == 'On Site';
                    hasTraveling = hasTraveling == true || childCampaign.Contact_Status__c == 'Traveling';
                    hasProgCompleted = hasProgCompleted == true || childCampaign.Contact_Status__c == 'Program Completed';
                    hasPreArrival = hasPreArrival == true || childCampaign.Contact_Status__c == 'Pre-Arrival';
                }
            }
            for(String field: new List<String>{'Has_Pre_Arrival_Students__c','Has_On_Site_Students__c','Has_Traveling_Students__c','Has_Program_Completed_Students__c'})
            {
                Boolean value = (Boolean) c.get(field);
                if(value)
                {
                    switch on field {
                        when 'Has_On_Site_Students__c'{
                            if(!hasOnSite)
                            {
                                createChildCampaigns(promiseHealthSafetyCase.CampaignType.ON_SITE);
                            }
                        }
                        when 'Has_Traveling_Students__c'{
                            if(!hasTraveling)
                            {
                                createChildCampaigns(promiseHealthSafetyCase.CampaignType.TRAVELING);
                            }
                        }
                        when 'Has_Program_Completed_Students__c'{
                            if(!hasProgCompleted)
                            {
                                createChildCampaigns(promiseHealthSafetyCase.CampaignType.PROGRAM_COMPLETED);
                            }
                        }
                        when 'Has_Pre_Arrival_Students__c'{
                            if(!hasPreArrival)
                            {
                                createChildCampaigns(promiseHealthSafetyCase.CampaignType.PRE_ARRIVAL);
                            }
                        }
                        when else {
                            System.debug(LoggingLevel.WARN, 'Field Name "' + field + '" is not supported, add the condition to promiseHealthSafetyCases.createCampaign.createChildCampaigns()');
                        }
                    }
                }
            }
            database.upsert(campaigns.values());
        }
        /**
         * @description Creates a specific set of campaigns baseed on the CampaignType
         * @parm CampaignType - Determines which campaign to build
         */
        private void createChildCampaigns(promiseHealthSafetyCase.CampaignType cType)
        {
            String nameTemplate = '{0} {1} {2}';
            String contactStatus;
            switch on cType {
                when ON_SITE{
                    contactStatus = 'On Site';
                }
                when TRAVELING{
                    contactStatus = 'Traveling';
                }
                when PROGRAM_COMPLETED{
                    contactStatus = 'Program Completed';
                }
                when PRE_ARRIVAL{
                    contactStatus = 'Pre-Arrival';
                }
                when else {
                    System.debug(LoggingLevel.WARN, 'CampaignType "' + cType.name() + '" is not supported, add the condition to promiseHealthSafetyCases.createCampaign.createChildCampaigns(CampaignType cType)');
                }
            }
            Campaign StuCampaign = new Campaign(ParentId = baseCampaign.Id, Type = 'Affected Student Campaign', Contact_Status__c = contactStatus);
            Campaign ParGarCampaign = new Campaign(ParentId = baseCampaign.Id, Type = 'Affected Student Emergency Contact Campaign', Contact_Status__c = contactStatus);
            Campaign HomeInstCampaign = new Campaign(ParentId = baseCampaign.Id, Type = 'Affected Home Institution Emergency Contact Campaign', Contact_Status__c = contactStatus);
            
            if(c.Has_Catalog_Students__c)
            {
                Campaign catStuCampaign = StuCampaign.clone(false, false, false, false);
                catStuCampaign.Program_Type__c = 'Catalog';
                catStuCampaign.Name = String.format(nameTemplate, new List<Object>{contactStatus, catStuCampaign.Program_Type__c, catStuCampaign.Type.replace('Affected ', '')});
                campaigns.put(String.format('{0} Student {1}', new List<Object>{catStuCampaign.Program_Type__c, contactStatus}), catStuCampaign);
                Campaign catParGarCampaign = ParGarCampaign.clone(false, false, false, false);
                catParGarCampaign.Program_Type__c = 'Catalog';
                catParGarCampaign.Name = String.format(nameTemplate, new List<Object>{contactStatus, catParGarCampaign.Program_Type__c, catParGarCampaign.Type.replace('Affected ', '')});
                campaigns.put(String.format('{0} Emergency Contact {1}', new List<Object>{catParGarCampaign.Program_Type__c, contactStatus}), catParGarCampaign);
                Campaign catHomeInstCampaign = HomeInstCampaign.clone(false, false, false, false);
                catHomeInstCampaign.Program_Type__c = 'Catalog';
                catHomeInstCampaign.Name = String.format(nameTemplate, new List<Object>{contactStatus, catHomeInstCampaign.Program_Type__c, catHomeInstCampaign.Type.replace('Affected ', '')});
                campaigns.put(String.format('{0} Home Institution {1}', new List<Object>{catHomeInstCampaign.Program_Type__c, contactStatus}), catHomeInstCampaign);
                
            }
            // TEST FOR CUSTOM STUDENTS
            System.debug('TEST Has_Custom_Students => ' + c.Has_Custom_Students__c);
            if(c.Has_Custom_Students__c)
            {
                Campaign custStuCampaign = StuCampaign.clone(false, false, false, false);
                custStuCampaign.Program_Type__c = 'Custom';
                custStuCampaign.Name = String.format(nameTemplate, new List<Object>{contactStatus, custStuCampaign.Program_Type__c, custStuCampaign.Type.replace('Affected ', '')});
                campaigns.put(String.format('{0} Student {1}', new List<Object>{custStuCampaign.Program_Type__c, contactStatus}), custStuCampaign);
                Campaign custParGarCampaign = ParGarCampaign.clone(false, false, false, false);
                custParGarCampaign.Program_Type__c = 'Custom';
                custParGarCampaign.Name = String.format(nameTemplate, new List<Object>{contactStatus, custParGarCampaign.Program_Type__c, custParGarCampaign.Type.replace('Affected ', '')});
                campaigns.put(String.format('{0} Emergency Contact {1}', new List<Object>{custParGarCampaign.Program_Type__c, contactStatus}), custParGarCampaign);
                Campaign custHomeInstCampaign = HomeInstCampaign.clone(false, false, false, false);
                custHomeInstCampaign.Program_Type__c = 'Custom';
                custHomeInstCampaign.Name = String.format(nameTemplate, new List<Object>{contactStatus, custHomeInstCampaign.Program_Type__c, custHomeInstCampaign.Type.replace('Affected ', '')});
                campaigns.put(String.format('{0} Home Institution {1}', new List<Object>{custHomeInstCampaign.Program_Type__c, contactStatus}), custHomeInstCampaign);
            }
        }
        /**
         * @description Gets the Student Affected Entities for the Case
         */
        private void getAffectedStudents()
        {
            students = new Map<Id, Affected_Entity__c>();
            for(List<Affected_Entity__c> affectedStudents: [SELECT Id, Reason_Affected__c, Student__c, Student__r.Host_Institution__r.Account__c, Application__r.Is_Custom__c FROM Affected_Entity__c WHERE Case__c =: c.Id AND RecordType.Name = 'Student'])
            {
                for(Affected_Entity__c ae: affectedStudents)
                {
                    students.put(ae.Student__c, ae);
                }
            }
        }
        /**
         * @description Gets the emergency contacts for the supplied students
         * @param Set<Id> The Contact Ids for the affected Students
         */
        private void getEmergencyContacts(Set<Id> studentIds)
        {
            eContacts = new Map<Id, List<Contact_Support_Personnel__c>>();

            for(List<Contact_Support_Personnel__c> cspRecords: [SELECT Id, Support_Personnel__r.Non_IFSA_Staff__c, Contact__c, Support_Personnel__c, Support_Personnel__r.RecordType.Name FROM Contact_Support_Personnel__c WHERE Contact__c IN: studentIds AND Support_Personnel__r.Type__c = 'Non IFSA Staff' AND Support_Personnel__r.RecordType.Name IN ('Account', 'Contact', 'Program Term')])
            {
                for(Contact_Support_Personnel__c csp: cspRecords)
                {
                    if(!eContacts.containsKey(csp.Contact__c))
                    {
                        eContacts.put(csp.Contact__c, new List<Contact_Support_Personnel__c>());
                    }
                    eContacts.get(csp.Contact__c).add(csp);
                }
            }
        }
        /**
         * @description Finds existing campaign member records for this case
         */
        private void getExistingCampaignMembers()
        {
            existingCampaignMembers = new Map<String,CampaignMember>();
            Map<Id, String> campaignIds = new Map<Id, String>();
            for(String key: campaigns.keySet())
            {
                system.debug('existingCampaignMembers value: ' + campaigns.get(key));
                if(campaigns.get(key).Id != null)
                {
                    campaignIds.put(campaigns.get(key).Id, key);
                }
            }
            String key;
            for(List<CampaignMember> members: [SELECT Id, ContactId, CampaignId FROM CampaignMember WHERE CampaignId IN: campaignIds.keySet()])
            {
                for(CampaignMember cm: members)
                {
                    existingCampaignMembers.put(cm.ContactId + '_' + campaignIds.get(cm.CampaignId), cm);
                }
            }
        }
        /**
         * @description Adds members to the different Campaigns
         */
        private void addCampaignMembers(Case c)
        {
            newCampaignMembers = new Map<String,CampaignMember>();
            for(Id studentId: students.keySet())
            {
                Affected_Entity__c ae = students.get(studentId);

                List<Contact_Support_Personnel__c> cspRecords = eContacts.get(ae.Student__c);
                
                String programType = ae.Application__r.Is_Custom__c ? 'Custom' : 'Catalog';
                String status = ae.Reason_Affected__c;
                String studentKey = String.format('{0} Student {1}', new List<Object>{programType, status});
                if(verifyAndAddMemberToCampaign(ae.Student__c, studentKey) && cspRecords != null && !cspRecords.isEmpty())
                {
                    for(Contact_Support_Personnel__c csp: cspRecords)
                    {
                        CampaignMember m = new CampaignMember(ContactId = csp.Support_Personnel__r.Non_IFSA_Staff__c);
                        switch on csp.Support_Personnel__r.RecordType.Name {
                            when 'Contact' {
                                verifyAndAddMemberToCampaign(csp.Support_Personnel__r.Non_IFSA_Staff__c, String.format('{0} Emergency Contact {1}', new List<Object>{programType, status}));
                            }
                            when 'Account', 'Program Term'{
                                verifyAndAddMemberToCampaign(csp.Support_Personnel__r.Non_IFSA_Staff__c, String.format('{0} Home Institution {1}', new List<Object>{programType, status}));
                            }
                            when else {
                                System.debug(LoggingLevel.WARN, 'Support_Personnel__c RecordType "' + csp.Support_Personnel__r.RecordType.Name + '" is not supported, add the condition to promiseHealthSafetyCases.createCampaign.addCampaignMember(Affected_Entity__c ae, Boolean isCustom)');
                            }
                        }
                    }
                }
            }
            if(newCampaignMembers.isEmpty() && existingCampaignMembers.isEmpty())
            {
                throw new promiseHealthSafetyCaseException('No Campaign Members', c);
            }
            // Insert new records
            database.insert(newCampaignMembers.values());
        }
        /**
         * @description Checks map to ensure that a contact Id with a campaign key only exists once.
         */
        private Boolean verifyAndAddMemberToCampaign(Id contactId, String campaignKey)
        {
            if(contactId != null && !newCampaignMembers.containsKey(contactId + '_' + campaignKey) && !existingCampaignMembers.containsKey(contactId + '_' + campaignKey))
            {
                CampaignMember cm = new CampaignMember(ContactId = contactId, CampaignId = campaigns.get(campaignKey).Id);
                newCampaignMembers.put(contactId + '_' + campaignKey, cm);
                return true;
            }
            return false;
        }
    }

    public class insertIncidentPromiseDone extends casePromiseBase implements Promise.Done
    {
        private string completed;
        public insertIncidentPromiseDone() {

        }

        public void done(Object incomingObject)
        {
            super.checkInput(incomingObject);
            completed = 'completed';
        }
    }

    public class insertIncidentPromiseError implements Promise.Error
    {
        @TestVisible
        private String errorMessage;

        public insertIncidentPromiseError() {}
        // This is the main interface method that you must implement
        // note that it does have a return type, and in this case I'm using the
        // promise.serializableData type. This will pass the 'error occured' string to the done handler
        public Object error(Exception e) {
            //for now, just dump it to the logs
            system.debug('Error Handler received the following exception ' + e.getmessage() + '\n\n' + e.getStackTraceString());
            //Make the error available for testing.
            this.errorMessage = e.getMessage();
            //Alternatively, you could do any number of things with this exception like:
            // 1. retry the promise chain. For instance, if an external service returns a temp error, retry
            // 1a. Use the flow control object to cap the retry's
            // 2. log the error to a UI friendly reporting object or audit log
            // 3. Email the error report, and related objects to the affected users
            // 4. post something to chatter.
            IFSA_Default_Amount__mdt sendEmail = [SELECT Amount__c FROM IFSA_Default_Amount__mdt WHERE DeveloperName = 'Send_Promise_Emails'].get(0);
            
            if(sendEmail.Amount__c == 1)
            {
                string message = '<p>There has been an error in promiseHealthSafetyCase.</p> <br/><br/> <p>' + UserInfo.getName() + '</p> <p>' + e.getMessage() + '</p> <br/><br/> <p>' + e.getStackTraceString() + '</p>';
                if(e instanceOf promiseHealthSafetyCaseException)
                {
                    Exception baseException = e.getCause();
                    message = message + 'Base Exception: <br /> ' + e.getMessage() + ' <br />';
                    promiseHealthSafetyCaseException pHSCException = (promiseHealthSafetyCaseException) e;
                    message = message + 'Case Information: <br/> ' + pHSCException.getBasicCaseInfo();
                }
                apexEmailUtility.sendGeneralEmail('promiseHealthSafetyCase has failed', message, new List<Id>{[SELECT User_Id__c FROM IFSA_Default_User__mdt WHERE DeveloperName = 'Apex_Errors'].get(0).User_Id__c}, false, null, null);
            }
    
            return e;
        }
    }

    public class promiseHealthSafetyCaseException extends Exception
    {
        private Case caseRecord;
        public promiseHealthSafetyCaseException(String message, Case c) {
            this(message);
            caseRecord = c;
        }
        public promiseHealthSafetyCaseException(String message, Case c, Exception e) {
            this(message, e);
            caseRecord = c;
        }
        public Id getCaseId()
        {
            return caseRecord.Id;
        }
        public String getBasicCaseInfo()
        {
            List<String> fields = new List<String>{'Id', 'CaseNumber', 'Severity__c', 'Subject', 'Category__c', 'Sub_Category__c'};
            String caseInfo = '<br />';
            for(String fieldName: fields)
            {
                caseInfo = caseInfo + fieldName + ': ' + caseRecord.get(fieldName) + '<br />';
            }
            return caseInfo;
        }
    }
}