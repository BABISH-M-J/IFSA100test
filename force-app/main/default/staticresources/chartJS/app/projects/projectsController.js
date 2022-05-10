/**
 * Chart Projects Page AngularJS Controller
 * @file Chart Projects Page AngularJS Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
/* Projects Controller */
.controller('projectsController', function($scope, $filter, viewModel, $uibModal, pageService, projectService, urlService, settingsFactory, fileUploadService)
{
    $scope.viewModel = viewModel.getViewModel();
    $scope.enableCEToggle = settingsFactory.getEnableCEToggle();
    $scope.toggleLoad = false;
    pageService.setTitle();
    $scope.urlService = urlService;
    $scope.allCourseEquivalents = [];
    var currentView = projectService.getCurrentView();
    var projectLoadPromise = projectService.getLoadingPromise();
    $scope.loading = true;
    // CMP Table Sorting defaults
    $scope.sortProperty = 'completedDate';
    $scope.sortReverse = true;
    // CMP Pagination Defaults
    $scope.pageSize = 25; // Number of projects per page
    $scope.maxNumberOfPages = 6; // Number of buttons visible in pagination
    $scope.currentPage = 0;
    // All Courses Table Sorting defaults
    $scope.ceSortProperty = 'status';
    $scope.ceSortReverse = true;
    // All Courses Pagination Defaults
    $scope.cePageSize = 25; // Number of projects per page
    $scope.ceMaxNumberOfPages = 6; // Number of buttons visible in pagination
    $scope.ceCurrentPage = 0;

    projectLoadPromise.then(function(result){
        $scope.projects = projectService.getProjects();
        $scope.filteredProjects = $scope.projects;
        console.log($scope.filteredProjects);
        $scope.loadCourseEquivalents();
        if(currentView == null){
            currentView = $scope.viewModel.userProfileName.includes('Student') ? 'Completed' : 'Home School';
            console.log($scope.viewModel.userProfileName);
        }
        $scope.filteredChanged(currentView);
        $scope.loading = false;
    },
    function(result) {
        // Load error message
        $scope.loadErrorModal(result);
    });

    // Loads all course equivalents
    $scope.loadCourseEquivalents = function()
    {
        var promise = projectService.loadCourseEquivalents();
        promise.then(function(result){
            $scope.allCourseEquivalents = result;
            $scope.countriesFilter = [];
            $scope.programsFilter = [];
            for (let index = 0; index < result.length; index++) {
                const course = result[index];
                if(!$scope.countriesFilter.find(c => c.name === course.hostInstitutionCourse.country))
                {
                    $scope.countriesFilter.push({
                        name: course.hostInstitutionCourse.country,
                        selected: true
                    })                            
                }
                for (let programIndex = 0; programIndex < course.hostInstitutionCourse.programs.length; programIndex++) {
                    const program = course.hostInstitutionCourse.programs[programIndex];
                    if(!$scope.programsFilter.find(p => p.name === program.recordName))
                    {
                        $scope.programsFilter.push({
                            name: program.recordName,
                            country: course.hostInstitutionCourse.country,
                            selected: true
                        })
                    }
                }
            }

            console.log($scope.allCourseEquivalents);
        },
        function(result){
            $scope.loadErrorModal(result);
        });
        console.log($scope.allCourseEquivalents);
    }

    $scope.saveEquivalents = function(courseEquivalents)
    {
        var data = angular.copy(courseEquivalents);
        var promise = projectService.saveCourseEquivalents(data);
        promise.then(function(result){
            // CE records updated
            $scope.loadSuccessModal({message: 'Course equivalencies updated'});
        },
        function(result){
            // CE records not updated
            $scope.loadErrorModal(result);
        })
    }

    $scope.approveAll = function()
    { 
        for(i=0; i < $scope.allCourseEquivalents.length; i++){
            if($scope.allCourseEquivalents[i].Status__c != 'Match'){
                $scope.allCourseEquivalents[i].Status__c = 'Match';
                $scope.allCourseEquivalents[i].changed = true;
            }
        }
    }
    
    $scope.filteredChanged = function(currentView)
    {
        projectService.setCurrentView(currentView);
        $scope.currentView = currentView;
        switch ($scope.currentView) {
            case 'Completed':
                $scope.filteredProjects = $filter('filter')($scope.projects, {completedDate: '', type: "CE"});
                $scope.currentPage = 0;
                $scope.ceCurrentPage = 0;
                break;
            case 'Pending':
                var t = $scope.viewModel.userProfileName == "IFSA Advisor User" ? "CI" : "CE";
                $scope.filteredProjects = $filter('filter')($scope.projects, {completedDate: null, type: t});
                $scope.currentPage = 0;
                $scope.ceCurrentPage = 0;
                break;
            case 'Home School':
                $scope.filteredProjects = $filter('filter')($scope.projects, {completedDate: '', type: "CI"});
                $scope.currentPage = 0;
                $scope.ceCurrentPage = 0;
                break;
            case 'Students':
                $scope.filteredProjects = $filter('filter')($scope.projects, {completedDate: '', type: "CE"});
                $scope.currentPage = 0;
                $scope.ceCurrentPage = 0;
                break;
            case 'All Classes':
                $scope.currentPage = 0;
                $scope.ceCurrentPage = 0;
                break;
            default:
                break;
        }
    }

    $scope.ceSearchToggle = function(ceSearch)
    {
        console.log('Starting process...');
        $scope.toggleLoad = true;
        $scope.viewModel.ceSearch = !ceSearch;
        
        var promise = projectService.ceSearchToggle($scope.viewModel.ceSearch, $scope.viewModel.userId, $scope.viewModel.userHomeInstitutionId);
        promise.then(function(result){
            // Set updated values to scope
            $scope.viewModel.ceSearch = result.Course_Equivalency_Search__c;
            $scope.viewModel.ceSearchLastUpdated = result.CE_Search_Last_Updated__c;
            // $scope.viewModel.ceSearchLastUpdatedBy = result.CE_Search_Last_Updated_By__r.Name;
            $scope.viewModel.ceSearchLastUpdatedBy = $scope.viewModel.firstName + ' ' + $scope.viewModel.lastName;
            // End loading
            $scope.toggleLoad = false;
        },function(result){
            $scope.toggleLoad = false;
            $scope.loadErrorModal(result);
        });

    }

    $scope.loadDenyReasonModal = function(item, project) {
        // item.homeInstitutionCourse = {
        //     courseCode: item.homeInstitutionCourseCode,
        //     title: item.homeInstitutionCourseTitle
        // };
        // item.hostInstitutionCourse = {
        //     courseCode: item.hostInstitutionCourseCode,
        //     title: item.hostInstitutionCourseTitle
        // };
        
        var modalInstance = $uibModal.open({
            animation: true,
            size: 'lg',
            backdrop: 'static',
            templateUrl: urlService.getCeModalUrl(),
            resolve: {
                data: item
            },
            controller: 'projectCourseDenyModalController'
        });
        
        modalInstance.result.then(function (deniedItem) {
            item = deniedItem;
        }, function() {
            console.log('Denied modal dismissed at: ' + new Date());
        });
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

    $scope.loadSuccessModal = function(successMessage) {
        var modalInstance = $uibModal.open({
            animation: true,
            backdrop: 'static',
            templateUrl: urlService.getSuccessModalUrl(),
            resolve: {
                data: successMessage
            },
            controller: 'successModalController'
        });
        
        modalInstance.result.then(function (result) {
                // This should not be hit because the modal never is never closed, only dismissed
        }, function(result) {
            console.log('Success modal dismissed at: ' + new Date());
            console.log(result);
        });
    }

    // Start CMP Pagination
    $scope.setCurrentPage = function(currentPage) 
    {
        $scope.currentPage = currentPage;
        projectService.setCurrentResultsPage($scope.currentPage);
    }
    $scope.getNumberAsArray = function(num) 
    {
        var values = [];
        var numOfPages = $scope.numberOfPages();
        if(numOfPages <= $scope.maxNumberOfPages){
            for (let index = 0; index < numOfPages; index++) {
                values.push(index);
            }
        }
        else if($scope.currentPage < $scope.maxNumberOfPages){
            for (let index = 0; index < $scope.maxNumberOfPages; index++) {
                values.push(index);
            }
        }
        else if($scope.currentPage >= $scope.maxNumberOfPages && $scope.currentPage < numOfPages - $scope.maxNumberOfPages){
            for (let index = $scope.currentPage - 3; index < $scope.currentPage + 3; index++) {
                values.push(index);
            }
        }
        else if($scope.currentPage >= $scope.maxNumberOfPages && $scope.currentPage >= numOfPages - $scope.maxNumberOfPages){
            for(let index = numOfPages - $scope.maxNumberOfPages; index < numOfPages; index++){
                values.push(index);
            }
        }
        return values;
    }
    $scope.numberOfPages = function() 
    {
        if($scope.filteredProjects) {
            return Math.ceil($scope.filteredProjects.length / $scope.pageSize);
        }
    }

    // CMP Filters
    $scope.sortBy = function(sortProperty)
    {
        $scope.sortReverse = ($scope.sortProperty === sortProperty) ? !$scope.sortReverse : false;
        $scope.sortProperty = sortProperty;
    }

    // Start All Course Equivalencies Pagination
    $scope.ceSetCurrentPage = function(currentPage) 
    {
        $scope.ceCurrentPage = currentPage;
    }
    $scope.ceGetNumberAsArray = function(num) 
    {
        var values = [];
        var numOfPages = $scope.ceNumberOfPages();
        if(numOfPages <= $scope.ceMaxNumberOfPages){
            for (let index = 0; index < numOfPages; index++) {
                values.push(index);
            }
        }
        else if($scope.ceCurrentPage < $scope.ceMaxNumberOfPages){
            for (let index = 0; index < $scope.ceMaxNumberOfPages; index++) {
                values.push(index);
            }
        }
        else if($scope.ceCurrentPage >= $scope.ceMaxNumberOfPages && $scope.ceCurrentPage < numOfPages - $scope.ceMaxNumberOfPages){
            for (let index = $scope.ceCurrentPage - 3; index < $scope.ceCurrentPage + 3; index++) {
                values.push(index);
            }
        }
        else if($scope.ceCurrentPage >= $scope.ceMaxNumberOfPages && $scope.ceCurrentPage >= numOfPages - $scope.ceMaxNumberOfPages){
            for(let index = numOfPages - $scope.ceMaxNumberOfPages; index < numOfPages; index++){
                values.push(index);
            }
        }
        return values;
    }
    $scope.ceNumberOfPages = function() 
    {
        if($scope.allCourseEquivalents) {
            return Math.ceil($scope.allCourseEquivalents.length / $scope.cePageSize);
        }
    }

    // All Course Equivalencies Filters
    $scope.ceSortBy = function(sortProperty)
    {
        $scope.ceSortReverse = ($scope.ceSortProperty === sortProperty) ? !$scope.ceSortReverse : false;
        $scope.ceSortProperty = sortProperty;
    }

    // Launch CE File Upload Modal
    $scope.loadCEUploadModal = function() {
        var modalInstance = $uibModal.open({
            animation: true,
            backdrop: 'static',
            templateUrl: urlService.getCeUploadFileModalUrl(),
            controller: 'uploadCEFileModalController'
        });
        
        modalInstance.result.then(function (file) {
            var promise = fileUploadService.uploadFileToSalesforce(file);
            promise.then(function(result){
                // File uploaded
                $scope.loadSuccessModal({message: 'File Upload Successful!'});
            },function(result){
                // Upload failed
                $scope.loadErrorModal(result);
            });
        }, function(result) {
            // Upload Modal canceled
        });
    }

});