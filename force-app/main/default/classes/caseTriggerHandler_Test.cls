@isTest
public class caseTriggerHandler_Test {
    
    @testSetup
    static void mockData(){
        
        BaseTriggerHandler.bypass('applicationTriggerHandler');
        
      //  Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
        World__c wrd = new World__c();
        wrd.Name ='test';
        wrd.CurrencyIsoCode = 'USD';
        insert wrd;
        
        Region__c	reg = new Region__c	();
        reg.CurrencyIsoCode ='USD';
        reg.World__c = wrd.Id;
        insert reg;
        
        Country__c c = new Country__c();
       
        c.Name = 'England';
        c.CurrencyIsoCode = 'USD';
        c.Region__c = reg.Id;
        c.Active__c = True;
        //c.None_of_These_Apply_Other_Factors__c = True;
        insert(c);
        Schema.SObjectType.Locality__c.getRecordTypeInfosByName().get('City/Town').getRecordTypeId() ;
        Locality__c l = new Locality__c(Name = 'London', Country__c = c.Id, CurrencyIsoCode = 'USD',
         RecordTypeId = Schema.SObjectType.Locality__c.getRecordTypeInfosByName().get('City/Town').getRecordTypeId() );
        system.debug('l' + l);
        insert(l);
        
        Host_Institution__c h = new Host_Institution__c(Name = 'University College London', Locality__c = l.Id,CurrencyIsoCode ='USD',  Country__c = c.Id);
        system.debug('h' +h );
        insert(h);
        system.debug('h' +h);
        

        
        Program__c p = new Program__c(Name = h.Name, Locality__c = l.Id, Country__c = c.Id);
        Database.insert(p);   
        
        //babish
        //Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c LIMIT 1];
		//Account acct = [SELECT Id FROM Account WHERE Institution__c =: h.Id];
		//Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);
	
        //babish
        
        List<Case> caseList = new List<Case>();
        Case cs1 = new Case();
        cs1.Subject = 'Test Subject1';
        cs1.status = 'New';
        cs1.description = 'Test description ';
        cs1.Alchohol_Involved__c = true;
        caseList.add(cs1);
        insert caseList;
        /*Case cs3 = new Case();
        cs3.Subject = 'Test Subjecty';
        cs3.status = 'New';
        cs3.description = 'Test descripti7on ';
        cs1.Alchohol_Involved__c = true;
        caseList.add(cs3);*/
        List<Case> caselist1 = new List<Case>();
        Case cs2 = new Case();
        cs2.Subject = 'Test Subject2';
        cs2.status = 'New';
        cs2.None_of_These_Apply_Other_Factors__c = false;
        cs2.description = 'Test description2';
        cs2.Alchohol_Involved__c = true;
        caselist1.add(cs2);
        insert caseList1;
       //undelete caseList;
        /*Case_Student__c cstud =new Case_Student__c(
            Case__c =cs1.Id,
            CurrencyIsoCode='USD',
            Student__c=ctc.Id
        );
        Database.insert(cstud);*/
        
    }
    
