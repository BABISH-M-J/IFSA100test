public without sharing class advisorWeeklyStatusUpdateController 
{
    public string accountId {get; set;}
    public string contactId {get; set;}
    public Boolean summerOnly {get; set;}
    private List<Application__c> applications;
    
    
    public advisorWeeklyStatusUpdateController() 
    {
        applications = new List<Application__c>();
    }

    public List<Application__c> getApplications
    {
        get {
            if(!summerOnly)
            {
                applications = [SELECT Id, Student_Last_Name__c, Student_First_Name__c, Applicant__r.Name, Status__c, Previous_Status__c, Program_Approval_Completed_By__c, Program_Approval_Completed_By__r.Name, Home_Institution_Account_ID__c, Program_Term__r.Display_Name__c, Applicant__r.Home_Institution__c, Applicant__r.Email, Program_Term__r.Program__r.Name, Application_Deadline__c, Designation__c FROM Application__c WHERE Home_Institution_Account__c =: accountId AND Program_Term__r.Program__r.Category__c = 'Catalog' AND Program_Term__r.Term__r.Year__c >=: Date.today().year() AND Status__c IN ('Program Selected', 'Ready to Submit', 'Submitted', 'Accepted', 'Accepted (With Conditions)') ORDER BY Application_Deadline__c, Program_Term__r.Program__r.Name, Student_Last_Name__c, Student_First_Name__c NULLS LAST];
            }
            else 
            {
                applications = [SELECT Id, Student_Last_Name__c, Student_First_Name__c, Applicant__r.Name, Status__c, Previous_Status__c, Program_Approval_Completed_By__c, Program_Approval_Completed_By__r.Name, Home_Institution_Account_ID__c, Program_Term__r.Display_Name__c, Applicant__r.Home_Institution__c, Applicant__r.Email, Program_Term__r.Program__r.Name, Application_Deadline__c, Designation__c FROM Application__c WHERE Home_Institution_Account__c =: accountId AND Program_Term__r.Program__r.Category__c = 'Catalog' AND Program_Term__r.Term__r.Year__c >=: Date.today().year() AND Status__c IN ('Program Selected', 'Ready to Submit', 'Submitted', 'Accepted', 'Accepted (With Conditions)') AND Program_Term__r.Display_Name__c LIKE '%Summer%' ORDER BY Application_Deadline__c, Program_Term__r.Program__r.Name, Student_Last_Name__c, Student_First_Name__c NULLS LAST];
            }
            return this.applications;
        }
    }
}