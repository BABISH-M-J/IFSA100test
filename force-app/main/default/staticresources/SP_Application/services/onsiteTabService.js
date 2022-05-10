/**
 * Student Portal Onsite Tab Service
 * @file Student Portal Onsite Tab Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('onsiteTabService', function(viewModel, $location, applicationItemService, $q) {
    var self = this;
    let tabs = [];
    let vm = viewModel.getViewModel();

    this.getTabs = function(){
        let deferred = $q.defer();

        applicationItemService.hasLearningPlan().then(function(hasLearningPlan){
            if(!tabs.length){
                tabs.push({
                    title: 'Housing',
                    page: '/onsite/housing',
                    icon: 'fa fa-home fa-fw',
                    active: $location.path() == '/onsite/housing'
                });
                tabs.push({
                    title: 'Contact Info',
                    page: '/onsite/contact-info',
                    icon: 'fa fa-mobile',
                    active: $location.path() == '/onsite/contact-info',
                    disabled: vm.applicationStatus != 'On Site' && vm.applicationStatus != 'Program Completed'
                });
                if(hasLearningPlan){
                    tabs.push({
                            title: 'Learning Plan',
                            page: '/onsite/learning-plan',
                            icon: 'glyphicon glyphicon-star',
                            active: $location.path() == '/onsite/learning-plan',
                            disabled: vm.applicationStatus != 'On Site' && vm.applicationStatus != 'Program Completed'
                    });
                }
                if(!vm.isCustom){
                    tabs.push(
                        {
                            title: 'Academics',
                            page: '/onsite/academics',
                            icon: 'glyphicon glyphicon-apple',
                            active: $location.path() == '/onsite/academics',
                            disabled: vm.applicationStatus != 'On Site' && vm.applicationStatus != 'Program Completed'
                        }
                    );
                }
                tabs.push({
                    title: 'Trips',
                    page: '/onsite/trips',
                    icon: 'fa fa-suitcase fa-fw',
                    active: $location.path() == '/onsite/trips',
                    disabled: vm.applicationStatus != 'On Site' && vm.applicationStatus != 'Program Completed'
                });
            }
            deferred.resolve(tabs);
        },function(error){
            deferred.reject(error);
        });

        return deferred.promise;
    }

});