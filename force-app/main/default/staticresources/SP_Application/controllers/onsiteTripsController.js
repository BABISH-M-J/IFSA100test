/**
 * Student Portal On Site Trips Page Controller
 * @file Student Portal On Site Trips Page Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('onsiteTripsController', function($scope, $modal, urlService, viewModel, tripsService, dateService) 
{
    $scope.urlService = urlService;
    $scope.activePage = 'Trips';
    $scope.trips = [];
    $scope.viewModel = {
        isCustom: viewModel.getViewModel().isCustom,
        applicationStatus: viewModel.getViewModel().applicationStatus,
        locked: viewModel.getViewModel().applicationStatus != 'On Site'
    }

    $scope.getTrips = function(){
        var promise = tripsService.getTrips();
        promise.then(function(result){
            $scope.trips = result;
            // Correct dates before proceding
            if($scope.trips.length){
                for(i=0;i<$scope.trips.length;i++){
                    $scope.trips[i].startDate != null ? $scope.trips[i].startDate = dateService.convertDate($scope.trips[i].startDate) : null;
                    $scope.trips[i].endDate != null ? $scope.trips[i].endDate = dateService.convertDate($scope.trips[i].endDate) : null;
                }
            }
        }, function(result){
            console.log('Could not retrieve trips');
        });
    }

    var d = new Date();
    d.setMinutes(30);
    var newTrip = resetNewTrip();

    correctTripDatesForJS();

    //Trips functions
    function correctTripDatesForJS() {
        angular.forEach($scope.upcomingTrips, function(trip){
            trip.startDate = new Date(trip.startDate.replace(/-/g, '\/').replace(/T.+/, ''));
            trip.endDate = new Date(trip.endDate.replace(/-/g, '\/').replace(/T.+/, ''));
        });
        angular.forEach($scope.pastTrips, function(trip){
            trip.startDate = new Date(trip.startDate.replace(/-/g, '\/').replace(/T.+/, ''));
            trip.endDate = new Date(trip.endDate.replace(/-/g, '\/').replace(/T.+/, ''));
        });
    }

    function resetNewTrip() {
        return {
            travelId: null,
            applicationId: viewModel.getViewModel().applicationId,
            cityName: '',
            contactId: viewModel.getViewModel().contactId,
            countryId: null,
            countryName: '',
            endDate: new Date(d.getFullYear(), d.getMonth(), d.getDay()),
            startDate: new Date(d.getFullYear(), d.getMonth(), d.getDay()),
            description: '',
            localityId: null,
            localityName: '',
            selectedStatus: 'Upcoming',
            statuses: ['Upcoming','Active','Complete'],
            tripName: '',
            tripEmail: $scope.viewModel.studentEmail, //get student's email
            tripPhone: $scope.viewModel.abroadPhoneNumber, //get student's abroad phone
            tripPhoneCountry: $scope.viewModel.abroadPhoneNumberCountry
        };
    }

    //START OF TRAVEL MODAL
    $scope.animationsEnabled = true;
    $scope.open = function (isNewTrip, existingTrip, doDelete) {
        $scope.deleteRecord = doDelete;
        $scope.isNewTrip = isNewTrip;
            if(isNewTrip){
                $scope.thisTrip = resetNewTrip();
            }
        else
        {                                        
            //Need to parse the date string from viewModel
            try
            {
                var sd = existingTrip.startDate.replace(/-/g, '/');
                sd = new Date(sd.match(/\d{4}\/\d{2}\/\d{2}/));
                existingTrip.startDate = sd;
            }
            catch(e){}
            try
            {
                var ed = existingTrip.endDate.replace(/-/g, '/');                            
                ed = new Date(ed.match(/\d{4}\/\d{2}\/\d{2}/));
                existingTrip.endDate = ed;
            }
            catch(e) {} 
            $scope.thisTrip = existingTrip;
        }

        var modalInstance = $modal.open({
            animation: $scope.animationsEnabled,
            size: 'lg',
            templateUrl: 
                urlService.getBaseResourceURL() + '/views/shared/modals/HTML_OnSiteModal.html',
            controller: 'travelModalController',
            resolve: {
                trip: $scope.thisTrip,
                doDelete: doDelete,
            }
        });

        modalInstance.result.then(function (selectedItem) {
            if(selectedItem.constructor === Array)
            {
                angular.forEach(selectedItem, function(trip){
                    //trip.startDate = trip.startDate.getFullYear() + "-" + (trip.startDate.getMonth() + 1) + "-" + (trip.startDate.getDate() + 1);
                    //trip.endDate = trip.endDate.getFullYear() + "-" + (trip.endDate.getMonth() + 1) + "-" + (trip.endDate.getDate() + 1);
                    $scope.upcomingTrips.push(trip);
                });
            }
            else
            {
                if(selectedItem && $scope.deleteRecord)
                {
                    for(var i = $scope.upcomingTrips.length - 1; i >= 0; i--) {
                        if($scope.upcomingTrips[i].travelId === selectedItem.travelId) {
                            $scope.upcomingTrips.splice(i, 1);
                        }
                    }
                }
                else if(selectedItem && !$scope.deleteRecord && $scope.isNewTrip)
                {
                    //selectedItem.startDate = selectedItem.startDate.getFullYear() + "-" + (selectedItem.startDate.getMonth() + 1) + "-" + (selectedItem.startDate.getDate() + 1);
                    //selectedItem.endDate = selectedItem.endDate.getFullYear() + "-" + (selectedItem.endDate.getMonth() + 1) + "-" + (selectedItem.endDate.getDate() + 1);
                    $scope.upcomingTrips.push(selectedItem);
                }
                else if(selectedItem && !$scope.deleteRecord && !$scope.isNewTrip)
                {
                    //selectedItem.startDate = selectedItem.startDate.getFullYear() + "-" + (selectedItem.startDate.getMonth() + 1) + "-" + (selectedItem.startDate.getDate() + 1);
                    //selectedItem.endDate = selectedItem.endDate.getFullYear() + "-" + (selectedItem.endDate.getMonth() + 1) + "-" + (selectedItem.endDate.getDate() + 1);
                    for(var i = $scope.upcomingTrips.length - 1; i >= 0; i--) {
                        if($scope.upcomingTrips[i].travelId === selectedItem.travelId) {
                            $scope.upcomingTrips[i] = selectedItem;
                        }
                    }                    
                }
            }
            
            //$scope.$apply();
        });
    };

    $scope.toggleAnimation = function () {
        $scope.animationsEnabled = !$scope.animationsEnabled;
    };

    $scope.getTrips();
});