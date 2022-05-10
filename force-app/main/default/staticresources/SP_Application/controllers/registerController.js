/**
* Register Controller
* @file Register Controller
* @copyright 2019 Institute for Study Abroad
* @author Brock Barlow <bbarlow@ifsa-butler.org>
* @version 2.0
*/
angular.module('app.controllers')
.controller('registerController', function ($scope, $modal, sanitizer, registerService, errorModalService, urlService, $filter, $location, applicationService, viewModel) {
    var step = 0
    var width = 1;
    $scope.loading = true;
    $scope.temp = {birthdate: null};

    $scope.init = function(){
        $scope.submitted = false;
        $scope.percentComplete = 0;
        $scope.selectedNatlSuccess = [];
        $scope.selectedGenderIdentity = [];
        
        var promise = registerService.getRegisterViewModel()
        promise.then(function(result){
            $scope.registerPage = urlService.getBaseResourceURL() + '/views/pages/register_page1.html';
            $scope.viewModel = result;
            $scope.viewModel.HomeInstitutionName = $filter('apostraphe')($scope.viewModel.HomeInstitutionName);
            $scope.viewModel.HomeInstitutionName = $filter('ampersand')($scope.viewModel.HomeInstitutionName);
            $scope.viewModel.studentFirstName = $filter('apostraphe')($scope.viewModel.studentFirstName);
            $scope.viewModel.MiddleName = $filter('apostraphe')($scope.viewModel.MiddleName);
            $scope.viewModel.studentLastName = $filter('apostraphe')($scope.viewModel.studentLastName);
            $scope.viewModel.Major = $filter('ampersand')($scope.viewModel.Major);
            $scope.viewModel.SecondMajor = $filter('ampersand')($scope.viewModel.SecondMajor);
            $scope.viewModel.Minor = $filter('ampersand')($scope.viewModel.Minor);
            $scope.viewModel.SecondMinor = $filter('ampersand')($scope.viewModel.SecondMinor);
            $scope.viewModel.GPA = $scope.viewModel.GPA != null ? $scope.viewModel.GPA.toString() : '';
            while($scope.viewModel.GPA.length < 5 && $scope.viewModel.GPA.length > 0) {
                $scope.viewModel.GPA = $scope.viewModel.GPA + '0';
            }
            
            //ACARSON added concitional to check to see if birthdate was undefined
            if($scope.viewModel.Birthdate != undefined){
                $scope.temp.birthdate = new Date($scope.viewModel.Birthdate);
                $scope.temp.birthdate.setDate($scope.temp.birthdate.getDate() + 1);
            }

            if($scope.viewModel.HomeInstitutionName == null) {
                if($scope.viewModel.UnlistedSchool != null) {
                    $scope.viewModel.HomeInstitutionName = $scope.viewModel.UnlistedSchool;
                } else {
                    $scope.viewModel.HomeInstitutionName = '';
                }
            }
            $scope.parseMultiSelect();
            $scope.viewModel.MajorOptions = $filter('ampersand')($scope.viewModel.MajorOptions.toString()).split(',');
            $scope.viewModel.DegreeOptions = $filter('apostraphe')($scope.viewModel.DegreeOptions.toString()).split(',');
            $scope.viewModel.Degree = $filter('apostraphe')($scope.viewModel.Degree);
            $scope.viewModel.FAFSAOptions = $filter('apostraphe')($scope.viewModel.FAFSAOptions.toString()).split(',');
            $scope.viewModel.FAFSA = $filter('apostraphe')($scope.viewModel.FAFSA);
            $scope.viewModel.TravelConcerns = $filter('apostraphe')($scope.viewModel.TravelConcerns);
            // Correct apostraphe in options, this has to be handled differently since the options have "," in the options
            for (let index = 0; index < $scope.viewModel.PersonalPronounOptions.length; index++) {
                let element = $scope.viewModel.PersonalPronounOptions[index];
                element = $filter('apostraphe')(element);
            }

            //$scope.firstGenCheckbox = $scope.viewModel.FirstGeneration == true ? 'No' : '';
            $scope.hideGIOther = true;
            $scope.datePickerOpen = false;
            $scope.secondMajorChecked = false;
            $scope.secondMinorChecked = false;
            $scope.middleNameRequired = true;
            $scope.surveyQuestions = false;
            $scope.surveySection = 0;
            $scope.travelConcerns = $scope.viewModel.TravelConcerns != null && $scope.viewModel.TravelConcerns != '' ? 'Yes' : 'No';

            $scope.loading = false;
        }, function(result){
            errorModalService.openErrorModal('Error', 'The student portal was unable to process your request, please refresh the page and try again. If you continue to receive this message please contact IFSA at admissions@ifsa-butler.org or call +1 800 858 0229 for assistance');
        })
    }
    
    $scope.openDatepicker = function($event) {
        $scope.datePickerOpen = true;
    };    

    $scope.hasSecondMajor = function(){
        $scope.secondMajorChecked = !$scope.secondMajorChecked;
        $scope.viewModel.SecondMajor = null;
    }
    $scope.hasSecondMinor = function(){
        $scope.secondMinorChecked = !$scope.secondMinorChecked;
        $scope.viewModel.SecondMinor = null;
    }
    $scope.doesntHaveMiddleName = function(){
        $scope.middleNameRequired = !$scope.middleNameRequired;
    }
    $scope.hasGIOther = function(opt){
        $scope.toggleGenderIdentity(opt);
        if(opt.name == 'Other Identity' && opt.value) {
            $scope.hideGIOther = false;
        }
        else if(opt.name == 'Other Identity' &&  !opt.value){
            $scope.viewModel.GenderIdentityOther = null;
            $scope.hideGIOther = true;
        }
    }
    $scope.toggleSurvey = function(arg, num){
        //$scope.loading = true;
        $scope.toggling = true;
        //$scope.parseMultiSelect();
        $scope.viewModel.Birthdate = $scope.temp.birthdate.getFullYear() + '-' + ($scope.temp.birthdate.getMonth() + 1) + '-' + $scope.temp.birthdate.getDate();
        if($scope.viewModel.GPA.length > 1 && $scope.viewModel.GPA[1] != '.') {
            $scope.viewModel.GPA = $scope.viewModel.GPA[0] + '.' + $scope.viewModel.GPA.substring(1,$scope.viewModel.GPA.length);
        } else if($scope.viewModel.GPA.length == 1) {
            $scope.viewModel.GPA += '.';
        }
        while($scope.viewModel.GPA.length < 5 && $scope.viewModel.GPA.length > 0) {
            $scope.viewModel.GPA = $scope.viewModel.GPA + '0';
        }
        $scope.viewModel.Race = formMultiSelect($scope.viewModel.RaceOptions);
        $scope.viewModel.GenderIdentity = formMultiSelect($scope.viewModel.GenderIdentityOptions);
        $scope.viewModel.NatlStudentSuccess = formMultiSelect($scope.viewModel.NatlStudentSuccessOptions);
        $scope.viewModel.TravelTopics = formMultiSelect($scope.viewModel.TravelTopicsOptions);
        $scope.travelConcerns = $scope.viewModel.TravelConcerns != null && $scope.viewModel.TravelConcerns != '' ? 'Yes' : 'No';
        let promise = registerService.saveRegistration($scope.viewModel, false);
        promise.then(function(result){
            $scope.submitted = false;
            $scope.toggling = false;
            $scope.surveyQuestions = arg;
            $scope.surveySection = num;
            $scope.percentComplete = $scope.surveySection * 25;
            $scope.registerPage = urlService.getBaseResourceURL() + '/views/pages/register_page' + ($scope.surveySection + 1) +'.html';
            //$scope.loading = false;
            //$scope.$apply();
        }, function(result){
            errorModalService.openErrorModal('Error', 'The student portal was unable to process your request, please check your responses. If you continue to receive this message please contact IFSA at admissions@ifsa-butler.org or call +1 800 858 0229 for assistance');
            $scope.submitted = false;
            $scope.toggling = false;
        });
    }
    $scope.moveSurveySectionForward = function(){
        scope.surveySection = surveySection + 1;
    }
    function SelectElement(valueToSelect){
        var elem = document.getElementById('firstGen');
        elem.value = value
    }

    $scope.UniversityOptions = [];
    $scope.searchSchools = function() {
        return portalRemotingMethods.searchHomeInstitution(
            $scope.viewModel.HomeInstitutionName, 
            function(result, event) {
                $scope.UniversityOptions = result;
                for(i = 0; i < $scope.UniversityOptions.length; i++) {
                    $scope.UniversityOptions[i].Name = sanitizer.sanitize($scope.UniversityOptions[i].Name);
                }
                $scope.$apply();
            }
        );
    }
    $scope.populateMultiSelect = function (arg, array) {
        if(arg){
            arg = $filter('apostraphe')(arg);
        }
        var lst = arg ? arg.split(";") : [];
        let returnList = [];
        //console.log(lst);
        for (let index = 0; index < array.length; index++) {
            const element = array[index];
            let e;
            if(typeof element === 'string'){
                e = {
                    name: $filter('apostraphe')(element),
                    value: false
                };
            }
            else{
                e = element;
            }
            for(i = 0; i< lst.length; i++){
                const selectedItem = lst[i];
                if(e.name == selectedItem) {
                    e.value = true;
                }
            }
            returnList.push(e);
        }
        return returnList;   
    }
    function formMultiSelect(options) {
        var result = "";
        //console.log(typeof options);
        if(options != null){
            for(i = 0; i < options.length; i++){
                const arg = options[i];
                
                if(result == "" && arg.value){
                    result = result.concat("", arg.name);
                }
                else if(arg.value){
                    result = result.concat(";", arg.name);
                }
            }
        }
        return result;
    }

    $scope.parseMultiSelect = function() {
        $scope.viewModel.RaceOptions = $scope.populateMultiSelect($scope.viewModel.Race, $scope.viewModel.RaceOptions);
        $scope.viewModel.GenderIdentityOptions = $scope.populateMultiSelect($scope.viewModel.GenderIdentity, $scope.viewModel.GenderIdentityOptions);
        $scope.viewModel.NatlStudentSuccessOptions = $scope.populateMultiSelect($scope.viewModel.NatlStudentSuccess, $scope.viewModel.NatlStudentSuccessOptions);
        $scope.viewModel.TravelTopicsOptions = $scope.populateMultiSelect($scope.viewModel.TravelTopics, $scope.viewModel.TravelTopicsOptions);
    }

    $scope.submit = function() {
        $scope.percentComplete = 4 * 25;

        $scope.viewModel.Birthdate = $scope.temp.birthdate.getFullYear() + '-' + ($scope.temp.birthdate.getMonth() + 1) + '-' + $scope.temp.birthdate.getDate();
        if($scope.viewModel.GPA.length > 1 && $scope.viewModel.GPA[1] != '.') {
            $scope.viewModel.GPA = $scope.viewModel.GPA[0] + '.' + $scope.viewModel.GPA.substring(1,$scope.viewModel.GPA.length);
        } else if($scope.viewModel.GPA.length == 1) {
            $scope.viewModel.GPA += '.';
        }
        while($scope.viewModel.GPA.length < 5 && $scope.viewModel.GPA.length > 0) {
            $scope.viewModel.GPA = $scope.viewModel.GPA + '0';
        }

        $scope.viewModel.Race = formMultiSelect($scope.viewModel.RaceOptions);
        $scope.viewModel.GenderIdentity = formMultiSelect($scope.viewModel.GenderIdentityOptions);
        $scope.viewModel.NatlStudentSuccess = formMultiSelect($scope.viewModel.NatlStudentSuccessOptions);
        $scope.viewModel.TravelTopics = formMultiSelect($scope.viewModel.TravelTopicsOptions);
        //$scope.viewModel.FirstGeneration = $scope.firstGenCheckbox == 'No' ? true : false;
        $scope.travelConcerns = $scope.viewModel.TravelConcerns != null && $scope.viewModel.TravelConcerns != '' ? 'Yes' : 'No';

        $scope.submitted = true;
        let promise = registerService.saveRegistration($scope.viewModel, true);
        promise.then(function(result){
            $scope.submitted = false;
            let app = applicationService.getApplication();
            console.log(app);
            $scope.viewModel.profileCompleted = true;
                //$scope.$apply();
                var modalInstance = $modal.open({
                    animation: true,
                    templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/HTML_SaveModal.html',
                    resolve: {
                        successful: result,
                        programSelected: app.Status_Program_Selected__c ? true : false
                    },
                    controller: 'registerSaveModalController',
                });
        
                modalInstance.result.then(function (result) {
                    console.log(result);
                    if((result.successful && result.programSelected) || viewModel.getViewModel().isCustom){
                        $location.path('/');
                    }
                    else if(result.successful){
                        $location.path('/select');
                    }
                    else {
                        $scope.init();
                    }
                }, function (result) {
                    // Not possible to dismiss modal
                    console.log(result);
                });
                //acarson
                if(result == false){
                    $scope.surveyQuestions = false;
                    $scope.surveySection = 0;
                }
        }, function(result){

        });
    }

    $scope.toggleNatlSuccess = function(opt){
        var index = $scope.selectedNatlSuccess.indexOf(opt.name);
        if(index == -1) {
            $scope.selectedNatlSuccess.push(opt.name);
        }
        else{
            $scope.selectedNatlSuccess.splice(index, 1);
        }
        $scope.viewModel.NatlStudentSuccess = '';
        for (let index = 0; index < $scope.selectedNatlSuccess.length; index++) {
            const element = $scope.selectedNatlSuccess[index];
            $scope.viewModel.NatlStudentSuccess = $scope.viewModel.NatlStudentSuccess + element + ';';
        }
    }
    $scope.toggleGenderIdentity = function(opt){
        var index = $scope.selectedGenderIdentity.indexOf(opt.name);
        if(index == -1) {
            $scope.selectedGenderIdentity.push(opt.name);
        }
        else{
            $scope.selectedGenderIdentity.splice(index, 1);
        }
        $scope.viewModel.GenderIdentity = '';
        for (let index = 0; index < $scope.selectedGenderIdentity.length; index++) {
            const element = $scope.selectedGenderIdentity[index];
            $scope.viewModel.GenderIdentity = $scope.viewModel.GenderIdentity + element + ';';
        }
    }

    $scope.init();
});