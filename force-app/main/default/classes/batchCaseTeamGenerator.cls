/**
 * Case team creation for Health & Safety cases. As of December 2020, the case record types used by this class are no longer being  used by IFSA and case team creation is handled by <<promiseHealthSafetyCase>>
 * @author Brock Barlow
 */
public without sharing class batchCaseTeamGenerator implements Database.Batchable<SObject> 
{
    private Case theCase;
    private String query;
    private List<ID> studentIds;
    private Map<String, CaseTeamRole> roleMap =  new Map<String, CaseTeamRole>();
    
    public batchCaseTeamGenerator(Case c, List<Case_Student__c> sc)
    {
        theCase = c;
        studentIds = new List<ID>();
        for(Case_Student__c studentCase: sc)
        {
            studentIds.add(studentCase.Student__c);
        }
        for(CaseTeamRole role: [SELECT Id, Name FROM CaseTeamRole])
        {
            roleMap.put(role.Name, role);
        }
    }
    public batchCaseTeamGenerator(Case c, List<Case_Student__c> sc, List<Id> applicationIds)
    {
        this(c, sc);
        if(applicationIds.isEmpty() || studentIds.isEmpty()){
            throw new NullPointerException();
        }
        query = String.format('SELECT Id, Contact__c, Support_Personnel__c FROM Contact_Support_Personnel__c WHERE Contact__c IN {0} AND (Application__c = NULL OR Application__c IN {1})', new List<object>{apexQueryUtility.buildInClause(studentIds), apexQueryUtility.buildInClause(applicationIds)});
    }
    public batchCaseTeamGenerator(Case c)
    {
        this(c, [SELECT Id, Student__c FROM Case_Student__c WHERE Case__c =: c.Id]);
        Id preDepartureRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Pre-Departure').getRecordTypeId();
        Id cityRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident City').getRecordTypeId();
        Id countryRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Country').getRecordTypeId();
        Id globalRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Global').getRecordTypeId();
        Id hostRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Host Institution').getRecordTypeId();
        Id programRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Program').getRecordTypeId();
        Id studentRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();
        List<Id> applicationIds = new List<Id>();
        List<Application__c> apps;
        if(theCase.RecordTypeId == preDepartureRT)
        {
            apps = [SELECT Id FROM Application__c WHERE Id IN (SELECT Active_Application__c FROM Contact WHERE Id IN: studentIds)];
        }
        else if(theCase.RecordTypeId == cityRT || theCase.RecordTypeId == countryRT || theCase.RecordTypeId == globalRT || theCase.RecordTypeId == hostRT || theCase.RecordTypeId == programRT)
        {
            apps = [SELECT Id FROM Application__c WHERE Id IN (SELECT On_Site_Application__c FROM Contact WHERE Id IN: studentIds) AND (Program_Term__r.End_Date__c >= LAST_N_DAYS:7 OR Program_Term__r.Parent_Program_Term__r.End_Date__c >= LAST_N_DAYS:7) AND Status__c IN ('Accepted', 'Accepted (with Conditions', 'On Site', 'Program Completed')];
        }
        else if(theCase.RecordTypeId == studentRT)
        {
            apps = [SELECT Id FROM Application__c WHERE Id IN (SELECT On_Site_Application__c FROM Contact WHERE Id IN: studentIds) AND Status__c IN ('On Site', 'Program Completed')];
        }
        for(Application__c app: apps)
        {
            applicationIds.add(app.Id);
        }

        if(applicationIds.isEmpty()){
            throw new NullPointerException();
        }
        query = String.format('SELECT Id, Contact__c, Support_Personnel__c FROM Contact_Support_Personnel__c WHERE Contact__c IN {0} AND (Application__c = NULL OR Application__c IN {1})', new List<object>{apexQueryUtility.buildInClause(studentIds), apexQueryUtility.buildInClause(applicationIds)});
    }

    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        system.debug(query);
        return Database.getQueryLocator(query);
    }
        
    public void execute(Database.BatchableContext bc, List<SObject> scope)
    {
        if(scope.isEmpty())
        {
            IfsaDataException e = new IfsaDataException();
            e.setMessage('Could not find any CSP records');
            throw e;
        }
        // Create "IN" clause to get the Support Personnel records
        String inClause = apexQueryUtility.buildInClause(scope, 'Support_Personnel__c');
        // Get all row in support personnel records related to the students
        List<Support_Personnel__c> supportPersonnel = apexQueryUtility.selectAllFrom('Support_Personnel__c', 'ifsa_staff__r.Name', 'ID IN ' + inClause + ' AND Type__c = \'IFSA Staff\' AND ifsa_staff__r.IsActive = TRUE');
        // Map to group IFSA staff user id's with their SP records
        Map<Id, List<Support_Personnel__c>> userSPMap = new Map<Id, List<Support_Personnel__c>>();
        List<Incident_Matrix__c> matrices;
        // Get the IM records depending on if the case has a sub sub category or not
        if(theCase.Incident_Sub_Subcategory__c != null)
            matrices = [SELECT id, support_role_type__c, ifsa_staff__c, ifsa_staff__r.Name FROM Incident_Matrix__c 
                WHERE Severity__c =: theCase.Incident_Severity__c
                AND IFSA_Staff__r.IsActive = TRUE
                AND Incident_Category__c =:  theCase.Incident_Category__c 
                AND Incident_Sub_Category__c =: theCase.Incident_Sub_Category__c
                AND Incident_Sub_Subcategory__c = : theCase.Incident_Sub_Subcategory__c];
        else
            matrices = [SELECT id, support_role_type__c, ifsa_staff__c, ifsa_staff__r.Name FROM Incident_Matrix__c 
                WHERE Severity__c =: theCase.Incident_Severity__c 
                AND IFSA_Staff__r.IsActive = TRUE
                AND Incident_Category__c =:  theCase.Incident_Category__c 
                AND Incident_Sub_Category__c =: theCase.Incident_Sub_Category__c];
        // Map to group IFSA staff user id's with their IM records				
        Map<Id, List<Incident_Matrix__c>> userMatrixMap = new Map<Id, List<Incident_Matrix__c>>();
        for(Incident_Matrix__c matrix: matrices)
        {
            if(!userMatrixMap.containsKey(matrix.IFSA_Staff__c))
            {				
                userMatrixMap.put(matrix.IFSA_Staff__c, new List<Incident_Matrix__c>());
            }
            userMatrixMap.get(matrix.IFSA_Staff__c).add(matrix);
        }
        // Get the existing case team members
        List<CaseTeamMember> membersList = apexQueryUtility.selectAllFrom('CaseTeamMember', 'ParentId = \'' + theCase.Id + '\'');
        Set<Id> ctmUserIds = new Set<Id>();
        for(CaseTeamMember ctm: membersList)
        {
            ctmUserIds.add(ctm.MemberId);
        }
        // Create sets and lists to hold case team members, and entitysubscriptions(Chatter Follows)
        Set<CaseTeamMember> members = new Set<CaseTeamMember>();
        List<EntitySubscription> subscriptions = new List <EntitySubscription>();
        List<EntitySubscription> existingSubs = [SELECT Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentId =: theCase.Id LIMIT 200];		
        Set<Id> existingSubsriberIds = new Set<Id>();
        for(EntitySubscription es: existingSubs)
        {
            existingSubsriberIds.add(es.SubscriberId);
        }
        // make current user follow case in chatter if they are not following it
        if(!existingSubsriberIds.contains(UserInfo.getUserId()))
        {			
            subscriptions.add(new EntitySubscription(ParentId = theCase.Id, SubscriberId = UserInfo.getUserId()));
            existingSubsriberIds.add(UserInfo.getUserId());
            system.debug(UserInfo.getUserId());
        }
        if(!membersList.isEmpty())
        {
            members = new Set<CaseTeamMember>(membersList);
        }
        // Iterate over SP and IM records to see if the IFSA staff members should be added to the case team
        for(Support_Personnel__c sp: supportPersonnel)	
        {
            if(userMatrixMap.containsKey(sp.IFSA_Staff__c))
            {				
                for(Incident_Matrix__c matrix: userMatrixMap.get(sp.IFSA_Staff__c))
                {					
                    if(matrix.Support_Role_Type__c == sp.Support_Role_Type__c && !ctmUserIds.contains(sp.IFSA_Staff__c))
                    {
                        // Create the Case Team Member record
                        system.debug(matrix.ifsa_staff__r.Name);
                        CaseTeamMember ctm = new CaseTeamMember();
                        ctm.ParentId = theCase.Id;
                        ctm.MemberId = matrix.IFSA_Staff__c;					
                        ctm.TeamRoleId = roleMap.get(matrix.Support_Role_Type__c).Id;
                        members.add(ctm);
                        ctmUserIds.add(matrix.IFSA_Staff__c);
                        // Make the case team member follow the case in Chatter if the do not already
                        if(!existingSubsriberIds.contains(matrix.IFSA_Staff__c))
                        {							
                            subscriptions.add(new EntitySubscription(ParentId = theCase.Id, SubscriberId = matrix.IFSA_Staff__c));
                            existingSubsriberIds.add(matrix.IFSA_Staff__c);
                            system.debug(matrix.IFSA_Staff__c);
                        }
                    }
                }
            }
        }
        // Cleanup
        membersList.clear();
        membersList.addAll(members);
        // Possible unneeded debugging
        system.debug(existingSubsriberIds);
        for(EntitySubscription es: subscriptions)
        {
            system.debug(es.subscriberId);
        }
        // Upsert the case team members
        Database.UpsertResult[] results = database.upsert(membersList);
        for(Database.UpsertResult result: results)
        {
            if(!result.isSuccess())
            {
                // Return false if something goes wrong
                System.debug(LoggingLevel.WARN, 'Could not upsert a case team member');
            }
        }
        // Insert the EntitySubscription (Chatter Follows)
        try
        {
            database.insert(subscriptions, false);
        }
        catch (DMLException dmlEx) 
        {
            //if we get an error because this user is already following this object, it's okay.
            if (dmlEx.getDmlType(0) == statusCode.DUPLICATE_VALUE) 
            {
                System.Debug('OrgTeamSubscribeOrg: subscription already exists');
            } 
            else 
            {
                //otherwise we have a more serious error that we need to throw.
                throw dmlEx;
            }
        }
    }

    public void finish(Database.BatchableContext BC)
    {
        theCase.Case_Team_Job_Id__c = null;
        theCase.Case_Team_Added__c = true;
        theCase.Generate_Case_Team__c = false;
        database.update(theCase);
    }
}