     @isTest
    public static void testUpdateScenario(){
        User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            Test.startTest();
            List<Case> csList = [Select id, status from case where subject =: 'Test Subject1'   ];
            system.debug('csList' + csList );
            csList[0].status = 'Waiting';
            update csList;
            List<CaseTeamMember> members = [SELECT Id FROM CaseTeamMember WHERE ParentId =: csList[0].id  LIMIT 1  ];
            System.assertEquals(false, members.isEmpty(), 'The case does not have team members');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testbeforeDelete(){
        User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            Test.startTest();
            Map<ID,Case> oldMap = new Map<ID,Case>([Select id, status,RecordTypeId from Case where subject =: 'Test Subject2' ]);
			system.debug('oldMap' + oldMap);
            
            
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
            Map<ID,Case> oldMap = new Map<ID,Case>([Select id, status,RecordTypeId from case where subject =: 'Test Subject2'   ]);
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
            List<Case> newRecords = [Select id, status,RecordTypeId from case where subject =: 'Test Subject1'   ];
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
            Map<ID,Case> newMap = new Map<ID,Case>([Select id, status,RecordTypeId from case where subject =: 'Test Subject1'  ]);
            List<Case> newRecords = newMap.values();
            HealthSafety_CaseTriggerHandlerExtension hs = new HealthSafety_CaseTriggerHandlerExtension();
            Boolean result = (Boolean) hs.call('afterUndelete', new Map<String, Object> { 'newRecords' => newRecords, 'newMap' => newMap });
            Test.stopTest();
            System.assert(result, 'If function is called then it should return true');
        }
    }
    @isTest
    public static void linkStudentsToHostInstitutionCase1(){

        User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){

        List<Case_Host_Institution__c> chlist = new List <Case_Host_Institution__c>();
        Case_Host_Institution__c chost = new Case_Host_Institution__c();
        chost.CurrencyIsoCode ='USD';
      //  chost.None_of_These_Apply_Other_Factors__c = True;
        chlist.add(chost);
        insert chlist;
        caseService.linkStudentsToHostInstitutionCase(chlist);
        }
    }
    
    @isTest
    public static void testInsertScenario1(){
       User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            
            World__c wrld = new World__c();
            wrld.CurrencyIsoCode  = 'USD';
            wrld.Name = 'England';
            insert wrld;
            
            Region__c reg = new Region__c();
            reg.World__c =wrld.Id;
            reg.CurrencyIsoCode = 'USD';
            insert reg;
            
            Country__c ctry = new Country__c();
            ctry.CurrencyIsoCode = 'USD';
            ctry.Region__c = reg.Id;
            insert ctry;
            
           Case c1 = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Program').getRecordTypeId());
            //c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId() ;
            c1.Incident_Severity__c = 'Non-Emergency';
           // c1.Student__c=ctc1.Id;
            c1.Incident_Category__c = 'Program/Country Wide';
            c1.Incident_Sub_Category__c = 'Political/Social Unrest';
            c1.Incident_Sub_Subcategory__c = 'Protests/Demonstrations';
            c1.Date_Time_of_Incident__c = Datetime.now();
            c1.Affected_Programs__c = 'University College London';
            Database.insert(c1);
            
            
           // Contact ctc1 = apexMockDataUtility.createContact('Test', acct.Id);
            
            List<Case_Country__c> ccountrylist = new List<Case_Country__c>();
            Case_Country__c ccountry = new Case_Country__c();
            ccountry.Country__c = ctry.Id;
            ccountry.CurrencyIsoCode = 'USD';
            ccountry.Case__c = c1.Id;
            ccountrylist.add(ccountry);
           Database.insert(ccountrylist);
            
//caseService cseinstance =  new caseService();
          caseService.LinkStudentsToCountryCase(ccountrylist);
                
        }
    }
    
    @isTest
    public static void linkStudentsToCityCase1(){
         User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
           List <Case_City__c> ccity = new List<Case_City__c>();
            Case_City__c city = new Case_City__c();
            city.CurrencyIsoCode ='USD';
            ccity.add(city);
            Database.Insert(ccity);
            caseService.linkStudentsToCityCase(ccity);
        }
    }
     /*@isTest
    public static void generateCaseTeam1(){
        
         User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
        
        Case case1 = new Case();

        case1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();

        case1.Status = 'New';

       // case1.Student__c = app.Applicant__c;

        case1.Date_Time_of_Incident__c = DateTime.now();

        case1.Incident_Category__c = 'Conduct';

        case1.Incident_Sub_Category__c = 'Arrest/Allegation';

        case1.Incident_Sub_Subcategory__c = 'Arson';

        case1.Subject = 'IFSA Case Controller Test';

        case1.Incident_Severity__c = 'Critical';

        //case1.Description = caseDescription;

       // case1.Add_Case_Comment__c = caseComment;

        Database.insert(case1);
            
            
            Contact cont = new Contact();
            cont.Lastname= 'Test';
            cont.firstName = 'simple';
            Database.Insert(cont);
            
           List<Case_Student__c> cstudent = new List<Case_Student__c>();
            Case_Student__c cstu = new Case_Student__c();
            cstu.CurrencyIsoCode = 'USD';
            cstu.Case__c = case1.Id;
            cstu.Student__c = cont.Id;
            cstudent.add(cstu);
            DataBase.Insert(cstudent);
            
          /*  Account acct = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId());

            acct.Name = 'Test';
                
                Database.insert(acct);
            
            Contact ctc = new Contact(

            LastName = 'Test',

            AccountId = acct.Id,

            Email = 'test' + Math.random() + '@ifsa-butler.org',

            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId()

        );

Database.insert(ctc);

		//List<Application__c> applist = new  List<Application__c>();
		Application__c application = new Application__c(

            Name = 'Unit Test Application',

            Status__c = 'Registered',

            Applicant__c = ctc.Id
            

        );
		//applist.add(application);
        Database.insert(application);*/
            
            
            
            //caseService.generateCaseTeam(cstudent);
            //Boolean testq = caseService.generateCaseTeam(case1, cstudent, new List<Id>{application.Id});
            
     //   }
   // }
    
     @isTest
    public static void generateCaseTeam1(){
        
        
         User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            
            Case case1 = new Case();

        case1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();

        case1.Status = 'New';

       // case1.Student__c = app.Applicant__c;

        case1.Date_Time_of_Incident__c = DateTime.now();

        case1.Incident_Category__c = 'Conduct';

        case1.Incident_Sub_Category__c = 'Arrest/Allegation';

        case1.Incident_Sub_Subcategory__c = 'Arson';

        case1.Subject = 'IFSA Case Controller Test';

        case1.Incident_Severity__c = 'Critical';

        //case1.Description = caseDescription;

       // case1.Add_Case_Comment__c = caseComment;

        Database.insert(case1);
            
            
             Contact cont = new Contact();
            cont.Lastname= 'Test';
            cont.firstName = 'simple';
            Database.Insert(cont);
            
            List<Application__c> Applist = new List<Application__c>();
            Application__c appli = new Application__c();
            appli.CurrencyIsoCode ='USD';
            appli.Applicant__c = cont.Id;
            Applist.add(appli);
           Database.insert(Applist);
            
           List<Case_Student__c> listStudCase = caseService.getAffectedStudents(Applist,case1) ;
        }
        
    }
    
    @isTest
    public static void generateCaseTeam2(){
        
         BaseTriggerHandler.bypass('applicationTriggerHandler');
        
        User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            
             Case case2 = new Case();

        case2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();

        case2.Status = 'New';

       // case1.Student__c = app.Applicant__c;

        case2.Date_Time_of_Incident__c = DateTime.now();

        case2.Incident_Category__c = 'Conduct';

        case2.Incident_Sub_Category__c = 'Arrest/Allegation';

        case2.Incident_Sub_Subcategory__c = 'Arson';

        case2.Subject = 'IFSA Case Controller Test';

        case2.Incident_Severity__c = 'Critical';

        //case1.Description = caseDescription;

       // case1.Add_Case_Comment__c = caseComment;

        Database.insert(case2);
            
            Contact cont = new Contact();
            cont.Lastname= 'Test';
            cont.firstName = 'simple';
            Database.Insert(cont);
            
            List<Case_Student__c> cstudent = new List<Case_Student__c>();
            Case_Student__c cstu = new Case_Student__c();
            cstu.CurrencyIsoCode = 'USD';
            cstu.Case__c = case2.Id;
            cstu.Student__c = cont.Id;
            cstudent.add(cstu);
            DataBase.Insert(cstudent);
            
            List<Application__c> Applist = new List<Application__c>();
            Application__c appst = new Application__c();
            appst.Applicant__c = cont.Id;
            appst.CurrencyIsoCode = 'USD';
            Applist.add(appst);
            Application__c applisttId = [select Id From Application__c LIMIT 1];
            Case ccc=[SELECT Id FROM Case];
            Boolean result =  CaseService.generateCaseTeam(ccc,cstudent,new List<Id>{applisttId.Id}); 
        }
    }
    
    
}