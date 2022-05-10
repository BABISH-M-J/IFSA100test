/**
 * Base controller for internal Visualforce pages.
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing abstract class internalBaseController extends ifsaBaseController
{
	/**
	 * Viewmodel
	 */
	public internalBaseViewModel viewModel {get;set;}

	/**
	 * Constructor
	 */
	public internalBaseController()
	{
		super();
	}
	
	/**
	 * populates viewmodel
	 */
	protected internalBaseViewModel populateInternalBaseViewModel(internalBaseViewModel viewModel)
	{
		viewModel = (internalBaseViewModel) super.populateIfsaBaseViewModel(viewModel);
		
		return viewModel;
	}
}