/**
* @description Controller for spanish evaluation page
* @author Cameron Ames
*/
public without sharing class studentSpanishEvalController
{
    public Boolean isLoaded {get;set;}
    public studentSpanishEvalViewModel viewModel {get;set;}

    public List<SelectOption> EvaluationMethodOptions {get;set;}
    public List<SelectOption> NeedsTrainingOptions {get;set;}
    public List<SelectOption> SpanishAuralComprehensionOptions {get;set;}
    public List<SelectOption> SpanishWritingAbilityOptions {get;set;}
    public List<SelectOption> SpanishSpeakingAbilityOptions {get;set;}
    public List<SelectOption> SpanishReadingAbilityOptions {get;set;}
    public List<SelectOption> SpanishEvaluationApprovalOptions {get;set;}
	public Boolean isErrorEvalMethod {get;set;}
	public Boolean isErrorTraining {get;set;}
	public Boolean isErrorAural {get;set;}
	public Boolean isErrorWriting {get;set;}
	public Boolean isErrorSpeaking {get;set;}
	public Boolean isErrorReading {get;set;}
	public Boolean isErrorApproval {get;set;}
	public Boolean isErrorConditionalComments {get;set;}

    private Application__c application {get;set;}
    private Application_Item__c applicationItem {get;set;}
    private User studentUser {get;set;}
    private Portal_System_Message__mdt message {get;set;}

    public studentSpanishEvalController()
    {
        this.isLoaded = true;

        try
        {
            Id applicationId = Id.valueOf(ApexPages.currentPage().getParameters().get('app'));
            Id appItemId = Id.valueOf(ApexPages.currentPage().getParameters().get('appItem'));

            this.applicationItem = (Application_Item__c) apexQueryUtility.selectAllFrom('Application_Item__c', 'Id = \'' + appItemId + '\'').get(0);
            this.application = [SELECT Id, Name, Applicant__c, Student_First_Name__c, Student_Last_Name__c, Preferred_Name__c, Program_Term__r.Name FROM Application__c WHERE Id =: applicationId];
            this.studentUser = [SELECT Id FROM User WHERE ContactId =: this.application.Applicant__c];
            try
            {
                this.message = [SELECT MasterLabel, Affected_Portal__c, Is_Lockdown_Active__c, Message__c, Message_End_Date__c, Message_Start_Date__c FROM Portal_System_Message__mdt WHERE Affected_Portal__c = 'Student' AND Message_Start_Date__c <=: Date.today() AND Message_End_Date__c >=: Date.today()].get(0);
            }
            catch (ListException e)
            {
                System.debug('There are not any messages at this time, Continue to load page');
            }
            

            if(this.applicationItem.Application__c != this.application.Id)
            {
                throw new ifsaDataException('The application Id did not match the Url parameter.');
            }

            this.viewModel = new studentSpanishEvalViewModel();
            this.populateViewModel();

            this.EvaluationMethodOptions = apexConversionUtility.getPicklistSelectValues(Application_Item__c.Evaluation_Method__c);
            this.NeedsTrainingOptions = apexConversionUtility.getPicklistSelectValues(Application_Item__c.Needs_Training__c);
            this.SpanishAuralComprehensionOptions = apexConversionUtility.getPicklistSelectValues(Application_Item__c.Spanish_Aural_Comprehension__c);
            this.SpanishWritingAbilityOptions = apexConversionUtility.getPicklistSelectValues(Application_Item__c.Spanish_Writing_Ability__c);
            this.SpanishSpeakingAbilityOptions = apexConversionUtility.getPicklistSelectValues(Application_Item__c.Spanish_Speaking_Ability__c);
            this.SpanishReadingAbilityOptions = apexConversionUtility.getPicklistSelectValues(Application_Item__c.Spanish_Reading_Ability__c);
            this.SpanishEvaluationApprovalOptions = apexConversionUtility.getPicklistSelectValues(Application_Item__c.Spanish_Evaluation_Approval__c);
        }
        catch (Exception e)
        {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            isLoaded = false;
        }
    }

    public void populateViewModel()
    {
        this.viewModel.appItemEvaluationMethod = this.applicationItem.Evaluation_Method__c;
        this.viewModel.appItemEvaluatorEmail = this.applicationItem.Evaluator_Email__c;
        this.viewModel.appItemEvaluatorName = this.applicationItem.Evaluator_Name__c;
        this.viewModel.appItemNeedsTraining = this.applicationItem.Needs_Training__c;
        this.viewModel.appItemSpanishAuralComprehension = this.applicationItem.Spanish_Aural_Comprehension__c;
        this.viewModel.appItemSpanishEvaluationApproval = this.applicationItem.Spanish_Evaluation_Approval__c;
        this.viewModel.appItemSpanishEvaluationComments = this.applicationItem.Spanish_Evaluation_Comments__c;
        this.viewModel.appItemSpanishEvaluationConditions = this.applicationItem.Spanish_Evaluation_Conditions__c;
        this.viewModel.appItemSpanishReadingAbility = this.applicationItem.Spanish_Reading_Ability__c;
        this.viewModel.appItemSpanishSpeakingAbility = this.applicationItem.Spanish_Speaking_Ability__c;
        this.viewModel.appItemSpanishWritingAbility = this.applicationItem.Spanish_Writing_Ability__c;
        this.viewModel.isEvaluee = this.studentUser.Id == UserInfo.getUserId();
        this.viewModel.isEvalWaived = this.applicationItem.Evaluation_Waived__c == 'Yes';
        this.viewModel.isComplete = this.applicationItem.Status__c == 'Complete';
        this.viewModel.systemMessage = this.message.Message__c;
		this.viewModel.isLockDownActive = this.message.Is_Lockdown_Active__c == true ? true : false;
        String[] strings = new String[3];
        if(this.application.Preferred_Name__c != null)
        {
            strings[0] = this.application.Preferred_Name__c;
        }
        else {
            strings[0] = this.application.Student_First_Name__c;
        }
        strings[1] = this.application.Student_Last_Name__c;
        strings[2] = this.application.Program_Term__r.Name;
        this.viewModel.applicationName = String.format('{0} {1} {2}', strings);
    }

    public void populateSObjects()
    {
        this.applicationItem.Evaluation_Method__c = this.viewModel.appItemEvaluationMethod;
        this.applicationItem.Evaluator_Email__c = this.viewModel.appItemEvaluatorEmail;
        this.applicationItem.Evaluator_Name__c = this.viewModel.appItemEvaluatorName;
        this.applicationItem.Needs_Training__c = this.viewModel.appItemNeedsTraining;
        this.applicationItem.Spanish_Aural_Comprehension__c = this.viewModel.appItemSpanishAuralComprehension;
        this.applicationItem.Spanish_Evaluation_Approval__c = this.viewModel.appItemSpanishEvaluationApproval;
        this.applicationItem.Spanish_Evaluation_Comments__c = this.viewModel.appItemSpanishEvaluationComments;
        this.applicationItem.Spanish_Evaluation_Conditions__c = this.viewModel.appItemSpanishEvaluationConditions;
        this.applicationItem.Spanish_Reading_Ability__c = this.viewModel.appItemSpanishReadingAbility;
        this.applicationItem.Spanish_Speaking_Ability__c = this.viewModel.appItemSpanishSpeakingAbility;
        this.applicationItem.Spanish_Writing_Ability__c = this.viewModel.appItemSpanishWritingAbility;
    }

    public PageReference authorize()
    {
		if(this.viewModel.isLockDownActive)
        {
            return new PageReference('/SP_Home');
        }
        if(!this.isLoaded)
		{
			//return new PageReference('/SP_Apply');
		}
		else if(this.viewModel.isComplete && !this.viewModel.isEvaluee)
		{
			return new PageReference('/SP_RecommendationSuccess');
		}

		return null;
    }

    public PageReference submitEvaluation()
    {
        try
        {            
            this.populateSObjects();
            List<String> errors = CheckAnswers();
            if(errors.Size() > 0)
            {
            	for(String error : errors)
            	{
            		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, error));
            	}
            	return null;
            }
            this.applicationItem.Status__c = 'Complete';
            if(Database.update(this.applicationItem).isSuccess())
            {
                return new PageReference('/SP_RecommendationSuccess');
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Something went wrong while submitting your data. Please try again. If the probelem persists, please Contact IFSA-Butler.'));
                return null;
            }
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Something went wrong while submitting your data. Please try again. If the probelem persists, please Contact IFSA-Butler.'));
            return null;
        }
    }
    private List<String> CheckAnswers()
    {
    	List<String> errors = new List<String>();
    	if(this.applicationItem.Evaluation_Method__c == 'Select One')
		{
			errors.add('Please select a value for "How is this evaluation determined"');
			this.isErrorEvalMethod = true;
		}
		else
		{
			this.isErrorEvalMethod = false;
		}
        if(this.applicationItem.Needs_Training__c == 'Select One')
		{
			errors.add('Please select a value for "What is your opinion of the applicant’s ability to pursue university-level course work in this language?"');
			this.isErrorTraining = true;
		}
		else
		{
			this.isErrorTraining = false;
		}
        if(this.applicationItem.Spanish_Aural_Comprehension__c == 'Select One')
		{
			errors.add('Please select a value for "Aural Comprehension"');
			this.isErrorAural = true;
		}
		else
		{
			this.isErrorAural = false;
		}
		if(this.applicationItem.Spanish_Writing_Ability__c == 'Select One')
		{
			errors.add('Please select a value for "Writing Ability"');
			this.isErrorWriting = true;
		}
		else
		{
			this.isErrorWriting = false;
		}
		if(this.applicationItem.Spanish_Speaking_Ability__c == 'Select One')
		{
			errors.add('Please select a value for "Speaking Ability"');
			this.isErrorSpeaking = true;
		}
		else
		{
			this.isErrorSpeaking = false;
		}
        if(this.applicationItem.Spanish_Reading_Ability__c == 'Select One')
		{
			errors.add('Please select a value for "Reading Ability"');
			this.isErrorReading = true;
		}
		else
		{
			this.isErrorReading = false;
		}
        if(this.applicationItem.Spanish_Evaluation_Approval__c == 'Select One')
		{
			errors.add('Please indicate your approval');
			this.isErrorApproval = true;
		}
		else
		{
			this.isErrorApproval = false;
		}
		if(this.applicationItem.Spanish_Evaluation_Approval__c == 'I conditionally approve the applicant for intermediate/advanced study abroad in Spanish.' && this.applicationItem.Spanish_Evaluation_Conditions__c == '')
		{
			errors.add('Please explain the conditions of your conditional approval');
			this.isErrorConditionalComments = true;
		}
		else
		{
			this.isErrorConditionalComments = false;
		}
		return errors;
    }
}