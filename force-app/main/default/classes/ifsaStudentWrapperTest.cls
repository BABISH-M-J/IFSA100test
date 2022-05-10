/**
 * @description Test class for the <<ifsaStudentWrapper>>
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public with sharing class ifsaStudentWrapperTest
{
	/**
	 * @description Test the instance methods and constructors
	 */
	public static testMethod void testInstance()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		User studentUser = (User) testInfo.get('studentUser');
		Test.startTest();
		//Test instance constructor
		ifsaStudentWrapper studentWrapper = new ifsaStudentWrapper(studentUser, new Contact(), new Account());
		
		//Test Id constructor
		System.runAs(studentUser)
		{
			studentWrapper = new ifsaStudentWrapper(UserInfo.getUserId());

			//Test view model populators
			studentApplyViewModel viewModel = (studentApplyViewModel) studentWrapper.populateStudentBaseViewModel(new studentApplyViewModel());
			System.assertNotEquals(null, viewModel.studentLastName, 'The view model student last name should not be null.');
			
			customDocumentsViewModel viewModel3 = (customDocumentsViewModel) studentWrapper.populateCustomBaseViewModel(new customDocumentsViewModel());
			System.assertNotEquals(null, viewModel3.studentLastName, 'The view model student last Name should not be null.');
			
			customProfileViewModel viewModel4 = studentWrapper.populateViewModel(new customProfileViewModel());
			System.assertNotEquals(null, viewModel4.StudentEmail, 'The view model should not have a null email.');

			studentApplyItemDetailsViewModel viewModel2 = new studentApplyItemDetailsViewModel();
			viewModel2.mailingCity = 'Test';
			viewModel2.mailingCountry = 'USA';
			viewModel2.mailingState = 'IN';
			viewModel2.mailingStreet = '12345';
			viewModel2.mailingZip = '54321';
			viewModel2.sameBillingAddress = true;
			viewModel2.sameOtherAddress = false;
			
			System.assert(studentWrapper.saveInformation(viewModel2), 'The information failed to save.');
			System.assertEquals(viewModel2.mailingStreet, studentWrapper.getAccount().BillingStreet, 'The billing street did not match the mailing street.');
			
			//Test getters
			Contact testContact = studentWrapper.getContact();
			Account testAccount = studentWrapper.getAccount();
			User testUser = studentWrapper.getUser();
			Id testId = studentWrapper.getActiveApplicationId();
			testId = studentWrapper.getHomeInstitutionId();
		}
		Test.stopTest();
	}
}