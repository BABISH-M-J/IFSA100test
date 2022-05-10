/**
 * Test class for <<apexErrorUtility>>
 * @author Cameron Ames
 */
// ApexDoc updated 1/25/2021 Brock Barlow
@isTest
public without sharing class apexErrorUtilityTest
{
	/**
	 * Tests <<apexErrorUtility>>.throwException
	 */
	public static testMethod void testThrowException()
	{
		try
		{
			apexErrorUtility.throwException(new ifsaDataException('Test Exception'));
			System.assert(false, 'An Exception should have been thrown by now.');
		}
		catch(Exception e)
		{
			System.assert(true, 'An Exception was thrown.');
		}
	}
}