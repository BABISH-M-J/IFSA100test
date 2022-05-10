@istest(seeAlldata=true)
public class UpdateDimensionsTest{
    static testMethod void validateUpdateDimensions() {
        User u = [SELECT Id FROM User WHERE Alias = 'fadmi'];
        Boolean hasFFA = false;
        system.runAs(u)
        {
            try
            {
                c2g__codaUserCompany__c uc = [SELECT Id FROM c2g__codaUserCompany__c WHERE c2g__User__c =: u.Id];

                hasFFA = true;
                Account acc=new account();
                acc.name ='test';
                insert acc;
                
                Term__c t =new Term__c();
                t.name ='testterm';
                insert t;
                
                c2g__codaDimension1__c cd =new c2g__codaDimension1__c();
                cd.name ='dim1';
                cd.c2g__ReportingCode__c ='uniquehaiye';
                insert cd;
                World__c w= new World__c (name='Global',CurrencyIsoCode = 'USD' );
                insert w;
                Region__c region = new Region__c(name = 'International Support' , World__c = w.id);
                insert region;
                Country__c con= new Country__c(name = 'China', CurrencyIsoCode = 'USD',Region__c = region.id,Active__c = true);
                insert con;
                Program__c a =new Program__c ();
                a.name='tets';
                a.Dim_1_Location__c  = cd.id;
                a.Country__c = con.id;
                insert a;      
                
                Program_Term__c  pt=new Program_Term__c  ();
                pt.name ='testing';
                pt.Program__c =a.id;
                pt.Term__c = t.id;   
                pt.Country__c = con.id;
                insert pt;
                
                Contact c =new Contact();
                c.lastname ='testname';
                insert c;
                
                Application__c aa =new Application__c();
                aa.Program_Term__c = pt.id;
                aa.name ='testit';
                aa.Applicant__c = c.id;       
                insert aa;
                
                Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive = true);
                insert prod;
                Id pricebookId = Test.getStandardPricebookId();
                PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
                insert standardPrice;
                

                List<c2g__codaAccountingCurrency__c> cclist =new  List<c2g__codaAccountingCurrency__c> ([select id from c2g__codaAccountingCurrency__c where Name ='USD']);
                c2g__codaAccountingCurrency__c ac =new c2g__codaAccountingCurrency__c();
                if(cclist.size()==0){
                    c2g__codaCompany__c cc =[select id from c2g__codaCompany__c limit 1];           
                    ac.Name ='USD';
                    ac.c2g__DecimalPlaces__c =1;
                    ac.c2g__OwnerCompany__c = cc.id;
                    insert ac;
                }else
                {
                    ac = cclist[0];
                }
                
                c2g__codaInvoice__c ci=new c2g__codaInvoice__c();
                ci.c2g__InvoiceDate__c =date.today();
                ci.c2g__DueDate__c =date.today();
                ci.c2g__Account__c =acc.id;
                ci.c2g__InvoiceCurrency__c = ac.id;      
                insert ci;
                
                c2g__codaInvoiceLineItem__c cci =new c2g__codaInvoiceLineItem__c();
                cci.c2g__Invoice__c = ci.id;
                cci.Responsible_Party__c = 'Student';
                cci.c2g__UnitPrice__c = 123;
                cci.c2g__Quantity__c =22;
                cci.c2g__Product__c = prod.id;
                cci.Applications__c= aa.id;
                insert cci;
            }
            catch (QueryException e)
            {
                if(!hasFFA)
                    system.debug('Financial Force Account has not been setup in this org');
                else
                    throw e;
            }
        }
    }
}