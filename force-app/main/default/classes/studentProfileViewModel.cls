/**
 * @description View model for the student profile page.
 * @author Cameron Ames
 */
public without sharing class studentProfileViewModel extends studentBaseViewModel
{
	public String mailingStreet {get;set;}
	public String mailingCity {get;set;}
	public String mailingState {get;set;}
	public String mailingZip {get;set;}
	public String mailingCountry {get;set;}
	public String otherStreet {get;set;}
	public String otherCity {get;set;}
	public String otherState {get;set;}
	public String otherZip {get;set;}
	public String otherCountry {get;set;}
	public String billingStreet {get;set;}
	public String billingCity {get;set;}
	public String billingState {get;set;}
	public String billingZip {get;set;}	
	public String billingCountry {get;set;}
	public String tradingCurrency {get;set;}

	public String accountId {get;set;}
	public String contactId {get;set;}
}