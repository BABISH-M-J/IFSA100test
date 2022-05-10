/**
 * Tests some of the functionality of <<apexMockDataUtility>>
 * @author Cameron Ames
 */
// ApexDoc updated 1/25/2021 Brock Barlow
@isTest
public without sharing class apexMockDataUtilityTest
{
	/**
	 * Tests creating a Program Advisor User for unit testing
	 */
	static testMethod void testCreateProgramAdvisor() 
	{
		 User u= apexMockDataUtility.createProgramAdvisor();   
		 apexMockDataUtility.createHomeCourse();
    }
}