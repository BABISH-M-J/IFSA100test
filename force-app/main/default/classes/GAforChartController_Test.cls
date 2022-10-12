@isTest
public class GAforChartController_Test {
	
    @testSetup
    public static void mockdata(){
        
    }
    
    @isTest
    public static void testsetGATIdSandbox(){
        GAforChartController gacc = new GAforChartController();
        gacc.setGATId();
        System.assert(String.isNotBlank(gacc.GATId));
    }
    
    @isTest
    public static void testgetGATIdSandbox(){
        GAforChartController gacc = new GAforChartController();
        String result = gacc.getGATId();
        System.assert(String.isNotBlank(result));
    }
}