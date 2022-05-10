/**
* Student Portal On Site Academics Upload Class Syllabus Modal
* @file Student Portal On Site Academics Upload Class Syllabus Modal
* @copyright 2019 Institute for Study Abroad
* @author Brock Barlow <bbarlow@ifsa-butler.org>
* @version 2.0
*/
angular.module('app.controllers')
.controller('syllbusUploadModalController', function ($scope, $modalInstance, data, courseRegService)
{
    $scope.data = data;
    $scope.hasError = false;
    
    $scope.submit = function()
    {
        var promise = courseRegService.submitSyllabus($scope.fileToUpload, $scope.data.courseId);
        promise.then(function(result){
            $scope.hasError = false;
            $modalInstance.close('success');
        }, function(result){
            $scope.hasError = true;
        });        
    }

    $scope.close = function () {
        $modalInstance.dismiss('cancel');
    };
})