/**
 * Student Portal On Site Housing Page Controller
 * @file Student Portal On Site Housing Page Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('onsiteHousingController', function($scope, $modal, urlService, viewModel, housingService) 
{
    $scope.urlService = urlService;
    $scope.activePage = 'Housing';
    $scope.viewModel = {
        applicationStatus: viewModel.getViewModel().applicationStatus
    }
    $scope.initialize = function() {
        var promise = housingService.getHousingInfo(viewModel.getViewModel().applicationId);
        promise.then(function(result){
            $scope.viewModel = result;
            $scope.viewModel.applicationStatus = viewModel.getViewModel().applicationStatus;
            var slides = $scope.slides = [];
            for(var i=0; i<$scope.viewModel.photos.length; i++)
            {
                slides.push({
                    image: $scope.viewModel.photos[i].image,
                    text: $scope.viewModel.photos[i].text,
                    url: $scope.viewModel.photos[i].url
                })
            }
        },
        function(result){
            console.log('Something went wrong');
        })
        $scope.noWrapSlides = false;
        
        
    }

    $scope.initialize();
});