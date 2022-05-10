/**
* Yes No Modal Controller Controller
* @file Yes No Modal Controller Controller
* @copyright 2019 Institute for Study Abroad
* @author Brock Barlow <bbarlow@ifsa-butler.org>
* @version 2.0
*/
angular.module('app.controllers')
.controller('yesNoModalController', function ($scope, $modalInstance, data)
{
    $scope.data = data;

    $scope.close = function () {
        $modalInstance.dismiss('cancel');
    };

    $scope.submit = function() {
        $modalInstance.close('yes');
    }
})