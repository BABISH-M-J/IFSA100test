/**
 * Viewmodel class for <<advisorPortalController>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/22/2021 Brock Barlow
public without sharing class advisorPortalViewModel extends advisorBaseViewModel 
{
    /**
     * Holds introduction text stored in Custom_Community_Setting__mdt custom metadata
     */
    public String introText { get;set; }
    /**
     * Holds the value used on the instituion tile stored in Custom_Community_Setting__mdt custom metadata
     */
    public String institutionTileText {get;set;}
    /**
     * Holds the value used on the students tile stored in Custom_Community_Setting__mdt custom metadata
     */
    public String studentsTileText {get;set;}
    /**
     * Holds the value used on the prospective students tile stored in Custom_Community_Setting__mdt custom metadata
     */
    public String propectiveStudentsTileText {get;set;}
    /**
     * Holds the value used on the profile tile stored in Custom_Community_Setting__mdt custom metadata
     */
    public String profileTileText {get;set;}
    /**
     * Holds the value used on the CHART tile stored in Custom_Community_Setting__mdt custom metadata
     */
    public String chartTileText {get;set;}
    /**
     * Holds the field director's first name
     */
    public String fieldDirectorFirstName {get;set;}
    /**
     * Holds the field director's last name
     */
    public String fieldDirectorLastName {get;set;}
    /**
     * Holds the field director's profile image url
     */
    public String fieldDirectorProfileImageURL {get;set;}
    /**
     * Holds the field director's phone number
     */
    public String fieldDirectorPhone {get;set;}
    /**
     * Holds the field director's email address
     */
    public String fieldDirectorEmail {get;set;}
    /**
     * Holds the field director's introduction
     */
    public String fieldDirectorIntro {get;set;}
    /**
     * Holds the field director's title
     */
    public String fieldDirectorTitle {get;set;}
    /**
     * Determines if prospective students is shown. This is determined by Custom_Community_Setting__mdt custom metadata
     */
    public Boolean showToolbox {get;set;}
    /**
     * Application Status Definitions
     */
    public Map<String, String> statusDefinitions {get;set;}
    /**
     * Students page instructions
     */
    public String studentsGettingStarted {get;set;}
    /**
     * Object prefix map
     */
    public Map<String,String> objectPrefixes {get;set;}

    /**
     * Constructor function. Retrieves Custom_Community_Setting__mdt records 
     */
    public advisorPortalViewModel() 
    {
        statusDefinitions = new Map<String, String>();
        for (Custom_Community_Setting__mdt setting : [SELECT Label, DeveloperName, Content__c FROM Custom_Community_Setting__mdt WHERE DeveloperName LIKE '%AP_%']) 
        {
            switch on setting.DeveloperName {
                when 'AP_CHART'{
                    chartTileText = setting.Content__c;
                }
                when 'AP_Institution'{
                    institutionTileText = setting.Content__c;
                }
                when 'AP_Introduction'{
                    introText = setting.Content__c;
                }
                when 'AP_Profile'{
                    profileTileText = setting.Content__c;
                }
                when 'AP_Students'{
                    studentsTileText = setting.Content__c;
                }
                when 'AP_FD_Intro'{
                    fieldDirectorIntro = setting.Content__c;
                }
                when 'AP_Prospective_Students'{
                    propectiveStudentsTileText = setting.Content__c;
                }
                when 'AP_Display_Toolbox'{
                    showToolbox = setting.Content__c.toLowerCase() == 'true';
                }
                when 'AP_Students_Getting_Started'{
                    studentsGettingStarted = setting.Content__c;
                }
                when else {
                    if(setting.DeveloperName.contains('AP_Status_'))
                    {
                        statusDefinitions.put(setting.Label.replace('Status ', ''), setting.Content__c);
                    }
                }
                
            }
            objectPrefixes = new Map<String, String>{
                'Contact' => Schema.getGlobalDescribe().get('Contact').getDescribe().getKeyPrefix(),
                'Application__c' => Schema.getGlobalDescribe().get('Application__c').getDescribe().getKeyPrefix(),
                'Application_Item__c' => Schema.getGlobalDescribe().get('Application_Item__c').getDescribe().getKeyPrefix()
            };
        }
    }
}