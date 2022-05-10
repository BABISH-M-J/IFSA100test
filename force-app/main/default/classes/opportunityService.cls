/**
 * Service class for the Opportunity object. This class contains the business logic that is called by <<opportunityTriggerHandler>>, <<opportunityCityTriggerHandler>> and <<opportunityCountryTriggerHandler>>
 * @author Brock Barlow
 */
public without sharing class opportunityService 
{
    public enum ErrorType 
    {
        MISSING_PA,
        MISSING_FD,
        MISSING_RD,
        MISSING_COUNTRY,
        MISSING_CITY    
    }
    public class opportunityServiceException extends Exception 
    {
        public opportunityServiceException(ErrorType et, String message)
        {
            switch on et {
                when MISSING_PA {
                    message = 'Missing value for required field "Program Advisor". Be sure that "Program Advisor" is populated before marking this opportunity as ' + CLOSED_WON_CUSTOM + '. ' + message;
                }
                when MISSING_FD{
                    message = 'Missing value for required field "Field Director". Be sure that "Field Director" is populated before marking this opportunity as ' + CLOSED_WON_CUSTOM + '. ' + message;
                }
                when MISSING_RD{
                    message = 'Missing value for required field "Resident Director". Be sure that "Resident Director" is populated before marking this opportunity as ' + CLOSED_WON_CUSTOM + '. ' + message;
                }
                when MISSING_COUNTRY{
                    message = 'Missing value for required field "Starting Country". Be sure that "Starting Country" is populated before marking this opportunity as ' + CLOSED_WON_CUSTOM + '. ' + message;
                }
                when MISSING_CITY{
                    message = 'Missing value for required field "Starting City". Be sure that "Starting City" is populated before marking this opportunity as ' + CLOSED_WON_CUSTOM + '. ' + message;
                }
            }
            this.setMessage(message);
        }
    } // Class opportunityServiceException end

    // Create constants
    static final String CUSTOM_PROPOSAL_ACCEPTANCE = 'Proposal Accepted';
    static final String CUSTOM_DRAFT_AGREEMENT = 'Sent Agreement';
    static final String CLOSED_WON_CUSTOM = 'Proposal Accepted';
    static final String CLOSED_WON_CATALOG = 'Program Approved';
    static final DateTime CLOSED_WON_DATETIME = Datetime.now();
    static final String PROG_OP_DID_NOT_OPERATE = 'Program Did Not Operate';
    static final String PROG_DID_NOT_OPERATE_NO_ENROLL = 'Did not enroll';

    /**
     * Update the ammount value on opportunity records used by Custom Programs
     * @param newRecords List<Opportunity> new records from <<opportunityTriggerHandler>>
     */
    public static void updateAmmount(List<Opportunity> newRecords) 
    {
        //system.debug('--- opportunityService updateAmmount Start ---');
        // Create set of Opportunity custom record type Ids
        Set<Id> customRTS = new Set<Id>{Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Custom Program (New)').getRecordTypeId(), Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Custom Program (Repeat)').getRecordTypeId()};
        // Loop through Opportunity records in newRecords and if their record types are in the customRTS set, set Amount if appropriate fields have values over zero.
        for(Opportunity opp: newRecords)
        {
            if(customRTS.contains(opp.RecordTypeId))
            {
                if(opp.Final_Enrollment_Formula__c > 0 && opp.Profit__c > 0)
                {
                    opp.Amount = opp.Final_Enrollment_Formula__c * opp.Profit__c;
                }
                else if(opp.Projected_Enrollment__c > 0 && opp.Profit__c > 0)
                {
                    opp.Amount = opp.Projected_Enrollment__c * opp.Profit__c;
                }
            }
        }
        //system.debug('--- opportunityService updateAmmount End ---');
    }
    /**
     * Update the ammount value on opportunity records used by Custom Programs
     * @param newRecords List<Opportunity> new records from <<opportunityTriggerHandler>>
     * @param oldMap Map<Id, Opportunity> old records in a Map from <<opportunityTriggerHandler>>
     */
    public static void checkIfOpportunityIsWon(List<Opportunity> newRecords, Map<Id, Opportunity> oldMap)
    {
        //system.debug('--- opportunityService checkIfOpportunityIsWon Start ---');
        // Custom
        final Id customNewRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Custom Program (New)').getRecordTypeId();
        final Id customRepeatRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Custom Program (Repeat)').getRecordTypeId();
        // Catalog
        final Id catalogRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Program Approval').getRecordTypeId();
        // Affiliation Approval
        final Id affiliationRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Affiliation Agreement').getRecordTypeId();


        List<Opportunity> customOpps = new List<Opportunity>();
        List<Opportunity> catalogOpps = new List<Opportunity>();
        List<Opportunity> noEnrollOpps = new List<Opportunity>();

        for(Opportunity newOpp: newRecords)
        {
            Opportunity oldOpp = oldMap.get(newOpp.Id);
            if(newOpp.RecordTypeId == customNewRT || newOpp.RecordTypeId == customRepeatRT)
            {
                if(oldOpp.StageName != CLOSED_WON_CUSTOM && newOpp.StageName == CLOSED_WON_CUSTOM)
                {
                    customOpps.add(newOpp);
                }
                else if(oldOpp.Program_Operation_Status2__c	!= PROG_OP_DID_NOT_OPERATE && newOpp.Program_Operation_Status2__c == PROG_OP_DID_NOT_OPERATE && newOpp.Program_Did_Not_Operate_Status__c == PROG_DID_NOT_OPERATE_NO_ENROLL)
                // else if(oldOpp.Program_Operation_Status__c != PROG_OP_DID_NOT_OPERATE && newOpp.Program_Operation_Status__c == PROG_OP_DID_NOT_OPERATE && newOpp.Program_Did_Not_Operate_Status__c == PROG_DID_NOT_OPERATE_NO_ENROLL)
                {
                    noEnrollOpps.add(newOpp);
                }
            }
            else if(newOpp.RecordTypeId == catalogRT)
            {
                /* if(oldOpp.StageName != CLOSED_WON_CUSTOM && newOpp.StageName == CLOSED_WON_CUSTOM)
                {
                    catalogOpps.add(newOpp);
                } */
            }
            else if(newOpp.RecordTypeId == affiliationRT)
            {
                // Things that happen when the opportunity record type is Affiliation Approval
            }
            else 
            {
                throw new opportunityServiceException('Unexpected Opportunity Record Type. RecordTypeId: ' + newOpp.RecordTypeId);
            }            
        }
        if(!customOpps.isEmpty())
        {
            customWon(new Map<Id, Opportunity>(customOpps));
        }
        /* if(!catalogOpps.isEmpty())
        {
            catalogWon(catalogOpps);
        } */
        if(!noEnrollOpps.isEmpty())
        {
            removeProgramTermRecords(noEnrollOpps);
        }
        //system.debug('--- opportunityService checkIfOpportunityIsWon End ---');

    }
    /**
     * Creates, tasks and other records once a catalog program bid had been won.
     * @param records List<Opportunity> of catalog opportunity records
     */
    /* private static void catalogWon(List<Opportunity> records)
    {

    } */
    /**
     * Creates, tasks and other records once a custom program bid had been won.
     * @param records Map<Id, Opportunity> of custom opportunity records
     */
    private static void customWon(Map<Id, Opportunity> records)
    {
        //system.debug('--- customWon Start ---');
        Integer counter = 0;
        for(Opportunity o: records.values())
        {
            if(o.Resident_Director__c == null)
            {
                throw new opportunityService.opportunityServiceException(ErrorType.MISSING_RD,  'First Exception on row ' + counter + ' with the Id ' + o.Id + '.');
            }
            else if(o.Program_Advisor__c == null)
            {
                throw new opportunityService.opportunityServiceException(ErrorType.MISSING_PA, 'First Exception on row ' + counter + ' with the Id ' + o.Id + '.');
            }
            else if(o.Field_Director__c == null)
            {
                throw new opportunityService.opportunityServiceException(ErrorType.MISSING_FD, 'First Exception on row ' + counter + ' with the Id ' + o.Id + '.');
            }
            else if(o.Country__c == null)
            {
                throw new opportunityService.opportunityServiceException(ErrorType.MISSING_COUNTRY, 'First Exception on row ' + counter + ' with the Id ' + o.Id + '.');
            }
            else if(o.City__c == null)
            {
                throw new opportunityService.opportunityServiceException(ErrorType.MISSING_CITY, 'First Exception on row ' + counter + ' with the Id ' + o.Id + '.');
            }
            counter = counter++;
        }
        // Get or create program record
        //System.debug('Get or create program');
        Map<Id, Program__c> oppProgramMap = new Map<Id, Program__c>();
        Set<Id> programIds = new Set<Id>();
        for(Opportunity opp: records.values())
        {
            if(opp.Program__c != null)
            {
                programIds.add(opp.Program__c);
            }
        }
        Map<Id, Program__c> programs = new Map<Id, Program__c>([SELECT Id, Name, Resident_director_team_member__c, Country__c, Locality__c, Category__c, Custom_Program_Home_Instituiton_Account__c, Available_Sections__c, OwnerId, (SELECT Id, Start_Date__c FROM Program_Terms__r ORDER BY Start_Date__c DESC LIMIT 1 ) FROM Program__c WHERE Id IN: programIds]);
        for(Opportunity opp: records.values())
        {
            if(opp.Program__c == null)
            {
                Program__c p = new Program__c(
                    Name = opp.Program_Name__c,
                    Resident_director_team_member__c = opp.Resident_Director__c,
                    Country__c = opp.Country__c,
                    Locality__c = opp.City__c,
                    Category__c = opp.Category__c,
                    Custom_Program_Home_Instituiton_Account__c = opp.AccountId,
                    Available_Sections__c = opp.Term__c,
                    OwnerId = opp.OwnerId
                );
                oppProgramMap.put(opp.Id, p);
            }
            else
            {
                oppProgramMap.put(opp.Id, programs.get(opp.Program__c));
            }
        }
        database.upsert(oppProgramMap.values());        
        Map<String, Id> terms = new Map<String, Id>();
        for(Term__c t: [SELECT Id, Name FROM Term__c WHERE Year__c >=: Date.today().year()])
        {
            terms.put(t.Name, t.Id);
        }


        // Get or create program term record
        //System.debug('Get or create program term');
        final Id standard = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();
        List<Program_Term__c> programTerms = new List<Program_Term__c>();
        List<Opportunity> oppsWithNewPrograms = new List<Opportunity>();
        Map<Id, Id> programOppMap = new Map<Id, Id>();
        for(Id oppId: oppProgramMap.keySet())
        {
            Program__c program = oppProgramMap.get(oppId);
            Opportunity opp = records.get(oppId);
            if(opp.Program__c == null)
            {
                oppsWithNewPrograms.add(new Opportunity(Id = oppId, Program__c = program.Id));
            }
            programOppMap.put(program.Id, oppId);
            if(program.Program_Terms__r.isEmpty())
            {
                programTerms.add(new Program_Term__c(
                    Name = program.Name + ' ' + opp.Term__c + ' ' + opp.Year__c,
                    Program__c = program.Id,
                    Term__c = terms.get(opp.Term__c + ' ' + opp.Year__c),
                    Country__c = opp.Country__c,
                    Locality__c = opp.City__c,
                    OwnerId = opp.Program_Advisor__c,
                    Start_Date__c = opp.Start_Date__c,
                    End_Date__c = opp.End_Date__c,
                    RecordTypeId = standard
                ));
            }
            else
            {
                Id existingPT = program.Program_Terms__r.get(0).Id;
                Id termId = terms.get(opp.Term__c + ' ' + opp.Year__c);

                if(termId == null)
                {
                    //Term does not exist, create it
                    Term__c newTerm = new Term__c(Name = opp.Term__c + ' ' + opp.Year__c, Section__c = opp.Term__c, Year__c = Integer.valueOf(opp.Year__c));
                    database.insert(newTerm);
                    termId = newTerm.Id;
                }
                internalTermCloneController.initializeCloneJob_OppWon(existingPT, termId, opp.Id);
            }
        }
        sObjectBatchUpdater.batchUpdate(oppsWithNewPrograms, 200);
        database.insert(programTerms);
        List<Opportunity> updateOpps = new List<Opportunity>();
        for(Program_Term__c pt: programTerms)
        {
            updateOpps.add(new Opportunity(Id = programOppMap.get(pt.Program__c), Program_Term__c = pt.Id));
        }
        System.enqueueJob(new sObjectQueueableUpdater(updateOpps, sObjectQueueableUpdater.dmlOperation.isUpdate));

        // Iterate over Custom_Program_Task_Assignment__c records and create tasks
        List<Task> tasks = new List<Task>();
        List<Custom_Program_Task_Assignment__c> assignments = [SELECT Id, Assign_To__c, Assign_To_User__c, Name, Due_Date_Number__c, Due_Date_Type__c, Due_Date_Units__c, RecordType.Name, Exclude_From_Service_Only_Programs__c FROM Custom_Program_Task_Assignment__c];
        if(assignments.isEmpty())
        {
            throw new opportunityServiceException('Could not find Custom_Program_Task_Assignment__c records. Custom_Program_Task_Assignment__c records are needed to create tasks when a custom program opportunity is won.');
        }
        for(Custom_Program_Task_Assignment__c assignment: assignments)
        {
            for(Opportunity opp: records.values())
            {
                if(!opp.Service_Only__c || opp.Service_Only__c && !assignment.Exclude_From_Service_Only_Programs__c)
                {
                    Date dueDate = getDueDate(assignment, opp);
                    Task t = new Task(
                        Subject = assignment.Name,
                        OwnerId = assignment.RecordType.Name == 'Role' ? getAssignee(assignment, opp) : assignment.Assign_To_User__c,
                        ActivityDate = dueDate,
                        IsReminderSet = true,
                        ReminderDateTime = dueDate.addDays(-14),
                        WhatId = opp.Id
                    );
                    if(t.OwnerId == null)
                    {
                        throw new opportunityServiceException('Task has does not have an owner');
                    }
                    tasks.add(t);
                }
            }
        }

        database.insert(tasks);
        //system.debug('--- customWon End ---');
    }
    @TestVisible
    /**
     * repeatable code that will get the due date for a task from an opportunity and custom program task assignment
     * @param assignment Custom_Program_Task_Assignment__c record
     * @param opp Opportunity record
     * @return Date object for the due date of the task
     */
    private static Date getDueDate(Custom_Program_Task_Assignment__c assignment, Opportunity opp)
    {
        // TODO Create logic to determine due date
        Date result;
        Decimal value = assignment.Due_Date_Units__c == 'Week(s)' ? 7 * assignment.Due_Date_Number__c : assignment.Due_Date_Number__c;
        switch on assignment.Due_Date_Type__c {
            when 'Proposal Acceptance' {
                result = CLOSED_WON_DATETIME.date();
            }
            when 'Roster Deadline' {
                result = opp.Roster_Deadline__c;
            }
            when 'Program Start' {
                result = opp.Start_Date__c;
            }
            when 'Program End' {
                result = opp.End_Date__c;
            }
            when else {
                throw new opportunityServiceException('Unexpected Custom_Program_Task_Assignment__c Due_Date_Type__c value. Value: ' +  assignment.Due_Date_Type__c);
            }
        }
        result = assignment.Due_Date_Units__c == 'Month(s)' ? result.addMonths(value.intValue()) : result.addDays(value.intValue());
        //System.debug(assignment.Name + ' Due Date:' + result);
        return result;
    }
    /**
     * repeatable code that will get the assignee for a task from an opportunity and custom program task assignment
     * @param assignment Custom_Program_Task_Assignment__c record
     * @param opp Opportunity record
     * @return Id User Id for the task to be assigned to.
     */
    private static Id getAssignee(Custom_Program_Task_Assignment__c assignment, Opportunity opp)
    {
        Id assignee;
        switch on assignment.Assign_To__c {
            when 'Program Manager' {
                assignee = opp.OwnerId;
            }
            when 'Program Advisor' {
                assignee = opp.Program_Advisor__c;
            }
            when 'Resident Director' {
                assignee = opp.Resident_Director__c;
            }
            when else {
                throw new opportunityServiceException('Unexpected Custom_Program_Task_Assignment__c Assign_To__c value. Value: ' +  assignment.Assign_To__c);
            }
        }
        if(assignee == null)
        {
            throw new opportunityServiceException('The ' + assignment.Assign_To__c + ' field on Opportunity. ' + opp.Name + ' is empty. Please correct the record before continuing.');
        }
        return assignee;
    }

    /**
     * Adds all IFSA team members to the Opportunity Team so they all have access to the record
     * @param newMap Map<Id, Opportunity> newMap from <<opportunityTriggerHandler>>
     */
    public static void updateTeamMembers(Map<Id, Opportunity> newMap)
    {
        //system.debug('--- opportunityService updateTeamMembers Start ---');
        final Id customNewRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Custom Program (New)').getRecordTypeId();
        final Id customRepeatRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Custom Program (Repeat)').getRecordTypeId();
        Map<Id, List<OpportunityTeamMember>> teamMembers = new Map<Id, List<OpportunityTeamMember>>();
        for(OpportunityTeamMember teamMember: [SELECT Id, Name, OpportunityId, OpportunityAccessLevel, TeamMemberRole, Title, UserId FROM OpportunityTeamMember WHERE OpportunityId IN: newMap.keySet()])
        {
            if(!teamMembers.containsKey(teamMember.OpportunityId))
            {
                teamMembers.put(teamMember.OpportunityId, new List<OpportunityTeamMember>());
            }
            teamMembers.get(teamMember.OpportunityId).add(teamMember);
        }
        List<OpportunityTeamMember> newTeamMembers = new List<OpportunityTeamMember>();
        for(Opportunity o: newMap.values())
        {
            if(o.RecordTypeId == customNewRT || o.RecordTypeId == customRepeatRT)
            {
                Boolean hasProgramManager = false;
                Boolean hasFieldDirector = false;
                Boolean hasProgramAdvisor = false;
                Boolean hasResidentDirector = false;
                if(teamMembers.containsKey(o.Id))
                {
                    for(OpportunityTeamMember teamMember: teamMembers.get(o.Id))
                    {
                        switch on teamMember.TeamMemberRole {
                            when 'Program Manager' {
                                hasProgramManager = true;
                            }
                            when 'Program Advisor' {
                                hasProgramAdvisor = true;
                            }
                            when 'Field Director' {
                                hasFieldDirector = true;
                            }
                            when 'Resident Director' {
                                hasResidentDirector = true;
                            }
                        }
                    }
                }
                if(!hasProgramManager && o.OwnerId != null)
                {
                    newTeamMembers.add(new OpportunityTeamMember(
                        OpportunityId = o.Id,
                        UserId = o.OwnerId,
                        OpportunityAccessLevel = 'Edit',
                        TeamMemberRole = 'Program Manager'
                    ));
                }
                if(!hasProgramAdvisor && o.Program_Advisor__c != null)
                {
                    newTeamMembers.add(new OpportunityTeamMember(
                        OpportunityId = o.Id,
                        UserId = o.Program_Advisor__c,
                        OpportunityAccessLevel = 'Read',
                        TeamMemberRole = 'Program Advisor'
                    ));
                }
                if(!hasFieldDirector && o.Field_Director__c != null)
                {
                    newTeamMembers.add(new OpportunityTeamMember(
                        OpportunityId = o.Id,
                        UserId = o.Field_Director__c,
                        OpportunityAccessLevel = 'Read',
                        TeamMemberRole = 'Field Director'
                    ));
                }
                if(!hasResidentDirector && o.Resident_Director__c != null)
                {
                    newTeamMembers.add(new OpportunityTeamMember(
                        OpportunityId = o.Id,
                        UserId = o.Resident_Director__c,
                        OpportunityAccessLevel = 'Read',
                        TeamMemberRole = 'Resident Director'
                    ));
                }
            }
        }
        Database.insert(newTeamMembers);
        //system.debug('--- opportunityService updateTeamMembers End ---');
    }
    /**
     * removes program term records for an opportunity that is marked as "Did not enroll"
     * @param records List<Opportunity> new records from <<opportunityTriggerHandler>>
     */
    private static void removeProgramTermRecords(List<Opportunity> records)
    {
        Map<Id, String> programIdTermNameMap = new Map<Id, String>();
        for(Opportunity opp: records)
        {
            programIdTermNameMap.put(opp.Program__c, opp.Term__c + ' ' + opp.Year__c);
        }

        List<Id> toDelete = new List<Id>();
        for(Program_Term__c pt: [SELECT Id, Program__c, Term__r.Name, (SELECT Id FROM Applications__r WHERE Status__c IN ('Accepted', 'Accepted (with Conditions)', 'On Site', 'Program Completed', 'Waitlisted')) FROM Program_Term__c WHERE Program__c IN: programIdTermNameMap.keySet() AND Term__r.Name IN: programIdTermNameMap.values()])
        {
            if(programIdTermNameMap.containsKey(pt.Program__c) && programIdTermNameMap.get(pt.Program__c) == pt.Term__r.Name && pt.Applications__r.isEmpty())
            {
                toDelete.add(pt.Id);
            }
        }
        List<Application_Requirement__c> reqs = [SELECT Id FROM Application_Requirement__c WHERE Program_Term__c IN: toDelete];
        List<Program_Term_Housing_Option__c> pthos = [SELECT Id FROM Program_Term_Housing_Option__c WHERE Program_Term__c IN: toDelete];
        for(Application_Requirement__c req: reqs)
        {
            toDelete.add(req.Id);
        }
        for(Program_Term_Housing_Option__c ptho: pthos)
        {
            toDelete.add(ptho.Id);
        }

        Database.delete(toDelete);

    }
    /**
     * Creates Opportunity_Country__c records for Opportunities for new records or for existing records when Opportunity.Country__c has changed. This method does not delete any records if Opportunity.Country__c is changed from one country to another, it is up to the end user to ensure that the related Opportunity_Country__c records are correct.
     * @param newMap
     * @param oldMap
     */
    public static void createOpportunityJunctionRecords(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap)
    {
        //system.debug('--- opportunityService createOpportunityJunctionRecords Start ---');
        // Custom
        Set<Id> customRecordTypeIds = new Set<Id>{Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Custom Program (New)').getRecordTypeId(), Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Custom Program (Repeat)').getRecordTypeId()};
        List<SObject> newRecords = new List<SObject>();
        // Find existing junction records
        Map<Id, Set<Id>> oppCountryMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> oppCityMap = new Map<Id, Set<Id>>();

        for(Opportunity_Country__c oppCountry: [SELECT Id, Opportunity__c, Country__c FROM Opportunity_Country__c WHERE Opportunity__c IN: newMap.keySet()])
        {
            if(!oppCountryMap.containsKey(oppCountry.Opportunity__c))
            {
                oppCountryMap.put(oppCountry.Opportunity__c, new Set<Id>());
            }
            oppCountryMap.get(oppCountry.Opportunity__c).add(oppCountry.Country__c);
        }
        for(Opportunity_City__c oppCity: [SELECT Id, Opportunity__c, City__c FROM Opportunity_City__c WHERE Opportunity__c IN: newMap.keySet()])
        {
            if(!oppCityMap.containsKey(oppCity.Opportunity__c))
            {
                oppCityMap.put(oppCity.Opportunity__c, new Set<Id>());
            }
            oppCityMap.get(oppCity.Opportunity__c).add(oppCity.City__c);
        }        

        Set<Id> debugOids = new Set<Id>();
        for(Id oId : newMap.keySet()){
            debugOids.add(oId);
        }
        List<Opportunity> debugOppList = [SELECT Id, Name, Program_Term__c, Program_Term__r.Term__c FROM Opportunity WHERE Id IN :debugOids];


        for(Opportunity record: newMap.values())
        {
            if(record.Country__c != null && customRecordTypeIds.contains(record.RecordTypeId) && (!oldMap.containsKey(record.Id) || (oldMap.containsKey(record.Id) && oldMap.get(record.Id).Country__c != record.Country__c) && (!oppCountryMap.containsKey(record.Id) || !oppCountryMap.get(record.Id).contains(record.Country__c))))
            {
                newRecords.add(new Opportunity_Country__c(
                    Opportunity__c = record.Id,
                    Country__c = record.Country__c
                ));
            }

            if(record.City__c != null && customRecordTypeIds.contains(record.RecordTypeId) && (!oldMap.containsKey(record.Id) || (oldMap.containsKey(record.Id) && oldMap.get(record.Id).City__c != record.City__c) && (!oppCityMap.containsKey(record.Id) || !oppCityMap.get(record.Id).contains(record.City__c))))
            {
                newRecords.add(new Opportunity_City__c(
                    Opportunity__c = record.Id,
                    City__c = record.City__c
                ));
            }
        }
        newRecords.sort();
        database.insert(newRecords);
        //system.debug('--- opportunityService createOpportunityJunctionRecords End ---');
    }
    /**
     * Updates Opportunity.Cities__c when Opportunity_City__c records are updates
     * @param records Opportunity_City__c that have been inserted, updated, deleted, or undeleted
     */
    public static void updateOpportunityCities(List<Opportunity_City__c> records)
    {
        Set<Id> opportunityIds = new Set<Id>();
        for(Opportunity_City__c oc: records)
        {
            opportunityIds.add(oc.Opportunity__c);
        }
        List<Opportunity> opportunities = [SELECT Id, Cities__c, (SELECT City__r.Name FROM Opportunity_Cities__r) FROM Opportunity WHERE Id IN: opportunityIds];
        for(Opportunity o: opportunities)
        {
            String c = '';
            for(Opportunity_City__c oc: o.Opportunity_Cities__r)
            {
                c = c + oc.City__r.Name + ', ';
            }
            o.Cities__c = c.removeEnd(', ');
        }
        database.update(opportunities);
    }
    /**
     * Updates Opportunity.Countries__c when Opportunity_Country__c records are updates
     * @param records Opportunity_Country__c that have been inserted, updated, deleted, or undeleted
     */
    public static void updateOpportunityCountries(List<Opportunity_Country__c> records)
    {
        Set<Id> opportunityIds = new Set<Id>();
        for(Opportunity_Country__c oc: records)
        {
            opportunityIds.add(oc.Opportunity__c);
        }
        List<Opportunity> opportunities = [SELECT Id, Countries__c, (SELECT Country__r.Name FROM Opportunity_Countries__r) FROM Opportunity WHERE Id IN: opportunityIds];
        for(Opportunity o: opportunities)
        {
            String c = '';
            for(Opportunity_Country__c oc: o.Opportunity_Countries__r)
            {
                c = c + oc.Country__r.Name + ', ';
            }
            o.Countries__c = c.removeEnd(', ');
        }
        database.update(opportunities);
    }
} // Class opportunityService end