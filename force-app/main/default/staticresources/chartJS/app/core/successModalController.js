/**
 * Chart Success Modal AngularJS Controller
 * @file Chart Success Modal AngularJS Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('successModalController', function($scope, $uibModalInstance, data)
{
    console.log('Modal opened at: ' + new Date());
    $scope.message = data.message;

    $scope.closeModal = function()
    {
        $uibModalInstance.dismiss('Closed');
    }
});