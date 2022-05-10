/**
 * Student Portal Application Service
 * @file Student Portal Application Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('applicationService', function($q, $timeout, viewModel, $modal, urlService, $location) {
    var self = this;
    var application;
    var applicationPromise;
    var loadApplicationsPromise;
    var applications;

    this.getApplicationFromSF = function(appId)
    {
        applicationPromise = $q.defer();

        portalRemotingMethods.getApplication(
            appId,
            function(result, event) {
                if(result) {
                    application = result;
                    applicationPromise.resolve(application);
                }
                else {
                    application = null;
                    applicationPromise.reject(event);
                }
        });
        return applicationPromise.promise;
    }

    this.getApplication = function() {
        return application;
    }

    this.getApplicationPromise = function() {
        return applicationPromise.promise;
    }

    this.getHostInstitutions = function() {
        var deferred = $q.defer();

        portalRemotingMethods.searchHostInstitutions(
            null,
            application.Program_Term__r.Program__c,
            function(result, event)
            {
                if(result){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }
            }
        )

        return deferred.promise;
    }

    this.getLoadApplicationsPromise = function() {
        if(loadApplicationsPromise)
        {
            return loadApplicationsPromise;
        }
        return self.loadApplications();
    }

    this.loadApplications = function() {
        loadApplicationsPromise = $q.defer();
        let vm = viewModel.getViewModel();
        if(vm){
            portalRemotingMethods.getApplicationsJS(
                viewModel.getViewModel().contactId, 
                function(result, event) {
                    if(!result){
                        loadApplicationsPromise.reject(event);
                    }
                    applications = result;
                    loadApplicationsPromise.resolve(applications);
                }
            );
        }
        else{
            $location.path('/SP_Login');
        }

        return loadApplicationsPromise.promise;
    }
    this.getApplications = function() {
        if(applications){
            return applications;
        }
    }

    this.switchApplication = function() 
    {
        let promise = this.loadApplications();
        promise.then(function(result){
            var modalInstance = $modal.open({
                animation: true,
            size: 'lg',
            templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/HTML_SwitchApplication.html',
            resolve: {
                    data: self.getApplications()
                },
                controller: 'switchApplicationModalController'
            });
        }, function(result){
            console.log('Could not load applications');
        })
        
    }

    this.isRegistered = function(status){
        return status != null && status != 'New';
    }
    this.isProgramSelected = function(status){
        return status != null && status != 'New' && status != 'Registered';
    }
    this.isReadyToSubmit = function(status){
        return status != null && status == 'Ready to Submit';
    }
    this.isApplied = function(status){
        return status != null && status != 'New' && status != 'Registered' && status != 'Program Selected';
    }
    this.isAccepted = function(status){
        return status.indexOf('Accepted') > -1;
    }

});