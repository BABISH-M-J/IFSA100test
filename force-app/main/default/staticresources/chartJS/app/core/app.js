/**
 * App module for CHART
 * @file App module for CHART
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
var app = angular.module('app', ['app.controllers', 'app.filters', 'app.services', 'app.directives', 'ngRoute', 'ui.bootstrap', 'ngSanitize','angular-google-analytics','infinite-scroll','angular.backtop']);
app.config(function($locationProvider){
    $locationProvider.hashPrefix('');
    $locationProvider.html5Mode({
        enabled: false,
        requireBase: true
    });
});

// Gets favorites, courses and projects from Salesforce, and once they have loaded set loading to false
app.run(function($rootScope, courseService, projectService, favoriteService, viewModel, Analytics, urlService, $uibModal){
    //Visualforce.remoting.timeout = 120000; // Set timeout at page level
    $rootScope.loading = true;
    var loadingError = false;
    var currentURL = new URL(location);
    var projectId = currentURL.searchParams.get('projectId');
    console.log(projectId);
    if(projectId)
    {
        window.location.assign('#/projects/' + projectId);
    }
    // Load Favorites
    var favoritePromise = favoriteService.loadFavorites();
    favoritePromise.then(function(result){
        console.log('Favorites loaded!');
    },
    function(result){
        console.log('Could not load favorites - ' + result);
        if(!loadingError)
        {
            loadingError = true;
            var modalInstance = $uibModal.open({
                animation: true,
                backdrop: 'static',
                templateUrl: urlService.getErrorModalUrl(),
                resolve: {
                    data: {
                        message: 'An issue is preventing CHART from loading course data, please try again later',
                    }
                },
                controller: 'errorModalController'
            });
            
            modalInstance.result.then(function (result) {
                    // This should not be hit because the modal never is never closed, only dismissed
            }, function(result) {
                console.log('Error modal dismissed at: ' + new Date());
                console.log(result);
            });
        }        
    });
    // Load Courses
    var coursePromise = courseService.loadCourses(viewModel.getViewModel().courseIds);
    coursePromise.then(function(result){
        console.log('Courses loaded!');
        $rootScope.loading = false;
    },
    function(result){
        console.log('Could not load courses - ' + result);
        if(!loadingError)
        {
            loadingError = true;
            var modalInstance = $uibModal.open({
                animation: true,
                backdrop: 'static',
                templateUrl: urlService.getErrorModalUrl(),
                resolve: {
                    data: {
                        message: 'An issue is preventing CHART from loading course data, please try again later',
                    }
                },
                controller: 'errorModalController'
            });
            
            modalInstance.result.then(function (result) {
                    // This should not be hit because the modal never is never closed, only dismissed
            }, function(result) {
                console.log('Error modal dismissed at: ' + new Date());
                console.log(result);
            });
        }
    });
    // Load Projects
    var projectPromise = projectService.loadProjects();
    projectPromise.then(function(result){
        console.log('Projects loaded!');
    },
    function(result){
        console.log('Could not load projects - ' + result);
        if(!loadingError)
        {
            loadingError = true;
            var modalInstance = $uibModal.open({
                animation: true,
                backdrop: 'static',
                templateUrl: urlService.getErrorModalUrl(),
                resolve: {
                    data: {
                        message: 'An issue is preventing CHART from loading course data, please try again later',
                    }
                },
                controller: 'errorModalController'
            });
            
            modalInstance.result.then(function (result) {
                    // This should not be hit because the modal never is never closed, only dismissed
            }, function(result) {
                console.log('Error modal dismissed at: ' + new Date());
                console.log(result);
            });
        }
    });
    
});
angular.module('app.controllers', []);
angular.module('app.services', []);
angular.module('app.directives', []);