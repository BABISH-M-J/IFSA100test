/**
 * Student Portal Blacklist Model Directive
 * @file Student Portal Blacklist Model Directive
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.directives')
.directive('blacklist', function (){ 
    return {
       require: 'ngModel',
       link: function(scope, elem, attr, ngModel) {
           var blacklist = attr.blacklist.split(',');
           ngModel.$parsers.unshift(function (value) {
             //console.log(value);
              ngModel.$setValidity('blacklist', blacklist.indexOf(value) === -1);
              return value;
           });
       }
    };
 });