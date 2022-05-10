@RestResource(urlMapping='/ForgotPassword/*')
global class ForgotPassword{
    @HttpPost
    global static string ResetPassword(String username, String authorizationKey,string emailTemplateName){
        system.debug('inside goo monk');
        if(Label.CreateUserAuthKey != authorizationKey){
            return 'Invalid Authorization Key';
        } 
        List<User> users = new List<User>();
        users = Database.Query('SELECT Id, Name FROM User WHERE Email  =: username');        
        for(User u : users){
            system.resetPasswordWithEmailTemplate(u.Id, true,emailTemplateName);          
        }
        if(users.size() > 0){
            return 'success';
        }else{
            return 'user does not exist.';
        }
    }
    public Pagereference redirect(){
        string url = 'https://ifdevarea.wpengine.com/';
        Pagereference pr = new Pagereference(url);
        pr.setRedirect(true);
        return pr;
    }
}