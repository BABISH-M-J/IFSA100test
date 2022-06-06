/**
* Road Map Service
* @file Road Map Service
* @copyright 2022 Institute for Study Abroad
* @author Clayton Pelfrey <cpelfrey@ifsa-butler.org>
* @version 0.1
*/
angular.module('app.services')
.service('roadMapService', function ($q, viewModel){
    console.log('roadMapService');
    var self = this;
    this.getRoadMapViewModel = function(){
        console.log('js roadMapService.getRoadMapViewModel Start');
        var deferred = $q.defer();
        portalRemotingMethods.getRoadMapViewModel(
            function(result, event){
                if(result){
                    console.log('result yes => ' + result);
                    deferred.resolve(result)
                }
                else{
                    console.log('result no => ' + result);
                    deferred.reject(result);
                }                
            }
        );
        return deferred.promise;
    }
    
    this.saveRoadMap = function(vm, roadMapComplete){
        console.log('js roadMapService.saveRoadMap Start');
        let deferred = $q.defer();
        /*let raceOptions = angular.copy(vm.RaceOptions);
        let genderIdentityOptions = angular.copy(vm.GenderIdentityOptions);
        let natlStudentSuccessOptions = angular.copy(vm.NatlStudentSuccessOptions);
        let travelTopicsOptions = angular.copy(vm.TravelTopicsOptions);
        let personalPronounOptions = angular.copy(vm.PersonalPronounOptions);
        delete vm.RaceOptions;
        delete vm.GenderIdentityOptions;
        delete vm.NatlStudentSuccessOptions;
        delete vm.TravelTopicsOptions;
        delete vm.PersonalPronounOptions;*/
        console.log('vm => ' + vm);
        for(key in vm)
        {
            console.log(key + ' => ' + vm[key]);
        }
        console.log('angular.toJson(vm) => ' + angular.toJson(vm));
        let jsonStr = angular.toJson(vm);
        console.log('jsonStr => ' + jsonStr);
        //vm.RaceOptions = raceOptions;
        //vm.GenderIdentityOptions = genderIdentityOptions;
        //vm.NatlStudentSuccessOptions = natlStudentSuccessOptions;
        //vm.TravelTopicsOptions = travelTopicsOptions;
        //vm.PersonalPronounOptions = personalPronounOptions;
        portalRemotingMethods.saveRoadMapData(
            jsonStr,
            roadMapComplete,
            function(result, event) {
                if(result)
                {
                    if(roadMapComplete){
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
        console.log('js roadMapService.saveRoadMap End');
        return deferred.promise;
    }
})