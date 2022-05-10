/**
 * @description Test Class for <<internalTermCloneController>>
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
@isTest
public without sharing class internalTermCloneControllerTest
{
	private static Map<String, SObject> testData {get;set;}

    @isTest static void testInstance()
	{
        testData = apexMockDataUtility.createIfsaDataCollection();
        Program_Term__c pt = (Program_Term__c) testData.get('programTerm2');
        Program_Term_Housing_Option__c ptho1 = new Program_Term_Housing_Option__c(Housing_Option__c = testData.get('housingOption').Id, Program_Term__c = pt.Id);
        database.insert(ptho1);

        formBuilderComponentController.Form formWrap = new formBuilderComponentController.Form();
        Id cifRecordTypeId = Schema.SObjectType.Dynamic_Form__c.getRecordTypeInfosByName().get('CIF').getRecordTypeId();

        formWrap = formBuilderComponentController.initForm(null, cifRecordTypeId);
        String jsonWrapper = JSON.serialize(formWrap, true);
        String formId = formBuilderComponentController.submitForm(jsonWrapper, 4, 4, 'testForm', true);

        Application_Requirement__c appReq = (Application_Requirement__c) testData.get('applicationRequirement');
        appReq.Program_Term__c = pt.Id;
        appReq.Dynamic_Form__c = formId;
        database.update(appReq);
        
        
        Test.startTest();
        PageReference ref = new PageReference('/apex/internalTermClone?ptId=' + pt.Id);
        Test.setCurrentPage(ref);
        internalTermCloneController controller = new internalTermCloneController();
        internalTermCloneViewModel viewModel = controller.viewModel;
        viewModel.getSerializedViewModel();
        String newTermId = internalTermCloneController.createNewTerm('Spring', 2040);
        String jobIds = internalTermCloneController.initializeCloneJob(pt.Id, newTermId);
        Test.stopTest();
        String status = internalTermCloneController.checkApexJobs(jobIds);
        String programTermId = internalTermCloneController.getNewProgramTermId(pt.Program__c, newTermId);
        system.assertNotEquals(null, programTermId);

        // Test a term that already exists
        String existingTermId = internalTermCloneController.createNewTerm('Spring', 2040);
        system.assertEquals(newTermId, existingTermId, 'Ids are not the same');
        // These will return null;
        system.assertEquals(null, internalTermCloneController.initializeCloneJob(pt.Id, ''), 'Expecting null value');
        system.assertEquals(null, internalTermCloneController.getNewProgramTermId(pt.Program__c, ''), 'Expecting null value');
        // This will throw an exception
        Id poId = [SELECT Id FROM Program_Term__c WHERE RecordType.Name LIKE 'Program Option%'].get(0).Id;
        ref = new PageReference('/apex/internalTermClone?ptId=' + poId);
        Test.setCurrentPage(ref);
        Boolean correctException = false;
        try
        {
            controller = new internalTermCloneController();
        }
        catch (Exception e)
        {
            correctException = e instanceof internalTermCloneViewModel.internalTermCloneViewModelException;
            if(!correctException)
                throw e;
        }
        system.assertEquals(true, correctException, 'This should have cause an "internalTermCloneViewModel.internalTermCloneViewModelException" to be thrown');
    }
    @isTest(SeeAllData=true)
    static void testCheckJob()
    {
        // Wrapped in a Try/Catch because if the org does not have any jobs we do not want it to fail the test       
        try
        {
            // Find a completed job
            AsyncApexJob job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE Status = 'Completed' LIMIT 1].get(0);
            String jobIds = '["' + job.Id + '"]';
            String status = internalTermCloneController.checkApexJobs(jobIds);
            // Find a failded job
            job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE Status = 'Failed' LIMIT 1].get(0);
            jobIds = '["' + job.Id + '"]';
            status = internalTermCloneController.checkApexJobs(jobIds);
            // Find an aborted job
            job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE Status = 'Aborted' LIMIT 1].get(0);
            jobIds = '["' + job.Id + '"]';
            status = internalTermCloneController.checkApexJobs(jobIds);
            // Find a running job
            job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE Status = 'Running' LIMIT 1].get(0);
            jobIds = '["' + job.Id + '"]';
            status = internalTermCloneController.checkApexJobs(jobIds);
        }
        catch (Exception e)
        {
            
        }
        finally
        {
            system.debug('Test testCheckJob completed');
        }

    }
}