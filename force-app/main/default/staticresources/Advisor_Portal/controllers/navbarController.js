/**
 * Advisor Portal Navbar Controller
 * @file Advisor Portal Navbar Controller
 * @copyright 2020 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('navbarController', function($scope, $modal, urlService, viewModel) 
{
    $scope.urlService = urlService;
    $scope.viewModel = viewModel.getViewModel();
    $scope.brandImageURL = urlService.getBaseResourceURL() + '/images/IFSA_Navbar_Brand_Logo.png';    
});