/**
 * App module for SP_Application
 * @file App module for SP_Application
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 1.0
 */
var app = angular.module('app', ['app.controllers', 'app.filters', 'app.services', 'app.directives', 'ui.bootstrap', 'ngRoute','ngSanitize', 'htmlSafe', 'ngSignaturePad', 'textAngular', 'angular-google-analytics']);

app.run(function($rootScope, applicationService, viewModel, applicationItemService, pageService, Analytics){
    $rootScope.loading = true;
    let loadAppsPromise = applicationService.getLoadApplicationsPromise();
    let vm = viewModel.getViewModel();
    if(vm == undefined)
    {
        window.location.assign(result.Is_Custom__c ? '/customportal/CP_Login' : '/studentportal/SP_Login');
    }
    else
    {
        if(!vm.totalAppItemCount)
        {
            applicationItemService.populateApplicationItems(vm.applicationId).then(function(result){
                // Everything went according to plan, we do not need to do anything here.
            }, function(err){
                console.error(err);
            });
        }
        else
        {
            // Ensure that the application has an app item for every app requirement for the selected program term
            applicationItemService.checkForNewApplicationReqs(vm.applicationId).then(function(result){
                // Everything went according to plan, we do not need to do anything here.
                // console.info(result);
            }, function(error){
                console.error(error);
            })
        }

        applicationService.getApplicationFromSF(vm.applicationId).then(function(result){
            var currentURL = new URL(location);
            pageService.setDefaultTitle(result.Program_Term_Program__c + ' ' + result.Program_Term_Section__c + ' ' + result.Program_Term_Year__c + (result.Is_Custom__c ? ' | IFSA Custom Portal' : ' | IFSA Student Portal'));
            if(!vm.profileCompleted && !result.Is_Custom__c)
            {
                window.location.assign('#/register');
            }
            else if(result.Status__c == 'On Site' && currentURL.hash == '#/' && !result.Is_Custom__c)
            {
                window.location.assign('#/onsite/housing');
            }
            else if(result.Status__c != 'On Site' && result.Status__c != 'Program Completed' && result.Status__c != 'Withdraw' && currentURL.hash.indexOf('onsite') > -1)
            {
                if(result.Status__c.indexOf('Accepted') > -1 && result.Housing_Assignment__c != null && currentURL.hash != '#/onsite/housing/')
                {
                    window.location.assign('#/');
                }            
            }
        },
        function(result){
            console.log('could not load app');
        });
        $rootScope.loading = false;
    }
    /*
    var appItemsPromise = applicationItemService.getApplicationItems(viewModel.getViewModel().applicationId);
    appItemsPromise.then(function(result){
        // Do nothing
    },
    function(result){
        console.log('could not load app items');
    });
    */
   
});

angular.module('app.controllers', []);
angular.module('app.services', []);
angular.module('app.filters', []);
angular.module('app.directives', []);