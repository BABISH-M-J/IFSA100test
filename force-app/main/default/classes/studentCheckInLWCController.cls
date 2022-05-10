public with sharing class studentCheckInLWCController {
    @AuraEnabled(cacheable=true)
    public static List<Application__c> getAppList(){
        List<String> countries = new List<String>();
        User u = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        // System Admins, Academic Programs Staff - Add all countries
        if(u.Profile.Name == 'System Administrator' || u.Profile.Name == 'Program Management and Development')
        {
            for(Group g: [SELECT Id, Name, DeveloperName, Type FROM Group WHERE Name LIKE '% Office'])
            {
                countries.add(g.Name.replace(' Office', ''));
            }
        }
        else
        {
            String officeName;
            for(GroupMember gm: [SELECT Id, Group.id, Group.name, Group.type FROM GroupMember WHERE Group.Name LIKE '% Office' AND UserOrGroupId =: u.Id])
            {
                countries.add(gm.Group.Name.replace(' Office', ''));
            }
        }
        system.debug(countries);
        return [
            SELECT Id, Name, Student_First_Name__c, Student_Last_Name__c, Program_Term_Program__c, Program_Term_Section__c, Program_Term_Year__c, Home_Institution__c, Status__c, Resident_Staff_Checked_In__c 
                FROM Application__c 
                WHERE Resident_Staff_Checked_In__c = FALSE AND Program_Country__c IN: countries 
                AND (
                    (
                        Program_Term_Start_Date__c <= THIS_WEEK AND Status__c IN ('Accepted', 'Accepted (with Conditions)', 'On Site')
                    )
                    OR
                    (
                        Program_Term_Start_Date__c >= TODAY AND Status__c = 'On Site'
                    )
                )
                ORDER BY Program_Term_Program__c, Program_Term_Section__c, Student_Last_Name__c, Student_First_Name__c
        ];
    }
}