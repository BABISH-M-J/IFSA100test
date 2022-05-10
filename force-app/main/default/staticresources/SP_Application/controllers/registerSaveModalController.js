/**
* Register Save Modal Controller
* @file Register Save Modal Controller
* @copyright 2019 Institute for Study Abroad
* @author Brock Barlow <bbarlow@ifsa-butler.org>
* @version 2.0
*/
angular.module('app.controllers')
.controller('registerSaveModalController', function ($scope, $modalInstance, successful, programSelected) {
    $scope.successful = successful;
    $scope.programSelected = programSelected;

    $scope.close = function(){
        $modalInstance.close({
            successful: $scope.successful,
            programSelected: $scope.programSelected
        });
    }
});