angular.module('app.controllers')
.controller('profileController', function($scope, $modal, urlService, viewModel, profileService, $log) 
{
    $scope.isSubmitting = false;
    $scope.loading = true;
    profileService.getProfileViewModel().then(function(result){
        $scope.viewModel = result;
        $scope.loading = false;
    }, function(error){
        $log.error(error);
        $scope.loading = false;
    });
    
    $scope.submit = function() {
        $scope.isSubmitting = true;
        profileService.saveProfile($scope.viewModel).then(function(result){
            $scope.isSubmitting = false;
        }, function(error){
            $scope.isSubmitting = false;
            $log.error(error);
        });
    }
})