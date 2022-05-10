@IsTest(seeAllData=true)
private class dlrs_c2godaCreditNoteLineItemTest
{
    @IsTest
    private static void testTrigger()
    {
        User u = [SELECT Id FROM User WHERE Alias = 'fadmi'];
        Test.startTest();
        system.runAs(u)
        {
            try
            {
                c2g__codaUserCompany__c uc = [SELECT Id FROM c2g__codaUserCompany__c WHERE c2g__User__c =: u.Id].get(0);
                List<c2g__codaAccountingCurrency__c> currencyList = [SELECT Id FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD' AND c2g__OwnerCompany__c =: uc.Id];
                
                Account acc = new Account(
                    Name = 'test',
                    c2g__CODAInvoiceEmail__c = 'test123@test.com',
                    c2g__CODAAccountTradingCurrency__c='USD'
                );
                insert acc;
                
                
                c2g__codaCreditNote__c creditNote = new c2g__codaCreditNote__c (
                    c2g__CreditNoteCurrency__c = currencyList.size() > 0 ? currencyList[0].Id : NULL,
                    c2g__Account__c = acc.Id
                );
                insert creditNote;  
                
                product2 p2=new product2(
                    Name = 'Test'
                );
                insert p2;
                
                c2g__codaCreditNoteLineItem__c creditNoteLine = new c2g__codaCreditNoteLineItem__c (
                    c2g__CreditNote__c = creditNote.Id,
                    c2g__UnitPrice__c = 9,
                    c2g__Quantity__c = 10,
                    c2g__Product__c = p2.Id
                );
                insert creditNoteLine;
            }
            catch (ListException e)
            {
                system.debug('Financial Force Account has not been setup in this org');
            }
        }
        Test.stopTest();
    }
}