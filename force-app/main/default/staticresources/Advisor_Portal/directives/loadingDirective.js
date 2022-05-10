angular.module('app.directives')
.directive('loading', function (urlService){ 
    return {
        scope: {
             isLoading: '=',
        },
        restrict: 'E',
        transclude: true,
        templateUrl: urlService.getBaseResourceURL() + '/views/shared/loading.html',
        link: function (scope, element, attrs) {
            
        }
    };
 });