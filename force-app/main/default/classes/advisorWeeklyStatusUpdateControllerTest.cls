@isTest
public without sharing class advisorWeeklyStatusUpdateControllerTest
{
   @TestSetup
    static void makeData(){
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'CMS'});
    }

    public static testMethod void testSummerFalse()
    {
         advisorWeeklyStatusUpdateController awsuc = new advisorWeeklyStatusUpdateController();
         List<Application__c> apps = new List<Application__c>();
         awsuc.summerOnly = false;
         apps = awsuc.getApplications;
    }

    public static testMethod void testSummerTrue()
    {
         advisorWeeklyStatusUpdateController awsuc = new advisorWeeklyStatusUpdateController();
         List<Application__c> apps = new List<Application__c>();
         awsuc.summerOnly = true;
         apps = awsuc.getApplications;
    }
}