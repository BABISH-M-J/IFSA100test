/**
 * Test class for the custom portal profile controller.
 * THE CUSTOM PORTAL IS POWERD BY THE CATALOG STUDENT PORTAL SO THAT EFFORTS ARE NOT DUPLICATED AS OF SUMMER 2020
 * @author Cameron Ames
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
public without sharing class customProfileControllerTest
{
	/**
	 * @description test all instance methods
	 */
	public static testMethod void testInstance()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		User studentUser = (User) testInfo.get('studentUser');

		try
		{
			System.runAs(studentUser)
			{
				test.startTest();
				customProfileController controller = new customProfileController();
				controller.validateAccess();
				controller.uploadPhoto();
				controller.save();
				test.stopTest();
			}
		}
		catch(Exception e)
		{
			System.assertEquals(true, false, 'An Exception was thrown. ' + e.getMessage());
		}
	}
}