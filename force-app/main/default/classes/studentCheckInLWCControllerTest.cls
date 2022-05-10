@isTest
public with sharing class studentCheckInLWCControllerTest
{
    static testMethod void testGetAppList()
    {
        List<Application__c> result;
        User admin = [SELECT Id FROM User WHERE IsActive = TRUE AND Profile.Name = 'System Administrator' LIMIT 1].get(0);
        system.runAs(admin){
             result = studentCheckInLWCController.getAppList();
        }        

        User resStaff = [SELECT Id FROM User WHERE IsActive = TRUE AND Profile.Name = 'IFSA Resident Staff' LIMIT 1].get(0);
        system.runAs(resStaff){
            result = studentCheckInLWCController.getAppList();
        }

    }
}