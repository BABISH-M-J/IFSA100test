/**
 * Chart Course Detail Page AngularJS Controllers
 * @file Chart Course Detail Page AngularJS Controllers
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('detailsController', function($scope, $routeParams, viewModel, courseService, pageService, favoriteService, settingsFactory, urlService, $uibModal, projectService, replaceFilter, $timeout, $filter)
{
    try {
        $scope.selectedCourse = courseService.getCourse($routeParams.courseId);
        pageService.setTitle($scope.selectedCourse.courseTitle + ' -  ' + $scope.selectedCourse.courseCode);
    } catch (error) {
        pageService.setTitle();
        console.log('Could not find a course in memory. Will try to retrieve it from the database');
    }
    $scope.viewModel = viewModel.getViewModel();
    $scope.recordDisclaimerText = settingsFactory.getRecordDisclaimer();
    $scope.urlService = urlService;
    $scope.courseLoading = true;

    // Loads the selected course's details
    $scope.loadCourseDetails = function()
    {
        console.log('--- loadCourseDetails start ---');
        var promise = courseService.loadCourseDetails($routeParams.courseId);
        promise.then(function(result){
            $scope.selectedCourse = result;
            pageService.setTitle($scope.selectedCourse.courseTitle + ' -  ' + $scope.selectedCourse.courseCode);
            $scope.courseLoading = false;
            if($scope.selectedCourse.courseDeliveryMethod == 'Hybrid'){
                $scope.selectedCourse.courseDeliveryMethod = 'Face-to-Face and Online';
            }
            $scope.favorites = favoriteService.getFavorites();
            var fav = favoriteService.checkFavorite($scope.selectedCourse.recordId);
            if(fav){
                $scope.selectedCourse.isFavorite = true;
                $scope.selectedCourse.favoriteId = fav.Id;
            } else {
                $scope.selectedCourse.isFavorite = false;
                $scope.selectedCourse.favoriteId = null;
            }
            $scope.processRightColDetails();
            $scope.processLeftColDetails();
        }, function(result){
            $scope.loadErrorModal(result);
            $scope.courseLoading = false;
        });
        console.log('--- loadCourseDetails end ---');
    }
    
    $scope.printPage = function()
    {
        $scope.printDisabled = true;
        for (let index = 0; index < $scope.classInfo.length; index++) {
            const element = $scope.classInfo[index];
            element.isOpen = true;
        }
        $timeout(function(){
            window.print();
            $scope.printDisabled = false;
        }, 250);
    }
    $scope.loadCourseDetails();

    $scope.loadNewCourseModal = function() {
        var modalInstance = $uibModal.open({
            animation: true,
            size: 'lg',
            backdrop: 'static',
            templateUrl: urlService.getNewCourseModalUrl(),
            resolve: {
                data: $scope.selectedCourse
            },
            controller: 'newHomeCourseModalController'
        });
        
        modalInstance.result.then(function (course) {
            var courseSavePromise = courseService.createNewHomeInstitutionCourseEquivalency(course, $scope.selectedCourse.recordId);
            courseSavePromise.then(function(result){
                $rootScope.loading = true;
                console.log(result);
                $scope.loadCourseDetails();
            },
            function(result){
                console.log('Could not save Course Equivalents!');
                console.log(result);
                $scope.loadErrorModal(result);
            })

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
    
    $scope.updateFavorite = function(course){

        $scope.savingFavorite = true;
        
        // Add/Delete Favorite Record
        var promise = favoriteService.updateFavorite($scope.viewModel.contactId, course);
        promise.then(
        function(result){
            // Actions
            console.log(result);
            if(result.payload){
                var fav = result.payload;
                course.isFavorite = true;
                course.favoriteId = fav.Id;
            } else {
                course.isFavorite = false;
                course.favoriteId = null;
            }
            $scope.savingFavorite = false;
        }, function(result){
            $scope.savingFavorite = false;
            $scope.loadErrorModal(result);
        });
    }

    $scope.updateStatus = function(item) {
        ce = {
            recordId: item.Id,
            homeInstitutionCourse: {
                courseCode: item.Home_Institution_Course__r.Course_Code__c,
                title: item.Home_Institution_Course__r.Name
            },
            hostInstitutionCourse: {
                courseCode: $scope.selectedCourse.courseCode,
                title: $scope.selectedCourse.courseTitle
            },
            deniedReason: null,
            deniedReasonOther: null,
            status: item.Status__c
        }

        if(ce.status == 'Not a Match')
        {
            var modalInstance = $uibModal.open({
                animation: true,
                size: 'lg',
                backdrop: 'static',
                templateUrl: urlService.getCeModalUrl(),
                resolve: {
                    data: ce
                },
                controller: 'projectCourseDenyModalController'
            });
            
            modalInstance.result.then(function (deniedItem) {
                ce = deniedItem;
                $scope.finalizeStatusUpdate(ce, item);
            }, function() {
                console.log('Denied modal dismissed at: ' + new Date());
            });
        }
        else
        {
            $scope.finalizeStatusUpdate(ce, item);
        }
    }
    $scope.finalizeStatusUpdate = function(ce, item)
    {
        var courseEquivalents = [ce];
        var data = angular.copy(courseEquivalents);
        var promise = projectService.saveCourseEquivalents(data);
        promise.then(function(result){
            // CE records updated
            item.Status__c = ce.status;
            item.Denied_Reason__c = ce.deniedReason;
            item.Denied_Reason_Other__c = ce.deniedReasonOther;
            item.edit = false;
        },
        function(result){
            // CE records not updated
            $scope.loadErrorModal(result);
        })
    }
    $scope.getCity = function(course){
        return courseService.getCourseCity(course);
    }
   $scope.processRightColDetails = function(){
       console.log('--- processRightColDetails start ---');
       console.log('--- selectedCourse items start ---');
       for(key in $scope.selectedCourse){
           console.log(key + ' => ' + $scope.selectedCourse[key]);
       }
       console.log('--- selectedCourse items end ---');
       let classInfo =[];
       /*Start Class Information */
       // Description
       if($scope.selectedCourse.courseDescription){
           classInfo.push({
               name: "Description",
               description: $scope.selectedCourse.courseDescription,
               isOpen: true
           });
       }
       // Learning Objectives
       if($scope.selectedCourse.studentLearningObjectives){
           classInfo.push({
               name: "Learning Objectives",
               description: $scope.selectedCourse.studentLearningObjectives,
               isOpen: false
           });
       }
       // Outline
       if($scope.selectedCourse.courseOutline){
            classInfo.push({
                name: "Outline",
                description: $scope.selectedCourse.courseOutline,
                isOpen: false
            });
        }
        // Evaluation Methods
       if($scope.selectedCourse.evaluationMethod){
            classInfo.push({
                name: "Evaluation Methods",
                description: $scope.selectedCourse.evaluationMethod,
                isOpen: false
            });
        }
        // Resources and Readings
       if($scope.selectedCourse.resourcesReadings){
            classInfo.push({
                name: "Resource and Readings",
                description: $scope.selectedCourse.resourcesReadings,
                isOpen: false
            });
        }
        // Known Prerequisites and Restrictions
        if($scope.selectedCourse.knownPreReqsAndRestrictions){
            classInfo.push({
                name: "Known Prerequisites and Restrictions",
                description: $scope.selectedCourse.knownPreReqsAndRestrictions,
                isOpen: false
            });
        }
        // Additional Notes
        if($scope.selectedCourse.externalNotes){
            classInfo.push({
                name: "Additional Notes",
                description: $scope.selectedCourse.externalNotes,
                isOpen: false
            });
        }
        // Syllabus
        if($scope.selectedCourse.isIFSAClass && $scope.selectedCourse.files.length){
            classInfo.push({
                name: "Syllabus",
                subDetails: $scope.selectedCourse.files,
                description: null,
                isOpen: false,
                type: "Files"
            });
        }
        $scope.classInfo = classInfo;

        console.log('--- processRightColDetails end ---');
    }
    $scope.processLeftColDetails = function(){
        let classDetails = [];
        /* Start Class Details */
        // Course Location(s)
        if($scope.selectedCourse.courseLocations && $scope.selectedCourse.courseLocations.length || $scope.selectedCourse.hostInstitutionName){
            classDetails.push({
                header: "Location of Instruction",
                subDetails: $scope.selectedCourse.courseLocations && $scope.selectedCourse.courseLocations.length ? $scope.selectedCourse.courseLocations : [{Location_of_Instruction__r: {Name : $scope.selectedCourse.hostInstitutionName}}],
                description: null,
                icon: "map marker"
            });
        }
        // Contact Hours
        if($scope.selectedCourse.contactHours){
            classDetails.push({
                header: "Contact Hours",
                subDetails: null,
                description: $scope.selectedCourse.contactHours,
                icon: "university"
            });
        }
        // Lab Hours
        if($scope.selectedCourse.labHours){
            classDetails.push({
                header: "Lab Hours",
                subDetails: null,
                description: $scope.selectedCourse.labHours,
                icon: "flask"
            });
        }
        // Language of Instruction
        if($scope.selectedCourse.languageOfInstruction || $scope.selectedCourse.languageOfInstructionOther){
            classDetails.push({
                header: "Language of Instruction",
                subDetails: null,
                description: $scope.selectedCourse.languageOfInstruction != 'Other' ? $scope.selectedCourse.languageOfInstruction : $scope.selectedCourse.languageOfInstructionOther,
                icon: "comment"
            });
        }
        // Year in Foreign Degree Plan
        if($scope.selectedCourse.yearInForeignDegreePlan || $scope.selectedCourse.yearInForeignDegreePlanOther){
            classDetails.push({
                header: "Year in Foreign Degree Plan",
                subDetails: null,
                description: $scope.selectedCourse.yearInForeignDegreePlan != 'Other' ? $scope.selectedCourse.yearInForeignDegreePlan : $scope.selectedCourse.yearInForeignDegreePlanOther,
                icon: "graduation cap"
            });
        }
        // Class Delivery Method
        if($scope.selectedCourse.courseDeliveryMethod){
            classDetails.push({
                header: "Class Delivery Method",
                subDetails: null,
                description: $scope.selectedCourse.courseDeliveryMethod,
                icon: "users"
            });
        }
        // Approval Required By Host Department
        if($scope.selectedCourse.specialPermissionRequired){
            classDetails.push({
                header: "Approval Required By Host Department",
                subDetails: null,
                description: null,
                icon: "check"
            });
        }
        // Last Renewed Date
        if($scope.selectedCourse.lastRenewedDate){
            classDetails.push({
                header: "Renewed " + $filter('date')($scope.selectedCourse.lastRenewedDate, 'shortDate'),
                subDetails: null,
                description: null,
                icon: "check"
            });
        }
        $scope.classDetails = classDetails;
        /* End Class Details */
        /* Start Learning Component */
        let learningComponents = [];
        if($scope.selectedCourse.capstoneCourseOrProject){
            learningComponents.push("Capstone Course or Project");
        }
        if($scope.selectedCourse.communityBasedLearning){
            learningComponents.push("Community-Based Learning");
        }
        if($scope.selectedCourse.directedResearch){
            learningComponents.push("Directed Research");
        }
        if($scope.selectedCourse.ePortfoilio){
            learningComponents.push("e-Portfolio");
        }
        if($scope.selectedCourse.fieldStudyVisits){
            learningComponents.push("Field Study/Visits");
        }
        if($scope.selectedCourse.internship){
            learningComponents.push("Internship");
        }
        if($scope.selectedCourse.labComponent){
            learningComponents.push("Laboratory Component");
        }
        if($scope.selectedCourse.learningCommunities){
            learningComponents.push("Learning Communities");
        }
        if($scope.selectedCourse.professionalDevelopmentProject){
            learningComponents.push("Professional Development Project");
        }
        if($scope.selectedCourse.serviceLearning){
            learningComponents.push("Service Learning");
        }
        if($scope.selectedCourse.studioArt){
            learningComponents.push("Studio Art");
        }
        if($scope.selectedCourse.teachingPracticum){
            learningComponents.push("Teaching Practicum");
        }
        if($scope.selectedCourse.volunteering){
            learningComponents.push("Volunteering");
        }
        if($scope.selectedCourse.writingIntensive){
            learningComponents.push("Writing Intensive");
        }
        $scope.learningComponents = learningComponents;
    }
});