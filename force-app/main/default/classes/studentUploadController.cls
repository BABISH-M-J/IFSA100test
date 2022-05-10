/**
* @description Controller for upload page
* @author Cameron Ames
*/
public without sharing class studentUploadController extends studentBaseController
{
	public Attachment attmt {get;set;}
	public Id parentId {get;set;}
	public studentApplyViewModel viewModel {get;set;}
	private Application_Item__c appItem {get;set;}
    public String pageSource {get;set;}
	
	public studentUploadController()
	{
		super();
		this.parentId = Id.valueOf(ApexPages.currentPage().getParameters().get('parentId'));
        this.pageSource = ApexPages.currentPage().getParameters().get('pageSource');
        if(this.pageSource == null || this.pageSource == '')
        {
            this.pageSource = 'SP_Apply';
        }
		this.attmt = new Attachment();
		this.viewModel = populateViewModel(new studentApplyViewModel());
		this.appItem = (Application_Item__c) apexQueryUtility.selectAllFrom('Application_Item__c', 'Id = \'' + this.parentId + '\'').get(0);        
	}
	
	public PageReference submit()
	{
		String portal = '';
		if (this.pageSource.contains('CP') == true)
		{
			portal = 'customportal';
		}
		else if (this.pageSource.contains('SP') == true)
		{
			portal = 'studentportal';
		}
		if(this.attmt.name != null )
        {
            this.attmt.ParentId = this.parentId;
		    Database.insert(this.attmt);
            return new PageReference('/' + portal + '/' + this.pageSource);
        }
        else
        {        	
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select a file to upload'));
            return null;
        }
		
	}
    private studentApplyViewModel populateViewModel(studentApplyViewModel viewModel)
    {
        viewModel = (studentApplyViewModel)super.populateViewModel(new studentApplyViewModel());
        viewModel.pageSource = this.pageSource;
        return viewModel;
    }
}