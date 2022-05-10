/**
 * Chart Course Search Page AngularJS Controller
 * @file Chart Course Search Page AngularJS Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('searchController', function($scope, $anchorScroll, $location, $filter, $routeParams, $window, viewModel, courseService, pageService, projectService, favoriteService, settingsFactory, urlService, $uibModal) 
{
    pageService.setTitle();
    $scope.disclaimerSearchText = settingsFactory.getSearchDisclaimer();
    $scope.disclaimerDismissed = settingsFactory.getDisclaimerDismissed();
    $scope.viewModel = viewModel.getViewModel();
    $scope.cmpMessage = settingsFactory.getSearchCMPMessage();
    $scope.urlService = urlService;
    $scope.noResultsMessage = settingsFactory.getNoResultsMessage();
    $scope.showFavorites = settingsFactory.getShowFavorites() && ($scope.viewModel.userProfileName == 'IFSA CHART Student User' || $scope.viewModel.userProfileName == 'IFSA Student User' || $scope.viewModel.userProfileName == 'IFSA Advisor User' || $scope.viewModel.userProfileName == 'IFSA CHART Faculty User');
    //filter defaults
    $scope.favoritesOnlySelected = courseService.getFavoriteToggle();
    $scope.pageSize = 10; // Number of courses per page
    $scope.maxNumberOfPages = 6; // Number of buttons visible in pagination
    $scope.currentPage = 0;
    $scope.infiniteScrollResults = [];
    $scope.cmpProject = null;
    $scope.sortOptions = [
        {name: 'IFSA Exclusive', enabled: true, type: 'sortByIFSAExclusive', sortParams: ['-isIFSAClass', 'courseTitle']},
        {name: 'Host Institution', enabled: false, type: 'sortByHostInstitutionName', sortParams: ['hostInstitutionName', 'courseTitle']},
        {name: 'Host Institution Class Code', enabled: false, type: 'sortByHostInstitutionClassCode', sortParams: ['courseCode', 'courseTitle']},
        {name: 'Class Title', enabled: false, type: 'sortByClassTitle', sortParams: ['courseTitle']}
    ];

    $scope.showSort = false;
    var searchTerm = $routeParams.searchTerm;
    
    // Load courses
    $scope.loadCourses = function()
    {
        var promise = courseService.getLoadingPromise();;
        promise.then(function(pResult){
            if(pResult == 'Completed'){
                $scope.filterCriteria = courseService.getFilterCriteria();
                $scope.currentSearchTerm = searchTerm;
                $scope.filterCriteria.searchTerm = $scope.currentSearchTerm;
                $scope.filterCriteria.favorites = $scope.favoritesOnlySelected;
                $scope.viewModel.courseResults = courseService.getCourses();
                $scope.currentPage = courseService.getCurrentResultsPage();
                let sType = $scope.sortOptions.find(o => o.type == $scope.filterCriteria.sortType);
                if(sType)
                {
                    $scope.changeSortBy(sType);   
                }
                else
                {
                    $scope.changeSortBy($scope.sortOptions[0]);
                }
                $scope.filterCriteriaChanged();
                $scope.favorites = favoriteService.getFavorites();
                $scope.loadMore();
                $scope.$emit('list:filtered');
                $scope.loading = false;
            }
            else{
                console.log(pResult);
            }
        }, function(result){
            $scope.loadErrorModal(result);
        })
    }
    $scope.loadCEs = function(cmpId)
    {
        var projectPromise = projectService.getProject(cmpId);
        projectPromise.then(
            function(project){
                var cePromise = projectService.getCourseEquivalents(project);
                $scope.cmpProject = project;
                cePromise.then(
                    function(results){
                        $scope.courseEquivalents = results;
                        for (let index = 0; index < results.length; index++) {
                            const ce = results[index];
                            var course = $scope.viewModel.courseResults.find(c => c.recordId == ce.hostInstitutionCourse.recordId);
                            if(course){
                                course.addedToProject = true;
                            }                            
                        }
                    }
                )
            },
            function(result){
                $scope.loadErrorModal(result);
            }
        )
    }
    // START INFINITE SCROLL
    $scope.loadMore = function() {
        let last = $scope.infiniteScrollResults.length - 1;
        let newLast = $scope.filteredResults.length >= last + 10 ? last + 10 : $scope.filteredResults.length;
        if(last < newLast){
            for (let index = last + 1; index < newLast; index++) {
                $scope.infiniteScrollResults.push($scope.filteredResults[index]);            
            }
        }
    }
    // END INFINITE SCROLL
    // Filters the results when a filter is changed
    $scope.favoritesOnly = function()
    {
        $scope.favoritesOnlySelected = !$scope.favoritesOnlySelected;
        courseService.setFavoriteToggle($scope.favoritesOnlySelected);
        $scope.filterCriteria = courseService.getFilterCriteria();
        $scope.filterCriteria.favorites = !$scope.filterCriteria.favorites;
        $scope.filterCriteriaChanged();
    }
    $scope.filterCriteriaChanged = function()
    {                
        $scope.currentPage = 0;
        courseService.setCurrentResultsPage($scope.currentPage);
        $scope.filteredResults = $filter('courseSearchAndFilter')($scope.viewModel.courseResults, $scope.filterCriteria);
        $scope.filteredResults = $filter('orderBy')($scope.filteredResults, $scope.sortType.sortParams);
        if($scope.filterCriteria.reverseSort)
        {
            $scope.filteredResults.reverse();
        }
        $scope.infiniteScrollResults = [];
        $scope.loadMore();
        $scope.$emit('list:filtered');
    }
    $scope.refreshCourses = function()
    {
        courseService.populateFilters();
        courseService.setFavoriteToggle(false);
        $scope.filterCriteria = courseService.getFilterCriteria();
        $scope.filterCriteria.searchTerm = '';        
        $scope.filterCriteriaChanged();
        $location.path('/search/');

    }
    $scope.addToCMP = function(course)
    {
        var promise = projectService.addCourseToCMP(course.recordId, $scope.viewModel.cmpId);
        promise.then(
            function(result) {
                console.log('Course added to CMP');
                course.addedToProject = true;
                $scope.loadCEs($scope.viewModel.cmpId);
            },
            function(result) {
                console.log('Course NOT added to CMP');
            }
        )
    }
    $scope.addSelectedToCMP = function()
    {
        var courses = [];
        for (let index = 0; index < $scope.viewModel.courseResults.length; index++) {
            const element = $scope.viewModel.courseResults[index];
            if(element.selectedForCMP)
            {
                courses.push(element);
            }
        }
        var promise = projectService.addCoursesToCMP(courses, $scope.viewModel.cmpId);
        promise.then(
            function(result) {
                console.log('Course added to CMP');
                for (let index = 0; index < courses.length; index++) {
                    const element = courses[index];
                    element.addedToProject = true;
                    element.selectedForCMP = false;
                }
                $scope.loadCEs($scope.viewModel.cmpId);
            },
            function(result) {
                console.log('Course NOT added to CMP');
            }
        )
    }

    $scope.dismissDisclaimer = function() 
    {
        $scope.disclaimerDismissed = settingsFactory.setDisclaimerDismissed(true);

    };
    
    if($scope.viewModel.cmpId)
    {
        $scope.loadCEs($scope.viewModel.cmpId);
    }
    $scope.loadErrorModal = function(error) {
        var modalInstance = $uibModal.open({
            animation: true,
            backdrop: 'static',
            templateUrl: urlService.getErrorModalUrl(),
            resolve: {
                data: error
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

    $scope.updateFavorite = function(course){

        course.savingFavorite = true;
        
        // Add/Delete Favorite Record
        var promise = favoriteService.updateFavorite($scope.viewModel.contactId, course);
        promise.then(
        function(result){
            // Actions
            if(result.payload){
                fav = result.payload;
                course.favoriteId = fav.Id;
                course.isFavorite = true;
            } else {
                course.favoriteId = null;
                course.isFavorite = false;
            }
            course.savingFavorite = false;
            // $scope.filterCriteriaChanged();
            // Instead of useing filterCriteriaChanges(), just reset filteredResults manually (below)
            // The method resets the pagination page to 0 and we don't want that to happen when favoriting/unfavoriting
            $scope.filteredResults = $filter('courseSearchAndFilter')($scope.viewModel.courseResults, $scope.filterCriteria);
        }, function(result){
            course.savingFavorite = false;
            $scope.loadErrorModal(result);
        });
    }

    $scope.isEmptyObject = function(obj){
        return angular.equals({}, obj) || obj === null;
    }

    $scope.getCity = function(course) {
        return courseService.getCourseCity(course);
    }
    $scope.getCourseEquivalents = function(course) {
        if(!course.courseEquivalents){
            course.loadingEquivalents = true;
            courseService.getCourseEquivalents(course.recordId).then(
                function(result){
                    course.courseEquivalents = result;
                    course.loadingEquivalents = false;
                },
                function(result){
                    console.error(result);
                    course.loadingEquivalents = false;
                }
            )
        }
    }
    $scope.changeSortBy = function(sortItem) {
        $scope.currentSortName = sortItem.name;
        sortItem.enabled = true;

        if(sortItem == $scope.sortType){
            $scope.filterCriteria.reverseSort = !$scope.filterCriteria.reverseSort;
        }
        else{
            $scope.filterCriteria.reverseSort = false;
        }

        for (let index = 0; index < $scope.sortOptions.length; index++) {
            const item = $scope.sortOptions[index];
            if(item != sortItem)
            {
                item.enabled = false;
            }
        }

        $scope.sortType = sortItem;
        $scope.filterCriteria.sortType = sortItem.type;
        $scope.filterCriteriaChanged();
    }
    $scope.scrollToTop = function(){
        $location.hash('resultsDesktop');
        $anchorScroll();
    }
    $scope.loadCourses();
});