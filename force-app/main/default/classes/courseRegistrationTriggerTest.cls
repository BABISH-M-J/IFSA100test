@isTest
public without sharing class courseRegistrationTriggerTest 
{
    @TestSetup
    static void makeData(){
        apexMockDataUtility.createIfsaDataCollection(new Set<String>{'Courses'});
    }
    @IsTest
    static void testGradeConversionNumber(){
        Application__c app = [SELECT Id, Program_Term__r.Program__r.Host_Institution__c FROM Application__c LIMIT 1];
        Course__c course = [SELECT Id, Butler_Department_Code__c FROM Course__c LIMIT 1];
        Butler_Department_Code__c code = new Butler_Department_Code__c(Id = course.Butler_Department_Code__c);
        Course_Registration__c cr = apexMockDataUtility.createCourseRegistration(course.Id, app.Id, code);
        
        // Added this code by Vinod Powerfluence on <10/8/2021> for fixing the error and code coverage
        list<Host_Institution__c> hostlist = new list<Host_Institution__c>();
        List<Host_Institution__c> hi   =[select Id, Credit_Conversion_JSON__c from Host_Institution__c where Id  =: app.Program_Term__r.Program__r.Host_Institution__c];
        for(Host_Institution__c host1 :hi){
            host1.credit_conversion_JSON__c ='[{"StartDate":"2021-09-20","IsActive":true,"EndDate":null,"Conversions":[{"USSemesterCreditHours":5,"HostInstitutionCredits":10}],"ActiveTerms":["Spring","Summer","Fall"]}]';
            hostlist.add(host1);
        }
        DataBase.update (hostlist);
        Grade_Conversion__c gc = new Grade_Conversion__c(
            Host_Institution__c = [SELECT Id,Name ,Credit_Conversion_JSON__c FROM Host_Institution__c WHERE Id =: app.Program_Term__r.Program__r.Host_Institution__c].Id,
            Type__c = 'Number Range',
            Grade_A__c = '93 - 100',
            Grade_A_Minus__c = '90 - 92',
            Grade_B_Plus__c = '87 - 89',
            Grade_B__c = '83-86',
            Grade_B_Minus__c = '82-80',
            Grade_C_Plus__c = '77 - 79',
            Grade_C__c = '73-76',
            Grade_C_Minus__c = '72-70',
            Grade_D_Plus__c = '67 - 69',
            Grade_D__c = '63-66',
            Grade_D_Minus__c = '62-60',
            Grade_F__c = '59-0',
            Sections__c = 'Spring;Summer;Fall;',
            Start_Date__c = Date.today().addDays(-10)
        );
		system.debug('gc35--'+gc);
        Database.insert(gc);
        Test.startTest();
        cr.Host_Institution_Grade__c = '88';
        cr.Status__c = 'Approved';
        cr.Host_Institution__c = app.Program_Term__r.Program__r.Host_Institution__c;
        database.update(cr);
        Test.stopTest();
        cr = [SELECT Id, Final_Grade__c, Status__c FROM Course_Registration__c WHERE Id =: cr.Id];
       System.assertEquals('B+', cr.Final_Grade__c);
    }

    @IsTest
    static void testGradeConversionLetter(){
        Application__c app = [SELECT Id, Program_Term__r.Program__r.Host_Institution__c FROM Application__c LIMIT 1];
        Course__c course = [SELECT Id, Butler_Department_Code__c FROM Course__c LIMIT 1];
        Butler_Department_Code__c code = new Butler_Department_Code__c(Id = course.Butler_Department_Code__c);
        Course_Registration__c cr = apexMockDataUtility.createCourseRegistration(course.Id, app.Id, code);
        // Added this code by Vinod Powerfluence on <10/8/2021> for fixing the error and code coverage
         list<Host_Institution__c> hostlist = new list<Host_Institution__c>();
        List<Host_Institution__c> hi   =[select Id, Credit_Conversion_JSON__c from Host_Institution__c where Id  =: app.Program_Term__r.Program__r.Host_Institution__c];
 
        for(Host_Institution__c host1 :hi){
            host1.credit_conversion_JSON__c ='[{"StartDate":"2021-09-20","IsActive":true,"EndDate":null,"Conversions":[{"USSemesterCreditHours":5,"HostInstitutionCredits":10}],"ActiveTerms":["Spring","Summer","Fall"]}]';
            
            hostlist.add(host1);
        }
        DataBase.update (hostlist);
        system.debug('hostlist---103' + hostlist);
        Grade_Conversion__c gc = new Grade_Conversion__c(
            Host_Institution__c = [SELECT Id FROM Host_Institution__c WHERE Id =: app.Program_Term__r.Program__r.Host_Institution__c].Id,
            Type__c = 'Letter Grade',
            Grade_A__c = 'A+, A',
            Grade_A_Minus__c = 'A-',
            Grade_B_Plus__c = 'B+',
            Grade_B__c = 'B',
            Grade_B_Minus__c = 'B-',
            Grade_C_Plus__c = 'C+',
            Grade_C__c = 'C',
            Grade_C_Minus__c = 'C-',
            Grade_F__c = 'F',
            Sections__c = 'Spring;Summer;Fall;',
            Start_Date__c = Date.today().addDays(-10)
        );
        Database.insert(gc);
        Test.startTest();
        cr.Host_Institution_Grade__c = 'A+';
        cr.Status__c = 'Approved';
        cr.Host_Institution__c = app.Program_Term__r.Program__r.Host_Institution__c;
        database.update(cr);
        Test.stopTest();
        cr = [SELECT Id, Final_Grade__c, Status__c FROM Course_Registration__c WHERE Id =: cr.Id];
        System.assertEquals('A', cr.Final_Grade__c);
    }

    @IsTest
    static void testGradeUnlistedOption(){
        Application__c app = [SELECT Id, Program_Term__r.Program__r.Host_Institution__c  FROM Application__c Limit 1];
        // Added this code by Vinod Powerfluence on <10/8/2021> for fixing the error and code coverage
        list<Host_Institution__c> hostlist = new list<Host_Institution__c>();
        List<Host_Institution__c> hi   =[select Id, Credit_Conversion_JSON__c from Host_Institution__c where Id  =: app.Program_Term__r.Program__r.Host_Institution__c];
         for(Host_Institution__c host1 :hi){
            host1.credit_conversion_JSON__c ='[{"StartDate":"2021-09-20","IsActive":true,"EndDate":null,"Conversions":[{"USSemesterCreditHours":5,"HostInstitutionCredits":10}],"ActiveTerms":["Spring","Summer","Fall"]}]';
            hostlist.add(host1);
        }
        DataBase.update (hostlist);
        Course__c course = [SELECT Id, Butler_Department_Code__c FROM Course__c LIMIT 1];
        Butler_Department_Code__c code = new Butler_Department_Code__c(Id = course.Butler_Department_Code__c);
        Course_Registration__c cr = apexMockDataUtility.createCourseRegistration(course.Id, app.Id, code);
        Grade_Conversion__c gc = new Grade_Conversion__c(
            Host_Institution__c = [SELECT Id FROM Host_Institution__c WHERE Id =: app.Program_Term__r.Program__r.Host_Institution__c].Id,
            Type__c = 'Letter Grade',
            Grade_A__c = 'A+, A',
            Grade_A_Minus__c = 'A-',
            Grade_B_Plus__c = 'B+',
            Grade_B__c = 'B',
            Grade_B_Minus__c = 'B-',
            Grade_C_Plus__c = 'C+',
            Grade_C__c = 'C',
            Grade_C_Minus__c = 'C-',
            Grade_F__c = 'F',
            Sections__c = 'Spring;Summer;Fall;',
            Start_Date__c = Date.today().addDays(-10)
            
        );      
        Database.insert(gc);
        Test.startTest();
        cr.Host_Institution_Grade__c = 'W';
        cr.Status__c = 'Approved';
        cr.Host_Institution__c = app.Program_Term__r.Program__r.Host_Institution__c;
        database.update(cr);
        Test.stopTest();
        cr = [SELECT Id, Final_Grade__c, Status__c FROM Course_Registration__c WHERE Id =: cr.Id];
        System.assertEquals('W', cr.Final_Grade__c);
    }    
}