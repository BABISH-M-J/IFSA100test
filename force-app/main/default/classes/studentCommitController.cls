/**
* @description Controller class used by SP_Commit
*/
public without sharing class studentCommitController extends studentBaseController
{
    public studentApplyViewModel viewModel {get;set;}

//     private User programAdvisor {get;set;}
//     private Program_Term__c parentProgramTerm {get;set;}
//     private Program_Term__c programTerm {get;set;}
//     private List<Application_Item__c> applicationItems {get;set;}
//     private string student {get; set;}

//     public studentCommitController()
//     {
//         super();
//         if(this.application != null)
//         {
//             List<String> phase = new List<String>();
//             phase.add('Pre-Acceptance');
//             phase.add('Optional');
//             if(this.application.Status__c != 'Submitted' && this.application.Status__c != 'Ready To Submit' && this.application.Status__c != 'Waitlisted')
//             {
//                 phase.add('Post-Acceptance');
//             }
//             if(this.application.Status_Contract_Signed__c != null)
//             {
//                 phase.add('Post-Contract');
//             }
//             if(this.application.Status__c != 'Rejected')
//             {
//                 this.applicationItems = [SELECT Id, Name, Status__c, Phase__c FROM Application_Item__c WHERE Application__c =: this.application.Id AND Phase__c IN: phase];
//                 system.debug('# of App Items: ' + this.applicationItems.size());
//             }		
//             else
//             {
//                 this.applicationItems = [SELECT Id, Name, Status__c, Phase__c FROM Application_Item__c WHERE Application__c =: this.application.Id AND Status__c = 'Complete' AND Phase__c =: phase];
//             }
//             this.student = [SELECT Id, Applicant__r.FirstName FROM Application__c WHERE Id =: this.application.Id].get(0).Applicant__r.FirstName;
            
//             if(this.application.Program_Term__c != null)
//             {
//                 this.programTerm = [SELECT Id, Name, OwnerId, Parent_Program_Term__c, Program__r.Name, Program__r.Webpage_Url__c, Program__r.Host_Institution__r.Country__r.Name, Program__r.Category__c FROM Program_Term__c WHERE ID =: this.application.Program_Term__c];
//                     this.programAdvisor = [SELECT Id, FirstName, LastName, Email, Phone, FullPhotoUrl, Calendly_Link__c, PA_Intro_Video__c FROM User WHERE Id =: programTerm.OwnerId];
//                     try
//                     {
//                         this.parentProgramTerm = [SELECT Id, Name, OwnerId, Program__r.Name, Program__r.Webpage_Url__c, Program__r.Host_Institution__r.Country__r.Name FROM Program_Term__c WHERE ID =: this.programTerm.Parent_Program_Term__c];
//                     }
//                     catch (QueryException ex) 
//                     {
//                         system.debug('Program Term: ' + this.programTerm.Name + ' does not have a program term.');
//                     }

//                 this.viewModel = new studentApplyViewModel();
//                 this.populateViewModel();
//             }
//             else
//             {
//                 this.programAdvisor = new User();
//                 this.viewModel = new studentApplyViewModel();
//             }
//         }  
//     }
//     /**
//     * @description Validates access to the page
//     */
//     public override PageReference validateAccess()
//     { 
//         if(!this.studentContact.Profile_Completed__c)
//         {
//             return new PageReference('/SP_Register');
//         }
//         if(this.application == null)
//         {
//             return new PageReference('/SP_ApplicationSelector');
//         }
//         if(this.viewModel.isDropped)
//         {
//             return new PageReference('/SP_Home');
//         }
//         else if(!this.viewModel.isApplied)
//         {
//         return new PageReference('/SP_Apply');
//         }
//         return null;
//     }
//   /**
//   * @description Populates the viewmodel
//   */
//     private void populateViewModel()
//     {
//         this.viewModel = (studentApplyViewModel) super.populateViewModel(this.viewModel);
//         this.viewModel.advisorEmail = this.programAdvisor.Email;
//         this.viewModel.advisorFirstName = this.programAdvisor.FirstName;
//         this.viewModel.advisorLastName = this.programAdvisor.LastName;
//         this.viewModel.advisorPhone = this.programAdvisor.Phone;
//         this.viewModel.advisorPhotoUrl = this.programAdvisor.FullPhotoUrl;
//         this.viewModel.advisorCalendlylink = this.programAdvisor.Calendly_Link__c;
//         this.viewModel.paIntroVideo = this.programAdvisor.PA_Intro_Video__c;
//         this.viewModel.applicationName = this.application.Name;
//         this.viewModel.firstName = this.student;
//         this.viewModel.programTermName = this.programTerm.Name;
//         this.viewModel.applicationId = this.application.Id;
//         this.viewModel.appItemsIncomplete = (Integer) this.application.Application_Items_Incomplete_Count__c;
//         this.viewModel.acceptanceConditions = this.application.Acceptance_Conditions__c;
//         this.viewModel.waitlistMessage = this.application.Waitlisted_Message__c;
//         this.viewModel.conditionsMet = this.application.Conditions_Met__c == true ? true : false;
//         this.viewModel.completionNotificationReceived = this.application.Completion_Notification_Received__c;
//         this.viewModel.programName = this.programTerm.Program__r.Name;
//         this.viewModel.programUrl = this.programTerm.Program__r.Webpage_Url__c;
//         this.viewModel.scholarshipURL = [SELECT URL__c FROM Static_Link_URL__mdt WHERE DeveloperName = 'Scholarship_Link'].get(0).URL__c;
//         for(Application_Item__c appItem: this.applicationItems)
//         {
//             if(appItem.Name == 'Scholarship')
//             {
//                 this.viewModel.hasScholarship = true;
//             }
//         }
//         this.viewModel.isCatalog = this.programTerm.Program__r.Category__c == 'Catalog' ? true : false;
//         this.viewModel.appItems = new List<studentApplyItemViewModel>();
//         for(Application_Item__c applicationItem : this.applicationItems)
//         {
//         studentApplyItemViewModel itemViewModel = new studentApplyItemViewModel();
//         itemViewModel.id = applicationItem.Id;
//         itemViewModel.name = applicationItem.Name;
//         itemViewModel.status = applicationItem.Status__c;
//         itemViewModel.phase = applicationItem.Phase__c;
//         this.viewModel.appItems.add(itemViewModel);
//         }
//         system.debug('# of studentApplyItemViewModel :' + this.viewModel.appItems.size());
//         Schema.DescribeFieldResult financialAidPickList = Financial_Aid_Item__c.Financial_Aid_Types__c.getDescribe();

//         List<Schema.PicklistEntry> financialAidTypes = financialAidPickList.getPicklistValues();    
//         this.viewModel.aidTypes = financialAidTypes;    
//     }
//     /**
//     * @description Marks an applicaiton as "Ready to Submit"
//     */
//     @RemoteAction
//     public static void closeCompletionNotification(String applicationId)
//     {
//         try
//         {
//             Id appId = Id.valueOf(applicationId);
//             Application__c application = [SELECT Id, Completion_Notification_Received__c FROM Application__c WHERE Id =: appId];
//             application.Completion_Notification_Received__c = true;
//             Database.update(application);
//         }
//         catch(Exception e)
//         {
//             System.debug(LoggingLevel.ERROR, e.getMessage());
//         }
//     }
}