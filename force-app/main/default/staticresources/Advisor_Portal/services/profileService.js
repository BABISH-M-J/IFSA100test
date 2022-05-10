angular.module('app.services')
.service('profileService', function($q, $timeout, $modal, urlService, $location) {
    let self = this;
    let viewModelPromise = $q.defer();

    this.loadProfileViewModel = function(){
        advisorPortalController.getProfileViewModel(
            function(result, event){
                if(event.status){
                    viewModelPromise.resolve(result);
                }
                else{
                    viewModelPromise.reject(event.messge);
                }
            }
        )
        return viewModelPromise.promise;
    }
    this.getProfileViewModel = function(){
        return viewModelPromise.promise;
    }

    this.saveProfile = function(data){
        let deferred = $q.defer();
        advisorPortalController.saveData(
            angular.toJson(data),
            function(result, event) {
                var param = {
                    successful: result,
                    afterSave: true,
                    message: ''
                }
                var modalInstance = $modal.open({
                    animation: true,
                    templateUrl: urlService.getBaseResourceURL() + '/views/shared/HTML_AdvisorSaveModal.html',
                    backdrop: 'static',
                    resolve: {
                        params: param
                    },
                    controller: 'confirmModalController'
                });
                if(event.status){
                    deferred.resolve(event);
                }
                else{
                    deferred.reject(event);
                }
            }
        );
        return deferred.promise;
    }
});