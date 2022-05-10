angular.module('app.controllers')
.controller('housingModalController', function ($scope, $modalInstance, data, studentsService) {
    $scope.data = data;
    if($scope.data.housingAssignment){
        if($scope.data.housingAssignment.Attachments && $scope.data.housingAssignment.Attachments.length){
            $scope.selectedId = $scope.data.housingAssignment.Attachments[0].Id;
        }
        $scope.data.housingOption = studentsService.getHousingOption($scope.data.housingAssignment.Housing_Option__c);
    }
    else if($scope.data.housingOptions){
        $scope.activeItem = 0;
    }

    $scope.selectOption = function(index){
        $scope.activeItem = index;
    }

    $scope.selectImage = function(imageId){
        $scope.selectedId = imageId;
    }

    // Close modal
    $scope.exit = function() {
        $modalInstance.dismiss('ok');
    }
});