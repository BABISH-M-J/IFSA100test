/**
 * Student Portal On Site Trips Modal Controller
 * @file Student Portal On Site Trips Modal Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Jay Holt <jholt@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('classSearchModalController', function ($scope, $modalInstance, viewModel, data, classInterestService, errorModalService, courseRegService)
{
    $scope.init = function(){
        console.log('---classSearchModelController---');
        $scope.data = data;
        $scope.searching = false;
        $scope.newCourse = {
            courseTitle: null,
            courseCode: null,
            courseCredits: null,
            hostInstitutionId: null,
            programId: viewModel.getViewModel().programId
        };    

        $scope.addCustomClass = false;
        $scope.selectedItem = null;
        $scope.viewModel.searchText = '';
        $scope.msgDismissed = false;
        $scope.institutions = [];
        $scope.finalizeResults($scope.data.favorites);
        var promise = courseRegService.getHostInstitutions();
        promise.then(function(result){
            $scope.institutions = result;
            if(result.length == 1)
            {
                $scope.newCourse.hostInstitutionId = result[0].Id;
                //$scope.populateLocationOfInstruction();
            }
            else
            {
                $scope.locations = null;    
            }
        }, function(result){

        });
    }
    
    
    $scope.close = function () {
        $modalInstance.dismiss('cancel');
    };

    $scope.dismissMsg = function(){
        $scope.msgDismissed = true;
    };

    $scope.newClass = function(){
        //console.log('new class');
        $scope.addCustomClass = !$scope.addCustomClass;
    };

    $scope.submitSelection = function() {
        if($scope.addCustomClass)
        {
            var index = $scope.institutions.findIndex(inst => inst.Id == $scope.newCourse.hostInstitutionId);
            $scope.newCourse.hostInstitutionName = $scope.institutions[index].Name;
            var promise = classInterestService.submitNewCourse($scope.newCourse);
            promise.then(function(result){
                $modalInstance.close(result);
            }, function (result){
                errorModalService.openErrorModal('An Error has occured saving this course', result['ErrMsg'] + ' Please try again. If you continue to have problems, contact IFSA. ERROR_1006');
            })
        }
        else{
            $modalInstance.close($scope.selectedItem);
        }
        
    }

    $scope.selectClass = function(selectedClass) {
        $modalInstance.close(selectedClass);
    }

    $scope.searchClasses = function() {
        // Using a search 
        if($scope.viewModel.searchText.length >= 2)
        {
            $scope.searching = true;
            var promise = classInterestService.searchClasses($scope.viewModel.searchText);
            promise.then(function(result){
                $scope.finalizeResults(result);
            }, function(result){

            });
        }
        else if(!$scope.viewModel.searchText.length)
        {
            $scope.finalizeResults($scope.data.favorites);
        }
    }

    $scope.finalizeResults = function(courses) {
        var results = [];
        if(!$scope.viewModel.searchText || $scope.viewModel.searchText == ''){
            for (let index = 0; index < courses.length; index++) {
                const course = courses[index];
                var c = course.Course__r;
                c.isFavorite = true;
                results.push(c);
            }
        }
        else{
            for (let index = 0; index < courses.length; index++) {
                const course = courses[index];
                if(-1 < $scope.data.favorites.findIndex(f => f.Course__c == course.Id)){
                    course.isFavorite = true;
                }
            }
            results = courses;
        }
        for (let index = 0; index < results.length; index++) {
            const result = results[index];
            let selectionIndex = $scope.data.courseList.findIndex(c => c.Id == result.Id);
            if(selectionIndex > -1)
            {
                result.selected = true;
            }
            else
            {
                selectionIndex = $scope.data.courseList.findIndex(c => c.alternateCourse != null && c.alternateCourse.Id == result.Id);
                if(selectionIndex > -1)
                {
                    result.selected = true;
                }
            }
        }
        $scope.classResults = results;
            
    }

    /* $scope.populateLocationOfInstruction = function(){
        if($scope.newCourse.hostInstitutionId){
            let hostInstitution = $scope.institutions.find(h => h.Id == $scope.newCourse.hostInstitutionId);
            if(hostInstitution.Location_of_Instructions__r.length && hostInstitution.Location_of_Instructions__r.length > 1){
                $scope.locations = [];
                $scope.locations.push({Id: null, Name: '-Unknown-'});
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
    } */

    $scope.init();
});