@isTest
public class caseTriggerHandler_Test {
    
    @testSetup
    static void mockData(){
        
        BaseTriggerHandler.bypass('applicationTriggerHandler');
        
        List<Case_Program__c> cprogram = new  List<Case_Program__c>();
        Case_Program__c cpro = new Case_Program__c();
        cpro.CurrencyIsoCode = 'USD';
        cprogram.add(cpro);
        Database.insert(cprogram);
        
        
        Contact cont = new Contact();
            cont.Lastname= 'Test';
            cont.firstName = 'simple';
            Database.Insert(cont);
        
       /* List<Case_Student__c> cstudent = new List<Case_Student__c>();
            Case_Student__c cstu = new Case_Student__c();
            cstu.CurrencyIsoCode = 'USD';
            cstu.Case__c = case1.Id;
            cstu.Reason_Affected__c = 'Tour';
            cstu.Student__c = cont.Id;
            
            cstudent.add(cstu);
            DataBase.Insert(cstudent);*/
        
        
      //  Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
        World__c wrd = new World__c();
        wrd.Name ='test';
        wrd.CurrencyIsoCode = 'USD';
        insert wrd;
        
        Region__c   reg = new Region__c ();
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
        
        Locality__c l = new Locality__c(Name = 'London', Country__c = c.Id, CurrencyIsoCode = 'USD', RecordTypeId = Schema.SObjectType.Locality__c.getRecordTypeInfosByName().get('City/Town').getRecordTypeId() );
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
        
         
            
            
       
           Application__c appli = new Application__c();
            appli.CurrencyIsoCode ='USD';
            appli.Applicant__c = cont.Id;
       
           Database.insert(appli );
         
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
            
            Case_Country__c ccountry = new Case_Country__c();
            ccountry.Country__c = c.Id;
            ccountry.CurrencyIsoCode = 'USD';
            ccountry.Case__c = c1.Id;
           Database.insert(ccountry);  
           
          
            Case_City__c city = new Case_City__c();
            city.CurrencyIsoCode ='USD';

            Database.Insert(city );
            
            
              
            Case case1 = new Case();

        case1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();

        case1.Status = 'New';
        case1.Student__c=cont.Id;

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
        
        List<Case_Student__c> cstudent = new List<Case_Student__c>();
            Case_Student__c cstu = new Case_Student__c();
            cstu.CurrencyIsoCode = 'USD';
            cstu.Case__c = case1.Id;
            cstu.Reason_Affected__c = 'Tour';
            cstu.Student__c = cont.Id;
            
            cstudent.add(cstu);
            DataBase.Insert(cstudent);
        
       List<Host_Institution__c> hlist = new List <Host_Institution__c>();
        Host_Institution__c host = new Host_Institution__c();
        host.Country__c = c.Id;
        host.CurrencyIsoCode = 'USD';
        hlist.add(host);
        Database.Insert(hlist);
        
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
         Test.startTest();
        caseService.linkStudentsToHostInstitutionCase(chlist);
         Test.stopTest();
        }
    }
    
    @isTest
    public static void testInsertScenario1(){
       User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            
           Case_Country__c ccountrylist=[Select Id,Country__c,Country_Name__c,Case__c from Case_Country__c ];
            
          Test.startTest();
            

          caseService.LinkStudentsToCountryCase(new List<Case_Country__c >{ccountrylist});
            Test.stopTest();     
        }
    }
    
    @isTest
    public static void linkStudentsToCityCase1(){
         User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
        Case_City__c ccity=[Select Id , City__c, Case__c from Case_City__c];
           Test.startTest();
            
            caseService.linkStudentsToCityCase(new List<Case_City__c>{ccity});
             Test.stopTest();  
        }
    }

    
     @isTest
    public static void getAffectedStudents1(){
        
        
         User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
                  Id RId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();

            Case case1=[Select Id from Case where RecordTypeId =:RId];
            
            
            List<Application__c> Applist = new List<Application__c>();
            Applist=[Select Id,Applicant__c,Is_Custom__c,Applicant__r.Name,Applicant__r.Traveling_Status__c,Status__c from Application__c];
            
         
            
           List<Case_Student__c> listStudCase = caseService.getAffectedStudents(Applist,case1) ;
        }
        
    }
    

    
    @isTest
    public static void programCase1(){
        
         User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
             Case case3 = new Case();

        case3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();

        case3.Status = 'New';

       // case1.Student__c = app.Applicant__c;
            case3.Generate_Case_Team__c = false;
        case3.Date_Time_of_Incident__c = DateTime.now();

        case3.Incident_Category__c = 'Conduct';

        case3.Incident_Sub_Category__c = 'Arrest/Allegation';

        case3.Incident_Sub_Subcategory__c = 'Arson';

        case3.Subject = 'IFSA Case Controller Test';

        case3.Incident_Severity__c = 'Critical';

       //case1.Description = caseDescription;

       // case1.Add_Case_Comment__c = caseComment;
        
        Database.insert(case3);
             
            
            Program__c pr = [select Id,Name From Program__c];
            model_program nprogram = new model_program(pr);
               
            caseService.relatedToCase var = caseService.programCase(case3,new List<model_program>{nprogram},new List<String>{'Test'});
             
        }
        
    }
    
    @isTest
    public static void generateCaseTeam_test(){
         User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
         Id RId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();

            Case case1=[Select Id,RecordTypeId , Generate_Case_Team__c, Status,Incident_Sub_Subcategory__c,Incident_Severity__c,Incident_Category__c,Incident_Sub_Category__c from Case where RecordTypeId =:RId];
            
            case1.Generate_Case_Team__c=true;
            update case1;
                        List<Id> Applist = new List<Id>{[Select Id from Application__c].Id};
            Case_Student__c xe = [Select Id,CurrencyIsoCode,Case__c,Reason_Affected__c,Student__c From Case_Student__c];

           Test.startTest();
            
           // caseService.generateCaseTeam(new List<Case>{case1});
              caseService.generateCaseTeam(case1,new List<Case_Student__c>{xe},AppList);

             Test.stopTest();  
        }
    }    
   
    @isTest
    public static void setReasonAffected_test(){
         User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
    
            Case_Student__c xe = [Select Id,CurrencyIsoCode,Case__c,Reason_Affected__c From Case_Student__c];
            xe.Reason_Affected__c =null;
            update xe;
            Test.startTest();
              caseService.setReasonAffected(new List<Case_Student__c >{xe});
            Test.stopTest();  
            
            }
    }
    
    @isTest
    public static void studentCase_test(){
         User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
     Id RId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();

            Case case1=[Select Id,RecordTypeId , Student__c,Generate_Case_Team__c from Case where RecordTypeId =:RId];
              Application__c app=[Select Id,Applicant__c,Status__c from Application__c];
            app.Applicant__c = case1.Student__c;
            app.Status__c='On Site';
            update app;
            Test.startTest();
              caseService.studentCase(case1, true, new List<String >{'Traveling','On Site'});
               caseService.studentCase(case1, false, new List<String >{'Traveling','On Site'});
            Test.stopTest();  
           
            
            
            }
    }
    
      @isTest
    public static void linkStudentsToStudentCase_test(){
         User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
     Id RId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();

            Case case1=[Select Id,RecordTypeId , Student__c,Generate_Case_Team__c from Case where RecordTypeId =:RId];
          Application__c app=[Select Id,Applicant__c,Status__c from Application__c];
            app.Applicant__c = case1.Student__c;
            app.Status__c='On Site';
            update app;
            Test.startTest();
              caseService.linkStudentsToStudentCase(new List<Case>{case1});
              
            Test.stopTest();  
           
            
            
            }
    }
     @isTest
    public static void linkStudentsToProgramCase_test(){
        
        User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            Id RId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();
            
            Case case1=[Select Id,RecordTypeId , Student__c,Generate_Case_Team__c from Case where RecordTypeId =:RId];
            Case_Program__c  cpgm = [select Id, CurrencyIsoCode,Program__c,Case__c From Case_Program__c];
            Test.startTest();
            caseService.linkStudentsToProgramCase(new List<Case_Program__c>{cpgm});
            
            Test.stopTest();
            
        }
        
    }
    @isTest
    public static void generateCaseTeam_testwithcase(){
         User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            Id RId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();
            
            Case case1=[Select Id,RecordTypeId , Student__c,Generate_Case_Team__c from Case where RecordTypeId =:RId];
            case1.Generate_Case_Team__c=false;
            update case1;
            Test.startTest();
            caseService.generateCaseTeam(new List<Case>{case1});
            Test.stopTest();
    }
    }
    @isTest
    public static void countryCase_test(){
          User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
             Id RId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();
            
            Case case1=[Select Id,RecordTypeId , Student__c,Generate_Case_Team__c from Case where RecordTypeId =:RId];
            Test.startTest();
            Country__c cc = [select Id,Name,CurrencyIsoCode From Country__c LIMIT 1];
            
           model_country mc = new model_country(cc);
            caseService.countryCase(case1,new List<model_country>{mc},new List<String >{'On Site'});
            Test.stopTest();
            
        }
    }
    @isTest
    public static void cityCase_test(){
        User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            Id RId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();
            
            Case case1=[Select Id,RecordTypeId , Student__c,Generate_Case_Team__c from Case where RecordTypeId =:RId];
            Test.startTest();
            Locality__c loc = [select Id, Name,Country__c,CurrencyIsoCode, RecordTypeId From Locality__c LIMIT 1 ];
            model_city mCity = new model_city(loc);
            caseService.cityCase(case1,new List<model_city>{mCity},new List<String>{'On Site'});
            caseService.relatedToCase imp = new caseService.relatedToCase();
            imp.import(new caseService.relatedToCase());
            Test.stopTest();
        }
    }
    @isTest
    public static void createSFTicketToAddValueToPicklist_test(){
         User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            Test.startTest();
            caseService.createSFTicketToAddValueToPicklist('case','subject','Prem is beating');
            Test.stopTest();
            
        }
    }
    @isTest
    public static void hostCase_test(){
         User contextUser = [SELECT Id FROM User WHERE Profile.Name = 'IFSA Health and Safety User' AND IsActive = TRUE LIMIT 1].get(0);
        System.runAs(contextuser){
            Id RId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();
            
            Case case1=[Select Id,RecordTypeId , Student__c,Generate_Case_Team__c from Case where RecordTypeId =:RId];
            Host_Institution__c hlist = [select Id,Name,Country__c,CurrencyIsoCode From Host_Institution__c  LIMIT 1];
            Test.startTest();
            model_hostInstitution hin = new model_hostInstitution(hlist);
             caseService.hostCase(case1,new List<model_hostInstitution>{hin},new List<String>{'On Site'});
            Test.stopTest();
        }
    }
}