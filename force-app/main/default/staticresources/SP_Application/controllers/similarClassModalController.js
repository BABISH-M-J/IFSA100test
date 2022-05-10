/**
 * Student Portal On Site Trips Modal Controller
 * @file Student Portal On Site Trips Modal Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Jay Holt <jholt@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('similarClassModalController', function ($scope, $modalInstance, viewModel, data, classInterestService, errorModalService, courseRegService)
{
    $scope.data = data;
    $scope.init = function(){
        
    }

    $scope.close = function () {
        $modalInstance.dismiss('cancel');
    };

    $scope.dismissMsg = function(){
        $scope.msgDismissed = true;
    };

    $scope.submitSelection = function() {
        if($scope.selectedItem){
            $modalInstance.close($scope.selectedItem);   
        }
    }
    $scope.submitNewClass = function() {
        $modalInstance.dismiss('Use Course');
    }

    $scope.selectClass = function(selectedClass) {
        
        if($scope.selectClass){
            $modalInstance.close(selectedClass);
        }
        
        /*
        let currentValue = selectedClass.selected;
        for (let index = 0; index < $scope.data.courses.length; index++) {
            const element = $scope.data.courses[index];
            element.selected = false;
        }
        selectedClass.selected = !currentValue;
        if(selectedClass.selected){
            $scope.selectedItem = selectedClass;
        }
        */
    }

    $scope.init();
});