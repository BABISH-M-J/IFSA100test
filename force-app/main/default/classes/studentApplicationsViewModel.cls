/**
* @description Viewmodel class to display details about an application
* @author Brock Barlow
*/
public with sharing class studentApplicationsViewModel {
	public String activeApplication {get;set;}
	public List<ApplicationViewModel> applications {get;set;}
	public Contact student {get;set;}
	public Id activeAppId {get;set;}
	public Boolean saveStudent {get;set;}
	
	public studentApplicationsViewModel()
	{
		this.applications = new List<ApplicationViewModel>();
	}

}