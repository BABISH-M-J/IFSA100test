@IsTest(seeAllData=true)
private class dlrs_c2godaInvoiceLineItemTest
{
    @IsTest
    private static void testTrigger()
    {
        List<c2g__codaInvoiceLineItem__c > salesList = [Select Id from c2g__codaInvoiceLineItem__c  limit 1];
        update salesList;
        /*Contact con= new Contact(lastname= 'TestContact');
        insert con;
        Account acc = new Account();
        acc.Name = 'test';
        acc.c2g__CODAInvoiceEmail__c = 'test123@test.com';
        acc.c2g__CODAAccountTradingCurrency__c='USD';
        insert acc;
        
         Application__c app = new Application__c(
                             name='Aaron Broache Mérida Universities Program Spring Test',
                             Applicant__c = con.id,
                             CurrencyIsoCode= 'USD');
         insert app;
        
        List<c2g__codaCompany__c> cm = new List<c2g__codaCompany__c>();
        cm = [select id , name from c2g__codaCompany__c];
        
        c2g__codaInvoice__c sales = new c2g__codaInvoice__c(c2g__InvoiceDate__c = System.today(),
                                    c2g__InvoiceStatus__c = 'In Progress',
                                    c2g__Account__c = acc.id,
                                    c2g__OwnerCompany__c= cm[0].id, 
                                    c2g__DueDate__c = System.today()
                                    );
         insert sales;
         product2 p2=new product2();
         p2.Name='test';
         p2.IsActive = true;
         insert p2;
         c2g__codaInvoiceLineItem__c invoiceLine = new c2g__codaInvoiceLineItem__c(
                              c2g__Product__c = p2.id,
                              c2g__UnitPrice__c = 9,
                              c2g__Quantity__c = 10, 
                              CurrencyIsoCode= 'USD',
                              c2g__Invoice__c=  sales.id  );
         insert invoiceLine;*/
         
       
    }
}