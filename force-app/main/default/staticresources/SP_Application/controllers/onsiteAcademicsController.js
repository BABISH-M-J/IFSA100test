/**
 * Student Portal On Site Academics Page Controller
 * @file Student Portal On Site Academics Page Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('onsiteAcademicsController', function($scope, $modal, $filter, $http, urlService, viewModel, applicationService, courseRegService, errorModalService, browserDetectService, dateService) 
{
    $scope.uploadNeeded = false;
    var imageDictionary;
    $scope.init = function() {
        $scope.loading = true;
        $scope.showViewPDF = false;
        $scope.urlService = urlService;
        $scope.activePage = 'Academics';
        var vm = viewModel.getViewModel();
        var instructions = vm.portalSettings.find(s => s.DeveloperName == 'SP_CRF_Instructions');
        var cutoffDatePast = vm.portalSettings.find(s => s.DeveloperName == 'SP_CRF_Cutoff_Past');
        $scope.viewModel = {
            applicationStatus: vm.applicationStatus,
            hasFinancialHold: vm.hasFinancialHold,
            butlerId: vm.butlerId,
            courses: [],
            crfInstructions: instructions.Content__c,
            crfCutoffDatePast: cutoffDatePast.Content__c
        }
        var broswerName = browserDetectService.getBrowserName()
        if(broswerName == 'chrome' || broswerName == 'firefox' || broswerName == 'opera'){
            $scope.showViewPDF = true;
        }
        var syllabusPromise = courseRegService.getCRFConfiguration();
        syllabusPromise.then(function(result){
            $scope.uploadNeeded = courseRegService.getRequestSyllabi();
            $scope.spanishTitles = courseRegService.getSpanishTitles();
            $scope.crfCutoffDate = dateService.convertDate(courseRegService.getCrfCutoffDate());
            $scope.crfEditable = courseRegService.getCrfEditable();
            $scope.newCourse = {
                hostInstitutionId: null,
                hostInstitutionName: null,
            };
        }, function(result){
            $scope.uploadNeeded = false;
            $scope.loading = false;
        })
        $scope.getCourseRegistrations();        
    }

    $scope.getCourseRegistrations = function() {
        var promise = courseRegService.getCourseRegistrations();
        promise.then(function(result){
            // Resolved
            $scope.viewModel.courses = [];
            for (let index = 0; index < result.length; index++) {
                const course = result[index];
                course.isRegistered = course.courseStatus == "CRF - Draft";
                $scope.viewModel.courses.push(course);
            }
            $scope.getApplication();
            $scope.getHostInstitutions();
            $scope.loading = false;
        }, function(result){
            // Rejection
            $scope.loading = false;
            $scope.error = true;
            console.log('courseRegService.getCourseRegistrations failed');
        })
        imageDictionary = {};
        toDataURL(urlService.getIFSALetterheadURL(), function(dataUrl) {
            imageDictionary['letterhead'] = dataUrl;
        });
        toDataURL(urlService.getBaseResourceURL() + '/images/IFSALogo_withTagline.png', function(dataUrl) {
            imageDictionary['logo_with_tagline'] = dataUrl;
        });
        toDataURL(urlService.getBaseResourceURL() + '/images/AA_Director_Signature.jpg', function(dataUrl) {
            imageDictionary['aa_signature'] = dataUrl;
        });
    }

    $scope.getApplication = function() {
        var promise = applicationService.getApplicationPromise();
        promise.then(function(result){
            var application = applicationService.getApplication();
            $scope.viewModel.applicationStatus = application.Status__c;
            var crfComplete = false;
            var today = new Date();
            if(application.Course_Registration_Form_Submitted__c && !application.Program_Term_Section__c.includes('Year')){
                crfComplete = true;
            }
            else if(application.Course_Registration_Form_Submitted__c && application.Program_Term_Section__c.includes('Year') && application.CRF_Status__c == 'Round 1 Complete' && application.Program_Term__r.Start_Of_Second_Term__c > today){
                crfComplete = true;
            }
            else if(application.Course_Registration_Form_Submitted__c && application.Program_Term_Section__c.includes('Year') && application.CRF_Status__c == 'Round 2 Complete'){
                crfComplete = true;
            }
            $scope.viewModel.isCourseRegEditable = application.Status__c == 'On Site' && !crfComplete ? true : false;
            $scope.application = application;
        }, function(result){
            console.log('cound not load application');
        });
    }
    $scope.getHostInstitutions = function() {
        var promise = applicationService.getHostInstitutions();
        promise.then(function(result){
            $scope.viewModel.institutions = result;
        }, function(result){
            console.log('cound not load host institution');
        });
    }

    //Opens add course form
    $scope.addCourse = function() {
        var modalInstance = $modal.open({
            animation: true,
            //size: 'lg',
            backdrop: 'static',
            templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/addClassModal.html',
            resolve: {
                data: {
                    title: 'Add Class',
                    institutions: $scope.viewModel.institutions,
                    spanishTitles: courseRegService.getSpanishTitles()
                }
            },
            controller: 'addClassModalController'
        });

        modalInstance.result.then(function(result){
            // Actions when modal is submitted
            // Add status to newCourse and push to viewModel.courses
            let existingIndex = $scope.viewModel.courses.findIndex(c => c.courseId == result.courseId);
            if(existingIndex === -1 || !result.courseId){
                var newCourse = result;
                //Added by powerfluence req by call date 02/09/2022 starts
                newCourse.courseId=result.createdCourseId;
                //Added by powerfluence req by call date 02/09/2022 ends
                newCourse.courseTitle = newCourse.courseName;
                newCourse.courseStatus = 'New';
                newCourse.isRegistered = true;
                newCourse.locationId = result.locationId != '000000000000000' ? result.locationId : null
                $scope.viewModel.courses.push(newCourse);
            }
            else{
                const existingCourse = $scope.viewModel.courses[existingIndex];
                existingCourse.courseStatus = 'CRF - Draft';
                existingCourse.isRegistered = true;
                existingCourse.instructorFirstName = result.instructorFirstName;
                existingCourse.instructorLastName = result.instructorLastName;
                existingCourse.locationId = result.locationId != '000000000000000' ? result.locationId : null;
            }
        }, function(result) {
            // Actions when modal is cancelled
        });
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
        var inst = $scope.viewModel.institutions.find(i => i.Id == item);
        inst.Name = $filter('apostraphe')(inst.Name);
        inst.Name = $filter('ampersand')(inst.Name);
        $scope.newCourse.hostInstitutionName = inst.Name;
    }

    //Search for courses
    $scope.searchForCourses = function() {
        var promise = courseRegService.searchCourses($scope.newCourse.hostInstitutionId, $scope.newCourse.encodedCourseName, 'Course_Title_2__c');
        promise.then(function(result){
            $scope.courseResults = result;
        }, function(result){

        });
    }
    $scope.searchForCoursesUntranslated = function() {
        var promise = courseRegService.searchCourses($scope.newCourse.hostInstitutionId, $scope.newCourse.untranslatedCourseTitle, 'Untranslated_Course_Title__c');
        promise.then(function(result){
            $scope.untranslatedCourseResults = result;
        }, function(result){

        });
    }

    //Select a course
    $scope.selectCourse = function(item) {
        var institutionId = $scope.newCourse.hostInstitutionId;
        var institutionName = $scope.newCourse.hostInstitutionName;
        $scope.newCourse = item;
        var title = $filter('ampersand')(item.courseName);
        title = $filter('apostraphe')(title);
        $scope.newCourse.encodedCourseName = title;
        $scope.newCourse.untranslatedCourseTitle = item.untranslatedTitle;
        $scope.newCourse.hostInstitution = institutionId;
        $scope.newCourse.hostInstitutionId = institutionId;
        $scope.newCourse.hostInstitutionName = institutionName;
    }      

    //Use this to submit the entire course registration form.
    $scope.submitCourseRegistration = function(finalized) {
        var prompt;
        if(finalized)
        {
            prompt = "Once you submit this form, you cannot modify it."
            $scope.saving = true;

            var modalInstance = $modal.open({
                animation: true,
                size: 'lg',
                backdrop: 'static',
                templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/submitCRFModal.html',
                resolve: {
                    data: {
                        title: 'Class Registration Form', 
                        prompt: prompt,
                        viewModel: $scope.viewModel
                    }
                },
                controller: 'submitCRFModalController'
            });

        }
        else
        {
            prompt = "Are you sure you want to save your class registrations for later?"
            $scope.savingForLater = true;

            var modalInstance = $modal.open({
                animation: true,
                size: 'lg',
                backdrop: 'static',
                templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/YesNoModal.html',
                resolve: {
                    data: {
                        title: 'Class Registration Form', prompt: prompt }
                },
                controller: 'yesNoModalController'
            });

        }

        modalInstance.result.then(function(result){
            var status = finalized ? 'Approval Pending' : 'CRF - Draft';
            var crs = angular.copy($scope.viewModel.courses);
            for (let index = 0; index < crs.length; index++) {
                const course = crs[index];
                if(course.courseStatus == 'New' || course.courseStatus == 'CRF - Draft')
                {
                    course.courseStatus = status;
                }                
            }
            var promise = courseRegService.submitCourseRegistrations(crs);
            promise.then(function(result){
                console.log('saved');
                $scope.confirmCourseRegistrationSubmission(result, null, finalized);
                var appPromise = applicationService.getApplicationFromSF(viewModel.getViewModel().applicationId);
                appPromise.then(function(result){
                    $scope.getCourseRegistrations();
                },
                function(result){
                    console.log('could not load app');
                });
            },
            function(result){
                console.log('not saved');
                $scope.confirmCourseRegistrationSubmission(result, null, null);
            });
        }, function(result) {
            // rejected - modal was canceled
            $scope.saving = false;
            $scope.savingForLater = false;
        });

        
    }

    //This is the callback function after course registration is submitted
    $scope.confirmCourseRegistrationSubmission = function(result, event, finalized) {
        if(!result) {
            // Error
            errorModalService.openErrorModal('Error submitting Class Registration Form', 'Something went wrong! Please click ok and double check your CRF. Double check that your web browser is up-to-date, all your classes have a Host Institution, and there are no letters in the credit fields. After doing so, please submit your CRF again. If you still have difficulties, please contact IFSA Resident Staff.');
        } 
        else if(result && finalized) {
            // Finalized and submitted
            errorModalService.openErrorModal('Class Registration Form Submitted', 'Thank you for submitting your Class Registration Form! If you make any changes to your schedule after today, please contact IFSA Resident Staff to update your records.');
            $scope.viewModel.isCourseRegEditable = false;                    
        }
        else if(result && !finalized) {
            // Saved for later
            errorModalService.openErrorModal('Class Registration Form Submitted', "Your Class Registration has been saved for later");                 
        }
        $scope.saving = false;
        $scope.savingForLater = false;
    }

    $scope.removeCourse = function(item) {
        let index = $scope.viewModel.courses.findIndex(c => c == item);
        let course = $scope.viewModel.courses[index];
        if(course.courseStatus != 'New')
        {
            var modalInstance = $modal.open({
                animation: true,
                size: 'lg',
                backdrop: 'static',
                templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/CRFAddRemoveModal.html',
                resolve: {
                    data: {title: 'Reason class not taken', course: course, type: 'Remove', reasons: courseRegService.getNotRegisteredReasons() }
                },
                controller: 'crfAddRemoveModalController'
            });

            modalInstance.opened.then(function(){
                setTimeout(function(){resize();}, 500);
            });

            modalInstance.result.then(function(result){
                course = result;
                course.courseStatus = 'Not Registered';
                $scope.viewModel.courses[index] = course;
            }, function(result) {
                // rejected - modal was canceled
            });
        }
        else
        {
            $scope.viewModel.courses.splice($scope.viewModel.courses.indexOf(course), 1);
        }
        
    }

    $scope.registerCourse = function(course){
        let courseIndex = $scope.viewModel.courses.findIndex(c => c.courseId == course.courseId);
        var modalInstance = $modal.open({
            animation: true,
            size: 'lg',
            backdrop: 'static',
            templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/CRFAddRemoveModal.html',
            resolve: {
                data: {title: 'Add class', course: course, type: 'Add', reasons: null, institutions: $scope.viewModel.institutions}
            },
            controller: 'crfAddRemoveModalController'
        });

        modalInstance.opened.then(function(){
            setTimeout(function(){resize();}, 500);
        });

        modalInstance.result.then(function(result){
            course = result;
            course.courseStatus = 'CRF - Draft';
            course.isRegistered = true;
            $scope.viewModel.courses[courseIndex] = course;
        }, function(result) {
            // rejected - modal was canceled
        });
    }

    $scope.submitSyllabus = function(course)
    {
        var modalInstance = $modal.open({
            animation: true,
            templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/SyllabusUploadModal.html',
            resolve: {
                data: course,
            },
            controller: 'syllbusUploadModalController'
        });
        modalInstance.result.then(function(result){
            // resolved - file was uploaded
        }, function(result){
            // rejected - modal was canceled
        })
    }

    $scope.calculateCIFItemsRemaining = function()
    {
        let itemsRemaining = 0;
        for (let index = 0; index < $scope.viewModel.courses.length; index++) {
            const element = $scope.viewModel.courses[index];
            if(element.courseStatus == 'CIF - Submitted') {
                itemsRemaining++;
            }
        }
        return itemsRemaining;
    }
    $scope.generatePDF = function()
    {
        var studentBirthday = dateService.convertDate(new Date($scope.application.Birthday__c));
        var docDefinition = {
            pageMargins: [ 30, 130, 30, 115 ],
            styles: {
                tableHeader: {
                    bold: true,
                    fontSize: 13,
                    color: 'black'
                },
            },
            header: {
                columns: [
                    {
                        image: imageDictionary['logo_with_tagline'],
                        margin: [10, 10]
                    },
                    {
                        alignment: 'right',
                        margin: [10, 10],
                        text: 'Institute for Study Abroad\n6201 Corporate Dr. Suite 200\nIndianapolis, IN, 46278\nPhone: 317-940-9336\nToll Free: 800-858-0229\n Fax: 317-940-9762\nwww.ifsa-butler.org'
                    }
                ]
            },
            footer: [
                {
                    text: 'An official transcript will be issued by Butler University’s Office of Registration and Records, 4600 Sunset Avenue, Indianapolis, IN 46208. In the interim, inquiries about this student’s participation in the program overseas can be directed to the Institute for Study Abroad (317-940-9336).', 
                    margin: [25, 0, 25, 5],
                    fontSize: 10
                },
                {
                    columns: [
                        {text: 'Downloaded Date: ' + new Date().toLocaleDateString(), margin: [25, 15, 25, 5], fontSize: 10, width: '*'},
                        {text: 'Signed:', fontSize: 10, margin: [25, 15, 5, 5], width: 'auto'},
                        {image: imageDictionary['aa_signature'], width: 180, margin: [0, 15, 5, 5]}    
                    ]
                }
            ],
            content: [
                {text: ['Name: ', $scope.application.Student_First_Name__c, ' ', $scope.application.Student_Last_Name__c, ' ID: ', $scope.application.Butler_ID__c, ' DOB: ', studentBirthday.toLocaleDateString(), ' \n']},
                {text: ['US Academic Term: ', $scope.application.Program_Term_Section__c, ' ', $scope.application.Program_Term_Year__c, '\n']},
                {text: ['Host Institution: ', cleanText($scope.application.Host_Institution__c), '\n']},
                {text: ['Home Institution: ', cleanText($scope.application.Home_Institution__c), '\n\n']}
            ]
        };
        var classesTable = {
            table: {
    	        headerRows: 2,
    	        widths: ['*', 225, '*', '*', '*'],
    	        body:[
	                [
                        {
                            border: [false, false, false, false],
							fillColor: '#8C8E8F',
							text: 'Report of Credits Earned for Study Abroad', 
							style: 'tableHeader', 
							colSpan: 5, 
							alignment: 'center'
                            
                        },{},{},{},{}
                    ],
	                [
                        {text: 'Department', style: 'tableHeader', border: [false, false, false, false], fillColor: '#8C8E8F'},
                        {text: 'Course Information', style: 'tableHeader', border: [false, false, false, false], fillColor: '#8C8E8F'},
                        {text: 'Attempted', style: 'tableHeader', border: [false, false, false, false], fillColor: '#8C8E8F'},
                        {text: 'Earned', style: 'tableHeader', border: [false, false, false, false], fillColor: '#8C8E8F'},
                        {text: 'Grade', style: 'tableHeader', border: [false, false, false, false], fillColor: '#8C8E8F'},
                    ]
                ]
            }
        }

        var gradedCourseRegistrations = $filter('gradedCoursesFilter')($scope.viewModel.courses);
        
        for (let index = 0; index < gradedCourseRegistrations.length; index++) {
            const cr = gradedCourseRegistrations[index];
            classesTable.table.body.push(
                [
                    {text: cr.departmentCodeString, border: [false, false, false, false]},
                    {text: cleanText(cr.courseTitle) + ' ' + cleanText(cr.hostInstitutionName) + ' ' +  cr.courseCode, border: [false, false, false, false]},
                    {text: cr.usCredits, border: [false, false, false, false]},
                    {text: cr.usCreditsEarned, border: [false, false, false, false]},
                    {text: cr.courseGrade, border: [false, false, false, false]},
                ]
            );
        }
        docDefinition.content.push(classesTable);
        docDefinition.content.push('\n\n\n');
        var summaryTable = {
            table: {
                headerRows: 1,
                widths: ['*', 'auto', 75,],
                body:[
                    [
                        {border: [false, false, false, false], text:''},{
                            fillColor: '#8C8E8F',
                            text: 'Transcript Summary', 
                            style: 'tableHeader', 
                            colSpan: 2, 
                            alignment: 'center'
                            
                        },{}
                    ],
                    [
                        {border: [false, false, false, false], text:''},
                        {text: 'GPA', alignment: 'right'},
                        {text: $scope.application.Program_GPA__c}
                    ],
                    [
                        {border: [false, false, false, false], text:''},
                        {text: 'Credits Attempted', alignment: 'right'},
                        {text: $scope.application.Credits_Attempted__c}
                    ],
                    [
                        {border: [false, false, false, false], text:''},
                        {text: 'Credits Earned', alignment: 'right'},
                        {text: $scope.application.Credits_Earned__c}
                    ]
                ]
            }
        }
        docDefinition.content.push(summaryTable);
        pdfMake.fonts = {
            Roboto: {
                normal: 'Roboto-Regular.ttf',
                bold: 'Roboto-Bold.ttf',
                italics: 'Roboto-Italic.ttf'
            }
        }
        pdfMake.createPdf(docDefinition).open();
        // var win = window.open('', '_blank');
        // $http.post('/someUrl', data).then( function (response) {
        //     pdfMake.createPdf(docDefinition).open(win);
        // });
    }

    $scope.getNumberOfCourses = function(){
        let itemCount = 0;
        for (let index = 0; index < $scope.viewModel.courses.length; index++) {
            const element = $scope.viewModel.courses[index];
            if(element.courseStatus == 'CIF - Submitted' || element.courseStatus == 'CRF - Draft' || element.courseStatus == 'New') {
                itemCount++;
            }
        }
        return itemCount;
    }
    function cleanText(value) {
        value = $filter('apostraphe')(value);
        value = $filter('ampersand')(value)
        return value;
    }

    $scope.init();
});