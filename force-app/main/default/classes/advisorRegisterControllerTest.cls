/**
 * Test class for the advisor register controller.
 * @author Cameron Ames
 */
// ApexDoc updated 1/23/2021 Brock Barlow
@isTest
public with sharing class advisorRegisterControllerTest
{
	/**
	 * Test instance methods
	 */
  
	public static testMethod void testInstance()
	{
          Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection();

		Home_Institution__c homeInstitution = (Home_Institution__c) testData.get('homeInstitution1');
		Account acct = [SELECT Id FROM Account WHERE Institution__c =: homeInstitution.Id AND RecordType.Name = 'Home Institution' LIMIT 1];
		Contact ctc = apexMockDataUtility.createContact('Test1', acct.Id);
        //modified by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
 			User testUser = new User(
            FirstName = 'Unit',
            LastName = 'Test',
            email = 'test@123.ifsa.com',
            Username = 'john@acme.com',
           Alias = 'john',
            CommunityNickname = 'john',
            UserRole = [SELECT Id FROM Userrole WHERE Name =: 'President'].get(0),
            ProfileId = [SELECT Id FROM Profile WHERE Name =: 'IFSA Advisor User'].get(0).Id,
            contactId = ctc.Id,
            //CreatedDate = DateTime.now(),
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            UserPermissionsMobileUser = false,
            Email_Confirmed_For_CHART__c = true
                
        );       
        Database.insert(testUser);
		Contact ctc1 = apexMockDataUtility.createContact('Test2', acct.Id);
        User use=apexMockDataUtility.createUser(ctc1.Id);
       // use.email = 'test@123.ifsa.com';
        //Database.update(use);
         system.debug('email'+acct);

        system.debug('email'+use.Email);
       
		advisorRegisterController controller = new advisorRegisterController();

		// controller.viewModel.password = 'asdfasdf1';
		// controller.viewModel.confirmPassword = 'asdfasf1';
		controller.viewModel.password = 'Adfasdf@1';
		controller.viewModel.confirmPassword = 'Adfasdf@1';
//modified by PowerFluence req_dt:03/29/2022 ref email from Clayton ends
		controller.viewModel.email = 'test@123.ifsa.com';
		controller.viewModel.firstName = 'Unit';
		controller.viewModel.lastName = 'Test';
        controller.viewModel.institutionId = homeInstitution.Id;
//added by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
		//controller.viewModel.title = 'Test';
		//controller.viewModel.homeInstitutionName = homeInstitution.name;
		//controller.viewModel.customMessages = 'Test123';
		controller.validateAccess();
		
//added by PowerFluence req_dt:03/29/2022 ref email from Clayton ends
		/*User newUser = [SELECT Id, ContactId, Username FROM User WHERE ProfileId =:testUser.ProfileId  AND CreatedDate >=: Date.today() AND Email =: 'test@123.ifsa.com'].get(0);
        system.debug('newUser'+newUser+Date.today()+DateTime.now());*/
		 system.runAs(testUser){
		
		advisorRegisterController arc = new advisorRegisterController();
		String result = advisorRegisterController.register(JSON.serialize(controller.viewModel));
      
//modified by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
		PageReference ref =arc.validateAccess();
		PageReference ref1 =arc.registerUser();
//modified by PowerFluence req_dt:03/29/2022 ref email from Clayton ends		
		String error = 'ERROR: Sorry, ';
		system.assertEquals(true, result.startsWith(error));
              }
	
	}

	/**
	 * test static method search home institution
	 */
	public static testMethod void testSearchHomeInstitution()
	{
		List<Home_Institution__c> his = advisorRegisterController.searchHomeInstitution('Butler University');
	}

}