/**
 * Student Portal Upload Upload Change Directive
 * @file Student Portal Upload Upload Change Directive
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.directives')
.directive('ngUploadChange',['$parse', function($parse) {
    return {
        restrict: 'A',
        link: function (scope, element, attrs) {
          var onChangeFunc = scope.$eval(attrs.ngUploadChange);
          element.bind('change', function(event){
            var files = event.target.files;
            onChangeFunc(files);
          });
            
          element.bind('click', function(){
              element.val('');
          });
        }
      };
}]);