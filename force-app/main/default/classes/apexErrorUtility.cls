/**
 * Utility class for error and debug handling.
 * @author Cameron Ames
 */
// ApexDoc updated 1/25/2021 Brock Barlow
 public without sharing class apexErrorUtility
{
	/**
	 * Logs and throws the exception.
	 * @param The exception to throw/post to the debug log.
	 */
	public static void throwException(Exception except)
	{
		apexErrorUtility.debug(LoggingLevel.ERROR, except.getMessage());
		throw except;
	}

	/**
	 * If the code is configured to debug, then write to the debug log
	 * @param level The level of logging at which this statement should be posted
	 * @param message The debug message
	 */
	public static void debug(LoggingLevel level, String message)
	{
		//Check the configuration utility to see if debugging is on
		if(apexConfigurationUtility.getInstance().isDebugOn())
		{
			System.debug(level, message);
		}
	}
}