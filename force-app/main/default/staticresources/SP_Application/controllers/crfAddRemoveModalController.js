/**
* Student Portal On Site Academics Add / Remove Class Modal
* @file Student Portal On Site Academics Add / Remove Class Modal
* @copyright 2019 Institute for Study Abroad
* @author Brock Barlow <bbarlow@ifsa-butler.org>
* @version 2.0
*/
angular.module('app.controllers')
.controller('crfAddRemoveModalController', function ($scope, $modalInstance, data, courseRegService)
{
    $scope.init = function(){
        $scope.data = data;
        $scope.data.course = angular.copy($scope.data.course);
        var promise = courseRegService.getChildCourses($scope.data.course.courseId);
        promise.then(function(result){
            // Resolved
            $scope.data.course.childClasses = result;
            if($scope.data.course.childClasses && data.type != 'Remove') {
                $scope.data.course.parent = true;
            }
        }, function(result){
            // Rejection
            
            console.log('courseRegService.getChildCourses failed');
        })
        $scope.response = {};
        $scope.populateLocationOfInstruction();
    }

    $scope.submit = function()
    {
        if(data.type == 'Remove')
        {
            $scope.data.course.notRegisteredReason = $scope.response.reason;
            $scope.data.course.notRegisteredReasonOther = $scope.response.reasonOtherExplanation;
        }
        if(data.type == 'OtherClass')
        {
            $scope.data.course.otherClassReason = $scope.response.reason;
            $scope.data.course.otherClassReasonOther = $scope.response.reasonOtherExplanation;
        }
        $modalInstance.close($scope.data.course);
    }

    $scope.close = function () {
        $modalInstance.dismiss('cancel');
    };

    $scope.populateLocationOfInstruction = function(){
        if($scope.data.course.hostInstitutionId && $scope.data.type == 'Add'){
            let hostInstitution = $scope.data.institutions.find(h => h.Id ==  $scope.data.course.hostInstitutionId);
            $scope.data.oxbridge = hostInstitution.Uses_Oxbridge_Tutorials__c;
            if(hostInstitution.Location_of_Instructions__r && hostInstitution.Location_of_Instructions__r.length && hostInstitution.Location_of_Instructions__r.length > 1){
                $scope.locations = [];
                $scope.locations.push({Id: null, Name: '-Unknown-'});
                for (let index = 0; index < hostInstitution.Location_of_Instructions__r.length; index++) {
                    const element = hostInstitution.Location_of_Instructions__r[index];
                    $scope.locations.push(element);                    
                }
            }
            else if(hostInstitution.Location_of_Instructions__r && hostInstitution.Location_of_Instructions__r.length && hostInstitution.Location_of_Instructions__r.length == 1)
            {
                $scope.locations = hostInstitution.Location_of_Instructions__r;
            }
        }
    }

    $scope.changeCourseRegistration = function() {
        var promise = courseRegService.updateCourseReg($scope.data.course.courseId);
        promise.then(function(result){
            // Resolved
            $scope.data.course.courseTitle = result.Course_Title_2__c;
            $scope.data.course.courseCode = result.Course_Code__c;
            $scope.data.course.hostInstitutionName = result.Host_Institution__r.Name;
            $scope.data.course.credits = result.Host_Credits__c;
            $scope.data.course.usCredits = result.US_Semester_Credit_Hours__c;
            $scope.data.course.parent = false;
        }, function(result){
            // Rejection
            
        })

    };


    $scope.init();
})