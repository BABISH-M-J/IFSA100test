/**
 * Unit Test class for <<apexDmlUtility>>
 */
// ApexDoc updated 1/25/2021 Brock Barlow
@isTest
private class apexDmlUtilityTest {

	/**
	 * Tests <<apexDmlUtility>>.deleteIfCreated
	 */
    static testMethod void testDeleteIfCreated() {
    	List<SObject> testList = new List<SObject>();
    	World__c world = new World__c();
		database.insert(world);

		Region__c region = new Region__c();
		region.World__c = world.Id;
		database.insert(region);
        testList.add(apexMockDataUtility.createTerm());
        testList.add(apexMockDataUtility.createCountry(region.Id));
        
        apexDmlUtility.deleteIfCreated(testList);
        
    }
}