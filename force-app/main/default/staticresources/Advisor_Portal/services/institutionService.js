angular.module('app.services')
.service('institutionService', function($q, $interval, $modal, urlService, $location) {
    let self = this;
    let viewModelPromise = $q.defer();
    let checkJobIntervalPromise;
    let checkJobPromise

    this.loadInstitutionViewModel = function(){
        advisorPortalController.getInstitutionViewModel(
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
    this.getInstitutionViewModel = function(){
        return viewModelPromise.promise;
    }

    this.saveProgAuth = function(changedItems){
        let deferred = $q.defer();

        advisorPortalController.saveProgramAuthorizations(
            angular.toJson(changedItems),
            function(result, event){
                var param = {
                    successful: result,
                    afterSave: true,
                    message: ''
                }
                self.displayConfirmModal(param);
                if(event.status){
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(event)
                }
            }
        );

        return deferred.promise;
    }

    this.search = function(type, homeInstitutionId, selectedCountry, authorization){
        let deferred = $q.defer();
        advisorPortalController.getFilteredPrograms(
            homeInstitutionId,
            selectedCountry,
            authorization,
            function(result, event) {
                if(event.status){
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(event);
                }
            }
        );
        return deferred.promise;
    }

    this.authorizeAllPrograms = function(homeInstitutionAccountId){
        let deferred = $q.defer();
        advisorPortalController.authorizeAllPrograms(
            homeInstitutionAccountId,
            function(result, event)
            {
                if(event.status)
                {
                    var param = {
                        successful: result,
                        afterSave: true,
                        message: 'It may take a moment before all of your changes are visible in the portal. The table will refresh once the change is proigated to the database'
                    }
                    self.displayConfirmModal(param);
                    self.checkJobStatus(result).then(function(result){
                        deferred.resolve(result);
                    }, function(error){
                        deferred.reject(error);
                    });
                }
                else{
                    deferred.reject(event);
                }
            }
        );
        return deferred.promise;
    }

    this.approveUser = function(advisor){
        let deferred = $q.defer();
        advisorPortalController.approveUser(
            advisor,
            function(result, event) {
                var param = {
                    successful: result,
                    afterSave: true,
                    message: ''
                }
                self.displayConfirmModal(param);
                if(event.status) {
                    deferred.resolve(event);
                }
                else{
                    deferred.reject(event);
                }
            }
        );
        return deferred.promise;
    }

    this.disableUser = function(advisor){
        let deferred = $q.defer();

        advisorPortalController.denyUser(
            advisor,
            function(result, event) {
                var param = {
                    successful: result,
                    afterSave: true,
                    message: ''
                }
                self.displayConfirmModal(param);
                if(event.status) {
                    deferred.resolve(event);
                }
                else{
                    deferred.reject(event);
                }
            }
        );
        return deferred.promise;
    }

    this.displayConfirmModal = function(param){
        var modalInstance = $modal.open({
            animation: true,
            templateUrl: urlService.getBaseResourceURL() + '/views/shared/HTML_AdvisorSaveModal.html',
            backdrop: 'static',
            resolve: {
                params: param
            },
            controller: 'confirmModalController'
        });
    }

    this.checkJobStatus = function(jobId){
        if(!checkJobPromise){
            checkJobPromise = $q.defer();
        }
        checkJobIntervalPromise = $interval(function(){
            advisorPortalController.checkJobStatus(
                jobId,
                function(result, event){
                    if(event.status){
                        switch (result.Status) {
                            case 'Holding':
                            case 'Queued':
                            case 'Preparing':
                            case 'Processing':
                                // Job is still processing
                                break;
                            case 'Aborted':
                            case 'Completed':
                            case 'Failed':
                                $interval.cancel(checkJobIntervalPromise);
                                if(result.Status == 'Completed'){
                                    checkJobPromise.resolve(result.Status);
                                }
                                else{
                                    checkJobPromise.reject(result.Status);
                                }    
                                break;                            
                            default:
                                break;
                        }
                    }
                    else{
                        $interval.cancel(checkJobIntervalPromise);
                    }
                }
            );
        }, 500)
        return checkJobPromise.promise;
    }
});