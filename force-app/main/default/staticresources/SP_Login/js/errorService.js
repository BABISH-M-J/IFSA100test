// SP_Login Page AngularJS Controller
// Created by: Brock Barlow

angular.module('app.services')
.service('errorService', function($modal, $q, urlService, $window, $location) {
    var self = this;
    this.openErrorModal = function(errorName) {
        var deferred = $q.defer();
        var modalInstance = $modal.open({
            animation: true,
            backdrop: 'static',
            templateUrl: urlService.getResourceURL() + '/html/errorModal.html',
            resolve: {
                data: {errorName: errorName}
            },
            controller: 'errorModalController'
        });

        modalInstance.opened.then(function(){
            //setTimeout(function(){resize();}, 500);
        });

        modalInstance.result.then(function(result){
            deferred.resolve(result);
        }, function(result) {
            deferred.resolve(result);
        });
        
        return deferred.promise;
    }

    this.openExistingUserModal = function(modalOptions){
        var modalInstance = $modal.open({
            animation: true,
            backdrop: 'static',
            keyboard: false,
            templateUrl: urlService.getResourceURL() + '/html/existingUserModal.html',
            resolve: {
                data: modalOptions
            },
            controller: 'existingUserModalController'
        });

        modalInstance.result.then(function(result){
            // modal closed, follow link           
            if(result.search('#') > -1 && result.search('chart') == -1){
                $location.path(result.replace('#', ''));
            }
            else if(result == ''){
                // Do nothing
            }
            else if(result.search('&amp;') > -1){
                var decoded = result.replace(/amp;/g, '');
                window.location.assign(decoded);
            }
            else {
                $window.location.href = result;
            }
            
        }, function(result) {
            // modal canceled
        });
    }
})