/**
 * Controller class for CH_Error Visualforce page
 * @author Brock Balow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public without sharing class chartErrorController extends chartBaseController
{
	/**
	 * Viewmodel to provide information to the VF page
	 */
	public chartSearchViewModel viewModel {get;set;}
	/**
	 * Constructor, gets the data needed to display the page
	 */
	public chartErrorController() 
	{
		super();
        
        this.viewModel = new chartSearchViewModel();
		this.populateViewModel();
	}

	private void populateViewModel()
    {
        this.viewModel = (chartSearchViewModel) super.populateViewModel(this.viewModel);
        
    }
}