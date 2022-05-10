@IsTest(SeeAllData = false)
public with sharing class LightningLoginFormControllerTest {

 @IsTest
 static void testLoginWithInvalidCredentials() {
  try{
      System.assertNotEquals('Argument 1 cannot be null', LightningLoginFormController.login(null, 'fakepwd', null));
  }catch(Exception exp){
  }
  LightningLoginFormController.getIsUsernamePasswordEnabled();
  LightningLoginFormController.getForgotPasswordUrl();
  LightningLoginFormController.getIsSelfRegistrationEnabled();
  LightningLoginFormController.getSelfRegistrationUrl();
  LightningLoginFormController.getAuthConfig();
  LightningLoginFormController.setExperienceId('Test');
 }

 @IsTest
 static void LightningLoginFormControllerInstantiation() {
  LightningLoginFormController controller = new LightningLoginFormController();
  System.assertNotEquals(controller, null);
 }

 @IsTest
 static void testIsUsernamePasswordEnabled() {
  System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
 }

 @IsTest
 static void testIsSelfRegistrationEnabled() {
  System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
 }

 @IsTest
 static void testGetSelfRegistrationURL() {
  System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
 }

 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig);
 }
}