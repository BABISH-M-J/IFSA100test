/**
* Regisert Service
* @file Regisert Service
* @copyright 2019 Institute for Study Abroad
* @author Brock Barlow <bbarlow@ifsa-butler.org>
* @version 2.0
*/
angular.module('app.services')
.service('registerService', function ($q, viewModel){
    var self = this;
    this.getRegisterViewModel = function(){
        var deferred = $q.defer();
        portalRemotingMethods.getRegistrationViewModel(
            function(result, event){
                if(result){
                    deferred.resolve(result)
                }
                else{
                    deferred.reject(result);
                }                
            }
        );
        return deferred.promise;
    }
    
    this.saveRegistration = function(vm, registrationComplete){
        let deferred = $q.defer();
        let raceOptions = angular.copy(vm.RaceOptions);
        let genderIdentityOptions = angular.copy(vm.GenderIdentityOptions);
        let natlStudentSuccessOptions = angular.copy(vm.NatlStudentSuccessOptions);
        let travelTopicsOptions = angular.copy(vm.TravelTopicsOptions);
        let personalPronounOptions = angular.copy(vm.PersonalPronounOptions);
        delete vm.RaceOptions;
        delete vm.GenderIdentityOptions;
        delete vm.NatlStudentSuccessOptions;
        delete vm.TravelTopicsOptions;
        delete vm.PersonalPronounOptions;
        let jsonStr = angular.toJson(vm);
        vm.RaceOptions = raceOptions;
        vm.GenderIdentityOptions = genderIdentityOptions;
        vm.NatlStudentSuccessOptions = natlStudentSuccessOptions;
        vm.TravelTopicsOptions = travelTopicsOptions;
        vm.PersonalPronounOptions = personalPronounOptions;
        portalRemotingMethods.saveRegistrationData(
            jsonStr,
            registrationComplete,
            function(result, event) {
                if(result)
                {
                    if(registrationComplete){
                        let vm = viewModel.getViewModel();
                        vm.profileCompleted = true;
                        viewModel.setViewModel(vm);
                    }
                    deferred.resolve(true);
                }
                else
                {
                    deferred.reject(false);
                }
            }
        );
        return deferred.promise;
    }
})