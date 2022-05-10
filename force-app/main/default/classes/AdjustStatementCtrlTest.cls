/**
 * Test class for <<AdjustStatementCtrl>>
 */
// ApexDoc updated 1/22/2021 Brock Barlow
@isTest(seeAlldata=true)
public without sharing class AdjustStatementCtrlTest
{
    /**
     * Tests an instance of <<AdjustStatementCtrl>>
     */
    public static testMethod void AdjustStatementCtrlTest() {
        User u = [SELECT Id FROM User WHERE Alias = 'fadmi'];
        system.runAs(u)
        {
            Account acc = new Account();
            acc.name = 'Test';
            insert acc;  
                                                                                    
            List<c2g__codaTransactionLineItem__c> transLine = [Select  c2g__Account__c, 
                                                            c2g__LineNumber__c, id ,c2g__Transaction__r.c2g__TransactionType__c, 
                                                            name, c2g__Transaction__c   from c2g__codaTransactionLineItem__c 
                                                            where c2g__Transaction__r.c2g__TransactionType__c = 'Invoice' limit 1];                                                          
            
            test.startTest();
            
            if(!transLine.isEmpty())
            {
                ApexPages.StandardController sc = new ApexPages.StandardController([Select id, name from account where id=:transLine[0].c2g__Account__c limit 1]);
                AdjustStatementCtrl t = new AdjustStatementCtrl(sc);
                
                t.getTransline();
                t.save();
                t.cancel();
            }
            test.stopTest();
        }
    }
}