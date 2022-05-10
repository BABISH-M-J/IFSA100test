/**
* @description Viewmodel for spanish evaluation page
* @author Cameron Ames
*/
public without sharing class studentSpanishEvalViewModel extends portalBaseViewModel
{
	public String appItemEvaluationMethod {get;set;}
	public String appItemNeedsTraining {get;set;}
	public String appItemSpanishAuralComprehension {get;set;}
	public String appItemSpanishWritingAbility {get;set;}
	public String appItemSpanishSpeakingAbility {get;set;}
	public String appItemSpanishReadingAbility {get;set;}
	public String appItemSpanishEvaluationComments {get;set;}
	public String appItemSpanishEvaluationApproval {get;set;}
	public String appItemSpanishEvaluationConditions {get;set;}
	public String appItemEvaluatorName {get;set;}
	public String appItemEvaluatorEmail {get;set;}
	public String applicationName {get;set;}
	public Boolean isEvaluee {get;set;}
	public Boolean isEvalWaived {get;set;}
	public Boolean isComplete {get;set;}

	// System Maintenance Fields
    public String systemMessage {get;set;}
    public Boolean isLockDownActive {get;set;}
}