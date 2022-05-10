/**
 * Chart Navbar AngularJS Controller
 * @file Chart Navbar AngularJS Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('navbarController', function($scope, $location, courseService, favoriteService, settingsFactory, urlService, viewModel)
{
    $scope.viewModel = viewModel.getViewModel();
    $scope.urlService = urlService;
    $scope.viewModel = viewModel.getViewModel();
    $scope.showFavorites = settingsFactory.getShowFavorites() && ($scope.viewModel.userProfileName == 'IFSA CHART Student User' || $scope.viewModel.userProfileName == 'IFSA Student User' || $scope.viewModel.userProfileName == 'IFSA Advisor User' || $scope.viewModel.userProfileName == 'IFSA CHART Faculty User');
    $scope.showClassMatching = settingsFactory.getShowProjects() && ($scope.viewModel.userProfileName == 'IFSA CHART Student User' || $scope.viewModel.userProfileName == 'IFSA Student User' || $scope.viewModel.userProfileName == 'IFSA Advisor User' || $scope.viewModel.userProfileName == 'IFSA CHART Faculty User');
    $scope.filterCriteria = {
        searchTerm: ""
    };
    $scope.favoriteCount = 0;
    $scope.cifToolTipText = $scope.viewModel.cifAppItems.length > 1 ? 'Class Interest Forms' : 'Class Interest Form';

    // Starts a search
    $scope.searchCourses = function (searchType)
    {
        $location.path('/search/' + $scope.filterCriteria.searchTerm);
    }

    $scope.favorites = function()
    {
        courseService.populateFilters();
        courseService.setFavoriteToggle(true);
        $location.path('/search/' );
    }

    $scope.$on("$routeChangeSuccess", function () {
        $scope.showHome = $location.path() == '/';
        $scope.onSearch = $location.path().indexOf('search') !== -1;
        $scope.showClassMatching = $location.path() != '/projects';
        var fc = courseService.getFilterCriteria();
        if(!fc || !fc.searchTerm || fc.searchCourses == 'All Classes') {
            $scope.filterCriteria.searchTerm = '';    
        }
    })
    $scope.getFirstName = function(){
        return $scope.viewModel.preferredName != null && $scope.viewModel.preferredName != undefined ? $scope.viewModel.preferredName : $scope.viewModel.firstName
    }
});