/**
 * Used to obtain configuration data.
 * @author Cameron Ames
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class configurationManager
{
	/**
	 * Used to determine if apex is executing in test mode.
	 * @return True if running in test mode, otherwise false.
	 */
	public static Boolean isTestMode()
	{
		return Test.isRunningTest() && [SELECT Id, Test_Mode__c FROM IFSA_Global_Setting__mdt WHERE QualifiedApiName =: 'Settings' LIMIT 1].Test_Mode__c;
	}

	/**
	 * Returns the appropriate email setting based on whether or not we are in test mode.
	 * @return the string listed in 'Default Email Settings' or 'Test Email Settings'.
	 */
	public static String getEmailSettingsApiName()
	{
		IFSA_Global_Setting__mdt globalSetting = [SELECT Id, Default_Email_Settings__c, Test_Email_Settings__c FROM IFSA_Global_Setting__mdt WHERE QualifiedApiName =: 'Settings' LIMIT 1];
		return configurationManager.isTestMode() ? globalSetting.Test_Email_Settings__c : globalSetting.Default_Email_Settings__c;
	}

	/**
	 * Returns the appropriate trigger setting based on whether or not we are in test mode.
	 * @return the string listed in 'Default Trigger Execution Settings' or 'Test Trigger Execution Settings'.
	 */
	public static String getTriggerSettingsApiName()
	{
		IFSA_Global_Setting__mdt globalSetting = [SELECT Id, Default_Trigger_Execution_Settings__c, Test_Trigger_Execution_Settings__c FROM IFSA_Global_Setting__mdt WHERE QualifiedApiName =: 'Settings' LIMIT 1];
		return configurationManager.isTestMode() ? globalSetting.Test_Trigger_Execution_Settings__c : globalSetting.Default_Trigger_Execution_Settings__c;
	}

	/**
	 * Used to determine if the after insert contact trigger should fire based on settings.
	 * @return True if the trigger should fire, otherwise false.
	 */
	public static Boolean shouldExecuteAfterInsertContact()
	{
		return [SELECT Id, QualifiedApiName, Execu_After_Insert_Contact__c FROM IFSA_Trigger_Execution_Setting__mdt WHERE QualifiedApiName =: configurationManager.getTriggerSettingsApiName() LIMIT 1].Execu_After_Insert_Contact__c;
	}

	/**
	 * Used to determine if the custom portal welcome email should be sent out based on settings.
	 * @return True if the email should be sent, otherwise false.
	 */
	public static Boolean shouldSendCustomPortalWelcomeEmail()
	{
		return [SELECT Id, Send_Custom_Welcome_Email__c FROM IFSA_Email_Setting__mdt WHERE QualifiedApiName =: configurationManager.getEmailSettingsApiName() LIMIT 1].Send_Custom_Welcome_Email__c;
	}
}