// Student Portal Registration Service
// Created by: Brock Barlow
angular.module('app.services')
.service('registrationService', function($q) {
    var self = this;

    this.register = function(viewModel) {
        var deferred = $q.defer();
        // clone viewModel to new var
        var vm = angular.copy(viewModel);
        
        // Removing fields not needed to create account/user/contact records
        delete vm.homeInstitutionName;
        delete vm.major;
        delete vm.OtherMajor;
        delete vm.majorOptions;
        delete vm.courses;
        delete vm.coursesDescription;
        delete vm.homeInstitutionOptions;
        delete vm.countryOfInterest;
        delete vm.countryOptions;
        delete vm.desiredCountry;
        delete vm.desiredCountry2;
        delete vm.desiredCountry3;
        delete vm.semesterOptions;
        delete vm.programTerms;
        delete vm.program;
        delete vm.errorMessages;
        delete vm.gwUser;
        delete vm.programId;

        console.log('--- vm ---');
        for(key in vm){
            console.log(key + ' => ' + vm[key]);
        }
        console.log(angular.toJson(vm));
        studentLoginController.register(
            angular.toJson(vm),
            function(result, event) {
                if(event.status && !result.userId){
                    self.prepareUserRecord(result, deferred);
                }
                else if(event.status && result.userId){
                    deferred.resolve(result.userId)
                }
                else{
                    deferred.reject(event.message);
                }
            }
        );
        return deferred.promise
    }

    this.prepareUserRecord = function(data, deferred){
        let vm = angular.copy(data.viewModel);
        delete data.viewModel;

        studentLoginController.prepareUserRecord(
            angular.toJson(data),
            angular.toJson(vm),
            function(result, event)
            {
                if(event.status){
                    self.createUserRecord(result, deferred);
                }
                else{
                    deferred.reject(event.message)
                }
            }
        )
    }

    this.createUserRecord = function(data, deferred){
        let vm = angular.copy(data.viewModel);
        delete data.viewModel;
        studentLoginController.createUserRecord(
            angular.toJson(data),
            angular.toJson(vm),
            function(result, event)
            {
                if(event.status){
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(event.message);
                }
            }
        )
    }

    this.createApplication = function(userId, viewModel) {
        var deferred = $q.defer();
        var vm = angular.copy(viewModel);
        delete vm.majorOptions;
        delete vm.countryOptions;
        delete vm.semesterOptions;
        delete vm.programTerms;

        studentLoginController.createApplicationAndUpdateContact(
            userId,
            angular.toJson(vm),
            function(result) {
                if(result != null && result.indexOf('Error') < 0){
                    console.log("Created Application Record");
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(result);
                }
            }
        );
        return deferred.promise
    }

    this.getProgramTerms = function(programId){
        var deferred = $q.defer();

        studentLoginController.getTermsByProgramId(
            programId,
            function(result, event) {
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
});