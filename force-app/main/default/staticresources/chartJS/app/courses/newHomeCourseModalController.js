/**
 * Chart New Home Course Modal AngularJS Controller
 * @file Chart New Home Course Modal AngularJS Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('newHomeCourseModalController', function($scope, $uibModalInstance, data, viewModel)
{
    console.log('Modal opened at: ' + new Date());
    $scope.data = data;
    $scope.newCourse = {
        CourseCode: '',
        CourseTitle: '',
        CourseDescription: '',
        HomeInstitutionAccount: viewModel.getViewModel().userHomeInstitutionId
    }    

    $scope.save = function()
    {
        
        $uibModalInstance.close($scope.newCourse);
    }
    $scope.closeModal = function()
    {
        
        $uibModalInstance.dismiss(null);
    }
});