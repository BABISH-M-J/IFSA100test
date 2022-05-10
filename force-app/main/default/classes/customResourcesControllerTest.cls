/**
 * Test class for Resource Controller of the custom portal
 * THE CUSTOM PORTAL IS POWERD BY THE CATALOG STUDENT PORTAL SO THAT EFFORTS ARE NOT DUPLICATED AS OF SUMMER 2020
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
public without sharing class customResourcesControllerTest {

    public static testMethod void testInstance()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		User studentUser = (User) testInfo.get('studentUser');
		System.runAs(studentUser)
		{
			test.startTest();
			customResourcesController controller = new customResourcesController();
			PageReference reference = controller.validateAccess();
			test.stopTest();
		}
	}
}