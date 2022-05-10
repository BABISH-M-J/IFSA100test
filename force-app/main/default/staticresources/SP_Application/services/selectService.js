/**
 * Student Portal Select Service
 * @file Student Portal Select Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('selectService', function($q, $modal, urlService) {
    var self = this;
    this.getSelectViewModel = function(){
        var deferred = $q.defer();
        portalRemotingMethods.getSelectViewModel(
            function(result, event){
                if(result){
                    switch (result.applicationStatus) {
                        case 'On Site':
                            result.isOnSite = true;
                        case 'Accepted':
                        case 'Accepted (with Conditions)':
                            result.isAccepted = true;
                        case 'Submitted':
                            result.isApplied = true;
                        case 'Ready to Submit':
                            result.isReadyToSubmit = true;
                        case 'Program Selected':
                            result.isProgramSelected = true;
                        case 'Registered':
                            result.isRegistered = true;                    
                            break;
                        default:
                            break;
                    }
                    deferred.resolve(result)
                }
                else{
                    deferred.reject(result);
                }                
            }
        );
        return deferred.promise;
    }
    this.createApplication = function(programTermId, createNewApp){
        var deferred = $q.defer();

        portalRemotingMethods.createApp(
            programTermId,
            createNewApp,
            function(result, event) {
                var modalInstance = $modal.open({
                    animation: true,
                    templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/HTML_programSelectedModal.html',
                    resolve: {
                        successful: result
                    },
                    controller: 'programSelectedModalController',
                });

                modalInstance.result.then(function(result){
                    deferred.resolve(result);
                }, function(error){
                    deferred.reject(event);
                });
            }
        );

        return deferred.promise;
    }
});