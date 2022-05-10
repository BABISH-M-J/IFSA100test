/**
 * Google Analytics Utility, used with community controllers to fetch Google Analytics configuration settings
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class GoogleAnalyticsUtility
{
    private Google_Tracking_Setting__mdt trackerSetting;
    private Boolean hasData;
    public GoogleAnalyticsUtility(String SiteName)
    {
        String settingName;
        String orgType;
        hasData = false;
        if (![SELECT IsSandbox FROM Organization LIMIT 1][0].IsSandbox) 
        {
            orgType = 'Production';
        }
        else 
        {
            orgType = 'Sandbox';
        }
        settingName = String.format('{0}_{1}_Tracker', new List<String>{siteName, orgType});
        try
        {
            trackerSetting = [SELECT Analytics_Id__c, Tag_Manager_Id__c  FROM Google_Tracking_Setting__mdt WHERE DeveloperName =: settingName].get(0);
            hasData = true;
        }
        catch (Exception e)
        {
            trackerSetting = null;
        }
    }

    public String getAnalyticsId()
    {
        if(hasData)
        {
            return trackerSetting.Analytics_Id__c;
        }
        return null;
    }

    public String getTagManagerId()
    {
        if(hasData)
        {
            return trackerSetting.Tag_Manager_Id__c;
        }
        return null;
    }
}