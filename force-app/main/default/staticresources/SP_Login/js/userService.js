// Student Portal URL Service
// Created by: Brock Barlow
angular.module('app.services')
.service('userService', function(viewModel, $q, errorService, urlService) {
    var self = this;

    this.isAuthenticated = function(){
        let vm = viewModel.getViewModel();
        return vm.contactId != null && vm.contactId != undefined;
    }

    this.checkForExistingUser = function(emailAddress) {
        let deferred = $q.defer();

        studentLoginController.checkForExistingUser(
            emailAddress,
            function(result, event){
                if(event.status && !result){
                    deferred.resolve(event.status);
                }
                else{
                    deferred.reject(result);
                    if(result){
                        if(result.Contact.First_Access_Student_Portal__c){
                            self.existingUser('sp', result.Id, emailAddress);
                        }
                        else if(result.Contact.First_Access_CHART__c){
                            self.existingUser('ch', result.Id, emailAddress);
                        }
                        else if(result.Contact.First_Access_Global_Wayfinder__c){
                            self.existingUser('gw', result.Id, emailAddress);
                        }
                        else {
                            errorService.openErrorModal('SP_Login_GenericRegError');
                        }
                    }
                    else{
                        errorService.openErrorModal('SP_Login_GenericRegError');
                    }
                }
            }
        )

        return deferred.promise;
    }

    this.resetPassword = function(emailAddress) {
        let deferred = $q.defer();

        studentLoginController.resetPassword(
            emailAddress,
            function(result, event){
                if(event.status){
                    deferred.resolve(event.status);
                }
                else{
                    deferred.reject(result);
                }
            }
        )

        return deferred.promise;
    }

    this.existingUser = function(val, userId, emailAddress) {
        let modalOptions;
        switch (val) {
            case 'ch':
                modalOptions = {
                    color: 'aqua',
                    header: 'Hello again!',
                    imageUrl:  urlService.getResourceURL() + '/images/PopUpCharacters-01.png',
                    body: 'You\'ve already used this email to login to CHART. Please follow the button below to start your app through CHART',
                    url: `/chart/SP_Login?UserId=${userId}#/login`,
                    linkText: 'Take me to CHART!',
                    buttonColor: 'ifsa-lt-aqua'
                }
                break;
            case 'sp':
                modalOptions = {
                    color: 'blue',
                    header: 'Welcome Back!',
                    imageUrl:  urlService.getResourceURL() + '/images/PopUpCharacters-03.png',
                    body: 'You\'ve already started an app, Click the button below to contine working on it!',
                    url: `#/login/${emailAddress}`,
                    linkText: 'Log In',
                    buttonColor: 'ifsa-lt-blue'
                }
                break;
            case 'gw':
                modalOptions = {
                    color: 'clover',
                    header: 'Have we met before?',
                    imageUrl:  urlService.getResourceURL() + '/images/PopUpCharacters-02.png',
                    body: 'It looks like you\'ve used this email to sign in to Global Wayfinder. To start your app please login through the button below.',
                    url: `/studentportal/SP_Login?UserId=${userId}`,
                    linkText: 'Show me the Way(finder)!',
                    buttonColor: 'ifsa-lt-clover'
                }
                break;            
            default:
                break;
        }
        errorService.openExistingUserModal(modalOptions);
    }
});