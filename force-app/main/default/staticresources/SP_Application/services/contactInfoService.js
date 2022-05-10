/**
 * Student Portal Contact Info Service
 * @file Student Portal Contact Info Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('contactInfoService', function($q, $timeout, viewModel) {
    var self = this;

    this.updateAbroadPhoneNumber = function(abroadPhoneNumber, abroadPhoneNumberCountry, contactId) {
        var deferred = $q.defer();
        portalOnSiteRemotingMethods.updateAbroadPhoneNumber(
            abroadPhoneNumber,
            abroadPhoneNumberCountry.Id,
            contactId,
            function(result, event){
                if(result)
                {
                    deferred.resolve(result);
                }
                else
                {
                    deferred.reject(null);
                }
            }
        );
        return deferred.promise;
    }

    this.updateProfileInfo = function(data) {
        var deferred = $q.defer();
        portalRemotingMethods.saveAddresses(
            angular.toJson(data),
            function(result, event){
                if(result.isSuccess)
                {
                    deferred.resolve(result);
                }
                else
                {
                    deferred.reject(result);
                }
            }
        );
        return deferred.promise;
    }

    this.getProfileInfo = function() {
        var deferred = $q.defer();
        portalRemotingMethods.getProfileInfo(
            function(result, event){
                if(result)
                {
                    deferred.resolve(result);
                }
                else
                {
                    deferred.reject(null);
                }
            }
        );
        return deferred.promise;
    }
    
});