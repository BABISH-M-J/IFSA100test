@isTest
private class userTriggerTest {
	
	@isTest static void updateUserTest()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();

		User u = (User) testInfo.get('academicAffiarsUser');

		Database.update(u);
	}

	@isTest static void insertUserTest()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		Test.startTest();
		Contact c = (Contact) testInfo.get('studentContact');
		c.Id = null;
		c.Active_Application__c = null;
		Database.insert(c);
		User u = apexMockDataUtility.createUser(c.Id);
		Database.insert(u);
		Test.stopTest();
	}

	@isTest static void deactivateUserTest() 
	{
		userTriggerHandler.bypassAfterInsert = true;
		// Build Test
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();

		User u = (User) testInfo.get('academicAffiarsUser');
		User s = (User) testInfo.get('studentUser');
		List<Incident_Matrix__c> ims = apexMockDataUtility.createMatrix(u.Id);
		List<Support_Personnel__c> sps = [SELECT Id FROM Support_Personnel__c WHERE IFSA_Staff__c =: u.Id];
		// Ensure we have records to delete
		System.assertEquals(false, sps.isEmpty(), sps.size());
		System.assertEquals(false, ims.isEmpty(), ims.size());
		
		u.IsActive = false;
		s.IsActive = false;
		// Start  Test
		User a = [SELECT Id FROM User WHERE Alias = 'fadmi'];
		system.runAs(a)
		{
			Test.startTest();
			// Update user as inactive
			Database.update(new List<User>{u, s});
			Test.stopTest();
		}		
		// Get Results
		sps = [SELECT Id FROM Support_Personnel__c WHERE IFSA_Staff__c =: u.Id];
		ims = [SELECT Id FROM Incident_Matrix__c WHERE IFSA_Staff__c =: u.Id];
		
		// Assert that the records were deleted
		System.assertEquals(true, sps.isEmpty(), sps.size());
		System.assertEquals(true, ims.isEmpty(), ims.size());
		userTriggerHandler.bypassAfterInsert = false;
	}
	@isTest (SeeAllData=true)
	static void createContentWorkspaceLinkTest()
	{
		List<ContentVersion> csvFiles = [SELECT ContentDocumentId, TagCsv FROM ContentVersion LIMIT 1];
		Test.startTest();
		userService.createContentWorkspaceDocs(new Map<Id, ContentVersion>(csvFiles), 'Test_' + Math.roundToLong(Math.random()*99999));
		Test.stopTest();
		List<ContentWorkSpaceDoc> cdl = [SELECT Id FROM ContentWorkSpaceDoc WHERE ContentDocumentId =: csvFiles.get(0).ContentDocumentId];
		System.assertEquals(false, cdl.isEmpty());
	}
}