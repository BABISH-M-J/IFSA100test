// remember, directive name must start with a lower case & use camel case naming convetion
angular.module('app.directives').directive('existingUser', function (userService, $q, $timeout) {
    return {

        // limit usage to argument only
        restrict: 'A',

        // require NgModelController, i.e. require a controller of ngModel directive
        require: 'ngModel',

        // create linking function and pass in our NgModelController as a 4th argument
        link: function(scope, element, attr, ngModel) {
            ngModel.$asyncValidators.existingUser = function(modelValue, viewValue) {
                let emailAddress = modelValue;
                let deferred = $q.defer();
                if(attr.existingUserId != null && attr.existingUserId != ''){
                    $timeout(function() {
                        deferred.resolve();
                    }, 300);                    
                }
                else{
                    userService.checkForExistingUser(emailAddress).then(
                        function (response) {
                            deferred.resolve();
                        }, function (error) {
                            deferred.reject();
                        }
                    );
                }
                return deferred.promise;
            }
        }
    };
});