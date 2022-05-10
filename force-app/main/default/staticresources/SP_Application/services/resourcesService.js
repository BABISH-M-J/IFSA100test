/**
 * Student Portal Resources Service
 * @file Student Portal Resources Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('resourcesService', function($q, $timeout, viewModel) {
    var self = this;

    this.getApplicationResources = function(){
        var deferred = $q.defer();
        // Get resources
        portalRemotingMethods.getApplicationResources(
            viewModel.getViewModel().applicationId,
            function(result, event) {
                if(result){
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(event);
                }
            }
        )

        return deferred.promise;
    }

});