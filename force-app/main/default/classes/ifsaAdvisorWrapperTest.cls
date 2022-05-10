/**
 * @description Test class for the advisor wrapper class
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public with sharing class ifsaAdvisorWrapperTest
{
	/**
	 * @description Test the instance methods and constructors
	 */
	public static testMethod void testInstance()
	{
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
		Home_Institution__c homeInstitution = (Home_Institution__c) testData.get('homeInstitution');
		Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
		Id advisorContactId = [SELECT Id FROM Contact WHERE RecordTypeId = :advisorRecordType LIMIT 1].Id;
		User advisorUser = apexMockDataUtility.createAdvisor(advisorContactId);
		Contact advisorContact = (Contact) testData.get('advisorContact1');
		advisorContact.Advisor_Type__c = 'Billing';
		Database.update(advisorContact);
		
		//Test instance constructor
		ifsaAdvisorWrapper advisorWrapper = new ifsaAdvisorWrapper(advisorUser, new Contact());
		
		//Test Id constructor
		System.runAs(advisorUser)
		{
			Test.startTest();
			advisorWrapper = new ifsaAdvisorWrapper(UserInfo.getUserId());

			//Test view model populators
			advisorProfileViewModel viewModel = (advisorProfileViewModel) advisorWrapper.populateAdvisorBaseViewModel(new AdvisorProfileViewModel());
			System.assertNotEquals(null, viewModel.approvedForAdvising, 'Approved for advising should not be null.');
			viewModel = advisorWrapper.populateViewModel(viewModel);
			System.assertNotEquals(null, viewModel.AdvisorReceiveAlerts, 'Receive alerts should not be null.');
			
			viewModel.AdvisorFax = '8675309';
			System.assert(advisorWrapper.saveInformation(viewModel), 'The information failed to save.');
			
			viewModel = advisorWrapper.populateViewModel(viewModel);
			System.assertEquals('8675309', viewModel.AdvisorFax, 'The fax number did not equal the saved value.');
			
			advisorInstitutionViewModel viewModel2 = advisorWrapper.populateViewModel(new advisorInstitutionViewModel());
			System.assertNotEquals(null, viewModel.AdvisorType, 'The advisor Type should not be null.');
			
			advisorInstitutionalAdvisorsViewModel viewModel3 = advisorWrapper.populateviewModel(new advisorInstitutionalAdvisorsViewModel());
			System.assertNotEquals(null, viewModel3.AdvisorId, 'The advisor Id should not have been null.');
			
			//Test getters
			Id testId = advisorWrapper.getAccountId();
			Boolean isApproved = advisorWrapper.isApprovedForAdvising();
			Test.stopTest();
		}
	}
	public static testMethod void testWebService()
	{
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
		Home_Institution__c homeInstitution = (Home_Institution__c) testData.get('homeInstitution');
		Contact advisorContact = (Contact) testData.get('advisorContact1');
		advisorContact.Advisor_Type__c = 'Billing';
		advisorContact.FirstName = 'Test';
		advisorContact.LastName = 'User';
		advisorContact.Email = 'testUser@email.test';
		advisorContact.Id = null;
		Database.insert(advisorContact);
		Test.startTest();

		String result = ifsaAdvisorWrapper.createAdvisorUser(advisorContact.Id);

		Test.stopTest();

		System.assertEquals('The advisor User has been created and the advisor has been sent a password reset email.', result);
	}
}