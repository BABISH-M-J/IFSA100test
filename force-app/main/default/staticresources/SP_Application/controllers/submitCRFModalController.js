/**
* Yes No Modal Controller Controller
* @file Yes No Modal Controller Controller
* @copyright 2019 Institute for Study Abroad
* @author Brock Barlow <bbarlow@ifsa-butler.org>
* @version 2.0
*/
angular.module('app.controllers')
.controller('submitCRFModalController', function ($scope, $modal, urlService, viewModel, $modalInstance, courseRegService, data)
{
    $scope.data = data;
    $scope.spanishTitles = courseRegService.getSpanishTitles();

    $scope.close = function () {
        $modalInstance.dismiss('cancel');
    };

    $scope.submit = function() {
        $modalInstance.close('yes');
    }

    $scope.addClass = function () {
        var modalInstance = $modal.open({
            animation: true,
            size: 'lg',
            backdrop: 'static',
            templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/addClassModal.html',
            resolve: {
                data: {
                    title: 'Add Class',
                    institutions: data.viewModel.institutions,
                    isSubmitting: true,
                    spanishTitles: courseRegService.getSpanishTitles()
                }
            },
            controller: 'addClassModalController'
        });

        modalInstance.result.then(function(result){
            // Actions when modal is submitted
            // Add status to newCourse and push to viewModel.courses
            var newCourse = result;
            newCourse.courseTitle = newCourse.courseName;
            newCourse.courseStatus = "Not Registered";
            data.viewModel.courses.push(newCourse);
        }, function(result) {
            // Actions when modal is cancelled
        });
    }

    $scope.removeClass = function (item) {
        var index = data.viewModel.courses.indexOf(item);
        data.viewModel.courses.splice(index, 1);
    }
})