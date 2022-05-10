/**
 * Google Analytics For Chart Controller, used with GAforCHART VF component
 * @author Tim Osborn
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public class GAforChartController {
    public String GATId;
    public void setGATId() {
        if (![SELECT IsSandbox FROM Organization LIMIT 1][0].IsSandbox) {
            GATId = [SELECT Content__c FROM Custom_Community_Setting__mdt WHERE DeveloperName = 'CHART_Production_GA_Tracker_Id'].get(0).Content__c;
        } else {
            GATId = [SELECT Content__c FROM Custom_Community_Setting__mdt WHERE DeveloperName = 'CHART_Sandbox_GA_Tracker_Id'].get(0).Content__c;
        }
    }
    public String getGATId() {
        if (![SELECT IsSandbox FROM Organization LIMIT 1][0].IsSandbox) {
            GATId = [SELECT Content__c FROM Custom_Community_Setting__mdt WHERE DeveloperName = 'CHART_Production_GA_Tracker_Id'].get(0).Content__c;
        } else {
            GATId = [SELECT Content__c FROM Custom_Community_Setting__mdt WHERE DeveloperName = 'CHART_Sandbox_GA_Tracker_Id'].get(0).Content__c;
        }
        return GATId;
    }
}