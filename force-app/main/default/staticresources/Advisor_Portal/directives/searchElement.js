angular.module('app.directives')
.directive('searchElement', function (urlService){ 
    return {
        scope: {
            element: '='
         },
        restrict: 'E',
        transclude: true,
        templateUrl: urlService.getBaseResourceURL() + '/views/student_templates/search_element.html',
        link: function (scope, ele, attrs) {
            let parts = scope.element.split('-&gt;')
            let e = {
                topic: parts[0],
                subTopic: parts.length > 2 ? parts.slice(1, -1) : null,
                term: parts[parts.length - 1]
            }
            scope.data = e
            //console.log(scope.element);
        }
    };
 });