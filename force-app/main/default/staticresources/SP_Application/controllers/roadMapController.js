/**
 * Student Portal Course Interest Form Controller
 * @file Student Portal Course Interest Form Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('roadMapController', function($scope, $modal, $routeParams, urlService, viewModel, roadMapService, applicationItemService, errorModalService, toArrayFilter, $window, $timeout)
{
    $scope.roadMapSubmitButtonDisabled = false;
    console.log('roadMapController start');
    $scope.urlService = urlService;
    $scope.viewModel = viewModel.getViewModel();
    //$scope.brandImageURL = urlService.getBaseResourceURL() + '/images/IFSA_Navbar_Brand_Logo.png';
    /* roadMapSteps
        roadMapSteps of the form are defined by creating and step object and pushing to $scope.roadMapSteps. The first and last roadMapSteps are defined below. roadMapSteps for required, departments and 
        selections are defined and pushed as needed in the function $scope.getCoursesFromForm. If additional roadMapSteps are needed in the future they will need to be defined in this js file
    */
   console.log('before roadMapSteps create');
    $scope.roadMapSteps = [
        {apiName: 'pre1', description: 'How to complete this form', isCompleted: false, shortTitle: 'Intro', title: 'Introduction', templateUrl: urlService.getBaseResourceURL() + '/views/pages/road-map-pre-page1.html' },
        {apiName: 'pre2', description: 'Complete Class Interest Form', isCompleted: false, shortTitle: 'Sign', title: 'Sign and Complete', templateUrl: urlService.getBaseResourceURL() + '/views/pages/road-map-pre-page2.html'}
    ];
    console.log('after roadMapSteps create');
    
    $scope.pdfLoading = false;
    $scope.savingForLater = false;
    $scope.saving = false;
    

    $scope.updateView = function(view){
        console.log('updateView');
        $scope.viewIndex = $scope.roadMapSteps.findIndex(s => s.apiName == view.apiName);
        for (let index = 0; index < $scope.viewIndex; index++) {
            const element = $scope.roadMapSteps[index];
            element.isCompleted = true;
        }         
        $scope.view = view;
        if($scope.viewIndex == $scope.roadMapSteps.length - 1){

        }
    }
    
    $scope.loadAppItem = function(){
        console.log('loadAppItem roadMapController');
        console.log('getBaseResourceURL => ' + urlService.getBaseResourceURL);
        $scope.loading = true;
        $scope.roadMapPage = urlService.getBaseResourceURL() + '/views/pages/road-map-pre-page1.html';
        console.log('after registerPage');
        //$scope.updateView($scope.roadMapSteps[0]);
        $scope.updateView('Introduction');
        $scope.loadingForm = true;
        //$scope.loadingCourses = true;
        //$scope.introduction = null;
        //$scope.closing = null;
        //$scope.signature = null;
        roadMapService.getRoadMapViewModel();
        console.log('viewModel.preInitiate => ' + viewModel.preInitiate);
        var promise = applicationItemService.getApplicationItemDetails($routeParams.appItemId);
        promise.then(function(result){
            $scope.appItem = result;
            $scope.loading = false;
            if($scope.appItem.status == 'Complete'){
                $scope.isComplete = true;            
                if(result.files[0]){
                    $scope.appItem.pdf = result.files[0];
                }
            }
            else {
                //let index = $scope.appItem.form.formData.items.findIndex(i => i.fieldType == 'Date')
                /*if(index > -1){
                    $scope.appItem.form.formData.items[index].response = new Date();
                }*/
            }
            // We may want to consider before we push to production to only run the next line if $scope.isComplete == false
            //$scope.getCourseRegistrations();
        },
        function(result){
            errorModalService.openErrorModal('An Error has occured loading your applicaiton item', 'There was an error loading your applicaiton item. Please try again. If you continue to have problems, contact IFSA.');
        });
    }  
    
    $scope.toggleSurvey = function(arg, newPageNum, prePost){
        //$scope.loading = true;
        $scope.toggling = true;        
        $scope.submitted = false;
        $scope.toggling = false;
        $scope.surveyQuestions = arg;
        $scope.surveySection = newPageNum;
        $scope.roadMapPage = urlService.getBaseResourceURL() + '/views/pages/road-map-' + prePost + '-page' + newPageNum + '.html';  
        //$scope.roadMapPage = urlService.getBaseResourceURL() + '/views/pages/register_page' + ($scope.surveySection + 1) +'.html';  
      
    }

    $scope.nextView = function(){
        let index = $scope.roadMapSteps.findIndex(s => s.apiName == $scope.view.apiName);
        $scope.view.isCompleted = true;
        $scope.updateView($scope.roadMapSteps[index + 1]);
    }

    $scope.determineWidth = function() {
        if($scope.windowWidth < 992){
            return "small"
        }
        else{
            return "large"
        }
    }
    
    // TEST UNCOMMENT TEST
    //$scope.loadAppItem();

    $scope.greaterThan = function(prop, val){
        return function(item){
        return item[prop] > val;
        }
    }

    $scope.lessThan = function(prop, val){
        return function(item){
        return item[prop] < val;
        }
    }    

    /*$scope.submit = function() {

        var promise = applicationItemService.submitApplicationItem(angular.toJson($scope.appItem), '', '', '');
        promise.then(function(result){
            console.log('Saved Application Item');
            window.location.assign('#/');
            //$scope.savingForLater = false;
            $scope.saving = false;
        },
        function(result){
            if(saveForLater){
                //ERROR_1002
                errorModalService.openErrorModal('An Error has occured saving your class interests', 'There was an error saving your class interests. Please try again. If you continue to have problems, contact IFSA. ERROR_1002');    
            }
            else {
                //ERROR_1005
                errorModalService.openErrorModal('An Error has occured submitting your road map form', 'There was an error submitting your class interest form. Please try again. If you continue to have problems, contact IFSA. ERROR_1005');
            }
            $scope.savingForLater = false;
            $scope.saving = false;
        });
    }*/

    $scope.submit = function() {
        console.log('js roadMapController.submit Start');
        $scope.roadMapSubmitButtonDisabled = true;
        let roadMapComplete = true;
        console.log('$scope.viewModel => ' + $scope.viewModel);
        var promise = roadMapService.saveRoadMap($scope.viewModel, roadMapComplete);
        promise.then(function(result){
            console.log('Saved Road Map');
            //window.location.assign('#/');
            //$scope.savingForLater = false;
            //$scope.saving = false;
        },
        function(result){
            if(result){
                console.log('result => ' + result);
            }
            else {
                console.log('result is null');
            }
            //$scope.savingForLater = false;
            //$scope.saving = false;
        });
        var promise2 = applicationItemService.submitApplicationItem(angular.toJson($scope.appItem), '', '', '');
        promise2.then(function(result){
            console.log('Saved Application Item');
            window.location.assign('#/');
            //$scope.savingForLater = false;
            $scope.saving = false;
        },
        function(result){
            if(saveForLater){
                //ERROR_1002
                errorModalService.openErrorModal('An Error has occured saving your class interests', 'There was an error saving your class interests. Please try again. If you continue to have problems, contact IFSA. ERROR_1002');    
            }
            else {
                //ERROR_1005
                errorModalService.openErrorModal('An Error has occured submitting your road map form', 'There was an error submitting your class interest form. Please try again. If you continue to have problems, contact IFSA. ERROR_1005');
            }
            $scope.savingForLater = false;
            $scope.saving = false;
        });
        console.log('js roadMapController.submit End');
    }

    console.log('BEFORE LOADAPPITEM!!!!!!!!!!')
    $scope.loadAppItem();
});