// Student Portal URL Service
// Created by: Brock Barlow
angular.module('app.services')
.service('urlService', function() {
    return {
        getResourceURL: function() {
            return baseResourceURL;
        }
    }
});