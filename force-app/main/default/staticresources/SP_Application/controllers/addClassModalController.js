/**
* Add Class Controller Controller
* @file Add Class Controller Controller
* @copyright 2019 Institute for Study Abroad
* @author Jay Holt <jholt@ifsa-butler.org>
* @version 1.0
*/
angular.module('app.controllers')
.controller('addClassModalController', function ($scope, $modalInstance, data, $filter, courseRegService, viewModel)
{
    console.log('-- addClassModalController --');

    $scope.data = data;
    // suggestion by powerfluence 0001 starts here
    $scope.selectedHostInstitution = '';
    // suggestion by powerfluence 0001 ends here
    // Added by powerfluence - req dt.02/16/2022 - 001 - starts
    $scope.loading=false;
    // Added by powerfluence - req dt.02/16/2022 - 001 - ends
    // Added by powerfluence - req dt.02/09/2022 - 001 - starts
    $scope.closeModal = false;
    // Added by powerfluence - req dt.02/09/2022 - 001 - ends
    if(data.isSubmitting){
        $scope.response = {};
        $scope.data.reasons = courseRegService.getNotRegisteredReasons()
    }

    $scope.close = function () {
        $modalInstance.dismiss('cancel');
    };

    $scope.submit = function() {
        console.log('--- submit ---');
        if(!$scope.newCourse.existingCourse){
            $scope.newCourse.courseName = $scope.newCourse.encodedCourseName;
        }
        if(data.isSubmitting){
            console.log('--- Data is submitting ---');
            $scope.newCourse.notRegisteredReason = $scope.response.reason;
            $scope.newCourse.notRegisteredReasonOther = $scope.response.reasonOtherExplanation;
        }
        // commented by powerfluence - req dt.02/09/2022 - 002 - starts
        // $modalInstance.close($scope.newCourse);
        // commented by powerfluence - req dt.02/09/2022 - 002 - ends
    };

    $scope.submitNewCourse = function(){
        $scope.loading=true;
        console.log('--- submitNewCourse ---');
        if(!$scope.newCourse.existingCourse){
            console.log('--- No existing course ---');
            $scope.newCourse.courseName = $scope.newCourse.encodedCourseName;
            $scope.newCourse.hostInstitutionName = $scope.newCourse.Name;
            // put appId value here
            var appId = viewModel.getViewModel().applicationId;
            for(key in $scope.newCourse){
                console.log(key + ' => ' + $scope.newCourse[key]);
            }
            // modified by powerfluence - req dt.01/28/2022 - 001 - starts
            // courseRegService.createCourseRegistration($scope.newCourse, appId);
            // courseRegService.getCourseRegistrations();

            // modified by powerfluence - req dt.02/09/2022 - 001 - starts
            var promiseCourseRegistration = courseRegService.createCourseRegistration($scope.newCourse, appId);
            promiseCourseRegistration.then(
                function (result) {
                    console.log('result',result);
                    $scope.newCourse.createdCourseId = result;
                    var promiseGetCourseRegistrations = courseRegService.getCourseRegistrations();
                    promiseGetCourseRegistrations.then(
                        function (result) {
                            console.log('result',result);
                            $scope.closeModal = true;
                        }, function (error) { //promiseGetCourseRegistrations
                            console.log('error',error);
                            $scope.closeModal = true;
                        } //promiseGetCourseRegistrations - error
                    ); //promiseGetCourseRegistrations
                }, function (error) {  //promiseCourseRegistration
                    console.log('error',error);
                    $scope.closeModal = true;
                }  //promiseCourseRegistration - error
            ); //promiseCourseRegistration
            // modified by powerfluence - req dt.02/09/2022 - 001 - ends
            
            // commented by powerfluence - req dt.02/09/2022 - 001 - starts
            /*
            courseRegService.createCourseRegistration($scope.newCourse, appId).then(
                function (result) {
                    courseRegService.getCourseRegistrations().then(
                        function (result) {
                            
                        }, function(error) {

                        }
                    );
                }, function (error) {

                }
            );
            */
            // commented by powerfluence - req dt.02/09/2022 - 001 - ends

            // modified by powerfluence - req dt.01/28/2022 - 001 - ends
            // Experimental 
            //$scope.newCourse = item;
            //$scope.newCourse.existingCourse = true;
            //var title = $filter('ampersand')(item.courseName);
            //title = $filter('apostraphe')(title);
            //$scope.newCourse.encodedCourseName = title;
            //$scope.newCourse.untranslatedCourseTitle = item.untranslatedTitle;
            //$scope.newCourse.hostInstitutionId = item.hostInstitutionId;
            //$scope.newCourse.hostInstitutionName = item.hostInstitutionName;
            //console.log('newCourse.hostInstitutionName => ' + $scope.newCourse.hostInstitutionName);
            // Added by powerfluence - req dt.02/09/2022 - 002 - starts
        } else {
            $scope.newCourse.createdCourseId = $scope.newCourse.courseId;
            $scope.closeModal = true;
            // Added by powerfluence - req dt.02/09/2022 - 002 - ends
        }
        if(data.isSubmitting){
            console.log('--- Data is submitting ---');
            $scope.newCourse.notRegisteredReason = $scope.response.reason;
            $scope.newCourse.notRegisteredReasonOther = $scope.response.reasonOtherExplanation;
        }
        // commented by powerfluence - req dt.02/09/2022 - 003 - starts
        // $modalInstance.close($scope.newCourse);
        // commented by powerfluence - req dt.02/09/2022 - 003 - ends
    };

    // Added by powerfluence - req dt.02/09/2022 - 003 - starts
    $scope.$watch(function(scope) { return scope.closeModal; },
        function(newValue, oldValue) {
            if(newValue){
                $scope.loading=false;
            $modalInstance.close($scope.newCourse);
            }
        }
        );
    // Added by powerfluence - req dt.02/09/2022 - 003 - starts

    //Search for courses
    $scope.searchForCourses = function() {
        // Experimental start
        console.log('---searchCourses---')
        console.log('newCourse => ' , $scope.newCourse);
        console.log('hostInstitutionId => ' + $scope.newCourse.hostInstitutionId);
        let hostInstitution = $scope.data.institutions.find(h => h.Id == $scope.newCourse.hostInstitutionId);
        /*console.log('--- hostInsitution data start ---');
            for(key in hostInstitution){
                console.log(key + ' => ' + hostInstitution[key]);
            }
            console.log('--- hostInstitution data end ---');*/
        // Experimenta end
        
        var promise = courseRegService.searchCourses($scope.newCourse.hostInstitutionId, $scope.newCourse.encodedCourseName, 'Course_Title_2__c');
        promise.then(function(result){
            $scope.courseResults = result;
            //console.log('courseResults => ' + $scope.courseResults);
        }, function(result){

        });
    }
    // Search for untranslated courses
    $scope.searchForCoursesUntranslated = function() {
        var promise = courseRegService.searchCourses($scope.newCourse.hostInstitutionId, $scope.newCourse.untranslatedCourseTitle, 'Untranslated_Course_Title__c');
        promise.then(function(result){
            $scope.untranslatedCourseResults = result;
        }, function(result){

        });
    }

    //Select a course
    $scope.selectCourse = function(item) {
        // modified by powerfluence - req dt.01/28/2022 - 003 - starts
        $scope.newCourse = Object.assign({}, item);
        // modified by powerfluence - req dt.01/28/2022 - 003 - ends
        $scope.newCourse.existingCourse = true;
        var title = $filter('ampersand')(item.courseName);
        title = $filter('apostraphe')(title);
        $scope.newCourse.encodedCourseName = title;
        $scope.newCourse.untranslatedCourseTitle = item.untranslatedTitle;
        $scope.newCourse.hostInstitutionId = item.hostInstitutionId;
        $scope.newCourse.hostInstitutionName = item.hostInstitutionName;
        console.log('newCourse.hostInstitutionName => ' + $scope.newCourse.hostInstitutionName);
    }

    $scope.populateLocationOfInstruction = function(){
        console.log('--- populateLocationOfInstruction ---');
        if($scope.newCourse.hostInstitutionId){
            console.log('--- newCourse.hostInstitutionId exists ---');
            let hostInstitution = $scope.data.institutions.find(h => h.Id == $scope.newCourse.hostInstitutionId);
            for(key in hostInstitution){
                console.log(key + ' => ' + hostInstitution[key]);
            }
            $scope.data.oxbridge = hostInstitution.Uses_Oxbridge_Tutorials__c;
            console.log('oxbridge => ' + $scope.data.oxbridge);
            if(!hostInstitution.Location_of_Instructions__r){
                $scope.locations = [];
                $scope.locations.push({Id: '000000000000000', Name: '-Unknown-'});
            }
            else if(hostInstitution.Location_of_Instructions__r && hostInstitution.Location_of_Instructions__r.length && hostInstitution.Location_of_Instructions__r.length > 1){
                $scope.locations = [];
                $scope.locations.push({Id: '000000000000000', Name: '-Unknown-'});
                for (let index = 0; index < hostInstitution.Location_of_Instructions__r.length; index++) {
                    const element = hostInstitution.Location_of_Instructions__r[index];
                    $scope.locations.push(element);                    
                }
            }
            else if(hostInstitution.Location_of_Instructions__r.length && hostInstitution.Location_of_Instructions__r.length == 1)
            {
                $scope.locations = hostInstitution.Location_of_Instructions__r;
            }
        }
    }


    $scope.populateLocationOfInstruction = function(newItem){
        console.log('--- populateLocationOfInstruction ---');
        //if($scope.newCourse.hostInstitutionId){
        if(newItem){
            console.log('--- newItem exists ---');
            // suggestion by powerfluence 0002 starts here
            // let hostInstitution = $scope.data.institutions.find(h => h.Id == newItem);
            // console.log('newItem => ' + newItem);
            let hostInstitution = newItem;
            console.log('newItem => ', newItem);
            // suggestion by powerfluence 0002 ends here
            console.log('--- hostInstitutions start ---');
            for(key in hostInstitution){
                console.log(key + ' => ' + hostInstitution[key]);
            }
            console.log('--- hostInstitutions end ---');
            $scope.newCourse.hostInstitution = hostInstitution;
            $scope.newCourse.hostInstitution.Name = hostInstitution.Name;
            console.log('newCourse.hostInstitution.Id => ' + $scope.newCourse.hostInstitution.Id);
            $scope.newCourse.hostInstitutionId = $scope.newCourse.hostInstitution.Id;
            console.log('--- hostInstitution info start ---');
            for(key in hostInstitution){
                console.log(key + ' => ' + hostInstitution[key]);
            }
            console.log('--- hostInstitution info end ---');
            $scope.data.oxbridge = hostInstitution.Uses_Oxbridge_Tutorials__c;
            console.log('oxbridge => ' + $scope.data.oxbridge);

            // Clear fields
            $scope.newCourse.encodedCourseName = null;
            $scope.newCourse.untranslatedCourseTitle = null;
            $scope.newCourse.courseCode = null;
            $scope.newCourse.credits = null;
            $scope.newCourse.instructorFirstName = null;
            $scope.newCourse.instructorLastName = null;

            if(!hostInstitution.Location_of_Instructions__r){
                $scope.locations = [];
                $scope.locations.push({Id: '000000000000000', Name: '-Unknown-'});
            }
            else if(hostInstitution.Location_of_Instructions__r && hostInstitution.Location_of_Instructions__r.length && hostInstitution.Location_of_Instructions__r.length > 1){
                $scope.locations = [];
                $scope.locations.push({Id: '000000000000000', Name: '-Unknown-'});
                for (let index = 0; index < hostInstitution.Location_of_Instructions__r.length; index++) {
                    const element = hostInstitution.Location_of_Instructions__r[index];
                    $scope.locations.push(element);                    
                }
            }
            else if(hostInstitution.Location_of_Instructions__r.length && hostInstitution.Location_of_Instructions__r.length == 1)
            {
                $scope.locations = hostInstitution.Location_of_Instructions__r;
            }
        }
    }

    //EXPERIMENTAL
    $scope.initPopulateLocationOfInstruction = function(){
        
        console.log('--- initPopulateLocationOfInstruction ---');
        if($scope.newCourse.hostInstitutionId){
            console.log('--- newCourse.hostInstitutionId exists ---');
            let hostInstitution = $scope.data.institutions.find(h => h.Id == $scope.newCourse.hostInstitutionId);
            console.log('--- hostInstitution => ' + hostInstitution);
            console.log('--- hostInsitution data start ---');
            for(key in hostInstitution){
                console.log(key + ' => ' + hostInstitution[key]);
            }
            console.log('--- hostInstitution data end ---');
            $scope.data.oxbridge = hostInstitution.Uses_Oxbridge_Tutorials__c;
            console.log('oxbridge => ' + $scope.data.oxbridge);

            // Clear fields
            $scope.newCourse.encodedCourseName = null;
            $scope.newCourse.untranslatedCourseTitle = null;
            $scope.newCourse.courseCode = null;
            $scope.newCourse.credits = null;
            $scope.newCourse.instructorFirstName = null;
            $scope.newCourse.instructorLastName = null;

            if(!hostInstitution.Location_of_Instructions__r){
                $scope.locations = [];
                $scope.locations.push({Id: '000000000000000', Name: '-Unknown-'});
            }
            else if(hostInstitution.Location_of_Instructions__r && hostInstitution.Location_of_Instructions__r.length && hostInstitution.Location_of_Instructions__r.length > 1){
                $scope.locations = [];
                $scope.locations.push({Id: '000000000000000', Name: '-Unknown-'});
                for (let index = 0; index < hostInstitution.Location_of_Instructions__r.length; index++) {
                    const element = hostInstitution.Location_of_Instructions__r[index];
                    $scope.locations.push(element);                    
                }
            }
            else if(hostInstitution.Location_of_Instructions__r.length && hostInstitution.Location_of_Instructions__r.length == 1)
            {
                $scope.locations = hostInstitution.Location_of_Instructions__r;
            }
        }
    }

    //$scope.initPopulateLocationOfInstruction();


    angular.element(document).ready(function(){
        console.log('--- Document Ready ---');

        $scope.initialCourse = {
            courseTitle: null,
            courseCode: null,
            courseCredits: null,
            hostInstitutionId: null,
            programId: viewModel.getViewModel().programId
        };

        console.log('Data.Institutions => ' + $scope.data.institutions);
        for(item in $scope.data.institutions){
            console.log('item => ' + item);
            if(item == 0){
                console.log('FIRST=> ' + $scope.data.institutions[item]);
                console.log('testCourse => ', $scope.data.institutions[item]);
                // modified by powerfluence - req dt.01/28/2022 - 002 - starts
                $scope.newCourse = Object.assign({}, $scope.data.institutions[item]);
                // modified by powerfluence - req dt.01/28/2022 - 002 - ends
                //$scope.initialCourse.hostInstitutionId = $scope.newCourse['Id'];
                $scope.newCourse.hostInstitutionId = $scope.newCourse['Id'];
                //$scope.populateLocationOfInstruction();
                console.log('initCourse => ' + $scope.initialCourse.hostInstitutionId);
                /*for(key in $scope.newCourse){
                    console.log(key + ' => ' + $scope.newCourse[key]);
                }*/
            }            
        }
        
        $scope.populateLocationOfInstruction();
        $scope.initPopulateLocationOfInstruction();
        courseRegService.getCRFConfiguration();
    });
})