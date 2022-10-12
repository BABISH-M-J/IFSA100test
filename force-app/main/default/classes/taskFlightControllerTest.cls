@isTest
private class taskFlightControllerTest {
	@isTest static void getFlightsPassTest() {
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
		Application__c app = (Application__c) testData.get('studentApplication');
		User studentUser = (User) testData.get('studentUser');
		
		Travel_PLan__c travelPlan = new Travel_Plan__c();
		travelPlan.Status__c = 'Submitted For Approval';
		travelPlan.Travel_Plan_Information__c = 'Unit Test Data';

		app.Travel_Plan__c = travelPlan.Id;
		test.startTest();
		system.runAs(studentUser)
        {
			database.insert(travelPlan);
		}

		travelPlan = (Travel_Plan__c) apexQueryUtility.selectAllFrom('Travel_Plan__c', 'Travel_Plan_Information__c = \'' + travelPlan.Travel_Plan_Information__c + '\'').get(0);

		Task travelPlanApproval = new Task();
		travelPlanApproval.description = travelPlan.Travel_Plan_Information__c;
		travelPlanApproval.Priority = 'Normal';
		travelPlanApproval.recordTypeId = '01261000000kpUyAAI';
		travelPlanApproval.Status = 'Not Started';
		travelPlanApproval.Subject = 'Student Travel Plan needs approval';
		travelPlanApproval.WhatId = travelPlan.Id;
		travelPlanApproval.WhoId = app.Applicant__c;
		system.runAs(studentUser)
        {
			database.insert(travelPlanApproval);
		}

		ApexPages.StandardController sc = new ApexPages.StandardController(travelPlanApproval);
		taskFlightController controller = new taskFlightController(sc);

		test.stopTest();
	}
	@isTest static void getFlightsFailTest() {
		ApexPages.StandardController sc = new ApexPages.StandardController(new Task());
		taskFlightController controller = new taskFlightController(sc);
	}
}