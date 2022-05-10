/**
 * Student Portal On Site Contact Info Page Controller
 * @file Student Portal On Site Contact Info Page Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('onsiteContactInfoController', function($scope, $modal, urlService, viewModel, contactInfoService) 
{
    $scope.urlService = urlService;
    $scope.activePage = 'ContactInfo';
    $scope.onSiteAlerts = [];

    $scope.viewModel = {
        isCustom: viewModel.getViewModel().isCustom,
        phoneCountries: viewModel.getViewModel().phoneCountries,
        applicationStatus: viewModel.getViewModel().applicationStatus
    }

    $scope.setCountryCode = function(country) {
        $scope.viewModel.abroadPhoneNumber = country.Phone_Code__c != null ? "+" + country.Phone_Code__c : "";
    }

    $scope.updateAbroadPhoneNumber = function() {
        var promise = contactInfoService.updateAbroadPhoneNumber($scope.viewModel.abroadPhoneNumber, $scope.viewModel.abroadPhoneNumberCountry, viewModel.getViewModel().contactId);
        promise.then(function(result){
            $scope.onSiteAlerts.push({ type: 'success', msg: 'Phone number while abroad has saved successfully!' });
        },
        function(result){
            $scope.onSiteAlerts.push({ type: 'danger', msg: 'Phone number while abroad did not save successfully!' });
        })
    }

    $scope.closeOnSiteAlert = function(index) {
        $scope.onSiteAlerts.splice(index, 1);
    };
});