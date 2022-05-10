var app = angular.module('app', ['app.controllers', 'app.services', 'app.filters', 'app.directives', 'ui.bootstrap', 'ngSanitize', 'ngSemanticDirectives', 'ngRoute', 'ngMessages', 'ifsa.common', 'angular-google-analytics']);


app.config(function($routeProvider){
    $routeProvider
    .when("/", {
        templateUrl : baseResourceURL + '/html/main.html',
        controller : "mainController"
    })
    .when("/login", {
        templateUrl : baseResourceURL + '/html/login.html',
        controller : "loginController"
    })
    .when("/login/:email", {
        templateUrl : baseResourceURL + '/html/login.html',
        controller : "loginController"
    })
    .when("/register", {
        templateUrl : baseResourceURL + '/html/register.html', 
        controller : "registerController"
    })
    .when("/auth", {
        templateUrl : baseResourceURL + '/html/login.html',
        controller : "loginController"
    })
    .when("/forgot-password", {
        templateUrl : baseResourceURL + '/html/forgotPassword.html',
        controller : "loginController"
    })
    .when("/redirect-to-portal", {
        templateUrl : baseResourceURL + '/html/redirectToPortal.html',
        controller : "mainController"
    })

});

app.config(function (AnalyticsProvider) {
    // Add configuration code as desired
    AnalyticsProvider.setAccount(analyticsId);
    AnalyticsProvider.trackUrlParams(true);
});

app.run(function(viewModel, $location, $window, Analytics){
    let vm = viewModel.getViewModel();
    if(vm.hasApps){
        $location.path('/redirect-to-portal');
        $window.location.assign('/studentportal');
    }
    else if(vm.gwUser && !vm.isLoggedIn){
        $location.path('/auth');
    }
    else if(vm.contactId || vm.programId){
        $location.path('/register');
    }
})

angular.module('app.controllers', []);
angular.module('app.services', []);
angular.module('app.filters', []);
angular.module('app.directives', []);