// SP_Login Page AngularJS Controller
// Created by: Brock Barlow
angular.module('app.controllers')
app.controller('existingUserModalController', function($scope, $modalInstance, viewModel, data) 
{
    $scope.init = function(){
        $scope.modal = data;
    }
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    }
    $scope.close = function () {
        $modalInstance.close(data.url);
    }

    $scope.init();

});