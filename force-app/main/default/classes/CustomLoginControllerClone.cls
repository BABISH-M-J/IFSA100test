global with sharing class CustomLoginControllerClone {
    global String username {get; set;}
    global String password {get; set;}

    global PageReference login() {
        String startUrl = 'https://ifdevarea.wpengine.com';

        return Site.login(username, password, startUrl);
    }
}