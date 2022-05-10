angular.module('app.controllers')
.controller('studentsController', function($scope, $modal, urlService, viewModel, studentsService, $log) 
{
    $scope.isSearching = false;
    $scope.appDetailsURL = urlService.getBaseResourceURL() + '/views/shared/HTML_ApplicationDetails.html'
    studentsService.getStudentsViewModel().then(function(result){
        $scope.viewModel = result;
        $scope.viewModel.searchString = '';
        $scope.viewModel.onlyProgramApproval = true;
        $scope.search();
    }, function(error){
        $scope.error = error;
    })

    $scope.search = function() {
        if($scope.viewModel.searchString == null || $scope.viewModel.searchString == '') {
            $scope.viewModel.searchString == ' ';
        }
        $scope.isSearching = true;
        studentsService.search(
            $scope.viewModel.selectedTerm, $scope.viewModel.selectedYear, $scope.viewModel.selectedCountry, $scope.viewModel.selectedStatus, $scope.viewModel.onlyProgramApproval, $scope.viewModel.searchString).then(
            function(result) {
                $scope.appList = result;
                $scope.isSearching = false;
            }, function(error){
                $log.error(error);
            }
        );
    }

    $scope.viewAppItem = function (item, type) {
        let itemId;
        switch (type) {
            case 'pa':
                item.isLoadingPA = true;
                itemId = item.ProgramApprovalId;
                break;
            case 'lp':
                item.isLoadingLP = true;
                itemId = item.LearningPlanId
                break;
            default:
                break;
        }
        
        studentsService.getAppItem(itemId).then(function(result){
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
                setTimeout(function(){resize();item.isLoadingLP = false; item.isLoadingPA = false;}, 500);					
            });
            modalInstance.result.then(function (isComplete){
                if(isComplete){
                    $scope.search();	
                }					
            });
        },function(error){
            $log.error(error);
        });
    }

    $scope.getAppDetails = function(application) {
        application.isLoadingApp = true;
        studentsService.getAppDetails(application.ApplicationId).then(function(result) {
            application.isLoadingApp = false;
        }, function(error){
            $log.error(error);
        });
    }

    $scope.searchForStudentNames = function() {
        studentsService.getStudentNames($scope.viewModel.searchString).then(function(result){
            $scope.studentResults = result;
        }, function(result){

        });
    }

    $scope.selectStudent = function(item){
        $scope.viewModel.searchString = item.Name;
    }
})