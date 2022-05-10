/**
 * @description Base controller functionality for all portals
 * @author Cameron Ames
 */
public without sharing abstract class portalBaseController extends ifsaBaseController
{
	protected Portal_System_Message__mdt message {get;set;}
	/**
	 * @description Constructor function.
	 */
	protected portalBaseController()
	{
		super();
		String portalName = getPortalName();		
		try
		{
			this.message = [SELECT MasterLabel, Affected_Portal__c, Is_Lockdown_Active__c, Message__c, Message_End_Date__c, Message_Start_Date__c FROM Portal_System_Message__mdt WHERE Affected_Portal__c =: portalName AND Message_Start_Date__c <=: Date.today() AND Message_End_Date__c >=: Date.today()].get(0);
		}
		catch (ListException ex)
		{
			system.debug('No System Messages at this time');
		}
		
	}

	private String getPortalName()
	{
		String controllerName =String.valueOf(this).subString(0, 8);
		system.debug(controllerName);
		if(controllerName.contains('student'))
			return 'Student';
		else if(controllerName.contains('advisor'))
			return 'Advisor';
		else if(controllerName.contains('custom'))
			return 'Custom';

		return '';
	}
	
	/**
	 * @description Takes a view model class and fills it with data that can be obtained from this controller and parent class(es).
	 * @param viewModel A pre-existing instance of the view model class
	 * @return The same view model instance, populated with applicable data.
	 */
	protected portalBaseViewModel populatePortalBaseViewModel(portalBaseViewModel viewModel)
	{
		viewModel = (portalBaseViewModel) super.populateIfsaBaseViewModel(viewModel);
		viewModel.systemMessage = this.message.Message__c;
		viewModel.isLockDownActive = this.message.Is_Lockdown_Active__c == true ? true : false;
		
		return viewModel;
	}

	/**
	 * @description Accessor function. The default action is to do nothing (return null) but could potentially return a redirect.
	 * @return A pageReference redirect, or null, to signify that the page is accesible.
	 */
	public virtual PageReference validateAccess()
	{
		return null;
	}
}