@isTest
private with sharing class dynamicFormServiceTest {
    @TestSetup
    static void makeData(){
        
        Id recType = Schema.SObjectType.Dynamic_Form__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Dynamic_Form__c df=new Dynamic_Form__c(recordTypeId=recType,Name='testform');
        Database.insert(df);
        
        Dynamic_Form_Item__c dfi=new Dynamic_Form_Item__c(Dynamic_Form__c=df.Id,Name='testFormItem',Use_Destination_Field_s_Picklist_Values__c=true);
        dfi.Destination_Object_Name__c = 'Dynamic_Form_Item__c';
        dfi.Destination_Field_Name__c = 'CurrencyIsoCode';
        Database.insert(dfi);
    }
    
    @isTest
    static void testgetPicklistValues()
    {
        Dynamic_Form_Item__c dfi=[Select Id,Use_Destination_Field_s_Picklist_Values__c,Destination_Field_Name__c,Destination_Object_Name__c from Dynamic_Form_Item__c limit 1];
        test.startTest();
        dynamicFormService.getPicklistValues(new List<Dynamic_Form_Item__c>{dfi});
        System.assertEquals(false, dfi.Use_Destination_Field_s_Picklist_Values__c);
        test.stopTest();
    }
    
    @isTest
    static void testconvertResponseText()
    {
        formBuilderComponentController.Item formItem= new formBuilderComponentController.Item();
        test.startTest();
        formItem.fieldType='Text';
        formItem.response = 'Test';
        Object result = dynamicFormService.convertResponse(formItem);
        System.assertEquals(result,formItem.response);
        String stringresult = dynamicFormService.convertResponse(formItem,result);
        System.assert(String.isNotBlank(stringresult));
        test.stopTest();
    }  
    
    @isTest
    static void testconvertResponseNumber()
    {
        formBuilderComponentController.Item formItem= new formBuilderComponentController.Item();
        test.startTest();
        formItem.fieldType='Number';
        formItem.response = '123';
        Object result = dynamicFormService.convertResponse(formItem);
        System.assertEquals(result,Double.valueOf(formItem.response));
        String stringresult = dynamicFormService.convertResponse(formItem,result);
        System.assert(String.isNotBlank(stringresult));
        test.stopTest();
    }  
    
    @isTest
    static void testconvertResponseCheck_Box()
    {
        formBuilderComponentController.Item formItem= new formBuilderComponentController.Item();
        test.startTest();
        formItem.fieldType='Check_Box';
        formItem.response = 'true';
        Object result = dynamicFormService.convertResponse(formItem);
        System.assertEquals(result,Boolean.valueOf(formItem.response));
        formItem.fieldType='Check Box';
        String stringresult = dynamicFormService.convertResponse(formItem,result);
        System.assert(String.isNotBlank(stringresult));
        test.stopTest();
    }  
    
    @isTest
    static void testconvertResponseDate_Time()
    {
        formBuilderComponentController.Item formItem= new formBuilderComponentController.Item();
        test.startTest();
        formItem.fieldType='Date_Time';
        datetime currdatetime = System.today();
        formItem.response = String.valueOf(currdatetime);
        Object result = dynamicFormService.convertResponse(formItem);
        System.assertEquals(result,currdatetime);
        formItem.fieldType='Date/Time';
        String stringresult = dynamicFormService.convertResponse(formItem,result);
        System.assert(String.isNotBlank(stringresult));
        test.stopTest();
    }  
    
    @isTest
    static void testconvertResponseDate()
    {
        formBuilderComponentController.Item formItem= new formBuilderComponentController.Item();
        test.startTest();
        formItem.fieldType='Date';
        date todaydate = System.today();
        formItem.response = String.valueOf(todaydate);
        Object result = dynamicFormService.convertResponse(formItem);
        System.assertEquals(result,todaydate);
        String stringresult = dynamicFormService.convertResponse(formItem,result);
        System.assert(String.isNotBlank(stringresult));
        test.stopTest();
    }  

	@isTest
    static void testconvertResponseElse()
    {
        formBuilderComponentController.Item formItem= new formBuilderComponentController.Item();
        test.startTest();
        formItem.response = 'Test';
        Object result = dynamicFormService.convertResponse(formItem);
        System.assertEquals(result,'Test');
        String stringresult = dynamicFormService.convertResponse(formItem,result);
        System.assert(String.isNotBlank(stringresult));
        test.stopTest();
    }          
}