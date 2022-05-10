/**
 * Student Portal Profile Controller
 * @file Student Portal Profile Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('profileController', function($scope, $modal, urlService, viewModel, contactInfoService, errorModalService)
{
    
    $scope.viewModel = {
        studentFirstName: viewModel.getViewModel().studentFirstName,
        studentLastName: viewModel.getViewModel().studentLastName
    }
    $scope.init = function(){
        $scope.message = '';
        $scope.isSuccess = true;
        $scope.submitted = false;
        $scope.hasChanges = false;
        $scope.isEditingMailing = false;
        $scope.isEditingOther = false;
        $scope.isEditingBilling = false;
        var promise = contactInfoService.getProfileInfo();
        promise.then(function(result){
            $scope.viewModel = result;
            $scope.viewModel.studentFirstName = viewModel.getViewModel().studentFirstName;
            $scope.viewModel.studentLastName = viewModel.getViewModel().studentLastName;
        }, function(result){
            // Load error modal
            var promise = errorModalService.openErrorModal('An Error has occured loading your profile information', 'There was an error loading your your profile information. Please try again. If you continue to have problems, contact IFSA.');
            promise.then(function(result){
                $scope.loading = false;
                window.location.assign('#/');
            });
        })
    }

    //Function for saving
    $scope.saveData = function() {
        $scope.submitted = true;
        var promise = contactInfoService.updateProfileInfo($scope.viewModel);
        promise.then(function(result) {
                $scope.processSaveResult(result);
        }, function(result){
            $scope.processSaveResult(result);
        });
    }

    $scope.processSaveResult = function(result) {
        $scope.submitted = false;
        $scope.isSuccess = result.isSuccess;
        if(result.isSuccess) {
            $scope.hasChanges = false;
            $scope.isEditingMailing = false;
            $scope.isEditingOther = false;
            $scope.isEditingBilling = false;
        }
        $scope.message = result.message;
    }
    //When the user closes the save message
    $scope.dismissSaveMessage = function() {
        $scope.message = '';
    }

    //When the user clicks an edit link note that there are changes
    $scope.noteChange = function() {
        $scope.hasChanges = true;
    }

    //When the user clicks edit on their home address
    $scope.editMailingAddress = function() {
        $scope.noteChange();
        $scope.isEditingMailing = true;
        $scope.isEditingBilling = false;
        $scope.isEditingOther = false;
    }

    //When the user clicks edit on their school address
    $scope.editOtherAddress = function() {
        $scope.noteChange();
        $scope.isEditingMailing = false;
        $scope.isEditingBilling = false;
        $scope.isEditingOther = true;
    }

    //When the user clicks edit on their billing address
    $scope.editBillingAddress = function() {
        $scope.noteChange();
        $scope.isEditingMailing = false;
        $scope.isEditingBilling = true;
        $scope.isEditingOther = false;
    }

    $scope.cancelEdit = function() {
        $scope.isEditingMailing = false;
        $scope.isEditingBilling = false;
        $scope.isEditingOther = false;
        $scope.submitted = false;
        $scope.hasChanges = false;
    }

    $scope.init();
});