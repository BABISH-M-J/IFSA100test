@isTest
private class TravelPlanCreationExtensionTest {
@TestSetup
	static void makeData(){
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
	}

	public static testMethod void testInstance() 
	{
        Application__c studentApplication = [SELECT Id FROM Application__c LIMIT 1];
        Application_Item__c travelPlan = new Application_Item__c();
        travelPlan.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Application_Item__c' AND DeveloperName = 'Travel_Plan'].get(0).Id;
        travelPlan.Status__c = 'Incomplete';
        travelPlan.Phase__c = 'Post-Contract';
        travelPlan.Application__c = studentApplication.Id;

        insert(travelPlan);
        
        Test.startTest();
        
			ApexPages.StandardController sc = new ApexPages.StandardController(studentApplication);
			TravelPlanCreationExtension controller = new TravelPlanCreationExtension(sc);	

		Test.stopTest();
	}	
	
	public static testMethod void testSubmitIndependentTravel()
	{
		Application_Item__c appItem = [SELECT Id FROM Application_Item__c LIMIT 1];
		Program_Term__c pt = [SELECT Id, Orientation_Group__c FROM Program_Term__c LIMIT 1];
		Test.startTest();
		

		List<Map<String, String>> dataMap = new List<Map<String, String>>();
		Map<String, String> flight = new Map<String, String>();
		flight.put('flightNumber', 'AA23');
		flight.put('Departure_Airport_Code__c', 'asd');
		flight.put('Arrival_Airport_Code__c', 'fds');
		Date testDate = Date.Today(); 
		flight.put('departureTime', testDate.Year() + '-05-21 10-10-10');
		flight.put('arrivalTime', testDate.Year() + '-05-21-10-10-10');
		dataMap.add(flight);
		
		Contact ctc = new Contact();
		ctc.LastName = 'TEst';
		ctc.Email = 'asdf@asdf.com';
		Database.insert(ctc);

		Travel_Plan__c testTravelPlan = new Travel_Plan__c();
		Arrival_Plan__c testArrivalPlan = new Arrival_Plan__c();
		Orientation_Group__c testOrientationGroup = new Orientation_Group__c();
		testTravelPlan.Name = 'Test Travel Plan';
		database.insert(testTravelPlan);
		testArrivalPlan.Name = 'Test Group Travel Option';
		testArrivalPlan.Arrival_Plan_Type__c = 'Suggested Flight';
		testArrivalPlan.Orientation_Group__c = testOrientationGroup.id;
		//testArrivalPlan.Program_Term__c = pt.id;
		database.insert(testArrivalPlan);
		pt.Orientation_Group__c = testOrientationGroup.id;
		database.update(pt);
	
		Boolean isSubmitted = TravelPlanCreationExtension.submitIndependentTravel('', dataMap, appItem.Id);
		System.assertEquals(true, isSubmitted);	
		Test.stopTest();		
	}
}