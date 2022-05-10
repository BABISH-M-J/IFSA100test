/**
 * Test class for apexSandboxData class
 * BBARLOW 3-9-2018 - Commenting out this test class and the class it tests so that it is not counted against apex limits and 
 * code coverage requirements. Developers will need to uncomment this class when needing to test creating mock data in 
 * Developer sandboxes.
*/
// ApexDoc updated 1/25/2021 Brock Barlow
@isTest
public with sharing class apexSandboxDataTest {
    /*
	public static testMethod void testGenerateSandboxData()
    {
    	User advisorUser = new User();
		advisorUser.FirstName = 'TEST';
		advisorUser.LastName = 'USER';
		advisorUser.Email = 'testuser'+ Integer.valueOf(math.rint(math.random()*1000000)) +'@yahoo.com.test';
		if(advisorUser.Email.split('@').get(0).length() > 20)
		{
			advisorUser.CommunityNickname = advisorUser.Email.split('@').get(0).substring(0,20) + String.valueOf(Math.random() * 100);
		}
		else
		{
			advisorUser.CommunityNickname = advisorUser.Email.split('@').get(0) + String.valueOf(Math.random() * 100);
		}
		
		Integer aliasEnding = 4;
		if(advisorUser.FirstName.length() < 4)
		{
			aliasEnding = advisorUser.FirstName.length();
		}
		
		advisorUser.Alias = advisorUser.FirstName.substring(0,1) + advisorUser.LastName.substring(0,aliasEnding);
		advisorUser.Username = advisorUser.Email + '.ifsa';
		advisorUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].get(0).Id;
		advisorUser.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'President'].get(0).Id;
		advisorUser.EmailEncodingKey = 'UTF-8';
		advisorUser.LanguageLocaleKey = 'en_US';
		advisorUser.LocaleSidKey = 'en_US';
		advisorUser.TimeZoneSidKey = 'America/Indiana/Indianapolis';
		
		database.insert(advisorUser);
		
		test.startTest();
        system.runAs(advisorUser)
        {
        	apexSandboxData.generateSandboxData();
        }
        
        

        test.stopTest();
    }

	public static testMethod void testCreateOtherRecords()
    {
		Map<String, sObject> testData = apexMockDataUtility.createIfsaDataCollection();
		test.startTest();
		apexSandboxData.createOtherRecords();
		test.stopTest();
	}
	*/
}