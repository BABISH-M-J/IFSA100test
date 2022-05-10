angular.module('app.controllers')
.controller('confirmModalController', function ($scope, $modalInstance, params) {
    $scope.successful = params.successful;
    $scope.afterSave = params.afterSave;
    $scope.message = params.message;
    $scope.exit = function() {
        $modalInstance.dismiss('ok');
    }
    $scope.cancel = function() {
        $modalInstance.dismiss('canceled');
    }
    $scope.save = function(val) {
        $modalInstance.close(val);
    }
});