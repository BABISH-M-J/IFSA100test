/**
 * Chart Course Service
 * @file Chart Course Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('courseService', function($q, $timeout, favoriteService, viewModel, replaceFilter) {
    var self = this;
    var courses = [];
    var offset = 0;
    var batchSize = 1000;
    var currentBatch = 0;
    var numberOfBatches = 0;
    var filterCriteria = null;
    var courseIds = [];
    var loadCoursesDefer = null;
    var currentResultsPage = 0;
    var vm = viewModel.getViewModel();
    var favoriteToggle = false;

    this.convertCourses = function(array)
    {
        results = [];
        angular.forEach(array, function(course)
        {
            results.push(self.convertCourse(course));
        });
        courses = courses.concat(results);
        return results;
    }
    this.convertCourse = function(c){
        if(c)
        {
            var course = {
                recordId: c.Id != null ? c.Id : null,
                recordName: c.Name != null ? c.Name : null,
                approvedForChart: c.Approved_For_CHART__c != null ? c.Approved_For_CHART__c : null,
                butlerDepartmentCodeId: c.Butler_Department_Code__c != null ? c.Butler_Department_Code__c : null,
                butlerDepartmentCode: c.Butler_Department_Code__c != null ? c.Butler_Department_Code__r.Name : null,
                capstoneCourseOrProject: c.Capstone_Course_or_Project__c != null ? c.Capstone_Course_or_Project__c : null,
                city: c.Host_Institution__r.Locality__c != null ? c.Host_Institution__r.Locality__r.Name : null,
                communityBasedLearning: c.Community_Based_Learning__c != null ? c.Community_Based_Learning__c : null,
                contactHours: c.Contact_Hours__c != null ? c.Contact_Hours__c : null,
                country: c.Host_Institution__c != null ? c.Host_Institution__r.Country__r.Name : null,
                courseCode: c.Course_Code__c != null ? c.Course_Code__c : null,
                courseDeliveryMethod: c.Course_Delivery_Method__c != null ? c.Course_Delivery_Method__c : null,
                courseDescription: c.Course_Description__c != null ? c.Course_Description__c : null,
                courseDescriptionShort: c.Course_Description_Short__c != null ? c.Course_Description_Short__c : null,
                courseOutline: c.Course_Outline__c != null ? c.Course_Outline__c : null,
                courseTitle: c.Course_Title_2__c != null ? c.Course_Title_2__c : null,
                createdById: c.CreatedById != null ? c.CreatedById : null,
                createdDate: c.CreatedDate != null ? c.CreatedDate : null,
                credits: c.Credits__c != null ? c.Credits__c : null,
                departmentCode: c.Department_Code__c != null ? c.Department_Code__c : null,
                directedResearch: c.Directed_Research__c != null ? c.Directed_Research__c : null,
                ePortfoilio: c.e_Portfolio__c != null ? c.e_Portfolio__c : null,
                evaluationMethod: c.Evaluation_Method__c != null ? c.Evaluation_Method__c : null,
                expirationReason: c.Expiration_Reason__c != null ? c.Expiration_Reason__c : null,
                externalNotes: c.External_Notes__c != null ? c.External_Notes__c : null,
                fieldStudyVisits: c.Field_Study_Visits__c != null ? c.Field_Study_Visits__c : null,
                hostCredits: c.Host_Credits__c != null ? c.Host_Credits__c : null,
                hostInstitutionId: c.Host_Institution__c != null ? c.Host_Institution__c : null,
                hostInstitutionName: c.Host_Institution__c != null ? c.Host_Institution__r.Name : null,
                internship: c.Internship__c != null ? c.Internship__c : null,
                isExpired: c.Is_Expired__c != null ? c.Is_Expired__c : null,
                isFavorite: false,
                favoriteId: null,
                isIFSAClass: c.Is_IFSA_Class__c != null ? c.Is_IFSA_Class__c : null,
                isTop20: c.Is_Top_20_Most_Popular__c != null ? c.Is_Top_20_Most_Popular__c : null,
                knownPreReqsAndRestrictions: c.Known_Pre_requisites_and_Restrictions__c != null ? c.Known_Pre_requisites_and_Restrictions__c : null,
                labHours: c.Lab_Hours__c != null ? c.Lab_Hours__c : null,
                labComponent: c.Laboratory_Component__c != null ? c.Laboratory_Component__c : null,
                languageOfInstruction: c.Language_of_Instruction__c != null ? c.Language_of_Instruction__c : null,
                languageOfInstructionOther: c.Language_of_Instruction_Other__c != null ? c.Language_of_Instruction_Other__c : null,
                lastModifiedById: c.LastModifiedById != null ? c.LastModifiedById : null,
                lastModifiedDate: c.LastModifiedDate != null ? c.LastModifiedDate : null,
                lastRegisteredDate: c.Last_Registered_Date__c != null ? c.Last_Registered_Date__c : null,
                lastRenewed: c.Last_Renewed__c != null ? c.Last_Renewed__c : null,
                lastRenewedById: c.Last_Renewed_By__c != null ? c.Last_Renewed_By__c : null,
                lastRenewedDate: c.Last_Renewed_Date__c != null ? c.Last_Renewed_Date__c : null,
                learningCommunities: c.Learning_Communities__c != null ? c.Learning_Communities__c : null,
                marketingRegion: c.Host_Institution__r.Country__r.Marketing_Region__c != null ? c.Host_Institution__r.Country__r.Marketing_Region__c : null,
                ownerId: c.OwnerId != null ? c.OwnerId : null,
                popularClass: c.Popular_Class__c != null ? c.Popular_Class__c : null,
                professionalDevelopmentProject: c.Professional_Development_Project__c != null ? c.Professional_Development_Project__c : null,
                resourcesReadings: c.Resources_Readings__c != null ? c.Resources_Readings__c : null,
                serviceLearning: c.Service_Learning__c != null ? c.Service_Learning__c : null,
                specialPermissionRequired: c.Special_Permission_Required__c != null ? c.Special_Permission_Required__c : null,
                studentLearningObjectives: c.Student_Learning_Objectives__c != null ? c.Student_Learning_Objectives__c : null,
                studioArt: c.Studio_Art__c != null ? c.Studio_Art__c : null,
                syllabusLink: c.Syllabus_Link__c != null ? c.Syllabus_Link__c : null,
                syllabusType: c.Syllabus_Type__c != null ? c.Syllabus_Type__c : null,
                teachingPracticum: c.Teaching_Practicum__c != null ? c.Teaching_Practicum__c : null,
                untranslatedCourseTitle: c.Untranslated_Course_Title__c != null ? c.Untranslated_Course_Title__c : null,
                usCredits: c.US_Credits__c != null ? c.US_Credits__c : null,
                usSemesterCreditHours: c.US_Semester_Credit_Hours__c != null ? c.US_Semester_Credit_Hours__c : null,
                usTerms: c.US_Terms__c != null ? c.US_Terms__c : null,
                volunteering: c.Volunteering__c != null ? c.Volunteering__c : null,
                writingIntensive: c.Writing_Intensive__c != null ? c.Writing_Intensive__c : null,
                yearInForeignDegreePlan: c.Year_in_Degree_Plan__c != null ? c.Year_in_Degree_Plan__c : null,
                yearInForeignDegreePlanOther: c.Year_in_Degree_Plan_Other__c != null ? c.Year_in_Degree_Plan_Other__c : null,
                tags: [],
                programs: [],
                courseMatches: []
            }
            var programNames = [];
            if(c.Program_Courses__r && c.Program_Courses__r.length)
            {
                angular.forEach(c.Program_Courses__r, function(pc)
                {
                    course.programs.push({
                        recordId: pc.Program_Option__c != null ? pc.Program_Option__c : pc.Program__c,
                        recordName: pc.Program_Option__c != null ? pc.Program__r.Name + ' - ' + pc.Program_Option__r.Name : pc.Program__r.Name,
                        programName: pc.Program__r.Name,
                        optionName: pc.Program_Option__c != null ? pc.Program_Option__r.Name : null,
                        academicURLSemester: pc.Program_Academic_URL_Semester__c,
                        academicURLSummer: pc.Program_Academic_URL_Summer__c,
                        selectedInSearch: true
                    });
                    if(programNames.indexOf(pc.Program__r.Name) === -1)
                    {
                        programNames.push(pc.Program__r.Name);
                    }
                });
            }
            if(c.Tags__r && c.Tags__r.length)
            {
                angular.forEach(c.Tags__r, function(tag)
                {
                    course.tags.push({
                        recordId: tag.Id,
                        recordName: tag.Name,
                        areaOfStudy: tag.Area_of_Study__c,
                        courseId: tag.Course__c,
                        department: tag.Department__c
                    });
                });
            }

            if(c.Course_Equivalencies__r && c.Course_Equivalencies__r.length)
            {
                course.courseMatches.push(c.Course_Equivalencies__r[0]);
            }
            course.courseLocations = c.Course_Locations__r;
        }
        else {
            course = c;
        }
        return course;
    }
    this.getCourse = function(courseId)
    {
        var course = courses.find(c => c.recordId == courseId);
        if(course){
            console.log('Course ID: ' + course.recordId);
            return course;
        }
        else {
            var promise = self.loadCourseDetails(courseId);
            promise.then(function(result){
                return result;
            }, function(result){
                console.log('Could not load course');
                return {courseTitle: 'Course on unapproved program'};
            });
        }
    }
    this.getCourses = function()
    {
        // iterate over courses to update favorites
        var favs = favoriteService.getFavorites();
        if(favs && favs.length)
        {
            angular.forEach(courses, function(course)
            {
                var fav = favs.find(f => f.Course__c == course.recordId);
                if(fav){
                    course.isFavorite = true;
                    course.favoriteId = fav.Id;
                } else {
                    course.isFavorite = false;
                    course.favoriteId = null;
                }
            });
        } else {
            angular.forEach(courses, function(course)
            {
                course.isFavorite = false;
                course.favoriteId = null;
            });
        }
        
        // return courses
        return courses;
    }
    this.hasCourses = function()
    {
        return courses.length > 0;
    }
    this.getCurrentBatch = function()
    {
        return currentBatch;
    }
    this.getTotalBatches = function()
    {
        return numberOfBatches;
    }
    this.getFilterCriteria = function()
    {
        return filterCriteria;
    }
    this.getLoadingStatus = function()
    {
        if(filterCriteria){
            return 'Completed';
        }
        if(courseIds.length){
            return 'In Progress';
        }
        return 'Not Started';
    }
    this.loadCourses = function(cIds)
    {
        loadCoursesDefer = $q.defer();
        loadCoursesDefer.promise.then(null,null,angular.noop);
        courseIds = cIds;
        courses = [];
        currentBatch = 0;
        offset = 0;
        filterCriteria = null;
        numberOfBatches = Math.ceil(courseIds.length / batchSize)

        let getCoursesInterval = window.setInterval(function(){
            new function(){
                var ids = courseIds.slice(offset, offset + batchSize)
                offset = offset + batchSize;
                if(offset > courseIds.length)
                {
                    clearInterval(getCoursesInterval);
                }
                if(ids){
                    chartRemoteMethods.getCoursesExtended(
                        ids,
                        vm.homeInstitutionAccountId,
                        vm.cmpId != null ? vm.cmpId : null,
                        function(result) {
                            if(result && result.success){
                                self.searchComplete(result.payload);
                            }
                            else{
                                loadCoursesDefer.reject(result);
                            }
                        }
                    );
                }
            }
        }, 100);
        return loadCoursesDefer.promise;
    }

    this.searchComplete = function(result)
    {
        currentBatch = currentBatch + 1;
        progressValue = (currentBatch / numberOfBatches) * 100;
        self.convertCourses(result);
        $timeout(function() {
            loadCoursesDefer.notify(self.getLoadingStatus())
        });
        if(courses.length == courseIds.length)
        {
            $timeout(function() {
                self.populateFilters();
                loadCoursesDefer.resolve(self.getLoadingStatus());
            }, 1000);
        }
        else
        {
            /*
            offset = offset + batchSize;
            var ids = courseIds.slice(offset, offset + batchSize)
            chartRemoteMethods.getCoursesExtended(
                ids,
                vm.homeInstitutionAccountId,
                vm.cmpId != null ? vm.cmpId : null,
                function(result) {
                    if(result)
                    {
                        self.searchComplete(result.payload);
                    }
                    else
                    {
                        loadCoursesDefer.reject(result);
                    }
                }
            );
            */
        }
    }
    this.populateFilters = function()
    {
        // Create the filter criteria object
        var fc = {
            marketingRegions: {},
            countries: {},
            programs: {},
            terms: {},
            learningComponents: {},
            areasOfStudy: {},
            departments: {},
            courseMatches: {},
            popularClasses: {},
            languagesOfInstruction: {},
            searchTerm: null,
            favorites: false,
            sortType: 'sortByIFSAExclusive',
            reverseSort: false
        }
        
        var tempMarketingRegions = [];
        var tempCountries = [];
        var tempPrograms = [];
        var tempTerms = [];
        var tempLearningComponents = [];
        var tempAreasOfStudy = [];
        var tempDepartments = [];
        var tempCourseMatches = [];
        var tempPopularClasses = [];
        var tempLanguagesOfInstruction = [];

        // Create Learning Component key/value pairs
        var learningComponents = {
                'capstoneCourseOrProject': 'Capstone Course Or Project',
                'communityBasedLearning': 'Community Based Learning',
                'directedResearch': 'Directed Research',
                'ePortfoilio': 'E-Portfolio',
                'fieldStudyVisits': 'Field Study Visits',
                'internship': 'Internship',
                'labComponent': 'Lab Component',
                'learningCommunities': 'Learning Communities',
                'professionalDevelopmentProject': 'Professional Development Project',
                'serviceLearning': 'Service Learning',
                'studioArt': 'Studio Art',
                'teachingPracticum': 'Teaching Practicum',
                'volunteering': 'Volunteering',
                'writingIntensive': 'Writing Intensive'
        };
        // Create none option for learning components, areas of study and departments
        fc.learningComponents['(none)'] = {name: '(none)', selectedInSearch: false, courseCount: 0};
        fc.areasOfStudy['(none)'] = {name:'(none)', selectedInSearch: false, courseCount: 0};
        fc.departments['(none)'] = {name: '(none)', selectedInSearch: false, courseCount: 0};
        fc.courseMatches['(none)'] = {name: '(none)', selectedInSearch: false, courseCount: 0};
        // iterate over course results
        angular.forEach(courses, function(course)
        {
            //console.log('Language => ' + course.languageOfInstruction);

            // Get Languages of Instruction
            if(tempLanguagesOfInstruction.indexOf(course.languageOfInstruction) === -1)
            {
                tempLanguagesOfInstruction.push(course.languageOfInstruction);
            }
            
            // Get Marketing Regions
            if(tempMarketingRegions.indexOf(course.marketingRegion) === -1)
            {
                tempMarketingRegions.push(course.marketingRegion);
            }
            // Get Countries
            if(tempCountries.indexOf(course.country) === -1)
            {
                tempCountries.push(course.country);
            }
            course.programNames = [];
            course.programOptions = [];
            if(course.popularClass || course.isTop20)
            {
                tempPopularClasses.push(course);
            }
            // Get Programs
            angular.forEach(course.programs, function(program)
            {
                course.programNames.push(program.programName);
                if(program.optionName)
                {
                    course.programOptions.push(program.optionName);
                }
                var index = tempPrograms.findIndex(p => p.programName == program.programName);
                if(index === -1)
                {
                    tempPrograms.push({
                        programName: program.programName,
                        options: program.optionName != null ? [program.optionName] : []
                    });
                }
                else {
                    var oIndex = tempPrograms[index].options.findIndex(o => o == program.optionName);
                    if(oIndex === -1)
                    {
                        tempPrograms[index].options.push(program.optionName);
                    }
                }
            });
            // Get Terms
            course.usTermsSplit = course.usTerms != null ? course.usTerms.split(";") : course.usTerms;
            angular.forEach(course.usTermsSplit, function(term)
            {
                if(tempTerms.indexOf(term) === -1)
                {
                    tempTerms.push(term);
                }
            });
            // Get Learning Components
            course.learningComponents = [];
            angular.forEach(learningComponents, function(value, key)
            {
                if(course.hasOwnProperty(key) && course[key] == true)
                {
                    course.learningComponents.push(value);
                    if(tempLearningComponents.indexOf(value) === -1)
                    {
                        tempLearningComponents.push(value);
                    }
                }
            });
            if(!course.learningComponents.length)
            {
                course.learningComponents.push('(none)');
            }
            // Get Departments and Areas of Study
            course.areasOfStudy = [];
            course.departments = [];
            angular.forEach(course.tags, function(tag)
            {
                if(tag.areaOfStudy)
                {
                    course.areasOfStudy.push(tag.areaOfStudy)
                    if(tempAreasOfStudy.indexOf(tag.areaOfStudy) === -1)
                    {
                        tempAreasOfStudy.push(tag.areaOfStudy);
                    }
                }
                if(tag.department)
                {
                    course.departments.push(tag.department)
                    if(tempDepartments.indexOf(tag.department) === -1)
                    {
                        tempDepartments.push(tag.department);
                    }
                }
                
            });
            if(!course.areasOfStudy.length)
            {
                course.areasOfStudy.push('(none)');
            }
            if(!course.departments.length)
            {
                course.departments.push('(none)');
            }
            
            
            // Get Course Matches
            angular.forEach(course.courseMatches, function(match)
            {
                if(!tempCourseMatches.length || tempCourseMatches.indexOf(match.Status__c) === -1)
                {
                    tempCourseMatches.push(match.Status__c);
                }
            });
            // Merge favorite data with courseResults data
            var tempFav = favoriteService.checkFavorite(course.recordId);
            if(tempFav){
                course.isFavorite = true;
                course.favoriteId = tempFav.Id;
            }
        });

        // Sort temporary filter lists
        tempMarketingRegions = tempMarketingRegions.sort();
        tempCountries = tempCountries.sort();
        tempPrograms = tempPrograms.sort(function(x, y){
            return x.programName > y.programName ? 1 : -1;
        });
        tempTerms = tempTerms.sort();
        tempLearningComponents = tempLearningComponents.sort();
        tempAreasOfStudy = tempAreasOfStudy.sort();
        tempDepartments = tempDepartments.sort();
        tempCourseMatches = tempCourseMatches.sort();
        tempLanguagesOfInstruction = tempLanguagesOfInstruction.sort();

        for(i=0;i<tempMarketingRegions.length;i++)
        {
            fc.marketingRegions[tempMarketingRegions[i]] = {name: tempMarketingRegions[i], selectedInSearch: false, courseCount: 0};
        }
        for(i=0;i<tempCountries.length;i++)
        {
            fc.countries[tempCountries[i]] = {name: tempCountries[i], selectedInSearch: false, courseCount: 0};
        }
        for(i=0;i<tempPrograms.length;i++){
            const program = tempPrograms[i];
            fc.programs[program.programName] = {name: program.programName, selectedInSearch: false, courseCount: 0, options: {}};
            if(program.options.length)
            {
                for (let index = 0; index < program.options.length; index++) {
                    const option = program.options[index];
                    if(option != null)
                    {
                        fc.programs[program.programName].options[option] = {name: option, selectedInSearch: false, courseCount: 0};   
                    }
                }
            }
            if(fc.programs[program.programName].options == {})
            {
                fc.programs[program.programName].options = null;
            }
        }
        for(i=0;i<tempTerms.length;i++)
        {
            fc.terms[tempTerms[i]] = {name: tempTerms[i], selectedInSearch: false, courseCount: 0};
        }
        for(i=0;i<tempLearningComponents.length;i++)
        {
            fc.learningComponents[tempLearningComponents[i]] = {name: tempLearningComponents[i], selectedInSearch: false, courseCount: 0};
        }
        for(i=0;i<tempAreasOfStudy.length;i++)
        {
            fc.areasOfStudy[tempAreasOfStudy[i]] = {name: tempAreasOfStudy[i], selectedInSearch: false, courseCount: 0};
        }
        for(i=0;i<tempDepartments.length;i++)
        {
            fc.departments[tempDepartments[i]] = {name: tempDepartments[i], selectedInSearch: false, courseCount: 0};
        }
        for(i=0;i<tempLanguagesOfInstruction.length;i++)
        {
            fc.languagesOfInstruction[tempLanguagesOfInstruction[i]] = {name: tempLanguagesOfInstruction[i], selectedInSearch: false, courseCount: 0};
        }
        fc.popularClasses['Popular_Classes'] = {name: 'Popular Classes Only', selectedInSearch: false, courseCount: tempPopularClasses.length};
        for(i=0;i<tempCourseMatches.length;i++)
        {
            fc.courseMatches[tempCourseMatches[i]] = {name: tempCourseMatches[i], selectedInSearch: false, courseCount: 0};
            
            if(fc.courseMatches[tempCourseMatches[i]].name == 'Match')
            {
                fc.courseMatches[tempCourseMatches[i]].description = 'For planning purposes, this class has been linked to a specific class at your home institution by an advisor from your institution. Open the record and scroll to the Class Equivalencies section for details. It is critical you review the class match with your home institution advisor directly.';
            }
            if(fc.courseMatches[tempCourseMatches[i]].name == 'Potential Match')
            {
                fc.courseMatches[tempCourseMatches[i]].description = 'For planning purposes, this class has been linked to a specific class at your home institution. Open the record and scroll to the Class Equivalencies section for details. Always review potential matches with your home institution advisor directly.';
            }
        }

        filterCriteria = fc;
        //console.log('fc.LOI.length => ' + filterCriteria.languagesOfInstruction.length());
        //console.log('fc.departments.length => ' + filterCriteria.departments.length());
    }
    this.loadCourseDetails = function(courseId)
    {
        var deferred = $q.defer();
        var vm = viewModel.getViewModel();
        var accountId = null;
        if(vm.cmpId != null)
        {
            accountId = vm.homeInstitutionAccountId;
        }
        chartRemoteMethods.getCourse(
            courseId,
            accountId,
            function(result) {
                if(result.success){
                    deferred.resolve(result.payload);
                }
                else{
                    deferred.reject(result);
                }
            }
        );
        return deferred.promise;
    }
    this.getLoadingPromise = function()
    {
        return loadCoursesDefer.promise;
    }
    this.getCurrentResultsPage = function()
    {
        return currentResultsPage;
    }
    this.setCurrentResultsPage = function(currentPage)
    {
        currentResultsPage = currentPage;
    }
    this.createNewHomeInstitutionCourseEquivalency = function(newHomeCourse, hostCourseId)
    {
        var deferred = $q.defer();

        newHomeCourseJSON = angular.toJson(newHomeCourse);

        chartRemoteMethods.createNewHomeInstitutionCourseEquivalency(
            newHomeCourseJSON,
            hostCourseId,
            viewModel.getViewModel().cmpId,
            function(result) {
                if(result.success) {
                    // Refreshes list
                    self.loadCourses(viewModel.getViewModel().courseIds)
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(result);
                }
            }
        )
        return deferred.promise;
    }

    this.getFavoriteToggle = function()
    {
        return favoriteToggle;
    }

    this.setFavoriteToggle = function(value)
    {
        favoriteToggle = value;
    }

    this.getCourseCity = function(course)
    {
        if(course.courseLocations && course.courseLocations.length)
        {
            // Remove duplicates
            let cities = course.courseLocations.reduce(function (accumulator, currentValue) {
                try{
                    if (accumulator.indexOf(currentValue.Location_of_Instruction__r.City__r.Name) === -1) {
                        accumulator.push(currentValue.Location_of_Instruction__r.City__r.Name);
                    } 
                }
                catch (e){
                    if (accumulator.indexOf(course.city) === -1) {
                        accumulator.push(course.city);
                    } 
                }
                return accumulator;
            }, []);
            let citiesString = cities.reduce(function (accumulator, currentValue) {
                return accumulator + currentValue + ', ';
            }, []);
            return replaceFilter(citiesString.slice(0, citiesString.lastIndexOf(', ')), '&#39;', '\'');
        }
        else
        {
            return course.city;
        }
    }
    this.getCourseEquivalents = function(courseId)
    {
        let deferred = $q.defer();
        let accountId = viewModel.getViewModel().homeInstitutionAccountId;

        chartRemoteMethods.getCourseEquivalents(courseId, accountId,
            function(result, event){
                if(result.success) {
                    deferred.resolve(result.payload);
                }
                else {
                    deferred.reject(result);
                }
        });

        return deferred.promise;
    }
});