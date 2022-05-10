/**
 * Student Portal On Site Learning Plan Page Controller
 * @file Student Portal On Site Learning Plan Page Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('onsiteLearningPlanController', function($scope, $modal, urlService, $filter, applicationItemService, viewModel, errorModalService) 
{
    $scope.urlService = urlService;
    $scope.activePage = 'LearningPlan';
    $scope.loading = true;
    $scope.viewModel = {
        applicationStatus: viewModel.getViewModel().applicationStatus,
        locked: viewModel.getViewModel().applicationStatus != 'On Site'
    }
    $scope.loadingItems = [
        {heading: '1. Academic goals', lines: [1,2,3]},
        {heading: '2. Personal goals', lines: [1,2,3]},
        {heading: '3. Professional development goals', lines: [1,2,3]},
        {heading: 'OPTIONAL: If you already know specific actions you plan to take to reach your goals, please list them below.', lines: [1,2,3,4]},
        {heading: 'OPTIONAL: Please share anything else about your goals. For example: timelines for accomplishing your goals, specific resources or guidance you plan to seek out on site, or obstacles that may stand between you and your achievement of goals.', lines: [1,2,3,4,5]}
    ];
    $scope.init = function(){
        var appItemsPromise = applicationItemService.getApplicationItemsPromise();
        appItemsPromise.then(function(result){
            var learningPlan = result.find(i => i.recordTypeName == 'Learning Plan');
            if(learningPlan)
            {
                $scope.getLearningPlan(learningPlan.id)
            }
            else
            {
                // Application does not have a learning plan
                $scope.hasLearningPlan = false;
                $scope.loading = false;
            }
        },
        function(result){
            console.log(result);
        });
    }

    $scope.getLearningPlan = function(appItemId)
    {
        var promise = applicationItemService.getApplicationItemDetails(appItemId);
        promise.then(function(result){
            $scope.viewModel = {
                learningPlan: result,
                applicationStatus: viewModel.getViewModel().applicationStatus,
                locked: viewModel.getViewModel().applicationStatus != 'On Site'
            };
            $scope.viewModel.learningPlan.isLocked = true;
            // Copy current values to new variables to track what is currently saved in Salesforce with new updates
            $scope.learningPlan = angular.copy($scope.viewModel.learningPlan);
            $scope.hasLearningPlan = true;
            $scope.loading = false;
        },
        function(result){
            var promise = errorModalService.openErrorModal('An Error has occured loading your applicaiton item', 'There was an error loading your your applicaiton item. Please try again. If you continue to have problems, contact IFSA.');
            promise.then(function(result){
                $scope.loading = false;
            //window.location.assign('#/');
            });
        });
    }

    $scope.updateLearningPlan = function() {
        $scope.isSaving = true;
        //$scope.$apply();
        var promise = applicationItemService.submitApplicationItem(angular.toJson($scope.viewModel.learningPlan),'','','');
        promise.then(function(result){
            alert("Saved Successfully!");
            $scope.getLearningPlan($scope.viewModel.learningPlan.id)
            $scope.viewModel.learningPlan.isLocked = true;
            $scope.learningPlan = angular.copy($scope.viewModel.learningPlan);
            $scope.isSaving = false;
        },
        function(result){
            alert("Error - Save Unsuccessful!");
            $scope.isSaving = false;
        });
    }
    $scope.init();
});