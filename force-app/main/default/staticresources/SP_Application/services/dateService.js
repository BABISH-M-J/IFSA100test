/**
 * Student Portal Resources Service
 * @file Student Portal Resources Service
 * @copyright 2019 Institute for Study Abroad
 * @author Jay Holt <jholt@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('dateService', function($q, $timeout, viewModel) {
    var self = this;

    // Dates are showing up incorrectly in the portal due to a js time zone issue
    // This method was a recommended fix to correct dates that are displaying 1 day off
    this.convertDate = function(date){
        if(date){
            var d = new Date(date);
            d.setMinutes(d.getMinutes() + d.getTimezoneOffset());
            return d;
        }

        return null;
    }

});