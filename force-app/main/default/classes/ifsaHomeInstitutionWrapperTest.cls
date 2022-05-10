/**
 * Test class for the home institution wrapper class.
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public without sharing class ifsaHomeInstitutionWrapperTest
{
	/**
	 * Test instance methods
	 */
	public static testMethod void testInstance()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		Contact studentContact = (Contact) testInfo.get('studentContact');
		test.startTest();
		//Test constructors
		ifsaHomeInstitutionWrapper homeInstitution = new ifsaHomeInstitutionWrapper(new Home_Institution__c(Id = studentContact.Home_Institution__c), new Account());
		
		homeInstitution = new ifsaHomeInstitutionWrapper(studentContact.Home_Institution__c);
		homeInstitution = ifsaHomeInstitutionWrapper.constructByAccountId(homeInstitution.getAccountId());
		
		Account hiAccount = (Account) testInfo.get('institutionAccount1');
		Contact advisorContact1 = apexMockDataUtility.createContact('TEst1', hiAccount.Id);
		Contact advisorContact2 = apexMockDataUtility.createContact('Test2', hiAccount.Id);
		User advisorUser1 = apexMockDataUtility.createAdvisor(advisorContact1.Id);
		User advisorUser2 = apexMockDataUtility.createAdvisor(advisorContact2.Id);

		List<ifsaAdvisorWrapper> advisorWrappers = homeInstitution.getAdvisors();

		//Test view model populators
		advisorProfileViewModel viewModel = homeInstitution.populateViewModel(new advisorProfileViewModel());
		System.assertNotEquals(null, viewModel.HomeInstitutionName, 'The home institution Name should not be null.');
		
		advisorInstitutionViewModel viewModel2 = homeInstitution.populateViewModel(new advisorInstitutionViewModel());
		System.assertNotEquals(null, viewModel2.HomeInstitutionName, 'The home institution Name should not be null.');
		test.stopTest();
	}
}