angular.module('app.controllers')
.controller('applicationController', function ($scope, $modalInstance, $modal, data, urlService) {
    $scope.data = data;
    $scope.tab = 'Application Items';
    $scope.goToPersonal = function() {
        $scope.tab = 'Personal Data';
    }
    $scope.goToAppItems = function() {
        $scope.tab = 'Application Items';
    }
    $scope.viewAppItem = function (item) {
        if(item.isComplete && !item.isLoading){
            item.isLoading = true;
            portalRemotingMethods.getApplicationItemDetails(
                item.id,
                function (result, event)
                {
                    if(result && !$scope.data.CustomApplication)
                    {
                        var modalInstance = $modal.open({
                            animation: true,
                            size: 'lg',
                            templateUrl: urlService.getSPResourceURL() + '/views/shared/modals/HTML_AppItemModal.html',
                            resolve: {
                                data: result
                            },
                            controller: 'appItemController'
                        });
                        modalInstance.opened.then(function(){
                            setTimeout(function(){resize();item.isLoading = false;}, 500);
                        });
                    }
                }
            );
        }
    }
    $scope.exit = function() {
        $modalInstance.dismiss('ok');
    }
});