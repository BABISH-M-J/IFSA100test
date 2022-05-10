@isTest
public class FinancialAidItemViewModel_Test {

    @testSetup
    public static void mockdata(){
        
    }
    
    @isTest
    public static void testFinancialAidItemViewModel(){
        FinancialAidItemViewModel favm = new FinancialAidItemViewModel();
        favm.aidType = 'test aidType';
        favm.disbursmentAmount = 123.00;
        favm.disbursmentDate = System.today();
        System.assertEquals(favm.aidType, 'test aidType');
    }
}