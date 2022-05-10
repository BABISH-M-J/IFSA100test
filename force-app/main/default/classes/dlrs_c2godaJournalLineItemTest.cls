/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest(seeAlldata = true)
private class dlrs_c2godaJournalLineItemTest
{
    @IsTest
    private static void testTrigger(){
        User u = [SELECT Id FROM User WHERE Alias = 'fadmi'];
        system.runAs(u)
        {
            try
            {
                c2g__codaUserCompany__c uc = [SELECT Id FROM c2g__codaUserCompany__c WHERE c2g__User__c =: u.Id].get(0);
                List<c2g__codaGeneralLedgerAccount__c> gla = [Select id,name from c2g__codaGeneralLedgerAccount__c limit 1];
            
                Account acc = new Account();
                acc.name = 'testAcc';
                acc.c2g__CODAAccountsReceivableControl__c = gla[0].Id;
                acc.c2g__CODAAccountTradingCurrency__c = 'USD';
                insert acc;
                
                c2g__codaJournal__c jl = new c2g__codaJournal__c();
                jl.c2g__ExternalCounterparty__c = acc.Id;
                insert jl;
                
                c2g__codaJournalLineItem__c jline = new c2g__codaJournalLineItem__c();
                jline.c2g__Account__c = acc.Id;
                jline.c2g__GeneralLedgerAccount__c = gla[0].Id;
                //jline.c2g__LocalGLA__c = gla[0].Id;
                jline.c2g__Journal__c = jl.Id;
                jline.c2g__LineType__c = 'Account - Vendor';
                insert jline;
                // Force the dlrs_c2godaJournalLineItemTrigger to be invoked, fails the test if org config or other Apex code prevents this.
                dlrs.RollupService.testHandler(new c2g__codaJournalLineItem__c());
            }
            catch (ListException e)
            {
                system.debug('Financial Force Account has not been setup in this org');
            }
            
        }
    }
}