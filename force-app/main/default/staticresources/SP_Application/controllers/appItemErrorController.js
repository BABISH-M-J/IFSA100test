/**
 * Student Portal Application Item Error Controller
 * @file Student Portal Application Item Error Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('appItemErrorController', function ($scope, $modalInstance, data) 
{
    
    $scope.data = data;

    $scope.submit = function() {
        $modalInstance.close('yes');
    }
});