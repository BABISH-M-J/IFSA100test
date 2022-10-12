@isTest
public class MetadataUtil_Test {
    
    @testSetup
    public static void mockdata(){
        
    }
    
    @isTest
    public static void testcheckMetadataAPIConnection(){
        Test.StartTest();
        Test.setMock(WebServiceMock.class, new MetadatServiceMock());
        Boolean result = MetadataUtil.checkMetadataAPIConnection();
        Test.StopTest();
        System.assert(result);
    }
    
    @isTest
    public static void testtransformToCustomMetadataAndCreateUpdateNullCheck(){
        Test.StartTest();
        MetadataUtil.transformToCustomMetadataAndCreateUpdate(null,null,null,null,null);
        Test.StopTest();
        System.assert(ApexPages.hasMessages());
    }
    
    @isTest
    public static void testtransformToCustomMetadataAndCreateUpdateHeaderMessage(){
        //Creating Test list as standardFields
        List<List<String>> fieldValues = new List<List<String>>();
        for(integer i=0 ;i<2;i++){
            List<String> str = new List<String>();
            for(integer j=0 ;j<2;j++){
                str.add('fieldValues '+i+j);
            }
            fieldValues.add(str);
        }
        
        //Creating Test list as header
        List<String> header = new List<String>();
        for(integer j=0 ;j<3;j++){
            header.add('header '+j);
        }
        
        Test.StartTest();
        MetadataUtil.transformToCustomMetadataAndCreateUpdate(null,fieldValues,header,null,0);
        Test.StopTest();
        System.assert(ApexPages.hasMessages());
    }
    
    @isTest
    public static void testtransformToCustomMetadataAndCreateUpdateCallout(){
        //Creating Test list as standardFields
        Set<String> standardFields = new Set<String>();
        standardFields.add('Name');
        
        //Creating Test list as fieldValues
        List<List<String>> fieldValues = new List<List<String>>();
        for(integer i=0 ;i<1;i++){
            List<String> str = new List<String>();
            for(integer j=0 ;j<2;j++){
                str.add('fieldValues '+i+j);
            }
            fieldValues.add(str);
        }
        
        //Creating Test list as //Creating Test list as standardFields
        List<String> header = new List<String>();
        header.add('Label');
        header.add('Name');
        
        Test.StartTest();
        Test.setMock(WebServiceMock.class, new MetadatServiceMockUpsertMetaData());
        MetadataUtil.transformToCustomMetadataAndCreateUpdate(standardFields,fieldValues,header,'Test123__mdt',0);
        Test.StopTest();
        System.assert(ApexPages.hasMessages());
    }
}