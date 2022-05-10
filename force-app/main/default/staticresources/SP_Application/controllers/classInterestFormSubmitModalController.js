/**
 * Student Portal Course Interest Form Submit Modal Controller
 * @file Student Portal Course Interest Form Submit Modal Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('classInterestFormSubmitModalController', function ($scope, $modalInstance)
{
    $scope.close = function (value) {
        if(value == 'no'){
            $modalInstance.dismiss('cancel');
        }
        else if(value == 'yes'){
            $modalInstance.close(true);
        }
    }
})