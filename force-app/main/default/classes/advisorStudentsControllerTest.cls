/**
 * Unit test class for <<advisorStudentsController>>. This class has been depreciated. Unit tests from this class have been moved to <<advisorPortalControllerTest>>
 */
// ApexDoc updated 1/25/2021 Brock Barlow
@isTest
public without sharing class advisorStudentsControllerTest
{
	/*
	@TestSetup
    static void makeData(){
        Map<String,SObject> testData = apexMockDataUtility.createIfsaDataCollection();
    }

	public static testMethod void testInstance1()
	{
		Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
		Id advisorContactId = [SELECT Id FROM Contact WHERE RecordTypeId = :advisorRecordType LIMIT 1].Id;
		User advisorUser = apexMockDataUtility.createAdvisor(advisorContactId);

		//User advisorUser = [SELECT Id FROM User WHERE ProfileId = :advisorProfile AND isActive = true LIMIT 1];
		Program_Term__c programTerm = [SELECT Id, Term__r.Section__c, Term__r.Year__c, Program__r.Host_Institution__r.Country__r.Name FROM Program_Term__c LIMIT 1];
		Application__c app = [SELECT Id FROM Application__c LIMIT 1];
		Program__c prog = [SELECT Id FROM Program__c LIMIT 1];
		Id sysAdminProfile = [SELECT Id FROM Profile WHERE Name =: 'System Administrator'].Id;
		prog.Academic_Affairs_Coordinator__c = [SELECT Id FROM User WHERE ProfileId = :sysAdminProfile LIMIT 1].Id;

		test.startTest();
		database.update(prog);
		System.runAs(advisorUser)
        {        	
			// Test loading page
			advisorStudentsController controller = new advisorStudentsController();
			PageReference reference = controller.validateAccess();
			// Test searching for students
			List<advisorStudentApplicationViewModel> applicationList = advisorStudentsController.searchForStudents(programTerm.Term__r.Section__c, String.valueOf(programTerm.Term__r.Year__c), programTerm.Program__r.Host_Institution__r.Country__r.Name, 'New', false, '');
			// Test get application details
			advisorStudentsAppDetailsViewModel details1 = advisorStudentsController.getApplicationDetails(String.valueOf(app.Id));
			// Test submit good program approval
			system.debug(String.valueOf(app.Id));
			advisorStudentsAppDetailsViewModel details2 = advisorStudentsController.getApplicationDetails(String.valueOf(app.Id));
			details2.appItems[0] = advisorStudentsController.getApplicationItemDetails(String.valueOf(details2.appItems[0].Id));
			details2.appItems[0].recordType = 'Program_Approval';            
			details2.appItems[0].status = 'Complete';
			details2.appItems[0].academicProbation = 'No';
			details2.appItems[0].approvalToStudy = 'Yes';
			details2.appItems[0].discipline = 'No';
			details2.appItems[0].goodStanding = 'Yes';
			String response = advisorStudentsController.submitApplicationItem(JSON.serialize(details2.appItems.get(0)), null, null, null);

			System.assertEquals('Complete', response);
			// Test submit bad program approval
			advisorStudentsAppDetailsViewModel details3 = advisorStudentsController.getApplicationDetails(String.valueOf(app.Id));
			details3.appItems[0] = advisorStudentsController.getApplicationItemDetails(String.valueOf(details2.appItems[0].Id));
			String explain = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec porta libero et molestie varius. Suspendisse potenti. Suspendisse dapibus ut diam a pulvinar. Ut finibus scelerisque tristique.';
			details3.appItems[0].recordType = 'Program_Approval';
			details3.appItems[0].status = 'Complete';
			details3.appItems[0].academicProbation = 'Yes';
			details3.appItems[0].academicProbationExplanation = explain;
			details3.appItems[0].approvalToStudy = 'No';
			details3.appItems[0].approvalToStudyExplanation = explain;
			details3.appItems[0].discipline = 'Yes';
			details3.appItems[0].disciplinaryActionExplanation = explain;
			details3.appItems[0].goodStanding = 'No';
			details3.appItems[0].goodStandingExplanation = explain;
			response = advisorStudentsController.submitApplicationItem(JSON.serialize(details3.appItems.get(0)), null, null, null);

			System.assertEquals('Complete', response);
		}
		test.stopTest();			
	}
	public static testMethod void testInstance2()
	{
		Id advisorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
		Id advisorContactId = [SELECT Id FROM Contact WHERE RecordTypeId = :advisorRecordType LIMIT 1].Id;
		User advisorUser = apexMockDataUtility.createAdvisor(advisorContactId);
		Application__c app = [SELECT Id FROM Application__c LIMIT 1];
		test.startTest();
		System.runAs(advisorUser)
        {
			// Test submit program approval for Submitted Student
			app = new Application__c(Id = app.Id, Status__c = 'Submitted');
			database.update(app);
            			
			advisorStudentsAppDetailsViewModel details2 = advisorStudentsController.getApplicationDetails(String.valueOf(app.Id));
			details2.appItems[0] = advisorStudentsController.getApplicationItemDetails(String.valueOf(details2.appItems[0].Id));
			details2.appItems[0].recordType = 'Program_Approval';            
			details2.appItems[0].status = 'Complete';
			details2.appItems[0].phase = 'Pre-Acceptance';
			details2.appItems[0].academicProbation = 'No';
			details2.appItems[0].approvalToStudy = 'Yes';
			details2.appItems[0].discipline = 'No';
			details2.appItems[0].goodStanding = 'Yes';
			String response = advisorStudentsController.submitApplicationItem(JSON.serialize(details2.appItems.get(0)), null, null, null);

			System.assertEquals('Complete', response);
			app = [SELECT Id, Status__c FROM Application__c WHERE Id =: app.Id];
			System.assertNotEquals('Ready To Submit', app.Status__c, 'The status has been changed back');
		}
		test.stopTest();
	}
	public static testMethod void testInstance3()
	{
		BaseTriggerHandler.bypass('userTriggerHandler');
		// Contact c = [SELECT Id, Home_Institution__c FROM Contact Home_Institution__c WHERE Home_Institution__c != NULL AND RecordTypeId =: Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId()].get(0);
		Application__c app = [SELECT Id FROM Application__c LIMIT 1];
		// User advisorUser = apexMockDataUtility.createAdvisor(c.Id);
		
		User guestUser = [SELECT Id FROM User WHERE Name = 'Advisor Portal Site Guest User'].get(0);
		test.startTest();
        
		// Test submit program approval for where user session has expired
		// app = new Application__c(Id = app.Id, Status__c = 'Program Selected');
		// database.update(app);
		advisorStudentsAppDetailsViewModel details4;
		
		details4 = advisorStudentsController.getApplicationDetails(String.valueOf(app.Id));
		details4.appItems[0] = advisorStudentsController.getApplicationItemDetails(String.valueOf(details4.appItems[0].Id));
		details4.appItems[0] = advisorStudentsController.getApplicationItemDetails(String.valueOf(details4.appItems[0].Id));
		
		System.runAs(guestUser)
        {
			String explain = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec porta libero et molestie varius. Suspendisse potenti. Suspendisse dapibus ut diam a pulvinar. Ut finibus scelerisque tristique.';
			details4.appItems[0].recordType = 'Program_Approval';
			details4.appItems[0].status = 'Complete';
			details4.appItems[0].academicProbation = 'Yes';
			details4.appItems[0].academicProbationExplanation = explain;
			details4.appItems[0].approvalToStudy = 'No';
			details4.appItems[0].approvalToStudyExplanation = explain;
			details4.appItems[0].discipline = 'Yes';
			details4.appItems[0].disciplinaryActionExplanation = explain;
			details4.appItems[0].goodStanding = 'No';
			details4.appItems[0].goodStandingExplanation = explain;
			String response = advisorStudentsController.submitApplicationItem(JSON.serialize(details4.appItems.get(0)), null, null, null);

			System.assertEquals('ERROR: Your session has been corrupted, please log out and log back in to try again.', response);
        }
		test.stopTest();
		BaseTriggerHandler.clearAllBypasses();
	}
	*/
}