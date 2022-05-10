/**
 * Test class for the advisor login controller.
 * @author Cameron Ames
 */
@isTest
public without sharing class advisorLoginControllerTest
{
	/**
	 * Test the instance methods.
	 */
	public static testMethod void testInstance()
	{
		advisorLoginController controller = new advisorLoginController();
		PageReference reference = controller.login();
		reference = controller.validateAccess();
	}
}