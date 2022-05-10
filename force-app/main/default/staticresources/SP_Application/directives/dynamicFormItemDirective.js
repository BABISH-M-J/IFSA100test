/**
 * Student Portal Dynamic Form Item Directive
 * @file Student Portal Dynamic Form Item Directive
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.directives')
.directive('dynamicFormItem', function (urlService, $templateRequest, $compile, $filter){
   return {
       
      scope: {
         formItem: '=',
         type: '@',
         change: '&'
      },
      restrict: 'E',
      link:  function(scope, element, attrs) {
         //console.log(attrs);
         var baseUrl = urlService.getBaseResourceURL() + '/views/shared/formItems';
         var templateUrl;
         if(attrs["type"] == 'No_Response_Required'){
            templateUrl = baseUrl + '/noResponse.html';
         }
         else if(attrs["type"] == 'Check_Box'){
            templateUrl = baseUrl + '/checkbox.html';
         }
         else if(attrs["type"] == 'Text'){
            templateUrl = baseUrl + '/text.html';
            scope.formItem.response = $filter('nbsp')(scope.formItem.response);
            scope.formItem.response = $filter('apostraphe')(scope.formItem.response);
            scope.formItem.response = $filter('ampersand')(scope.formItem.response);
            scope.formItem.response = $filter('quote')(scope.formItem.response);
         }
         else if(attrs["type"] == 'Date_Time'){
            templateUrl = baseUrl + '/datetime.html';
         }
         else if(attrs["type"] == 'Date'){
            templateUrl = baseUrl + '/date.html';
         }         
         else if(attrs["type"] == 'Picklist'){
            templateUrl = baseUrl + '/picklist.html';
         }
         else if(attrs["type"] == 'Signature'){
            templateUrl = baseUrl + '/signatureDrawn.html';
         }
         else if(attrs["type"] == 'Signature_Typed' || attrs["type"] == 'Initial'){
            templateUrl = baseUrl + '/signatureInitialTyped.html';
         }
         else if(attrs["type"] == 'CIF_Class_Table'){
            templateUrl = baseUrl + '/cifTable.html';
         }
         else if(attrs["type"] == 'Page_Break'){
            templateUrl = baseUrl + '/pageBreak.html';
         }
         else if(attrs["type"] == '{{formItem.fieldType}}'){
            templateUrl = baseUrl + '/dynamicFormItem.html';
         }
         else{
            //console.log(attrs["type"] + ' Using generic item template');
            templateUrl = baseUrl + '/dynamicFormItem.html';
         }

         if(templateUrl) {
            // Load the html through $templateRequest
            $templateRequest(templateUrl).then(function(html){
                // Convert the html to an actual DOM node
                var template = angular.element(html);
                // Append it to the directive element
                element.append(template);
                // And let Angular $compile it
                $compile(template)(scope);
            });
        }
      }
   }
});