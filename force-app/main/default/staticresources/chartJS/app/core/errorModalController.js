/**
 * Chart Error Modal AngularJS Controller
 * @file Chart Error Modal AngularJS Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('errorModalController', function($scope, $uibModalInstance, data, viewModel)
{
    console.log('Modal opened at: ' + new Date());
    $scope.data = data;

    $scope.closeModal = function()
    {
        $uibModalInstance.dismiss('Closed');
    }
});