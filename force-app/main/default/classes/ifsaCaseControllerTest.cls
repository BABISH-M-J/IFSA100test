/**
 * Unit tests for <<ifsaCaseController>>
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
private class ifsaCaseControllerTest
{	
    @TestSetup
	static void makeData(){
        Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'Support_Personnel'});
        apexMockDataUtility.createMatrix(UserInfo.getUserId());
	}

	private static String caseDescription = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer id varius purus. Proin rhoncus ultrices nisl, sed molestie augue. In consectetur arcu nisl, sit amet tristique diam vestibulum tempor. Donec dapibus ornare lorem, sit amet ultricies nulla. Cras pharetra congue interdum. Aliquam pulvinar viverra ante, vitae scelerisque turpis venenatis quis. Duis ullamcorper sem odio, at imperdiet ex aliquet fermentum. Donec ultricies aliquam dapibus. Donec congue tortor quis convallis feugiat. Donec pharetra nunc pretium placerat mattis. Quisque erat mi, commodo sed urna eu, mattis sodales leo. Cras lobortis vel nisl eget pellentesque.';
    private static String caseComment = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam a interdum mi. Nunc mollis, eros eu porta lacinia, orci neque.';
    private static Case testCase;
    private static Contact studentContact;

    public static void init(String appStatus)
    {
        init(appStatus, true);
    }

    private static void init(String appStatus, Boolean createCase)
    {
        studentContact = [SELECT Id, Name, FirstName, LastName, (SELECT Id FROM Applications__r LIMIT 1) FROM Contact WHERE RecordType.Name = 'Student' LIMIT 1];
        
        Application__c app = studentContact.Applications__r.get(0);
        app.Status__c = appStatus;
        database.update(app);

        if(createCase){
            if(appStatus == 'On Site')
                testCase = generateCase(studentContact.Id, 'Incident Student');
            else
                testCase = generateCase(studentContact.Id, 'Pre-Departure');
            database.insert(testCase);

            Task caseTask = new Task(WhatId = testCase.Id, Subject = 'Test Case Task');       

        database.insert(new List<SObject>{/* caseStudent, */caseTask});
        }
    }

    @isTest static void testInstanceWithRelatedRecordId()
	{
		init('On Site');
        //With parentCaseId
		Test.startTest();
        PageReference ref = new PageReference('/apex/ifsaCase?parentCaseId=' + testCase.Id);
        Test.setCurrentPage(ref);
        ApexPages.StandardController con = new ApexPages.StandardController(new Case());
        ifsaCaseController controller = new ifsaCaseController(con);

        //With countryId
        Program__c p = [SELECT Id, Host_Institution__c, Country__c FROM Program__c LIMIT 1];
        ref = new PageReference('/apex/ifsaCase?countryId=' + p.Country__c);
        Test.setCurrentPage(ref);
        con = new ApexPages.StandardController(testCase);
        controller = new ifsaCaseController(con);

        //With hostInstitutionId
        ref = new PageReference('/apex/ifsaCase?hostInstitutionId=' + p.Host_Institution__c);
        Test.setCurrentPage(ref);
        con = new ApexPages.StandardController(testCase);
        controller = new ifsaCaseController(con);

        //With programId
        ref = new PageReference('/apex/ifsaCase?programId=' + p.Id);
        Test.setCurrentPage(ref);
        con = new ApexPages.StandardController(testCase);
        controller = new ifsaCaseController(con); 
        Test.stopTest();
    }

    @isTest static void testInstanceWithCaseId()
	{
        init('On Site');
        //With CaseId
        PageReference ref = new PageReference('/apex/ifsaCase?caseId=' + testCase.Id);
        Test.setCurrentPage(ref);
        Test.startTest();
        ApexPages.StandardController con = new ApexPages.StandardController(testCase);
        ifsaCaseController controller = new ifsaCaseController(con);

        ifsaCaseController.saveCase(JSON.serialize(controller.viewModel));
        
        Test.stopTest();
	}
    
	@isTest static void testInstanceWithRecordTypeName()
	{
		init('On Site');

		Test.startTest();
        PageReference ref = new PageReference('/apex/ifsaCase?recordType=Incident_Student');
        Test.setCurrentPage(ref);
        ApexPages.StandardController con = new ApexPages.StandardController(new Case());
        ifsaCaseController controller = new ifsaCaseController(con);        

        Test.stopTest();
	}

    @isTest static void testInstanceWithPreDeparture()
    {
        init('Program Selected');

        Test.startTest();
        PageReference ref = new PageReference('/apex/ifsaCase?recordType=Pre_Departure');
        Test.setCurrentPage(ref);
        ApexPages.StandardController con = new ApexPages.StandardController(new Case());
        ifsaCaseController controller = new ifsaCaseController(con);  

        ifsaCaseController.searchForRecord('Contact', 'Test');
        ifsaCaseController.searchForRecordWithRecordType('Contact', 'Test', 'Student');

        Test.stopTest();
    }
    
	@isTest static void testInstanceWithStudentId()
	{
		init('On Site', false);

		Test.startTest();

        PageReference ref = new PageReference('/apex/ifsaCase?recordType=Incident_Student&studentId=' + studentContact.Id);
        Test.setCurrentPage(ref);
        ApexPages.StandardController con = new ApexPages.StandardController(new Case());
        ifsaCaseController controller = new ifsaCaseController(con);

        ifsaCaseViewModel viewModel = controller.viewModel;
        
        viewModel.caseIncidentDateTime = Datetime.now();
        viewModel.recordType = new model_recordType([SELECT Id, Name, DeveloperName, Description FROM RecordType WHERE DeveloperName = 'Incident_Student' AND SObjectType = 'Case']);
        viewModel.incidentCategory = 'Conduct';
        viewModel.incidentSubCategory = 'Arrest/Allegation';
        viewModel.incidentSubSubCategory = 'Arson';
        viewModel.incidentSeverity = controller.viewModel.severities.get(0);
        viewModel.student = new model_contact(studentContact);
        viewModel.subject = 'IFSA Case Controller Test';
        viewModel.description = caseDescription;

        ifsaCaseController.caseSaveResult result = (ifsaCaseController.caseSaveResult) JSON.createParser(ifsaCaseController.saveCase(JSON.serialize(viewModel))).readValueAs(Type.forName('ifsaCaseController.caseSaveResult'));
        //viewModel.result = theCase.Id;        
        //ifsaCaseController.saveUpdateCase(JSON.serialize(viewModel));
        // (List<String>)System.JSON.deserialize(json_string, List<String>.class)

        ifsaCaseController.refreshViewModel(result.caseId);
        ifsaCaseController.cancelEdit(result.caseId);
        ifsaCaseController.saveCaseComment('Comment Text', result.caseId, true);

        Test.stopTest();
        List<model_CaseTeamMember> ctResults = (List<model_CaseTeamMember>)JSON.deserialize(ifsaCaseController.getCaseTeam(result.caseId), List<model_CaseTeamMember>.class);
	}

	private static Case generateCase(Id studentId, String caseType)
	{
        List<RecordType> caseRecordTypeList = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Case'];
        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for(RecordType rt: caseRecordTypeList)
        {
        	caseRecordTypeMap.put(rt.Name, rt.Id);
            system.debug(rt.Name);
        }	        
        
        Case case1 = new Case();
        case1.RecordTypeId = caseRecordTypeMap.get(caseType);
        system.debug(case1.RecordTypeId);
        case1.Status = 'New';
        case1.Student__c = studentId;
        case1.Date_Time_of_Incident__c = DateTime.now();
        case1.Incident_Category__c = 'Conduct';
        case1.Incident_Sub_Category__c = 'Arrest/Allegation';
        case1.Incident_Sub_Subcategory__c = 'Arson';
        case1.Subject = 'IFSA Case Controller Test';
        case1.Incident_Severity__c = 'Critical';
        case1.Description = caseDescription;
        case1.Add_Case_Comment__c = caseComment;
        return case1;        
	}

    @isTest static void testAffectedComponentController()
    {
        init('On Site');
        Test.startTest();
        affectedComponentController.affectedComponentViewModel vm = affectedComponentController.getContacts(testCase.Id, 'Catalog', 'On_Site');
        Map<String, String> result = affectedComponentController.addToCaseCampaign(testCase.Student__c, testCase.Id, 'Affected Student Campaign');
        Test.stopTest();
    }
 //added by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
    @isTest static void testAffectedComponentController1()
    {
        init('Traveling');
        Test.startTest();
        affectedComponentController.affectedComponentViewModel vm = affectedComponentController.getContacts(testCase.Id, 'Catalog', 'Traveling');
        Test.stopTest();
    }
    @isTest static void testAffectedComponentController2()
    {
        init('Program_Completed');
        Test.startTest();
        affectedComponentController.affectedComponentViewModel vm = affectedComponentController.getContacts(testCase.Id, 'Catalog', 'Program_Completed');
        Test.stopTest();
    }
    @isTest static void testAffectedComponentController3()
    {
        init('pa12');
        Test.startTest();
        affectedComponentController.affectedComponentViewModel vm = affectedComponentController.getContacts(testCase.Id, 'Catalog', 'pa12');
        Test.stopTest();
    }
//added by PowerFluence req_dt:03/29/2022 ref email from Clayton ends
    @isTest static void testHostInstitutinoCase()
    {
        init('On Site');
        Test.startTest();
        testCase = generateCase(studentContact.Id, 'Incident Host Institution');
        testCase.Student__c = null;
        List<String> hiOptions = apexConversionUtility.getPicklistStringValues(Case.Affected_Host_Institutions__c);
        testCase.Affected_Host_Institutions__c = hiOptions[0];

        database.insert(testCase);

        Case_Host_Institution__c testCaseHI = new Case_Host_Institution__c(
            Case__c = testCase.Id,
            Host_Institution__c = [SELECT Id FROM Host_Institution__c LIMIT 1].get(0).Id
        );

        database.insert(testCaseHI);
    }
}