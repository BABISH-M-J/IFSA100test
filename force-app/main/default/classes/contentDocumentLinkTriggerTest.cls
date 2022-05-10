/**
 * Unit tests for <<contentDocumentLinkTriggerHandler>> and <<contentDocumentLinkService>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
@isTest
private class contentDocumentLinkTriggerTest {
	
	@isTest
	static void testCreateContentLinks() {
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>());

		ContentVersion testVersion = new ContentVersion();
		// Header row of CSV file
		String csv = 'Test Data';
		testVersion.Title = 'Schedule Backup Test';
		// Set Content Version properties
		testVersion.PathOnClient = '/'+testVersion.Title+'.csv';
		testVersion.VersionData = Blob.valueOf(csv);

		Database.insert(testVersion);
		
		Id fileId = [SELECT Id FROM ContentDocument LIMIT 1].get(0).Id;
		Id appId = [SELECT Id FROM Application__c LIMIT 1].get(0).Id;
		Id accountId = [SELECT Id FROM Account LIMIT 1].get(0).Id;

		Test.startTest();
		ContentDocumentLink link = new ContentDocumentLink(LinkedEntityId = appId, ContentDocumentId = fileId, ShareType = 'V');
		Database.insert(link);

		link = [SELECT Id, Visibility FROM ContentDocumentLink WHERE LinkedEntityId =: appId AND ContentDocumentId =: fileId].get(0);

		system.assertEquals('AllUsers', link.Visibility);

		ContentDocumentLink link2 = new ContentDocumentLink(LinkedEntityId = accountId, ContentDocumentId = fileId, ShareType = 'V');
		Database.insert(link2);

		link2 = [SELECT Id, Visibility FROM ContentDocumentLink WHERE LinkedEntityId =: accountId AND ContentDocumentId =: fileId].get(0);

		system.assertNotEquals('AllUsers', link2.Visibility);
		Test.stopTest();
	}

	@isTest
	static void testCreateContentLinksWithNoShareKeywords() {
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>());

		ContentVersion testVersion = new ContentVersion();
		// Header row of CSV file
		String csv = 'Test Data';
		testVersion.Title = 'Student Transcript';
		// Set Content Version properties
		testVersion.PathOnClient = '/'+testVersion.Title+'.csv';
		testVersion.VersionData = Blob.valueOf(csv);

		Database.insert(testVersion);
		
		Id fileId = [SELECT Id FROM ContentDocument LIMIT 1].get(0).Id;
		Id appId = [SELECT Id FROM Application__c LIMIT 1].get(0).Id;
		Id accountId = [SELECT Id FROM Account LIMIT 1].get(0).Id;

		Test.startTest();
		ContentDocumentLink link = new ContentDocumentLink(LinkedEntityId = appId, ContentDocumentId = fileId, ShareType = 'V');
		Database.insert(link);

		link = [SELECT Id, Visibility FROM ContentDocumentLink WHERE LinkedEntityId =: appId AND ContentDocumentId =: fileId].get(0);

		system.debug(link.Visibility);
		system.assertEquals('InternalUsers', link.Visibility);

		Test.stopTest();
	}
	@isTest
	static void testSetLastUploadDateNonPortalUser() {
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'Courses'});

		ContentVersion testVersion = new ContentVersion();
		// Header row of CSV file
		String csv = 'Test Data';
		testVersion.Title = 'Syllabi Test 1';
		// Set Content Version properties
		testVersion.PathOnClient = '/'+testVersion.Title+'.csv';
		testVersion.VersionData = Blob.valueOf(csv);

		Database.insert(testVersion);
		
		Id fileId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: testVersion.Id].get(0).ContentDocumentId;
		Id courseId = [SELECT Id FROM Course__c LIMIT 1].get(0).Id;

		Test.startTest();
		ContentDocumentLink link = new ContentDocumentLink(LinkedEntityId = courseId, ContentDocumentId = fileId, ShareType = 'V');
		Database.insert(link);

		Course__c c = [SELECT Id, Last_File_Upload_Date__c FROM Course__c WHERE Id =: courseId];

		system.assertEquals(null, c.Last_File_Upload_Date__c);
		Test.stopTest();
	}
	@isTest
	static void testSetLastUploadDatePortalUser() {
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>{'Courses'});
		Course__c c = new Course__c(
			Id = [SELECT Id FROM Course__c LIMIT 1].get(0).Id
		);
		// Header row of CSV file
		String csv = 'Test Data';
		String title = 'Syllabi Test 1';

		Boolean saved = false;
		Test.startTest();
		system.runAs((User) testData.get('studentUser'))
		{
			/*
			ContentVersion testVersion = new ContentVersion(
				Title = title,
				ContentLocation = 'S',
				PathOnClient = '/'+title+'.csv',
				VersionData = Blob.valueOf(csv),
				FirstPublishLocationId = c.Id,
				NetworkId = [SELECT Id FROM Network WHERE Name = 'Student Portal'].get(0).Id
			);
			Database.insert(testVersion);
			*/
			saved = portalOnSiteRemotingMethods.submitSyllabus(c.Id, csv, 'csv', title + '.csv');
		}

		c = [SELECT Id, Last_File_Upload_Date__c FROM Course__c WHERE Id =: c.Id];
				
		system.assertNotEquals(null, c.Last_File_Upload_Date__c);
		Test.stopTest();
	}
}