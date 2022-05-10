/**
 * Chart Project Service
 * @file Chart Project Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('projectService', function($q, courseService, viewModel) {
    var self = this;
    var projects = [];
    var loadProjectsPromise;
    var currentView;
    
    this.getProject = function(projectId)
    {
        var deferred = $q.defer();
        chartRemoteMethods.getCMPDetails(
            projectId,
            function(result) {
                if(result.success){
                    deferred.resolve(result.payload)
                }
                else{
                    deferred.reject(result);
                }
        });
        return deferred.promise;
    }
    this.getProjects = function()
    {
        return projects;
    }

    this.loadProjects = function() 
    {
        projects = [];
        var deferred = $q.defer();
        chartRemoteMethods.getCMPs(
            function(result) {
                if(result && result.success){
                    deferred.resolve(self.convertProjects(result.payload))
                }
                else{
                    deferred.reject(result);
                }
        });
        loadProjectsPromise = deferred.promise;
        return deferred.promise;
    }
    this.loadCourseEquivalents = function()
    {
        var deferred = $q.defer();

        chartRemoteMethods.getAllCourseEquivalents(
            viewModel.getViewModel().courseIds,
            function(result) {
                if(result.success){
                    var coursePromise = courseService.getLoadingPromise();
                    coursePromise.then(function(csResult){
                        // Build CE details from result
                        ceList = result.payload;
                        courseEquivalents = [];
                        for (let index = 0; index < ceList.length; index++) {
                            const element = ceList[index];
                            var course = courseService.getCourse(element.hostInstitutionCourseId);
                            var ce = {
                                recordId: element.recordId,
                                status: element.status,
                                homeInstitutionCourse: {
                                    title: element.homeInstitutionCourseTitle,
                                    courseCode: element.homeInstitutionCourseCode,
                                    recordId: element.homeInstitutionCourseId
                                },
                                hostInstitutionCourse: course != null ? course : {courseTitle: element.hostInstitutionCourseTitle, country: element.hostInstitutionCountry, programs: [{recordName: 'Program Not on Approved List'}], recordId: element.hostInstitutionCourseId},
                                lastApprovedRejectedName: element.lastApprovedRejectedName,
                                lastApprovedRejectedDate: element.lastApprovedRejectedDate
                            }
                            courseEquivalents.push(ce);
                        }
                        deferred.resolve(courseEquivalents);
                    },
                    function(csResult){
                        deferred.reject(csResult);
                    });
                }
                else{
                    deferred.reject(result);
                }
            }
        );
        return deferred.promise;
    }
    this.convertProjects = function(array)
    {
        angular.forEach(array, function(project)
        {
            projects.push(self.convertProject(project));
        });
        return projects;
    }
    this.convertProject = function(p){
        if(p) {
            var project = {
                recordId: p.Id,
                name: p.Title__c,
                academicAdvisorEmail: p.Academic_Advisor_Email__c,
		        additionalInformation: p.Additional_Information__c,
                completedDate: p.Completed_Date__c ? p.Completed_Date__c : null,
                lastViewedDate: p.Last_Viewed_Date__c ? p.Last_Viewed_Date__c : null,
		        contactId: p.Contact__c,
		        degreeReqs: p.Degree_Requirements__c,
		        facultyNames: p.Faculty_Names__c,
		        homeInstitutionAccountId: p.Home_Institution_Account__c ? p.Home_Institution_Account__c : null,
                homeInstitutionName: p.Home_Institution_Account__c ? p.Home_Institution_Account__r.Name : null,
                includeDirectedResearch: p.Include_Directed_Research__c ? p.Include_Directed_Research__c : null,
                includeInternshipOptions: p.Include_Internship_Options__c ? p.Include_Internship_Options__c : null,
		        includeNonApprovedPrograms: p.Include_Non_Approved_Programs__c,
		        major: p.Major__c,
		        regionsOfInterest: p.Regions ? p.Regions__c.split(',') : null,
		        specificCountries: p.Specific_Countries__c,
		        specificPrograms: p.Specific_Programs__c,
		        status: p.Status__c,
		        submittedDate: p.CreatedDate,
		        summaryOfResults: p.Summary_of_Results__c,
		        termsAbroad: p.Terms_Abroad__c,
		        yearInSchool: p.Year_in_School__c,
                yearsAbroad: p.Years_Abroad__c
            }
            switch (p.RecordType.Name) {
                case 'Course Equivalency':
                    project.type = 'CE';
                    break;
                case 'Curriculum Integration':
                    project.type = 'CI';
                    break;
                default:
                    break;
            }
            return project;
        }
    }
    this.getCourseEquivalents = function(project)
    {
        var deferred = $q.defer();
        var vm = viewModel.getViewModel();
        var coursePromise = courseService.getLoadingPromise();
        coursePromise.then(function(result){
            courseEquivalents = [];
            for (let index = 0; index < project.courseEquivalencies.length; index++) {
                const element = project.courseEquivalencies[index];
                var course = courseService.getCourse(element.hostInstitutionCourseId);
                var ce = {
                    recordId: element.recordId,
                    hostInstitutionCourse: course != null ? course : {courseTitle: element.hostInstitutionCourseTitle, country: element.hostInstitutionCountry, programs: [{recordName: 'Program Not on Approved List'}], recordId: element.hostInstitutionCourseId},
                    status: element.status,
                    homeInstitutionCourse: {
                        title: element.homeInstitutionCourseTitle,
                        courseCode: element.homeInstitutionCourseCode,
                        recordId: element.homeInstitutionCourseId
                    }
                }
                courseEquivalents.push(ce);
            }
            deferred.resolve(courseEquivalents);
        },
        function(result)
        {
            deferred.reject(result);
        });
        return deferred.promise;
    }
    this.submitProject = function(project)
    {
        var deferred = $q.defer();
        console.log(project);
        var jsonString = angular.toJson(project);
        console.log(jsonString);
        chartRemoteMethods.saveCMPRequest(
            jsonString,
            function(result) {
                console.log(result);
                if(result.success) {
                    console.log(project);
                    var promise = self.loadProjects();
                    promise.then(function(result)
                    {
                        if(result)
                        {
                            projects = result;
                            deferred.resolve(result);
                        }
                        else
                        {
                            deferred.reject(result);
                        }
                    });
                }
                else {
                    deferred.reject(result);
                }
            }
        )

        return deferred.promise;
    }
    this.getLoadingPromise = function()
    {
        return loadProjectsPromise;
    }
    this.addCourseToCMP = function(courseId, cmpId)
    {
        var deferred = $q.defer();

        chartRemoteMethods.addCourseToCMP(
            courseId,
            cmpId,
            function(result) {
                console.log(result)
                if(result.success)
                {
                    deferred.resolve('Success');
                }
                else
                {
                    deferred.reject(result);
                }
            }
        );

        return deferred.promise;
    }
    this.addCoursesToCMP = function(courses, cmpId)
    {
        var deferred = $q.defer();
        var courseIds = [];

        for (let index = 0; index < courses.length; index++) {
            const course = courses[index];
            courseIds.push(course.recordId);
        }

        chartRemoteMethods.addCoursesToCMP(
            courseIds,
            cmpId,
            function(result) {
                console.log(result);
                if(result.success)
                {
                    deferred.resolve('Success');
                }
                else
                {
                    deferred.reject(result);
                }
            }
        );

        return deferred.promise;
    }

    this.saveCourseEquivalents = function(courses)
    {
        var deferred = $q.defer();
        
        for (let index = 0; index < courses.length; index++) {
            const element = courses[index];
            delete element.hostInstitutionCourse;
            delete element.homeInstitutionCourse;
        }

        chartRemoteMethods.saveCourseEquivalents(
            angular.toJson(courses),
            function(result){
                console.log(result);
                if(result.success)
                {
                    deferred.resolve('Success');
                }
                else
                {
                    deferred.reject(result);
                }
            }
        )
        
        return deferred.promise;
    }

    this.ceSearchToggle = function(ceSearch, userId, userHomeInstitutionId)
    {
        var deferred = $q.defer();
        chartRemoteMethods.updateCESearch(
            ceSearch,
            userId,
            userHomeInstitutionId,
            function(result) {
                if(result.success)
                {
                    deferred.resolve(result.payload);
                }
                else
                {
                    deferred.reject(result);
                }
            }
        )
        return deferred.promise;
    }

    this.getCurrentView = function()
    {
        return currentView;
    }

    this.setCurrentView = function(value)
    {
        currentView = value;
    }
});