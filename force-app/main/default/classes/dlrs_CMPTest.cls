/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_CMPTest
{
    @IsTest
    private static void testTrigger()
    {
        // Generate test data
        Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
        // Force the dlrs_CMPTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        CMP__c testCMP = new CMP__c();
        testCMP.RecordTypeId = Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Course Equivalency').getRecordTypeId();
        testCMP.Contact__c = testData.get('studentContact').Id;
        testCMP.Home_Institution_Account__c = testData.get('institutionAccount1').Id;
        Test.startTest();
        dlrs.RollupService.testHandler(testCMP);
        Test.stopTest();
    }
}