/**
 * Student Portal Course Interest Form Controller
 * @file Student Portal Course Interest Form Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('classInterestFormController', function($scope, $modal, $routeParams, urlService, viewModel, applicationItemService, classInterestService, courseRegService, dynamicFormService, errorModalService, toArrayFilter, $window, $timeout)
{
    $scope.urlService = urlService;
    $scope.viewModel = viewModel.getViewModel();
    $scope.brandImageURL = urlService.getBaseResourceURL() + '/images/IFSA_Navbar_Brand_Logo.png';
    /* STEPS
        Steps of the form are defined by creating and step object and pushing to $scope.steps. The first and last steps are defined below. Steps for required, departments and 
        selections are defined and pushed as needed in the function $scope.getCoursesFromForm. If additional steps are needed in the future they will need to be defined in this js file
    */
    $scope.steps = [
        {apiName: 'introduction', description: 'How to complete this form', isCompleted: false, shortTitle: 'Intro', title: 'Introduction', templateUrl: urlService.getBaseResourceURL() + '/views/pages/cif-intro.html' },
        {apiName: 'sign', description: 'Complete Class Interest Form', isCompleted: false, shortTitle: 'Sign', title: 'Sign and Complete', templateUrl: urlService.getBaseResourceURL() + '/views/pages/cif-complete.html'}
    ];
    
    $scope.pdfLoading = false;
    $scope.savingForLater = false;
    $scope.saving = false;

    $scope.updateView = function(view){
        $scope.viewIndex = $scope.steps.findIndex(s => s.apiName == view.apiName);
        for (let index = 0; index < $scope.viewIndex; index++) {
            const element = $scope.steps[index];
            element.isCompleted = true;
        }
        if(view.apiName == 'selections' && $scope.appItem.form.formData.departments && $scope.appItem.form.formData.departments.linkClassesDept)
        {
            let selections = toArrayFilter($scope.courseSelections);
            for (let index = 0; index < selections.length; index++) {
                const course = selections[index];
                if(course.selectedDepartment){
                    $scope.departmentSelected(course);
                }
            }
        }
        $scope.view = view;
        if($scope.viewIndex == $scope.steps.length - 1){

        }
    }
    
    $scope.loadAppItem = function(){
        $scope.updateView($scope.steps[0]);
        $scope.loadingForm = true;
        $scope.loadingCourses = true;
        $scope.introduction = null;
        $scope.closing = null;
        $scope.signature = null;
        var promise = applicationItemService.getApplicationItemDetails($routeParams.appItemId);
        promise.then(function(result){
            $scope.appItem = result;
            if($scope.appItem.status == 'Complete'){
                $scope.isComplete = true;            
                if(result.files[0]){
                    $scope.appItem.pdf = result.files[0];
                }
            }
            else {
                let index = $scope.appItem.form.formData.items.findIndex(i => i.fieldType == 'Date')
                if(index > -1){
                    $scope.appItem.form.formData.items[index].response = new Date();
                }
            }
            // We may want to consider before we push to production to only run the next line if $scope.isComplete == false
            $scope.getCourseRegistrations();
        },
        function(result){
            errorModalService.openErrorModal('An Error has occured loading your applicaiton item', 'There was an error loading your applicaiton item. Please try again. If you continue to have problems, contact IFSA.');
        });
    }

    $scope.getCourseRegistrations = function() {
        var promise = classInterestService.getCourseRegistrations();
        promise.then(function(result){
            $scope.courseRegistrations = result;
            $scope.getCoursesFromForm();
        },
        function(result){
            errorModalService.openErrorModal('An Error has occured loading your course interest form', 'There was an error loading your course interest form. Please try again. If you continue to have problems, contact IFSA.');
        });
    }

    $scope.getCoursesFromForm = function(){
        console.log('getCoursesFromForm Start');
        var courseIds = [];
        if($scope.appItem.form.formData.formRules){
            for (let index = 0; index < $scope.appItem.form.formData.formRules.length; index++) {
                const rule = $scope.appItem.form.formData.formRules[index];
                if(rule.ruleItems != null){
                    for (let indexRuleItem = 0; indexRuleItem < rule.ruleItems.length; indexRuleItem++) {
                        const ruleItem = rule.ruleItems[indexRuleItem];
                        courseIds.push(ruleItem.relId);
                    }
                }
            }
        }
        for (let index = 0; index < $scope.courseRegistrations.length; index++) {
            const cr = $scope.courseRegistrations[index];
            courseIds.push(cr.courseId);
        }
        var deptPromise = classInterestService.getDepartments();
        var promise = classInterestService.getCourses(courseIds);
        promise.then(function(result){
            var courseSelections = {};
            $scope.alternateRule = null;
            $scope.requiredCount = 0;
            let departmentRuleIndex;
            // Process rules
            if($scope.appItem.form.formData.formRules){
                for (let index = 0; index < $scope.appItem.form.formData.formRules.length; index++) {
                    const rule = $scope.appItem.form.formData.formRules[index];
                    if(rule.ruleItems != null){
                        if(rule.ruleName == 'Must_Select_Course_X')
                        {
                            rule.title = 'Required classes';
                            rule.completed = true;
                            for (let index = 0; index < rule.ruleItems.length; index++) {
                                const ruleItem = rule.ruleItems[index];
                                ruleItem.course = result.find(c => c.Id == ruleItem.relId);
                                ruleItem.isFavorite = $scope.favoriteClasses.findIndex(f => f.Course__c == ruleItem.relId) > -1;
                                ruleItem.course.isRequired = true;
                                ruleItem.isSelected = true;
                                $scope.requiredCount = $scope.requiredCount + 1;
                                ruleItem.course.isAlternate = false;
                                var csLength = Object.keys(courseSelections).length + 1;
                                ruleItem.course.rank = csLength;
                                courseSelections["Selection" + csLength] = ruleItem.course;
                                courseSelections["Selection" + csLength].courseRegistration = $scope.courseRegistrations.find(cr => cr.courseId == ruleItem.course.Id);
                            }
                        }
                        else if(rule.ruleName == 'Must_Select_n_Courses')
                        {
                            let badItemIndexs = [];
                            rule.title = 'Must select ' + rule.reqRuleItems + ' class(es) from this list';
                            for (let indexRuleItem = 0; indexRuleItem < rule.ruleItems.length; indexRuleItem++) {
                                const ruleItem = rule.ruleItems[indexRuleItem];
                                ruleItem.course = result.find(c => c.Id == ruleItem.relId);
                                if(ruleItem.course){
                                    ruleItem.isFavorite = $scope.favoriteClasses.findIndex(f => f.Course__c == ruleItem.relId) > -1;
                                    ruleItem.course.isRequired = false;
                                }
                                else{
                                    badItemIndexs.push(indexRuleItem);
                                }
                            }
                            for(let bi = badItemIndexs.length - 1; bi > -1; bi--){
                                const i = badItemIndexs[bi];
                                rule.ruleItems.splice(i, 1);
                            }
                        }
                        else if(rule.ruleName == 'Advertise_X_Courses_in_List')
                        {
                            let badItemIndexs = [];
                            rule.title = 'Special Offerings';
                            for (let indexRuleItem = 0; indexRuleItem < rule.ruleItems.length; indexRuleItem++) {
                                const ruleItem = rule.ruleItems[indexRuleItem];
                                ruleItem.course = result.find(c => c.Id == ruleItem.relId);
                                if(ruleItem.course){
                                    ruleItem.isFavorite = $scope.favoriteClasses.findIndex(f => f.Course__c == ruleItem.relId) > -1;
                                    ruleItem.course.isRequired = false;
                                }
                                else{
                                    badItemIndexs.push(indexRuleItem);
                                }
                            }
                            for(let bi = badItemIndexs.length - 1; bi > -1; bi--){
                                const i = badItemIndexs[bi];
                                rule.ruleItems.splice(i, 1);
                            }
                        }
                        if($scope.steps.findIndex(s => s.apiName == 'required') === -1){
                            $scope.steps.splice($scope.steps.length - 1, 0, {apiName: 'required', description: 'Select required or recommended classes', isCompleted: false, shortTitle: 'Required', title: 'Required and Recommended', templateUrl: urlService.getBaseResourceURL() + '/views/pages/cif-required.html'});   
                        }
                    }
                    else
                    {
                        rule.title = rule.ruleName;
                        if(rule.ruleName == 'Must_Select_Alternates')
                        {
                            $scope.alternateRule = rule;
                        }
                        else if(rule.ruleName == 'May_Only_Select_Courses_from_N_Depts')
                        {
                            rule.title = 'Select Departments';
                            rule.noResText = rule.noResText != null ? rule.noResText.replace(/\n/g, "<br />") : rule.noResText;
                            // Departments need to be fetched from Salesforce
                            // These lines needs to be the end of this else if block!!! Move rule to formDate, splice rule form array.
                            console.log('About to create Department step');
                            $scope.steps.splice($scope.steps.length - 1, 0, {apiName: 'departments', description: 'Select department at host institution', isCompleted: false, shortTitle: 'Departments', title: 'Departments', templateUrl: urlService.getBaseResourceURL() + '/views/pages/cif-departments.html'});
                            $scope.appItem.form.formData.departments = rule;
                            departmentRuleIndex = index;
                        }
                    }
                }
            }
            if($scope.steps.findIndex(s => s.apiName == 'departments') !== -1)
            {
                $scope.appItem.form.formData.formRules.splice(departmentRuleIndex, 1);
                $scope.appItem.form.formData.departments.designations.forEach(d => {
                    d.selected = false;
                    d.selectedOption = null;
                });
                $scope.appItem.form.formData.departments.departmentLabel = 'Departments';
                deptPromise.then(function(result){
                    $scope.appItem.form.formData.departments.departmentsArray = result;
                }, function(error){
                    console.log('Could not load departments');
                })
                $scope.deptPickerStatus = {
                    isopen: false
                  };
                $scope.appItem.form.formData.departments.selectedDepartments = [];
                if($scope.appItem.status != 'Incomplete'){
                    let deptSelectionsPromise = classInterestService.getDepartmentApplications();
                    deptSelectionsPromise.then(function(result){
                        if($scope.appItem.form.formData.departments.selectDesignations){
                            for (let i = 0; i < $scope.appItem.form.formData.departments.designations.length; i++) {
                                const designation = $scope.appItem.form.formData.departments.designations[i];
                                let deptIndex = result.findIndex(d => d.designation == designation.name);
                                if(deptIndex > -1){
                                    designation.selectedOption = result[deptIndex].Id;
                                    $scope.addToSelectedWithDesignation(result[deptIndex].Id, designation);
                                    $timeout(function () {
                                        let i = $scope.appItem.form.formData.departments.selectedDepartments.findIndex(d => d.Id == result[deptIndex].Id);
                                        $scope.appItem.form.formData.departments.selectedDepartments[i].recordId = result[deptIndex].recordId;
                                    }, 5000);
                                }
                            }
                        }
                    }, function(error){
                        console.log('Could not load department applications');
                    })
                }
            }
            if($scope.appItem.form.formData.numReqElements)
            {
                $scope.steps.splice($scope.steps.length - 1, 0, {apiName: 'selections', description: 'Verify your selections in order of preference', shortTitle: 'Selections', title: 'Selections', templateUrl: urlService.getBaseResourceURL() + '/views/pages/cif-classes.html'});
            }
            // Place course registrations in course selections and create placeholders if needed
            var rank = Object.keys(courseSelections).length + 1;
            let numberOfPrimaryCR = 0;
            $scope.courseRegistrations.forEach(cr => {
                if(!cr.alternateFor){
                    numberOfPrimaryCR++;
                }
            })
            var maxIndex = $scope.appItem.form.formData.minNumReqElements != undefined ? (numberOfPrimaryCR > $scope.appItem.form.formData.minNumReqElements ? numberOfPrimaryCR : $scope.appItem.form.formData.minNumReqElements) : $scope.appItem.form.formData.numReqElements;
            if(Object.keys(courseSelections).length > maxIndex){
                maxIndex = Object.keys(courseSelections).length;
            }
            for(let index = Object.keys(courseSelections).length; index < maxIndex; index++){
                var ac;
                if($scope.alternateRule && ($scope.alternateRule.altForEach || $scope.alternateRule.reqElements > 0)){
                    ac = { Id: null, isAlternate: true };
                    $scope.alternateRule.reqElements = !$scope.alternateRule.altForEach ?  --$scope.alternateRule.reqElements : null;
                }
                var crIndex = $scope.courseRegistrations.findIndex(cr => cr.rank == rank && !cr.alternateFor);
                if(crIndex !== -1)
                {
                    let cr = $scope.courseRegistrations[crIndex];
                    let altIndex = $scope.courseRegistrations.findIndex(alt => alt.alternateFor == cr.courseRegId);
                    let alt = null;
                    let altCr = null;
                    if(altIndex !== -1)
                    {
                        altCr = $scope.courseRegistrations[altIndex];
                        alt = result.find(c => c.Id == altCr.courseId);
                        alt.courseRegistration = altCr;
                        alt.isAlternate = true;
                    }
                    let course = result.find(c => c.Id == cr.courseId);
                    course.isAlternate = false;
                    course.courseRegistration = cr;
                    course.selectedDepartment = cr.selectedDepartment;
                    course.fulfillsDegreeRequirement = cr.fulfillsDegreeRequirement ? cr.fulfillsDegreeRequirement : false;
                    course.alternateCourse = alt;
                    course.rank = rank;

                    courseSelections["Selection" + (index + 1)] = course;

                    if($scope.appItem.form.formData.formRules){
                        for (let index = 0; index < $scope.appItem.form.formData.formRules.length; index++) {
                            const rule = $scope.appItem.form.formData.formRules[index];
                            if(rule.ruleItems)
                            {
                                var ruleItemIndex = rule.ruleItems.findIndex(ri => ri.relId == cr.courseId)
                                if(ruleItemIndex > -1){
                                    rule.ruleItems[ruleItemIndex].isSelected = true;
                                    if(rule.ruleName == 'Must_Select_n_Courses'){
                                        course.noAlternate = true;
                                    }
                                }
                                if(altCr)
                                {
                                    ruleItemIndex = rule.ruleItems.findIndex(ri => ri.relId == altCr.courseId)
                                    if(ruleItemIndex > -1){
                                        rule.ruleItems[ruleItemIndex].isSelected = true;
                                    }
                                }
                            }
                            
                        }
                    }
                }
                else
                {
                    courseSelections["Selection" + (index + 1)] = {
                        Id: null,
                        isAlternate: false,
                        courseRegistration: null,
                        alternateCourse: ac,
                        rank: rank
                    }
                }
                rank = rank + 1;
            }
            if($scope.appItem.form.formData.formRules){
                for (let index = 0; index < $scope.appItem.form.formData.formRules.length; index++) {
                    const rule = $scope.appItem.form.formData.formRules[index];
                    if(rule.ruleItems && rule.ruleName == 'Must_Select_n_Courses')
                    {
                        let selectedItemCount = 0;
                        for (let i = 0; i < rule.ruleItems.length; i++) {
                            const ruleItem = rule.ruleItems[i];
                            if(ruleItem.isSelected)
                            {
                                selectedItemCount++;
                            }
                        }
                        if(rule.reqRuleItems == selectedItemCount){
                            rule.completed = true;
                        }
                    }
                }
            }
            $scope.courseSelections = courseSelections;
            $scope.loadingCourses = false;
            $scope.numberOfRemainingCourses();
            $scope.numberOfRemainingAlternates();
        }, function(result){
            errorModalService.openErrorModal('An Error has occured loading course data', 'There was an error loading course data. Please try again. If you continue to have problems, contact IFSA.');
        });
        console.log('getCoursesFromForm End');
    }

    $scope.classSearch = function(course, aFor){
        var key
        for (const k in $scope.courseSelections) {
            if ($scope.courseSelections.hasOwnProperty(k)) {
                const c = $scope.courseSelections[k];
                if(c == course){
                    key = k;
                }
            }
        }
        let selectedCourse = $scope.courseSelections[key];
        let alternateForId = aFor;
        //console.log('Launching class search modal.');
        var modalInstance = $modal.open({
            animation: true,
            size: 'lg',
            backdrop: 'static',
            controller: 'classSearchModalController',
            templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/ClassSearchModal.html',
            scope: $scope,
            resolve: {
                data: {
                    title: 'Class Search',
                    favorites : $scope.favoriteClasses,
                    hasFavorites : $scope.favoriteClasses.length > 0 ? true : false,
                    courseList: toArrayFilter($scope.courseSelections)
                }
            }
        });
        modalInstance.result.then(function (course) {
            //resolve action from modal
            if(alternateForId)
            {
                course.alternateFor = alternateForId;
                course.isAlternate = true;
                course.selectedDepartment = selectedCourse.selectedDepartment;
                selectedCourse.alternateCourse = course;
            }
            else
            {
                course.rank = selectedCourse.rank;
                selectedCourse = course;
                selectedCourse.fulfillsDegreeRequirement = false;
            }
            $scope.courseSelections[key] = selectedCourse;
        }, function() {
            // modal dismissed
        });
    }

    $scope.nextView = function(){
        let index = $scope.steps.findIndex(s => s.apiName == $scope.view.apiName);
        $scope.view.isCompleted = true;
        $scope.updateView($scope.steps[index + 1]);
    }

    $scope.loadFavoriteClasses = function() {
        $scope.favoritesPromise = classInterestService.loadFavorites();
        $scope.favoritesPromise.then(function(result){
            $scope.favoriteClasses = result;
        },
        function(result){
            errorModalService.openErrorModal('An Error has occured loading your class favorites', 'There was an error loading your class favorites. Please try again. If you continue to have problems, contact IFSA.');
        });
    }

    $scope.determineWidth = function() {
        if($scope.windowWidth < 992){
            return "small"
        }
        else{
            return "large"
        }
    }
    
    $scope.loadAppItem();
    $scope.loadFavoriteClasses();

    $scope.$watch('view', function() {
        if($scope.view.apiName == 'sign'){
            setTimeout(function(){resize();}, 500);
        }
    });

    $scope.greaterThan = function(prop, val){
        return function(item){
          return item[prop] > val;
        }
    }

    $scope.lessThan = function(prop, val){
        return function(item){
          return item[prop] < val;
        }
    }
    $scope.numberOfRemainingCourses = function(){
        var value = 0;
        if($scope.courseSelections){
            var selections = toArrayFilter($scope.courseSelections);
            for (let index = 0; index < selections.length; index++) {
                const element = selections[index];
                if(element.Id == null)
                {
                    value = ++value;
                }
            }
            $scope.loadingForm = false;
        }
        console.log('numberOfRemainingCourses => ' + value);
        return value;
    }

    $scope.numberOfRemainingAlternates = function(){
        var value = 0;
        if($scope.alternateRule && $scope.courseSelections){
            var selections = toArrayFilter($scope.courseSelections);
            for (let index = 0; index < selections.length; index++) {
                const element = selections[index];
                if(!element.noAlternate && !element.isRequired && (!element.alternateCourse || !element.alternateCourse.Id))
                {
                    value = ++value;
                }
            }
            $scope.loadingForm = false;
        }
        return value
    }

    $scope.maxNumOfItems = function() {
        if(!$scope.appItem.form.formData.departments || !$scope.appItem.form.departments.maxClassesPerDept){
            return 100;
        }
        else {
                return (($scope.appItem.form.formData.departments || {}).maxClassesPerDept || 0) * $scope.appItem.form.formData.departments.selectedDepartments.length;
        }
        //return (($scope.appItem.form.formData.departments || {}).maxClassesPerDept || 0) * $scope.appItem.form.formData.departments.selectedDepartments.length;
    }

    $scope.numberOfCourses = function(){
        let selections = toArrayFilter($scope.courseSelections)
        return selections.length;
    }

    $scope.numberOfRemainingCoursesForDept = function(department){
        var value = $scope.appItem.form.formData.departments.minClassesPerDept;
        if($scope.courseSelections){
            var selections = toArrayFilter($scope.courseSelections);
            for (let index = 0; index < selections.length; index++) {
                const element = selections[index];
                if(element.selectedDepartment && element.selectedDepartment == department.Id)
                {
                    value = --value;
                }
            }
        }
        return value >= 0 ? value : 0;
    }

    $scope.hasRuleItems = function() {
        return function(item){
            return item.ruleItems && item.ruleItems.length && item.ruleName != 'Change_Phase_of_App_Item_X';
        }
    }

    $scope.submitForm = function()
    {
        console.log('submitForm Start');
        var modalInstance = $modal.open({
            animation: true,
            size: 'lg',
            templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/ClassInterestFormSubmitModal.html',
            controller: 'classInterestFormSubmitModalController'
        });
        modalInstance.opened.then(function(){
            //setTimeout(function(){resize();}, 500);
        });
        modalInstance.result.then(function (course) {
            //resolve action from modal
            // Save the form with save for later = false
            $scope.saveForm(false);
        }, function() {
            // modal dismissed
        });
        console.log('submitForm End');
    }

    $scope.saveForm = function(saveForLater){
        console.log('saveForm Start');
        console.log('saveForLater => ' + saveForLater);
        // insert / update course registrations
        if(saveForLater){
            $scope.savingForLater = true;
        }
        else{
            $scope.saving = true;
        }
        var courseRegs = [];
        for (const key in $scope.courseSelections) {
            if ($scope.courseSelections.hasOwnProperty(key)) {
                const element = $scope.courseSelections[key];
                if(element.courseRegistration)
                {
                    element.courseRegistration.courseStatus = saveForLater ? 'CIF - Draft' : 'CIF - Submitted';
                    if(!element.courseRegistration.alternateFor){
                        element.courseRegistration.alternateFor = element.alternateFor != null ? element.alternateFor : null;
                    }                    
                    element.courseRegistration.rank = element.rank;
                    element.courseRegistration.fulfillsDegreeRequirement = element.fulfillsDegreeRequirement ? element.fulfillsDegreeRequirement : false;
                    element.courseRegistration.selectedDepartment = element.selectedDepartment;
                    courseRegs.push(element.courseRegistration);
                    console.log('element.alternateCourse => ' + element.alternateCourse);
                    console.log('element.alternateCourse.courseRegistration => ' + element.alternateCourse.courseRegistration);
                    if(element.alternateCourse && element.alternateCourse.courseRegistration)
                    {
                        element.alternateCourse.courseRegistration.courseStatus = saveForLater ? 'CIF - Draft' : 'CIF - Submitted';
                        if(!element.alternateCourse.courseRegistration.alternateFor){
                            element.alternateCourse.courseRegistration.alternateFor = element.alternateFor != null ? element.alternateFor : null;
                        } 
                        // Do not need alternate classes to be ranked since they are essentially ranked with the primary.          
                        //element.alternateCourse.courseRegistration.rank = element.rank;
                        courseRegs.push(element.alternateCourse.courseRegistration);
                    }
                    else if(element.alternateCourse && element.alternateCourse.Id)
                    {
                        element.alternateCourse.Status__c = saveForLater ? 'CIF - Draft' : 'CIF - Submitted';
                        courseRegs.push(classInterestService.createCourseRegistration(element.alternateCourse));
                    }
                }
                else if(element.Id)
                {
                    element.Status__c = saveForLater ? 'CIF - Draft' : 'CIF - Submitted';
                    courseRegs.push(classInterestService.createCourseRegistration(element));
                    if(element.alternateCourse && element.alternateCourse.courseRegistration)
                    {
                        element.alternateCourse.courseRegistration.courseStatus = saveForLater ? 'CIF - Draft' : 'CIF - Submitted';
                        if(!element.alternateCourse.courseRegistration.alternateFor){
                            element.alternateCourse.courseRegistration.alternateFor = element.alternateFor != null ? element.alternateFor : null;
                        }                    
                        element.alternateCourse.courseRegistration.rank = element.rank;
                        courseRegs.push(element.alternateCourse.courseRegistration);
                    }
                    else if(element.alternateCourse && element.alternateCourse.Id)
                    {
                        element.alternateCourse.Status__c = saveForLater ? 'CIF - Draft' : 'CIF - Submitted';
                        courseRegs.push(classInterestService.createCourseRegistration(element.alternateCourse));
                    }
                }
            }
        }
        let deptPromise;
        if($scope.appItem.form.formData.departments){
            deptPromise = classInterestService.saveDepartmentsChoices($scope.appItem.form.formData.departments.selectedDepartments);
        }
        
        console.log('courseRegs start');
        for(item in courseRegs){
            console.log('item start');
            for(key in item){
                console.log(key + ' => ' + item[key]);
            }
            console.log('item end');

        }
        console.log('courseRegs end');
        if(courseRegs.length){
            var promise = courseRegService.submitCourseRegistrations(courseRegs);
            promise.then(function(result){
                console.log('saved CR records');
                courseRegService.setCourseRegistrations(courseRegs);
                $scope.saveApplicationItem(saveForLater);
            },
            function(result){
                //ERROR_1001
                errorModalService.openErrorModal('An Error has occured saving your class interests', 'There was an error saving your class interests. Please try again. If you continue to have problems, contact IFSA. ERROR_1001');
                $scope.savingForLater = false;
                $scope.saving = false;
            });
        }
        else {
            $scope.saveApplicationItem(saveForLater);
        }
        console.log('submitForm End');
    }
    $scope.saveApplicationItem = function(saveForLater) {
        $scope.appItem.status = saveForLater ? 'Started' : 'Complete';
        
        if(saveForLater)
        {
            $scope.submitApplicationItem(saveForLater);
        }
        else if(!saveForLater)
        {
            // Save PDF
            if($scope.appItem.form.formData.departments && $scope.appItem.form.formData.departments.selectedDepartments && $scope.appItem.form.formData.departments.selectedDepartments.length){
                let deptFormItem = {
                    fieldType: 'Departments',
                    departmentRule: $scope.appItem.form.formData.departments,
                };
                let cifTableIndex = $scope.appItem.form.formData.items.findIndex(i => i.fieldType == 'CIF_Class_Table' && i.label == "CIF Class Table");
                $scope.appItem.form.formData.items.splice(cifTableIndex, 0, deptFormItem);
            }
            var promise = dynamicFormService.submitDynamicForm($scope.appItem.form, $scope.appItem.name);
            promise.then(function(result){
                console.log('saved PDF');
                $scope.submitApplicationItem(saveForLater);
            },
            function(result){
                //ERROR_1004
                errorModalService.openErrorModal('An Error has occured submitting your class interest form', 'There was an error submitting your class interest form. Please try again. If you continue to have problems, contact IFSA. ERROR_1004');
                $scope.savingForLater = false;
                $scope.saving = false;
            });
            
        }
    }
    $scope.submitApplicationItem = function(saveForLater) {
        console.log('submitApplicationItem Start');
        var promise = applicationItemService.submitApplicationItem(angular.toJson($scope.appItem), '', '', '');
        promise.then(function(result){
            console.log('Saved Application Item');
            window.location.assign('#/');
            $scope.savingForLater = false;
            $scope.saving = false;
        },
        function(result){
            if(saveForLater){
                //ERROR_1002
                errorModalService.openErrorModal('An Error has occured saving your class interests', 'There was an error saving your class interests. Please try again. If you continue to have problems, contact IFSA. ERROR_1002');    
            }
            else {
                //ERROR_1005
                errorModalService.openErrorModal('An Error has occured submitting your class interest form', 'There was an error submitting your class interest form. Please try again. If you continue to have problems, contact IFSA. ERROR_1005');
            }
            $scope.savingForLater = false;
            $scope.saving = false;
        });
        console.log('submitApplicationItem End');
    }

    $scope.selectFromRules = function(ruleItem, rule){
        var indexKey;
        for (const key in $scope.courseSelections) {
            if ($scope.courseSelections.hasOwnProperty(key)) {
                const element = $scope.courseSelections[key];
                if(element.Id == null && !element.isAlternate)
                {
                    indexKey = key;
                    break;
                }
            }
        }
        var cs = angular.copy($scope.courseSelections[indexKey]);
        $scope.courseSelections[indexKey] = ruleItem.course;
        $scope.courseSelections[indexKey].rank = cs.rank;

        ruleItem.isSelected = true;
        ruleItem.course.isAlternate = false;
        if(rule.ruleName == 'Must_Select_n_Courses')
        {
            $scope.courseSelections[indexKey].noAlternate = true;
        }
        let selectedItemCount = 0;
        for (let index = 0; index < rule.ruleItems.length; index++) {
            const ri = rule.ruleItems[index];
            if(ruleItem.relId == ri.relId)
            {
                ri.isSelected = ruleItem.isSelected;
            }
            if(ri.isSelected){
                selectedItemCount = ++selectedItemCount;
            }
        }
        if(rule.reqRuleItems == selectedItemCount){
            rule.completed = true;
        }
    }

    $scope.clearCourse = function(course) {
        $scope.isDeleting = true;
        var key
        for (const k in $scope.courseSelections) {
            if ($scope.courseSelections.hasOwnProperty(k)) {
                const c = $scope.courseSelections[k];
                if(c == course){
                    key = k;
                }
            }
        }
        
        if($scope.courseSelections[key].courseRegistration)
        {
            if($scope.courseSelections[key].alternateCourse && $scope.courseSelections[key].alternateCourse.courseRegistration)
            {
                classInterestService.deleteCourseInterest($scope.courseSelections[key].alternateCourse.courseRegistration.courseRegId);
            }
            var promise = classInterestService.deleteCourseInterest($scope.courseSelections[key].courseRegistration.courseRegId);
            promise.then(function(result){
                $scope.finalizeClearCourse(key);
            },function(result){
                // ERROR_1003
                errorModalService.openErrorModal('An Error has occured deleting class interest', 'There was an error deleting class interests "' + $scope.courseSelections[key].Course_Title_2__c + '". Please try again. If you continue to have problems, contact IFSA. ERROR_1003');
            })
        }
        else
        {
            $scope.finalizeClearCourse(key);
        }
    }
    $scope.clearAlternateCourse = function(course) {
        if(course.alternateCourse.courseRegistration)
        {
            $scope.isDeleting = true;
            var promise = classInterestService.deleteCourseInterest(course.alternateCourse.courseRegistration.courseRegId);
            promise.then(function(result){
                course.alternateCourse = { Id: null, isAlternate: true };
                $scope.isDeleting = false;
            },function(result){
                // ERROR_1003
                errorModalService.openErrorModal('An Error has occured deleting class interest', 'There was an error deleting class interests "' + $scope.courseSelections[index].Course_Title_2__c + '". Please try again. If you continue to have problems, contact IFSA. ERROR_1003');
            })
        }
        else
        {
            course.alternateCourse = { Id: null, isAlternate: true };
        }
    }
     
    $scope.finalizeClearCourse = function(index) {
        var isAlternate =  $scope.courseSelections[index].isAlternate ? true : false;
        var courseId = $scope.courseSelections[index].Id;
        var cs = angular.copy($scope.courseSelections[index]);
       
        $scope.courseSelections[index] = {
            Id: null,
            isAlternate: isAlternate,
            rank: cs.rank
        }
        $scope.isDeleting = false;
        var ruleItemIndex;
        for (let index = 0; index < $scope.appItem.form.formData.formRules.length; index++) {
            const rule = $scope.appItem.form.formData.formRules[index];
            if(rule.ruleItems)
            {
                ruleItemIndex = rule.ruleItems.findIndex(ri => ri.course.Id == courseId);
                if(ruleItemIndex > -1)
                {
                    rule.ruleItems[ruleItemIndex].isSelected = false;
                    rule.completed = false;
                    break;
                }
            }
        }
    }

    $scope.reorder = function(item, index, direction) {
        var selections = toArrayFilter($scope.courseSelections);
        switch (direction) {
            case 'up':
                var previous = selections.find(c => c.rank == item.rank - 1);
                previous.rank = item.rank;
                item.rank = item.rank - 1;
                break;
            case 'down':
                var next = selections.find(c => c.rank == item.rank + 1);
                next.rank = item.rank;
                item.rank = item.rank + 1;
                break;
            default:
                break;
        }
    }

    $scope.checkRules = function() {
        if($scope.appItem && $scope.appItem.form && $scope.appItem.form.formData.formRules && $scope.appItem.form.formData.formRules.length){
            for (let index = 0; index < $scope.appItem.form.formData.formRules.length; index++) {
                const rule = $scope.appItem.form.formData.formRules[index];
                console.log('rule.completed => ' + rule.completed);
                if((rule.ruleName == 'Must_Select_Course_X' || rule.ruleName == 'Must_Select_n_Courses') && !rule.completed){
                    console.log('Rule is not complete.')
                    return false;
                }
            }
        }
        if($scope.appItem.form.formData.departments && $scope.appItem.form.formData.departments.linkClassesDept){
            for (let index = 0; index < $scope.appItem.form.formData.departments.selectedDepartments.length; index++) {
                const d = $scope.appItem.form.formData.departments.selectedDepartments[index];
                if($scope.numberOfRemainingCoursesForDept(d) > 0)
                {
                    return false;
                }
            }
            let dept = $scope.appItem.form.formData.departments.selectedDepartments[0];
            let selections = toArrayFilter($scope.courseSelections);
            for (let index = 0; index < selections.length; index++) {
                const course = selections[index];
                if(course.Host_Institution__c == dept.Host_Institution__c && !course.selectedDepartment)
                {
                    return false;                    
                }
            }
        }
        return true;
    }

    $scope.addToSelectedWithDesignation = function(deptId, designation){
        console.log('addToSelectedWithDesignation Start');
        let dept = undefined;
        if(!$scope.clearingDepartments){
            if(deptId){
                dept = $scope.appItem.form.formData.departments.departmentsArray.find(d => d.Id == deptId);
                dept.designation = designation.name;
                dept.selected = true;
                designation.idBackup = JSON.parse(JSON.stringify(designation.selectedOption));
            }
            else{
                dept = $scope.appItem.form.formData.departments.departmentsArray.find(d => d.Id == designation.idBackup);
                dept.idBackup = null;
            }
            if($scope.appItem.form.formData.departments.selectedDepartments.length < $scope.appItem.form.formData.departments.designations){
                $scope.appItem.form.formData.departments.designations[$scope.appItem.form.formData.departments.selectedDepartments.length].selected = true;
            }
            $scope.appItem.form.formData.departments.selectedDepartments = [];
            $scope.appItem.form.formData.departments.designations.forEach(designation =>{
                if(designation.selectedOption){
                    $scope.appItem.form.formData.departments.selectedDepartments.push($scope.appItem.form.formData.departments.departmentsArray.find(d => d.Id == designation.selectedOption));
                }
            });
            let index = 0;
            $scope.appItem.form.formData.departments.departmentsArray.forEach(d =>{
                if($scope.appItem.form.formData.departments.selectedDepartments.findIndex(dept => dept == d) === -1){
                    d.selected = false;
                    if(d.recordId){
                        let deletePromise = classInterestService.deleteDepartmentApplication(d.recordId);
                        deletePromise.then(function(result){
                            // Promise resolved (record deleted)
                            //$scope.appItem.form.formData.departments.selectedDepartments.splice(index, 1);    
                        }, function(error){
                            // Promise rejected (record not deleted, error occured)
                            errorModalService.openErrorModal('An error has occured deleting department', 'There was an error deleting department "' + d.Name + '". Please try again. If you continue to have problems, contact IFSA. ERROR_1007');
                        })
                    }
                    else{
                        d.recordId = designation.daId != null ? designation.daId : null;
                    }
                }
                index = index++;
            });
        }
        console.log('addToSelectedWithDesignation End');

    }
    $scope.addToSelected = function(dept){
        // Add department to selectedDepartments array
        $scope.appItem.form.formData.departments.selectedDepartments.push(dept);
        // Removed department from departmentsArray so it can't be selected again
        let i = $scope.appItem.form.formData.departments.departmentsArray.findIndex(d => d.Id == dept.Id);
        $scope.appItem.form.formData.departments.departmentsArray.splice(i, 1);
    }

    $scope.removeFromSelected = function(index){
        const deptToBeRemoved = $scope.appItem.form.formData.departments.selectedDepartments[index]
         // The CIF form has department designations, add the designation to the selected department
        if($scope.appItem.form.formData.departments.designations && $scope.appItem.form.formData.departments.designations.length)
        {
            let designation = $scope.appItem.form.formData.departments.designations.find(d => d.name = deptToBeRemoved.designation)
            designation.selected = false;
        }
        // Add removed department back to departmentsArray so it can be reused
        $scope.appItem.form.formData.departments.departmentsArray.push(deptToBeRemoved);
        // Call classInterestService.deleteDepartmentApplication to delete Department_Application__c record if it has a record Id
        if(deptToBeRemoved.recordId){
            let deletePromise = classInterestService.deleteDepartmentApplication(deptToBeRemoved.recordId);
            deletePromise.then(function(result){
                // Promise resolved (record deleted)
                $scope.appItem.form.formData.departments.selectedDepartments.splice(index, 1);    
            }, function(error){
                // Promise rejected (record not deleted, error occured)
                errorModalService.openErrorModal('An error has occured deleting department', 'There was an error deleting department "' + deptToBeRemoved.Name + '". Please try again. If you continue to have problems, contact IFSA. ERROR_1008');
            })  
        }
        else{
            // Removed department from selectedDepartments
            $scope.appItem.form.formData.departments.selectedDepartments.splice(index, 1);
        }
    }

    $scope.addOptionalClass = function(){
        console.log('addOptionalClass Start');
        let index = $scope.numberOfCourses();
        let rank = index + 1;
        var ac;
        if($scope.alternateRule && ($scope.alternateRule.altForEach || $scope.alternateRule.reqElements > 0)){
            ac = { Id: null, isAlternate: true };
            $scope.alternateRule.reqElements = !$scope.alternateRule.altForEach ?  --$scope.alternateRule.reqElements : null;
        }
        $scope.courseSelections["Selection" + (index + 1)] = {
            Id: null,
            isAlternate: false,
            courseRegistration: null,
            alternateCourse: ac,
            rank: rank,
            isRemoveable: true
        }
        console.log('addOptionalClass End');
    }
    $scope.removeOptionalClass = function(index){
        delete $scope.courseSelections["Selection" + (index + 1)];
    }

    $scope.departmentSelected = function(course){
        let selections = toArrayFilter($scope.courseSelections);
        let departments = $scope.appItem.form.formData.departments.selectedDepartments
        for (let indexDept = 0; indexDept < departments.length; indexDept++) {
            const d = departments[indexDept];
            d.selectCount = 0;
            for (let index = 0; index < selections.length; index++) {
                const c = selections[index];
                if(c.selectedDepartment == d.Id) {
                    d.selectCount = ++d.selectCount;
                }
            }
        }
    }

    $scope.getDepartmentName = function(deptId){
        if(deptId){
            let deptIndex = $scope.appItem.form.formData.departments.selectedDepartments.findIndex(d => d.Id == deptId);
            if(deptIndex > -1){
                return $scope.appItem.form.formData.departments.selectedDepartments[deptIndex].Name;
            }
        }
        return "Choose a department";
    }

    $scope.clearDepartmentSelections = function(){
        $scope.clearingDepartments = true;
        $scope.appItem.form.formData.departments.designations.forEach(d =>{
            d.selectedOption = null;
        });
        $scope.appItem.form.formData.departments.departmentsArray.forEach(d => {
            d.recordId = null;
        });
        let deptAppIds = [];
        $scope.appItem.form.formData.departments.selectedDepartments.forEach(d =>{
            d.selected = false;
            if(d.recordId){
                deptAppIds.push(d.recordId);
            }
            /* let deletePromise = classInterestService.deleteDepartmentApplication(d.recordId);
            deletePromise.then(function(result){
                // Promise resolved (record deleted)
                $scope.appItem.form.formData.departments.selectedDepartments.splice(index, 1);
                $scope.clearingDepartments = false;
            }, function(error){
                // Promise rejected (record not deleted, error occured)
                errorModalService.openErrorModal('An error has occured deleting department', 'There was an error deleting department "' + deptToBeRemoved.Name + '". Please try again. If you continue to have problems, contact IFSA. ERROR_1009');
                $scope.clearingDepartments = false;
            }) */
        });
        if(deptAppIds.length)
        {
            classInterestService.deleteDepartmentApplications(deptAppIds)
            .then(function(results){
                results.forEach(result => {
                    let index = $scope.appItem.form.formData.departments.selectedDepartments.findIndex(dept => dept.recordId == result);
                    $scope.appItem.form.formData.departments.selectedDepartments.splice(index, 1);
                });
                $scope.clearingDepartments = false;
                $scope.appItem.form.formData.departments.selectedDepartments = [];
            }, function(errors){
                errors.forEach(error =>{
                    let deptToBeRemoved = $scope.appItem.form.formData.departments.selectedDepartments.find(dept => dept.recordId == result);
                    errorModalService.openErrorModal('An error has occured deleting department', 'There was an error deleting department "' + deptToBeRemoved.Name + '". Please try again. If you continue to have problems, contact IFSA. ERROR_1009');
                });
                $scope.clearingDepartments = false;
            });
        }
        else{
            $scope.appItem.form.formData.departments.selectedDepartments = [];
            $scope.clearingDepartments = false;
        }
    }
    $scope.clearingDepartments = false;
});