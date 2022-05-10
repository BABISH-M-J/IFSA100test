/**
 * Tests for studentResourceController
 *
 * Created by Brock Barlow
 */
 @isTest
public without sharing class studentResourcesControllerTest 
{
	private static Map<String, SObject> mockData = new Map<String, SObject>();
	private static Map<String, SObject> getMockData()
	{
		system.debug(mockData.size());
		if(mockData.isEmpty())
		{
			mockData = apexMockDataUtility.createIfsaDataCollection();			
		}		
		return mockData;		
	}
	public static testMethod void testInstance()
	{
		Map<String, SObject>  testData = getMockData();	
    	
		User studentUser = (User) testData.get('studentUser');
		Application__c studentApp = (Application__c) testData.get('studentApplication');
		Program_Term__c pt = (Program_Term__c) testData.get('programTerm');
		pt.Date_Approval_Status__c = 'Approved';
		pt.Arrival_Window_End_Time__c = '12:00 PM';
		pt.Arrival_Window_Start_Time__c = '9:00 AM';
		Resource_Item__c testResourceItem = new Resource_Item__c();
		testResourceItem.Country__c = testData.get('country').Id;
		testResourceItem.Name = 'Test Resource Item';
		testResourceItem.Category__c = 'Test Category';
		Schedule__c testScheduleItem = new Schedule__c(RecordTypeId = Schema.SObjectType.Schedule__c.getRecordTypeInfosByName().get('Break').getRecordTypeId());
		testScheduleItem.Name__c = 'Test Break';
		testScheduleItem.Status__c = 'Approved';
		testScheduleItem.Start_Date__c = Date.Today().addMonths(3);
		testScheduleItem.End_Date__c = testScheduleItem.Start_Date__c.addDays(2);
		testScheduleItem.Description__c = 'Description for test break';
		testScheduleItem.Program_Term__c = pt.Id;
		testScheduleItem.Country__c = pt.Country__c;

		//

		List<Program_Fee__c> pfList = new List<Program_Fee__c>();
		pfList.add(new Program_Fee__c(Name='Housing Fee', Amount__c=1500, Program_Term__c=pt.Id));
		pfList.add(new Program_Fee__c(Name='Non-Refundable Deposit', Amount__c=500, Program_Term__c=pt.Id));
		insert pfList;
		

		
		database.update(pt);
		database.insert(new List<Sobject>{testResourceItem, testScheduleItem});

		System.runAs(studentUser)
		{
			Test.startTest();
			// Test without child program term
			studentResourcesController controller = new studentResourcesController();
			PageReference reference = controller.validateAccess();
			// Test with child program term
			studentApp.Program_Term__c = testData.get('programOption1').Id;
			database.update(studentApp);

			controller = new studentResourcesController();
			// Test with approved program dates
			Program_Term__c ppt = (Program_Term__c) testData.get('programOption1');
			ppt.Date_Approval_Status__c = 'Approved';
			ppt.Arrival_Window_End_Time__c = '12:00 PM';
			ppt.Arrival_Window_Start_Time__c = '9:00 AM';
			database.update(ppt);

			controller = new studentResourcesController();
			
			Test.stopTest();
		}
	}
}