/**
 * Student Portal On Site Trips Modal Controller
 * @file Student Portal On Site Trips Modal Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('travelModalController', function ($scope, $modalInstance, trip, doDelete, viewModel, tripsService)
{
    $scope.alerts = [];
    $scope.delete = doDelete;
    $scope.trip = angular.copy(trip);
    $scope.trip.startDate = new Date();
    $scope.trip.endDate = new Date();
    try
    {
        $scope.trip.tripPhoneCountry = trip.tripPhoneCountry.Id;   
    }
    catch(exception)
    {
        console.log($scope.trip.tripPhoneCountry);
    }
    $scope.newTripsList = [];
    var vm = viewModel.getViewModel();
    $scope.phoneCountries = vm.phoneCountries;
    $scope.cityPlaceholder = "Choose a country first";

    $scope.closeAlert = function(index) {
        $scope.alerts.splice(index, 1);
    };

    $scope.addTrip = function() {
        $scope.save('multi');
    }

    $scope.save = function (saveType) {
        $scope.saveType = saveType;
        var promise = tripsService.saveTrip($scope.trip);
        promise.then(function(result){
            $scope.saveFinished(result, null);
        }, function(result){
            $scope.saveFinished(null, result);
        })
    };

    $scope.saveFinished = function (result, event) {
        if(result)
        {
            $scope.trip.travelId = result;
            if($scope.saveType == 'single' && $scope.newTripsList.length < 1)
            {
                $modalInstance.close($scope.trip);
            }
            else
            {
                $scope.newTripsList.push($scope.trip);
                $scope.trip = angular.copy(trip);
                $scope.trip.startDate = $scope.newTripsList[$scope.newTripsList.length - 1].endDate;
                if($scope.saveType == 'single')
                {
                    $scope.done();
                }
            }
        }
        else
        {
            $scope.alerts.push({ type: 'danger', msg: 'Trip did not save. Please try again.' });
        }
        //$scope.$apply();
    };

    $scope.yes = function (trip) {
        var promise = tripsService.saveTrip(trip);
        promise.then(function(result){
            $scope.deleteFinished(result, null);
        }, function(result){
            $scope.deleteFinished(null, result);
        })
    };

    $scope.deleteFinished = function (result, event) {
        if(result)
        {
            $modalInstance.close($scope.trip);
        }
        else
        {
            $scope.alerts.push({ type: 'danger', msg: 'Trip did not delete. Please try again.' });
            //$scope.$apply();
        }
    };

    $scope.startDateChanged = function () {
        if($scope.trip.endDate < $scope.trip.startDate) 
        {
            $scope.trip.endDate = $scope.trip.startDate;
        }
    }

    $scope.cancel = function () {
        //$scope.trip = originalTrip
        $modalInstance.dismiss('cancel');
    };

    $scope.done = function () {
        //$scope.trip = originalTrip
        $modalInstance.close($scope.newTripsList);
    };

    //Search for countries
    $scope.searchForCountries = function() {
        portalRemotingMethods.searchForRecord(
            'Country__c',
            $scope.trip.countryName,
            function(result, event) {
            $scope.populateCountryDropdown(result, event);
            }
        );
    }

    //Once country results have come back, populate
    $scope.populateCountryDropdown = function(result, event) {
        $scope.countryResults = result;
        $scope.$apply();
    }

    //Select a country
    $scope.selectCountry = function(item) {                
        $scope.trip.countryId = item.id;
        $scope.trip.countryName = item.name;
    }

    //Search for cities
    $scope.searchForCities = function() {
        portalRemotingMethods.searchForRecordWithRecordType(
            'Locality__c',
            $scope.trip.localityName,
            $scope.trip.countryName,
            function(result, event) {
                $scope.populateCityDropdown(result, event);
            }
        );
    }

    //Once city results have come back, populate
    $scope.populateCityDropdown = function(result, event) {
        $scope.cityResults = result;
        $scope.$apply();
    }

    //Select a city
    $scope.selectCity = function(item) {                
        $scope.trip.localityId = item.id;
        $scope.trip.localityName = item.name;
    }
});