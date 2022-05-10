@isTest
private class studentApplicationSelectorControllerTest {
	
	public static testMethod void testInstance()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		User studentUser = (User) testInfo.get('studentUser');
		Application__c app1 = (Application__c) testInfo.get('studentApplication');
		Application__c app2 = (Application__c) testInfo.get('studentApplication2');
        Test.startTest();
        system.runAs(studentUser)
        {        
        	studentApplicationSelectorController controller = new studentApplicationSelectorController();			
        	controller.selectedApplicationId = app2.Id;
        	controller.Save();        	
        }
        Test.stopTest();
	}	
}