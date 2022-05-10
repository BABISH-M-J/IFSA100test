/**
 * Unit tests for <<caseDetailsEmailController>>
 */
// ApexDoc updated 1/27/2021 Brock Barlow
@isTest
public without sharing class caseDetailsEmailControllerTests 
{
    private static String caseDescription = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer id varius purus. Proin rhoncus ultrices nisl, sed molestie augue. In consectetur arcu nisl, sit amet tristique diam vestibulum tempor. Donec dapibus ornare lorem, sit amet ultricies nulla. Cras pharetra congue interdum. Aliquam pulvinar viverra ante, vitae scelerisque turpis venenatis quis. Duis ullamcorper sem odio, at imperdiet ex aliquet fermentum. Donec ultricies aliquam dapibus. Donec congue tortor quis convallis feugiat. Donec pharetra nunc pretium placerat mattis. Quisque erat mi, commodo sed urna eu, mattis sodales leo. Cras lobortis vel nisl eget pellentesque.';
    private static String caseComment = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam a interdum mi. Nunc mollis, eros eu porta lacinia, orci neque.';
    /**
     * Test setup
     */
    @TestSetup
    static void makeData(){
        Map<String, sObject> testData = apexMockDataUtility.createIfsaDataCollection();
    }
    /**
     * Tests an instance of <<caseDetailsEmailController>>
     */
    @IsTest
    static void testInstance(){
        Application__c app = [SELECT Id, Status__c, Applicant__c FROM Application__c LIMIT 1];
        app.Status__c = 'On Site';
        database.update(app);      
        
        Case case1 = new Case();
        case1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Student').getRecordTypeId();
        case1.Status = 'New';
        case1.Student__c = app.Applicant__c;
        case1.Date_Time_of_Incident__c = DateTime.now();
        case1.Incident_Category__c = 'Conduct';
        case1.Incident_Sub_Category__c = 'Arrest/Allegation';
        case1.Incident_Sub_Subcategory__c = 'Arson';
        case1.Subject = 'IFSA Case Controller Test';
        case1.Incident_Severity__c = 'Critical';
        case1.Description = caseDescription;
        case1.Add_Case_Comment__c = caseComment;
        Database.insert(case1);

        Test.startTest();

        caseDetailsEmailController controller = new caseDetailsEmailController();
        controller.caseId = case1.Id;
        Set<String> students = controller.getStudents;
        Set<String> countries = controller.getCountries;
        Set<String> program = controller.getPrograms;

        Test.stopTest();        
    }
}