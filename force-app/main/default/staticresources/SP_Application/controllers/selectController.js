/**
 * Student Portal Select Controller
 * @file Student Portal Select Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('selectController', function($scope, $modal, urlService, viewModel, selectService, errorModalService, sanitizer, applicationService, $window, $location, $timeout)
{
    $scope.loading = true;
    $scope.startingNewApp = false;
    $scope.init = function(){
        $scope.programVisible = false;
        $scope.termVisible = false;
        $scope.programTermVisible = false;
        if(viewModel.getViewModel().isDropped)
        {
            window.location.assign('#/social');
        }
        else if(!viewModel.getViewModel().profileCompleted)
        {
            window.location.assign('#/register');
        }
        var promise = selectService.getSelectViewModel()
        promise.then(function(result){
            $scope.loading = false;
            $scope.viewModel = result;
            $scope.viewModel.isProgramSelected = applicationService.isProgramSelected(result.applicationStatus);
        }, function(result){
            $scope.loading = false;
            errorModalService.openErrorModal('Error', 'The student portal was unable to process your request, please refresh the page and try again. If you continue to receive this message please contact IFSA at admissions@ifsa-butler.org or call +1 800 858 0229 for assistance');
        })
    }
    
    $scope.switchApplication = function() 
    {
        applicationService.switchApplication();
    }

    $scope.switchProgram = function() {
        portalRemotingMethods.switchProgram(
            $scope.viewModel.contactId,
            function(result, event) {
                if(result == true)
                {
                    window.location.reload();
                }
            }
        );
    }
    $scope.createSecondaryApp = function () {
        $scope.startingNewApp = true;
        /* $scope.submittingData = true;
        portalRemotingMethods.createSecondaryApp(
            $scope.viewModel.contactId,
            function(result, event) {
                if(result == true)
                {
                    window.location.reload();
                }
            }
        ); */
    }

    $scope.beginProgramSelection = function() {
        $scope.programVisible = true;
    }
    $scope.selectCountry = function() {
        portalRemotingMethods.searchByCountry(
            $scope.viewModel.CountryName,
            function(result, event) {
                $scope.viewModel.TermOptions = [];
                $scope.viewModel.ProgramTermOptions = [];
                $scope.viewModel.TermName = '';
                $scope.termVisible = true;
                $scope.viewModel.TermOptions = result;
                for (i = 0; i < $scope.viewModel.TermOptions.length; i++) { 
                    $scope.viewModel.TermOptions[i] = sanitizer.sanitize($scope.viewModel.TermOptions[i]);
                }
                $scope.$apply();
            }
        );
    }
    $scope.selectTerm = function() {
        portalRemotingMethods.searchByTerm(
            $scope.viewModel.CountryName,
            $scope.viewModel.TermName,
            function(result, event) {
                $scope.viewModel.ProgramTermOptions = [];
                $scope.programTermVisible = true;
                $scope.viewModel.ProgramTermOptions = [];
                for(i = 0; i < result.length; i++) {
                    var programName = result[i].Display_Name__c.replace($scope.viewModel.TermName, "");
                    var item = {programName: programName, programTermName: result[i], id: result[i].Id};
                    $scope.viewModel.ProgramTermOptions.push(item);
                }                        
                $scope.$apply();
            }
        );
    }
    $scope.selectProgramTerm = function(programTermName) {
        programTermName = programTermName.toString();
        portalRemotingMethods.getProgramTermInfo(
            programTermName,
            function(result, event) {
                $scope.programTermData = result;
                $scope.$apply();
                var data = {
                    result: result,
                    loadingGif: urlService.getLoadingGifURL(),
                    createNewApp: $scope.startingNewApp
                };
                var modalInstance = $modal.open({
                    animation: true,
                    backdrop : 'static',
                    size: 'lg',
                    templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/HTML_ProgramDetailsModal.html',
                    resolve: {
                        data: data
                    },
                    controller: 'programDetailsModalController',
                });

                modalInstance.result.then(function (selectedItem) {
                    $location.path('/');
                    $timeout(function(){$window.location.reload();}, 400);
                }, function (error) {
                    console.error(error);
                });
            }
        );
    }

    $scope.init();
});