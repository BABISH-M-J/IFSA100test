/**
 * Student Portal Class Interest Service
 * @file Student Portal Class Interest Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('classInterestService', function($q, $timeout, $modal, viewModel, courseRegService, errorModalService, urlService, applicationService) {
    var self = this;
    var favorites = [];

    // Get favorites from the database
    this.loadFavorites = function()
    {
        favorites = [];
        var deferred = $q.defer();
        portalRemotingMethods.getFavorites(
            viewModel.getViewModel().applicationId,
            function(result) {
                if(result.success){
                    favorites = favorites.concat(result.payload);
                    deferred.resolve(result.payload);
                }
                else{
                    deferred.reject(result);
                }
        });
        return deferred.promise;
    }

    this.getCourses = function(courseIds)
    {
        var deferred = $q.defer();
        if(courseIds.length){
            portalRemotingMethods.getCourses(
                courseIds,
                function(result) {
                    if(result.success){
                        deferred.resolve(result.payload);
                    }
                    else{
                        deferred.reject(result);
                    }
            });
        }
        else{
            new function(){
                deferred.resolve([]);
            }
        }
        return deferred.promise;
    }

    this.getCourseRegistrations = function()
    {
        return courseRegService.getCourseRegistrations();
    }

    this.getLoadedCourseRegistrations = function()
    {
        return courseRegService.getLoadedCourseRegistrations();
    }

    this.searchClasses = function(searchTerm)
    {
        var deferred = $q.defer();
        portalOnSiteRemotingMethods.searchForCoursesByProgram(
            viewModel.getViewModel().applicationId,
            searchTerm,
            function(result) {
                if(result){
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(result);
                }
        });
        return deferred.promise;
    }
    this.createCourseRegistration = function(course)
    {
        var courseReg = {       
            courseRegId: null,
            courseName: course.Name,
            courseTitle: course.Course_Title_2__c,
            encodedCourseTitle: course.Course_Title_2__c,
            encodedCourseName: course.Name,
            courseCode	: course.Course_Code__c,
            departmentCode: course.Butler_Department_Code__c,
            departmentCodeString: null,
            instructorName: null,
            instructorFirstName: null,
            instructorLastName: null,
            courseId: course.Id,
            credits: course.Host_Credits__c,
            usCredits: course.US_Semester_Credit_Hours__c,
            isApproved: null,
            isDropped: null,
            hostInstitutionId: course.Host_Institution__c,
            hostInstitutionName: null,
            originalHostInstitutionName: null,
            courseGrade: null,
            applicationID: viewModel.getViewModel().applicationId,
            courseTerm: null,
            courseStatus: course.Status__c,
            qualityPoints: null,
            alternateFor: course.alternateFor,
            rank: course.rank,
            fulfillsDegreeRequirement: course.fulfillsDegreeRequirement ? course.fulfillsDegreeRequirement : false,
            required: course.isRequired ? true : false,
            selectedDepartment: course.selectedDepartment
        }
        return courseReg;
    }
    this.createCourseRegistrations = function(courses)
    {
        var courseRegs = [];
        for (let index = 0; index < courses.length; index++) {
            const c = courses[index];
            courseRegs.push(self.createCourseRegistration(c));
        }
        return courseRegs;
    }

    this.deleteCourseInterest = function(courseRegId)
    {
        var deferred = $q.defer();

        portalRemotingMethods.deleteCourseInterest(
            courseRegId, 
            function(result, event){
                if(result) {
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }
            })

        return deferred.promise;
    }

    this.submitNewCourse = function(newCourse)
    {
        var deferred = $q.defer();
        newCourse.applicationId = viewModel.getViewModel().applicationId;
        // First look to see if a course exists for the program
        portalOnSiteRemotingMethods.checkForExistingCourse(
            angular.toJson(newCourse),
            function(result, event){
                console.log(angular.toJson(newCourse));
                console.log(result);
                if(result.Status == 'Found Courses' && Array.isArray(result.Payload) && result.Payload.length)
                {
                    // Display courses to student to allow them to pick one from the list, if the list does not contain
                    // a match, the student can submit the course they entered.
                    // Open a new modal
                    var modalInstance = $modal.open({
                        animation: true,
                        size: 'lg',
                        backdrop: 'static',
                        controller: 'similarClassModalController',
                        templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/similarClassModal.html',
                        resolve: {
                            data: {
                                title: 'Classes similar to ' + newCourse.courseTitle + ' at ' + newCourse.hostInstitutionName,
                                courses: result.Payload,
                                newCourse: newCourse
                            }
                        }
                    });
                    // Resolve promise from modal
                    modalInstance.result.then(function (course) {
                        // If the student selected a course, pass it back to classSearchModalController
                        deferred.resolve(course);
                    }, function(result) {
                        // If the student does not select a course, submit the course data to insert new course
                        if(result == 'Use Course')
                        {
                            portalOnSiteRemotingMethods.submitCourse(
                                angular.toJson(newCourse),
                                function(result, event){
                                    deferred.resolve(result.Payload);
                            });
                        }
                        // The student canceled the modal
                        else
                        {
                            // Nothing needs to happen as of now.
                        }
                    });
                }
                else if(result.Status == 'Success' && !Array.isArray(result.Payload))
                {
                    deferred.resolve(result.Payload);
                }
                else
                {
                    // Some error happened
                    errorModalService.openErrorModal('An error occured submitting data', 'An error occured submitting data, Please try again later. If you contiue to receive this error please contact IFSA.');
                    deferred.reject(result);
                }
        });
        return deferred.promise;
    }

    this.getDepartments = function(){
        var deferred = $q.defer();
        let vm = viewModel.getViewModel();

        portalRemotingMethods.getDepartments(
            vm.programTermId,
            vm.programOptionId != null ? vm.programOptionId : null,
            function(result, event) {
                if(event.status){
                    let depts = [];
                    for (let index = 0; index < result.length; index++) {
                        const d = result[index];
                        let label = d.Name;
                        if(d.Program_Option__c != null && d.Program_Option__c != viewModel.getViewModel().programOptionId){
                            label = label + ' ' + d.Program_Option__r.Name;
                        }
                        label = label.replace(/&amp;/g, '&');
                        label = label.replace(/&39#;/g, '\'');
                        label = label.replace(/&quot;/g, '\"');
                        depts.push({
                            Host_Institution__c: d.Host_Institution__c,
                            Id: d.Id,
                            Name: d.Name,
                            Program__c: d.Program__c,
                            deptLabel: label
                        })
                    }
                    deferred.resolve(depts);
                }
                else{
                    deferred.reject(result);
                }
        });
        return deferred.promise;
    }

    this.getDepartmentApplications = function() {
        var deferred = $q.defer();
        let vm = viewModel.getViewModel();

        portalRemotingMethods.getDepartmentApplications(
            vm.applicationId,
            function(result, event) {
                if(event.status){
                    let deptSelections = [];
                    for (let index = 0; index < result.length; index++) {
                        const s = result[index];
                        deptSelections.push({
                            recordId: s.Id,
                            designation: s.Designation__c,
                            hostInstDept: s.Host_Institution_Departement__c,
                            hostInstDeptName: s.Host_Institution_Departement__r.Name,
                            hostInstitutionId: s.Host_Institution_Departement__r.Host_Institution__c,
                            programId: s.Host_Institution_Departement__r.Program__c,
                            programOptionId: s.Host_Institution_Departement__r.Program_Option__c,
                            programOptionName: s.Host_Institution_Departement__r.Program_Option__r ? s.Host_Institution_Departement__r.Program_Option__r.Name : null,
                            get Name(){
                                return this.hostInstDeptName;
                            },
                            get Program_Option__c(){
                                return this.programOptionId;
                            },
                            Program_Option__r: {
                                Name: s.Host_Institution_Departement__r.Program_Option__r ? s.Host_Institution_Departement__r.Program_Option__r.Name : null
                            },
                            get Id(){
                                return this.hostInstDept;
                            },
                            get Host_Institution__c(){
                                return this.hostInstitutionId;
                            }
                        });
                    }
                    deferred.resolve(deptSelections);
                }
                else{
                    deferred.reject(result);
                }
        });
        return deferred.promise;
    }

    this.deleteDepartmentApplication = function(deptAppId) {
        var deferred = $q.defer();
        let vm = viewModel.getViewModel();

        portalRemotingMethods.deleteDepartmentApplication(
            deptAppId,
            function(result, event) {
                if(event.status){
                    deferred.resolve(deptAppId);
                }
                else{
                    deferred.reject(deptAppId);
                }
        });
        return deferred.promise;
    }

    this.deleteDepartmentApplications = function(deptAppIds) {
        var promises = [];
        for(i = 0; i < deptAppIds.length; i++)
        {
            const deptAppId = deptAppIds[i];

            promises.push(self.deleteDepartmentApplication(deptAppId));
        }

        return $q.all(promises);
    }

    this.saveDepartmentsChoices = function(deptSelections) {
        var deferred = $q.defer();
        let vm = viewModel.getViewModel();
        let convertedArray = [];
        for (let index = 0; index < deptSelections.length; index++) {
            const dept = deptSelections[index];
            converted = {
                Host_Institution_Departement__c: dept.Id,
                Application__c: vm.applicationId,
                Designation__c: dept.designation
            };
            if(dept.recordId){
                converted.Id = dept.recordId;
            }
            convertedArray.push(converted);
        }
        let jsonData = JSON.stringify(convertedArray);

        portalRemotingMethods.saveDepartmentApplications(
            jsonData,
            function(result, event) {
                if(event.status){
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(result);
                }
        });
        return deferred.promise;
    }
});