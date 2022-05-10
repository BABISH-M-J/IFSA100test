/**
 * Student Portal Upload File Model Directive
 * @file Student Portal Upload File Model Directive
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.directives')
.directive('fileModel',['$parse', function($parse) {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
           var model = $parse(attrs.fileModel);
           var modelSetter = model.assign;
           
           element.bind('change', function() {
              scope.$apply(function() {
                 modelSetter(scope, element[0].files[0]);
              });
           });
        }
     };
}]);