angular.module('app.controllers')
.controller('institutionController', function($scope, $modal, urlService, viewModel, institutionService, $log, $filter) 
{
    // Controller init
    $scope.loading = true;
    let firstLoad = true;
    $scope.filteredApprovedPrograms = [];
    $scope.infiniteScrollResults = [];
    $scope.itemsPerPage = 15;
    $scope.currentPage = 1;
    $scope.changedItems = [];

    $scope.searchOnLoad = true;
    $scope.isSubmitting = false;
    $scope.isSearching = false;
    $scope.sortProperty = 'programName';
    $scope.sortOrder = false;

    $scope.viewModel = {HomeInstitutionName: viewModel.getViewModel().InstitutionName};

    institutionService.getInstitutionViewModel().then(function(result){
        $scope.viewModel = result;
        $scope.viewModel.authorization = "All";

        if($scope.viewModel.AdvisorType == "Primary Contact" || $scope.viewModel.approvedForProgramAuthorizations == true)
        {
            $scope.unlockProgramAuth = true
        }
        else
        {
            $scope.unlockProgramAuth = false;
        }
        $scope.loading = false;
        if($scope.searchOnLoad) {
            $scope.search('search');			
        }
    }, function(error){
        $scope.error = error;
    })
    // Sort program authorizations
    $scope.sortBy = function(propertyName) {
        $scope.sortOrder =  ($scope.sortProperty === propertyName) ? !$scope.sortOrder : false;
        $scope.sortProperty = propertyName;
        $scope.approvedProgramList = $filter('orderBy')($scope.approvedProgramList, $scope.sortProperty, $scope.sortOrder);
        $scope.figureOutApproveProgramsToDisplay();
    }
    // search program authorizations
    $scope.search = function(type) {
        $scope.isSearching = type == 'search';
        $scope.isCanceling = type == 'cancel';
        institutionService.search(type, $scope.viewModel.HomeInstitutionId, $scope.viewModel.SelectedCountry, $scope.viewModel.authorization).then(
            function(result, event) {
                $scope.approvedProgramList = result;
                if(firstLoad){
                    $scope.sortBy('Name');
                    firstLoad = false;
                }
                else{
                    $scope.figureOutApproveProgramsToDisplay();
                }
                $scope.isLoaded = true;
                $scope.isSearching = false;
                if(type == 'cancel')
                {
                    $scope.isCanceling = false;
                    $scope.changedItems = [];
                }
                $scope.currentPage = 1;
                $scope.searchOnLoad = true;
                
            }, function(error){
                $log.error(error);
            }            
        );
    }
    // Selects all displayed programs for the selected section
    $scope.selectAll = function(term)
    {
        angular.forEach($scope.filteredApprovedPrograms, function(program, key){
            switch (term) {
                case 'Spring':
                    program.activeProgramAuthorization.springTerm = $scope.selectAll.Spring;
                    program.activeProgramAuthorization.notApproved = false;
                    break;
                case 'Fall':
                    program.activeProgramAuthorization.fallTerm = $scope.selectAll.Fall;
                    program.activeProgramAuthorization.notApproved = false;
                    break;
                case 'Summer':
                    program.activeProgramAuthorization.summerTerm = $scope.selectAll.Summer;
                    program.activeProgramAuthorization.notApproved = false;
                    break;
                case 'Winter':
                    program.activeProgramAuthorization.winterTerm = $scope.selectAll.Winter;
                    program.activeProgramAuthorization.notApproved = false;
                    break;
                case 'AcademicYear':
                    program.activeProgramAuthorization.academicYear = $scope.selectAll.AcademicYear;
                    program.activeProgramAuthorization.notApproved = false;
                    break;
                case 'CalendarYear':
                    program.activeProgramAuthorization.calendarYear = $scope.selectAll.CalendarYear;
                    program.activeProgramAuthorization.notApproved = false;
                    break;
                case 'NotApproved':
                    program.activeProgramAuthorization.notApproved = $scope.selectAll.NotApproved;
                    program.activeProgramAuthorization.springTerm = false;
                    program.activeProgramAuthorization.fallTerm = false;
                    program.activeProgramAuthorization.summerTerm = false;
                    program.activeProgramAuthorization.winterTerm = false;
                    program.activeProgramAuthorization.academicYear = false;
                    program.activeProgramAuthorization.calendarTerm = false;
                default:
                    break;
            }
            $scope.valuesChanged(program.activeProgramAuthorization, !program.activeProgramAuthorization.notApproved);
        });
    }
    // Authorizes all programs
    $scope.authorizeAllPrograms = function()
    {
        $scope.processingAuthorizeAll = true;
        $scope.isApproveAll = true;
        var param = {
            message: "Are you sure you want to approve all IFSA programs?",
            successful: false,
            afterSave: false
        };
        var modalInstance = $modal.open({
            animation: true,
            templateUrl: urlService.getBaseResourceURL() + '/views/shared/HTML_AdvisorSaveModal.html',
            backdrop: 'static',
            resolve: {
                params: param
            },
            controller: 'confirmModalController'
        });
        modalInstance.result.then(function (result) {
            $scope.isApproveAll = false;
            if(result)
            {
                institutionService.authorizeAllPrograms($scope.viewModel.HomeInstitutionAccountId).then(
                    function(result){
                            $scope.processingAuthorizeAll = false;
                            $scope.viewModel.HomeInstitutionApprovesAllSummerPrograms = true;
                            $scope.viewModel.HomeInstitutionApprovesAllCalendarPrograms = true;
                            $scope.search('search');
                    },
                    function(error){
                        $scope.processingAuthorizeAll = false;
                        $log.error(error);
                    }
                );
            }
        }, function () {
            $log.info('Modal dismissed at: ' + new Date());
        });
    }

    // Selects all sections for the selected program
    $scope.selectAllAvalibleTerms = function(item)
    {
        if(item.activeProgramAuthorization.selectAllAvalibleTerms)
        {
            item.activeProgramAuthorization.springTerm = item.activeProgramAuthorization.availableTerms.indexOf("Spring") > -1 ? true : false;
            item.activeProgramAuthorization.fallTerm = item.activeProgramAuthorization.availableTerms.indexOf("Fall") > -1 ? true : false;
            item.activeProgramAuthorization.summerTerm = item.activeProgramAuthorization.availableTerms.indexOf("Summer") > -1 ? true : false;
            item.activeProgramAuthorization.winterTerm = item.activeProgramAuthorization.availableTerms.indexOf("Winter") > -1 ? true : false;
            item.activeProgramAuthorization.academicYear = item.activeProgramAuthorization.availableTerms.indexOf("Academic Year") > -1 ? true : false;
            item.activeProgramAuthorization.calendarYear = item.activeProgramAuthorization.availableTerms.indexOf("Calendar Year") > -1 ? true : false;
            item.activeProgramAuthorization.notApproved = false;
        }
        else
        {
            item.activeProgramAuthorization.springTerm = false;
            item.activeProgramAuthorization.fallTerm = false;
            item.activeProgramAuthorization.summerTerm = false;
            item.activeProgramAuthorization.winterTerm = false;
            item.activeProgramAuthorization.academicYear = false;
            item.activeProgramAuthorization.calendarYear = false;
            item.activeProgramAuthorization.notApproved = true;
        }
        $scope.valuesChanged(item.activeProgramAuthorization, true);

    }
    // When a checkbox is checked, add the program to the array of programs to update, but ensure a program is only in the list once.
    $scope.valuesChanged = function(item, isApproved)
    {
        item.selectedTerms = "";
        if(isApproved)
        {
            item.notApproved = false;
            // Spring
            if (item.springTerm) {
                item.selectedTerms = item.selectedTerms + 'Spring;';
            }
            else if(!item.springTerm && item.availableTerms.indexOf("Spring") > -1) {
                $scope.selectAll.Spring = false;
                $scope.viewModel.HomeInstitutionApprovesAllSpringPrograms = false;
                item.selectAllAvalibleTerms = false;
            }
            // Summer
            if (item.summerTerm) {
                item.selectedTerms = item.selectedTerms + 'Summer;';
            }
            else if(!item.summerTerm && item.availableTerms.indexOf("Summer") > -1) {
                $scope.selectAll.Summer = false;
                $scope.viewModel.HomeInstitutionApprovesAllSummerPrograms = false;
                item.selectAllAvalibleTerms = false;
            }
            // Fall
            if (item.fallTerm) {
                item.selectedTerms = item.selectedTerms + 'Fall;';
            }
            else if(!item.fallTerm && item.availableTerms.indexOf("Fall") > -1) {
                $scope.selectAll.Fall = false;
                $scope.viewModel.HomeInstitutionApprovesAllSpringPrograms = false;
                item.selectAllAvalibleTerms = false;
            }
            // Academic Year
            if (item.academicYear) {
                item.selectedTerms = item.selectedTerms + 'Academic Year;';
            }
            else if (!item.academicYear && item.availableTerms.indexOf("Academic Year") > -1) {
                $scope.selectAll.AcademicYear = false;
                $scope.viewModel.HomeInstitutionApprovesAllCalendarPrograms = false;
                item.selectAllAvalibleTerms = false;
            }
             // Winter
             if (item.winterTerm) {
                item.selectedTerms = item.selectedTerms + 'Winter;';
            }
            else if(!item.womterTerm && item.availableTerms.indexOf("Winter") > -1) {
                $scope.selectAll.Winter = false;
                $scope.viewModel.HomeInstitutionApprovesAllWinterPrograms = false;
                item.selectAllAvalibleTerms = false;
            }
            // Calendar Year
            if (item.calendarYear) {
                item.selectedTerms = item.selectedTerms + 'Calendar Year;';
            }
            else if (!item.calendarYear && item.availableTerms.indexOf("Calendar Year") > -1) {
                $scope.selectAll.CalendarYear = false;
                $scope.viewModel.HomeInstitutionApprovesAllCalendarPrograms = false;
                item.selectAllAvalibleTerms = false;
            }
        }
        else
        {
            item.selectedTerms = item.selectedTerms + 'Not Approved;';
            item.springTerm = false;
            item.summerTerm = false;
            item.fallTerm = false;
            item.academicYear = false;
            item.winterTerm = false;
            item.calendarYear = false;
            item.selectAllAvalibleTerms = false;
        }
        
        item.selectedTerms = item.selectedTerms.slice(0, -1);

        var hasProgram = false;
        angular.forEach($scope.changedItems, function(program, key){
            if(program.programId == item.programId)
            {
                program = item;
                hasProgram = true;
            }
        });
        if(hasProgram == false)
        {
            $scope.changedItems.push(item);
        }
    }
    // Sends the list of changed program authorizations back to Salesforce for saving.
    $scope.saveProgAuth = function() 
    {
        $scope.isSaving = true;
        var param = {
            message: "Are you sure you want to save these changes?",
            successful: false,
            afterSave: false
        };
        var modalInstance = $modal.open({
            animation: true,
            templateUrl: urlService.getBaseResourceURL() + '/views/shared/HTML_AdvisorSaveModal.html',
            backdrop: 'static',
            resolve: {
                params: param
            },
            controller: 'confirmModalController'
        });
        modalInstance.result.then(function (result) {
            if(result)
            {
                institutionService.saveProgAuth($scope.changedItems).then(
                    function(result){
                        $scope.changedItems = [];
                        $scope.search('search');
                        $scope.isSaving = false;
                    },
                    function(error){
                        $log.error('Program authorizations could not be saved');
                        $scope.isSaving = false;
                    }
                );
            }
        }, function () {
            $log.info('Modal dismissed at: ' + new Date());
            $scope.isSaving = false;
        });
    }

    $scope.loadMore = function() {
        let last = $scope.infiniteScrollResults.length - 1;
        let newLast = $scope.filteredApprovedPrograms.length >= last + 10 ? last + 10 : $scope.filteredApprovedPrograms.length;
        if(last < newLast){
            for (let index = last + 1; index < newLast; index++) {
                $scope.infiniteScrollResults.push($scope.filteredApprovedPrograms[index]);            
            }
        }
    }
    // Enables pagination on program authorizations
    $scope.figureOutApproveProgramsToDisplay = function() {
        $scope.infiniteScrollResults = [];
        var begin = (($scope.currentPage - 1) * $scope.itemsPerPage);
        var end = begin + $scope.itemsPerPage;
        $scope.filteredApprovedPrograms = $scope.approvedProgramList;
        $scope.selectAll.Spring = true;
        $scope.selectAll.Fall = true;
        $scope.selectAll.Summer = true;
        $scope.selectAll.AcademicYear = true;
        $scope.selectAll.Winter = true;
        $scope.selectAll.CalendarYear = true;
        angular.forEach($scope.filteredApprovedPrograms, function(program, key){
            if(!program.activeProgramAuthorization.springTerm) $scope.selectAll.Spring = false;
            if(!program.activeProgramAuthorization.fallTerm) $scope.selectAll.Fall = false;
            if(!program.activeProgramAuthorization.summerTerm) $scope.selectAll.Summer = false;
            if(!program.activeProgramAuthorization.winterTerm) $scope.selectAll.Winter = false;
            if(!program.activeProgramAuthorization.academicYear) $scope.selectAll.AcademicYear = false;
            if(!program.activeProgramAuthorization.calendarYear) $scope.selectAll.CalendarYear = false;
        });
        $scope.loadMore();
    };
    // User has changed pages of program authorizations
    $scope.pageChanged = function() {
        $scope.figureOutApproveProgramsToDisplay();
    };
    $scope.openProgramDetails = function (approvedProgram) {
        var modalInstance = $modal.open({
            animation: true,
            templateUrl: urlService.getBaseResourceURL() + '/views/shared/HTML_ApprovedProgramDetails.html',
            resolve: {
                data: approvedProgram.activeProgramAuthorization
            },
            controller: 'approvedProgramDetailsModalController'
        });
    }
    // Approves another user/contact at the home institution to use Advisor Portal
    $scope.approve = function (advisor) {
        advisor.isSubmitting = true;

        institutionService.approveUser(advisor.AdvisorId).then(
            function(result){
                advisor.AdvisorApprovedForAdvising = true;
                advisor.isSubmitting = false;
            },
            function(error){
                $log.error(error);
                advisor.isSubmitting = false;
            }
        )
    }
    // Disables access to Advisor Portal for the selected user/contact
    $scope.disable = function (advisor) {
        advisor.isSubmitting = true;

        institutionService.disableUser(advisor.AdvisorId).then(
            function(result){
                for(var i = 0; i < $scope.viewModel.advisorList.length; i++) {
                    var obj = $scope.viewModel.advisorList[i];

                    if(obj.AdvisorId == advisor.AdvisorId) {
                        $scope.viewModel.advisorList.splice(i, 1);
                    }
                }
                advisor.isSubmitting = false;
            },
            function(error){
                $log.error(error);
                advisor.isSubmitting = false;
            }
        )
    }
});