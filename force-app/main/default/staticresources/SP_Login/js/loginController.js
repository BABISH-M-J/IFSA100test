// SP_Login Page Login AngularJS Controller
// Created by: Brock Barlow
angular.module('app.controllers')
app.controller('loginController', function($scope, viewModel, urlService, userService, errorService, $http, $routeParams) 
{
    $scope.resourceURL = urlService.getResourceURL();
    $scope.viewModel = viewModel.getViewModel();
    if($routeParams.email){
        $scope.viewModel.email = $routeParams.email;
    }

    // Method for logging in
    $scope.login = function () {
        $scope.saving = true;
        $scope.alerts = [];
        studentLoginController.login(
            angular.toJson($scope.viewModel),
            function(result) {
                $scope.saving = false;
                if(result){
                    if(result == 'SP_Login_IncorrectPasswordError' || result == 'SP_Login_ExistingUserAPError') {
                        errorService.openErrorModal(result);
                    }
                    else if(result == 'SP_Login_ExistingUserCHError'){
                        errorService.openExistingUserModal({
                            color: 'aqua',
                            header: 'Hello again!',
                            imageUrl: $scope.resourceURL + '/images/PopUpCharacters-01.png',
                            body: viewModel.getViewModel().errorMessages[result],
                            url: '/chart/',
                            linkText: 'Take me to CHART!',
                            showClose: true,
                            buttonColor: 'ifsa-lt-aqua'
                        });
                    }
                    else if(result.indexOf('SP_Login_ExistingUserSPError') !== -1){
                        values = result.split(',');
                        errorService.openExistingUserModal({
                            color: 'blue',
                            header: 'Welcome Back!',
                            imageUrl:  urlService.getResourceURL() + '/images/PopUpCharacters-03.png',
                            body: 'You\'ve already started an app, Click the button below to contine working on it!',
                            url: values[1],
                            linkText: 'Log In',
                            buttonColor: 'ifsa-lt-blue'
                        })
                    }
                    else if(result == 'SP_Login_ExistingUserGWError'){
                        errorService.openExistingUserModal({
                            color: 'clover',
                            header: 'Have we met before?',
                            imageUrl: $scope.resourceURL + '/images/PopUpCharacters-02.png',
                            body: viewModel.getViewModel().errorMessages[result],
                            url: 'https://www.ifsa-butler.org',
                            linkText: 'Show me the Way(finder)!',
                            showClose: true,
                            buttonColor: 'ifsa-lt-clover'
                        })
                    }
                    else if($scope.viewModel.gwUser){
                        var decoded = result.replace(/amp;/g, '');
                        $http.get(decoded).then(function(response){
                            if($scope.viewModel.programId){
                                window.location.assign('/studentportal/SP_Login?ProgramId=' + $scope.viewModel.programId);
                            }
                            else{
                                window.location.assign('/studentportal/SP_Login');
                            }
                        });
                    }
                    else if($scope.viewModel.chUser){
                        var decoded = result.replace(/amp;/g, '');
                        $http.get(decoded).then(function(response){
                            if($scope.viewModel.programId){
                                window.location.assign('/chart/SP_Login?ProgramId=' + $scope.viewModel.programId);
                            }
                            else{
                                window.location.assign('/chart/SP_Login');
                            }
                        });
                    }
                    else {
                        var decoded = result.replace(/amp;/g, '');
                        window.location.assign(decoded);
                    }
                } else {
                    //console.log('Method failed to return a result.');
                }
                $scope.$apply();
            }
        );
    }

    $scope.checkEmail = function() {
        if($scope.viewModel.email){
            $scope.checkingEmail = true;
            $scope.message = null;
            $scope.header = null;
            $scope.status = null;
            userService.checkForExistingUser($scope.viewModel.email).then(function(result){
                // No user found
                $scope.checkingEmail = false;
                $scope.message = 'Could not find a user with that email address';
                $scope.header = 'Error';
                $scope.status = 'error';
            }, function(error){
                // Found user
                $scope.checkingEmail = false;
                if(error){
                    if(error.Contact.First_Access_Student_Portal__c){
                        $scope.message = 'Found an account with a matching email address. Click "Reset Password" to continue.';
                        $scope.status = 'success';
                        $scope.header = 'Success';
                    }
                    else if(error.Contact.First_Access_CHART__c){
                        $scope.message = 'Found an account for CHART, please try to login <a href="/chart/CH_Login">here</a>';
                        $scope.status = 'error';
                        $scope.header = 'Error';
                    }
                    else if(error.Contact.First_Access_Global_Wayfinder__c){
                        $scope.message = 'Found an account for CHART, please try to login <a href="www.ifsa-butler.org">here</a>';
                        $scope.status = 'error';
                        $scope.header = 'Error';
                    }
                    else {
                        $scope.message = 'Found an account but it is not permitted in IFSA Student Portal, please contact IFSA for assistance';
                        $scope.status = 'error';
                        $scope.header = 'Error';
                    }
                }
                else{
                    $scope.message = 'An unexpected error occurred, please refresh the page and try again. If you continue to receive this error please contact IFSA';
                    $scope.status = 'error';
                    $scope.header = 'Error';
                }
            })
        }
    }

    $scope.forgotPassword = function(){
        $scope.message = null;
        $scope.header = null;
        $scope.status = null;
        userService.resetPassword($scope.viewModel.email).then(function(result){
            // Success
            $scope.message = 'Please check your inbox for an email with a link to reset your password';
            $scope.status = 'success';
            $scope.header = 'Success';
            $scope.hideReset = true;
        }, function(error){
            // Error
            $scope.message = 'An unexpected error occurred, please refresh the page and try again. If you continue to receive this error please contact IFSA';
            $scope.status = 'error';
            $scope.header = 'Error';
        })
    }
});