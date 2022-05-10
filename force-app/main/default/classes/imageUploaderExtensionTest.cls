/**
 * Test class for <<imageUploaderExtension>>
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
private class imageUploaderExtensionTest {
	
	// Base64 string of a 32x32 pixel white square jpg
	static string imageName = 'Test Image.jpg';
	static string base64Image = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAySURBVFhH7c6xAQAgCMTAx/13Bgt3oPDSpL3qWxY772sBAAAAAAAAAAAAAAAAAPwOSAZNiAQ82P7MAwAAAABJRU5ErkJggg==';
	@isTest static void testInstance() 
	{
		//Create Mock Data
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
		Housing_Assignment__c ha = (Housing_Assignment__c) testData.get('housingAssignment');

		Test.startTest();
		// Launch Controller Extension
		ApexPages.StandardController sc = new ApexPages.StandardController(ha);
		imageUploaderExtension controller = new imageUploaderExtension(sc);

		// Add Attachment
		Attachment testInsert = imageUploaderExtension.upload(imageName, base64Image, ha.Id);
		System.assertNotEquals(null, testInsert);

		// Delete Attachment
		Boolean testDelete = imageUploaderExtension.deleteAttachment(testInsert.Id);
		System.assertEquals(true, testDelete);

		Test.stopTest();
	}
	
	/*@isTest static void test_method_two() {
		// Implement test code
	}*/
	
}