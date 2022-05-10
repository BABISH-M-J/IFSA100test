/**
 * An apex page controller that exposes the change password functionality
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    
    public PageReference changePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }     
    
   	public ChangePasswordController() {}
}