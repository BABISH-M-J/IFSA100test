angular.module('app.controllers')
.controller('approvedProgramDetailsModalController', function ($scope, $modalInstance, data, semicolonFilter) {
    $scope.data = data;
    $scope.loading = true;
    //$scope.$apply();
    // Callout to Salesforce to get billing arrangement
    advisorPortalController.getBillingArrangements(
        data.programId,
        data.accountId,
        function(result, event) {
            $scope.processBillingArrangements(result);
        }
    );
    // Processes Billing Arrangements
    $scope.processBillingArrangements = function(result) {
        if(result)
        {
            $scope.billingArrangements = result;
            $scope.loading = false;
            $scope.$apply();
        }
    }
    // Close modal
    $scope.exit = function() {
        $modalInstance.dismiss('ok');
    }
});