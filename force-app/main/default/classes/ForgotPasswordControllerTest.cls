/**
 * Unit tests for <<ForgotPasswordController>>
 */
// ApexDoc updated 2/8/2021 Brock Barlow
@IsTest 
public without sharing class ForgotPasswordControllerTest 
{
	final static String orgId = userInfo.getOrganizationId();
	@TestSetup
	static void makeData()
	{
		Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection(new Set<String>());
		Contact advisorContact = [SELECT Id FROM Contact WHERE RecordType.Name = 'Advisor' LIMIT 1].get(0);
		Contact studentContact = (Contact) testData.get('studentContact');
		studentContact.Id = null;
		studentContact.Active_Application__c = null;
		Database.insert(studentContact);
		User studentUser = apexMockDataUtility.createUser(studentContact.Id);
		User advisorUser = apexMockDataUtility.createAdvisor(advisorContact.Id);
		User u = new User(Id = UserInfo.getUserId());
		System.runAs(u)
		{
			Database.insert(new List<User>{advisorUser, studentUser});
		}
	}

	public static testMethod void testSPForgotPasswordController() 
	{
		// Instantiate a new controller with all parameters in the page
		User guestUser = [SELECT Id FROM User WHERE Name = 'Student Portal Site Guest User'];
		User testUser = [SELECT Id, Email FROM User WHERE Profile.Name = 'IFSA Student User' AND Email LIKE: '%@test' + orgId + '.org.test' LIMIT 1].get(0);
		System.debug(testUser.Email);
		System.runAs(guestUser)
		{
			Test.startTest();
			Test.setCurrentPage(Page.ForgotPassword);
			ForgotPasswordController controller = new ForgotPasswordController();
    		controller.username = testUser.Email;
			controller.community = 'studentportal';
    
    		System.assertNotEquals(null, controller.forgotPassword()); 
			Test.stopTest();
		}	
    }
	public static testMethod void testCPForgotPasswordController()
	{
		// Instantiate a new controller with all parameters in the page
		User guestUser = [SELECT Id FROM User WHERE Name = 'Custom Portal Site Guest User'];
		User testUser = [SELECT Id, Email FROM User WHERE Profile.Name = 'IFSA Student User' AND Email LIKE: '%@test' + orgId + '.org.test' LIMIT 1].get(0);
		System.runAs(guestUser)
		{
			Test.startTest();
			Test.setCurrentPage(Page.ForgotPassword);
			ForgotPasswordController controller = new ForgotPasswordController();
    		controller.username = testUser.Email;
			controller.community = 'customportal';
    
    		System.assertNotEquals(null, controller.forgotPassword()); 
			Test.stopTest();
		}	
    }
	public static testMethod void tesAPForgotPasswordController()
	{
		// Instantiate a new controller with all parameters in the page
		User guestUser = [SELECT Id FROM User WHERE Name = 'Advisor Portal Site Guest User'];
		User testUser = [SELECT Id, Email FROM User WHERE Profile.Name = 'IFSA Advisor User' AND Email LIKE: '%@test' + orgId + '.org.test' LIMIT 1].get(0);
		System.runAs(guestUser)
		{
			Test.startTest();
			Test.setCurrentPage(Page.ForgotPassword);
			ForgotPasswordController controller = new ForgotPasswordController();
    		controller.username = testUser.Email;
			controller.community = 'advisorportal';
    
    		System.assertNotEquals(null, controller.forgotPassword()); 
			Test.stopTest();
		}	
    }
	public static testMethod void testCHForgotPasswordController() 
	{
		// Instantiate a new controller with all parameters in the page
		User guestUser = [SELECT Id FROM User WHERE Name = 'CHART Site Guest User'];
		User testUser = [SELECT Id, Email FROM User WHERE Profile.Name = 'IFSA Student User' AND Email LIKE: '%@test' + orgId + '.org.test' LIMIT 1].get(0);
		System.runAs(guestUser)
		{
			Test.startTest();
			Test.setCurrentPage(Page.CH_ForgotPassword);
			ForgotPasswordController controller = new ForgotPasswordController();
    		controller.username = testUser.Email;
			controller.community = 'chart';
    
    		System.assertNotEquals(null, controller.forgotPassword()); 
			Test.stopTest();
		}	
    }
	public static testMethod void testFail()
	{
		// Instantiate a new controller with all parameters in the page
    	ForgotPasswordController controller = new ForgotPasswordController();
    	controller.username = 'test@salesforce.com';     	
    
    	System.assertEquals(controller.forgotPassword(),null); 
	}
}