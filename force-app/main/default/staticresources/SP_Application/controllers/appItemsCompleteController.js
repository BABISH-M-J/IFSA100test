/**
 * Student Portal Application Item Complete Controller
 * @file Student Portal Application Item Complete Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('appItemsCompleteController', function($scope, $modalInstance) {
    $scope.ok = function () {
        $modalInstance.dismiss('ok');
    };
});