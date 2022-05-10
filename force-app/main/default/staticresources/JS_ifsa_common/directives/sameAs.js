/**
 * Same As Directive - Taken from https://codepen.io/anon/pen/pJVLjg
 * @file Same As Directive
 * @copyright 2020 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 1.0
 */

angular.module('ifsa.common')
.directive('sameAs', function () {
    return {
      require: 'ngModel',
      link: function(scope, element, attrs, ctrl) {
        var modelToMatch = attrs.sameAs;      
        
        scope.$watch(attrs.sameAs, function() {
          ctrl.$validate();          
        })
        
        ctrl.$validators.match = function(modelValue, viewValue) {
          return viewValue === scope.$eval(modelToMatch);
        };
    }
    };
  });