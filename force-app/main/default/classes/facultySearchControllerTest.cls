/**
 * Unit tests for <<facultySearchController>>
 * @author Brock Barlow
 */
// ApexDoc updated 2/4/2021 Brock Barlow
@isTest
private with sharing class facultySearchControllerTest {
    @TestSetup
    static void makeData(){
      Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
    }
    
    static facultySearchController controller;
    static facultySearchViewModel viewModel;
    
    static void init()
    {
        //Create Data Set
        Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        Contact advisor = [SELECT Id, AccountId FROM Contact WHERE recordTypeId = :advisorRecordType LIMIT 1];
        Support_Personnel__c sp = new Support_Personnel__c(Support_Role_Type__c = 'Advisor', Type__c = 'Non IFSA Staff', Non_IFSA_Staff__c = advisor.Id, Account__c = advisor.AccountId, Emergency_Contact__c = true,RecordTypeId = Schema.SObjectType.Support_Personnel__c.getRecordTypeInfosByName().get('Account').getRecordTypeId());
        Database.insert(sp);
        List<Application__c> apps = [SELECT Id FROM Application__c];
        List<SObject> objs = new List<SObject>();
        List<Term__c> terms = [SELECT Id, Year__c FROM Term__c];
        for(Term__c t: terms)
        {
            t.Year__c = Date.today().Year();
            objs.add(t);
        }
        // objs.add(student);
        for(Application__c app: apps)
        {
            app.Program_Approval_Completed_By__c = advisor.Id;
            app.Home_Institution_Advisor__c = advisor.Id;
            app.Status__c = 'On Site';
            objs.add(app);
        }
        Database.update(objs);
        //Intialize Controler
        controller = new facultySearchController();
        viewModel = controller.viewModel;
        String result;
        Integer i = 0;
        // Set the first filters
        for(model_term t: viewModel.terms)
        {
            if(i < 2)
                t.selectedInSearch = true;
            i = i++;
        }
        i = 0;
        for(model_country c: viewModel.countries)
        {
            if(i < 3)
                c.selectedInSearch = true;
            i = i++;
        }
    }
    @isTest/* (SeeAllData=true) */
    static void testUpdateFiltersSearchStudentsReset()
    {
        init();
        // Run upadate filter method
        String result = facultySearchController.updateFilters(viewModel.getSerializedViewModel());
        // Parse result back into viewModel
        Test.startTest();
        //viewModel = facultySearchViewModel.parseJSONString(result);
        
        // Search using json result from last update filter method
        result = facultySearchController.search(result);
        viewModel = facultySearchViewModel.parseJSONString(result);

        system.assertNotEquals(0, viewModel.facultyContacts.size());
        // Finally clear the filters
        result = facultySearchController.resetFilters(result);

        Test.stopTest();
    }

    static testMethod void testInstanceAndSearchHomeInstitutionsByName()
    {
        init();
        Test.startTest();

        String jsonString = viewModel.getSerializedViewModel();
        facultySearchController.searchHomeInstitutionByName(jsonString, 'Test');

        Test.stopTest();
    }

    static testMethod void testSelectSPandSendEmail()
    {
        init();
        String result = facultySearchController.updateFilters(viewModel.getSerializedViewModel());
        Test.startTest();
        List<Support_Personnel__c> facultyMSP = apexQueryUtility.selectAllFrom('Support_Personnel__c', 'Account__r.Name, RecordType.Name, Non_IFSA_Staff__r.LastName, Non_IFSA_Staff__r.Name', 'Account__c != NULL AND Non_IFSA_Staff__c != NULL LIMIT 1');
        List<model_support_personnel> sps = new List<model_support_personnel>();
        for(Support_Personnel__c sp: facultyMSP)
        {
            model_support_personnel mc = new model_support_personnel(sp);
            sps.add(mc);
        }

        viewModel.selectedFaculty = sps.get(0);
        result = facultySearchController.getStudents(viewModel.getSerializedViewModel());
        viewModel = facultySearchViewModel.parseJSONString(result);
        result = facultySearchController.getFacultyContact(result);
        
        Boolean emailSent = facultySearchController.sendEmailMessage('Test Message', 'Test Subject', sps.get(0).nonIfsaStaffId, null, null);
        System.assertEquals(true, emailSent);
        emailSent = facultySearchController.sendEmailMessage('Test Message', 'Test Subject', '', null, null);
        System.assertEquals(false, emailSent);
        Test.stopTest();
    }

    @isTest /*(SeeAllData=true)*/
    static void testUpdateAdditionalFilters()
    {
        init();
        String result = facultySearchController.updateFilters(viewModel.getSerializedViewModel());
        Integer i = 0;
        // Parse result back into viewModel
        Test.startTest();
        //viewModel = facultySearchViewModel.parseJSONString(result);
        // Set the next filters
        i = 0;
        for(model_city c: viewModel.cities)
        {
            if(i < 2)
                c.selectedInSearch = true;
            i = i++;
        }
        i = 0;
        for(model_hostInstitution h: viewModel.hostInstitutions)
        {
            if(i < 2)
                h.selectedInSearch = true;
            i = i++;
        }
        // Run update filter method
        result =  facultySearchController.updateFilters(viewModel.getSerializedViewModel());
        //Parse results back into viewModel
        viewModel = facultySearchViewModel.parseJSONString(result);
        // Set the program filter
        i = 0;
        for(model_program p: viewModel.programs)
        {
            if(i < 2)
                p.selectedInSearch = true;
            i = i++;
        }
    }
}