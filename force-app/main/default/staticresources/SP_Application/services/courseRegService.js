/**
 * Student Portal Course Registration Service
 * @file Student Portal Course Registration Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('courseRegService', function($q, $timeout, viewModel) {
    var self = this;
    var courseRegistrations = [];
    var applicationId = viewModel.getViewModel().applicationId;
    var requestSyllabi = false;
    var notRegisteredReasons = [];
    var otherClassReasons = [];
    var crfSpanishTitles = false;
    var crfConfigDeferred;
    var crfCutoffDate;

    this.getCourseRegistrations = function(){
        var deferred = $q.defer();
        
        portalOnSiteRemotingMethods.getCourseRegistrations(
            applicationId,
            function(result, event) {
                if(result){
                    courseRegistrations = result;
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }
        });

        return deferred.promise;
    }

    this.submitCourseRegistrations = function(crs) {
        console.log('submitCourseRegistration Start');
        console.log('--- submitCourseRegistrations before angular.toJson ---');
        var courses = angular.toJson((crs))
        var deferred = $q.defer();
        portalOnSiteRemotingMethods.submitCourseRegistration(
            courses, applicationId,
            function(result, event) {
                if(result)
                {
                    deferred.resolve(result);
                }
                else
                {
                    deferred.reject(null);
                }
            }
        );
        console.log('submitCourseRegistration End');
        return deferred.promise;
    }

    this.getLoadedCourseRegistrations = function()
    {
        return courseRegistrations;
    }

    this.setCourseRegistrations = function(courseRegs)
    {
        courseRegistrations = courseRegs
    }

    this.getHostInstitutions = function()
    {
        var deferred = $q.defer();
        portalRemotingMethods.searchHostInstitutions(
            null, 
            viewModel.getViewModel().programId,
            function(result, event)
            {
                if(result) {
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }
            }
        );

        return deferred.promise;
    }
    
    this.submitSyllabus = function(file, courseId)
    {
        var deferred = $q.defer();
        var reader = new FileReader();
        reader.onloadend = function() {
            console.log('file is ' );
            console.dir(file);
            var f = reader.result;
            portalOnSiteRemotingMethods.submitSyllabus(
                courseId, 
                f.split(',')[1],
                file.type,
                file.name,
                function(result, event){
                    if(result)
                    {
                        deferred.resolve(result);
                    }
                    else
                    {
                        deferred.reject(event);
                    }
            });
        }
        reader.readAsDataURL(file);
        return deferred.promise;
    }

    this.getCRFConfiguration = function()
    {
        if(!crfConfigDeferred)
        {
            crfConfigDeferred = $q.defer();

            portalOnSiteRemotingMethods.getCRFConfiguration(
                viewModel.getViewModel().programTermName,
                function(result, event)
                {
                    if(result['Success'])
                    {
                        requestSyllabi = result['Request_Syllabi__c'];
                        notRegisteredReasons = result['Not_Registered_Reason__c'];
                        otherClassReasons = result['Other_Class_Reason__c'];
                        crfSpanishTitles = result['CRF_Require_Spanish_Title__c'];
                        crfCutoffDate = result['CRF_Cutoff_Date__c'];
                        crfEditable = result['CRF_Editable__c'];
                        crfConfigDeferred.resolve(true);
                    }
                    else
                    {
                        crfConfigDeferred.reject(false);
                    }
                }
            );
        }
        return crfConfigDeferred.promise;
    }

    this.getRequestSyllabi = function()
    {
        return requestSyllabi;
    }
    this.getNotRegisteredReasons = function()
    {
        return notRegisteredReasons;
    }
    this.getOtherClassReasons = function()
    {
        return otherClassReasons;
    }
    this.getSpanishTitles = function()
    {
        return crfSpanishTitles;
    }
    this.getCrfCutoffDate = function()
    {
        return crfCutoffDate;
    }
    this.getCrfEditable = function()
    {
        return crfEditable;
    }

    this.searchCourses = function(hostInstitutionId, searchTerm, fieldName)
    {
        console.log('--- courseRegService.searchCourses ---');
        var deferred = $q.defer();

        //console.log('hostInsitutionId => ' + hostInstitutionId);
        //console.log('searchTeam => ' + searchTerm);
        //console.log('fieldName => ' + fieldName);

        portalOnSiteRemotingMethods.searchForCourses(
            hostInstitutionId,
            searchTerm,
            fieldName,
            function(result, event) {
                if(result)
                {
                    deferred.resolve(result);
                }
                else
                {
                    deferred.reject(event);
                }
            }
        );

        return deferred.promise;
    }

    this.getChildCourses = function(courseId)
    {
        var deferred = $q.defer();

        portalOnSiteRemotingMethods.getChildClasses(
            courseId,
            function(result, event) {
                if(result)
                {
                    deferred.resolve(result);
                }
                else
                {
                    deferred.reject(event);
                }
            }
        );

        return deferred.promise;
    }

    this.updateCourseReg = function(ChId)
    {
        console.log('updateCourseReg Start');
        var deferred = $q.defer();
        portalOnSiteRemotingMethods.modifyCourseRegistration(
            ChId,
            function(result, event) {
                if(result)
                {
                    deferred.resolve(result);
                }
                else
                {
                    deferred.reject(event);
                }
            }
        );   
        console.log('updateCourseReg End'); 
        return deferred.promise;
    }

    //Call for creation of Course Registration
    this.createCourseRegistration = function(newCourse, appId)
    {
        console.log('createCourseRegistration Start');

        var deferred = $q.defer();
        console.log('name => ' + newCourse.courseName);
        console.log('code => ' + newCourse.courseCode);
        console.log('credits => ' + newCourse.credits);
        console.log('first => ' + newCourse.instructorFirstName);
        console.log('last => ' + newCourse.instructorLastName);
        console.log('host => ' + newCourse.hostInstitutionId);
        console.log('--- appId => ' + appId + ' ---');
        portalOnSiteRemotingMethods.createCourseRegistration(newCourse.courseName, newCourse.courseCode, newCourse.credits, newCourse.instructorFirstName, newCourse.instructorLastName, newCourse.hostInstitutionId, appId, function(result, event){
            // Added by powerfluence - req dt.02/09/2022 - 001 - starts
            if(result){
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }
            // Added by powerfluence - req dt.02/09/2022 - 001 - starts
             //something
        });
        console.log('createCourseRegistration End');
        return deferred.promise;
    }

});