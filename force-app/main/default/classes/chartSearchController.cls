/**
 * Controller for CH_Search Visualforce page. CH_Search and the AngularJS app that it runs is the main interface for CHART.
 * This class is to bootstrap CHART. All other interactions with CHART happen in <<chartRemoteMethods>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public without sharing class chartSearchController extends chartBaseController
 {	
    /**
     * An instance of <<chartSearchViewModel>> that contains the information to start CHART
     */
	public chartSearchViewModel viewModel {get;set;}
    /**
	 * Google Anayltics Id
	 */
    public String gaId {get;set;}
    /**
	 * Google Tag Manager Id
	 */
    public String gtmId {get;set;}

    /**
     * Constructor, collects the data to populate an instance of <<chartSearchViewModel>>
     */
    public chartSearchController() 
	{
		super();
        GoogleAnalyticsUtility util = new GoogleAnalyticsUtility('CHART');
        this.gaId = util.getAnalyticsId();
        this.gtmId = util.getTagManagerId();
        this.viewModel = new chartSearchViewModel();
		this.populateViewModel();
	}

	private void populateViewModel()
    {
        this.viewModel = (chartSearchViewModel) super.populateViewModel(this.viewModel);
        this.viewModel.homeInstitutionAccountId = null;
        Id cmpId = ApexPages.currentPage().getParameters().get('cmpId');
        CMP__c cmp;

        if(cmpId != null)
        {
            cmp = [SELECT Id, Home_Institution_Account__c, Contact__c, Home_Institution_Account__r.Name, Home_Institution_Account__r.Course_Equivalency_Search__c FROM CMP__c WHERE Id =: cmpId];
            this.viewModel.homeInstitutionAccountId = cmp.Home_Institution_Account__c;
            this.viewModel.homeInstitutionName = cmp.Home_Institution_Account__r.Name;
			this.viewModel.ceSearch = cmp.Home_Institution_Account__r.Course_Equivalency_Search__c;
            this.viewModel.cmpId = cmp.Id;
        }

        Map<Id, Course__c> courses = new Map<Id, Course__c>([
            SELECT Id
            FROM Course__c 
            WHERE Approved_for_CHART__c = TRUE AND Id IN (SELECT Course__c FROM Program_Course__c WHERE Program__r.Active__c = TRUE AND Program__c IN: chartRemoteMethods.getApprovedPrograms(this.viewModel.homeInstitutionAccountId, cmpId != null ? cmp : null))
        ]);
        this.viewModel.courseIds = new List<Id>(courses.keySet());
        if(this.viewModel.userProfileName.contains('Student'))
		{
			this.viewModel.applications = [SELECT Id, Program_Term_Program__c, Program_Term_Section__c, Program_Term_Year__c FROM Application__c WHERE Applicant__c =: this.viewModel.contactId];
		}
        Id cifAppItemRT = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Class Interest Form').getRecordTypeId();
		viewModel.cifAppItems = [
            SELECT Id, Name, Application__c, Application__r.Program_Term__r.Name 
            FROM Application_Item__c 
            WHERE Status__c != 'Complete' AND Application__r.Applicant__c =: viewModel.contactId AND RecordTypeId =: cifAppItemRT AND (Phase__c = 'Pre-Admit' 
                OR (Phase__c = 'Pre-Acceptance' AND Application__r.Status__c 
                    IN ('Ready To Submit', 'Submitted', 'Accepted', 'Accepted (with Conditions)')
                )
                OR (Phase__c = 'Post-Acceptance' AND Application__r.Status__c
                    IN ('Accepted', 'Accepted (with Conditions)'))
            )];
    }
}