/**
 * Test class for <<BatchUpdateContactEmail>>
 */
// ApexDoc updated 1/26/2021 Brock Barlow
@isTest
private class BatchUpdateContactEmailTest {
	/**
	 * Tests an instance of <<BatchUpdateContactEmail>>
	 */
	@isTest 
	static void testUpdateContact() {
		// Implement test code
		List<Contact> testContacts = new List<Contact>();
		for(Integer i = 0; i<100; i++){
			Contact c = new Contact(FirstName = 'test'+i, LastName = 'testuser');
			if(i<50){
				c.Email = 'test' + i + '@test.com';
				c.Secondary_Email__c = 'testthis' + i + '@test.com.test';
				c.IFSA_Butler_NET_Email__c = 'testingtesting' + i + '@test.com';
			}
			else{
				c.Email = 'test' + i + '@test.com.test';
				c.Secondary_Email__c = 'testthis' + i + '@test.com'; 
				c.IFSA_Butler_NET_Email__c = 'testingtesting' + i + '@test.com.test';
			}
			testContacts.add(c);
		}
		insert testContacts;

		Test.startTest();

		BatchUpdateContactEmail b = new BatchUpdateContactEmail();
		ID batchProcessId = Database.executeBatch(b);

		Test.stopTest();

		List<Contact> updatedContacts = [SELECT Id, Name, Email, Secondary_Email__c, IFSA_Butler_NET_Email__c FROM CONTACT WHERE Email != null AND Secondary_Email__c != null And IFSA_Butler_NET_Email__c != null];
		System.assertEquals(100, updatedContacts.size());
		for(Contact c : updatedContacts){
			System.assert(c.Email.endsWith('.test'));
			System.assert(c.Secondary_Email__c.endsWith('.test'));
			System.debug('c.IFSA_Butler_NET_Email__c ' + c.Name + ': ' + c.IFSA_Butler_NET_Email__c);
			System.assert(c.IFSA_Butler_NET_Email__c.endsWith('.test'));
		}
	}
	
	
	
}