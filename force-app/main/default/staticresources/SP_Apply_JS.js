var applyApp = angular.module('applyApp', ['ui.bootstrap','textAngular','ngFileUpload','ngSignaturePad','ngSanitize','htmlSafe','ui.bootstrap.datetimepicker','ui.dateTimeInput','ui.mask']);
		applyApp.controller('applyController', function($scope, $modal, viewModel, urlService, sanitizer) {
			//datepicker
			var validViews = ['year', 'month', 'day', 'hour', 'minute'];
    		var selectable = true;
    		//datepicker
    		$scope.departureOnSetTime = departureOnSetTime;
    		$scope.arrivalOnSetTime = arrivalOnSetTime;
			$scope.viewModel = viewModel.getViewModel();			
			$scope.addScholarship = function (appId) {
				window.location.assign($scope.viewModel.scholarshipURL);
				portalRemotingMethods.addScholarshipItem(
					appId, 
					function(result, event) {
						$scope.scholarshipItemAdded(result, event);
					}
				);				
			}
			$scope.scholarshipItemAdded = function(result, event) {
				if(result != null)
				{					
					$scope.viewModel.appItems.push(result);
					$scope.viewModel.hasScholarship = true;
					$scope.$apply();
				}
			}

			$scope.viewAppItem = function (item) {
				portalRemotingMethods.getApplicationItemDetails(
					item.id, 
					function(result, event) {
						$scope.loadAppItem(result, event, item.name);
					}
				);
			}			
			$scope.loadAppItem = function(result, event, itemName) {				
				if(result != null)
				{
					result.pageSource = 'SP_Apply';
	                result.PortalSource = 'studentportal';
					var modalInstance = $modal.open({
				    	animation: true,
						size: 'lg',
						templateUrl: urlService.getAppItemModalURL(),
						resolve: {
		        			data: result
		      			},
						controller: 'appItemController'
					});
					modalInstance.opened.then(function(){
						setTimeout(function(){resize();}, 500);
					});	
				}
				else
				{
					var modalInstance = $modal.open({
				    	animation: true,
						size: 'lg',
						templateUrl: urlService.getAppItemErrorURL(),
						resolve: {
		        			data: null
		      			},
						controller: 'appItemErrorController'
					});
					modalInstance.opened.then(function(){
						setTimeout(function(){resize();}, 500);
					});	
				}
			}
		});
		applyApp.controller('appItemErrorController', function ($scope, $modalInstance, data, Upload, $timeout, $sce, viewModel, $modal, sanitizer, $location) {
			//$scope.itemName = data;
		});

		applyApp.controller('appItemController', function ($scope, $modalInstance, data, Upload, $timeout, $sce, viewModel, urlService, $modal, sanitizer, $location) {
			$scope.data = data;
			$scope.directions = $scope.data.directions;
			//<script type='text/javascript' id='jsFastForms' src='https://fastforms.visualantidote.com/FormEngine/Scripts/Main.js?d=K1NUc9g6m92zL6LWZnihTgKM%2b5s%2b33aNsTAjdKZ8x7271yvqEOXFA48ZbRTdh2kw' />
			if($scope.data.fastFormsURL != null)
			{
				//$scope.data.fastFormsHTML = "<script type=\"text/javascript\" id=\"jsFastForms\" src=\"" + $scope.data.fastFormsURL + "\"><\/script>"
				$scope.data.fastFormsHTML = "<iframe width=\"100%\" height=\"400px\" frameborder=\"0\" src=\"" + $scope.data.fastFormsURL + "\" />"
				$scope.data.fastFormsHTML = $sce.trustAsHtml($scope.data.fastFormsHTML);
			}
			else
			{
				$scope.data.fastFormsHTML = null;
			}
			$scope.editContact = $scope.data.emptyContact;
			$scope.data.contentLink = ($scope.data.contentLink != null) ? $scope.data.contentLink.replace(/amp;/g, '') : null;
			$scope.submitWithoutCompletion = false;
			$scope.appItemTitle = data.name + ' - ' + data.status;
			$scope.data.independentFlights = [];
			if($scope.data.recordType == "Travel_Plan")
            {
				$scope.data.arrivalDate = $scope.data.arrivalDate.replace(/\//g, '-');
            	$scope.data.arrivalDate = new Date($scope.data.arrivalDate);
				$scope.data.selectedTravel = '';
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
			if($scope.data.recordType != 'Passport_Copy')
            {
                $scope.data.passportExpirationDate = null;
            }
            if($scope.data.recordType == 'Spanish_Language_Evaluation' && !$scope.data.evaluatorName && !$scope.data.evaluatorEmail)
            {
            	$scope.data.showSubmitEvalButton = true;
            }
            else
            {
                if($scope.data.passportExpirationDate != null) {
                    $scope.expirationDate = new Date($scope.data.passportExpirationDate);
                    $scope.expirationDate.setDate($scope.expirationDate.getDate() + 1);
                } else if($scope.data.recordType == 'Passport_Copy') {
                    $scope.expirationDate = new Date();
                } else {
                    $scope.data.passportExpiration = null;
                }
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
				$scope.viewModel = viewModel.getViewModel();
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
			$scope.sameAsHomeAddress = false;
			updateEmergencyContacts();

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

			function updateEmergencyContacts() {
				$scope.data.emergencyContacts = 0;			
				angular.forEach($scope.data.relatedContacts, function(c){
					if(c.isEmergencyContact)
					{
						$scope.data.emergencyContacts = $scope.data.emergencyContacts+1;
					}
				});
			}

			$scope.addContact = function() {
				$scope.data.editContact.isInvalid = false;
				if(!$scope.data.isEditMode)
				{
					$scope.data.relatedContacts.push($scope.data.editContact);
				}

				updateEmergencyContacts();
				
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
				updateEmergencyContacts();
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
						
			$scope.submitGroupTravel = function() {
				$scope.submittingData = true;
                portalRemotingMethods.submitGroupFlight(
                    $scope.data.travelOption,
                    $scope.data.arrivalPlanId,
                    $scope.data.id,
                    function(result, event) {
                        $scope.changeData(result);
                        $scope.isComplete = true;
                        $modalInstance.dismiss('complete');
                        $scope.$apply();
                    }
                );
            }
			$scope.submitIndependentFlights = function() {
				$scope.submittingData = true;
				var submitFlights = false;
				for(var i = 0; i < $scope.data.independentFlights.length; i++)
				{
					if( $scope.data.independentFlights[i] != null && $scope.data.independentFlights[i].flightNumber != null && $scope.data.independentFlights[i].Departure_Airport_Code__c != null
						&& $scope.data.independentFlights[i].departureTime && $scope.data.independentFlights[i].Arrival_Airport_Code__c && $scope.data.independentFlights[i].arrivalTime)
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
                    portalRemotingMethods.submitIndependentTravel(
                        $scope.data.travelOption,
                        $scope.data.arrivalPlanId = ($scope.data.arrivalPlanId ? $scope.data.arrivalPlanId : ""),
                        $scope.data.travelPlanInfo = ($scope.data.travelPlanInfo ? $scope.data.travelPlanInfo : ""),
                        $scope.data.independentFlights,
                        $scope.data.id,
    					function(result, event) {
                            if(result)
                            {
                                $scope.changeData(result);
                                $scope.isComplete = true;
                                $modalInstance.dismiss('complete');
                                $scope.$apply();
                            }
                            else
                            {
                                alert("An error has occured, please try again");
                                $scope.submittingData = false;
                                $scope.$apply();
                            }
    					}
					);
				}
				else
				{
					$scope.submittingData = false;
                    $scope.$apply();
				}
			}
			$scope.removeFlight = function(index) {
                var flight = $scope.data.independentFlights[index];
                $scope.data.independentFlights.splice( $scope.data.independentFlights.indexOf(flight), 1);
            }
			
			$scope.data.aidList = [];      
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
			
			$scope.submitSignature = function() {
				var canvas = document.getElementById("signature");
				canvas.toBlob(function(blob) {
  					$scope.file = blob;
					$scope.submitAttachment();
				});
			}
			$scope.addFlight = function() {
				$scope.data.independentFlights[$scope.data.independentFlights.length] = {};
			}
			$scope.submitRecommender = function() {
				$scope.submittingData = true;
				$scope.errorMessage = '';
				portalRemotingMethods.submitRecommender(
					$scope.recommenderName,
					$scope.recommenderEmail,
					$scope.data.id,
					function(result, event) {
						$scope.submittingData = false;
						if(event.message != '' && event.message != null) {
							alert(event.message);
						} else {
							$scope.recommenderSubmitted = true;
							$scope.data.recommendations.push({
								recommenderName : $scope.recommenderName,
								recommendationStatus : 'Incomplete',
								recommenderEmail : $scope.recommenderEmail,
								recommendationUrl : ''
							});
							$scope.recommenderName = '';
							$scope.recommenderEmail = '';
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
						if($scope.recommendationWaived != null && $scope.recommendationWaived != '') {
							$scope.data.recommendationWaived = $scope.recommendationWaived;
						}
						if($scope.evalWaived != null && $scope.evalWaived != '') {
							$scope.data.evalWaived = $scope.evalWaived;
						}
						for(var i = 0; i < $scope.data.housingOptions.length; i++) { 
					    	if($scope.data.housingOptions[i].Description != null) {
					      		$scope.data.housingOptions[i].Description = '';
					     	}
					    }
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
												$modalInstance.dismiss('complete');
											$scope.viewModel.appItemsIncomplete = $scope.viewModel.appItemsIncomplete - 1;
											$scope.$apply();
											if($scope.viewModel.appItemsIncomplete < 1) {
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
									$modalInstance.dismiss('complete');
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
							$modalInstance.dismiss('complete');
							//$scope.viewModel.appItemsIncomplete = $scope.viewModel.appItemsIncomplete - 1;
							$scope.$apply();
							if($scope.viewModel.appItemsIncomplete < 1) {
								$scope.showCompletionNotification($scope.viewModel.completionNotificationReceived);
							}
						}
						else
						{
							alert('An error has occured submitting your form, please try again later');
							$scope.submittingData = false;
							$modalInstance.dismiss('complete');
							//$scope.viewModel.appItemsIncomplete = $scope.viewModel.appItemsIncomplete - 1;
							$scope.$apply();
						}
					}
				);
			}
			$scope.closeModal = function() {
				$modalInstance.dismiss('complete');
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
				/*
				if($scope.sameParentAddress) {
					$scope.data.eContact2Street = $scope.data.eContactStreet;
					$scope.data.eContact2City = $scope.data.eContactCity;
					$scope.data.eContact2State = $scope.data.eContactState;
					$scope.data.eContact2Zip = $scope.data.eContactZip;
					$scope.data.eContact2Country = $scope.data.eContactCountry;
				}
				*/
				if($scope.expirationDate != null) {
                	$scope.data.passportExpirationDate = $scope.expirationDate.getFullYear() + '-' + ($scope.expirationDate.getMonth() + 1) + '-' + $scope.expirationDate.getDate();
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
				
				$scope.data.FASFA = ($scope.data.FASFA == 'true');
				if(!$scope.data.fastFormsURL)
				{
					var jsonString = angular.toJson($scope.data);
					portalRemotingMethods.submitApplicationItem(
						jsonString,
						'',
						'',
						'',
						function(result, event) {
							$scope.changeData(result);
						}
					);
				}
				else
				{
					$modalInstance.dismiss('complete');
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
				} else if($scope.data.recordType == 'Passport_Copy' && !$scope.data.passportInRenewal) {
					$scope.data.passportDataSubmitted = true;					
				}
				$scope.submittingData = false;
				if(($scope.data.recordType != 'Passport_Copy' && $scope.data.recordType != 'Recommendation' && $scope.data.recordType != 'Spanish_Language_Evaluation' ) 
                   || ($scope.data.recordType == 'Passport_Copy' && ($scope.data.passportInRenewal || $scope.data.passportDoNotHave))
                   || ($scope.data.recordType == 'Spanish_Language_Evaluation' && $scope.data.evaluatorEmail != null && $scope.data.evaluatorName != null)
                   || ($scope.data.recordType == 'Recommendation' && $scope.data.recommendations.length > 0)){
					$modalInstance.dismiss('complete');
                }
				for(i = 0; i < $scope.viewModel.appItems.length; i++) {
					if($scope.viewModel.appItems[i].id == $scope.data.id) {
						$scope.viewModel.appItems[i] = $scope.data;
					}
				}
				$scope.$apply();
				if($scope.viewModel.appItemsIncomplete < 1 && $scope.viewModel.status == 'Program Selected') {
					$scope.showCompletionNotification($scope.viewModel.completionNotificationReceived);
				}
			}
			$scope.showCompletionNotification = function(showPopup) {
				if(!showPopup) {
					studentApplyController.closeCompletionNotification(
						$scope.viewModel.applicationId, 
						function(result){
							if(result)
							{
								$scope.viewModel.applicationStatus = 'Ready To Submit';
								var modalInstance = $modal.open({
									animation: true,
									size: 'lg',
									templateUrl: urlService.getAppItemsCompleteModalURL(),
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
		});
		applyApp.controller('appItemsCompleteController', function($scope, $modalInstance) {
			$scope.ok = function () {
				$modalInstance.dismiss('ok');
			};
		});