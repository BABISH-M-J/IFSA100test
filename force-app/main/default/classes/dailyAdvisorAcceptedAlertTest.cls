/**
 * Test class for dailyAdvisorAcceptedAlertTest
 * @author Brock Barlow
 */
// ApexDoc updated 2/1/2021 Brock Barlow
@isTest
public class dailyAdvisorAcceptedAlertTest
{
    @TestSetup
    static void makeData(){
        Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
    }
    static testmethod void testSchedule()
    {
        String jobId = System.schedule('dailyAdvisorAcceptedAlert',
            '0 0 0 * * ? *', new dailyAdvisorAcceptedAlert());
    }

	static testmethod void testInstance()
    {
        Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        List<Application__c> applications = [SELECT Id, 
                                             Status__c, 
                                             Status_Accepted__c, 
                                             Program_Approval_Completed_By__c,
                                             Accepted_Alert_Status__c, 
                                             Home_Institution_Advisor__c,
                                             Status_Accepted_with_Conditions__c,
                                             Acceptance_Conditions__c
                                             FROM Application__c];
        Application__c app1 = applications[0];
        Application__c app2 = applications[1];
        Contact advisorCtc = [SELECT Id FROM Contact WHERE recordTypeId = :advisorRecordType LIMIT 1];

        Test.startTest();     
        app1.Status__c = 'Accepted';
        app1.Status_Accepted__c = Datetime.now();
        app1.Program_Approval_Completed_By__c = advisorCtc.Id;
        app1.Accepted_Alert_Status__c = 'Ready';
        app1.Home_Institution_Advisor__c = advisorCtc.Id;
        app2.Status__c = 'Accepted (with Conditions)';
        app2.Program_Approval_Completed_By__c = advisorCtc.Id;
        app2.Status_Accepted_with_Conditions__c = Datetime.now();
        app2.Accepted_Alert_Status__c = 'Ready';
        app2.Home_Institution_Advisor__c = advisorCtc.Id;
        app2.Acceptance_Conditions__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce fringilla massa vel nisi lobortis, in lacinia odio pellentesque.';
        List<Application__c> apps = new List<Application__c>();
        apps.add(app1);
        apps.add(app2);        
        database.update(apps);
        
        apps = [SELECT Id, Status__c, Program_Country__c, Accepted_Alert_Status__c FROM Application__c WHERE Accepted_Alert_Status__c = 'Ready' AND Status__c IN('Accepted','Accepted (with Conditions)') AND Is_Custom__c = FALSE AND (NOT Program_Country__c IN ('China','India')) LIMIT 100];

        system.debug(apps.size());

        dailyAdvisorAcceptedAlert.sendDailyAcceptanceAlert();

        Test.stopTest();
    }
    static testmethod void testInstanceAdvisorNoEmail()
    {
        Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        List<Application__c> applications = [SELECT Id, 
                                             Status__c, 
                                             Status_Accepted__c, 
                                             Program_Approval_Completed_By__c,
                                             Accepted_Alert_Status__c, 
                                             Home_Institution_Advisor__c,
                                             Status_Accepted_with_Conditions__c,
                                             Acceptance_Conditions__c
                                             FROM Application__c];
        Application__c app1 = applications[0];
        Application__c app2 = applications[1];
        Contact advisorCtc = [SELECT Id, Email FROM Contact WHERE recordTypeId = :advisorRecordType LIMIT 1];
        advisorCtc.Email = null;

        Test.startTest();     
        database.update(advisorCtc);        
        app1.Status__c = 'Accepted';
        app1.Status_Accepted__c = Datetime.now();
        app1.Accepted_Alert_Status__c = 'Ready';
        app1.Home_Institution_Advisor__c = advisorCtc.Id;
        app1.Program_Approval_Completed_By__c = advisorCtc.Id;
        app2.Program_Approval_Completed_By__c = advisorCtc.Id;
        app2.Status__c = 'Accepted (with Conditions)';
        app2.Status_Accepted_with_Conditions__c = Datetime.now();
        app2.Accepted_Alert_Status__c = 'Ready';
        app2.Home_Institution_Advisor__c = advisorCtc.Id;
        app2.Acceptance_Conditions__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce fringilla massa vel nisi lobortis, in lacinia odio pellentesque.';
        List<Application__c> apps = new List<Application__c>();
        apps.add(app1);
        apps.add(app2);
        database.update(apps);

        dailyAdvisorAcceptedAlert.sendDailyAcceptanceAlert();
        
        Test.stopTest();
    }
}