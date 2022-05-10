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
        
        List<User> usr = [Select Id,Contact.Name from User WHERE Id=:studentUsr.Id];
        
        System.runAs(studentUsr) {
            ApexPages.currentPage().getParameters().put('SNAME','Test4');
            sitePaymentCtrl obj = new sitePaymentCtrl();
            obj.createCashEntry();
        }
    }
}