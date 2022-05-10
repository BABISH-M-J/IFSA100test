/**
* Student Portal Program Details Modal Controller
* @file Student Portal Program Details Modal Controller
* @copyright 2019 Institute for Study Abroad
* @author Brock Barlow <bbarlow@ifsa-butler.org>
* @version 2.0
*/
angular.module('app.controllers')
.controller('programDetailsModalController', function ($scope, $modalInstance, data, sanitizer, selectService) {
    $scope.data = data;
    $scope.data.result.displayName = sanitizer.sanitize($scope.data.result.displayName);
    $scope.data.result.description = sanitizer.sanitize($scope.data.result.description);
    if($scope.data.result.hasOptions == 'true')
    {
        $scope.data.result.hasOptions = true;
        portalRemotingMethods.getProgramOptions(
            $scope.data.result.programTermId,
            function(result, event) {                        
                $scope.data.result.programOptions = result;
                
                $scope.$apply();
            }
        );
    }
    else
    {
        $scope.data.result.hasOptions = false;
    }
    $scope.submittingData = false;
    $scope.confirm = function (programTermId) {
        $scope.submittingData = true;
        selectService.createApplication(programTermId.toString(), $scope.data.createNewApp)
            .then(function(result){
                $modalInstance.close('success');
            }, function(error){
                $modalInstance.close('error');
        });
    };
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
})
.controller('programSelectedModalController', function ($scope, $modalInstance, successful) {
    $scope.successful = successful;

    $scope.clickOk = function(){
        if($scope.successful){
            $modalInstance.close('Application Created');
        }
        else{
            $modalInstance.dismiss('ok');
        }
    }
});