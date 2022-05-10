/**
* @description Base Viewmodel for student portal
* @author Cameron Ames
*/
public without sharing abstract class studentBaseViewModel extends portalBaseViewModel
{
	public String advisorFirstName {get;set;}
    public String advisorLastName {get;set;}
    public String advisorEmail {get;set;}
    public String advisorPhone {get;set;}
    public String advisorPhotoUrl {get;set;}
    public String advisorCalendlyLink {get;set;}
	public String paIntroVideo {get;set;}
	
	public String studentFirstName {get;set;}
	public String studentPreferredName {get;set;}
	public String studentLastName {get;set;}
	public String contactId {get;set;}
	public String butlerId {get;set;}
	
	public String applicationStatus {get;set;}
	public Boolean hasFinancialHold {get;set;}
	public Boolean hasHousing {get;set;}
	public Boolean hasManyApplications {get;set;}
	public Boolean hasScholarship {get;set;}
	public String scholarshipURL {get;set;}
    public Integer applicationCount {get;set;}
	public Boolean isCatalog {get;set;}
	public String programName {get;set;}
	public Boolean isTraveling {get; set;}
	public Boolean isCustom {get;set;}
	
	public Boolean isRegistered 
	{
		get
		{
			if(isRegistered != true)
			{
				isRegistered = (this.applicationStatus != null && this.applicationStatus != 'New');
			}
			return isRegistered;
		}
		set;
	}

	public Boolean isProgramSelected
	{
		get
		{
			if(isProgramSelected != true)
			{
				isProgramSelected = (this.applicationStatus != null && this.applicationStatus != 'New' && this.applicationStatus != 'Registered');
			}
			return isProgramSelected;
		}
		set;
	}
	public Boolean isReadyToSubmit
	{
		get
		{
			if(isReadyToSubmit != true)
			{
				isReadyToSubmit = (this.applicationStatus == 'Ready To Submit') ? true : false;
			}
			return isReadyToSubmit;
		}
		set;
	}

	public Boolean isApplied
	{
		get
		{
			if(isApplied != true)
			{
				isApplied = (this.applicationStatus != null && this.applicationStatus != 'New' && this.applicationStatus != 'Registered' && this.applicationStatus != 'Program Selected'); // && this.applicationStatus != 'Ready To Submit');
			}
			return isApplied;
		}
		set;
	}

	public Boolean isAccepted
	{
		get
		{
			if(isAccepted != true)
			{
				isAccepted = (this.applicationStatus == 'Accepted' || this.applicationStatus == 'Accepted (with Conditions)' || this.applicationStatus == 'On Site' || this.applicationStatus == 'Program Completed');
			}
			return isAccepted;
		}
		set;
	}

	public Boolean isOnSite
	{
		get
		{
				isOnSite = (this.applicationStatus != null && (this.applicationStatus == 'On Site' || this.applicationStatus == 'Program Completed' || this.hasHousing == true));
			
			return isOnSite;
		}
		set;
	}
	public Boolean isContractSigned
	{
		get
		{
			if(isContractSigned != true)
			{
				isContractSigned = (this.applicationStatus != null && (this.applicationStatus == 'On Site' || this.applicationStatus == 'Contract Signed' || this.applicationStatus == 'Housing Selected' || this.applicationStatus == 'Program Completed' || this.applicationStatus == 'Travel Approved'));
			}
			return isContractSigned;
		}
		set;
	}
	public Boolean isDropped
	{
		get
		{
			if(isDropped != true)
			{
				isDropped = (this.applicationStatus != null && (this.applicationStatus =='Dropped' || this.applicationStatus == 'Deferred' || this.applicationStatus == 'Diverted' || this.applicationStatus == 'Withdraw' || this.applicationStatus == 'Unqualified'));
			}
			return isDropped;
		}
		set;
	}
	public Boolean showChart
	{
		get
		{
			try
			{
				Custom_Community_Setting__mdt value = [SELECT DeveloperName, Content__c FROM Custom_Community_Setting__mdt WHERE DeveloperName = 'Show_CHART_In_Portals'].get(0);
				return value.Content__c == 'true' ? true : false;
			}
			catch(Exception e)
			{
				return false;
			}
		}
		set;
	}
}