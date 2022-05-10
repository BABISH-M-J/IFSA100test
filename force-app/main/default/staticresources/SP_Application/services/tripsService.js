/**
 * Student Portal Trips Service
 * @file Student Portal Trips Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('tripsService', function($q, $timeout, viewModel) {
    var self = this;

    this.getTrips = function(){
        var deferred = $q.defer();
        var applicationId = viewModel.getViewModel().applicationId;
        portalOnSiteRemotingMethods.getTrips(
            applicationId,
            function(result, event) {
                if(result)
                {
                    deferred.resolve(result);
                }
                else
                {
                    deferred.reject(event);
                }
            }
        );
        return deferred.promise;
    }

    this.saveTrip = function(trip){
        var deferred = $q.defer();
        portalOnSiteRemotingMethods.saveTrip(
            angular.toJson(trip),
                function(result, event) {
                    if(result)
                    {
                        deferred.resolve(result);
                    }
                    else
                    {
                        deferred.reject(event);
                    }
            }
        );
        return deferred.promise;
    }

    this.deleteTrip = function(trip){
        var deferred = $q.defer();

        portalOnSiteRemotingMethods.deleteTrip(
            trip.travelId,
            function(result, event) {
                if(result)
                {
                    deferred.resolve(result);
                }
                else
                {
                    deferred.reject(event);
                }
            }
        );

        return deferred.promise;
    }
});