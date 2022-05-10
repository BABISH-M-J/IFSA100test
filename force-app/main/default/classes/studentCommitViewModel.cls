/**
* @description Viewmodel for SP_Commit page
* @author Cameron Ames
*/
public without sharing class studentCommitViewModel extends studentBaseViewModel
{
    // public String advisorFirstName {get;set;}
    // public String advisorLastName {get;set;}
    // public String advisorEmail {get;set;}
    // public String advisorPhone {get;set;}
    // public String advisorPhotoUrl {get;set;}

	public String applicationName {get;set;}
	public String acceptanceConditions {get;set;}

	public List<studentApplyItemViewModel> appItems {get;set;}
}