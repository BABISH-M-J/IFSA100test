/**
 * Student Portal Switch Application Modal Controller
 * @file Student Portal Switch Application Modal Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('switchApplicationModalController', function ($scope, $modalInstance, data, $location) {
    $scope.data = data;
    $scope.setApplication = function (item)
    {
        portalRemotingMethods.setApplication(
        item,
        function(result, event) {
            if(result == true)
            {
                window.location.assign('#/');
                window.location.reload();
            }
        });
    }

    $scope.clickCreateBackup = function()
    {
        $modalInstance.dismiss('Start Backup Application');
        $location.path('/select');
    }
});