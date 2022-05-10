/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Program_TermTest
{
    @IsTest
    private static void testTrigger()
    {
Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
Program_Term__c po= (Program_Term__c) testData.get('programOption1');
dlrs.RollupService.testHandler(po);
    }
}