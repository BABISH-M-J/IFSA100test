/**
 * Utility class for detecting what instance the code is running on
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public without sharing class apexInstanceUtility 
{
	/**
	 * Returns true the instance is a sanbobx, false if production
	 */
	public static Boolean isSandBox 
	{
		get 
		{
			return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
		}
	}
	/**
	 * Gets the current server instance. I.E. 'na34', 'cs90'
	 */
	public static String instance 
	{
		get 
		{
			return getInstanceName();
		}
	}
	/**
	 * Gets the url for attachment to be used with communities;
	 */
	public static String attachmentUrl 
	{
		get 
		{
			//return 'https://c.' + apexInstanceUtility.instance + '.content.force.com/servlet/servlet.FileDownload?file=';
			return String.format('https://{0}.content.force.com/servlet/servlet.FileDownload?file=', new List<Object>{apexInstanceUtility.instance});
		}
	}
	/**
	 * Logic to get server instance
	 * @return String
	 */
	private static String getInstanceName() 
	{
		String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
		system.debug(baseURL);
		String i = baseURL.substringBetween('//', '.');
		i = i.substringBefore('.');
		return i;
		/*
		if(isSandBox) 
		{
			String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
			system.debug(baseURL);
			Integer index = baseURL.lastIndexOf('cs');
			String i = baseURL.substring(index);
			i = i.substringBefore('.');
			return i;
		}
		else 
		{
			return 'na130';
		}*/
	}
}