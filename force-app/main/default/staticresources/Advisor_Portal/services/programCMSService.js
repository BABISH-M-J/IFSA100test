angular.module('app.services')
.service('programCMSService', function($q, $filter) {
    let self = this;
    let _cmsData = [];
    let _loadingPromise;

    this.getProgramCMSfromSalesforce = function(){
        _loadingPromise = $q.defer();
        advisorPortalController.getProgramCMS(
            function(result, event){
                if(event.status){
                    _cmsData = result;
                    _loadingPromise.resolve();
                }
                else{
                    _loadingPromise.reject();
                }
        });
        return _loadingPromise.promise;
    }

    this.getProgramCMSRecord = function(cmsId){
        return _cmsData.find(cms => cms.Id == cmsId);
    }

    this.loadingPromise = function(){
        return _loadingPromise.promise;
    }
})