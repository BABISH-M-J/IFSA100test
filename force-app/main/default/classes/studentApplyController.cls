/**
* @description Controller class used by SP_Apply
* @author Brock Barlow
*/
public without sharing class studentApplyController extends studentBaseController
{
    // public studentApplyViewModel viewModel {get;set;}

    // private User programAdvisor {get;set;}
    // private Program_Term__c programTerm {get;set;}
    // private Program_Term__c parentProgramTerm {get;set;}
    // private List<Application_Item__c> applicationItems {get;set;}

    // //public studentApplyController(advisorStudentsController controller){}
  
    // public studentApplyController()
    // {
    //     super();
    //     if(this.application != null)
    //     {
    //         List<String> phase = new List<String>();
    //         phase.add('Pre-Admit');
    //         phase.add('Optional');
    //         system.debug(this.application.Status__c);
    //         if(this.application.Status__c != 'Rejected')
    //         {
    //     	    this.applicationItems = [SELECT Id, Name, Status__c FROM Application_Item__c WHERE Application__c =: this.application.Id AND Phase__c IN: phase];        
    //         }
    //     	else
    //     	{
    //     		this.applicationItems = [SELECT Id, Name, Status__c FROM Application_Item__c WHERE Application__c =: this.application.Id AND Status__c = 'Complete' AND Phase__c IN: phase];
    //     	}
    //     	if(this.application.Program_Term__c != null)
    //         {
    //             this.programTerm = [SELECT Id, Name, OwnerId, Parent_Program_Term__c, Program__r.Name, Program__r.Webpage_Url__c, Program__r.Host_Institution__r.Country__r.Name, Program__r.Category__c, Term__r.Section__c FROM Program_Term__c WHERE ID =: this.application.Program_Term__c];
    //             this.programAdvisor = [SELECT Id, FirstName, LastName, Email, Phone, FullPhotoUrl, Calendly_Link__c, PA_Intro_Video__c FROM User WHERE Id =: programTerm.OwnerId];
    //             try
    //             {
    //                 this.parentProgramTerm = [SELECT Id, Name, OwnerId, Program__r.Name, Program__r.Webpage_Url__c, Program__r.Host_Institution__r.Country__r.Name FROM Program_Term__c WHERE ID =: this.programTerm.Parent_Program_Term__c];
    //             }
    //             catch (QueryException ex) 
    //             {
    //                 system.debug('Program Term: ' + this.programTerm.Name + ' does not have a program term.');
    //             }

    //           this.viewModel = new studentApplyViewModel();
    //           this.populateViewModel();
    //         }
    //         else
    //         {
    //           this.programAdvisor = new User();
    //           this.viewModel = new studentApplyViewModel();
    //           this.populateViewModel();
    //         }
    //     }
    // }
    // /**
    // * @description Validates access to the page
    // */
    // public override PageReference validateAccess()
    // {
    //     if(this.viewModel.isLockDownActive)
    //     {
    //         return new PageReference('/SP_Home');
    //     }
    //     else if(this.application == null)
    //     {
    //         return new PageReference('/SP_ApplicationSelector');
    //     }
    //     if(this.viewModel.isDropped)
    //     {
    //     	return new PageReference('/SP_Home');
    //     }
    //     else if(!this.viewModel.isProgramSelected)
    //     {
    //       return new PageReference('/SP_Select');
    //     }
    //     return null;
    // }
    // /**
    // * @description Populates the viewmodel
    // */
    // private void populateViewModel()
    // {
    //     this.viewModel = (studentApplyViewModel) super.populateViewModel(this.viewModel);
    //     this.viewModel.advisorEmail = this.programAdvisor.Email;
    //     this.viewModel.advisorFirstName = this.programAdvisor.FirstName;
    //     this.viewModel.advisorLastName = this.programAdvisor.LastName;
    //     this.viewModel.advisorPhone = this.programAdvisor.Phone;
    //     this.viewModel.advisorPhotoUrl = this.programAdvisor.FullPhotoUrl;
    //     this.viewModel.advisorCalendlylink = this.programAdvisor.Calendly_Link__c;
    //     this.viewModel.paIntroVideo = this.programAdvisor.PA_Intro_Video__c;
    //     this.viewModel.applicationName = this.application.Name;
    //     this.viewModel.applicationId = this.application.Id;
    //     this.viewModel.countryName = this.programTerm.Program__r.Host_Institution__r.Country__r.Name;
    //     this.viewModel.appItemsIncomplete = (Integer) this.application.Application_Items_Incomplete_Count__c;
    //     this.viewModel.completionNotificationReceived = this.application.Completion_Notification_Received__c;
    //     this.viewModel.programName = this.programTerm.Program__r.Name;
    //     this.viewModel.programUrl = this.programTerm.Program__r.Webpage_Url__c;
    //     this.viewModel.scholarshipURL = [SELECT URL__c FROM Static_Link_URL__mdt WHERE DeveloperName = 'Scholarship_Link'].get(0).URL__c;
    //     for(Application_Item__c appItem: this.applicationItems)
    //     {
    //         if(appItem.Name == 'Scholarship')
    //         {
    //             this.viewModel.hasScholarship = true;
    //         }
    //     }
    //     this.viewModel.isCatalog = this.programTerm.Program__r.Category__c == 'Catalog' ? true : false;
    //     this.viewModel.appItems = new List<studentApplyItemViewModel>();
    //     for(Application_Item__c applicationItem : this.applicationItems)
    //     {
    //       studentApplyItemViewModel itemViewModel = new studentApplyItemViewModel();
    //       itemViewModel.id = applicationItem.Id;
    //       itemViewModel.name = applicationItem.Name;
    //       itemViewModel.status = applicationItem.Status__c;
    //       this.viewModel.appItems.add(itemViewModel);
    //     }
    //     Schema.DescribeFieldResult financialAidPickList = Financial_Aid_Item__c.Financial_Aid_Types__c.getDescribe();

    //     List<Schema.PicklistEntry> financialAidTypes = financialAidPickList.getPicklistValues();	
    //     this.viewModel.aidTypes = financialAidTypes;
    //     Id homeInstAccountId = [SELECT Home_Institution__r.Account__c FROM Contact WHERE Id =: studentContact.Id].get(0).Home_Institution__r.Account__c;
    //     Boolean programAuthorized = false;
    //     if(homeInstAccountId != null && this.application.program_term__c != null)
    //     {
    //         List<Program_Authorization__c> pAuths = [SELECT Id, Term__c FROM Program_Authorization__c WHERE Account__c =: homeInstAccountId AND Program__c =: programTerm.Program__c AND Is_Active__c = TRUE];
    //         if(pAuths.isEmpty())
    //         {
    //             programAuthorized = true;
    //         }
    //         for(Program_Authorization__c pAuth: pAuths)
    //         {
    //             if(pAuth.Term__c != null && pAuth.Term__c.contains(programTerm.Term__r.Section__c))
    //             {
    //                 programAuthorized = true;
    //             }
    //         }
    //     }
    //     else
    //     {
    //         programAuthorized = true;
    //     }
    //     this.viewModel.isUnauthorizedProgram = !programAuthorized;
    // }
    // /**
    // * @description Remote action that is fired from the last pre-admit item being completed
    // */
    // @RemoteAction
    // public static Boolean closeCompletionNotification(String applicationId)
    // {
    //     Id appId = Id.valueOf(applicationId);
    //     return closeCompletionNotification(appId);
    // }
    // /**
    // * @description Marks an applicaiton as "Ready to Submit"
    // */
    // public static Boolean closeCompletionNotification(Id applicationId)
    // {
    //     try
    //     {
    //         Application__c application = [SELECT Id, Completion_Notification_Received__c, Application_Items_Incomplete_Count__c FROM Application__c WHERE Id =: applicationId];
    //         if(application.Application_Items_Incomplete_Count__c < 1)            
    //         {
    //             application.Status__c = 'Ready To Submit';
    //             application.Completion_Notification_Received__c = true;

    //             Database.update(application);

    //             return true;
    //         }
    //     }
    //     catch(Exception e)
    //     {
    //         System.debug(LoggingLevel.ERROR, e.getMessage());
    //     }
    //     return false;
    // }
}