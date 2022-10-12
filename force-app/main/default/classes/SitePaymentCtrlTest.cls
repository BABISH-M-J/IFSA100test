@isTest
public without sharing class SitePaymentCtrlTest {
    public static testMethod void testInstance() {
        Account studentAcct = apexMockDataUtility.createAccount('Test2');
        //insert studentAcct;
        
        Contact studentCtc = apexMockDataUtility.createContact('Test4', studentAcct.Id);
        //insert studentCtc;
        
        List<Contact> tt = [Select Id,Name from Contact WHERE Id=:studentCtc.Id];
        System.debug('name===='+tt);
        
        User studentUsr = apexMockDataUtility.createUser(studentCtc.Id);
        // added by powerfluence based on Clayton req 03/29/2022 starts
        Database.upsert(studentUsr);
        // added by powerfluence based on Clayton req 03/29/2022 ends
        List<User> usr = [Select Id,Contact.Name from User WHERE Id=:studentUsr.Id];
        
        System.runAs(studentUsr) {
            ApexPages.currentPage().getParameters().put('SNAME','Test4');
            // added by powerfluence based on Clayton req 03/29/2022 starts
            ApexPages.currentPage().getParameters().put('PARENT RECORD ID',studentCtc.Id);
            // added by powerfluence based on Clayton req 03/29/2022 ends
            sitePaymentCtrl obj = new sitePaymentCtrl();
            obj.createCashEntry();
           
        }
    }
}