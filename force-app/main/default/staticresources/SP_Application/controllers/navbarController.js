/**
 * Student Portal Navbar Controller
 * @file Student Portal Navbar Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('navbarController', function($scope, $modal, urlService, viewModel, applicationService, $location, onsiteTabService) 
{
    onsiteTabService.getTabs().then(function(result){
        $scope.tabs = result;
    }, function(error){
        console.error('Unable to load On Site tabs');
    });
    $scope.urlService = urlService;
    $scope.viewModel = viewModel.getViewModel();
    if($scope.viewModel.customLogoId){
        $scope.brandImageURL = urlService.getPortalURL() + '/sfc/servlet.shepherd/version/download/' + $scope.viewModel.customLogoId;
    }
    else{
        $scope.brandImageURL = urlService.getBaseResourceURL() + '/images/IFSA_Navbar_Brand_Logo.png';
    }
    
    $scope.switchApplication = function() 
    {
        applicationService.switchApplication();
    }
    $scope.getFirstName = function(){
        return $scope.viewModel.studentPreferredName != null && $scope.viewModel.studentPreferredName != undefined ? $scope.viewModel.studentPreferredName : $scope.viewModel.studentFirstName
    }
    
});