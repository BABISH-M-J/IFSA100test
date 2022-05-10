/**
 * Chart Upload Course Equivalency File Modal Controller
 * @file Chart Upload Course Equivalency File Modal Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('uploadCEFileModalController', function($scope, $uibModalInstance, settingsFactory)
{
    //$scope.data = data;    
    $scope.explanation = settingsFactory.getCeUploadExplanation();

    $scope.save = function()
    {
        $uibModalInstance.close($scope.fileToUpload);
    }
    $scope.closeModal = function()
    {
        $uibModalInstance.dismiss('cancel');
    }
});