angular.module('app.services')
.service('studentsService', function($q, $timeout, $modal, urlService, $location, viewModel) {
    let self = this;
    let viewModelPromise = $q.defer();
    let statusDefinitions = viewModel.getViewModel().statusDefinitions;
    let housingOptions = [];

    this.loadStudentsViewModel = function(){
        advisorPortalController.getStudentsViewModel(
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
    this.getStudentsViewModel = function(){
        return viewModelPromise.promise;
    }

    this.search = function(selectedTerm, selectedYear, selectedCountry, selectedStatus, onlyProgramApproval, searchString){
        let deferred = $q.defer();
        advisorPortalController.searchForStudents(
            selectedTerm,
            selectedYear,
            selectedCountry,
            selectedStatus,
            onlyProgramApproval,
            searchString,
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

    this.searchForStudents = function(section, year,
        country, status,
        onlyProgramApproval, nameToSearch,
        currentPage, pageSize, otherOptions){
        let homeInstitutionId = viewModel.getViewModel().homeInstitutionId;
        let deferred = $q.defer();
        // getstudentssearch
        // getStudentsSearch(Id homeInstitutionId, String section, String year, String country, String status, Boolean onlyProgramApproval, String nameToSearch,Integer currentPage,Integer pageSize)
        // advisorPortalController.searchForStudents(
        advisorPortalController.getStudentsSearch(
            homeInstitutionId, section, year, country, status, onlyProgramApproval, nameToSearch, currentPage, pageSize, otherOptions,
            function(result, event) {
                if(event.status){
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(event);
                }
            },{ buffer: false, escape: true, timeout: 30000 }
        );
        return deferred.promise;
    }

    this.getAppItem = function(itemId){
        let deferred = $q.defer();
        portalRemotingMethods.getApplicationItemDetails(
            itemId, 
            function(result, event) {
                if(event.status){
                    deferred.resolve(result);
                }
            }
        );

        return deferred.promise;
    }

    this.getAppDetails = function(applicationId) {
        let deferred = $q.defer();
        advisorPortalController.getApplicationDetails(
            applicationId,
            function (result, event) {
                if(event.status){
                    var modalInstance = $modal.open({
                        animation: true,
                        size: 'lg',
                        templateUrl: urlService.getBaseResourceURL() + '/views/shared/HTML_ApplicationDetails.html',
                        resolve: {
                            data: result
                        },
                        controller: 'applicationController'
                    });
                    deferred.resolve(event);
                }
                else{
                    deferred.reject(event);
                }
            }
        );
        return deferred.promise;
    }

    this.getAppDetailsAppItemsOnly = function(appId){
        let deferred = $q.defer();
        advisorPortalController.getApplicationDetails(
            appId,
            function (result, event) {
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

    this.getStudentNames = function(studentName){
        let deferred = $q.defer();
        advisorPortalController.getStudentNames(
            studentName,
            function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(event);
                }
            }
        )
        return deferred.promise;
    }

    this.getStatusDefinition = function(status){
        let definition = statusDefinitions[status];
        return definition;
    }
    
    this.getStudents = function(){
        let homeInstitutionId = viewModel.getViewModel().homeInstitutionId;
        let deferred = $q.defer();
        advisorPortalController.getStudents(
            homeInstitutionId,
            function(result, event){
                if(event.status){
                    
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(event);
                }
            }
        )
        return deferred.promise;
    }

    this.getStudentsPaginated = function(currentPage, pageSize){
        let homeInstitutionId = viewModel.getViewModel().homeInstitutionId;
        let deferred = $q.defer();
        advisorPortalController.getStudentsPaginated(
            homeInstitutionId,
            currentPage,
            pageSize,
            function(result, event){
                if(event.status){
                    
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(event);
                }
            }
        )
        return deferred.promise;
    }

    this.getStudentsCount = function(){
        let homeInstitutionId = viewModel.getViewModel().homeInstitutionId;
        let deferred = $q.defer();
        advisorPortalController.getStudentsCount(
            homeInstitutionId,
            function(result, event){
                if(event.status){
                    
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(event);
                }
            }
        )
        return deferred.promise;
    }

    this.getStudentsSearchCount = function(section, year, country, status, onlyProgramApproval, nameToSearch, otherOptions){
        let homeInstitutionId = viewModel.getViewModel().homeInstitutionId;
        let deferred = $q.defer();
        advisorPortalController.getStudentsSearchCount(
            homeInstitutionId,
            section,
            year,
            country,
            status,
            onlyProgramApproval,
            nameToSearch,
            otherOptions,
            function(result, event){
                if(event.status){
                    
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(event);
                }
            },{ buffer: false, escape: true, timeout: 30000 }
        )
        return deferred.promise;
    }


    this.getHousingInfo = function(appId){
        let deferred = $q.defer();
        advisorPortalController.getHousingInfo(
            appId,
            function(result, event){
                if(event.status){
                    if(result.housingOptions && result.housingOptions.length){
                        housingOptions = result.housingOptions;
                    }
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(event);
                }
            }
        )
        return deferred.promise;
    }

    this.getHousingOption = function(housingOptionId){
        let housingOption = housingOptions.find(ho => ho.Housing_Option__c == housingOptionId);

        return housingOption;
    }
});