var app = angular.module('app', ['app.controllers', 'app.filters', 'app.services', 'app.directives', 'ui.bootstrap', 'ngRoute','ngSanitize', 'htmlSafe', 'ngSignaturePad', 'ngFileUpload', 'textAngular', 'angular-google-analytics', 'infinite-scroll', 'ifsa.common']);

app.config(function (AnalyticsProvider) {
    // Add configuration code as desired
    AnalyticsProvider.setAccount(analyticsId);
    AnalyticsProvider.trackUrlParams(true);
});

app.run(function($rootScope, viewModel, institutionService, studentsService, profileService, Analytics, programCMSService){
    let currentURL = new URL(location);
    let params = [];

    for(var pair of currentURL.searchParams.entries()) {
        params.push(pair);
    }

    if(params.length){
        let paramName = params[0][0];
        let paramValue = params[0][1];

        switch (paramName) {
            case 'StudentId':
                window.location.assign('#/students_v2/' + paramValue);
                break;
            case 'ResourceId':
                window.location.assign('#/resources/' + paramValue);
                break;
            default:
                break;
        }
    }

    institutionService.loadInstitutionViewModel();
    studentsService.loadStudentsViewModel();
    profileService.loadProfileViewModel();
    programCMSService.getProgramCMSfromSalesforce();
});

angular.module('app.controllers', []);
angular.module('app.services', []);
angular.module('app.filters', []);
angular.module('app.directives', []);