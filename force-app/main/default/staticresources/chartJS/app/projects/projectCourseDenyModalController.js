/**
 * Chart Project Details Page AngularJS Controller
 * @file Chart Project Details Page AngularJS Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('projectCourseDenyModalController', function($scope, $uibModalInstance, data, viewModel)
{
    console.log('Modal opened at: ' + new Date());
    $scope.data = data;
    $scope.data.originalStatus = data.status;
    console.log('Original Status: ' + $scope.data.originalStatus);
    $scope.deniedReasons = viewModel.getViewModel().ceDeniedReasons;

    $scope.save = function()
    {
        $scope.data.status = 'Not a Match';
        $scope.data.changed = true;
        $uibModalInstance.close($scope.data);
    }
    $scope.closeModal = function()
    {
        $scope.data.deniedReason = null;
        $scope.data.deniedReasonOther = null;
        $scope.data.changed = false;
        $scope.data.status = $scope.data.originalStatus;
        console.log('Status: ' + $scope.data.status + ', Changed: ' + $scope.data.changed);
        $uibModalInstance.dismiss($scope.data);
        // $uibModalInstance.dismiss('cancel');
    }
});