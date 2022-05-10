@isTest
public class programOptionConverterUtilityTest 
{/*
	@isTest static void splitSummerProgramTest() 
	{
		World__c w = new World__c(Name = 'Test World');
        insert w;
        Region__c r = new Region__c(Name = 'Test Region', World__c = w.Id);
        insert r;
        Country__c c = new Country__c(Name = 'Test Country', Region__c = r.Id, Active__c = true);
        insert c;
        Account a = new Account(Name = 'Test Account', Country__c = c.Id);
        insert a;
        Host_Institution__c h = new Host_Institution__c(Name = 'Test Institution', Account__c = a.Id, Country__c = c.Id);
        insert h;
        Program__c prog = new Program__c(Name = 'programName', Country__c = c.Id, Host_Institution__c = h.id);
        insert prog;
        test.startTest();
        programOptionConverterUtility.splitSummerProgram('programName');
        test.stopTest();
    }
    @isTest static void splitProgramsTest() 
	{
		World__c w = new World__c(Name = 'Test World');
        insert w;
        Region__c r = new Region__c(Name = 'Test Region', World__c = w.Id);
        insert r;
        Country__c c = new Country__c(Name = 'Test Country', Region__c = r.Id, Active__c = true);
        insert c;
        Account a = new Account(Name = 'Test Account', Country__c = c.Id);
        insert a;
        Host_Institution__c h = new Host_Institution__c(Name = 'programName _ optionName', Account__c = a.Id, Country__c = c.Id);
        insert h;
        Program__c prog = new Program__c(Name = 'programName', Country__c = c.Id, Host_Institution__c = h.id);
        insert prog;
        Program_Option__c po = new Program_Option__c(Name = 'optionName', Program__c = prog.Id, Country__c = c.Id);
        insert po;
        test.startTest();
        programOptionConverterUtility.splitPrograms('programName', 'optionName');
        test.stopTest();
    }
    @isTest static void splitUALProgramTest() 
	{
		World__c w = new World__c(Name = 'Test World');
        insert w;
        Region__c r = new Region__c(Name = 'Test Region', World__c = w.Id);
        insert r;
        Country__c c = new Country__c(Name = 'Test Country', Region__c = r.Id, Active__c = true);
        insert c;
        Account a = new Account(Name = 'Test Account', Country__c = c.Id);
        insert a;
        Host_Institution__c h = new Host_Institution__c(Name = 'Test Institution', Account__c = a.Id, Country__c = c.Id);
        insert h;
        Program__c prog = new Program__c(Name = 'programName', Country__c = c.Id, Host_Institution__c = h.id);
        insert prog;
        test.startTest();
        programOptionConverterUtility.splitProgramsUAL('programName', 'optionName');
        test.stopTest();
    }
    @isTest static void connectOptionsTest(){
        World__c w = new World__c(Name = 'Test World');
        insert w;
        Region__c r = new Region__c(Name = 'Test Region', World__c = w.Id);
        insert r;
        Country__c c = new Country__c(Name = 'Test Country', Region__c = r.Id, Active__c = true);
        insert c;
        Account a = new Account(Name = 'Test Account', Country__c = c.Id);
        insert a;
        Host_Institution__c h = new Host_Institution__c(Name = 'Test Institution', Account__c = a.Id, Country__c = c.Id);
        insert h;
        Program__c prog = new Program__c(Name = 'programName', Country__c = c.Id, Host_Institution__c = h.id, Category__c = 'Catalog');
        insert prog;
        Program_Option__c po = new Program_Option__c(Name = 'programOption', Country__c = c.Id, Program__c = prog.Id);
        insert po;
        Term__c t = new Term__c(Name = 'Spring', Section__c = 'Spring', Year__c = Date.today().year());
        insert t; 
        Program_Term__c pt1 = new Program_Term__c(Name = '1', Program__c = prog.Id, Term__c = t.Id, Country__c = c.Id, RecordTypeId = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Parent Program Term without Dates').getRecordTypeId());
        insert pt1;
        Program_Term__c pt2 = new Program_Term__c(Name = '2', Parent_Program_Term__c = pt1.Id, Country__c = c.Id, Program_Option_Name__c = po.Name, RecordTypeId = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option with Dates').getRecordTypeId());
        insert pt2;
        List<Program_Term__c> PTs = [SELECT Id, Name, 
											Program_Option__c,
											Program_Option_Name__c, 
											Program__c 
									   FROM Program_Term__c 
									  WHERE Program_Option_Name__c != null
									    AND Program_Option__c = null
										AND Parent_Program_Term__c != null
                                        AND Program__r.Category__c = 'Catalog']; 
        System.assertNotEquals(true, PTs.isEmpty(), 'No testable data has been created');
        test.startTest();
        programOptionService.connectOptions();
        test.stopTest();
    }*/
}