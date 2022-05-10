/**
* @description Viewmodel for an individual student. Used with studentRosterViewModel
* @author Brock Barlow
*/
public with sharing class studentRosterInformationViewModel {
	public String name {get;set;}
	public Id studentId {get;set;}
	public String homeSchoolName {get;set;}
	public String email {get;set;}
	public String phone {get;set;}
	public String phoneAbroad {get;set;}
	public String imageId {get;set;}
	public studentRosterInformationViewModel() {
		
	}
}