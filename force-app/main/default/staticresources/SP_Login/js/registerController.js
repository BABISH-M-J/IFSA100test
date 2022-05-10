// SP_Login Page Login AngularJS Controller
// Created by: Brock Barlow
angular.module('app.controllers')
app.controller('registerController', function($scope, $modal, viewModel, urlService, registrationService, errorService, $filter, $location, $window, userService) 
{
    $scope.resourceURL = urlService.getResourceURL();
    $scope.viewModel = viewModel.getViewModel();

    if($scope.viewModel.programId)
    {
        registrationService.getProgramTerms($scope.viewModel.programId).then(function(result){
            $scope.viewModel.programTermOptions = result;
            $scope.viewModel.program.Name = 'Tell us when you want to study at ' + $scope.viewModel.program.Name;
        },
        function(error){
            // We had an error, just allow the student to pick from all programs
            $scope.programId = null;
        })
    }

    // Method for creating new user accounts
    $scope.register = function () {
        console.log('--- register ---');
        for(key in $scope.viewModel){
            console.log(key + ' => ' + $scope.viewModel[key]);
        }
        if(!$scope.saving){
            $scope.saving = true;
            delete $scope.viewModel.programOfInterest.hasOptions;
            var programRepsonse = $scope.viewModel.programRepsonse;
            var passwordRetyped = $scope.viewModel.passwordRetyped;
            delete $scope.viewModel.programRepsonse;
            delete $scope.viewModel.passwordRetyped;
            
            if(!$scope.viewModel.gwUser){
                var regPromise = registrationService.register($scope.viewModel);
                regPromise.then(function(regResult){
                    // Registration Successful
                    if($scope.viewModel.contactId != null)
                    {
                        // We need to give Saleforce some time to change the users profile to "IFSA Student User"
                        setTimeout(function() {$scope.createApplication(regResult);}, 2000)
                    }
                    else
                    {
                        $scope.createApplication(regResult);
                    }
                },
                function(regResult) {
                    // Registration failed
                    $scope.saving = false;
                    if(regResult){
                        //$scope.alerts.push({msg: regResult, type: 'Warning'});
                        errorService.openErrorModal(regResult);
                    }
                    else {
                        //$scope.alerts.push({msg: 'ERROR: Could not create your account at this time. Please try again. If you continue to have this error please contact us at admissions@ifsa-butler.org or 1-800-858-0229', type: 'Warning'});
                        errorService.openErrorModal('SP_Login_GenericRegError');
                    }
                });
            }
            else{
                $scope.createApplication($scope.viewModel.userId);
            }

            $scope.viewModel.programRepsonse = programRepsonse;
            $scope.viewModel.passwordRetyped = passwordRetyped;
        }
    }
    
    // Creates the student's application once their Account, Contact and User records have been created OR their user profile has changed to "IFSA Student User"
    $scope.createApplication = function(regResult) {
        var appPromise = registrationService.createApplication(regResult, $scope.viewModel);
        appPromise.then(function(appResult){
            // Create Applicaiton Successful
            if(appResult.indexOf('https') !== -1)
            {
                var decoded = appResult.replace('amp;', '').replace('amp;', '').replace('amp;', '').replace('amp;', '').replace('amp;', '').replace('amp;', '').replace('amp;', '').replace('amp;', '');                                    
                window.location.assign(decoded);
            }
            else if(appResult.indexOf('/SP_Application') !== -1)
            {
                window.location.assign(window.location.protocol + '//' + window.location.hostname + '/studentportal/#/register');
            }
        }, function(appResult){
            // Create Applicaiton Failed
            $scope.saving = false;
            if(appResult) {
                //$scope.alerts.push({msg: appResult, type: 'Warning'});
                errorService.openErrorModal('SP_Login_GenericRegError');
            }
            else {
                //$scope.alerts.push({msg: 'ERROR: Could not create your account at this time. Please try again. If you continue to have this error please contact us at admissions@ifsa-butler.org or 1-800-858-0229', type: 'Warning'});
                errorService.openErrorModal('SP_Login_GenericRegError');
            }
            
        });
    }

    $scope.selectTerm = function() {
        var modalInstance = $modal.open({
            templateUrl: $scope.resourceURL + '/html/termSelectorModal.html',
            controller: 'termSelectorModalController',
            scope: $scope,
            size: 'lg',
            backdrop: 'static',
            resolve: {
                programTerms: function() {
                    return $scope.viewModel.programTermOptions;
                }
            }
            });
    
            modalInstance.result.then(function (programOfInterest) {
                $scope.selectProgramOfInterest(programOfInterest);
                delete $scope.viewModel.program;
            });
    }
    
    // MODAL
    $scope.open = function () {
        var modalInstance = $modal.open({
        templateUrl: $scope.resourceURL + '/html/programSelectorModal.html',
        controller: 'programSelectorModalController',
        scope: $scope,
        size: 'lg',
        backdrop: 'static',
        resolve: {
            countryOptions: function () {
                return $scope.viewModel.countryOptions;
            },
            semesterOptions: function () {
                return $scope.viewModel.semesterOptions;
            },
            homeInstitutionName: function() {
                return $scope.viewModel.homeInstitutionName;
            }
        }
        });

        modalInstance.result.then(function (programOfInterest) {
            $scope.selectProgramOfInterest(programOfInterest);
        });
    }

    $scope.selectProgramOfInterest = function(programOfInterest) {
        let programName = programOfInterest.Name;
        programName = $filter('apostraphe')(programName);
        programName = $filter('ampersand')(programName);
        programName = $filter('quote')(programName);
        $scope.viewModel.programOfInterest = programOfInterest;
    }
    
    $scope.reset = function () {
        $scope.viewModel.programOfInterest = null;
    }

    /* $scope.schoolEmailBlurred = function() {
        $scope.emailSuccess = null;
        if($scope.viewModel.email && !$scope.viewModel.contactId){
            $scope.checkingEmail = true;
            $scope.schoolEmailError = false;
            userService.checkForExistingUser($scope.viewModel.email).then(function(result){
                $scope.checkingEmail = false;
                $scope.emailSuccess = result;
            }, function(error){
                $scope.checkingEmail = false;
                $scope.schoolEmailError = error;
            })
        }
    } */

    $scope.openPickerModal = function(type){
        let options;
        let title;
        let labelField;
        let pickerType = type;
        switch (type) {
            case 'major':
                title = 'Major';
                options = $scope.viewModel.majorOptions;
                labelField = 'label';
                break;
            case 'home_institution':
                title = 'Home College or University College or University'
                options = $scope.viewModel.homeInstitutionOptions;
                labelField = 'Name';
                break;
            default:
                break;
        }

        var modalInstance = $modal.open({
            templateUrl: $scope.resourceURL + '/html/pickerModal.html',
            controller: 'pickerModalController',
            scope: $scope,
            backdrop: 'static',
            resolve: {
                data: {
                    pickerOptions: options,
                    title: title,
                    labelField: labelField,
                    type: pickerType
                }
            }
        });
    
        modalInstance.result.then(function (selectedOption) {
            switch (type) {
                case 'major':
                    $scope.viewModel.major = selectedOption[labelField];
                    break;
                case 'home_institution':
                    $scope.viewModel.homeInstitutionName = selectedOption[labelField];
                    $scope.viewModel.homeInstitutionId = selectedOption.Id ? selectedOption.Id : null
                    break;
                default:
                    break;
            }
        });
    }
});