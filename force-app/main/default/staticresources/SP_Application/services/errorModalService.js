/**
 * Student Portal Error Modal Service
 * @file Student Portal Error Modal Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('errorModalService', function($modal, $q, urlService) {
    var self = this;
    this.openErrorModal = function(title, message) {
        var deferred = $q.defer();
        var modalInstance = $modal.open({
            animation: true,
            size: 'lg',
            backdrop: 'static',
            templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/HTML_AppItemError.html',
            resolve: {
                data: {title: title, message: message }
            },
            controller: 'appItemErrorController'
        });

        modalInstance.opened.then(function(){
            setTimeout(function(){resize();}, 500);
        });

        modalInstance.result.then(function(result){
            deferred.resolve(result);
        }, function(result) {
            deferred.resolve(result);
        });
        
        return deferred.promise;
    }
})