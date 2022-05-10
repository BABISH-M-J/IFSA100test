// SP_Login Page AngularJS Controller
// Created by: Brock Barlow
angular.module('app.controllers')
app.controller('errorModalController', function($scope, $modalInstance, viewModel, data) 
{
    // SP_Login_GenericLoginError
    // SP_Login_GenericRegError
    // SP_Login_ExistingUserCHError
    // SP_Login_ExistingUserSPError
    $scope.init = function(){
        $scope.errorName = data.errorName;
        $scope.errorMessage = viewModel.getViewModel().errorMessages[data.errorName];
        switch (data.errorName) {
            case 'SP_Login_GenericLoginError':
            case 'SP_Login_IncorrectPasswordError':
                $scope.errorType = 'Login';
                break;

            case 'SP_Login_GenericRegError':
            case 'SP_Login_ExistingUserCHError':
            case 'SP_Login_ExistingUserSPError':
                $scope.errorType = 'Registration';
                break;

            default:
                $scope.errorMessage = data.errorName;
                break;
        }
    }
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    }

    $scope.init();

});