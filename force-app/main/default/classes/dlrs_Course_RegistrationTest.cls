/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Course_RegistrationTest
{
    
    @IsTest
    private static void testTrigger()
    {
        Account a = new Account(Name = 'Test Account');
        Database.insert(a);
        Contact c = new Contact(LastName = 'Contact', FirstName = 'Test', AccountId = a.Id);
        Database.insert(c);
        Application__c app = new Application__c(Applicant__c = c.Id, Name = 'Test Application', Status__c = 'New');
        Database.insert(app);
        // Force the dlrs_Course_RegistrationTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Course_Registration__c(Application__c = app.Id));
    }
}