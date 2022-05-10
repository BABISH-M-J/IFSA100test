/**
 * @description Unit tests for <<AdvisorReassignmentController>>
 */
// ApexDoc updated 1/22/2021 Brock Barlow
@isTest
private class advisorReassignmentControllerTest {
    /**
     * @description Tests retreiving the data required for the page to work and executes the save method
     */
    static testMethod void testInstance() {        
        Map<String, SObject> application = apexMockDataUtility.createIfsaDataCollection();
        Contact oldadvisor = (Contact) application.get('advisorContact1');
        Contact newadvisor = (Contact) application.get('advisorContact2');        
        PageReference ref = new PageReference('/apex/Advisor_Reassignment?id=' + oldadvisor.id);
        test.startTest();
        Test.setCurrentPage(ref);
        AdvisorReassignmentController controller = new AdvisorReassignmentController();
        controller.viewModel.newAdvisor = newadvisor.id;
        
        controller.Save();
        test.stopTest();
    }
}