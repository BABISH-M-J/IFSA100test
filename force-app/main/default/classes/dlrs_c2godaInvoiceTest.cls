/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest(seeAllDATA = true)
private class dlrs_c2godaInvoiceTest
{
    @IsTest
    private static void testTrigger()
    {
        User u = [SELECT Id FROM User WHERE Alias = 'fadmi'];
        system.runAs(u)
        {
            try
            {
                c2g__codaUserCompany__c uc = [SELECT Id FROM c2g__codaUserCompany__c WHERE c2g__User__c =: u.Id].get(0);
                // Force the dlrs_c2godaInvoiceTrigger to be invoked, fails the test if org config or other Apex code prevents this.
                dlrs.RollupService.testHandler(new c2g__codaInvoice__c());
            }
            catch (ListException e)
            {
                system.debug('Financial Force Account has not been setup in this org');
            }
        }
    }
}