/**
 * Student Portal Tab Controller
 * @file Student Portal Tab Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('onsiteTabController', function($scope, $location, onsiteTabService) {
    
    onsiteTabService.getTabs().then(function(result){
        $scope.tabs = result;
    }, function(error){
        console.error('Unable to load On Site tabs');
    });

    $scope.switchTab = function(tab){
        $location.path(tab.page);
    }    
    
});