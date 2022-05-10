/**
 * Test class for apexConfigurationUtility
 * @author Cameron Ames
 */
// ApexDoc updated 1/25/2021 Brock Barlow
 @isTest
public without sharing class apexConfigurationUtilityTest
{
	/**
	 * Tests default behavior
	 */
	public static testMethod void testDefaults()
	{
		//Attempt without any configuration settings.
		apexConfigurationUtility configUtility = apexConfigurationUtility.getInstance();

		System.assert(!configUtility.isDebugOn(), 'Debug should not be on by default.');
		System.assert(!configUtility.isNewAdvisorEnabled(), 'new advisor alert emails should not be on by default.');
		System.assertEquals(0, configUtility.getNewAdvisorRecipients().size(), 'There should not be any new advisor recipients by default.');
	}

	/**
	 * Tests with actual settings
	 */
	public static testMethod void testActiveSettings()
	{
		//Create test configurations
		IFSA_Code_Execution_Settings__c codeSettings = apexMockDataUtility.createCodeSettings('Test');
		IFSA_Email_Settings__c emailSettings = apexMockDataUtility.createEmailSettings('Test');
		IFSA_Configuration_Settings__c configurationSettings = apexMockDataUtility.createConfigurationSettings('Settings', 'Test', 'Test');
		
		apexConfigurationUtility.reset();
		apexConfigurationUtility configUtility = apexConfigurationUtility.getInstance();
		
		System.assert(configUtility.isDebugOn(), 'Our test settings should indicate that debug is on.');
		System.assert(configUtility.isNewAdvisorEnabled(), 'new advisor alert emails should be on with our new test settings.');
		System.assertEquals(2, configUtility.getNewAdvisorRecipients().size(), 'There should be 2 advisor recipients with our new test settings.');
	}
}