/**
 * Student Portal Multi Select Directive
 * @file Student Portal Multi Select Directive
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.directives')
.directive('multiSelect', function (urlService, $templateRequest, $compile, $filter){
    return {
       scope: {
            options: '=',
            selected: '=',
            isRequired: '&',
            labelText: '@',
            twoCols: '&?'
        },
        restrict: 'E',
        templateUrl: urlService.getBaseResourceURL() + '/views/shared/multiSelect.html',
        link: function ($scope, element, attrs) {            

        },
        controller: ['$scope', '$element', function($scope, $element){
            $scope.twoCols = $element.context.attributes['two-cols'] && $element.context.attributes['two-cols'].value == 'true' ? true : false;
            $scope.isRequired =  $element.context.attributes['is-required'] && $element.context.attributes['is-required'].value == 'true' ? true : false;
            $scope.toggle = function(opt, textClicked){
                if(textClicked)
                {
                    opt.value = !opt.value;
                }
                var index = $scope.selected.indexOf(opt.name);
                if(index == -1 && opt.value) {
                    $scope.selected.push(opt.name);
                }
                else if(index > -1) {
                    $scope.selected.splice(index, 1);
                }
                $scope.calculate();
            }
            $scope.calculate = function(){
                $scope.selected = [];
                for (let index = 0; index < $scope.options.length; index++) {
                    const opt = $scope.options[index];
                    if(opt.value && $scope.selected.indexOf(opt.name === -1)){
                        $scope.selected.push(opt.name);
                    }
                }
            }
            

            $scope.calculate();
        }]
    }
});
