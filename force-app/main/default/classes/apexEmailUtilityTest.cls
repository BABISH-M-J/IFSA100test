/**
 * Test class for sending out emails via apex.
 * @author Cameron Ames
 */
// ApexDoc updated 1/25/2021 Brock Barlow
 @isTest
public without sharing class apexEmailUtilityTest
{
	@TestSetup
    static void makeData(){
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection();
    }

	/**
	 * Tests the send program approval notification method
	 */
	public static testMethod void testSendProgramApprovalNotification()
	{
		Contact studentCtc = [SELECT Id, Home_Institution__c FROM Contact LIMIT 1];
		Application__c studentApplication = [SELECT Id FROM Application__c LIMIT 1];
		test.startTest();
		//Student should have HI People
		apexEmailUtility.sendProgramApprovalNotification(new List<Id>{studentApplication.Id});
		//Now we test Summer Only Advisors
		Program_Term__c pt = [SELECT Id FROM Program_Term__c LIMIT 1];
		Term__c t = [SELECT Id FROM Term__c WHERE Section__c = 'Summer' LIMIT 1];
		pt.Term__c = t.id; 
		
		Database.update(pt);
		
		apexEmailUtility.sendProgramApprovalNotification(new List<Id>{studentApplication.Id});
		
		//Now we associate student to nobody
		studentCtc.Home_Institution__c = null;
		Database.update(studentCtc);
		
		apexEmailUtility.sendProgramApprovalNotification(new List<Id>{studentApplication.Id});
		test.stopTest();
	}
	
	/**
	 * Tests the send new advisor alerts method.
	 */
	public static testMethod void testSendNewAdvisorAlert()
	{
		apexMockDataUtility.createEmailSettings('Default');
		Home_Institution__c homeInstitution = [SELECT Id FROM Home_Institution__c LIMIT 1];
		Account acct = apexMockDataUtility.createAccount('Test', homeInstitution.Id);

		Contact ctc = apexMockDataUtility.createContact('Test', acct.Id);
		test.startTest();
		apexEmailUtility.sendNewAdvisorAlert(new List<Id>{ctc.Id});
		test.stopTest();
	}
	
	/**
	 * Test the send error email method.
	 */
	public static testMethod void testSendErrorEmail()
	{
		apexEmailUtility.sendErrorEmail('this is a test');
	}

	public static testMethod void testSendGeneralEmail()
	{
		Contact student = [SELECT Id FROM Contact LIMIT 1];
		apexEmailUtility.sendGeneralEmail('Test', 'Test', new List<Id>{student.Id}, true);
		apexEmailUtility.sendGeneralEmail('Test', 'Test', new List<Id>{student.Id}, true, 'test@test.test,test@test.test', 'test@test.test,test@test.test');
		apexEmailUtility.sendGeneralEmail('Test', 'Test', new List<Id>{student.Id}, false, 'test@test.test', 'test@test.test');
	}
}