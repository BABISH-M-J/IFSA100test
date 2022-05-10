/**
 * Student Portal Window Size Directive
 * @file Student Portal Window Size Directive
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 * @see https://stackoverflow.com/questions/41175143/how-can-i-get-the-window-width-in-angularjs-on-resize-from-a-controller
 */
angular.module('app.directives')
.directive('windowSize', function ($window) {
    return function (scope, element) {
      var w = angular.element($window);
      scope.getWindowDimensions = function () {
          return {
              'h': w.height(),
              'w': w.width()
          };
      };
      scope.$watch(scope.getWindowDimensions, function (newValue, oldValue) {
        scope.windowHeight = newValue.h;
        scope.windowWidth = newValue.w;
        scope.style = function () {
            return {
                'height': (newValue.h - 100) + 'px',
                'width': (newValue.w - 100) + 'px'
            };
        };
      }, true);
  
      w.bind('resize', function () {
          scope.$apply();
      });
    }
  })