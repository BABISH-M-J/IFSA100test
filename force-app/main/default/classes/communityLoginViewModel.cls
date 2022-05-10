/**
 * Base class for <<chartLoginViewModel>> and <studentLoginViewModel>>
 */
public abstract class communityLoginViewModel extends portalBaseViewModel
{
    /**
     * User's email address
     */
    public String email {get;set;}
    /**
     * User's password
     */
    public String password {get;set;}
    /**
     * User's first name
     */
    public String firstName {get;set;}
    /**
     * User's last name
     */
    public String lastName {get;set;}
    /**
     * User type
     */
    public String userType {get;set;}
    /**
     * User's phone number
     */
    public String phone {get;set;}
}