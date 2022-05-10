/**
 * Class to generate new application line items when a program term is ready for billing or an application is marked as accepted
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class ifsaLineItemPopulator
{
    /**
    * Generate line items for a program term when it is marked ready for billing
    */
    public static String populateApplicationLineItems(List<Id> programTermId)
    {
        // Get the apps
        List<Application__c> appList = [SELECT Id, Name, Program_Term__c, Application_Home_Institution__c, Applicant__r.Home_Institution__c FROM Application__c WHERE Program_Term__c IN: programTermId AND (Status__c = 'Accepted' OR Status__c = 'Accepted (with Conditions)') AND Designation__c = 'Primary'];
        List<Program_Term__c> progTerms = new List<Program_Term__c>(); //[SELECT Id, Name, Term__c, Term__r.Name, Ready_for_Billing__c, Ready_for_Billing_Checked__c FROM Program_Term__c WHERE Id IN: programTermId];
        String returnStatement = '';
        for(Id progTermId: programTermId)
        {   
            Program_Term__c progTerm = new Program_Term__c(Id = progTermId);
            progTerm.Id = progTermId;
            progTerms.add(progTerm);
        }
        
        if(appList.size() < 1)
        {
            /* Disabling updating of program term this will be handled by programTermService.markReadyToBillBeforeUpdate()
            for(Program_Term__c progTerm: progTerms)
            {                   
                progTerm.Ready_for_Billing__c = true;
                progTerm.Ready_for_Billing_Checked__c = true;
            }
            database.update(progTerms);
            */
            if(progTerms.size() > 1)
            {
                returnStatement = progTerms.size() + ' programs have been marked as ready to bill. No line items have been created at this time.';
            }
            else if(progTerms.size() == 1)            
            {
                returnStatement = 'One program has been marked as ready to bill. No line items have been created at this time.';
            }            

            return returnStatement;
        }
        List<Id> idList = new List<Id>();
        for(Application__c app : appList)
        {
            idList.add(app.Id);
        }
        //List<Program_Term__c> progTerms = new List<Program_Term__c>();
        String batchId;
        try
        {
            batchId = populateApplications(idList, progTerms);
            if(progTerms.size() > 1 && appList.size() > 1)
            {                
                returnStatement = progTerms.size() + ' programs have been marked as ready to bill. ' + appList.size() + ' applications have been billed.';
            }
            else if(progTerms.size() == 1 && appList.size() > 1)            
            {                
                returnStatement = 'One program has been marked as ready to bill. ' + appList.size() + ' applications have been billed.';
            }
            else if(progTerms.size() == 1 && appList.size() == 1)
            {
                returnStatement = 'One program has been marked as ready to bill. One application has been billed.';   
            }
        }
        catch(Exception e)
        {
            return e.getMessage();
        }
        //return returnStatement;
        return batchId;
    }

    /**
     * Creates application line items based off of the application RUNS FROM TOP METHOD
     */
    public static String populateApplications(List<Id> applicationIds, List<Program_Term__c> programTerms)
    {
        //Get the applications - MODIFIED BBARLOW: Get PT Dimiension Fields
        List<Application__c> applicationList = [SELECT Id, Name, Program_Term__c, Program_Term__r.Program__c, Program_Term__r.Parent_Program_Term__c, Program_Term__r.Term__r.Name, 
                                                        Program_Term__r.Term__c, Application_Home_Institution__c, Applicant__r.Home_Institution__c, Home_Institution__c,
                                                        Program_Term__r.Program__r.Non_Refundable_Advance_Deposit__c, Program_Term_Section__c, Home_Institution_Account__c,
                                                        Program_Term__r.Dim_1_Location__c,Program_Term__r.Dim_2_Host_School__c,Program_Term__r.Dim_3_Category__c,
                                                        Program_Term__r.Dim_4_Term__c, Applicant__r.Home_Institution__r.Account__r.Institution_Type__c
                                                FROM Application__c WHERE Id IN: applicationIds];
        Set<Id> depositLineItems = new Set<Id>();
        for(Application_Line_Item__c lineItem: [SELECT Id, Name, Application__c FROM Application_Line_Item__c WHERE Name = 'Non-Refundable Advance Deposit' AND Application__c IN: applicationIds])
        {            
            depositLineItems.add(lineItem.Application__c);            
        }        

        /* This data is pulled in by the application query above
        //Get the term of applications 
        List<Program_Term__c> appTermList =new List<Program_Term__c>(); 
        
        // Modified On 1-AUG-2016 Query the fields contains Dimesion1,2,3,4 Ids from Program Term.
        if(applicationList.size()>0 && applicationList[0].Program_Term__c !=null){       
            appTermList = [select id,Dim_1_Location__c,Dim_2_Host_School__c,Dim_3_Category__c,Dim_4_Term__c 
                                from Program_Term__c where id =:applicationList[0].Program_Term__c];             
        }
        */

        Set<Id> programTermIdList = new Set<Id>();
        Set<Id> programIdList = new Set<Id>();
        Set<Id> homeInstitutionIdList = new Set<Id>();
        Set<Id> homeAccountIdList = new Set<Id>();
        Set<Id> programOptionIdList = new Set<Id>();
        Set<Id> termIdList = new Set<Id>();

        //Get the set of program term Ids and home institution ids
        Integer counter = 0;
        for(Application__c application : applicationList)
        {
            counter = counter++;
            programTermIdList.add(application.Program_Term__c);
            programIdList.add(application.Program_Term__r.Program__c);
            homeInstitutionIdList.add(application.Applicant__r.Home_Institution__c);
            homeAccountIdList.add(application.Home_Institution_Account__c);
            system.debug(application.Program_Term__r.Term__c);
            termIdList.add(application.Program_Term__r.Term__c);
            /*if(application.Program_Term__r.Parent_Program_Term__c != null)
            {
                programTermIdList.add(application.Program_Term__r.Parent_Program_Term__c);
            }*/
        }
        system.debug('Counter: ' + counter);

        //Get our program fees and approved programs based on the list of program term ids and home institution ids
        List<Program_Fee__c> programFees = [SELECT Id, Name, Program_Term__c, Direct_Bill_Category__c, Amount__c, 
                                            Product__c FROM Program_Fee__c WHERE Program_Term__c IN: programTermIdList];                
        //List<Program_Fee__c> programOptionFees = [SELECT Id, Name, Program_Option__c, Direct_Bill_Category__c, Amount__c, Product__c FROM Program_Fee__c WHERE Program_Option__c IN: programOptionIdList];
        List<Billing_Arrangement__c> billingArrangments = [SELECT Id, Name, Direct_Bill__c, Account__c, Term__c, Pays_Accomodation__c, 
                                                      Pays_Deposit__c, Pays_Tuition__c, Program__c, Discount_Amount__c, Discount_Recipient__c,
                                                      Account__r.Institution_Type__c
                                                      FROM Billing_Arrangement__c WHERE Program__c IN: programIdList
                                                      AND Account__c IN: homeAccountIdList];
        // Populate Ids and other vars that will be used in the application line item generation process
        Id programGrantProductID;
        Id depositProductId;
        Id guaranteedScholarshipProductID;
        Id indyAdmin;
        //Id guaranteedScholarship;
        Id programLaunchScholarship;
        Decimal guaranteedScholarshipAmmount;
        // Get Product2 Ids for Program Grant, Non-Refundable Deposit & Guaranteed Scholarship
        for(Product2 p: [SELECT Id, Name FROM Product2 WHERE Name = 'Program Grant' OR Name = 'Non-Refundable Deposit' OR Name = 'Guaranteed Scholarship'])
        {
            if(p.Name == 'Program Grant')
                programGrantProductID = p.Id;
            else if(p.Name == 'Non-Refundable Deposit')
                depositProductId = p.Id;
            else if(p.Name == 'Guaranteed Scholarship')
                guaranteedScholarshipProductID = p.Id;
        }
        // Get the Id of the Indy Admin Dimension 1 value and Guaranteed Scholarship Dimension 2 value. Wrapped in try catch block so that testing will not fail when this record does not exist
        try
        {
            indyAdmin = [SELECT Id FROM c2g__codaDimension1__c WHERE Name = 'Indianapolis, Administration'].get(0).Id;
            //guaranteedScholarship = [SELECT Id FROM c2g__codaDimension2__c WHERE Name = 'Guaranteed Scholarship'].get(0).Id;
            programLaunchScholarship = [SELECT Id FROM c2g__codaDimension2__c WHERE Name = '3 Program Launch Scholarship'].get(0).Id;
        }
        catch (Exception ex)
        {
            system.debug(ex.getMessage());
        }
        guaranteedScholarshipAmmount = [SELECT Amount__c FROM IFSA_Default_Amount__mdt WHERE DeveloperName = 'Guaranteed_Scholarship'].get(0).Amount__c;
       
        /*if(programFees.isEmpty() && programOptionFees.isEmpty())
        {
            return false;
        }*/
        
        //Map program term fees
        Map<Id, List<Program_Fee__c>> programFeeMap = new Map<Id, List<Program_Fee__c>>();
        
        for(Program_Fee__c programFee : programFees)
        {
            if(programFeeMap.get(programFee.Program_Term__c) == null)
            {
                programFeeMap.put(programFee.Program_Term__c, new List<Program_Fee__c>());
            }
            programFeeMap.get(programFee.Program_Term__c).add(programFee);
        }
        //Map program option fees
        /*
        Map<Id, List<Program_Fee__c>> programOptionFeeMap = new Map<Id, List<Program_Fee__c>>();
        for(Program_Fee__c programFee : programOptionFees)
        {
            if(programOptionFeeMap.get(programFee.Program_Option__c) == null)
            {
                programOptionFeeMap.put(programFee.Program_Option__c, new List<Program_Fee__c>());
            }
            programOptionFeeMap.get(programFee.Program_Option__c).add(programFee);
        }
        */
        //Map Billing Arrangements
        Map<Id, List<Billing_Arrangement__c>> billingArrangmentsMap = new Map<Id, List<Billing_Arrangement__c>>();
        for(Billing_Arrangement__c ba : billingArrangments)
        {
            if(billingArrangmentsMap.get(ba.Program__c) == null)
            {
                billingArrangmentsMap.put(ba.Program__c, new List<Billing_Arrangement__c>());
            }
            billingArrangmentsMap.get(ba.Program__c).add(ba);
        }

        //List<SObject> toInsertHomeLineItems = new List<SObject>();
        List<SObject> toInsertAppLineItems = new List<SObject>();
        List<Application__c> appsWithoutBillingArrangements = new List<Application__c>();
        
        //deal with each application
        for(Application__c application : applicationList)
        {
            List<Program_Fee__c> programFeeList = new List<Program_Fee__c>();
            if(programFeeMap.containsKey(application.Program_Term__c))
            {
                programFeeList.addAll(programFeeMap.get(application.Program_Term__c));
            }
            /*if(programFeeMap.containsKey(application.Program_Term__r.Parent_Program_Term__c))
            {
                programFeeList.addAll(programFeeMap.get(application.Program_Term__r.Parent_Program_Term__c));
            }*/
            List<Billing_Arrangement__c> billingArrangmentList = new List<Billing_Arrangement__c>();
            billingArrangmentList.addAll(billingArrangmentsMap.get(application.Program_Term__r.Program__c) != null ? billingArrangmentsMap.get(application.Program_Term__r.Program__c) : new List<Billing_Arrangement__c>());
            Billing_Arrangement__c billingArrangment = null;
            
            
            if(billingArrangmentList != null && billingArrangmentList.size() > 0)
            {
                for(Billing_Arrangement__c aBillingArrangement : billingArrangmentList)
                {
                    if(aBillingArrangement.Account__c == application.Home_Institution_Account__c && aBillingArrangement.Term__c.contains(application.Program_Term_Section__c))
                    {
                        billingArrangment = aBillingArrangement;
                    }
                }
            }
            try
            {
                System.debug(billingArrangment);
                if(billingArrangment != null && billingArrangment.Term__c.contains(application.Program_Term_Section__c) )
                {
                    Boolean isSchoolDiscount = billingArrangment.Discount_Recipient__c == 'School' && (billingArrangment.Discount_Amount__c != null || billingArrangment.Discount_Amount__c != 0);
                    
                    for(Program_Fee__c programFee : programFeeList )
                    {
                        Boolean isDirectBill = ifsaLineItemPopulator.isDirectBillFor(billingArrangment, programFee.Direct_Bill_Category__c);
                        Application_Line_Item__c appLineItem = new Application_Line_Item__c();
                        // Modified On 4-5-2018 Map the new field of Dim 1,2,3 And 4 to the corresponding fields of Application Line Item. Dimension Ids taken directly from program term                   
                        appLineItem.Academic_Period__c = application.Program_Term__r.Dim_4_Term__c != null ? application.Program_Term__r.Dim_4_Term__c : NULL;
                        appLineItem.Department__c = application.Program_Term__r.Dim_3_Category__c != null ? application.Program_Term__r.Dim_3_Category__c : NULL;
                        if(programFee.Name != 'Guaranteed Scholarship')
                        {
                            appLineItem.School__c = application.Program_Term__r.Dim_2_Host_School__c != null ? application.Program_Term__r.Dim_2_Host_School__c : NULL;
                            appLineItem.Country__c = application.Program_Term__r.Dim_1_Location__c != null ? application.Program_Term__r.Dim_1_Location__c : NULL;
                            appLineItem.Responsible_Party__c = isDirectBill ? 'School' : 'Student';
                        }
                        else
                        {
                            appLineItem.School__c = programLaunchScholarship;
                            appLineItem.Country__c = null;
                            appLineItem.Responsible_Party__c = isSchoolDiscount ? 'School' : 'Student';
                        }
                        appLineItem.Name = programFee.Name;                        
                        appLineItem.Type__c = 'Charge Account';
                        appLineItem.Charge__c = programFee.Amount__c;
                        appLineItem.Product__c = programFee.Product__c;                            
                        appLineItem.Application__c = application.Id;
                        
                        toInsertAppLineItems.add(appLineItem);
                    }

                    if(billingArrangment.Discount_Amount__c != null && !programFeeList.isEmpty())
                    {
                        Application_Line_Item__c appLineItem = new Application_Line_Item__c();
                            // Modified On 4-5-2018 Map the new field of Dim 1,2,3 And 4 to the corresponding fields of Application Line Item. Dimension Ids taken directly from program term
                            appLineItem.Country__c = indyAdmin;
                            // School__c should be left blank according to Regina on 9-6-2018
                            //appLineItem.School__c = application.Program_Term__r.Dim_2_Host_School__c != null ? application.Program_Term__r.Dim_2_Host_School__c : NULL;
                            appLineItem.Academic_Period__c = application.Program_Term__r.Dim_4_Term__c != null ? application.Program_Term__r.Dim_4_Term__c : NULL;
                            appLineItem.Name = 'Program Grant';
                            appLineItem.Type__c = 'Charge Account';
                            appLineItem.Charge__c = billingArrangment.Discount_Amount__c * -1;
                            appLineItem.Product__c = programGrantProductID;
                            appLineItem.Application__c = application.Id;
                            appLineItem.Responsible_Party__c = isSchoolDiscount ? 'School' : 'Student';
                            toInsertAppLineItems.add(appLineItem);
                    }
                    /* Regina does not want this to be automatic because she is not sure how long we will be doing this
                    if(billingArrangment.Account__r.Institution_Type__c == 'Public')
                    {
                        Application_Line_Item__c appLineItem = new Application_Line_Item__c();
                        appLineItem.School__c = guaranteedScholarship;
                        appLineItem.Country__c = null;
                        appLineItem.Responsible_Party__c = isSchoolDiscount ? 'School' : 'Student';
                        appLineItem.Name = 'Guaranteed Scholarship';                        
                        appLineItem.Type__c = 'Charge Account';
                        appLineItem.Charge__c = guaranteedScholarshipAmmount;
                        appLineItem.Product__c = guaranteedScholarshipProductID;
                        appLineItem.Application__c = application.Id;
                        toInsertAppLineItems.add(appLineItem);
                    }*/

                    /*
                    //This has been commented out because this process will not go into effect until the new website is online. Likely for Spring 2018 Term.
                    if(!depositLineItems.contains(application.Id) && application.Program_Term__r.Program__r.Non_Refundable_Advance_Deposit__c != null)
                    {                    
                        Application_Line_Item__c appLineItem = new Application_Line_Item__c(
                            Product__c = depositProductId,
                            Charge__c = application.Program_Term__r.Program__r.Non_Refundable_Advance_Deposit__c,
                            Name = 'Non-Refundable Advance Deposit',
                            Type__c = 'Charge Account',
                            Application__c = application.Id,
                            Responsible_Party__c = billingArrangment.Pays_Advanced_Deposit__c ? 'School' : 'Student'
                        );
                        if(appTermList.size()>0){                        
                            appLineItem.Country__c = appTermList[0].Dim_1_Location__c !=null ? appTermList[0].Dim_1_Location__c:NULL;
                            appLineItem.Academic_Period__c = appTermList[0].Dim_4_Term__c !=null?appTermList[0].Dim_4_Term__c:NULL;
                            appLineItem.Department__c = appTermList[0].Dim_3_Category__c !=null?appTermList[0].Dim_3_Category__c:NULL;
                            appLineItem.School__c = appTermList[0].Dim_2_Host_School__c !=null?appTermList[0].Dim_2_Host_School__c:NULL;
                        } 
                        toInsertAppLineItems.add(appLineItem);
                    }
                    */
                }
                else
                {
                    /*
                     Handles instances where a student's home school does not have a billing arrangement for the student's program, this will create 
                     Application_Line_Item__c records where the "Responsible_Party__c" will be "Student"
                    */
                    for(Program_Fee__c programFee : programFeeList )
                    {
                        Application_Line_Item__c appLineItem = new Application_Line_Item__c();
                        // Modified On 4-5-2018 Map the new field of Dim 1,2,3 And 4 to the corresponding fields of Application Line Item. Dimension Ids taken directly from program term                   
                        appLineItem.Academic_Period__c = application.Program_Term__r.Dim_4_Term__c != null ? application.Program_Term__r.Dim_4_Term__c : NULL;
                        appLineItem.Department__c = application.Program_Term__r.Dim_3_Category__c != null ? application.Program_Term__r.Dim_3_Category__c : NULL;
                        if(programFee.Name != 'Guaranteed Scholarship')
                        {
                            appLineItem.School__c = application.Program_Term__r.Dim_2_Host_School__c != null ? application.Program_Term__r.Dim_2_Host_School__c : NULL;
                            appLineItem.Country__c = application.Program_Term__r.Dim_1_Location__c != null ? application.Program_Term__r.Dim_1_Location__c : NULL;
                            appLineItem.Responsible_Party__c = 'Student';
                        }
                        else
                        {
                            appLineItem.School__c = programLaunchScholarship;
                            appLineItem.Country__c = null;
                            appLineItem.Responsible_Party__c = 'Student';
                        }
                        appLineItem.Name = programFee.Name;                        
                        appLineItem.Type__c = 'Charge Account';
                        appLineItem.Charge__c = programFee.Amount__c;
                        appLineItem.Product__c = programFee.Product__c;                            
                        appLineItem.Application__c = application.Id;
                        
                        toInsertAppLineItems.add(appLineItem);
                    }
                    /* Regina does not want this to be automatic because she is not sure how long we will be doing this
                    if(application.Applicant__r.Home_Institution__r.Account__r.Institution_Type__c == 'Public')
                    {
                        Application_Line_Item__c appLineItem = new Application_Line_Item__c();
                        appLineItem.School__c = guaranteedScholarship;
                        appLineItem.Country__c = null;
                        appLineItem.Responsible_Party__c = 'Student';
                        appLineItem.Name = 'Guaranteed Scholarship';                        
                        appLineItem.Type__c = 'Charge Account';
                        appLineItem.Charge__c = guaranteedScholarshipAmmount;
                        appLineItem.Product__c = guaranteedScholarshipProductID;
                        appLineItem.Application__c = application.Id;
                        toInsertAppLineItems.add(appLineItem);
                    }*/
                }
            }
            catch (Exception e)
            {
                appsWithoutBillingArrangements.add(application);
            }
        }
        if(!appsWithoutBillingArrangements.isEmpty())
        {
            //Create the error message email
            String messageBody = 'The following home institution accounts are missing billing authorizations for the applications <br/><hr/><br/>';
            messageBody = messageBody + '<table><tr><td>Home Institution Account</td><td>Application<td></tr><tr>';
            for(Application__c app: appsWithoutBillingArrangements)
            {
                messageBody = messageBody + '<td><a href="https://ifsa.my.salesforce.com/' + app.Home_Institution_Account__c + '">' + app.Id + '</a></td><td><a href="https://ifsa.my.salesforce.com/' + app.Name + '">' + app.Home_Institution__c + '</a>' + '/td>';
            }
            messageBody = messageBody + '</tr></table>';
            User finance = [SELECT Id, Email FROM User WHERE Name = 'Regina Owens'].get(0);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setReplyTo('no-reply@ifsa-butler.org');
            mail.setSenderDisplayName('IFSA-Butler No Reply');
            mail.setToAddresses(new List<String> {finance.Email});
            mail.setSubject('Missing Billing Arrangements');
            mail.setHtmlBody(messageBody);

			Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
        if(!appsWithoutBillingArrangements.isEmpty())
        {
            //Create the error message email
            String messageBody = 'The following home institution accounts are missing billing authorizations for the applications <br/><hr/><br/>';
            messageBody = messageBody + '<table><tr><td>Home Institution Account</td><td>Application<td></tr><tr>';
            for(Application__c app: appsWithoutBillingArrangements)
            {
                messageBody = messageBody + '<td><a href="https://ifsa.my.salesforce.com/' + app.Home_Institution_Account__c + '">' + app.Id + '</a></td><td><a href="https://ifsa.my.salesforce.com/' + app.Name + '">' + app.Home_Institution__c + '</a>' + '/td>';
            }
            messageBody = messageBody + '</tr></table>';
            User finance = [SELECT Id, Email FROM User WHERE Name = 'Regina Owens'].get(0);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setReplyTo('no-reply@ifsa-butler.org');
            mail.setSenderDisplayName('IFSA-Butler No Reply');
            mail.setToAddresses(new List<String> {finance.Email});
            mail.setSubject('Missing Billing Arrangements');
            mail.setHtmlBody(messageBody);

			Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
        ifsaLineItemBatchInsert liBatch = new ifsaLineItemBatchInsert(toInsertAppLineItems, programTerms);
        
        string batchId = Database.executeBatch(liBatch);
        return batchId;
    }

    private static Boolean isDirectBillFor(Billing_Arrangement__c billingArrangment, String feeCategory)
    {
        if(!billingArrangment.Direct_Bill__c)
        {
            return false;
        }
        if(billingArrangment.Pays_Accomodation__c && feeCategory == 'Accommodation')
        {
            return true;
        }
        if(billingArrangment.Pays_Deposit__c && feeCategory == 'Non-Refundable Deposit')
        {
            return true;
        }
        if(billingArrangment.Pays_Tuition__c && feeCategory == 'Tuition')
        {
            return true;
        }

        return false;
    }

    /**
     * Creates application line items based off of the application RUNS FROM APPLICATION AFTER UPDADE TRIGGER
     */
    public static void populateApplications(List<Id> applicationIds)
    {
        String batchId = populateApplications(applicationIds, null);
    }
}