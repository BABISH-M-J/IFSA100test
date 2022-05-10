/**
* @description Viewmodel for student roster
* @author Brock Barlow
*/
public with sharing class studentRosterViewModel {
	public Program_Term__c programTerm {get;set;}
	public List<studentRosterInformationViewModel> students {get;set;}

	public studentRosterViewModel() {
		this.students = new List<studentRosterInformationViewModel>();
	}
}