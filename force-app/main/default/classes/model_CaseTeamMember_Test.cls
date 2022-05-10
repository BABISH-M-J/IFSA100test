@isTest
public class model_CaseTeamMember_Test {
	
    @TestSetup
    public static void mockData(){
        //Create test account
        Account acct = apexMockDataUtility.createAccount('TestAcct');
        
        //Create test contact
        Contact ctc = apexMockDataUtility.createContact('TestCtc', acct.Id);
        
        //Create test user
        User u= apexMockDataUtility.createUser(ctc.id);
        insert u;
        
        //Create test Case
        Case case1 = new Case();
        case1.Status = 'New';
        case1.Student__c = ctc.id;
        case1.Date_Time_of_Incident__c = DateTime.now();
        case1.Category__c  = 'Academic';
        case1.Sub_Category__c = 'Accommodations';
        case1.Subject = 'IFSA Case Controller Test';
        case1.Incident_Severity__c = 'Critical';
        case1.Description = 'Test';
        case1.Alchohol_Involved__c  = true;
        insert case1;
    }
    
    @isTest 
    public static void testmodel_CaseTeamMember(){
        test.startTest();
        List<Case> cas = [Select id From Case];
        List<CaseTeamMember> caseTeamMem = [Select id, ParentId, TeamRole.Name, TeamRole.accesslevel, CreatedDate, member.FirstName, member.LastName, member.Email
                                           From CaseTeamMember Where ParentId =:cas[0].id];
        model_CaseTeamMember modCaseMem = new model_CaseTeamMember(caseTeamMem[0]);
        test.stopTest();
        System.assertEquals(modCaseMem.caseId, caseTeamMem[0].ParentId);
    }
    
    @isTest 
    public static void testmodel_CaseTeamMemberequalPositive(){
        test.startTest();
        model_CaseTeamMember modCaseMem = new model_CaseTeamMember();
        Boolean objCheck = modCaseMem.equals(modCaseMem);
        test.stopTest();
        System.assert(objCheck);
    }
    
    @isTest 
    public static void testmodel_CaseTeamMemberequalNegative(){
        Case cs = new Case();
        test.startTest();
        model_CaseTeamMember modCaseMem = new model_CaseTeamMember();
        Boolean objCheck = modCaseMem.equals(cs);
        test.stopTest();
        System.assert(!objCheck);
    }
}