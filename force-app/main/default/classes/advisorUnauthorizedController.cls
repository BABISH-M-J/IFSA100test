/**
 * @description Controller class used when an advisor is not authorized to use Advisor Portal
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public without sharing class advisorUnauthorizedController extends advisorBaseController
{
	/**
	 * Basic Constructor
	 */
	public advisorUnauthorizedController(){}
	/**
	 * Validates a users access to this page. If an authorized user happens upon this page, they are redirected back to the main advisor portal page
	 * @return PageReference
	 */
	public override PageReference validateAccess()
	{
		if(this.advisor.isApprovedForAdvising())
		{
			return new PageReference('Advisor_Portal');
		}
		
		return null;
	}
}