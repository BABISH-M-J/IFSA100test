/**
 * Phone Validation Directive
 * @file Phone Validation Directive
 * @copyright 2020 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 1.0
 */

angular.module('ifsa.common')
.directive('passwordValidation', function (){ 
    return {
        restrict: 'A',
        require: 'ngModel',
        link: function(scope, elem, attr, ngModel) {
            ngModel.$parsers.unshift(function (value) {
            let firstName = attr.passwordFirstName != null ? attr.passwordFirstName.toLowerCase() : null;
            let lastName = attr.passwordLastName != null ? attr.passwordLastName.toLowerCase() : null;
            let passwordLower = value.toLowerCase()
            if(passwordLower.indexOf(firstName) > -1){
                ngModel.$setValidity('passwordValidationFirstName', false);
            }
            else{
                ngModel.$setValidity('passwordValidationFirstName', true);
            }
            if(passwordLower.indexOf(lastName) > -1){
                ngModel.$setValidity('passwordValidationLastName', false);
            }
            else{
                ngModel.$setValidity('passwordValidationLastName', true);
            }
            
            return value;
            });
        }
    };
 });