/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_ApplicationTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_ApplicationTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
        Application__c app = (Application__c) testData.get('studentApplication');
        dlrs.RollupService.testHandler(app);
    }
}