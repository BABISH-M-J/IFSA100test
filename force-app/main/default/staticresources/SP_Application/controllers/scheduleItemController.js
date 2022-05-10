/**
 * Student Portal Schedule Details Modal Controller
 * @file Student Portal Schedule Details Modal Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('scheduleItemController', function($scope, $modalInstance, data)
{
    $scope.data = data;

    $scope.ok = function () {
        $modalInstance.close();
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
})