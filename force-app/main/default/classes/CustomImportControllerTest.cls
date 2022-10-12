/**
 * Unit tests for <<CustomImportController>>
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
private class CustomImportControllerTest {
	
	@isTest static void testInstanceGood() {
		Map<String, sObject> testData = apexMockDataUtility.createIfsaDataCollection();
		Program__c customProgram = (Program__c) testData.get('program');
		customProgram.Category__c = 'Custom';
		customProgram.Custom_Program_Home_Instituiton_Account__c = testData.get('institutionAccount1').Id;
		customProgram.Student_Access_to_Portal__c = 'Custom';
		customProgram.Display_Account_Tab__c = 'No';
		Database.update(customProgram);
		Blob csvBlobGood =  Blob.valueOf('last_name,first_name,preferred_name,middle_name,pronouns,gender,birthdate,passport_number,passport_expiration,country,email,phone_number\nBlazdell,Eadmund,Eadmund,Denys,his,Male,12/29/2001,709544558-3,4/25/2027,United States,dblazdell0@skyrock.com.test,540-735-5571\nMournian,Trista,Trista,Amalita,hers,Female,4/24/2000,647551979-0,2/22/2024,United States,amournian1@usgs.gov.test,212-270-1872');

		Test.setCurrentPageReference(new PageReference('CustomImport'));
		System.currentPageReference().getParameters().put('programTermId', testData.get('programTerm').Id);
		CustomImportController controller = new CustomImportController();
		
		// Test with known good csv file
		controller.csvFileBody = csvBlobGood;
		controller.importCSVFile();
		Test.startTest();
		controller.SaveAccounts();
		controller.SaveContacts();
		controller.SaveApplications();
		Test.stopTest();
		
	}

	@isTest static void testInstanceBad() {
		Map<String, sObject> testData = apexMockDataUtility.createIfsaDataCollection();
		Program__c customProgram = (Program__c) testData.get('program');
		customProgram.Category__c = 'Custom';
		customProgram.Custom_Program_Home_Instituiton_Account__c = testData.get('institutionAccount1').Id;
		customProgram.Student_Access_to_Portal__c = 'Custom';
		customProgram.Display_Account_Tab__c = 'No';
		Database.update(customProgram);
		Blob csvBlobBad1 =  Blob.valueOf('last_name,first_name,preferred_name,middle_name,pronouns,gender,birthdate,passport_number,passport_expiration,country,email,phone_number\nBlazdell,Eadmund,Eadmund,Denys,his,Male,12/29/2001,709544558-3,,United States,dblazdell0@skyrock.com.test,540-735-5571\nMournian,Trista,Trista,Amalita,hers,Female,4/24/2000,647551979-0,2/22/2024,United States,amournian1@usgs.gov.test,212-270-1872');
		Blob csvBlobBad2 =  Blob.valueOf('last_name,first_name,preferred_name,middle_name,pronouns,gender,birthdate,passport_number,passport_expiration,country,email,phone_number\nBlazdell,Eadmund,Eadmund,Denys,his,,12/29/2001,709544558-3,4/25/2027,United States,dblazdell0@skyrock.com.test,540-735-5571\nMournian,Trista,Trista,Amalita,hers,Female,4/24/2000,647551979-0,2/22/2024,United States,amournian1@usgs.gov.test,212-270-1872');
		Test.startTest();
		Test.setCurrentPageReference(new PageReference('CustomImport'));
		System.currentPageReference().getParameters().put('programTermId', testData.get('programTerm').Id);
		CustomImportController controller = new CustomImportController();

		// Test with bad file to have an error
		controller.csvFileBody =  csvBlobBad1;
		controller.importCSVFile();
		controller.csvFileBody =  csvBlobBad2;
		controller.importCSVFile();

		Test.stopTest();
	}
}