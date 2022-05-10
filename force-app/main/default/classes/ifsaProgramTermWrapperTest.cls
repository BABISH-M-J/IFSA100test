/**
 * Test class for the program advisor wrapper class
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public with sharing class ifsaProgramTermWrapperTest
{
	/**
	 * Test the instance methods and constructors
	 */
	public static testMethod void testInstance()
	{
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
		test.startTest();
		Program_Term__c programTerm = (Program_Term__c) testInfo.get('programTerm');
		
		//Test instance constructor
		ifsaProgramTermWrapper programTermWrapper = new ifsaProgramTermWrapper(programTerm);
		
		//Test Id constructor
		programTermWrapper = new ifsaProgramTermWrapper(programTerm.Id);
		
		studentApplyViewModel viewModel = programTermWrapper.populateViewModel(new studentApplyViewModel());
		System.assertNotEquals(null, viewModel.programName, 'The view model program name should not be null.');
		
		//Test getters
		Id testId = programTermWrapper.getOwnerId();
		Id countryId = programTermWrapper.getCountryId();
		test.stopTest();
	}

	/**
	 * Test the static method to obtain data on the current program terms.
	 */
	public static testMethod void testGetCurrentProgramTermOptions()
	{
		Term__c term1 = apexMockDataUtility.createTerm();
		Term__c term2 = apexMockDataUtility.createTerm('Fall', 2010);
		Term__c term3 = apexMockDataUtility.createTerm('Summer', Date.today().year() + 1);
		World__c world = new World__c();
		database.insert(world);

		Region__c region = new Region__c();
		region.World__c = world.Id;
		database.insert(region);
		Country__c country = apexMockDataUtility.createCountry(region.Id);
		Host_Institution__c hostInstitution = apexMockDataUtility.createHostInstitution(country.Id);
		Program__c program = apexMockDataUtility.createProgram(hostInstitution);
		Program_Term__c programTerm = apexMockDataUtility.createProgramTerm(program, term1);
		Program_Term__c programTerm2 = apexMockDataUtility.createProgramTerm(program, term2);
		Program_Term__c programTerm3 = apexMockDataUtility.createProgramTerm(program, term3);
		
		Map<String, Set<String>> programTermData = ifsaProgramTermWrapper.getCurrentProgramTermOptions();
		System.assertEquals(2, programTermData.get('Sections').size(), 'The number of sections did not equal 2. There were ' + programTermData.get('Sections').size());
		System.assertEquals(2, programTermData.get('Years').size(), 'The number of years did not equal 2. There were ' + programTermData.get('Years').size());
		System.assertEquals(1, programTermData.get('Countries').size(), 'The number of years did not equal 1. There were ' + programTermData.get('Years').size());
	}
}