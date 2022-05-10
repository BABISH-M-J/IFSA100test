/**
 * Controller that is used for the login page of the advisor portal.
 * @author Cameron Ames
 */
// ApexDoc updated 1/22/2021 Brock Barlow
public without sharing class advisorLoginController
{
	/**
	 * Container for all data needed on the page. See <<advisorLoginViewModel>>	 
	 */
	public advisorLoginViewModel viewModel {get;set;}
	/**
	 * Google Anayltics Id
	 */
	public String gaId {get;set;}
	/**
	 * Google Tag Manager Id
	 */
    public String gtmId {get;set;}
	public String startURL {get;set;}	

	/**
	 * Constructor function. Only initializes a blank view model for this page.
	 * @return void
	 */
	public advisorLoginController()
	{
		system.debug(ApexPages.currentPage().getURL());
		this.startURL = ApexPages.currentPage().getParameters().get('startURL');
		this.viewModel = new advisorLoginViewModel();
		GoogleAnalyticsUtility util = new GoogleAnalyticsUtility('AP');
        this.gaId = util.getAnalyticsId();
        this.gtmId = util.getTagManagerId();
		system.debug(startURL);
	}

	/**
	 * Authorization function required to be implemented on every page. This action is called upon page load. It always returns null (is authorized) because no authorization is needed.
	 * @return PageReference
	 */
	public PageReference validateAccess()
	{
		return null;
	}

	/**
	 * Function used login to the website.
	 * @return PageReference
	 */
    public PageReference login()
	{
		System.debug(startURL);
        return Site.login(viewModel.email + '.ifsa', viewModel.password, startURL);
    }
}