@isTest
public class caseTriggerHandler_Test {
    
    @testSetup
    public static void mockData(){
        
        Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
        Country__c c = (Country__c) testData.get('country');
        c.Id = null;
        c.Name = 'England';
        Database.insert(c);
        
        Locality__c l = new Locality__c(Name = 'London', Country__c = c.Id, RecordTypeId = Schema.SObjectType.Locality__c.getRecordTypeInfosByName().get('City/Town').getRecordTypeId() );
        Database.insert(l);
        
        Host_Institution__c h = new Host_Institution__c(Name = 'University College London', Locality__c = l.Id, Country__c = c.Id);
        Database.insert(h);
        
        Program__c p = new Program__c(Name = h.Name, Locality__c = l.Id, Country__c = c.Id);
        Database.insert(p);      
        
        List<Case> caseList = new List<Case>();
        Case cs1 = new Case();
        cs1.Subject = 'Test Subject1';
        cs1.status = 'New';
        cs1.description = 'Test description ';
        cs1.Alchohol_Involved__c = true;
        caseList.add(cs1);
        insert caseList;
    }
    
    @isTest
    public static void testUpdateScenario(){
        User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            Test.startTest();
            List<Case> csList = [Select id, status from case where subject =: 'Test Subject1'];
            csList[0].status = 'Waiting';
            update csList;
            List<CaseTeamMember> members = [SELECT Id FROM CaseTeamMember WHERE ParentId =: csList[0].id];
            System.assertEquals(false, members.isEmpty(), 'The case does not have team members');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testbeforeDelete(){
        User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            Test.startTest();
            Map<ID,Case> oldMap = new Map<ID,Case>([Select id, status, RecordTypeId from case where subject =: 'Test Subject1']);
            List<Case> oldRecords = oldMap.values();
            List<Case> newRecords = oldMap.values();
            HealthSafety_CaseTriggerHandlerExtension hs = new HealthSafety_CaseTriggerHandlerExtension();
            //Called because we need to set newRecords to call the before delete function
            Boolean result1 = (Boolean) hs.call('beforeInsert', new Map<String, Object> { 'newRecords' => newRecords});
            
            Boolean result = (Boolean) hs.call('beforeDelete', new Map<String, Object> { 'newRecords' => newRecords, 'oldRecords' => oldRecords, 'oldMap' => oldMap });
            Test.stopTest();
            System.assert(result, 'If function is called then it should return true');
        }
    }
    
    @isTest
    public static void testafterDelete(){
        User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            Test.startTest();
            Map<ID,Case> oldMap = new Map<ID,Case>([Select id, status,RecordTypeId from case where subject =: 'Test Subject1']);
            List<Case> oldRecords = oldMap.values();
            List<Case> newRecords = oldMap.values();
            HealthSafety_CaseTriggerHandlerExtension hs = new HealthSafety_CaseTriggerHandlerExtension();
            //Called because we need to set newRecords to call the after delete function
            Boolean result1 = (Boolean) hs.call('beforeInsert', new Map<String, Object> { 'newRecords' => newRecords});
            
            Boolean result = (Boolean) hs.call('afterDelete', new Map<String, Object> { 'newRecords' => newRecords, 'oldRecords' => oldRecords, 'oldMap' => oldMap });
            Test.stopTest();
            System.assert(result, 'If function is called then it should return true');
        }
    }
    
    @isTest
    public static void testbeforeUndelete(){
        User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            Test.startTest();
            List<Case> newRecords = [Select id, status,RecordTypeId from case where subject =: 'Test Subject1'];
            HealthSafety_CaseTriggerHandlerExtension hs = new HealthSafety_CaseTriggerHandlerExtension();
            Boolean result = (Boolean) hs.call('beforeUndelete', new Map<String, Object> { 'newRecords' => newRecords});
            Test.stopTest();
            System.assert(result, 'If function is called then it should return true');
        }
    }
    
    @isTest
    public static void testafterUndelete(){
        User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            Test.startTest();
            Map<ID,Case> newMap = new Map<ID,Case>([Select id, status,RecordTypeId from case where subject =: 'Test Subject1']);
            List<Case> newRecords = newMap.values();
            HealthSafety_CaseTriggerHandlerExtension hs = new HealthSafety_CaseTriggerHandlerExtension();
            Boolean result = (Boolean) hs.call('afterUndelete', new Map<String, Object> { 'newRecords' => newRecords, 'newMap' => newMap });
            Test.stopTest();
            System.assert(result, 'If function is called then it should return true');
        }
    }
    
    @IsTest
    static void testLegacyProgramCase(){
        User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            Test.startTest();
            Case c = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Program').getRecordTypeId());
            c.Incident_Severity__c = 'Non-Emergency';
            c.Incident_Category__c = 'Program/Country Wide';
            c.Incident_Sub_Category__c = 'Political/Social Unrest';
            c.Incident_Sub_Subcategory__c = 'Protests/Demonstrations';
            c.Date_Time_of_Incident__c = Datetime.now();
            c.Affected_Programs__c = 'University College London';
            Database.insert(c);
            List<Case_Program__c> cpList = [Select id,Program__c From Case_Program__c Where Case__c =: c.id];
            Test.stopTest();
            System.assert(cpList.size() > 0, 'There should be Case Program record inserted for this case');
        }
    }
    
    
}