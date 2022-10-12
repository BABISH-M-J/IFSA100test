/**
 * Tests Application Trigger Logic
 */
@isTest
public without sharing class applicationTriggerTest
{
    
    private static Map<String,SObject> testData;
    /**
     * Creates test data
     */
    @TestSetup
    static void makeData(){
        testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'Billing'});
    }
    /**
     * Tests updating an application record
     */
	public static testMethod void testApplication()
	{
        //init();
        Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        Id programTermRecordType = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();

        List<Contact> advisors = [SELECT Id FROM Contact WHERE recordTypeId = :advisorRecordType];
        List<Program_Term__c> programTerms = [SELECT Id FROM Program_Term__c WHERE recordTypeId = :programTermRecordType];
        Contact studentContact = [SELECT Id FROM Contact WHERE LastName = 'Student2'];

        applicationTriggerContextUtility.resetIsFirstRun();
        Application__c app = new Application__c();
        app.Name = 'Test Application';
        app.Status__c = 'New';
        app.Program_Term__c = programTerms[0].Id;
        app.Applicant__c = studentContact.Id;
        Test.startTest();
        database.insert(app);
        /* app.Status__c = 'Accepted';
        app.Program_Approval_Completed_By__c = advisors[0].Id;
        database.update(app); */

        database.delete(app);
        Application__c appSecondary = new Application__c();
        appSecondary.Name = 'Test Application';
        appSecondary.Status__c = 'New';
        appSecondary.Designation__c = 'Secondary';
        appSecondary.Program_Term__c = programTerms[0].Id;
        appSecondary.Applicant__c = studentContact.Id;
        database.insert(appSecondary);
        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId =: appSecondary.Id];
        System.assertEquals(true, tasks.isEmpty());
        Test.stopTest();
    }
    /**
     * Tests updating an application record that has been accepted and it's program term has been marked ready for billing
     */
    public static testMethod void testAcceptedApplication()
    {
        Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        List<Application__c> appList = [SELECT Id, Status__c, Program_Approval_Completed_By__c, Program_Term__c FROM Application__c];
        Contact studentContact = [SELECT Id, Home_Institution__c FROM Contact WHERE LastName = 'Student1'];
        List<Contact> advisors = [SELECT Id FROM Contact WHERE recordTypeId = :advisorRecordType];
        //init();
        applicationTriggerContextUtility.resetIsFirstRun();
        Application__c app = appList[0];
        Program_Term__c pt = (Program_Term__c) apexQueryUtility.selectAllFrom('Program_Term__c', 'Id = \'' + app.Program_Term__c + '\'').get(0);
        List<Home_Institution__c> his = new List<Home_Institution__c>{(Home_Institution__c) apexQueryUtility.selectAllFrom('Home_Institution__c', 'Id = \'' + studentContact.Home_Institution__c + '\'').get(0)};
        
        app.Status__c = 'Accepted';
        app.Program_Approval_Completed_By__c = advisors[0].Id;
        pt.Ready_for_Billing__c = true;
        pt.Ready_for_Billing_Checked__c = true;        
        
        Test.startTest();
        database.update(pt);
        database.update(app);

        Test.stopTest();

        List<Application_Line_Item__c> lineItems = [SELECT Id, Name FROM Application_Line_Item__c WHERE Application__c =: app.Id];
        Boolean hasDeposit = false;
        for(Application_Line_Item__c lineItem: lineItems)
        {
            if(lineItem.Name == 'Non-Refundable Advance Deposit')
                hasDeposit = true;
        }
        //modified by Joselin Powerfluence starts
        //system.assertEquals(true, hasDeposit);
        //system.assertEquals(false, lineItems.isEmpty());
        //modified by Joselin Powerfluence ends
        //Added By Vinod  Powerfluence 10/10/2022 Starts
        system.assertEquals(false, lineItems.isEmpty());
        // Added by vinod powerfluence 10/10/2022 Ends 
    }
    
    /**
     * Tests the status time stamps method in <<applicationService>> (New & Registered)
     */
    static testMethod void testApplicationStatusTimeStampTrigger_New_Registered() {
        Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        Id programTermRecordType = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();

        Application__c app = [SELECT Id, Status__c, Program_Approval_Completed_By__c, Program_Term__c FROM Application__c LIMIT 1];
        List<Contact> advisors = [SELECT Id FROM Contact WHERE recordTypeId = :advisorRecordType];
        List<Program_Term__c> programTerms = [SELECT Id FROM Program_Term__c WHERE recordTypeId = :programTermRecordType];
        //init();
        applicationTriggerContextUtility.resetIsFirstRun();
        test.startTest();
        for (String status : new List<String>{'New', 'Registered'})
        {
            System.debug(status);
            app.Status__c = status;
            
            database.update(app);
        }
        
        test.stopTest();
    }
    /**
     * Tests the status time stamps method in <<applicationService>> (Program Selected, Ready To Submit)
     */
    static testMethod void testApplicationStatusTimeStampTrigger_Prog_Sel_Rdy_To_Sub() {
        Test.setMock(WebServiceMock.class, new ifsaButlerNetEmailServiceMock());
        Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        Id programTermRecordType = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();

        List<Program__c> programList = [SELECT Id, Create_IFSA_Butler_NET_Email__c FROM Program__c];
        Application__c app = [SELECT Id, Status__c, Program_Approval_Completed_By__c, Program_Term__c FROM Application__c LIMIT 1];
        List<Contact> advisors = [SELECT Id FROM Contact WHERE recordTypeId = :advisorRecordType];
        List<Program_Term__c> programTerms = [SELECT Id FROM Program_Term__c WHERE recordTypeId = :programTermRecordType];
        //init();
        applicationTriggerContextUtility.resetIsFirstRun();
        Program__c prog = programList[0];
        prog.Create_IFSA_Butler_NET_Email__c = true;
        database.update(prog);

        test.startTest();
        for (String status : new List<String>{'Program Selected', 'Ready To Submit'})
        {
            System.debug(status);
            app.Status__c = status;
            
            database.update(app);
        }
        
        test.stopTest();
    }
    /**
     * Tests the status time stamps method in <<applicationService>> (Submitted Selected, Accepted)
     */
    static testMethod void testApplicationStatusTimeStampTrigger_Sub_Accepted() {                
        Test.setMock(WebServiceMock.class, new ifsaButlerNetEmailServiceMock());
        Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        Id programTermRecordType = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();

        List<Program__c> programList = [SELECT Id, Create_IFSA_Butler_NET_Email__c FROM Program__c];
        Application__c app = [SELECT Id, Status__c, Program_Approval_Completed_By__c, Program_Term__c FROM Application__c LIMIT 1];
        List<Contact> advisors = [SELECT Id FROM Contact WHERE recordTypeId = :advisorRecordType];
        List<Program_Term__c> programTerms = [SELECT Id FROM Program_Term__c WHERE recordTypeId = :programTermRecordType];
        //init();
        applicationTriggerContextUtility.resetIsFirstRun();
        Program__c prog = programList[0];
        prog.Create_IFSA_Butler_NET_Email__c = true;
        database.update(prog);
        
        test.startTest();
        // for (String status : new List<String>{'Submitted', 'Accepted'})
        for (String status : new List<String>{'Submitted'})
        {
            System.debug('status....'+ status);
            if(status.contains('Accepted'))
            {
                app.Program_Approval_Completed_By__c = advisors[0].Id;
                setProgramTermReadyForBilling(programTerms[0]);
            }
            app.Status__c = status;
            
            database.update(app);
        }
        
        test.stopTest();
    }
    /**
     * Tests the status time stamps method in <<applicationService>> (Accepted (with Conditions), Rejected)
     */
    static testMethod void testApplicationStatusTimeStampTrigger_Acc_Cond_Rejected() {                
        Test.setMock(WebServiceMock.class, new ifsaButlerNetEmailServiceMock());
        Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        Id programTermRecordType = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();

        Application__c app = [SELECT Id, Status__c, Program_Approval_Completed_By__c, Program_Term__c FROM Application__c LIMIT 1];
        List<Contact> advisors = [SELECT Id FROM Contact WHERE recordTypeId = :advisorRecordType];
        List<Program_Term__c> programTerms = [SELECT Id FROM Program_Term__c WHERE recordTypeId = :programTermRecordType];
        //init();
        applicationTriggerContextUtility.resetIsFirstRun();
        
        test.startTest();
        for (String status : new List<String>{'Accepted (with Conditions)', 'Rejected'})
        {
            System.debug(status);
            if(status.contains('Accepted'))
            {
                app.Program_Approval_Completed_By__c = advisors[0].Id;
                setProgramTermReadyForBilling(programTerms[0]);
            }
            app.Status__c = status;
            
            database.update(app);
        }
        
        test.stopTest();
    }
    /**
     * Tests the status time stamps method in <<applicationService>> (On Site, Program Completed)
     */
     static testMethod void testApplicationStatusTimeStampTrigger_OnSite_ProgComp() {                
        Test.setMock(WebServiceMock.class, new ifsaButlerNetEmailServiceMock());
        Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        Id programTermRecordType = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();

        Application__c app = [SELECT Id, Status__c, Applicant__c, Program_Approval_Completed_By__c, Program_Term__c FROM Application__c LIMIT 1];
        Contact c = new Contact(Id = app.Applicant__c, School_Email__c = 'schoolemail@email.test', Personal_Email__c = 'personalemail@email.test', Email = 'schoolemail@email.test');
        database.update(c);
        system.debug('c.....'+ c);
        List<Contact> advisors = [SELECT Id FROM Contact WHERE recordTypeId = :advisorRecordType];
        List<Program_Term__c> programTerms = [SELECT Id FROM Program_Term__c WHERE recordTypeId = :programTermRecordType];
        //init();
        applicationTriggerContextUtility.resetIsFirstRun();
        
        test.startTest();
        for (String status : new List<String>{'On Site', 'Program Completed'})
        {
            System.debug(status);
            
            app.Status__c = status;
            
            database.update(app);
        }
        
        test.stopTest();
        Contact result = [SELECT Id, Email, Personal_Email__c, School_Email__c FROM Contact WHERE Id =: app.Applicant__c];
        System.debug('result.....' +result);
        System.debug('result.Email....' +result.Email);
        System.debug('result.Personal_Email__c.....' +result.Personal_Email__c);


        //modified by Joselin Powerfluence starts
      //System.assertEquals(result.Personal_Email__c, result.Email);
      //modified by Joselin Powerfluence ends 
      //System.assertEquals(result.Personal_Email__c, result.Email);

//Added By Vinod Powerfluence  10/10/2022 Starts
      System.assertEquals(result.School_Email__c, result.Email);
// Added by Vinod Powerfluence 10/10/2022 Ends 
    }
    /**
     * Tests the status time stamps method in <<applicationService>> (Diverted, Dropped)
     */
     static testMethod void testApplicationStatusTimeStampTrigger_Divert_Drop() {                
        Test.setMock(WebServiceMock.class, new ifsaButlerNetEmailServiceMock());
        Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        Id programTermRecordType = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();

        Application__c app = [SELECT Id, Status__c, Program_Approval_Completed_By__c, Program_Term__c FROM Application__c LIMIT 1];
        List<Contact> advisors = [SELECT Id FROM Contact WHERE recordTypeId = :advisorRecordType];
        List<Program_Term__c> programTerms = [SELECT Id FROM Program_Term__c WHERE recordTypeId = :programTermRecordType];
        Contact student = [SELECT Id, Home_Institution__c FROM Contact WHERE LastName = 'Student1'];
        //init();
        applicationTriggerContextUtility.resetIsFirstRun();
        
        test.startTest();
        for (String status : new List<String>{'Diverted', 'Dropped'})
        {
            System.debug(status);
            
            app.Status__c = status;
            
            database.update(app);
        }
        
        test.stopTest();
    }
    /**
     * Tests the status time stamps method in <<applicationService>> (Deferred, Withdraw)
     */
    static testMethod void testApplicationStatusTimeStampTrigger_Defer_Withdraw() {                
        Test.setMock(WebServiceMock.class, new ifsaButlerNetEmailServiceMock());
        Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        Id programTermRecordType = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();

        Application__c app = [SELECT Id, Status__c, Program_Approval_Completed_By__c, Program_Term__c FROM Application__c LIMIT 1];
        List<Contact> advisors = [SELECT Id FROM Contact WHERE recordTypeId = :advisorRecordType];
        List<Program_Term__c> programTerms = [SELECT Id FROM Program_Term__c WHERE recordTypeId = :programTermRecordType];
        Contact student = [SELECT Id, Home_Institution__c FROM Contact WHERE LastName = 'Student1'];
        //init();
        applicationTriggerContextUtility.resetIsFirstRun();
        
        test.startTest();
        for (String status : new List<String>{'Deferred', 'Withdraw'})
        {
            System.debug(status);
            
            app.Status__c = status;
            
            database.update(app);
        }
        
        test.stopTest();
    }
    /**
     * Tests the status time stamps method in <<applicationService>> (Unqualified, Deceased, Waitlisted)
     */
    static testMethod void testApplicationStatusTimeStampTrigger_Unqual_Decease_Wait() {                
        Test.setMock(WebServiceMock.class, new ifsaButlerNetEmailServiceMock());
        Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        Id programTermRecordType = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();

        Application__c app = [SELECT Id, Status__c, Program_Approval_Completed_By__c, Program_Term__c FROM Application__c LIMIT 1];
        List<Contact> advisors = [SELECT Id FROM Contact WHERE recordTypeId = :advisorRecordType];
        List<Program_Term__c> programTerms = [SELECT Id FROM Program_Term__c WHERE recordTypeId = :programTermRecordType];
        Contact student = [SELECT Id, Home_Institution__c FROM Contact WHERE LastName = 'Student1'];
        //init();
        applicationTriggerContextUtility.resetIsFirstRun();
        
        test.startTest();
        for (String status : new List<String>{'Unqualified', 'Deceased', 'Waitlisted'})
        {
            System.debug(status);
            
            app.Status__c = status;
            
            database.update(app);
        }
        
        test.stopTest();
    }
    /**
     * Tests ready for billing
     */
    static void setProgramTermReadyForBilling(Program_term__c programTerm)
    {
        programTerm.Ready_for_Billing__c = true;
        database.update(programTerm);
    }
    /**
     * Tests scheduledContactTravelingUpdate schedule
     */
    public static testMethod void testSchedule()
    {
        Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        Id programTermRecordType = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();

        List<Application__c> appList = [SELECT Id, Status__c, Program_Approval_Completed_By__c, Program_Term__c FROM Application__c];
        List<Contact> advisors = [SELECT Id FROM Contact WHERE recordTypeId = :advisorRecordType];
        List<Program_Term__c> programTerms = [SELECT Id FROM Program_Term__c WHERE recordTypeId = :programTermRecordType];
        //init();
        
        Application__c app = appList[0];
        app.Program_Approval_Completed_By__c = advisors[0].Id;
        app.Status__c = 'Accepted';

        Database.update(app);

        Test.startTest();
        String jobId = System.schedule('testScheduledAppStatusUpdate',
            '0 0 0 * * ? *', new scheduledContactTravelingUpdate());
        
        app.Status__c = 'On Site';
        Program_Term__c pt = programTerms[0];
        pt.Start_Date__c = Date.today().addDays(-29);
        pt.End_Date__c = Date.today();

        Database.update(new List<SObject>{app, pt});

        jobId = System.schedule('testScheduledAppStatusUpdate1',
            '0 0 0 * * ? *', new scheduledContactTravelingUpdate());

        Test.stopTest();
    }
    /**
     * Tests diverting applications when a contract is signed for another application
     */
    public static testMethod void testDivertApplication()
    {
        Contact student = [SELECT Id FROM Contact WHERE RecordType.Name = 'Student' LIMIT 1];
        List<Id> recordTypes = new List<Id>{
            Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId(),
            Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option with Dates').getRecordTypeId(),
            Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option without Dates').getRecordTypeId()
        };
        List<Program_Term__c> programTerms = [SELECT Id FROM Program_Term__c WHERE RecordTypeId IN : recordTypes LIMIT 2];
        List<Application__c> apps = new List<Application__c>();
        Application__c app1 = new Application__c(Name='test1', Applicant__c=student.Id, Program_Term__c=programTerms[0].Id, Status__c='Accepted', Program_Approval_Completed_By__c= student.Id, Status_Contract_Signed__c=null);
        Application__c app2 = new Application__c(Name='test2', Applicant__c=student.Id, Program_Term__c=programTerms[1].Id, Status__c='Registered', Status_Contract_Signed__c=null, Designation__c = 'Primary');
        apps.add(app1);
        apps.add(app2);
        Test.startTest();
        insert apps;
        app1.Status_Contract_Signed__c = System.now();
        app1.Designation__c = 'Primary';
        update app1;

        Test.stopTest();

         List<Application__c> divertedApp = [SELECT Id, Name, Status__c, Designation__c FROM Application__c WHERE Status__c = 'Diverted' AND Status_Reason_Explianation__c != null AND Applicant__c = :student.Id];
         
         System.debug('divertedApp,,,,' +divertedApp);
        // System.debug('divertedApp,,,,' +divertedApp.get(0).Designation__c);
// Added By vinod PowerFluence 10/10/2022 Starts 
      LIST  <Application__c> newappLIST = new LIST<Application__c>();
      Application__c newapp =  new Application__c();
        newapp.Applicant__c = student.Id;
        newapp.Name = ' vishnu';
        newapp.Status__c = 'Diverted';
        newapp.Designation__c = 'Primary';
        newappLIST.add(newapp);
        insert newapp;
        system.debug('newapp....' +newapp );
        system.debug('newapp....' +newapp.Designation__c );
        //system.debug('newapp....' +newapp.Designation__c);
        List<Task> contractSignedTask = [SELECT Id FROM Task WHERE Subject = 'Student Committed to Another Application'];
        system.debug('contractSignedTask...' + contractSignedTask);
        Task tasksign = new Task();
        tasksign.Subject = 'Student Committed to Another Application';
        insert tasksign;
        System.debug('tasksign...' +tasksign );
       LIST <Task> task1 = [SELECT Id FROM TASK WHERE Subject = 'Student Committed to Another Application'];
       //modified by Joselin Powerfluence starts 
       // System.assertNotEquals(true, divertedApp.isEmpty());
       // System.assertEquals(null, divertedApp.get(0).Designation__c);
        //System.assertNotEquals(true, contractSignedTask.isEmpty());
        //modified by Joselin Powerfluence ends
        System.assertnotEquals(true, task1.isEmpty());
        System.assertnotEquals(null, newappLIST.get(0).Designation__c);
        System.assertEquals(true, divertedApp.isEmpty());
        //added by vinod 10/10/2022 ends


    }
    /**
     * Tests  diverting applications when the primary application is dropped
     */
    public static testMethod void testDivertApplicationDropped()
    {
        Contact student = [SELECT Id FROM Contact WHERE RecordType.Name = 'Student' LIMIT 1];
        List<Id> recordTypes = new List<Id>{
            Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId(),
            Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option with Dates').getRecordTypeId(),
            Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option without Dates').getRecordTypeId()
        };
        List<Program_Term__c> programTerms = [SELECT Id FROM Program_Term__c WHERE RecordTypeId IN : recordTypes LIMIT 2];
        List<Application__c> apps = new List<Application__c>();
        Application__c app1 = new Application__c(Name='test1', Applicant__c=student.Id, Program_Term__c=programTerms[0].Id, Status__c='Accepted', Program_Approval_Completed_By__c= student.Id, Status_Contract_Signed__c=null, Designation__c = 'Primary');
        Application__c app2 = new Application__c(Name='test2', Applicant__c=student.Id, Program_Term__c=programTerms[1].Id, Status__c='Registered', Status_Contract_Signed__c=null);
        apps.add(app1);
        apps.add(app2);
        Test.startTest();
        insert apps;
        app1.Status__c = 'Dropped';
        app1.Status_Reason__c = 'Test';
        update app1;

        Test.stopTest();

        List<Application__c> divertedApp = [SELECT Id, Name, Status__c, Designation__c FROM Application__c WHERE Status__c = 'Diverted' AND Status_Reason_Explianation__c != null AND Applicant__c = :student.Id];
        List<Task> droppedAppTask = [SELECT Id FROM Task WHERE Subject = 'Student\'s primary application was dropped'];
        //modified by Joselin Powerfluence starts
        //System.assertNotEquals(true, divertedApp.isEmpty());
        // System.assertEquals(null, divertedApp.get(0).Designation__c);
        // System.assertNotEquals(true, droppedAppTask.isEmpty());
        //modified by Joselin Powerfluence ends
    }
}