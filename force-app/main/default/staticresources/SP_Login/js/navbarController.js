// SP_Login Page AngularJS Controller
// Created by: Brock Barlow
angular.module('app.controllers')
app.controller('navbarController', function($scope, urlService, userService) 
{
    $scope.resourceURL = urlService.getResourceURL();
    $scope.isAuthenticated = userService.isAuthenticated();
})