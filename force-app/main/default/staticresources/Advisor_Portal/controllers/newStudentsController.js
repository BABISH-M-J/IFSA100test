angular.module('app.controllers')
.controller('newStudentsController', function($scope, $modal, urlService, viewModel, studentsService,
                                              $log, $routeParams, $filter, dateService, gradeReportService,
                                              $timeout, programCMSService) 
{
    $scope.templateURL = urlService.getBaseResourceURL() + '/views/student_templates/';
    $scope.errors = [];
    $scope.loading = true;
    $scope.activeStudent = undefined;
    $scope.activeTab = undefined;
    $scope.activeApp = null;
    $scope.showFilters = false;
    $scope.appSelected = false;
    let option = $routeParams.option != null ? $routeParams.option : 'all'
    $scope.filters = { 
        otherOptions: option == 'all' || option == 'leads' ? option : 'all',
        // otherOptions: "",
        appStatus: "",
        appCountry: "",
        appTerm: "",
        appYear: "", 
        section: "",
        onlyProgramApproval: false,
        studentName: "",
    };
    $scope.studentsGettingStarted = viewModel.getViewModel().studentsGettingStarted;
    $scope.students = [];
    $scope.cmsLoading = true;
    $scope.currentPage = 0;
    // https://stackoverflow.com/questions/35880043/model-isnt-updating-when-selected-option-changes
    $scope.pageSize = {selected: 20};
    $scope.previousSize = $scope.pageSize.selected;
    $scope.totalRecords = 0;
    $scope.isDisabledSearchFilter = true;
    programCMSService.loadingPromise().then(result =>{
        $scope.cmsLoading = false;
    }, error => {
        console.log("Could not load program data");
    })
    
    $scope.numberOfPages=function(){
        return Math.ceil($scope.totalRecords/$scope.pageSize.selected);                
    }
    
    $scope.enableApplySearchFilterButton=function(){
        $scope.isDisabledSearchFilter = false;
    }
    
    $scope.changePageSize=function(pageSizeChanged){
        
        // hotfix by Powerfluence - ref. mail dt.1/13/2022 from Jennifer
        // var pageIndexCorrection = 1;
        // $scope.currentPage = $scope.currentPage + pageIndexCorrection;

        // var upperRecordNumberOfCurrentPage = $scope.currentPage * $scope.previousSize;
        // upperRecordNumberOfCurrentPage = Math.min( upperRecordNumberOfCurrentPage, $scope.totalRecords);
        // $scope.currentPage = Math.ceil( upperRecordNumberOfCurrentPage / $scope.pageSize.selected);
        // $scope.currentPage = $scope.currentPage - pageIndexCorrection;
        $scope.currentPage = 0;
        $scope.previousSize = $scope.pageSize.selected;
        // $scope.currentPage = Math.ceil($scope.previousSize*$scope.currentPage/$scope.pageSize.selected);                
        // hotfix by Powerfluence - ref. mail dt.1/13/2022 from Jennifer

        // $scope.currentPage = Math.ceil($scope.previousSize*$scope.currentPage/pageSizeChanged);                
        // $scope.getStudentsPaginated();
        $scope.appSelected = false;
        $scope.searchForStudents();
    }
    
    $scope.filterOtherOptions=function(student){
        let returnValue = false;

        switch ($scope.filterOtherOptions) {

            case "all":
                returnValue = true;
                break;

            case "pending":
                student.applications.v.forEach(application => {
                    if (application.Status === "Pending")
                    {
                        returnValue = true;                        
                    }
                });
                break;

            case "leads":
                returnValue = true;
                break;

            case "searches":
                hasSavedsearch = student.savedSearches.v.length > 0;
                returnValue = hasSavedsearch;
                break;

            case "notes":
                hasToolBoxNotes = student.toolBoxNotes.v.length > 0;
                returnValue = hasToolBoxNotes;
                break;

            case "favorites":
                hasFavoritePrograms = student.favoritePrograms.v.length > 0;
                returnValue = hasFavoritePrograms;
                break;
        
            default:
                break;
        }
    }

    $scope.goPreviousPage = function(){
      $scope.currentPage = $scope.currentPage - 1;
    //   $scope.getStudentsCount();
    //   $scope.getStudentsPaginated();
      $scope.getStudentsSearchCount();
      $scope.appSelected = false;
      $scope.searchForStudents();
    }
    
    $scope.goNextPage = function(){
        $scope.currentPage = $scope.currentPage + 1;
        // $scope.getStudentsCount();
        // $scope.getStudentsPaginated();
        $scope.getStudentsSearchCount();
        $scope.appSelected = false;
        $scope.searchForStudents();
    }
    
    $scope.applySearchFilter = function(){
        $scope.currentPage = 0;
        $scope.isDisabledSearchFilter = true;
        $scope.getStudentsSearchCount();
        $scope.appSelected = false;
        $scope.searchForStudents();
        // $scope.getStudentsPaginated();
    }

  studentsService.getStudentsViewModel().then(function(result){
        $scope.studentViewModel = result;
        if($scope.studentViewModel.AvailableStatuses.indexOf('All') == 0){
            $scope.studentViewModel.AvailableStatuses.splice(0, 1);
        }
        if($scope.studentViewModel.AvailableTerms.indexOf('All') == 0){
            $scope.studentViewModel.AvailableTerms.splice(0, 1);
        }
        if($scope.studentViewModel.AvailableYears.indexOf('All') == 0){
            $scope.studentViewModel.AvailableYears.splice(0, 1);
        }
        if($scope.studentViewModel.AvailableCountries.indexOf('All') == 0){
            $scope.studentViewModel.AvailableCountries.splice(0, 1);
        }
    }, function(error){
        $scope.errors.push(error);
    })

    $scope.selectStudent = function(student){
        if($scope.activeStudent != student)
        {
            $scope.activeStudent = student;
            $scope.activeTab = "info";
            $scope.activeApp = null;
            if($scope.activeStudent.favoritePrograms){
                programCMSService.loadingPromise().then(result =>{
                    $scope.activeStudent.favoritePrograms.forEach(p => {
                        p.cmsData = programCMSService.getProgramCMSRecord(p.CMS__c);
                    })
                }, error => {

                })                
            }
        }
        else
        {
            $scope.activeStudent = undefined;
            $scope.activeTab = undefined;
        }
    }

    $scope.applicationIcon = function(application, menuName){
        let htmlString = '';
        application.tooltips = [];
        if(application.Course_Load != 'Regular'){
            htmlString = htmlString + '<i class="exclamation circle right floated icon"></i>';
            application.tooltips.push('Course Load is ' + application.Course_Load);
        }

        if(application.programApprovalStatus != 'Complete' && (application.Status == 'Ready To Submit' || application.Status == 'Submitted' || application.Status == 'Accepted' || application.Status == 'Accepted (with Conditions)')){
            htmlString = htmlString + '<i class="right floated icons"><i class="clipboard list icon"></i><i class="mini bottom right corner inverted hourglass icon"></i></i>';
            application.tooltips.push('Program Approval has not been completed');
        }

        if(htmlString == '' && menuName == 'leftMenu'){
            htmlString = htmlString + '<i class="folder icon"></i>';
        }
        return htmlString;
    }

    $scope.displayAppToolTips = function(app){
        let result = '';
        if(app.tooltips && app.tooltips.length){
            for (let i = 0; i < app.tooltips.length; i++) {
                const tooltip = app.tooltips[i];
                result = result + (i > 0 ? ', ' : '') + tooltip;
            }
        }
        return result;
    }

    $scope.selectTab = function(appId){
        $scope.activeTab = appId;
        if(appId != "info" && appId != 'note' && appId != 'favorites' && appId != 'searches'){
            $scope.activeApp = $scope.activeStudent.applications.find(app => app.appId == appId);
            $scope.activeApp.statistics = [
                {
                    label: 'Application Status',
                    value: $scope.activeApp.Status
                },
                {
                    label: 'Approval Status',
                    value: $scope.activeApp.programApprovalStatus
                },
            ];
            switch ($scope.activeApp.Status) {
                case 'Program Selected':
                    if($scope.activeApp.Application_Deadline){
                        $scope.activeApp.statistics.push({
                            label: 'Application Deadline',
                            value: $filter('date')(dateService.convertDate($scope.activeApp.Application_Deadline), 'M/d/y')
                        });
                    }
                    break;
                case 'Ready To Submit':
                case 'Submitted':
                case 'Accepted':
                case 'Accepted (with Conditions)':
                    if($scope.activeApp.Start_Date){
                        $scope.activeApp.statistics.push({
                            label: 'Program Start',
                            value: $filter('date')(dateService.convertDate($scope.activeApp.Start_Date), 'M/d/y')
                        });
                    }
                    break;
                case 'On Site':
                    if($scope.activeApp.End_Date){
                        $scope.activeApp.statistics.push({
                            label: 'Program End',
                            value: $filter('date')(dateService.convertDate($scope.activeApp.End_Date), 'M/d/y')
                        });
                    }
                    break;
                default:
                    break;
            }
            if($scope.activeApp.Course_Load_Approved_By_Resident_Staff){
                $scope.activeApp.statistics.push({
                    label: 'Course Load',
                    value: $scope.activeApp.Course_Load
                });
            }
            if($scope.activeApp.Host_Transcript_Received){
                $scope.activeApp.statistics.push({
                    label: 'Host Transcript(s) Received',
                    value: $filter('date')(dateService.convertDate($scope.activeApp.Host_Transcript_Received), 'M/d/y')
                });
            }
            if($scope.activeApp.Hold_Date){
                $scope.activeApp.statistics.push({
                    label: $scope.activeApp.Release_Date ? 'Financial Hold Released' : 'Financial Hold',
                    value: $filter('date')($scope.activeApp.Release_Date ? dateService.convertDate($scope.activeApp.Release_Date) : dateService.convertDate($scope.activeApp.Hold_Date), 'M/d/y')
                })
            }
            if($scope.activeApp.Butler_Transcript_Mailed){
                $scope.activeApp.statistics.push({
                    label: 'Transcript Mailed',
                    value: $filter('date')(dateService.convertDate($scope.activeApp.Butler_Transcript_Mailed), 'M/d/y')
                })
            }
            if($scope.activeApp.Status == 'On Site' || $scope.activeApp.Status == 'Program Completed' || $scope.activeApp.Status == 'Withdraw'){
                $scope.activeAppTab = 'classes';
            }
            else{
                $scope.activeAppTab = 'items';
            }

            $scope.activeApp.buttons = [];
            $scope.activeApp.loading = true;
            studentsService.getAppDetailsAppItemsOnly(appId).then(function (result){
                $scope.activeApp.appItems = result.appItems;
                let programApprovalIndex = $scope.activeApp.appItems.findIndex(ai => ai.name == 'Program Approval');
                if(programApprovalIndex > -1){
                    $scope.activeApp.buttons.push({
                        label: 'Complete Program Approval',
                        value: 'Program_Approval',
                        disabled: $scope.activeApp.programApprovalStatus == 'Complete',
                        icon: 'clipboard list icon',
                        appItem: $scope.activeApp.appItems[programApprovalIndex]
                    });
                }
                let learningPlanIndex = $scope.activeApp.appItems.findIndex(ai => ai.name == 'Learning Plan');
                if(learningPlanIndex > -1){
                    $scope.activeApp.buttons.push({
                        label: 'View Learning Plan',
                        value: 'Learning_Plan',
                        disabled: $scope.activeApp.appItems[learningPlanIndex].status != 'Complete',
                        icon: 'list alternate outline icon',
                        appItem: $scope.activeApp.appItems[learningPlanIndex]
                    })
                }
                $scope.activeApp.loading = false;
            }, function (error){
                $log.error(error);
            });
            studentsService.getHousingInfo(appId).then(function (result){
                if(result.housingOptions){
                    $scope.activeApp.housingOptions = result.housingOptions;
                    $scope.activeApp.buttons.push({
                        label: 'View Housing Options',
                        value: 'Housing_Options',
                        disabled: false,
                        icon: 'home icon'
                    });
                }
                if(result.housingAssignment){
                    $scope.activeApp.housingAssignment = result.housingAssignment;
                    $scope.activeApp.statistics.push({
                        label: 'Housing Assignment',
                        value: result.housingAssignment.Name
                    });
                    $scope.activeApp.buttons.push({
                        label: 'View Housing Assignment',
                        value: 'Housing_Assignment',
                        disabled: false,
                        icon: 'map pin icon'
                    });
                }
                $scope.loading = false;
            }, function (error){
                $log.error(error);
                $scope.loading = false;
            });
        }
        else{
            $scope.activeApp = null;
            $scope.loading = false;
        }
    }
    $scope.selectAppTab = function(appTab){
        $scope.activeAppTab = appTab;
    }

    $scope.getStatusDefinition = function(status){
        return studentsService.getStatusDefinition(status);
    }

    $scope.getTopics = function(advisingTopics){
        if(advisingTopics){
            return advisingTopics.split(';');
        }
    }

    $scope.getStudents = function(){
        $scope.loading = true;
        studentsService.getStudents().then(function(result){
            $scope.students = result;
            $scope.totalRecords = $scope.students.length;
            let objectPrefixes = viewModel.getViewModel().objectPrefixes;
            let objectPrefix = $routeParams.option.substr(0, 3);
            let objectName;
            switch (objectPrefix) {
                case objectPrefixes.Application__c:
                    objectName = 'Application__c';
                    break;
                case objectPrefixes.Application_Item__c:
                    objectName = 'Application_Item__c';
                    break;
                case objectPrefixes.Contact:
                    objectName = 'Contact';
                    break;
                default:
                    break;
            }
            if(objectName == 'Application_Item__c'){
                for (let index = 0; index < $scope.students.length; index++) {
                    const student = $scope.students[index];
                    for (let appIndex = 0; appIndex < student.applications.length; appIndex++) {
                        const application = student.applications[appIndex];
                        const appItem = application.appItems.find(ai => ai.Id == $routeParams.option);
                        if(!appItem){
                            continue;
                        }
                        $scope.selectStudent(student);
                        $scope.selectTab(application.appId);
                        $scope.viewAppItem(appItem, null);
                        break;
                    }
                    if($scope.activeStudent){
                        break;
                    }
                }
            }
            else if(objectName == 'Application__c'){
                for (let index = 0; index < $scope.students.length; index++) {
                    const student = $scope.students[index];
                    const application = student.applications.find(a => a.appId == $routeParams.option);
                    if(!application){
                        continue;
                    }
                    $scope.selectStudent(student);
                    $scope.selectTab(application.appId);
                    break;
                }
            }
            else if(objectName == 'Contact'){
                const student = $scope.students.find(s => s.StudentId == $routeParams.option);
                $scope.selectStudent(student);
            }
            $scope.loading = false;
        }, function(error){
            $log.error(error);
            $scope.loading = false;
        });
    }
    
    $scope.searchForStudents = function() {
        $scope.loading = true;
        $scope.isDisabledSearchFilter = true;
        studentsService.searchForStudents($scope.filters.appTerm, $scope.filters.appYear,
                                         $scope.filters.appCountry, $scope.filters.appStatus,
                                         $scope.filters.onlyProgramApproval, $scope.filters.studentName,
                                         $scope.currentPage, $scope.pageSize.selected, $scope.filters.otherOptions)
                        .then(function(result){
            $scope.students = result;
            let objectPrefixes = viewModel.getViewModel().objectPrefixes;
            let objectPrefix = $routeParams.option.substr(0, 3);
            let objectName;
            switch (objectPrefix) {
                case objectPrefixes.Application__c:
                    objectName = 'Application__c';
                    break;
                case objectPrefixes.Application_Item__c:
                    objectName = 'Application_Item__c';
                    break;
                case objectPrefixes.Contact:
                    objectName = 'Contact';
                    break;
                default:
                    break;
            }
            if(objectName == 'Application_Item__c'){
                for (let index = 0; index < $scope.students.length; index++) {
                    const student = $scope.students[index];
                    for (let appIndex = 0; appIndex < student.applications.length; appIndex++) {
                        const application = student.applications[appIndex];
                        const appItem = application.appItems.find(ai => ai.Id == $routeParams.option);
                        if(!appItem){
                            continue;
                        }
                        $scope.selectStudent(student);
                        $scope.selectTab(application.appId);
                        $scope.viewAppItem(appItem, null);
                        break;
                    }
                    if($scope.activeStudent){
                        break;
                    }
                }
            }
            else if(objectName == 'Application__c'){
                for (let index = 0; index < $scope.students.length; index++) {
                    const student = $scope.students[index];
                    const application = student.applications.find(a => a.appId == $routeParams.option);
                    if(!application){
                        continue;
                    }
                    $scope.selectStudent(student);
                    $scope.selectTab(application.appId);
                    break;
                }
            }
            else if(objectName == 'Contact'){
                const student = $scope.students.find(s => s.StudentId == $routeParams.option);
                $scope.selectStudent(student);
            }
            $scope.loading = false;
            /***
             * SPR-002 INC-003 
             * Code block added by: Powerfluence
             */
            if ($scope.appSelected)
            {
                $scope.loading = true;
                let selectedStudent = $scope.students.find(s => s.StudentId == $scope.activeStudent.StudentId);
                $scope.activeStudent = selectedStudent;
                // if (selectedStudent)
                // {
                //     $scope.activeStudent = selectedStudent;
                //     $scope.selectTab($scope.activeApp.appId);
                // } else {
                //     $scope.activeStudent = undefined;
                // }
                if (selectedStudent)
                {
                    $scope.selectTab($scope.activeApp.appId);
                }
                $scope.loading = false;
            }
        }, function(error){
            $log.error(error);
            $scope.loading = false;
        });
    };

    $scope.getStudentsSearchCount = function() {
        studentsService.getStudentsSearchCount($scope.filters.appTerm, $scope.filters.appYear,
                                        $scope.filters.appCountry, $scope.filters.appStatus,
                                        $scope.filters.onlyProgramApproval,  $scope.filters.studentName,
                                        $scope.filters.otherOptions).then(function(result){
            $scope.totalRecords = result;
        }, function(error){
            $log.error(error);
            $scope.loading = false;
        });
    };

    $scope.getStudentsCount = function() {
        studentsService.getStudentsCount().then(function(result){
            $scope.totalRecords = result;
        }, function(error){
            $log.error(error);
            $scope.loading = false;
        });
    };

    $scope.getStudentsPaginated = function(){
        $scope.loading = true;
        studentsService.getStudentsPaginated($scope.currentPage, $scope.pageSize.selected).then(function(result){
            $scope.students = result;
            let objectPrefixes = viewModel.getViewModel().objectPrefixes;
            let objectPrefix = $routeParams.option.substr(0, 3);
            let objectName;
            switch (objectPrefix) {
                case objectPrefixes.Application__c:
                    objectName = 'Application__c';
                    break;
                case objectPrefixes.Application_Item__c:
                    objectName = 'Application_Item__c';
                    break;
                case objectPrefixes.Contact:
                    objectName = 'Contact';
                    break;
                default:
                    break;
            }
            if(objectName == 'Application_Item__c'){
                for (let index = 0; index < $scope.students.length; index++) {
                    const student = $scope.students[index];
                    for (let appIndex = 0; appIndex < student.applications.length; appIndex++) {
                        const application = student.applications[appIndex];
                        const appItem = application.appItems.find(ai => ai.Id == $routeParams.option);
                        if(!appItem){
                            continue;
                        }
                        $scope.selectStudent(student);
                        $scope.selectTab(application.appId);
                        $scope.viewAppItem(appItem, null);
                        break;
                    }
                    if($scope.activeStudent){
                        break;
                    }
                }
            }
            else if(objectName == 'Application__c'){
                for (let index = 0; index < $scope.students.length; index++) {
                    const student = $scope.students[index];
                    const application = student.applications.find(a => a.appId == $routeParams.option);
                    if(!application){
                        continue;
                    }
                    $scope.selectStudent(student);
                    $scope.selectTab(application.appId);
                    break;
                }
            }
            else if(objectName == 'Contact'){
                const student = $scope.students.find(s => s.StudentId == $routeParams.option);
                $scope.selectStudent(student);
            }
            $scope.loading = false;
        }, function(error){
            $log.error(error);
            $scope.loading = false;
        });
    }

    $scope.appButtonClicked = function(button) {
        button.loading = true;
        switch (button.value) {
            case 'Program_Approval':
                $scope.viewAppItem(button.appItem, 'pa', button);
                break;
            case 'Learning_Plan':
                $scope.viewAppItem(button.appItem, 'lp', button);
                break;
            case 'Housing_Options':
            case 'Housing_Assignment':
                let result;
                switch (button.value) {
                    case 'Housing_Options':
                        result = {
                            housingOptions: $scope.activeApp.housingOptions
                        }
                        break;
                    case 'Housing_Assignment':
                        result = {
                            housingAssignment: $scope.activeApp.housingAssignment
                        }
                    default:
                        break;
                }
                var modalInstance = $modal.open({
                    animation: true,
                    // size: 'lg',
                    templateUrl: urlService.getBaseResourceURL() + '/views/shared/HTML_HousingModal.html',
                    resolve: {
                        data: result
                    },
                    controller: 'housingModalController'
                });
                modalInstance.opened.then(function(){
                    button.loading = false;
                    setTimeout(function(){resize();}, 500);					
                });
                modalInstance.result.then(function (result){
                    
                }, function(result){
                    
                });
                break;
        
            default:
                break;
        }
    }

    $scope.viewAppItem = function (item, type, button) {
        $scope.loading = true;
        let itemId = item.id ? item.id : item.Id;
        item.loading = true;
        
        studentsService.getAppItem(itemId).then(function(result){
            var modalInstance = $modal.open({
                animation: true,
                size: 'lg',
                templateUrl: urlService.getSPResourceURL() + '/views/shared/modals/HTML_AppItemModal.html',
                resolve: {
                    data: result
                  },
                controller: 'appItemController'
            });
            modalInstance.opened.then(function(){
                item.loading =false;
                if(button)
                {
                    button.loading = false;
                }
                setTimeout(function(){resize();}, 500);					
            });
            modalInstance.result.then(function (isComplete){
                if(isComplete){
                    $scope.appSelected = true;
                    $scope.searchForStudents();
                }
            });
            $scope.loading = false;
        },function(error){
            $scope.loading = false;
            $log.error(error);
        });
    }

    $scope.generateGradeReport = function(){
        $scope.generatingGradeReport = true;
        gradeReportService.generatePDF($scope.activeApp.appId).then(function(result){
            $scope.generatingGradeReport = false;
        }, function(errors){
            $scope.generatingGradeReport = false;
            for (let i = 0; i < errors.length; i++) {
                const e = errors[i];
                $scope.errors.push(e);
            }            
        });
    }

    // $scope.getStudents();
    // $scope.getStudentsCount();
    // $scope.getStudentsPaginated();
    $scope.getStudentsSearchCount();
    $scope.appSelected = false;
    $scope.searchForStudents();
})

// angular.module.filter("startFrom", function() {
//     //We already have a limitTo filter built-in to angular,
//     //let's make a startFrom filter

//     return function(start) {
//     start = +start; //parse to int
//     return $scope.students.slice(start);
// }
// });