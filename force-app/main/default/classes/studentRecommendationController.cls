/**
* @description Controller for SP_Recommendation page
* @author Cameron Ames
*/
public without sharing class studentRecommendationController
{
    public Boolean isLoaded {get;set;}
    public studentRecommendationViewModel viewModel {get;set;}

    private Recommendation__c recommendation {get;set;}
    private Application_Item__c applicationItem {get;set;}
    private Application__c application {get;set;}
	private User studentUser {get;set;}
    private Portal_System_Message__mdt message {get;set;}

    public studentRecommendationController()
    {
        this.isLoaded = true;

        try
        {
            Id recommendationId = Id.valueOf(ApexPages.currentPage().getParameters().get('recommender'));
            Id appItemId = Id.valueOf(ApexPages.currentPage().getParameters().get('app'));

            this.recommendation = (Recommendation__c) apexQueryUtility.selectAllFrom('Recommendation__c', 'Id = \'' + recommendationId + '\'').get(0);
            this.applicationItem = (Application_Item__c) apexQueryUtility.selectAllFrom('Application_Item__c', 'Id = \'' + appItemId + '\'').get(0);
            this.application = [SELECT Id, Name, Preferred_Name__c, Applicant__r.FirstName, Applicant__r.LastName, Applicant__c, Program_Term__r.Display_Name__c FROM Application__c WHERE Id =: this.applicationItem.Application__c];
			this.studentUser = [SELECT Id FROM User WHERE ContactId =: this.application.Applicant__c];
            try
            {
                this.message = [SELECT MasterLabel, Affected_Portal__c, Is_Lockdown_Active__c, Message__c, Message_End_Date__c, Message_Start_Date__c FROM Portal_System_Message__mdt WHERE Affected_Portal__c = 'Student' AND Message_Start_Date__c <=: Date.today() AND Message_End_Date__c >=: Date.today()].get(0);
            }
            catch (ListException ex)
            {
                system.debug('No System Messages at this time');
            }

            if(this.recommendation.Application_Item__c != appItemId)
            {
                isLoaded = false;
            }

            this.viewModel = new studentRecommendationViewModel();
            this.populateViewModel();
        }
        catch (Exception e)
        {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            isLoaded = false;
        }
    }

    private void populateViewModel()
    {
		this.viewModel.studentFirstName = this.application.Applicant__r.FirstName;
		this.viewModel.studentLastName = this.application.Applicant__r.LastName;
        this.viewModel.studentPreferredName = this.application.Preferred_Name__c;
		this.viewModel.programTerm = this.application.Program_Term__r.Display_Name__c;
		this.viewModel.content = this.recommendation.Recommendation__c;
        this.viewModel.applicationName = this.application.Name;
        this.viewModel.recommendationEmail = this.recommendation.Email_Address__c;
        this.viewModel.recommendationId = this.recommendation.Id;
        this.viewModel.recommendationName = this.recommendation.Name;
        this.viewModel.recommendationRecommenderName = this.recommendation.Recommender_Name__c;
		this.viewModel.recommendationTitle = this.recommendation.Title__c;
		this.viewModel.university = this.recommendation.University__c;
		this.viewModel.phone = this.recommendation.Phone_Number__c;
		this.viewModel.recommendationStatus = this.recommendation.Status__c;
		this.viewModel.isRecommendee = this.studentUser.Id == UserInfo.getUserId();
		this.viewModel.recommendeeWaived = this.applicationItem.Recommendation_Wavied__c == 'Yes';
        this.viewModel.systemMessage = this.message.Message__c;
		this.viewModel.isLockDownActive = this.message.Is_Lockdown_Active__c == true ? true : false;
    }

    public PageReference validateAccess()
    {
		if(this.viewModel.isLockDownActive)
        {
            return new PageReference('/SP_Home');
        }
        else if(!this.isLoaded)
		{
			return new PageReference('/SP_Apply');
		}
		else if(this.viewModel.recommendationStatus == 'Complete' && !this.viewModel.isRecommendee)
		{
			return new PageReference('/SP_RecommendationSuccess');
		}

        return null;
    }

    public PageReference submitRecommendation()
    {
        return null;
    }
    @RemoteAction
    public static string submitRecommendation(string jsonData)
    {
        try
        {
            studentRecommendationViewModel viewModel = new studentRecommendationViewModel();

            if(jsonData == null)
            {
                return 'Something went wrong while submitting your data. Please try again. If the probelem persists, please Contact IFSA. ERROR: Rec0001';
            }
            
            try
            {
                viewModel = (studentRecommendationViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('studentRecommendationViewModel'));
            }
                catch(Exception e)
            {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                return 'Something went wrong while submitting your data. Please try again. If the probelem persists, please Contact IFSA. ERROR: Rec0002';
            }
            
            Recommendation__c recommendation = new Recommendation__c(Id = viewModel.recommendationId);
            recommendation.Recommendation__c = viewModel.content;
            recommendation.Email_Address__c = viewModel.recommendationEmail;
            recommendation.Recommender_Name__c = viewModel.recommendationRecommenderName;
            recommendation.University__c = viewModel.university;
            recommendation.Title__c = viewModel.recommendationTitle;
            recommendation.Phone_Number__c = viewModel.phone;
            recommendation.Status__c = 'Complete';

            Boolean successfulSubmission = Database.update(recommendation).isSuccess();
            system.debug(viewModel);
            if(successfulSubmission && portalRemotingMethods.submitPDF(recommendation.Id, viewModel.fileData, viewModel.fileType, viewModel.fileName))
            {
                return '/studentportal/SP_RecommendationSuccess';
            }
            else
            {
                return 'Something went wrong while submitting your data. Please try again. If the probelem persists, please Contact IFSA. ERROR: Rec0003';
            }
        }
        catch (Exception e)
        {
            return 'Something went wrong while submitting your data. Please try again. If the probelem persists, please Contact IFSA. ERROR: Rec0004';
        }
    }
}