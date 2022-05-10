/**
 * Unit Tests for <<apexInstanceUtility>>
 */
// ApexDoc updated 1/25/2021 Brock Barlow
@isTest
private class apexInstanceUtilityTest 
{	
	/**
	 * Tests an instance of <<apexInstanceUtility>>
	 */
	@isTest
	static void testInstance()
	{
		String test = apexInstanceUtility.instance;
		System.assertEquals(false, test.contains('.'));
		System.debug(test);
		String url = apexInstanceUtility.attachmentUrl;
		System.debug(url);
	}
	
}