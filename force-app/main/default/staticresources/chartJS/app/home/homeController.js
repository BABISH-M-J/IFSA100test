/**
 * Chart Home Page AngularJS Controller
 * @file Chart Home Page AngularJS Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('homeController', function($scope, $filter, $location, viewModel, $interval, courseService, pageService, favoriteService, settingsFactory, urlService) 
{
    $scope.urlService = urlService;
    $scope.disclaimerText = settingsFactory.getDisclaimer();
    pageService.setTitle();
    $scope.viewModel = viewModel.getViewModel();
    $scope.timer = null;
    $scope.progressValue = 0;
    $scope.noCourses = false;
    $scope.faqView = 'classes';
    
    /* COURSE RETREIVAL START */
    $scope.loadCourses = function()
    {
        var promise = courseService.getLoadingPromise();;
        $scope.startTimer();
        promise.then(function(pResult){
            if(pResult == 'Completed'){
                // Run once courses have been loaded
                $scope.stopTimer();
                courseService.populateFilters();
                $scope.filterCriteria = courseService.getFilterCriteria();
                $scope.filterCriteria.searchTerm = null;
                $scope.filteredResults = $filter('courseSearchAndFilter')(courseService.getCourses(), $scope.filterCriteria);
                if($scope.filteredResults.length == 0){
                    $scope.noCourses = true;
                }
                else if($location.path() == '/'){ 
                    $location.path('/search/');
                }
            }
            else{
                console.log(pResult);
            }
        })
    }
    $scope.startTimer = function()
    {
        // Creates a timer
        $scope.timer = $interval(function(){
            // Update progress bar
            $scope.currentBatch = courseService.getCurrentBatch();
            $scope.numberOfBatches = courseService.getTotalBatches();
            $scope.progressValue = ($scope.currentBatch / $scope.numberOfBatches) * 100;
        }, 1000)
    }
    $scope.stopTimer = function() 
    {
        // Stops the timer, if it has been defined
        if(angular.isDefined($scope.timer)){
            $interval.cancel($scope.timer)
        }
    }
    /* COURSE RETREIVAL END */
    $scope.searchCoursesHome = function () {
        if($scope.filterCriteria.searchTerm){
            $location.path('/search/' + $scope.filterCriteria.searchTerm);
        }
        else{
            $location.path('/search/');
        }
    }
    /* Update FAQ View */
    $scope.updateView = function(view) {
        $scope.faqView = view;
    }

    // Starts the process of loading courses once the page has been initialized
    $scope.loadCourses();
});