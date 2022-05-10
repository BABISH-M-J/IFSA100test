/**
 * Utility class for configuring custom settings. Since this class is used in debugging, all exceptions should be handled locally.
 * @author Cameron Ames
 */
// ApexDoc updated 1/25/2021 Brock Barlow
global without sharing class apexConfigurationUtility
{
	/**
	 * Since this is a singleton class, this is the instance.
	 */
	private static apexConfigurationUtility instance {get;set;}

	/**
	 * The general configuration settings.
	 */
	private IFSA_Configuration_Settings__c configurationSettings {get;set;}

	/**
	 * The code configuration settings.
	 */
	private IFSA_Code_Execution_Settings__c codeExecutionSettings {get;set;}

	/**
	 * The email configuration settings.
	 */
	private IFSA_Email_Settings__c emailSettings {get;set;}

	/**
	 * Singleton accessor method.
	 * @return Singleton of the class.
	 */
	public static apexConfigurationUtility getInstance()
	{
		if(instance == null)
		{
			instance = new apexConfigurationUtility();
		}
		
		return instance;
	}

	/**
	 * Used to reset the singleton.
	 */
	public static void reset()
	{
		instance = null;
	}

	/**
	 * Constructor for the class. Can only be accessed by singleton accessors.
	 */
	private apexConfigurationUtility()
	{
		this.setConfigurationSettings('Settings');
		this.setCodeSettings(this.getCodeSettingsName());
		this.setEmailSettings(this.getEmailSettingsName());
	}

	/**
	 * If the user wants to use something besides the default settings, this method points the configuration object to a new configuration instance.
	 * @param configurationInstance Which custom setting record should be used?
	 */
	public void setConfigurationSettings(String configurationInstance)
	{
		//Attempt to set the instance.
		this.configurationSettings = IFSA_Configuration_Settings__c.getInstance(configurationInstance);
		
		if(this.configurationSettings == null)
		{
			System.debug(LoggingLevel.ERROR, 'There was no ' + configurationInstance + ' Set for IFSA_Configuration_Settings__c.');
		}
	}

	/**
	 * Examines the configuration settings to determine the appropriate code settings to use.
	 * @return A string of the code settings name.
	 */
	public String getCodeSettingsName()
	{
		//We don't have an instance of our settings if this is true
		if(this.configurationSettings == null)
		{
			System.debug(LoggingLevel.ERROR, 'The configuration settings were not properly initialized. Returning default value of default.');
			return 'Default';
		}
		
		return this.configurationSettings.IFSA_Code_Execution_Settings__c;
	}

	/**
	 * If the user wants to use something besides the default settings, this method points the configuration object to a new settings instance.
	 * @param codeInstance Which custom setting record should be used?
	 */
	public void setCodeSettings(String codeInstance)
	{
		//Attempt to set the instance.
		this.codeExecutionSettings = IFSA_Code_Execution_Settings__c.getInstance(codeInstance);
		
		if(this.codeExecutionSettings == null)
		{
			System.debug(LoggingLevel.ERROR, 'There was no ' + codeInstance + ' Set for IFSA_Code_Execution_Settings__c.');
		}
	}

	/**
	 * Examines the configuration settings to determine the appropriate email settings to use.
	 * @return A string of the email settings name.
	 */
	public String getEmailSettingsName()
	{
		//We don't have an instance of our settings if this is true
		if(this.configurationSettings == null)
		{
			System.debug(LoggingLevel.ERROR, 'The configuration settings were not properly initialized. Returning default value of default.');
			return 'Default';
		}
		
		return this.configurationSettings.IFSA_Email_Settings__c;
	}

	/**
	 * If the user wants to use something besides the default settings, this method points the configuration object to a new email instance.
	 * @param emailInstance Which custom setting record should be used?
	 */
	public void setEmailSettings(String emailInstance)
	{
		//Attempt to set the instance.
		this.emailSettings = IFSA_Email_Settings__c.getInstance(emailInstance);
		
		if(this.emailSettings == null)
		{
			System.debug(LoggingLevel.ERROR, 'There was no ' + emailInstance + ' Set for IFSA_Email_Settings__c.');
		}
	}

	/**
	 * 'Getter' for the Debug_Enabled__c property.
	 * @return The boolean value for Debug_Enabled__c.
	 */
	public Boolean isDebugOn()
	{
		//We don't have an instance of our settings if this is true
		if(this.codeExecutionSettings == null)
		{
			System.debug(LoggingLevel.ERROR, 'The code execution settings were not properly initialized. Returning default value of false for debug enabled.');
			return false;
		}

		return this.codeExecutionSettings.Debug_Enabled__c;
	}

	/**
	 * 'Getter' for the New_Advisor_Alert_Enabled__c property.
	 * @return The boolean value for New_Advisor_Alert_Enabled__c.
	 */
	public Boolean isNewAdvisorEnabled()
	{
		//We don't have an instance of our settings if this is true
		if(this.emailSettings == null)
		{
			System.debug(LoggingLevel.ERROR, 'The email execution settings were not properly initialized. Returning default value of true for new advisor enabled.');
			return false;
		}

		return this.emailSettings.New_Advisor_Alert_Enabled__c;
	}

	/**
	 * 'Getter' for the New_Advisor_Alert_Recipients__c property.
	 * @return The list of string values for the new advisor alert recipients.
	 */
	public List<String> getNewAdvisorRecipients()
	{
		//We don't have an instance of our settings if this is true
		if(this.emailSettings == null)
		{
			System.debug(LoggingLevel.ERROR, 'The email settings were not properly initialized. Returning default value of an empty list.');
			return new List<String>();
		}

		return this.emailSettings.New_Advisor_Alert_Recipients__c.replace(' ', '').split(';');
	}
}