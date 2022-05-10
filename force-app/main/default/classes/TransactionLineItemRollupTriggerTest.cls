@isTest
private class TransactionLineItemRollupTriggerTest 
{
	/*
	@isTest(seeAllData=true)
	static void testTrigger() 
	{
		//Get mock data
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();		
		Account studentAccount = (Account) testData.get('studentAccount');
		Application__c studentApplication = (Application__c) testData.get('studentApplication');		

		Test.startTest();		

        c2g__codaCompany__c company = [SELECT id, name FROM c2g__codaCompany__c].get(0);

       String companyName = company.Name;

       User usr = (User) testData.get('academicAffiarsUser');
       //usr.c2g__APILicenseKey__c = System.label.FF_Accounting_API_Key;
       //update(usr);
       

        //Set our new user as belonging to a company
        /*
        insert new c2g__codaUserCompany__c(

            c2g__company__c = company.id,

            c2g__user__c = usr.id);

        System.runAs( new User(id=UserInfo.getUserId()) ){ //insert setup sObject inside runAs to avoid MIXED_DML exception

            insert new groupMember(userOrGroupId = usr.id, groupId = [SELECT id FROM Group WHERE name = :'FF '+companyName].id);

        }

       

        System.runAs(usr){

            c2g.CODAAPICommon_6_0.Context ctx = new c2g.CODAAPICommon_6_0.Context();

            ctx.companyName = companyName;

           

            c2g__codaInvoice__c invoice = new c2g__codaInvoice__c(

                c2g__Account__c = studentAccount.Id,

                c2g__InvoiceDate__c = Date.today(),

                c2g__invoiceStatus__c = 'In Progress',

                c2g__DerivePeriod__c = true,

                c2g__DeriveCurrency__c = true,

                c2g__DeriveDueDate__c = true,

                c2g__CopyAccountValues__c = true

            );

            insert invoice;

            // Insert Invoice line items

            List<c2g__codaInvoiceLineItem__c> invoiceLines = new List<c2g__codaInvoiceLineItem__c>();

            invoiceLines.add(

            new c2g__codaInvoiceLineItem__c(

            c2g__Invoice__c = invoice.Id,

            c2g__Product__c = testData.get('product1').Id,

            Applications__c = studentApplication.Id,

            c2g__Quantity__c = 10));            

            invoiceLines.add(

            new c2g__codaInvoiceLineItem__c(

            c2g__Invoice__c = invoice.Id,

            c2g__Product__c = testData.get('product1').Id,

            Applications__c = studentApplication.Id,

            c2g__Quantity__c = 2));

            insert invoiceLines;

           

            // Post the Invoice

            c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();

            ref.Id = invoice.Id;

           

            // Post Invoices

            //c2g.CODAAPISalesInvoice_6_0.PostInvoice(ctx,ref);

        } 
        Test.stopTest();
    }
    */
}