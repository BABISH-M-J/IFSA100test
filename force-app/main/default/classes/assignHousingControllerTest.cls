/**
 * Unit tests for <<assignHousingController>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
@isTest
private class assignHousingControllerTest {
    /**
     * Tests an instance of <<assignHousingController>> and it's methods
     */
//modified by PowerFluence req_dt:03/29/2022 ref email from Clayton starts

    // static testMethod void testInstance() {        
    //     Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();
    //     Application__c app = (Application__c) testData.get('studentApplication');                 
    //    // Housing_Option__c hOption = (Housing_Option__c) testData.get('housingOption');
    //     Housing_Assignment__c hAssign = (housing_Assignment__c) testData.get('housingAssignment');
    //    // Program_Term__c pt = (Program_Term__c) testData.get('programTerm');
      
        
    //     Test.startTest();
    //     PageReference ref = new PageReference('/apex/Advisor_Reassignment?id=' + app.id);
    //     Test.setCurrentPage(ref);
    //     assignHousingController controller = new assignHousingController();
    //     controller.viewModel.housingAssignment = hAssign.id;
        
    //     assignHousingController.getHousing(hAssign.Locality__c, app.Id);

    //     assignHousingController.assignHousing(hAssign.Name, app.Id);
       
    //     controller.returnToApp();
    //     test.stopTest();
    // }


    //modified

    static testMethod void testInstance2()
    {
        Map<String, SObject> testData = apexMockDataUtility.createIfsaDataCollection();

        Housing_Assignment__c hAssign = (housing_Assignment__c) testData.get('housingAssignment');
        Application__c app = (Application__c) testData.get('studentApplication'); 
        Program_Term__c pt = (Program_Term__c) testData.get('programTerm');

        Housing_Option__c houseOption = new Housing_Option__c();
        houseOption.Name = 'test';
        
        Database.insert(houseOption);
        system.debug('datagatering'+houseOption.Id);
        Program_Term_Housing_Option__c option= new Program_Term_Housing_Option__c();
        option.Housing_Option__c= houseOption.Id;
        option.Program_Term__c = pt.Id;
        Database.insert(option);

        Housing_Preference__c house = new Housing_Preference__c();
        house.Application__c = app.Id ;
        house.Program_Term_Housing_Option__c = option.Id;
        house.Rank__c= 1;
        Database.insert(house);

        Test.startTest();
        PageReference ref = new PageReference('/apex/Advisor_Reassignment?id=' + app.id);
        Test.setCurrentPage(ref);
        assignHousingController controller = new assignHousingController();
        controller.viewModel.housingAssignment = hAssign.Id;

        assignHousingController.getHousing(hAssign.Locality__c, app.Id);

        assignHousingController.assignHousing(hAssign.Name, app.Id);
       
        controller.returnToApp();
        Test.stopTest();
    }
//modified by PowerFluence req_dt:03/29/2022 ref email from Clayton ends

}