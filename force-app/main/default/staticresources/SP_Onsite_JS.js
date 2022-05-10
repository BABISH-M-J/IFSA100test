var onSiteApp = angular.module('onSiteApp', ['ui.bootstrap', 'ngViewModel', 'truncate', 'ngSanitize']);
onSiteApp.filter('notNewOrGraded', function() {
    return function(courseRegs) {
        return courseRegs.filter(function(courseReg) {
            if(courseReg.courseStatus != 'New' && courseReg.courseStatus != 'Grade Submitted')
                return true;
            else
                return false;
        });
    };
});
onSiteApp.filter('ampersand', function(){
    return function(input){
        return input ? input.replace(/&amp;/g, '&') : '';
    }
});
onSiteApp.filter('apostraphe', function(){
    return function(input){
        return input ? input.replace(/&#39;/g, "'") : '';
    }
});
onSiteApp.filter('quote', function(){
    return function(input){
        return input ? input.replace(/&amp;quot;/g, '"') : '';
    }
});


onSiteApp.controller('onSiteController', function($scope, $modal, viewModel, $filter, 
    urlService, ampersandFilter, apostrapheFilter, quoteFilter) {

    //Initializers            
    $scope.viewModel = viewModel.getViewModel();
    var selectedTab = getParameterByName('tab'); 
    switch(selectedTab)
    {
        case "Housing":
            $scope.housingSelected = true;
            $scope.academicSelected = false;
            $scope.tripSelected = false;
            $scope.contactSelected = false;
            break;
        case "Academic":
            $scope.housingSelected = false;
            $scope.crfSelected = true;
            $scope.tripSelected = false;
            $scope.contactSelected = false;
            break;
        case "Trips":
            $scope.housingSelected = false;
            $scope.crfSelected = false;
            $scope.tripSelected = true;
            $scope.contactSelected = false;
            break;
        case "Contact":
            $scope.housingSelected = false;
            $scope.crfSelected = false;
            $scope.tripSelected = false;
            $scope.contactSelected = true;
            break;
        default:
            $scope.housingSelected = true;
            $scope.crfSelected = false;
            $scope.tripSelected = false;
            $scope.contactSelected = false;
            break;
    }
    $scope.onSiteAlerts = [];
    $scope.addingCourse = false;
    $scope.onlyGradeReport = false;
    $scope.newCourse = {}
    $scope.courseResults = [];
    $scope.myInterval = 0;
    $scope.noWrapSlides = false;
    angular.forEach($scope.viewModel.phoneCountries, function(country){
        if($scope.viewModel.abroadPhoneNumberCountry == country.Id)
        {
            $scope.viewModel.abroadPhoneNumberCountry = country;
        }
    });
    correctTripDatesForJS();
    var d = new Date();
    d.setMinutes(30);
    var newTrip = resetNewTrip();
    angular.forEach($scope.viewModel.courses, function(course){
        if(course.courseGrade && course.courseStatus == 'Grade Submitted')
        {
            $scope.showGradeCol = true;
        }
    });
    var slides = $scope.slides = [];
    for(var i=0; i<$scope.viewModel.photos.length; i++)
    {
        slides.push({
            image: $scope.viewModel.photos[i].image,
            text: $scope.viewModel.photos[i].text,
            url: $scope.viewModel.photos[i].url
        })
    }
    if($scope.viewModel.learningPlan)
    {
        $scope.viewModel.learningPlan.isLocked = true;
        // Filter Learning Plan
        $scope.viewModel.learningPlan.academicGoalsA = $filter('apostraphe')($scope.viewModel.learningPlan.academicGoalsA);
        $scope.viewModel.learningPlan.academicGoalsB = $filter('apostraphe')($scope.viewModel.learningPlan.academicGoalsB);
        $scope.viewModel.learningPlan.academicGoalsC = $filter('apostraphe')($scope.viewModel.learningPlan.academicGoalsC);
        $scope.viewModel.learningPlan.personalGoalsA = $filter('apostraphe')($scope.viewModel.learningPlan.personalGoalsA);
        $scope.viewModel.learningPlan.personalGoalsB = $filter('apostraphe')($scope.viewModel.learningPlan.personalGoalsB);
        $scope.viewModel.learningPlan.personalGoalsC = $filter('apostraphe')($scope.viewModel.learningPlan.personalGoalsC);
        $scope.viewModel.learningPlan.professionalGoalsA = $filter('apostraphe')($scope.viewModel.learningPlan.professionalGoalsA);
        $scope.viewModel.learningPlan.professionalGoalsB = $filter('apostraphe')($scope.viewModel.learningPlan.professionalGoalsB);
        $scope.viewModel.learningPlan.professionalGoalsC = $filter('apostraphe')($scope.viewModel.learningPlan.professionalGoalsC);
        $scope.viewModel.learningPlan.specificActions1 = $filter('apostraphe')($scope.viewModel.learningPlan.specificActions1);
        $scope.viewModel.learningPlan.specificActions2 = $filter('apostraphe')($scope.viewModel.learningPlan.specificActions2);
        $scope.viewModel.learningPlan.specificActions3 = $filter('apostraphe')($scope.viewModel.learningPlan.specificActions3);
        $scope.viewModel.learningPlan.specificActions4 = $filter('apostraphe')($scope.viewModel.learningPlan.specificActions4);
        $scope.viewModel.learningPlan.specificActions5 = $filter('apostraphe')($scope.viewModel.learningPlan.specificActions5);
        $scope.viewModel.learningPlan.otherInformation = $filter('apostraphe')($scope.viewModel.learningPlan.otherInformation);
        $scope.viewModel.learningPlan.academicOriginalA = $filter('apostraphe')($scope.viewModel.learningPlan.academicOriginalA);
        $scope.viewModel.learningPlan.academicOriginalB = $filter('apostraphe')($scope.viewModel.learningPlan.academicOriginalB);
        $scope.viewModel.learningPlan.academicOriginalC = $filter('apostraphe')($scope.viewModel.learningPlan.academicOriginalC);
        $scope.viewModel.learningPlan.personalOriginalA = $filter('apostraphe')($scope.viewModel.learningPlan.personalOriginalA);
        $scope.viewModel.learningPlan.personalOriginalB = $filter('apostraphe')($scope.viewModel.learningPlan.personalOriginalB);
        $scope.viewModel.learningPlan.personalOriginalC = $filter('apostraphe')($scope.viewModel.learningPlan.personalOriginalC);
        $scope.viewModel.learningPlan.professionalOriginalA = $filter('apostraphe')($scope.viewModel.learningPlan.professionalOriginalA);
        $scope.viewModel.learningPlan.professionalOriginalB = $filter('apostraphe')($scope.viewModel.learningPlan.professionalOriginalB);
        $scope.viewModel.learningPlan.professionalOriginalC = $filter('apostraphe')($scope.viewModel.learningPlan.professionalOriginalC);
        $scope.viewModel.learningPlan.specificOriginal1 = $filter('apostraphe')($scope.viewModel.learningPlan.specificOriginal1);
        $scope.viewModel.learningPlan.specificOriginal2 = $filter('apostraphe')($scope.viewModel.learningPlan.specificOriginal2);
        $scope.viewModel.learningPlan.specificOriginal3 = $filter('apostraphe')($scope.viewModel.learningPlan.specificOriginal3);
        $scope.viewModel.learningPlan.specificOriginal4 = $filter('apostraphe')($scope.viewModel.learningPlan.specificOriginal4);
        $scope.viewModel.learningPlan.specificOriginal5 = $filter('apostraphe')($scope.viewModel.learningPlan.specificOriginal5);
        $scope.viewModel.learningPlan.otherInformationOriginal = $filter('apostraphe')($scope.viewModel.learningPlan.otherInformationOriginal);
        $scope.viewModel.learningPlan.academicGoalsA = $filter('quote')($scope.viewModel.learningPlan.academicGoalsA);
        $scope.viewModel.learningPlan.academicGoalsB = $filter('quote')($scope.viewModel.learningPlan.academicGoalsB);
        $scope.viewModel.learningPlan.academicGoalsC = $filter('quote')($scope.viewModel.learningPlan.academicGoalsC);
        $scope.viewModel.learningPlan.personalGoalsA = $filter('quote')($scope.viewModel.learningPlan.personalGoalsA);
        $scope.viewModel.learningPlan.personalGoalsB = $filter('quote')($scope.viewModel.learningPlan.personalGoalsB);
        $scope.viewModel.learningPlan.personalGoalsC = $filter('quote')($scope.viewModel.learningPlan.personalGoalsC);
        $scope.viewModel.learningPlan.professionalGoalsA = $filter('quote')($scope.viewModel.learningPlan.professionalGoalsA);
        $scope.viewModel.learningPlan.professionalGoalsB = $filter('quote')($scope.viewModel.learningPlan.professionalGoalsB);
        $scope.viewModel.learningPlan.professionalGoalsC = $filter('quote')($scope.viewModel.learningPlan.professionalGoalsC);
        $scope.viewModel.learningPlan.specificActions1 = $filter('quote')($scope.viewModel.learningPlan.specificActions1);
        $scope.viewModel.learningPlan.specificActions2 = $filter('quote')($scope.viewModel.learningPlan.specificActions2);
        $scope.viewModel.learningPlan.specificActions3 = $filter('quote')($scope.viewModel.learningPlan.specificActions3);
        $scope.viewModel.learningPlan.specificActions4 = $filter('quote')($scope.viewModel.learningPlan.specificActions4);
        $scope.viewModel.learningPlan.specificActions5 = $filter('quote')($scope.viewModel.learningPlan.specificActions5);
        $scope.viewModel.learningPlan.otherInformation = $filter('quote')($scope.viewModel.learningPlan.otherInformation);
        $scope.viewModel.learningPlan.academicOriginalA = $filter('quote')($scope.viewModel.learningPlan.academicOriginalA);
        $scope.viewModel.learningPlan.academicOriginalB = $filter('quote')($scope.viewModel.learningPlan.academicOriginalB);
        $scope.viewModel.learningPlan.academicOriginalC = $filter('quote')($scope.viewModel.learningPlan.academicOriginalC);
        $scope.viewModel.learningPlan.personalOriginalA = $filter('quote')($scope.viewModel.learningPlan.personalOriginalA);
        $scope.viewModel.learningPlan.personalOriginalB = $filter('quote')($scope.viewModel.learningPlan.personalOriginalB);
        $scope.viewModel.learningPlan.personalOriginalC = $filter('quote')($scope.viewModel.learningPlan.personalOriginalC);
        $scope.viewModel.learningPlan.professionalOriginalA = $filter('quote')($scope.viewModel.learningPlan.professionalOriginalA);
        $scope.viewModel.learningPlan.professionalOriginalB = $filter('quote')($scope.viewModel.learningPlan.professionalOriginalB);
        $scope.viewModel.learningPlan.professionalOriginalC = $filter('quote')($scope.viewModel.learningPlan.professionalOriginalC);
        $scope.viewModel.learningPlan.specificOriginal1 = $filter('quote')($scope.viewModel.learningPlan.specificOriginal1);
        $scope.viewModel.learningPlan.specificOriginal2 = $filter('quote')($scope.viewModel.learningPlan.specificOriginal2);
        $scope.viewModel.learningPlan.specificOriginal3 = $filter('quote')($scope.viewModel.learningPlan.specificOriginal3);
        $scope.viewModel.learningPlan.specificOriginal4 = $filter('quote')($scope.viewModel.learningPlan.specificOriginal4);
        $scope.viewModel.learningPlan.specificOriginal5 = $filter('quote')($scope.viewModel.learningPlan.specificOriginal5);
        $scope.viewModel.learningPlan.otherInformationOriginal = $filter('quote')($scope.viewModel.learningPlan.otherInformationOriginal);
        $scope.viewModel.learningPlan.academicGoalsA = $filter('ampersand')($scope.viewModel.learningPlan.academicGoalsA);
        $scope.viewModel.learningPlan.academicGoalsB = $filter('ampersand')($scope.viewModel.learningPlan.academicGoalsB);
        $scope.viewModel.learningPlan.academicGoalsC = $filter('ampersand')($scope.viewModel.learningPlan.academicGoalsC);
        $scope.viewModel.learningPlan.personalGoalsA = $filter('ampersand')($scope.viewModel.learningPlan.personalGoalsA);
        $scope.viewModel.learningPlan.personalGoalsB = $filter('ampersand')($scope.viewModel.learningPlan.personalGoalsB);
        $scope.viewModel.learningPlan.personalGoalsC = $filter('ampersand')($scope.viewModel.learningPlan.personalGoalsC);
        $scope.viewModel.learningPlan.professionalGoalsA = $filter('ampersand')($scope.viewModel.learningPlan.professionalGoalsA);
        $scope.viewModel.learningPlan.professionalGoalsB = $filter('ampersand')($scope.viewModel.learningPlan.professionalGoalsB);
        $scope.viewModel.learningPlan.professionalGoalsC = $filter('ampersand')($scope.viewModel.learningPlan.professionalGoalsC);
        $scope.viewModel.learningPlan.specificActions1 = $filter('ampersand')($scope.viewModel.learningPlan.specificActions1);
        $scope.viewModel.learningPlan.specificActions2 = $filter('ampersand')($scope.viewModel.learningPlan.specificActions2);
        $scope.viewModel.learningPlan.specificActions3 = $filter('ampersand')($scope.viewModel.learningPlan.specificActions3);
        $scope.viewModel.learningPlan.specificActions4 = $filter('ampersand')($scope.viewModel.learningPlan.specificActions4);
        $scope.viewModel.learningPlan.specificActions5 = $filter('ampersand')($scope.viewModel.learningPlan.specificActions5);
        $scope.viewModel.learningPlan.otherInformation = $filter('ampersand')($scope.viewModel.learningPlan.otherInformation);
        $scope.viewModel.learningPlan.academicOriginalA = $filter('ampersand')($scope.viewModel.learningPlan.academicOriginalA);
        $scope.viewModel.learningPlan.academicOriginalB = $filter('ampersand')($scope.viewModel.learningPlan.academicOriginalB);
        $scope.viewModel.learningPlan.academicOriginalC = $filter('ampersand')($scope.viewModel.learningPlan.academicOriginalC);
        $scope.viewModel.learningPlan.personalOriginalA = $filter('ampersand')($scope.viewModel.learningPlan.personalOriginalA);
        $scope.viewModel.learningPlan.personalOriginalB = $filter('ampersand')($scope.viewModel.learningPlan.personalOriginalB);
        $scope.viewModel.learningPlan.personalOriginalC = $filter('ampersand')($scope.viewModel.learningPlan.personalOriginalC);
        $scope.viewModel.learningPlan.professionalOriginalA = $filter('ampersand')($scope.viewModel.learningPlan.professionalOriginalA);
        $scope.viewModel.learningPlan.professionalOriginalB = $filter('ampersand')($scope.viewModel.learningPlan.professionalOriginalB);
        $scope.viewModel.learningPlan.professionalOriginalC = $filter('ampersand')($scope.viewModel.learningPlan.professionalOriginalC);
        $scope.viewModel.learningPlan.specificOriginal1 = $filter('ampersand')($scope.viewModel.learningPlan.specificOriginal1);
        $scope.viewModel.learningPlan.specificOriginal2 = $filter('ampersand')($scope.viewModel.learningPlan.specificOriginal2);
        $scope.viewModel.learningPlan.specificOriginal3 = $filter('ampersand')($scope.viewModel.learningPlan.specificOriginal3);
        $scope.viewModel.learningPlan.specificOriginal4 = $filter('ampersand')($scope.viewModel.learningPlan.specificOriginal4);
        $scope.viewModel.learningPlan.specificOriginal5 = $filter('ampersand')($scope.viewModel.learningPlan.specificOriginal5);
        $scope.viewModel.learningPlan.otherInformationOriginal = $filter('ampersand')($scope.viewModel.learningPlan.otherInformationOriginal);
        // Copy current values to new variables to track what is currently saved in Salesforce with new updates
        $scope.learningPlan = angular.copy($scope.viewModel.learningPlan);        
    }
    
    //searchForHostInstitution();
    //Functions
    //Trips functions
    function correctTripDatesForJS() {
        angular.forEach($scope.viewModel.upcomingTrips, function(trip){
            trip.startDate = new Date(trip.startDate.replace(/-/g, '\/').replace(/T.+/, ''));
            trip.endDate = new Date(trip.endDate.replace(/-/g, '\/').replace(/T.+/, ''));
        });
        angular.forEach($scope.viewModel.pastTrips, function(trip){
            trip.startDate = new Date(trip.startDate.replace(/-/g, '\/').replace(/T.+/, ''));
            trip.endDate = new Date(trip.endDate.replace(/-/g, '\/').replace(/T.+/, ''));
        });
    }

    function resetNewTrip() {
        return {
            travelId: null,
            applicationId: $scope.viewModel.applicationId,
            cityName: '',
            contactId: $scope.viewModel.contactId,
            countryId: null,
            countryName: '',
            endDate: new Date(d.getFullYear(), d.getMonth(), d.getDay()),
            startDate: new Date(d.getFullYear(), d.getMonth(), d.getDay()),
            description: '',
            localityId: null,
            localityName: '',
            selectedStatus: 'Upcoming',
            statuses: ['Upcoming','Active','Complete'],
            tripName: '',
            tripEmail: $scope.viewModel.studentEmail, //get student's email
            tripPhone: $scope.viewModel.abroadPhoneNumber, //get student's abroad phone
            tripPhoneCountry: $scope.viewModel.abroadPhoneNumberCountry
        };
    }

    //START OF TRAVEL MODAL        
$scope.animationsEnabled = true;
$scope.open = function (isNewTrip, existingTrip, doDelete) {
    $scope.deleteRecord = doDelete;
    $scope.isNewTrip = isNewTrip;
        if(isNewTrip){
            $scope.thisTrip = resetNewTrip();
        }
    else
    {                                        
            //Need to parse the date string from viewModel
            try
            {
                var sd = existingTrip.startDate.replace(/-/g, '/');
                sd = new Date(sd.match(/\d{4}\/\d{2}\/\d{2}/));
                existingTrip.startDate = sd;
            }
            catch(e){}
            try
            {
                var ed = existingTrip.endDate.replace(/-/g, '/');                            
                ed = new Date(ed.match(/\d{4}\/\d{2}\/\d{2}/));
                existingTrip.endDate = ed;
            }
            catch(e) {} 
            $scope.thisTrip = existingTrip;
    }

    var modalInstance = $modal.open({
        animation: $scope.animationsEnabled,
        size: 'lg',
        templateUrl: 
            urlService.getOnSiteModalURL(),
        controller: 'TravelModalController',
        resolve: {
            trip: $scope.thisTrip,
            doDelete: doDelete,
        }
    });

    modalInstance.result.then(function (selectedItem) {
        if(selectedItem.constructor === Array)
        {
            angular.forEach(selectedItem, function(trip){
                //trip.startDate = trip.startDate.getFullYear() + "-" + (trip.startDate.getMonth() + 1) + "-" + (trip.startDate.getDate() + 1);
                //trip.endDate = trip.endDate.getFullYear() + "-" + (trip.endDate.getMonth() + 1) + "-" + (trip.endDate.getDate() + 1);
                $scope.viewModel.upcomingTrips.push(trip);
            });
        }
        else
        {
            if(selectedItem && $scope.deleteRecord)
            {
                for(var i = $scope.viewModel.upcomingTrips.length - 1; i >= 0; i--) {
                    if($scope.viewModel.upcomingTrips[i].travelId === selectedItem.travelId) {
                        $scope.viewModel.upcomingTrips.splice(i, 1);
                    }
                }
            }
            else if(selectedItem && !$scope.deleteRecord && $scope.isNewTrip)
            {
                //selectedItem.startDate = selectedItem.startDate.getFullYear() + "-" + (selectedItem.startDate.getMonth() + 1) + "-" + (selectedItem.startDate.getDate() + 1);
                //selectedItem.endDate = selectedItem.endDate.getFullYear() + "-" + (selectedItem.endDate.getMonth() + 1) + "-" + (selectedItem.endDate.getDate() + 1);
                $scope.viewModel.upcomingTrips.push(selectedItem);
            }
            else if(selectedItem && !$scope.deleteRecord && !$scope.isNewTrip)
            {
                //selectedItem.startDate = selectedItem.startDate.getFullYear() + "-" + (selectedItem.startDate.getMonth() + 1) + "-" + (selectedItem.startDate.getDate() + 1);
                //selectedItem.endDate = selectedItem.endDate.getFullYear() + "-" + (selectedItem.endDate.getMonth() + 1) + "-" + (selectedItem.endDate.getDate() + 1);
                for(var i = $scope.viewModel.upcomingTrips.length - 1; i >= 0; i--) {
                    if($scope.viewModel.upcomingTrips[i].travelId === selectedItem.travelId) {
                        $scope.viewModel.upcomingTrips[i] = selectedItem;
                    }
                }                    
            }
        }
        
        $scope.$apply();
    });
};

$scope.toggleAnimation = function () {
    $scope.animationsEnabled = !$scope.animationsEnabled;
};
//END OF CODE FOR TRAVEL MODAL

    //Contact Info
    $scope.setCountryCode = function(country) {
        $scope.viewModel.abroadPhoneNumber = country.Phone_Code__c != null ? "+" + country.Phone_Code__c : "";
    }

    $scope.updateAbroadPhoneNUmber = function() {
        portalRemotingMethods.updateAbroadPhoneNumber(
            $scope.viewModel.abroadPhoneNumber,
            $scope.viewModel.abroadPhoneNumberCountry.Id,
            $scope.viewModel.contactId,
            function(result, event){
                if(result)
                    $scope.onSiteAlerts.push({ type: 'success', msg: 'Phone number while abroad has saved successfully!' });
                else
                    $scope.onSiteAlerts.push({ type: 'danger', msg: 'Phone number while abroad did not save successfully!' });
                $scope.$apply();
            });
    }
    $scope.closeOnSiteAlert = function(index) {
        $scope.onSiteAlerts.splice(index, 1);
        };
// Start of Learning Plan
    $scope.updateLearningPlan = function() {
        $scope.isSaving = true;
        //$scope.$apply();

        portalRemotingMethods.submitApplicationItem(
            angular.toJson($scope.viewModel.learningPlan),
            '',
            '',
            '',
            function(result, event) {
                $scope.updateLearningPlanComplete(result);
            }
        );
        
    };
    $scope.updateLearningPlanComplete = function(result) {
        if(result)
        {
            alert("Saved Successfully!");
            $scope.viewModel.learningPlan.isLocked = true;
            $scope.learningPlan = angular.copy($scope.viewModel.learningPlan);
        }
        else
        {
            alert("Error - Save Unsuccessful!");
        }
        $scope.isSaving = false;
        $scope.$apply();
    }
// End of Learning Plan
// Start of Courses
    //Opens add course form
    $scope.addCourse = function() {
        $scope.addingCourse = true;                
        $scope.$apply();
        document.getElementById("hostSchoolTextBox").focus();
    }

    //Cancels add course form
    $scope.cancelCourse = function() {
        $scope.addingCourse = false;
        $scope.newCourse = {};
    }

    //Adds course to list
    $scope.confirmCourse = function() {
        $scope.newCourse.courseName = $scope.newCourse.encodedCourseName;
        $scope.newCourse.courseTitle = $scope.newCourse.courseName;
        $scope.newCourse.courseStatus = 'New';             
        $scope.viewModel.courses.push($scope.newCourse);
        $scope.cancelCourse();
        document.getElementById("addButton").focus();
    }

    //Search for home institutions
    function searchForHostInstitution() {
        portalRemotingMethods.searchHostInstitutions(
            $scope.viewModel.programID,
            function(result, event) {
                $scope.populateHostInstitution(result, event);
            }
        );
    }
    //Populate host institution
    $scope.populateHostInstitution = function(result, event) {
        $scope.institutionResults = result;
        $scope.$apply();
    }
    //Select an institution
    $scope.selectInstitution = function(item) {
        $scope.newCourse.hostInstitutionId = item.Id;
        $scope.newCourse.hostInstitutionName = item.Name.replace("&#39;", "'");
    }

    //Search for courses
    $scope.searchForCourses = function() {
        portalRemotingMethods.searchForCourses(
            $scope.newCourse.hostInstitutionId,
            $scope.newCourse.encodedCourseName,
            function(result, event) {
                $scope.populateCourseDropdown(result, event);
            }
        );
    }

    //Once course results have come back, populate
    $scope.populateCourseDropdown = function(result, event) {
        $scope.courseResults = result;
        $scope.$apply();
    }

    //Select a course
    $scope.selectCourse = function(item) {
        var institutionId = $scope.newCourse.hostInstitutionId;
        var institutionName = $scope.newCourse.hostInstitutionName;
        $scope.newCourse = item;
        if(item.encodedCourseName)
        {
            $scope.newCourse.encodedCourseName = item.encodedCourseName.replace("IFSA_ampSymbol_IFSA", "&");
            $scope.newCourse.courseName = $scope.newCourse.encodedCourseName;
        }
        else
        {
            $scope.newCourse.encodedCourseName = item.courseName;
        }
        $scope.newCourse.hostInstitution = {Id: institutionId, Name: institutionName};
        $scope.newCourse.hostInstitutionId = institutionId;
        $scope.newCourse.hostInstitutionName = institutionName;
    }            

    //Use this to submit the entire course registration form.
    $scope.submitCourseRegistration = function() {
        var isReady = confirm("Once you have submitted this form, you cannot modify it. Continue?");
        $scope.isSubmitting = true
        var courses = angular.toJson(($scope.viewModel.courses))
        if(isReady) {
            portalRemotingMethods.submitCourseRegistration(
                courses, $scope.viewModel.applicationId,
                function(result, event) {
                    $scope.confirmCourseRegistrationSubmission(result, event);
                }
            );
        }
    }

    //This is the callback function after course registration is submitted
    $scope.confirmCourseRegistrationSubmission = function(result, event) {
        if(!result) {
            alert("There was an error submitting your course registration form. You may attempt to submit again if you wish. If you continue to have problems, please contact IFSA.");
        } else {
            alert("Your Course Registration was submitted successfully.");
            angular.forEach($scope.viewModel.courses, function(course){
                course.courseStatus == 'Approval Pending';
            });
            $scope.viewModel.isCourseRegEditable = false;                    
        }
        $scope.isSubmitting = false;
        $scope.$apply();
    }
    $scope.removeCourse = function(course) {
        $scope.viewModel.courses.splice($scope.viewModel.courses.indexOf(course), 1);
    }
});
//Travel Modal Controller
onSiteApp.controller('TravelModalController', function ($scope, $modalInstance, trip, doDelete, viewModel) 
{
    $scope.alerts = [];
    $scope.delete = doDelete;
    $scope.trip = angular.copy(trip);
    $scope.trip.startDate = new Date();
    $scope.trip.endDate = new Date();
    try
    {
        $scope.trip.tripPhoneCountry = trip.tripPhoneCountry.Id;   
    }
    catch(exception)
    {
        console.log($scope.trip.tripPhoneCountry);
    }
    $scope.newTripsList = [];
    var vm = viewModel.getViewModel();
    $scope.phoneCountries = vm.phoneCountries;
    $scope.cityPlaceholder = "Choose a country first";

    $scope.closeAlert = function(index) {
        $scope.alerts.splice(index, 1);
    };

    $scope.addTrip = function() {
        $scope.save('multi');
    }

    $scope.save = function (saveType) {
        $scope.saveType = saveType;
        portalRemotingMethods.saveTrip(
            angular.toJson($scope.trip),
                function(result, event) {
                    $scope.saveFinished(result, event)
            }
        );
    };

    $scope.saveFinished = function (result, event) {
        if(result)
        {
            $scope.trip.travelId = result;
            if($scope.saveType == 'single' && $scope.newTripsList.length < 1)
            {
                $modalInstance.close($scope.trip);
            }
            else
            {
                $scope.newTripsList.push($scope.trip);
                $scope.trip = angular.copy(trip);
                $scope.trip.startDate = $scope.newTripsList[$scope.newTripsList.length - 1].endDate;
                if($scope.saveType == 'single')
                {
                    $scope.done();
                }
            }
        }
        else
        {
            $scope.alerts.push({ type: 'danger', msg: 'Trip did not save. Please try again.' });
        }
        $scope.$apply();
    };

    $scope.yes = function (trip) {
        portalRemotingMethods.deleteTrip(
            trip.travelId,
            function(result, event) {
                $scope.deleteFinished(result, event)
            }
        );
    };

    $scope.deleteFinished = function (result, event) {
        if(result)
        {
            $modalInstance.close($scope.trip);
        }
        else
        {
            $scope.alerts.push({ type: 'danger', msg: 'Trip did not delete. Please try again.' });
            $scope.$apply();
        }
    };

    $scope.startDateChanged = function () {
        if($scope.trip.endDate < $scope.trip.startDate) 
        {
            $scope.trip.endDate = $scope.trip.startDate;
        }
    }

    $scope.cancel = function () {
        //$scope.trip = originalTrip
        $modalInstance.dismiss('cancel');
    };

    $scope.done = function () {
        //$scope.trip = originalTrip
        $modalInstance.close($scope.newTripsList);
    };

    //Search for countries
    $scope.searchForCountries = function() {
        portalRemotingMethods.searchForRecord(
            'Country__c',
            $scope.trip.countryName,
            function(result, event) {
            $scope.populateCountryDropdown(result, event);
            }
        );
    }

    //Once country results have come back, populate
    $scope.populateCountryDropdown = function(result, event) {
        $scope.countryResults = result;
        $scope.$apply();
    }

    //Select a country
    $scope.selectCountry = function(item) {                
        $scope.trip.countryId = item.id;
        $scope.trip.countryName = item.name;
    }

    //Search for cities
    $scope.searchForCities = function() {
        portalRemotingMethods.searchForRecordWithRecordType(
            'Locality__c',
            $scope.trip.localityName,
            $scope.trip.countryName,
            function(result, event) {
                $scope.populateCityDropdown(result, event);
            }
        );
    }

    //Once city results have come back, populate
    $scope.populateCityDropdown = function(result, event) {
        $scope.cityResults = result;
        $scope.$apply();
    }

    //Select a city
    $scope.selectCity = function(item) {                
        $scope.trip.localityId = item.id;
        $scope.trip.localityName = item.name;
    }
});