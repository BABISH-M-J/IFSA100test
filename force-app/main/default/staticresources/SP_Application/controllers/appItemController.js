/**
 * Student Portal Application Item Controller
 * @file Student Portal Application Item Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('appItemController', function ($scope, $filter, $routeParams, dynamicFormService, $sce, viewModel, urlService, $modal, sanitizer, $location, dateService, applicationItemService, errorModalService, browserDetectService) {
    var data = null;
    
    $scope.init = function(data) {
        $scope.data = data;
        $scope.portal = 'studentportal';
        let vm = viewModel.getViewModel();
        $scope.data.studentFirstName = vm.studentPreferredName != null && vm.studentPreferredName != undefined ? vm.studentPreferredName : vm.studentFirstName
        $scope.form = {};
        $scope.directions = $scope.data.directions;
        if($scope.data.fastFormsTemplateID && $scope.data.fastFormsURL != null)
        {
            //$scope.data.fastFormsHTML = "<script type=\"text/javascript\" id=\"jsFastForms\" src=\"" + $scope.data.fastFormsURL + "\"><\/script>"
            $scope.data.fastFormsHTML = "<iframe width=\"100%\" height=\"400px\" frameborder=\"0\" src=\"" + $scope.data.fastFormsURL + "\" />"
            $scope.data.fastFormsHTML = $sce.trustAsHtml($scope.data.fastFormsHTML);
        }
        else if($scope.data.fastFormsTemplateID && $scope.data.fastFormsURL == null)
        {
            $scope.data.fastFormsHTML = "<p>Sorry for the inconvenience but this form could not be loaded at this time. Please try again later. If you continue to receive this error, please contact IFSA</p>";
            $scope.hideSubmitButtons = true;
            $scope.data.fastFormsHTML = $sce.trustAsHtml($scope.data.fastFormsHTML);
        }
        else
        {
            $scope.data.fastFormsHTML = null;
        }
        $scope.editContact = $scope.data.emptyContact;
        try 
        {
            $scope.data.contentLink = ($scope.data.contentLink != null) ? $scope.data.contentLink.replace(/amp;/g, '') : null;
        }
            catch(err) 
        {
            //do nothing
        }
        $scope.submitWithoutCompletion = false;
        $scope.appItemTitle = data.name + ' - ' + data.status;
        $scope.data.independentFlights = [];
        $scope.data.selectedTravel = '';
        
        if($scope.data.recordType == "Travel_Plan")
        {
            try {
                $scope.data.arrivalDate = new Date($scope.data.arrivalDate);
                $scope.data.arrivalDate.setDate($scope.data.arrivalDate.getDate() + 1);
                $scope.data.arrivalDate.setHours(0);
                $scope.data.arrivalDate.setMinutes(0);
                $scope.data.arrivalDate.setSeconds(0);
                $scope.data.arrivalDate.setMilliseconds(0);

                $scope.data.arrivalDatePlus1 = new Date($scope.data.arrivalDate);
                $scope.data.arrivalDatePlus1 = new Date($scope.data.arrivalDatePlus1.setDate($scope.data.arrivalDatePlus1.getDate() + 1));
                $scope.data.arrivalDatePlus30 = new Date($scope.data.arrivalDate);
                $scope.data.arrivalDatePlus30 = new Date($scope.data.arrivalDatePlus30.setMonth($scope.data.arrivalDatePlus30.getMonth() + 1));
                $scope.dateOptions = {
                    formatYear: 'yy',
                    startingDay: 1
                };
                $scope.commonDirections = vm.portalSettings.find(s => s.DeveloperName == 'SP_Travel_Plan_Common_Instructions')["Content__c"];
                var broswerName = browserDetectService.getBrowserName();
                $scope.useNativeDateAndTimePicker = true;
                if(broswerName == 'safari' || broswerName == 'ie'){
                    $scope.useNativeDateAndTimePicker = false;
                }
            } catch (error) {
                console.log(error);
                $scope.data.arrivalDate = null;
            }
        }
        if($scope.data.recordType == 'Learning_Plan' && !vm.isCustom)
        {
            $scope.learningPlanDisclosureSet = $scope.data.isComplete;
        }
        else if($scope.data.recordType == 'Learning_Plan' && vm.isCustom)
        {
            $scope.learningPlanDisclosureSet = true;
            $scope.data.learningPlanDisclosure = 'Yes';
        }
        $scope.data.passportDataSubmitted = $scope.data.status == 'Completed';
        $scope.evalWaived = null;
        if($scope.data.eContactFirstName != null)
        { $scope.data.lockContact1 = $scope.data.eContactFirstName.length > 0; }
        if($scope.data.eContact2FirstName != null)
        { $scope.data.lockContact2 = $scope.data.eContact2FirstName.length > 0; }		
        if($scope.data.name.match("Transcript")) {
            $scope.data.isTranscript = true;
        } else {
            $scope.data.isTranscript = false;
        }
        if($scope.data.recordType == 'No_Action' && $scope.data.name == 'Advising Call')
        {
            $scope.data.isComplete = false;
            $scope.data.status = 'Started';
        }
        if($scope.data.recordType == 'Spanish_Language_Evaluation' && !$scope.data.evaluatorName && !$scope.data.evaluatorEmail)
        {
            $scope.data.showSubmitEvalButton = true;
        }
        if($scope.data.recordType == 'Personal_Essay' && $scope.data.status == 'Started' && $scope.data.content)
        {
            // Parse through $scope.data.content to get the personal essay questions and responses to populate fields
            // Each personal essay question is surrounded by "<b></b> tags and responses are surrounded by "<br/>" tags

            var questionLabel = $scope.data.essayQuestions[0].language == 'English' ? "English Question " : "Spanish Question ";
            var questionName = $scope.data.essayQuestions[0].language == 'English' ? "English_Question_" : "Spanish_Question_";
            $scope.data.essayQuestions = [];
            $scope.data.content = $scope.data.content.replace(/&lt;p&gt;/g, "");
            $scope.data.content = $scope.data.content.replace(/&lt;&#47;p&gt;/g, "");
            $scope.data.content = $scope.data.content.replace(/&lt;/g, "<");
            $scope.data.content = $scope.data.content.replace(/&gt;/g, ">");
            var qsAndAs = $scope.data.content.split("<br><br>");
            qsAndAs.pop();
            var counter = 1;

            angular.forEach(qsAndAs, function(QandA){
                var text = QandA.split("</b><br>");
                $scope.data.essayQuestions.push(
                    {
                        label: questionLabel + counter,
                        name: questionName + counter,
                        language: "English",
                        question: text[0].replace("<b>", "").replace("</b>", "").replace("<br>", ""),
                        response: text[1]
                    }
                );
                counter = counter + 1;
            });

        }
        if($scope.recordType == 'Addresses')
        {
            $scope.updateEmergencyContacts();
        }
        if($scope.data.recordType == "Learning_Plan")
        {
            $scope.data.status = "Complete";
        }   
        $scope.flights = [];
        if($scope.data.directoryOptOutStatus == 'Released') {
            $scope.directoryOptOut = true;
        } else {
            $scope.directoryOptOut = false;
        }
        // Pasport_Copy
        $scope.data.passportDataSubmitted = $scope.data.status == 'Completed';
        if($scope.data.recordType == 'Passport_Copy') {
            $scope.additionalInstructions = vm.portalSettings.find(s => s.DeveloperName == 'SP_Passport_Additional_Instructions')["Content__c"];
            $scope.additionalDoNotHaveOrRenewalInstructions = vm.portalSettings.find(s => s.DeveloperName == 'SP_Passport_Add_Do_Not_Have_Instruct')["Content__c"];
            if($scope.data.passportNumber && $scope.data.passportCountry && $scope.data.passportExpirationDate){
                $scope.data.passportReadyForUpload = true;
            }
            // Set Passport Expiration Date
            if($scope.data.passportExpirationDate != null) {
                $scope.data.expirationDate = dateService.convertDate($scope.data.passportExpirationDate);
            }
        } 
        else {
            $scope.data.passportExpirationDate = null;
        }
        $scope.flights = [];
        if($scope.data.directoryOptOutStatus == 'Released') {
            $scope.directoryOptOut = true;
        } else {
            $scope.directoryOptOut = false;
        }
        $scope.datePickerOpen = false;

        $scope.openDatepicker = function($event) {
            $scope.datePickerOpen = true;
        };
        for(i=0;i<$scope.data.recommendations.length;i++) {
            $scope.data.recommendations[i].recommendationUrl = $scope.data.recommendations[i].recommendationUrl.replace('amp;','');
        }
        if($scope.data.courses == null) {
            $scope.data.courses = [];
        }
        if($scope.isComplete == null) {
            $scope.isComplete = $scope.data.appItemStatus == 'Complete';
        }
        if(!$scope.isComplete) {
            $scope.viewModel = vm;
        }
        $scope.loadingGif = urlService.getLoadingGifURL();
        $scope.submittingData = false;
        $scope.errorMessage = '';
        $scope.file = null;
        if($scope.data.textToSign != null) {
            $scope.data.textToSign = sanitizer.trustHtml($scope.data.textToSign);
        }
        if($scope.data.directions != null) {
            $scope.data.directions = sanitizer.trustHtml($scope.data.directions);
        }			
        if($scope.data.content != null) {
            $scope.data.content = sanitizer.trustHtml($scope.data.content);
        }
        for(var i = 0; i < $scope.data.housingOptions.length; i++) {	
            if($scope.data.housingOptions[i].Description != null) {
                $scope.data.housingOptions[i].Description = sanitizer.trustHtml($scope.data.housingOptions[i].Description);
            }
        }
        $scope.numberOfHousingPrefs = $scope.data.housingOptions.length > 5 ? 5 : $scope.data.housingOptions.length;

        if($scope.data.housingOptions.length < 2)
        {
            if($scope.data.housingOptions.length > 0)
                {
                    $scope.data.housingOptions[0].Rank = $scope.data.housingRankOptions[0];
                }
            $scope.housingPrefsComplete = true;
        }
        if($scope.data.recordType == 'Download_Upload' && $scope.data.contentLink.indexOf('amp;') != -1)
        {
            var link = $scope.data.contentLink.replace(/amp;/g, '');
            $scope.data.contentLink = link;
        }
        $scope.loading = false;
    }

    $scope.dismissError = function() {
        $scope.errorMessage = '';
    }

    $scope.calculateNumRankedHousing = function(option)
    {
        $scope.numberOfSelectedHousingPrefs = 0;
        for(var i = 0; i < $scope.data.housingOptions.length; i++) {    
            if($scope.data.housingOptions[i].Rank) {
                $scope.numberOfSelectedHousingPrefs = $scope.numberOfSelectedHousingPrefs + 1;       
            }
        }
        
        $scope.housingPrefsComplete = $scope.numberOfSelectedHousingPrefs >= $scope.numberOfHousingPrefs;
    }

    //Start Addresses and Contacts
    if($scope.data && $scope.data.emergencyContacts && $scope.data.emergencyContacts.length) {
        $scope.sameAsHomeAddress = false;
        $scope.updateEmergencyContacts();
    }
    

    $scope.cancelNewContact = function() {
        $scope.data.sameAsHomeAddress = false;
        $scope.data.showAddContactForm = false;
        $scope.data.noEmail = false;
        $scope.data.editContact = {
            relationshipWithStudent: '',
            mailingStreet: '',
            mailingCity: '',
            mailingState: '',
            mailingZip: '',
            mailingCountry: '',
            isEmergencyContact: false,
            sendMarketingMaterials: false
        };
    }

    $scope.updateEmergencyContacts = function () {
        $scope.data.emergencyContacts = 0;	
        angular.forEach($scope.data.relatedContacts, function(c){
            if(c.isEmergencyContact)
            {
                $scope.data.emergencyContacts = $scope.data.emergencyContacts+1;
            }
        });
    }

    $scope.numberOfEmergencyContacts = function() {
        var count = 0;
        if($scope.data && $scope.data.relatedContacts) {
            angular.forEach($scope.data.relatedContacts, function(c){
                if(c.isEmergencyContact)
                {
                    count = count+1;
                }
            });
        }
        return count;
    }

    $scope.addContact = function() {
        $scope.data.editContact.isInvalid = false;
        if(!$scope.data.isEditMode)
        {
            $scope.data.relatedContacts.push($scope.data.editContact);
        }

        $scope.updateEmergencyContacts();
        
        $scope.data.editContact = {
            relationshipWithStudent: '',
            mailingStreet: '',
            mailingCity: '',
            mailingState: '',
            mailingZip: '',
            mailingCountry: '',
            isEmergencyContact: false,
            sendMarketingMaterials: false

        };
        $scope.data.noEmail = false;
        $scope.data.sameAsHomeAddress = false;
        $scope.data.showAddContactForm = false;
        $scope.data.isEditMode = false;
    }

    $scope.editExistingContact = function(contact) {
        $scope.data.isEditMode = true;
        $scope.data.editContact = contact;
        $scope.data.showAddContactForm = true;
    }

    $scope.deleteContact = function(contact) {
        $scope.data.relatedContacts.splice($scope.data.relatedContacts.indexOf(contact) ,1);
        $scope.updateEmergencyContacts();
    }

    $scope.toggleDoNotContact = function() {
        if($scope.data.doNotContact){
            $scope.data.doContact = false;
        }
    }
    $scope.toggleDoContact = function() {
        if($scope.data.doContact){
            $scope.data.doNotContact = false;
        }
    }
    $scope.toggleParentHomeAddress = function() {
        //$scope.sameAsHomeAddress = !$scope.sameAsHomeAddress;
        if($scope.data.sameAsHomeAddress) {
            $scope.data.editContact.mailingStreet = $scope.data.mailingStreet;
            $scope.data.editContact.mailingCity = $scope.data.mailingCity;
            $scope.data.editContact.mailingState = $scope.data.mailingState;
            $scope.data.editContact.mailingPostalCode = $scope.data.mailingZip;
            $scope.data.editContact.mailingCountry = $scope.data.mailingCountry;
        } else {
            $scope.data.editContact.mailingStreet = '';
            $scope.data.editContact.mailingCity = '';
            $scope.data.editContact.mailingState = '';
            $scope.data.editContact.mailingPostalCode = '';
            $scope.data.editContact.mailingCountry = '';
        }
    }
    $scope.toggleOtherHomeAddress = function() {
        if($scope.data.sameOtherAddress) {
            $scope.data.otherStreet = $scope.data.mailingStreet;
            $scope.data.otherCity = $scope.data.mailingCity;
            $scope.data.otherState = $scope.data.mailingState;
            $scope.data.otherZip = $scope.data.mailingZip;
            $scope.data.otherCountry = $scope.data.mailingCountry;
        } else {
            $scope.data.otherStreet = '';
            $scope.data.otherCity = '';
            $scope.data.otherState = '';
            $scope.data.otherZip = '';
            $scope.data.otherCountry = '';
        }
    }
    $scope.toggleBillingHomeAddress = function() {
        if($scope.data.sameBillingAddress) {
            $scope.data.billingStreet = $scope.data.mailingStreet;
            $scope.data.billingCity = $scope.data.mailingCity;
            $scope.data.billingState = $scope.data.mailingState;
            $scope.data.billingZip = $scope.data.mailingZip;
            $scope.data.billingCountry = $scope.data.mailingCountry;
        } else {
            $scope.data.billingStreet = '';
            $scope.data.billingCity = '';
            $scope.data.billingState = '';
            $scope.data.billingZip = '';
            $scope.data.billingCountry = '';
        }
    }
    //End Addresses and Contacts
    //Start Travel and Flights
    $scope.getFlights = function() {
        portalRemotingMethods.getTravelDetails(
            $scope.data.selectedTravel,
            function(result, event) {
                if(event.result) {
                    $scope.flights = result;
                    $scope.$apply();
                }
            }
        );
    }

    $scope.addFlight = function() {
        let today = new Date();
        today.setHours(0);
        today.setMinutes(0);
        today.setSeconds(0);
        today.setMilliseconds(0);
        let flight = {
            arrivalDatePart: today,
            arrivalTimePart: today,
            departureDatePart: today,
            departureTimePart: today,
            type: 'Outgoing'
        }
        $scope.data.independentFlights.push(flight);
    }

    $scope.removeFlight = function(index) {
        var flight = $scope.data.independentFlights[index];
        $scope.data.independentFlights.splice( $scope.data.independentFlights.indexOf(flight), 1);
    }

    $scope.submitIndependentFlights = function() {
        $scope.submittingData = true;
        var submitFlights = false;
        for(let i = 0; i < $scope.data.independentFlights.length; i++)
        {
            const flight = $scope.data.independentFlights[i];
            flight.departureTime = flight.departureDatePart;
            flight.departureTime.setHours(flight.departureTimePart.getHours());
            flight.departureTime.setMinutes(flight.departureTimePart.getMinutes());
            flight.arrivalTime = flight.arrivalDatePart;
            flight.arrivalTime.setHours(flight.arrivalTimePart.getHours());
            flight.arrivalTime.setMinutes(flight.arrivalTimePart.getMinutes())
            if( flight != null && flight.flightNumber != null && flight.Departure_Airport_Code__c != null
                && flight.departureTime && flight.Arrival_Airport_Code__c && flight.arrivalTime)
                {
                    submitFlights = true;
                }
                else
                {
                    submitFlights = false;
                }
        }
        if( submitFlights == true)
        {
            var promise = applicationItemService.submitIndependentTravel(
                $scope.data.travelPlanInfo,
                $scope.data.independentFlights,
                $scope.data.id
            );
            promise.then(function(result){
                $scope.changeData(result);
                $scope.isComplete = true;
                //$modalInstance.dismiss('complete');
                window.location.assign('#/');
                $scope.$apply();
            },function(result){
                errorModalService.openErrorModal('An Error has occured submitting your form', 'There was an error submitting your form. ' +  result.message + ' Please try again. If you continue to have problems, contact IFSA.');
                $scope.submittingData = false;
            })
        }
        else
        {
            $scope.submittingData = false;
            $scope.$apply();
        }
    }
    //End Travel and Flights
    //Start Scholarships			
    if($scope.data) {
        $scope.data.aidList = [];
    }
    $scope.addAid = function() {
        $scope.data.aidList[$scope.data.aidList.length] = {
            aidType: '',
            disbursmentAmount: 0,
            disbursmentDate: new Date()
        };
    }
    $scope.removeAid = function(index) {
        var aid = $scope.data.aidList[index];
        $scope.data.aidList.splice( $scope.data.aidList.indexOf(aid), 1);
    }
    //End of Scholarships
    $scope.submitSignature = function() {
        var canvas = document.getElementById("signature");
        canvas.toBlob(function(blob) {
              $scope.file = blob;
            $scope.submitAttachment();
        });
    }
    $scope.submitRecommender = function() {
        $scope.submittingData = true;
        $scope.errorMessage = '';
        portalRemotingMethods.submitRecommender(
            $scope.form.recommenderName,
            $scope.form.recommenderEmail,
            $scope.data.id,
            function(result, event) {
                $scope.submittingData = false;
                if(event.message != '' && event.message != null) {
                    alert(event.message);
                } else {
                    $scope.recommenderSubmitted = true;
                    $scope.data.recommendations.push({
                        recommenderName : $scope.form.recommenderName,
                        recommendationStatus : 'Incomplete',
                        recommenderEmail : $scope.form.recommenderEmail,
                        recommendationUrl : ''
                    });
                    $scope.form.recommenderName = '';
                    $scope.form.recommenderEmail = '';
                }
                $scope.$apply();
            }
        );
    }
    $scope.minify = function(data) {
        var keys = Object.keys(data);
        for(i = 0; i < keys.length; i++) {
            if(keys[i].indexOf("housingRankOptions") == -1) {
                if(keys[i].indexOf("Options") > -1 || data[keys[i]] === null || data[keys[i]] === false) {				
                    delete data[keys[i]];
                }
            }
        }
        return data;
    }
    $scope.submitAttachment = function() {
        $scope.submittingData = true;
        $scope.errorMessage = '';
        var item;
        for (item in $scope.data.aidList)
        {
            
        }        
        $scope.data.FASFA = ($scope.data.FASFA == 'true');
        if($scope.file != null && $scope.file.size > 2048000) {
            $scope.errorMessage = 'The file must be less than 2 MB.';
            $scope.submittingData = false;
            return;
        } else if($scope.file != null) {
            var reader = new FileReader();
            reader.onloadend = function() {
                if($scope.directoryOptOut && $scope.data.recordType == 'Agreements_and_Releases') {
                    $scope.data.directoryOptOutStatus = 'Withheld';
                } else if($scope.data.recordType == 'Agreements_and_Releases') {
                    $scope.data.directoryOptOutStatus = 'Released';
                }
                $scope.data.File = reader.result;
                $scope.data.textToSign = sanitizer.untrustHtml($scope.data.textToSign);
                $scope.data.directions = sanitizer.untrustHtml($scope.data.directions);
                $scope.data.content = sanitizer.untrustHtml($scope.data.content);
                if($scope.file.name == null) {
                    $scope.file.name = 'a.png'
                }
                if($scope.form.recommendationWaived != null && $scope.form.recommendationWaived != '') {
                    $scope.data.recommendationWaived = $scope.form.recommendationWaived;
                }
                if($scope.form.evalWaived != null && $scope.form.evalWaived != '') {
                    $scope.data.evalWaived = $scope.form.evalWaived;
                }
                for(var i = 0; i < $scope.data.housingOptions.length; i++) { 
                    if($scope.data.housingOptions[i].Description != null) {
                          $scope.data.housingOptions[i].Description = '';
                     }
                }
                var dataToSubmit;
                if($scope.data.recordType == "Housing_Preferences_Form")
                {
                    dataToSubmit = angular.toJson($scope.data);
                }
                else
                {
                    dataToSubmit = angular.toJson($scope.minify($scope.data));
                }                        
                portalRemotingMethods.submitApplicationItem(
                    dataToSubmit,
                    '',
                    '',
                    '',
                    function(result, event) {
                        if(event.result) {
                            portalRemotingMethods.submitSignature($scope.data.id, 
                                $scope.data.name, 
                                $scope.data.File.split(',')[1],  
                                $scope.file.type,
                                $scope.file.name,
                                function(result, event) {
                                    $scope.changeData(result);
                                    $scope.submittingData = false;
                                    $scope.isComplete = true;
                                    if(!$scope.data.isStarted)
                                        //$modalInstance.dismiss('complete');
                                        window.location.assign('#/');
                                    $scope.viewModel.appItemsIncomplete = $scope.viewModel.appItemsIncomplete - 1;
                                    $scope.$apply();
                                    if($scope.viewModel.appItemsIncomplete < 1 && $scope.viewModel.status == 'Program Selected') {
                                        $scope.showCompletionNotification($scope.viewModel.completionNotificationReceived);
                                    }
                                }
                            );
                        } else if(event.message != null && event.message.indexOf('Input too long') != -1) {
                            alert('Error: The file was too big. Please select another file for upload.');
                            $scope.submittingData = false;
                            $scope.$apply();									
                        } else if($scope.data.recordType == 'Recommendation' || $scope.data.recordType == 'Spanish_Language_Evaluation') {
                            $scope.data.status = 'Started';
                            $scope.data.isStarted = true;
                            $scope.data.showSubmitEvalButton = ($scope.data.recordType == 'Spanish_Language_Evaluation') ? true : false;
                            for(i = 0; i < $scope.viewModel.appItems.length; i++) {
                                if($scope.viewModel.appItems[i].id == $scope.data.id) {
                                    $scope.viewModel.appItems[i] = $scope.data;
                                }
                            }
                            $scope.submittingData = false;
                            $scope.$apply();
                        } else {
                            //$modalInstance.dismiss('complete');
                            window.location.assign('#/');
                            $scope.$apply();
                        }
                    }
                );
            }
            reader.readAsDataURL($scope.file);
        }
    }
    $scope.addCourse = function() {
        $scope.data.courses.push({'Id' : null, 'courseName' : '', 'courseCode' : ''});
    }
    $scope.submitEvaluator = function() {
        $scope.submittingData = true;
        $scope.errorMessage = '';
        $scope.data.directions = '';
        portalRemotingMethods.submitApplicationItem(
            angular.toJson($scope.data),
            '',
            '',
            '',
            function(result, event) {
                if(result)
                {
                    $scope.data.status = 'Started';
                    $scope.data.isStarted = true;
                    for(i = 0; i < $scope.viewModel.appItems.length; i++) {
                        if($scope.viewModel.appItems[i].id == $scope.data.id) {
                            $scope.viewModel.appItems[i] = $scope.data;
                        }
                    }						
                    $scope.submittingData = false;
                    //$modalInstance.dismiss('complete');
                    window.location.assign('#/');
                    //$scope.viewModel.appItemsIncomplete = $scope.viewModel.appItemsIncomplete - 1;
                    $scope.$apply();
                    if($scope.viewModel.appItemsIncomplete < 1 && $scope.viewModel.status == 'Program Selected') {
                        $scope.showCompletionNotification($scope.viewModel.completionNotificationReceived);
                    }
                }
                else
                {
                    alert('An error has occured submitting your form, please try again later');
                    $scope.submittingData = false;
                    //$modalInstance.dismiss('complete');
                    window.location.assign('#/');
                    //$scope.viewModel.appItemsIncomplete = $scope.viewModel.appItemsIncomplete - 1;
                    $scope.$apply();
                }
            }
        );
    }
    $scope.closeModal = function() {
        //$modalInstance.dismiss('complete');
        window.location.assign('#/');
    }

    function checkEmail(emailAddress) {
        var email = emailAddress;
        var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        try {
            if (!filter.test(email)) {
                return false;
            }
            return true;
        }
        catch(err) {
            return false;
        }
        
    }
    $scope.saveForLater = function(){
        $scope.submitWithoutCompletion = true;
        $scope.submit();
    }

    $scope.submit = function() {
        if($scope.file != null) {
            $scope.submitAttachment();
            return;
        }
        if($scope.data.recordType == "Update_Emergency_Contact")
        {                    
            var emailCounter = 0;
            angular.forEach($scope.data.relatedContacts, function(value){
                if(checkEmail(value.email))
                {
                    emailCounter = emailCounter + 1;                            
                }
            });
            if(emailCounter < 1)
            {
                $scope.data.directions = '<span class="text-danger">ERROR: Please ensure that your emergency contact\'s information is up to date. You must have at least one contact with an email address to submit the form.</span>'
                return;
            }
        }
        if($scope.data.expirationDate != null) {
            $scope.data.passportExpirationDate = $scope.data.expirationDate.getFullYear() + '-' + ($scope.data.expirationDate.getMonth() + 1) + '-' + $scope.data.expirationDate.getDate();
        }
        if($scope.data.recordType == 'Personal_Essay' || $scope.data.recordType == 'No_Action' && $scope.data.isTranscript)
        {
            $scope.data.status = !$scope.submitWithoutCompletion ? 'Complete' : 'Started';
            if($scope.data.recordType == 'Personal_Essay')
            {
                $scope.data.content = '';
            angular.forEach($scope.data.essayQuestions, function(q){
                var responseText = q.response != null ? q.response : "";
                $scope.data.content = $scope.data.content + '<b>' + q.question + '</b><br/>' + responseText  + '<br/><br/>';
            });
            }
        }                
        $scope.submittingData = true;
        $scope.errorMessage = '';
        // BBARLOW 2/16 The PAs do not like that the directions are cleared out when a non-signature item is saved
        $scope.data.directions = $scope.directions;
        for(var i = 0; i < $scope.data.housingOptions.length; i++) {	
            if($scope.data.housingOptions[i].Description != null) {
                $scope.data.housingOptions[i].Description = '';
            }
        }
        
        if($scope.data.isTranscript)
        {
            $scope.data.status = 'Started';
        }
        
        $scope.data.FASFA = ($scope.data.FASFA == 'true');
        if(!$scope.data.fastFormsURL)
        {
            var promise = applicationItemService.submitApplicationItem(angular.toJson($scope.data), '', '', '');
            promise.then(function(result) {
                $scope.changeData(result);
            },
            function(result){
                $scope.submittingData = false;
                errorModalService.openErrorModal('An Error has occured submitting your form', 'There was an error submitting your form. Please try again. If you continue to have problems, contact IFSA.');
                window.location.assign('#/');
            });
        }
        else
        {
            //$modalInstance.dismiss('complete');
            window.location.assign('#/');
        }
        
    }			
    $scope.changeData = function(result) {
        if(result && ($scope.submitWithoutCompletion || ($scope.data.recordType == 'Spanish_Language_Evaluation' && !$scope.data.evaluatorEmail && !$scope.data.evaluatorName && $scope.data.evalWaived != 'Not Selected')
           || ($scope.data.recordType == 'Recommendation' && $scope.data.recommendations.length == 0 && $scope.data.recommendationWaived != 'Not Selected')
           || ($scope.data.recordType == 'Personal_Essay' && $scope.data.status == 'Started'))) {
            $scope.data.status = 'Started';
            $scope.data.isStarted = true;				
        } else if(result && ($scope.data.recordType != 'Passport_Copy') || ($scope.data.recordType == 'Spanish_Language_Evaluation' && $scope.data.evaluatorEmail && $scope.data.evaluatorName) || ($scope.data.recordType == 'Recommendation' && $scope.data.recommendations.length > 0)) {
            $scope.data.isComplete = true;
            $scope.data.status = 'Complete';
            $scope.data.isStarted = false;
            $scope.viewModel.appItemsIncomplete = $scope.viewModel.appItemsIncomplete - 1;
        } else if($scope.data.isTranscript) {
            $scope.data.status = 'Started';
            $scope.data.isStarted = true;
        //FF Issue workaround 8-1-2016 Brock Barlow
        /*} else if($scope.data.recordType == 'Addresses' && $scope.data.hasAccountTradingCurrency) {
            $scope.data.isStarted = true;
            $scope.data.status = 'Started'; */
        } else if($scope.data.recordType == 'Passport_Copy' && ($scope.data.passportInRenewal || $scope.data.passportDoNotHave)) {
            $scope.data.status = 'Started';
            $scope.data.isStarted = true;
            $scope.data.passportDataSubmitted = false;
         } else if($scope.data.recordType == 'Passport_Copy' && (!$scope.data.passportInRenewal || !$scope.data.passportDoNotHave)) {
            $scope.data.passportDataSubmitted = true;					
        }
        $scope.submittingData = false;
        if(($scope.data.recordType != 'Passport_Copy' && $scope.data.recordType != 'Recommendation' && $scope.data.recordType != 'Spanish_Language_Evaluation' ) 
           || ($scope.data.recordType == 'Passport_Copy' && ($scope.data.passportInRenewal || $scope.data.passportDoNotHave))
           || ($scope.data.recordType == 'Spanish_Language_Evaluation' && $scope.data.evaluatorEmail != null && $scope.data.evaluatorName != null)
           || ($scope.data.recordType == 'Recommendation' && $scope.data.recommendations.length > 0)){
            //$modalInstance.dismiss('complete');
            window.location.assign('#/');
        }
        for(i = 0; i < $scope.viewModel.appItems.length; i++) {
            if($scope.viewModel.appItems[i].id == $scope.data.id) {
                $scope.viewModel.appItems[i] = $scope.data;
            }
        }
        if($scope.viewModel.appItemsIncomplete < 1 && $scope.viewModel.status == 'Program Selected') {
            $scope.showCompletionNotification($scope.viewModel.completionNotificationReceived);
        }
    }
    $scope.showCompletionNotification = function(showPopup) {
        if(!showPopup) {
            studentApplicationController.closeCompletionNotification(
                $scope.viewModel.applicationId, 
                function(result){
                    if(result)
                    {
                        $scope.viewModel.applicationStatus = 'Ready To Submit';
                        var modalInstance = $modal.open({
                            animation: true,
                            size: 'lg',
                            templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/HTML_AppItemsCompleteModal.html',
                            resolve: {
                            },
                            controller: 'appItemsCompleteController'
                        });
                    }
                });
        }
    }
    $scope.expirationChanged = function() {
        $scope.data.passportInRenewal = false;
    }

    // Load app item details from Salesforce
    $scope.loading = true;
    var promise = applicationItemService.getApplicationItemDetails($routeParams.appItemId);
    promise.then(function(result){
        $scope.init(result);
        setTimeout(function(){resize();}, 500);
    },
    function(result){
        var promise = errorModalService.openErrorModal('An Error has occured loading your applicaiton item', 'There was an error loading your your applicaiton item. Please try again. If you continue to have problems, contact IFSA.');
        promise.then(function(result){
            $scope.loading = false;
            window.location.assign('#/');
        });
    });

    $scope.saveDynamicForm = function() {
        $scope.submittingData = true;
        var promise = dynamicFormService.submitDynamicForm($scope.data.form, $scope.data.name);
            promise.then(function(result) {
                $scope.changeData(result);
            },
            function(result){
                var promise = errorModalService.openErrorModal('An Error has occured submitting your form', 'There was an error submitting your form. Please try again. If you continue to have problems, contact IFSA.');
                promise.then(function(result){
                    $scope.submittingData = false;
                    window.location.assign('#/');
                });
            });
    }
    $scope.processRules = function(controlFormItem) {
        dynamicFormService.processRules(controlFormItem);
    }

    $scope.getFirstName = function(){
        return $scope.viewModel.studentPreferredName != null && $scope.viewModel.studentPreferredName != undefined ? $scope.viewModel.studentPreferredName : $scope.viewModel.studentFirstName
    }

    $scope.disableSignatureSubmit = function(sigPad){
        if(sigPad && !sigPad._isEmpty){
            switch ($scope.data.recordType) {
                case 'Spanish_Language_Evaluation':
                    return !$scope.form.evalWaived;
                case 'Recommendation':
                    return !$scope.form.recommendationWaived;
                case 'Housing_Preferences_Form':
                    return !$scope.housingPrefsComplete;
                default:
                    return false;
            }            
        }
        return true;
    }
});