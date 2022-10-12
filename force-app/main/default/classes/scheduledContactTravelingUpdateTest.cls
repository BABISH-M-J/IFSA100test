@isTest
public without sharing class scheduledContactTravelingUpdateTest {
    
    // Create test data
    @TestSetup
    static void makeData(){
        //Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'CMS'});
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection(new List<String>{'accountTrigger'}, new Set<String>{'CMS'});
    }

    /*public static testMethod void testSchedule()
    {
    	Test.startTest();
    	String jobId = System.schedule('testscheduledContactTravellingUpdate' + Datetime.now().format(),
            '0 0 0 * * ? *', new scheduledContactTravelingUpdate());
        
        Test.stopTest();
    }*/
    public static testMethod void testUpdateApplicationStatuses()
    {
        List<Application__c> lApps = apexQueryUtility.selectAllFrom('Application__c', 'Program_Term__r.End_Date__c', 'Id != null LIMIT 1');
        Application__c app = lApps.get(0);
        Program_Term__c pt = [SELECT Id, End_Date__c FROM Program_Term__c WHERE Id =: app.Program_Term__c LIMIT 1].get(0);
        pt.End_Date__c = Date.newInstance(2022, 1, 1);
        app.Program_Term__r.End_Date__c = Date.newInstance(2022, 1, 1);
        app.Status__c = 'On Site';
        Database.update(pt);
        Database.update(app);
        Test.startTest();
        scheduledContactTravelingUpdate.updateApplicationStatuses();
        Test.stopTest();
    }
    public static testMethod void testUpdateTravelingStatusOnContacts()
    {
        List<Application__c> lApps = apexQueryUtility.selectAllFrom('Application__c', 'Applicant__r.Traveling_Status__c', 'Id != null');
        Application__c app = lApps.get(0);
        Travel_Plan__c tp = new Travel_Plan__c(Name='Test', First_Departure__c = Date.newInstance(2022, 1, 1));
        Database.insert(tp);
        app.Travel_Plan__c = tp.Id;
        app.Applicant__r.Traveling_Status__c = 'Not Traveling';
        app.Status__c = 'Accepted';
        app.Approval_Override__c = true;
        Database.update(app);
        Test.startTest();
        scheduledContactTravelingUpdate.updateTravelingStatusOnContacts();
        Test.stopTest();
    }
    public static testMethod void testUpdateTravelingStatusOnContacts2()
    {
        List<Application__c> lApps = apexQueryUtility.selectAllFrom('Application__c', 'Applicant__r.Traveling_Status__c', 'Id != null');
        Application__c app = lApps.get(0);
        Travel_Plan__c tp = new Travel_Plan__c(Name='Test', First_Departure__c = Date.newInstance(2022, 1, 1));
        Database.insert(tp);
        app.Travel_Plan__c = tp.Id;
        app.Applicant__r.Traveling_Status__c = 'Pre-Program';
        app.Status__c = 'Accepted';
        app.Approval_Override__c = true;
        Database.update(app);
        Test.startTest();
        scheduledContactTravelingUpdate.updateTravelingStatusOnContacts();
        Test.stopTest();
    }
    public static testMethod void testUpdateTripStatus()
    {
        Test.startTest();
        scheduledContactTravelingUpdate.updateTripStatus();
        Test.stopTest();
    }
    public static testMethod void testUpdateEmailAddresses()
    {
        List<Application__c> listApps = [SELECT Id, Applicant__c FROM Application__c LIMIT 1];
        List<Contact> listContacts = [SELECT Id FROM Contact LIMIT 1];
        listContacts.get(0).Email = 'SomeRandomEmail@test.invalid';
        listContacts.get(0).Personal_Email__c = 'TestPersonalEmail@test.invalid';
        //listContacts.get(0).School_Email__c = 'TESTSchoolTEST@test.edu.invalid';
        listApps.get(0).Applicant__c = listContacts.get(0).Id;
        Database.update(listContacts);
        Database.update(listApps);
        List<Id> contactIds = new List<Id>();
        for(Contact c : listContacts){
            contactIds.add(c.Id);
        }
        Test.startTest();
        scheduledContactTravelingUpdate.updateEmailAddresses(contactIds);
        Test.stopTest();
    }
}