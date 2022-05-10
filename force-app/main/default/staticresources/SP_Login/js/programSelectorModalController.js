angular.module('app.controllers')
.controller('programSelectorModalController', function ($scope, $modalInstance, countryOptions, semesterOptions, homeInstitutionName, $filter) {

    // PROPERTIES
    $scope = $scope;
    $scope.countryOptions = countryOptions;
    $scope.semesterOptions = semesterOptions;
    $scope.homeInstitutionName = homeInstitutionName != null ? homeInstitutionName : null;
    $scope.phase = 'search';
    $scope.searching = false; // Indicates if form is currently searching for records
    $scope.loading = false; // Indicates if program details are being loaded
    $scope.programResults = null; // List of programs returned from user query
    $scope.parentRecordTypes = ["Parent Program Term with Dates", "Parent Program Term without Dates"]; // List of parent record types used for identifying if a program has options
    $scope.selectedProgram = null; // The user selected program term in scope
    $scope.programOptions = null; // List of program options related to the program term in scope
    $scope.programOfInterest = null;
    
    // METHODS
    // Query for terms based on selected country
    $scope.getTerms = function() {
        $scope.loadingTerms = true;
        this.selectedSemester = null;
        studentLoginController.getTerms(
            this.selectedCountry,
            function(result, event){
                if(event.status){
                    $scope.semesterOptions = result;
                }
                else{
                    console.error('Could not retreive terms');
                }
                $scope.loadingTerms = false;
                $scope.$apply();
            }
        );
    }

    // Query for list of programs based on user input
    $scope.searchPrograms = function () {
        $scope.selectedCountry = this.selectedCountry;
        $scope.selectedSemester = this.selectedSemester;
        $scope.searching = true;
        $scope.phase = 'results';
        if($scope.selectedCountry && $scope.selectedSemester) {
            studentLoginController.searchPrograms(
                $scope.selectedCountry,
                $scope.selectedSemester,
                $scope.homeInstitutionName,
                function(result) {
                    for(i = 0; i < result.length; i++)
                    {
                        // Set program option flag
                        if($scope.parentRecordTypes.indexOf(result[i].RecordType.Name) < 0){
                            result[i].hasOptions = false;
                        } else {
                            result[i].hasOptions = true;
                        }
                    }
                    $scope.programResults = result;
                    $scope.searching = false;
                    $scope.$apply();
                }
            );
        }
        else {
            $scope.searching = false;
        }
    }

    // Select program and route to program detail page; load options
    $scope.selectProgram = function (item) {
        $scope.phase = 'details';
        $scope.selectedProgram = item;
        // Get program options if applicable
        if($scope.selectedProgram.hasOptions){
            $scope.loading = true;
            studentLoginController.getProgramOptions(
                $scope.selectedProgram.Id,
                function (result) {
                    $scope.selectedProgram.programOptions = result;
                    $scope.loading = false;
                    $scope.$apply();
                }
            );
        }
    }

    // Complete modal activity and save result back to page
    $scope.ok = function (programOfInterest) {
        programOfInterest.Name = $filter('apostraphe')(programOfInterest.Name);
        $scope.programOfInterest = programOfInterest;
        $modalInstance.close($scope.programOfInterest);
    }

    $scope.back = function () {
        $scope.selectedCountry = $scope.selectedCountry;
        $scope.selectedSemester = $scope.selectedSemester;
        $scope.phase = 'results';
    }

    // Cancel modal activity
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    }
});