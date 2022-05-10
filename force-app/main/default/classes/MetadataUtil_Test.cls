@isTest
public class MetadataUtil_Test {
    
    @testSetup
    public static void mockdata(){
        
    }

    @isTest
    public static void test1(){
  Test.StartTest();

        MetadataUtil.checkMetadataAPIConnection();
        
        Test.StopTest();
    }
}