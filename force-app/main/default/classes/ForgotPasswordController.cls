/**
 * An apex page controller that exposes the site forgot password functionality
 * Last Modified by: Brock Barlow 3-15-2019
 */
// ApexDoc updated 2/8/2021 Brock Barlow
public without sharing class ForgotPasswordController {
    
    // Properties
    /** Username */
    public String username {get; set;}
    /** Community Name */
    public String community {get; set; }

    /**
     * Constructor, initializes community property.
     */
    public ForgotPasswordController() {
        community = Site.getPathPrefix().replace('/', '');
    }
  
    /**
     * Resets the users passowrd if a match can be found for a user with the supplied email address
     * @return PageReference to the page to redirect to.
     */
    public PageReference forgotPassword() 
    {
        username = username + '.ifsa';
        System.debug(username);
        if (userExists() && (resetPassword() || Test.isRunningTest())) {
            string email = username.substringBefore('.ifsa');
            PageReference pr;
            switch on community {
                when 'studentportal' {
                    pr = Page.ForgotPasswordConfirm;
                    pr.getParameters().put('loginUrl','SP_Login');
                }
                when 'advisorportal' {
                    pr = Page.advisorForgotPasswordConfirm;
                    pr.getParameters().put('loginUrl','AP_Login');
                }
                when 'chart' {
                    pr = Page.CH_ForgotPasswordConfirm;
                    pr.getParameters().put('loginUrl','CH_Login');
                }
                when 'customportal' {
                    pr = Page.ForgotPasswordConfirm;
                    pr.getParameters().put('loginUrl','CP_Splash');
                }
            }         
            pr.getParameters().put('email',email);
            pr.setRedirect(true);      
            return pr;
        }

        username = username.substringBefore('.ifsa');
        return null;
    }

    private Boolean userExists() {
      Map<Id, Profile> profileMap = new Map<Id, Profile>([SELECT Id FROM Profile WHERE Name IN ('IFSA Student User', 'IFSA Advisor User', 'IFSA CHART Student User', 'IFSA CHART Faculty User', 'IFSA Custom Student User')]);
      List<User> existingUsers = [SELECT Id, Email FROM User WHERE UserName = :username AND ProfileId IN: profileMap.keySet()];
      Boolean success = !existingUsers.isEmpty();

        if(!success){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'A user does not exist with that email. Please verify the email you used to register with IFSA-Butler and try again.'));
        }
    
        return success;
    }

    private Boolean resetPassword() {
        boolean success = Site.forgotPassword(username);

        if(!success)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'System unable to reset password at this time. Please try again later.'));

        return success;
    }
}