// SP_Login Page AngularJS Controller
// Created by: Brock Barlow
angular.module('app.controllers')
app.controller('mainController', function($scope, viewModel, urlService) 
{
    $scope.alerts = [];
    $scope.resourceURL = urlService.getResourceURL();
    $scope.viewModel = viewModel.getViewModel();

});