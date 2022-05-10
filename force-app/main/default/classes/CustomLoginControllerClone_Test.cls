@isTest
public without sharing class CustomLoginControllerClone_Test {
    public static testMethod void testInstance(){
        CustomLoginControllerClone custloginObj=new CustomLoginControllerClone();
        custloginObj.username='Test';
        custloginObj.password='Test@1234';
        Test.startTest();
        custloginObj.login();
        Test.stopTest();
    }
  
}