@isTest
public without sharing class studentHomeControllerTest
{
	public static testMethod void testInstance()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		User studentUser = (User) testInfo.get('studentUser');
		Test.startTest();
		System.runAs(studentUser)
		{
			studentHomeController controller = new studentHomeController();
			PageReference reference = controller.validateAccess();
		}
		Test.stopTest();
	}
}