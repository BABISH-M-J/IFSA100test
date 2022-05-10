/**
 * Test class for the program advisor wrapper class
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public with sharing class ifsaProgramAdvisorWrapperTest
{
	/**
	 * Test the instance methods and constructors
	 */
	public static testMethod void testInstance()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		User studentUser = (User) testInfo.get('studentUser');
		test.startTest();
		System.runAs(studentUser)
		{
			//Try to make a student a pa wrapper
			try
			{
			ifsaProgramAdvisorWrapper studentPaWrapper = new ifsaProgramAdvisorWrapper(UserInfo.getUserId());
			System.assert(false, 'An Exception should have been thrown.');
			}
			catch (Exception e)
			{
			System.assert(true, 'this Exception is expected.');
			}
		}
		
		User programAdvisor = apexMockDataUtility.createProgramAdvisor();
		
		//Test instance constructor
		ifsaProgramAdvisorWrapper programAdvisorWrapper = new ifsaProgramAdvisorWrapper(programAdvisor);
		
		System.runAs(programAdvisor)
		{
			//Test Id constructor
			programAdvisorWrapper = new ifsaProgramAdvisorWrapper(UserInfo.getUserId());
			
			studentApplyViewModel viewModel = programAdvisorWrapper.populateViewModel(new studentApplyViewModel());
			System.assertNotEquals(null, viewModel.advisorEmail, 'The view model advisor email should not be null.');
		}
		test.stopTest();
	}
}