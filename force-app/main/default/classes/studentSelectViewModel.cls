/**
* @description Viewmodel for SP_Select page
* @author Cameron Ames
*/
public without sharing class studentSelectViewModel extends studentBaseViewModel
{
    public String programTermName {get;set;}
	public String countryName {get;set;}	
	public List<String> countryOptions {get;set;}
	
	public String advisorFirstName {get;set;}
    public String advisorLastName {get;set;}
    public String advisorEmail {get;set;}
    public String advisorPhone {get;set;}
    public String advisorPhotoUrl {get;set;}
    public String advisorCalendlyLink {get;set;}
    public String paIntroVideo {get;set;}
    public studentApplicationsViewModel applications {get;set;}
}