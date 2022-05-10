public with sharing class model_Essay_Question {
	public String label {get;set;}
	public String name {get;set;}
	public String question {get;set;}
	public String language {get;set;}
	public String response {get;set;}
	
	public model_Essay_Question(Personal_Essay_Question__mdt essayQuestion) 
	{
		this.label = essayQuestion.MasterLabel;
		this.name = essayQuestion.DeveloperName;
		this.question = essayQuestion.Question_Text__c;
		this.language = essayQuestion.Language__c;
	}
}