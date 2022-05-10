/**
 * Phone Validation Directive
 * @file Phone Validation Directive
 * @copyright 2020 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 1.0
 */

angular.module('ifsa.common')
.directive('phoneValidation', function (){ 
    return {
        restrict: 'A',
        require: 'ngModel',
        link: function(scope, elem, attr, ngModel) {
            ngModel.$parsers.unshift(function (value) {
            let code = attr.phoneValidationCountryCode;
            let number = '' + value; // Ensures that the value is treated as a string an not a number
            if(!code || code == ''){
                ngModel.$setValidity('phoneValidationNoCountry', false);
            }
            else if(code && number){
                ngModel.$setValidity('phoneValidationNoCountry', true);
                ngModel.$setValidity('phoneValidationBlank', true); 
                
                let phoneNumber = libphonenumber.parsePhoneNumberFromString(number, attr.phoneValidationCountryCode);
                if(phoneNumber){
                    let isValid = phoneNumber.isValid();

                    ngModel.$setValidity('phoneValidationNotValid', isValid);  
                }
                else{
                    ngModel.$setValidity('phoneValidationNotValid', false);    
                }
            }
            else{
                ngModel.$setValidity('phoneValidationBlank', false);    
            }
            
            return value;
            });
        }
    };
 });