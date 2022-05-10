/**
 * Student Portal On Site Filters
 * @file Student Portal On Site Filters
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.filters')
.filter('submittedCoursesFilter', function() {
    return function(courseRegs) {
        return courseRegs.filter(function(courseReg) {
            switch (courseReg.courseStatus) {
                // Every status where a course would be displayed
                case 'Approval Pending':
                case 'Approved':
                case 'Grade Entered':
                case 'Grade Corrected':
                case 'Course Omitted':
                case 'Grade Revised':
                    return true;
                default:
                    return false;
            }
            if(courseReg.courseStatus != 'New' && courseReg.courseStatus != 'Grade Submitted' && courseReg.courseStatus.indexOf('CIF') === -1 && courseReg.courseStatus != 'Not Registered')
                return true;
        });
    };
})
.filter('newCoursesFilter', function() {
    return function(courseRegs) {
        return courseRegs.filter(function(courseReg) {
            switch (courseReg.courseStatus) {
                // Every status where a course would be displayed
                case 'New':
                case 'CIF - Submitted':
                case 'CRF - Draft':
                    return true;            
                default:
                    return false;
            }
        });
    };
})
.filter('gradedCoursesFilter', function() {
    return function(courseRegs) {
        return courseRegs.filter(function(courseReg) {
            switch (courseReg.courseStatus) {
                // Every status where a course would be displayed
                case 'Grade Verified':
                case 'Grade Submitted':
                case 'Ready for Butler':
                    return true;            
                default:
                    return false;
            }
        });
    };
})
.filter("toArray", function(){
    return function(obj) {
        var result = [];
        angular.forEach(obj, function(val, key) {
            result.push(val);
        });
        return result;
    };
});