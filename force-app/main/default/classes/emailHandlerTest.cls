/**
 *Test class for <<emailHandler>>
 * @author Cameron Ames
 */
// ApexDoc updated 2/1/2021 Brock Barlow
@isTest
public without sharing class emailHandlerTest
{
	/**
	 * Test Sending the custom portal welcome email with blank contacts.
	 */
    public static testMethod void testCustomPortalWelcomeNoContacts()
    {
		emailHandler.sendCustomPortalWelcomeEmail(null);
    }

	/**
	 * Test Sending the custom portal welcome email with valid contacts.
	 */
	public static testMethod void testCustomPortalWelcomeValid()
	{
		Contact testContact = apexMockDataUtility.createContact('test', null);
		emailHandler.sendCustomPortalWelcomeEmail(new List<Contact>{testContact});
	}
    
    //added by powerfuence Joselin for Codecoverage on configurationManagerClass starts
    Public static testMethod void testConfiguratinManager(){
        configurationManager.shouldExecuteAfterInsertContact();
        contactTriggerContextUtility.setIsAfterTrue();
       contactTriggerContextUtility.isFirstRun();
    }
     //added by powerfuence Joselin for Codecoverage on configurationManagerClass ends
}