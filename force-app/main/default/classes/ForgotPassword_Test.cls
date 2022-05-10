@Istest
public  class ForgotPassword_Test {
    public static testmethod   void testForgotPasswordController() {
          ForgotPassword controller = new ForgotPassword();     
    	ForgotPassword.ResetPassword('test@salesforce.com', '36345405743753840177', 'test');
        controller.redirect();
        
    }
}