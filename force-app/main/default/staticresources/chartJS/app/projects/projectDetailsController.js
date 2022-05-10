/**
 * Chart Project Details Page AngularJS Controller
 * @file Chart Project Details Page AngularJS Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('projectDetailsController', function($scope, $routeParams, $filter, $uibModal, viewModel, pageService, projectService, urlService)
{
    $scope.viewModel = viewModel.getViewModel();
    pageService.setTitle();
    $scope.urlService = urlService;
    $scope.loading = false;
    // Table Sorting defaults
    $scope.sortProperty = 'completedDate';
    $scope.sortReverse = true;
    // Pagination Defaults
    $scope.pageSize = 25; // Number of projects per page
    $scope.maxNumberOfPages = 6; // Number of buttons visible in pagination
    $scope.currentPage = 0;

    $scope.loadDetails = function()
    {
        $scope.loading = true;
        var projectPromise = projectService.getProject($routeParams.projectId);
        projectPromise.then(function(result) {
            
            $scope.selectedProject = result;
            $scope.selectedProject.degreeReqs = $scope.selectedProject.degreeReqs != null ? $scope.selectedProject.degreeReqs.replace(/(?:\r\n|\r|\n)/g, '<br />') : null;
            
            var cePromise = projectService.getCourseEquivalents($scope.selectedProject);
            cePromise.then(function(result){
                if(result){
                    console.log('Course Equivalents loaded!');
                    // All Project Equivalents
                    $scope.projectEquivalents = result;
                    // Create list of equivalents in order of country -> program -> equivalent
                    var countries = [];
                    for (let index = 0; index < result.length; index++) {
                        const ce = result[index];
                        ce.approved = null;
                        if(!countries.find(c => c.name === ce.hostInstitutionCourse.country)){
                            countries.push({
                                name: ce.hostInstitutionCourse.country,
                                programs: [{
                                    name: ce.hostInstitutionCourse.programs[0].recordName,
                                    academicURLSemester: ce.hostInstitutionCourse.programs[0].academicURLSemester,
                                    academicURLSummer: ce.hostInstitutionCourse.programs[0].academicURLSummer,
                                    courses: [ce]
                                }]
                            });
                        }
                        else {
                            var country = countries.find(c => c.name === ce.hostInstitutionCourse.country);
                            if(!country.programs.find(p => p.name === ce.hostInstitutionCourse.programs[0].recordName)){
                                country.programs.push({
                                    name: ce.hostInstitutionCourse.programs[0].recordName,
                                    academicURLSemester: ce.hostInstitutionCourse.programs[0].academicURLSemester,
                                    courses: [ce]
                                })
                            }
                            else {
                                var program = country.programs.find(p => p.name === ce.hostInstitutionCourse.programs[0].recordName);
                                program.courses.push(ce);
                            }
                        }
                    }
                    $scope.countries = countries;
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
                    
                    $scope.loading = false;
                }
            },
            function(result){
                    console.log('Could not load Course Equivalents!');
                    $scope.loading = false;
                    $scope.loadErrorModal(result);
            })
        },
        function(result){
            console.log("An error occured loading course details.");
            //$scope.errorMessage = 'There was an error loading this project. Please refresh and try again.';
            $scope.loadErrorModal(result);
        })
    }
    
    $scope.printPage = function()
    {
        window.print();
    }

    $scope.saveEquivalents = function(courseEquivalents, tableView)
    {
        var data = angular.copy(courseEquivalents);
        if(tableView){
            var promise = projectService.saveCourseEquivalents(data);
        } else {
            var promise = projectService.saveCourseEquivalents(data.courses);
        }
        
        promise.then(function(result){
                // CE records updated
                $scope.loadSuccessModal({message: 'Course equivalencies updated'});
            },
            function(result){
                // CE records not updated
                $scope.loadErrorModal(result);
        })
    }


    $scope.loadDenyReasonModal = function(item) {
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

    $scope.loadDetails();
    
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

    // Table  Pagination
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
        if($scope.projectEquivalents) {
            return Math.ceil($scope.projectEquivalents.length / $scope.pageSize);
        }
    }

    // Table Filters
    $scope.sortBy = function(sortProperty)
    {
        $scope.sortReverse = ($scope.sortProperty === sortProperty) ? !$scope.sortReverse : false;
        $scope.sortProperty = sortProperty;
    }
});