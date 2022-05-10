/**
 * Student Portal On Site Trips Modal Controller
 * @file Student Portal On Site Trips Modal Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Jay Holt <jholt@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('paIntroVideoModalController', function ($scope, $sce, $modalInstance, data)
{
    $scope.data = data;
    $scope.data.paIntroVideo = $sce.trustAsResourceUrl($scope.data.paIntroVideo + '?autoplay=1&controls=0&rel=0&modestbranding=1');

    $scope.close = function () {
        $modalInstance.dismiss('cancel');
    };

});