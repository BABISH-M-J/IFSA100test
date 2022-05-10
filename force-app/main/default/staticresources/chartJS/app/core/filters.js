/**
 * Chart Search Page AngularJS Filters
 * @file Chart Search Page AngularJS Filters
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.filters', []);
angular.module('app.filters')
// Replace filter - replaces an instance of a string within a string with another string
.filter('replace', [function () {

    return function (input, from, to) {
    
    if(input === undefined || input === null) {
        return;
    }

    var regex = new RegExp(from, 'g');
    return input.replace(regex, to);
    
    };
}])
// Fixes escaped HTML tags
.filter('fixHTMLTags', function() {
    return function(input) {
        if(input){
            input = input.replace(/&lt;/g, '<');
            input = input.replace(/&gt;/g, '>');
            input = input.replace(/&quot;/g, '"');
        }
        return input;
    }
})
// Removes "<p>" and "</p>" tags
.filter('stripPTags', function(){
    return function(input) {
        if(input){
            var startTag = new RegExp('<p>', 'g');
            var endTag = new RegExp('</p>', 'g');
            input = input.replace(startTag, '');
            input = input.replace(endTag, '');
        }
        return input;
    }
})

// Start From Filter - used with pagination
.filter('startFrom', function() {
    return function(input, start) {
        if(input){
            return input.slice(start);
        }
}})

// Unique items only
.filter('unique', function() {
    // we will return a function which will take in a collection
    // and a keyname
    return function(collection, keyname) {
        // we define our output and keys array;
        var output = [], 
            keys = [];
        
        // we utilize angular's foreach function
        // this takes in our original collection and an iterator function
        angular.forEach(collection, function(item) {
            // we check to see whether our object exists
            var key = item[keyname];
            // if it's not already part of our keys array
            if(keys.indexOf(key) === -1) {
                // add it to our keys array
                keys.push(key); 
                // push this item to our final output array
                output.push(item);
            }
        });
        // return our array which should be devoid of
        // any duplicates
        return output;
    };
})
.filter('limitHtml', function() {
    return function(text, limit) {

        var changedString = String(text).replace(/<[^>]+>/gm, '');
        var length = changedString.length;

        return changedString.length > limit ? changedString.substr(0, limit - 1) : changedString; 
    }
})

// Course Search and Filter filter - Filters course using filter criteria and possibly a search term
.filter('courseSearchAndFilter', function() {
    return function(items, filterCriteria){
        // Filter by region
        var selected = {
            regions: 0,
            countries: 0,
            programs: 0,
            options: 0,
            terms: 0,
            learningComponents: 0,
            departments: 0,
            languagesOfInstruction: 0,
            areasOfStudy: 0,
            popularClasses: 0,
            courseMatches: 0
        };
        angular.forEach(filterCriteria.marketingRegions, function(value, key)
        {
            value.courseCount = 0;
            selected.regions = value.selectedInSearch ? selected.regions + 1 : selected.regions;
        });
        angular.forEach(filterCriteria.countries, function(value, key)
        {
            value.courseCount = 0;
            selected.countries = value.selectedInSearch ? selected.countries + 1 : selected.countries;
        });
        angular.forEach(filterCriteria.programs, function(value, key)
        {
            value.courseCount = 0;
            selected.programs = value.selectedInSearch ? selected.programs + 1 : selected.programs;
            for (const option in value.options) {
                if (value.options.hasOwnProperty(option)) {
                    const opt = value.options[option];
                    opt.courseCount = 0;
                    selected.options = opt.selectedInSearch ? selected.options + 1: selected.options;
                }
            }
        });
        angular.forEach(filterCriteria.terms, function(value, key)
        {
            value.courseCount = 0;
            selected.terms = value.selectedInSearch ? selected.terms + 1 : selected.terms;
        });
        angular.forEach(filterCriteria.learningComponents, function(value, key)
        {
            value.courseCount = 0;
            selected.learningComponents = value.selectedInSearch ? selected.learningComponents + 1 : selected.learningComponents;
        });
        angular.forEach(filterCriteria.departments, function(value, key)
        {
            value.courseCount = 0;
            selected.departments = value.selectedInSearch ? selected.departments + 1 : selected.departments;
        });

        // Languages
        angular.forEach(filterCriteria.languagesOfInstruction, function(value, key)
        {
            value.courseCount = 0;
            selected.languagesOfInstruction = value.selectedInSearch ? selected.languagesOfInstruction + 1 : selected.languagesOfInstruction;
        });

        angular.forEach(filterCriteria.areasOfStudy, function(value, key)
        {
            value.courseCount = 0;
            selected.areasOfStudy = value.selectedInSearch ? selected.areasOfStudy + 1 : selected.areasOfStudy;
        });
        angular.forEach(filterCriteria.popularClasses, function(value, key){
            value.courseCount = 0;
            selected.popularClasses = value.selectedInSearch ? selected.popularClasses + 1 : selected.popularClasses;
        });
        angular.forEach(filterCriteria.courseMatches, function(value, key)
        {
            value.courseCount = 0;
            selected.courseMatches = value.selectedInSearch ? selected.courseMatches + 1 : selected.courseMatches;
        });
        items = items.filter(function(element, index, array){
            if(selected.regions > 0 && !filterCriteria.marketingRegions[element.marketingRegion].selectedInSearch)
            {
                return false;
            }
            if(selected.countries > 0 && !filterCriteria.countries[element.country].selectedInSearch)
            {
                return false;
            }
            if(selected.programs > 0 && selected.options == 0)
            {
                programSelectedCount = 0;
                angular.forEach(element.programNames, function(value)
                {
                    if(filterCriteria.programs[value].selectedInSearch)
                    {
                        programSelectedCount = programSelectedCount + 1;
                    }
                });
                if(programSelectedCount < 1)
                {
                    return false;
                }
            }
            else if(selected.programs > 0 && selected.options > 0)
            {
                programSelectedCount = 0;
                optionsSelectedCount = 0;
                for (let index = 0; index < element.programs.length; index++) {
                    const program = element.programs[index];
                    if(program.optionName != null && filterCriteria.programs[program.programName].options[program.optionName].selectedInSearch)
                    {
                        optionsSelectedCount++;
                    }
                }
                if(optionsSelectedCount < 1)
                {
                    return false;
                }
            }
            if(selected.terms > 0)
            {
                termSelectedCount = 0;
                angular.forEach(element.usTermsSplit, function(value)
                {
                    if(filterCriteria.terms[value].selectedInSearch)
                    {
                        termSelectedCount = termSelectedCount + 1;
                    }
                });
                if(termSelectedCount < 1)
                {
                    return false;
                }
            }                    
            if(selected.learningComponents > 0)
            {
                learningComponentSelectedCount = 0;
                angular.forEach(element.learningComponents, function(value)
                {
                    if(filterCriteria.learningComponents[value].selectedInSearch)
                    {
                        learningComponentSelectedCount = learningComponentSelectedCount + 1;
                    }
                });
                if(learningComponentSelectedCount < 1)
                {
                    return false;
                }
            }
            if(selected.departments > 0)
            {
                departmentSelectedCount = 0;
                angular.forEach(element.departments, function(value)
                {
                    if(filterCriteria.departments[value].selectedInSearch)
                    {
                        departmentSelectedCount = departmentSelectedCount + 1;
                    }
                });
                if(departmentSelectedCount < 1)
                {
                    return false;
                }
            }
            
            // language            
            if(selected.languagesOfInstruction > 0 && !filterCriteria.languagesOfInstruction[element.languageOfInstruction].selectedInSearch)
            {
                return false;
            }
            

            if(selected.areasOfStudy > 0)
            {
                areasOfStudySelectedCount = 0;
                angular.forEach(element.areasOfStudy, function(value)
                {
                    if(filterCriteria.areasOfStudy[value].selectedInSearch)
                    {
                        areasOfStudySelectedCount = areasOfStudySelectedCount + 1;
                    }
                });
                if(areasOfStudySelectedCount < 1)
                {
                    return false;
                }
            }
            if(selected.popularClasses > 0)
            {
                popularClassesSelectedCount = 0;
                if(filterCriteria.popularClasses['Popular_Classes'].selectedInSearch && (element.popularClass || element.isTop20))
                {
                    popularClassesSelectedCount++;
                }
                if(popularClassesSelectedCount < 1)
                {
                    return false;
                }
            }
            if(selected.courseMatches > 0)
            {
                courseMatchSelectedCount = 0;
                angular.forEach(element.courseMatches, function(value)
                {
                    if(filterCriteria.courseMatches[value.Status__c].selectedInSearch)
                    {
                        courseMatchSelectedCount++;
                    }
                });
                if(courseMatchSelectedCount < 1)
                {
                    return false;
                }
            }
            return true;
        });
        // Search by searchTerm
        if(!filterCriteria.searchTerm || filterCriteria.searchTerm == '' || filterCriteria.searchTerm == 'All Classes')
        {}
        else
        {
            var searchArray = [];
            // Convert search term to lower case and replace slashes and dashes with spaces
            searchTermLower = filterCriteria.searchTerm.toLowerCase();
            if(searchTermLower.startsWith('"') && searchTermLower.endsWith('"'))
            {
                // Full match search
                // Strip quotes
                searchTermLower = searchTermLower.replace(/"/g, '');
                searchArray = [searchTermLower];
                items = items.filter(function(element, index, array){
                    // Convert course title, untranslated course title and tags to lower case
                    courseTitle = element.courseTitle != null ? element.courseTitle.toLowerCase() : '';
                    untranslatedCourseTitle = element.untranslatedCourseTitle != null ? element.untranslatedCourseTitle.toLowerCase() : '';
                    
                    if(courseTitle.indexOf(searchTermLower) > -1)
                        return true;
                    else if(untranslatedCourseTitle.indexOf(searchTermLower) > -1)
                        return true;
                    else {}
                    return false;
                });
            }
            else
            {
                // Non full match search
                // Replace slashes and dashes with spaces
                searchTermLower = searchTermLower.replace(/\//g, ' ');
                searchTermLower = searchTermLower.replace(/\\/g, ' ');
                searchTermLower = searchTermLower.replace(/-/g, ' ');
                // Replace other punctuation with empty string ('')
                searchTermLower = searchTermLower.replace(/,/g, '');
                searchTermLower = searchTermLower.replace(/:/g, '');
                searchTermLower = searchTermLower.replace(/"/g, '');
                searchTermLower = searchTermLower.replace(/-/g, '');
                // Spilt search term by spaces
                var searchTerms = searchTermLower.split(' ');
                // Remove excluded words
                var wordsToExclude = ["a","an","the","and","of","in","for","un","una","la","el","las","los","y","de","e"];
                for (let i = 0; i < searchTerms.length; i++) {
                    const searchTerm = searchTerms[i];
                    if(wordsToExclude.indexOf(searchTerm) === -1)
                    {
                        searchArray.push(searchTerm);
                    }
                }
                items = items.filter(function(element, index, array){
                    // Convert course title, untranslated course title and tags to lower case
                    courseTitle = element.courseTitle != null ? element.courseTitle.toLowerCase().split(' ') : [];
                    untranslatedCourseTitle = element.untranslatedCourseTitle != null ? element.untranslatedCourseTitle.toLowerCase().split(' ') : [];
                    
                    
                    // Using each the split search terms, search course titles, untranslated course titles, and tags.
                    for (let index = 0; index < searchArray.length; index++) {
                        const element = searchArray[index];
                        if(courseTitle.indexOf(element) > -1)
                            return true;
                        else if(untranslatedCourseTitle.indexOf(element) > -1)
                            return true;
                        else {
                        }
                    }
                    return false;
                });
            }
        }
        // Limit items only to favorites
        if(filterCriteria.favorites){
            items = items.filter(function(element, index, array){
                if(element.isFavorite){
                    return true;
                }
                return false;
            });
        }
        angular.forEach(items, function(item){
            delete item.courseTitleLC;
            filterCriteria.countries[item.country].courseCount++;
            filterCriteria.marketingRegions[item.marketingRegion].courseCount++;
            filterCriteria.languagesOfInstruction[item.languageOfInstruction].courseCount++;
            var alreadyUsedPrograms = [];
            var alreadyUsedOptions = [];
            for (let index = 0; index < item.programs.length; index++) {
                const program = item.programs[index];
                var addItProgram = true;
                var addItOption = program.optionName ? true : false;
                if(alreadyUsedPrograms.findIndex(p => p == program.programName) !== -1) {
                    addItProgram = false;
                }
                if(program.optionName && alreadyUsedOptions.findIndex(o => o == program.optionName)!== -1){
                    addItOption = false;
                }
                if(addItProgram){
                    filterCriteria.programs[program.programName].courseCount = filterCriteria.programs[program.programName].courseCount + 1;
                    alreadyUsedPrograms.push(program.programName);
                }
                if(addItOption){
                    filterCriteria.programs[program.programName].options[program.optionName].courseCount = filterCriteria.programs[program.programName].options[program.optionName].courseCount + 1;
                    alreadyUsedOptions.push(program.optionName);
                }
            }
            angular.forEach(item.usTermsSplit, function(term){
                filterCriteria.terms[term].courseCount++;
            });
            angular.forEach(item.learningComponents, function(learningComponent){
                filterCriteria.learningComponents[learningComponent].courseCount++;
            });
            angular.forEach(item.departments, function(department){
                filterCriteria.departments[department].courseCount++;
            });
            angular.forEach(item.areasOfStudy, function(areaOfStudy){
                filterCriteria.areasOfStudy[areaOfStudy].courseCount++;
            });
            angular.forEach(item.courseMatches, function(courseMatch){
                filterCriteria.courseMatches[courseMatch.Status__c].courseCount++;
            });
            filterCriteria.popularClasses['Popular_Classes'].courseCount = item.popularClass || item.isTop20 ? filterCriteria.popularClasses['Popular_Classes'].courseCount + 1 : filterCriteria.popularClasses['Popular_Classes'].courseCount;
                
        });

        return items;
    } 
})
.filter('projectCourseSearchAndFilter', function() {
    return function(collection, property, values, programs) {
        var returnList = [];
        if(collection == undefined && collection == null)
        {
            return null;
        }
        for (let index = 0; index < collection.length; index++) {
            const ce = collection[index];
            switch (property) {
                case 'country':
                    for (let countryIndex = 0; countryIndex < values.length; countryIndex++) {
                        const value = values[countryIndex];
                        if(ce.hostInstitutionCourse.country == value.name && value.selected)
                        {
                            returnList.push(ce);
                            break;
                        }
                        else if(!value.selected)
                        {
                            for (let index = 0; index < programs.length; index++) {
                                const program = programs[index];
                                if(program.country == value.name)
                                {
                                    program.selected = false;
                                }
                            }
                        }
                    }
                    break;
                case 'program':
                    for (let index = 0; index < ce.hostInstitutionCourse.programs.length; index++) {
                        const program = ce.hostInstitutionCourse.programs[index];
                        for (let programIndex = 0; programIndex < values.length; programIndex++) {
                            const value = values[programIndex];
                            if(program.recordName == value.name && value.selected)
                            {
                                if(!returnList.find(e => e.recordId === ce.recordId))
                                {
                                    returnList.push(ce);
                                    break;
                                }                        
                            }
                        }
                    }
                    //returnList = collection;
                    break;
                default:
                    break;
            }
        }
        return returnList;
    } 
})
.filter("chartRegionFilter", [
    function() {
        return function (regions, params) {
            let terms = params.terms;
            let userType = params.userType;
            let outsideApproved = params.outsideApproved == 'true';
            regions.forEach(region => {
                region.visible = false;
                region.countries.forEach(country => {
                    country.programsToDisplay = country.programs;
                    if(terms.findIndex(t => t.isSelected) !== -1){
                        country.programsToDisplay = arrayIntersection(country.programsToDisplay, terms, 'terms');
                    }
                    if(userType != 'Student'){
                        country.programsToDisplay = checkApproved(country.programsToDisplay, outsideApproved);
                    }
                    if(country.programsToDisplay.length){
                        country.visible = true;
                        region.visible = true;
                    }                    
                });
            })

            return regions;
        }
        function checkApproved(programs, oA){
            return programs.filter(function(p){
                p.notApproved = !p.activeProgramAuthorization || (p.activeProgramAuthorization && p.activeProgramAuthorization.selectedTerms.indexOf("Not Approved") !== -1);
                if(!p.notApproved || oA){
                    return true;
                }                    
            })
        }

        function arrayIntersection(a, b, type) {
            return a.filter(function(x) {
                for (let index = 0; index < b.length; index++) {
                    const item = b[index];
                    switch (type) {
                        case 'terms':
                            if(item.isSelected && ((item.term == 'Academic Year' && x.hasAcademicYearProgramTerms) || (item.term == 'Fall' && x.hasFallProgramTerms) || (item.term == 'Spring' && x.hasSpringProgramTerms || (item.term == 'Summer' && x.hasSummerProgramTerms)))){
                                return true;
                            }                                
                            break;
                        case 'regions':
                            if(item.isSelected && x.regionName == item.region)
                            {
                                return true;
                            }
                        case 'countries':
                            if(item.isSelected && x.countryName == item.name){
                                return true;
                            }
                        default:
                            break;
                    }                    
                }
            });
        }
    }
]);