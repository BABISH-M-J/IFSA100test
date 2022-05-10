/**
 * Date Service
 * @file Date Service
 * @copyright 2021 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsa-butler.org> 
 * @version 2.0
 */
 angular.module('ifsa.common')
.service('dateService', function() {
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