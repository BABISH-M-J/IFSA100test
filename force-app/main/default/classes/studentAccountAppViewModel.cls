/**
* @description Viewmodel class to display details about the student's account and balance
* @author Brock Barlow
*/
public without sharing class studentAccountAppViewModel
{
	public Decimal applicationBalance {get;set;}
	public String applicationName {get;set;}
	public List<studentAccountAppLineItemViewModel> lineItems {get;set;}
}