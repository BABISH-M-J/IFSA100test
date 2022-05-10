/**
 * Chart Project Form Page AngularJS Controller
 * @file Chart Project Form Page AngularJS Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('projectFormController', function($scope, $location, viewModel, $uibModal, projectService, pageService, settingsFactory, urlService, $filter)
{
    $scope.viewModel = viewModel.getViewModel();
    $scope.urlService = urlService;
    pageService.setTitle();
    $scope.welcomeMessage = settingsFactory.getCMPWelcome($scope.viewModel.userProfileName);
    $scope.ciceName = settingsFactory.getCICEName();
    $scope.ciceEmail = settingsFactory.getCICEEmail();
    $scope.specificCountryYesNo = "";
    $scope.natureOfInfo = "";
    // $scope.viewModel.additionalInformationArray = [];
    $scope.userType = $scope.viewModel.userProfileName.indexOf("Advisor User") !== -1 ? "Advisor" : "Student";
    
    $scope.init = function ()
    {
        // Initialize project object
        $scope.project = {
            academicAdvisorEmail: null,
            firstName: $scope.viewModel.firstName,
            lastName: $scope.viewModel.lastName,
            email: $scope.viewModel.email,
            facultyNames: null,
            homeInstitutionName: $scope.viewModel.userHomeInstitutionName,
            includeDirectedResearch: false,
            includeInternshipOptions: false,
            includeNonApprovedPrograms: 'false',
            contactId: $scope.viewModel.contactId,
            major: $scope.viewModel.major,
            yearInSchool: null,
            degreeReqs: null,
            regionsOfInterest: [],
            specificCountries: [],
            specificPrograms: [],
            submittedDate: null,
            completedDate: null,
            status: "Submitted",
            type: $scope.viewModel.userProfileName == "IFSA Advisor User" ? "CI" : "CE",
            additionalInformation: '',
            summaryOfResults: null,
            yearsAbroad: [],
            termsAbroad: [],
            homeClasses: []
        }

        // Get years
        $scope.years = [];
        $scope.years.push({year: "Undecided", isSelected: false});
        for (let index = 0; index < $scope.viewModel.years.length; index++) {
            const year = $scope.viewModel.years[index];
            var app;
            if($scope.viewModel.applications)
            {
                app = $scope.viewModel.applications.find(a => a.Program_Term_Year__c == year);
            }
            var y = {year: year, isSelected: app != null};
            if(y.isSelected)
            {
                $scope.yearsChanged(y);
            }
            $scope.years.push(y);
        }
        // Get regions, countries and progarms
        $scope.regions = [];
        //$scope.regions.push({region: "Undecided", isSelected: false, countries: []});
        $scope.countries = [];
        $scope.programs = [];
        $scope.programMaster = [];
        for (let index = 0; index < $scope.viewModel.regionNames.length; index++) {
            const region = $scope.viewModel.regionNames[index];
            r = {region: region, isSelected: false, countries: []}
            for (let index = 0; index < $scope.viewModel.countries.length; index++) {
                const country = $scope.viewModel.countries[index];
                if(country.marketingRegion == region) {
                    c = {name: country.recordName, id: country.recordId, isSelected: false, programs: [], isCollapsed: true};
                    for (let index = 0; index < $scope.viewModel.programs.length; index++) {
                        const program = $scope.viewModel.programs[index];
                        if(program.countryName == c.name) {
                            var app;
                            if($scope.viewModel.applications){
                                app = $scope.viewModel.applications.find(a => a.Program_Term_Program__c == program.recordName)
                            }
                            p = {
                                name: program.recordName,
                                id: program.recordId,
                                isSelected: false,
                                hasAcademicYearProgramTerms: program.hasAcademicYearProgramTerms,
                                hasFallProgramTerms: program.hasFallProgramTerms,
                                hasSpringProgramTerms: program.hasSpringProgramTerms,
                                hasSummerProgramTerms: program.hasSummerProgramTerms,
                                activeProgramAuthorization: program.activeProgramAuthorization,
                                countryName: c.name,
                                regionName: r.region

                            };
                            $scope.programMaster.push(p);
                            c.programs.push(p);
                            if(app != null)
                            {
                                $scope.specificCountryYesNo = "Yes"
                                p.isSelected = true;
                                c.isSelected = true;
                                r.isSelected = true;
                            }
                        }
                    }
                    r.countries.push(c);
                }
            }
            $scope.regions.push(r);
        }
        
        for (let index = 0; index < $scope.regions.length; index++) {
            const region = $scope.regions[index];
            if(region.isSelected)
            {
                $scope.regionChanged(region);
                for (let index = 0; index < region.countries.length; index++) {
                    const country = region.countries[index];
                    if(country.isSelected)
                    {
                        $scope.countryChanged(country);
                        for (let index = 0; index < country.programs.length; index++) {
                            const program = country.programs[index];
                            if(program.isSelected)
                            {
                                $scope.programsChanged(program);
                            }
                        }
                    }
                }
            }
        }
        
        // Get terms
        $scope.terms = [];
        //$scope.terms.push({term: "Undecided", isSelected: false});
        for (let index = 0; index < $scope.viewModel.termNames.length; index++) {
            const term = $scope.viewModel.termNames[index];
            var app;
            if($scope.viewModel.applications){
                app = $scope.viewModel.applications.find(a => a.Program_Term_Section__c == term);
            }
            var t = {term: term, isSelected: app != null};
            if(t.isSelected)
            {
                $scope.termsChanged(t);
            }
            $scope.terms.push(t);
        }
    }

    $scope.submitProject = function(project)
    {
        $scope.saving = true;
        let hc = JSON.parse(JSON.stringify(project.homeClasses));
        for (let index = 0; index < project.homeClasses.length; index++) {
            const homeClass = project.homeClasses[index];
            let line = homeClass.courseCode + ', ' + homeClass.courseTitle + '\n';
            project.degreeReqs = !project.degreeReqs ? line : project.degreeReqs + line;
        }
        //delete project.homeClasses;

        project.includeNonApprovedPrograms = project.includeNonApprovedPrograms == 'true' ? true : false;
        // for (let index = 0; index < $scope.viewModel.additionalInformationArray.length; index++) {
        //     const element = $scope.viewModel.additionalInformationArray[index];
        //     project.additionalInformation = project.additionalInformation + element + index < $scope.viewModel.additionalInformationArray.length ? ', ' : '';
        // }
        // if($scope.viewModel.additionalInfoOther)
        // {
        //     project.additionalInformation = project.additionalInformation + ', ' + $scope.viewModel.additionalInfoOther;
        // }
        var promise = projectService.submitProject(project);
        promise.then(function(result){
            console.log(result);
            projectService.setCurrentView('Pending');
            $location.path("/projects");
        }, function(result){
            project.homeClasses = hc;
            $scope.loadErrorModal(result);
            $scope.saving = false;
        });
    }

    $scope.regionChanged = function(region)
    {
        if(region.isSelected && region.region == "Undecided"){
            $scope.project.regionsOfInterest = [];
            $scope.project.specificCountries = [];
            $scope.countries = [];
            $scope.project.specificPrograms = [];
            $scope.programs = [];
            for (let index = 0; index < $scope.regions.length; index++) {
                const region = $scope.regions[index];
                region.isSelected = false;
                for (let index = 0; index < region.countries.length; index++) {
                    const country = region.countries[index];
                    country.isSelected = false;
                    $scope.programsChanged(country);
                }
            }
            region.isSelected = true;
        }
        else if(region.isSelected){
            try {
                var undecided = $scope.regions.find(r => r.region == "Undecided");
                undecided.isSelected = false;
            } catch (error) {
                
            }            
            $scope.project.regionsOfInterest.push(region.region);
            for (let index = 0; index < region.countries.length; index++) {
                const element = region.countries[index];
                if(!$scope.countries.includes(p => p.Name))
                {
                    $scope.countries.push(element);
                }
            }
        }
        else if(region.region != "Undecided"){
            $scope.project.regionsOfInterest.splice($scope.project.regionsOfInterest.indexOf(region.region), 1);
            
            for (let index = 0; index < region.countries.length; index++) {
                const country = region.countries[index];
                country.isSelected = false;
                $scope.countryChanged(country);
                $scope.countries.splice($scope.countries.find(c => c.name == country.name), 1);
            }
        }
    }
    $scope.yearsChanged = function(year)
    {
        if(year.isSelected && year.year == "Undecided"){
            $scope.project.yearsAbroad = [];
            for (let index = 0; index < $scope.years.length; index++) {
                const year = $scope.years[index];
                year.isSelected = false;
            }
            year.isSelected = true;
        }
        else if(year.isSelected){
            try {
                var undecided = $scope.years.find(y => y.year == "Undecided");
                undecided.isSelected = false;
            } catch (error) {
                
            }
            $scope.project.yearsAbroad.push(year.year);
        }
        else if(year.year != "Undecided"){
            $scope.project.yearsAbroad.splice($scope.project.yearsAbroad.indexOf(year.year), 1);
        }
    
    }

    $scope.termsChanged = function(term)
    {
        if(term.isSelected && term.term == "Undecided"){
            $scope.project.termsAbroad = [];
            for (let index = 0; index < $scope.terms.length; index++) {
                const term = $scope.terms[index];
                term.isSelected = false;
            }
            term.isSelected = true;
        }
        else if(term.isSelected){
            try {
                var undecided = $scope.terms.find(y => y.term == "Undecided");
                undecided.isSelected = false;    
            } catch (error) {
                
            }            
            $scope.project.termsAbroad.push(term.term);
        }
        else if(term.term != "Undecided"){
            $scope.project.termsAbroad.splice($scope.project.termsAbroad.indexOf(term.term), 1);
        }
    
    }
    $scope.countryChanged = function(country)
    {
        if(country.isSelected && country.name == "Undecided"){
            $scope.project.specificCountries = [];
            $scope.countries = [];
            $scope.project.specificPrograms = [];
            $scope.programs = [];
            for (let index = 0; index < $scope.countries.length; index++) {
                const country = $scope.countries[index];
                country.isSelected = false;
                for (let index = 0; index < country.programs.length; index++) {
                    const program = country.programs[index];
                    program.isSelected = false;
                    $scope.programsChanged(program);
                }
            }
            country.isSelected = true;
        }
        else if(country.isSelected){
            try {
                var undecided = $scope.countries.find(c => c.name == "Undecided");
                undecided.isSelected = false;
            } catch (error) {
                
            }
            $scope.project.specificCountries.push(country.name);
            /* for (let index = 0; index < country.programs.length; index++) {
                const program = country.programs[index];
                program.isSelected = false;
                program.country = country.name;
                $scope.programsChanged(program);
                if(!$scope.programs.includes(p => p.Name))
                {
                    $scope.programs.push(program);
                }
            } */
            country.isCollapsed = true;
            $scope.programs.push(country);
        }
        else if(country.name != "Undecided"){
            $scope.project.specificCountries.splice($scope.project.specificCountries.indexOf(country.name), 1);
            
            /* for (let index = 0; index < country.programs.length; index++) {
                const program = country.programs[index];
                $scope.programs.splice($scope.programs.find(p => p.name == program.name), 1);
            } */
            $scope.programs.splice($scope.programs.find(c => c.name == country.name), 1);
        }
    
    }
    $scope.programsChanged = function(program)
    {
        if(program.isSelected && program.name == "Undecided"){
            $scope.project.specificPrograms = [];
            $scope.programs = [];
            for (let index = 0; index < $scope.programs.length; index++) {
                const program = $scope.programs[index];
                program.isSelected = false;
            }
            program.isSelected = true;
        }
        else if(program.isSelected){
            try {
                var undecided = $scope.programs.find(c => c.name == "Undecided");
                undecided.isSelected = false;
            } catch (error) {
                
            }
            $scope.project.specificPrograms.push(program.name);
        }
        else if(program.name != "Undecided"){
            $scope.project.specificPrograms.splice($scope.project.specificPrograms.indexOf(program.name), 1);
        }
    
    }
    $scope.addClass = function(newClass){

        $scope.project.homeClasses.push(JSON.parse(JSON.stringify(newClass)));
        $scope.clearClass(newClass);
    }
    $scope.clearClass = function(newClass){
        newClass.courseTitle = null;
        newClass.courseCode = null;
    }
    $scope.removeClass = function(classToRemove){
        let index = $scope.project.homeClasses.findIndex(c => c.courseCode == classToRemove.courseCode && c.courseTitle == classToRemove.courseTitle);
        $scope.project.homeClasses.splice(index, 1);
    }
    
    $scope.init();
    $scope.loadErrorModal = function(error) {
        var modalInstance = $uibModal.open({
            animation: true,
            backdrop: 'static',
            templateUrl: urlService.getErrorModalUrl(),
            resolve: {
                data: error
            },
            controller: 'errorModalController'
        });
        
        modalInstance.result.then(function (result) {
                // This should not be hit because the modal never is never closed, only dismissed
        }, function(result) {
            console.log('Error modal dismissed at: ' + new Date());
            console.log(result);
        });
    }
});