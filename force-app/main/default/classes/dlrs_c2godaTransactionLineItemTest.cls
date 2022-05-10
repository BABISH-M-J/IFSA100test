/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_c2godaTransactionLineItemTest
{
    @IsTest(SeeAllData=true)
    private static void testTrigger()
    {
User u = [SELECT Id FROM User WHERE Alias = 'fadmi'];
        system.runAs(u)
        {
            try
            {
                c2g__codaUserCompany__c uc = [SELECT Id FROM c2g__codaUserCompany__c WHERE c2g__User__c =: u.Id].get(0);
                List<c2g__codaTransactionLineItem__c> lineItem = [Select id from c2g__codaTransactionLineItem__c limit 1];
            
            	update lineItem;
            }
            catch (ListException e)
            {
                system.debug('Financial Force Account has not been setup in this org');
            }
            
            List<c2g__codaTransactionLineItem__c> lineItem = [Select id from c2g__codaTransactionLineItem__c limit 1];
            
            update lineItem;
        }
    }
}