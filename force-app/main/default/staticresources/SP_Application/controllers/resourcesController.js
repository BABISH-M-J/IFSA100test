/**
 * Student Portal Resources Controller
 * @file Student Portal Resources Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('resourcesController', function($scope, $modal, urlService, viewModel, resourcesService, dateService, errorModalService)
{
    $scope.urlService = urlService;
    $scope.loading = true;
    $scope.init = function(){
        var isCustom = viewModel.getViewModel().isCustom
        if(viewModel.getViewModel().isDropped)
        {
            window.location.assign('#/social');
        }
        else if(!viewModel.getViewModel().profileCompleted && !isCustom)
        {
            window.location.assign('#/register');
        }
        else if(!viewModel.getViewModel().isProgramSelected)
        {
            window.location.assign('#/select');
        }
        if(isCustom && !viewModel.getViewModel().showAccountTab){
            $scope.hideProgDueDate = true;
        }
        
        var promise = resourcesService.getApplicationResources();
        promise.then(function(result){
            $scope.viewModel = result;
            $scope.viewModel.customResourcesText = viewModel.getViewModel().customResourcesText;
            // Convert program dates
            // There is an issue where dates from SF are showing up incorrectly
            // This fixes this issue
            $scope.viewModel.startDate != null ? $scope.viewModel.startDate = dateService.convertDate($scope.viewModel.startDate) : null;
            $scope.viewModel.endDate != null ? $scope.viewModel.endDate = dateService.convertDate($scope.viewModel.endDate) : null;
            $scope.viewModel.ifsaOrientationStartDate != null ? $scope.viewModel.ifsaOrientationStartDate = dateService.convertDate($scope.viewModel.ifsaOrientationStartDate) : null;
            $scope.viewModel.ifsaOrientationEndDate != null ? $scope.viewModel.ifsaOrientationEndDate = dateService.convertDate($scope.viewModel.ifsaOrientationEndDate) : null;
            $scope.viewModel.universityOrientationStarts != null ? $scope.viewModel.universityOrientationStarts = dateService.convertDate($scope.viewModel.universityOrientationStarts) : null;
            $scope.viewModel.universityOrientationEnds != null ? $scope.viewModel.universityOrientationEnds = dateService.convertDate($scope.viewModel.universityOrientationEnds) : null;
            $scope.viewModel.suggestedDepartureFromUS != null ? $scope.viewModel.suggestedDepartureFromUS = dateService.convertDate($scope.viewModel.suggestedDepartureFromUS) : null;
            $scope.viewModel.programDueDate != null ? $scope.viewModel.programDueDate = dateService.convertDate($scope.viewModel.programDueDate) : null;
            $scope.viewModel.startOfSecondTerm != null ? $scope.viewModel.startOfSecondTerm = dateService.convertDate($scope.viewModel.startOfSecondTerm) : null;
            $scope.viewModel.moveIntoTermHousing != null ? $scope.viewModel.moveIntoTermHousing = dateService.convertDate($scope.viewModel.moveIntoTermHousing) : null;
            $scope.viewModel.applicationDeadline != null ? $scope.viewModel.applicationDeadline = dateService.convertDate($scope.viewModel.applicationDeadline) : null;
            $scope.viewModel.classesBegin != null ? $scope.viewModel.classesBegin = dateService.convertDate($scope.viewModel.classesBegin) : null;
            $scope.viewModel.classesEnd != null ? $scope.viewModel.classesEnd = dateService.convertDate($scope.viewModel.classesEnd) : null;
            $scope.viewModel.assessmentsBegin != null ? $scope.viewModel.assessmentsBegin = dateService.convertDate($scope.viewModel.assessmentsBegin) : null;
            $scope.viewModel.assessmentsEnd != null ? $scope.viewModel.assessmentsEnd = dateService.convertDate($scope.viewModel.assessmentsEnd) : null;
            $scope.viewModel.examBegin != null ? $scope.viewModel.examBegin = dateService.convertDate($scope.viewModel.examBegin) : null;
            $scope.viewModel.examBegin != null ? $scope.viewModel.examBegin = dateService.convertDate($scope.viewModel.examBegin) : null;
            $scope.viewModel.groupTransferToHostCity != null ? $scope.viewModel.groupTransferToHostCity = dateService.convertDate($scope.viewModel.groupTransferToHostCity) : null;
            
            // Iterate over schedule records to convert thier dates
            if($scope.viewModel.scheduleList.length){
                for(i=0;i < $scope.viewModel.scheduleList.length; i++){
                    $scope.viewModel.scheduleList[i].startDate != null ? $scope.viewModel.scheduleList[i].startDate = dateService.convertDate($scope.viewModel.scheduleList[i].startDate) : null;
                    $scope.viewModel.scheduleList[i].endDate != null ? $scope.viewModel.scheduleList[i].endDate = dateService.convertDate($scope.viewModel.scheduleList[i].endDate) : null;
                }
            }

            $scope.showDates = (
				$scope.viewModel.startDate || 
				$scope.viewModel.endDate ||
				$scope.viewModel.ifsaOrientationStartDate ||
				$scope.viewModel.ifsaOrientationEndDate ||
				$scope.viewModel.universityOrientationStarts ||
				$scope.viewModel.universityOrientationEnds ||
				$scope.viewModel.suggestedDepartureFromUS ||
				$scope.viewModel.programDueDate ||
				$scope.viewModel.startOfSecondTerm ||
				$scope.viewModel.arrivalWindowStartTime ||
				$scope.viewModel.arrivalWindowEndTime ||
				$scope.viewModel.moveIntoTermHousing ||
				$scope.viewModel.classesBegin ||
				$scope.viewModel.classesEnd ||
				$scope.viewModel.assessmentsBegin ||
				$scope.viewModel.assessmentsEnd ||
				$scope.viewModel.examBegin ||
				$scope.viewModel.examEnd ||
				$scope.viewModel.groupTransferToHostCity
            );
            
            $scope.tabs = [];
            $scope.tabs.push({title: "Program Details", templateUrl: urlService.getBaseResourceURL() + '/views/pages/resources-dates.html'});
            if(!isCustom){
                $scope.tabs.push({title: "Cost of Attendance", templateUrl: urlService.getBaseResourceURL() + '/views/pages/resources-costs.html'});
            }
            $scope.tabs.push({title: "Helpful Documents and Links", templateUrl: urlService.getBaseResourceURL() + '/views/pages/resources-docs.html'});

            $scope.oneAtATime = true;
            $scope.loading = false;
        }, function(result){
            // Load error modal
            var promise = errorModalService.openErrorModal('An Error has occured loading your applicaiton resources', 'There was an error loading your your applicaiton resources. Please try again. If you continue to have problems, contact IFSA.');
            promise.then(function(result){
                $scope.submittingData = false;
                window.location.assign('#/');
            });
        })
    }

    $scope.open = function (item) {

        var modalInstance = $modal.open({
                    animation: true,
                    templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/HTML_ScheduleModal.html',
                    size: 'lg',
                    resolve: {
                        data: item
                    },
                    controller: 'scheduleItemController'
                });
                modalInstance.opened.then(function(){
                    setTimeout(function(){resize();}, 500);
                });	
        };

    $scope.init();
});