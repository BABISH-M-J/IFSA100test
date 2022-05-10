/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest(seeAlldata = true)
private class dlrs_c2godaCashEntryLineItemTest
{
    @IsTest
    private static void testTrigger(){
    
        User u = [SELECT Id FROM User WHERE Alias = 'fadmi'];
        system.runAs(u)
        {
            try
            {
                c2g__codaUserCompany__c uc = [SELECT Id FROM c2g__codaUserCompany__c WHERE c2g__User__c =: u.Id].get(0);
                List<c2g__codaGeneralLedgerAccount__c> gla = [Select id, name from c2g__codaGeneralLedgerAccount__c limit 1];
                Account acc = new Account();
                acc.name =  'TestAcc';
                acc.c2g__CODAAccountsReceivableControl__c = gla[0].Id;
                insert acc;
                
                c2g__codaCashEntry__c cs = new c2g__codaCashEntry__c();
                cs.c2g__Date__c = date.today().addDays(10);
                insert cs;
                
                c2g__codaCashEntryLineItem__c cline = new c2g__codaCashEntryLineItem__c();
                cline.c2g__Account__c = acc.Id;
                cline.c2g__CashEntryValue__c = 400;
                cline.c2g__CashEntry__c = cs.Id;
                insert cline;
                // Force the dlrs_c2godaCashEntryLineItemTrigger to be invoked, fails the test if org config or other Apex code prevents this.
                
                dlrs.RollupService.testHandler(new c2g__codaCashEntryLineItem__c());
            }
            catch (ListException e)
            {
                system.debug('Financial Force Account has not been setup in this org');
            }
        }
    }
}