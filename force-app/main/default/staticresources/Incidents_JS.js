var ifsaCaseApp = angular.module('ifsaCaseApp', ['ui.bootstrap','ui.bootstrap.datetimepicker','ui.dateTimeInput','truncate','ngSanitize']);

ifsaCaseApp.filter('ampersand', function(){
	return function(input){
		return input ? input.replace(/&amp;/, '&') : '';
	}
});

ifsaCaseApp.filter('apostraphe', function(){
	return function(input){
		return input ? input.replace(/&#39;/, "'") : '';
	}
});

ifsaCaseApp.filter('capitalize', function() {
	return function(input, scope) {
		if (input!=null)
			input = input.toLowerCase();
		return input.substring(0,1).toUpperCase()+input.substring(1);
	}
});

ifsaCaseApp.filter('catalogCustomFilter', function () {
    return function (items, catalogOrCustom) {
        var filtered = [];
        
        for (var i = 0; i < items.length; i++) {
            var item = items[i];
            if (item.tags.indexOf(catalogOrCustom) != -1) {
            	filtered.push(item);
            }
        }
        return filtered;
    };
});

ifsaCaseApp.filter('statusFilter', function () {
    return function (items, status) {
        var filtered = [];
        
        for (var i = 0; i < items.length; i++) {
            var item = items[i];
            if (item.tags.indexOf(status) != -1) {
            	filtered.push(item);
            }
        }
        return filtered;
    };
});

ifsaCaseApp.controller('ifsaCaseController', function($scope, viewModel, profile, $filter, ampersandFilter, apostrapheFilter, capitalizeFilter)
{
	$scope.viewModel = viewModel.getViewModel();
	$scope.viewModel.isAdmin = profile.getProfile() == '00e61000000WN1eAAG';
	$scope.showCloseCase = false;
	//Check record type to set one of the below boolean values
	//When a new record type is added it will need added here too.
	//If the record type does not match any of the record types before the last line
	//the page will assume that the record type is a 'Incident_*' record type.
	if($scope.viewModel.recordType)
	{
		$scope.academicAppealCase = $scope.viewModel.recordType.developerName == 'Academic_Appeal' ? true : false;
		$scope.helpDeskCase = $scope.viewModel.recordType.developerName == 'Help_Desk' ? true : false;
		$scope.preDepartureCase = $scope.viewModel.recordType.developerName == 'Pre_Departure' ? true : false;
	}
	else
	{
		$scope.academicAppealCase = false;
		$scope.helpDeskCase = false;
		$scope.preDepartureCase = false;
	}
	
	//If none of the above mark as an incident.
	$scope.incidentCase = !$scope.academicAppealCase && !$scope.helpDeskCase && !$scope.preDepartureCase ? true : false;

	/*$scope.showComments = true;
	$scope.showFiles = true;
	$scope.showEcontacts = true;
	$scope.showAffectedArea = true;
	$scope.showAffectedStudents = true;
	$scope.showRelatedCases = true;
	$scope.showCaseTeam = true;*/
	processViewModel();

	function processViewModel() {
		$scope.viewModel.caseIncidentDateTime = $scope.viewModel.caseIncidentDateTime != null ? $scope.viewModel.caseIncidentDateTime : new Date();
		var ownerName = $scope.viewModel.owner.firstName != null ? $scope.viewModel.owner.firstName : null + ' ' + $scope.viewModel.owner.lastName != null ? $scope.viewModel.owner.lastName : null;
		$scope.searchedUser = $scope.viewModel.owner.userId != null ? ownerName : null;
		$scope.searchedUser = ampersandFilter($scope.searchedUser);
		$scope.searchedStudent = $scope.viewModel.student.contactId != null ? $scope.viewModel.student.firstName + ' ' + $scope.viewModel.student.lastName : null;
		$scope.searchedHostInstitution = $scope.viewModel.hostInstitution.hostInstitutionId != null ? $scope.viewModel.hostInstitution.Name : null;
		$scope.searchedCountry = $scope.viewModel.country.countryId != null ? $scope.viewModel.country.Name: null;
		$scope.searchedCity = $scope.viewModel.incidentCity.localityId != null ? $scope.viewModel.incidentCity.name : null;
		$scope.searchedCase = $scope.viewModel.parentCase.caseId != null ? $scope.viewModel.parentCase.caseNumber : null;
		$scope.searchedProgram = $scope.viewModel.program.programId != null ? $scope.viewModel.program.Name : null;
		$scope.searchedApplication = $scope.viewModel.applicationId != null ? $scope.viewModel.application.Name : null;
		$scope.recordType = $scope.viewModel.recordType;
		if(!$scope.viewModel.student.contactId)
		{
			$scope.viewModel.student = null;
		}
		$scope.alerts = [];
		$scope.edit = $scope.viewModel.edit;
		$scope.isNew = $scope.viewModel.createdDate == null ? true : false;
		if($scope.viewModel.incidentSeverity)
		{
		for (var i = 0; i < $scope.viewModel.severities.length; i++) 
		{
		    if ($scope.viewModel.severities[i].apiName == $scope.viewModel.incidentSeverity.apiName) 
			{
		        $scope.viewModel.incidentSeverity = $scope.viewModel.severities[i];
		        break;
		    	}
			}
		}
		angular.forEach($scope.viewModel.affectedStudents, function(student){
			if(student.contactRecord.On_Site_Application__r != null)
			{
				//Program Term Start Date
				if(student.contactRecord.On_Site_Application__r.Program_Term__r.Start_Date__c != null)
				{
					student.contactRecord.On_Site_Application__r.Program_Term__r.Start_Date__c = processDates(student.contactRecord.On_Site_Application__r.Program_Term__r.Start_Date__c);
				}
				//Program Term End Date
				if(student.contactRecord.On_Site_Application__r.Program_Term__r.End_Date__c != null)
				{
					student.contactRecord.On_Site_Application__r.Program_Term__r.End_Date__c = processDates(student.contactRecord.On_Site_Application__r.Program_Term__r.End_Date__c);
				}
				//Parent Program Term Dates
				if(student.contactRecord.On_Site_Application__r.Program_Term__r.Parent_Program_Term__r != null)
				{
					//Parent Program Term Start Date
					if(student.contactRecord.On_Site_Application__r.Program_Term__r.Parent_Program_Term__r.Start_Date__c != null)
					{
						student.contactRecord.On_Site_Application__r.Program_Term__r.Parent_Program_Term__r.Start_Date__c = processDates(student.contactRecord.On_Site_Application__r.Program_Term__r.Parent_Program_Term__r.Start_Date__c);
					}
					//Parent Program Term End Date
					if(student.contactRecord.On_Site_Application__r.Program_Term__r.Parent_Program_Term__r.End_Date__c != null)
					{
						student.contactRecord.On_Site_Application__r.Program_Term__r.Parent_Program_Term__r.End_Date__c = processDates(student.contactRecord.On_Site_Application__r.Program_Term__r.Parent_Program_Term__r.End_Date__c);
					}
				}
			}
		});
		$scope.$apply();
	};

	function processDates(dateString) {
		var parts = dateString.split('-');
		//please put attention to the month (parts[0]), Javascript counts months from 0:
		// January - 0, February - 1, etc
		var newDate = new Date(parts[0],parts[1]-1,parts[2]);
		return newDate;
	}

	$scope.setRecordType = function(recordType)
	{
		//var country = {countryId: $scope.viewModel.country.countryId, Name: $scope.viewModel.country.Name};

		$scope.viewModel.recordType = recordType;
		$scope.$apply();
		//If record type is incident or pre departure set $scope.viewModel.isIncident
	}

	$scope.addAlert = function(alertType, message) {
		$scope.alerts.push({type: alertType, msg: message});
	};

	$scope.closeAlert = function(index) {
		$scope.alerts.splice(index, 1);
	};

	$scope.addAffectedStudent = function() {
		window.location.assign('/0B6/e?kp=500&pid=' + viewModel.caseId + '&retURL=%2F' + viewModel.caseId);	
	};

	//Search for students
	$scope.searchForStudents = function() {
		if($scope.searchedStudent.length > 0)
		{
			ifsaCaseController.searchForRecordWithRecordType(
				'Contact',
				$scope.searchedStudent,
				'Student',
				function(result, event) {
					$scope.populateStudentDropdown(result, event);
				}
			);
		}
		else
		{
			$scope.viewModel.student = null;
		}
	}

	//Once student results have come back, populate
	$scope.populateStudentDropdown = function(result, event) {
		$scope.studentResults = result;
		$scope.$apply();
	}

	//Select a student
	$scope.selectStudent = function(item) {
		$scope.viewModel.student = {
			contactId: item.id,
			Name: item.name,
			firstName: item.firstName,
			lastName: item.lastName,
		}
		/*$scope.viewModel.student.contactId = item.id;
		$scope.viewModel.student.Name = item.name;
		$scope.viewModel.student.firstName = item.firstName;
		$scope.viewModel.student.lastName = item.lastName;*/
	}

	//Search for applications
	$scope.searchForApplications = function() {
		if($scope.searchedApplication.length > 0)
		{
			ifsaCaseController.searchForRecord(
				'Application__c',
				$scope.searchedApplication,
				function(result, event) {
					$scope.populateApplicationDropdown(result, event);
				}
			);
		}
		else
		{
			$scope.viewModel.application = null;
		}
	}

	//Once student results have come back, populate
	$scope.populateApplicationDropdown = function(result, event) {
		$scope.applicationResults = result;
		$scope.$apply();
	}

	//Select a student
	$scope.selectApplication = function(item) {
		item.name = item.name.replace(/&#39;/g, "'");
		$scope.viewModel.application = {
			applicationId: item.id,
			Name: item.name			
		}
		/*$scope.viewModel.student.contactId = item.id;
		$scope.viewModel.student.Name = item.name;
		$scope.viewModel.student.firstName = item.firstName;
		$scope.viewModel.student.lastName = item.lastName;*/
	}

	//Search for cases
	$scope.searchForCases = function() {
		ifsaCaseController.searchForRecord(
			'Case',
			$scope.searchedCase,
			function(result, event) {
			$scope.populateCaseDropdown(result, event);
			}
		);	
	}

	//Once case results have come back, populate
	$scope.populateCaseDropdown = function(result, event) {
		$scope.caseResults = result;
		$scope.$apply();
	}

	//Select a case
	$scope.selectCase = function(item) {                
		$scope.viewModel.parentCase.caseId = item.id;
		$scope.viewModel.parentCase.caseNumber = item.name;
	}

	//Search for users
	$scope.searchForUsers = function() {
		ifsaCaseController.searchForRecord(
			'User',
			$scope.searchedUser,
			function(result, event) {
				$scope.populateUserDropdown(result, event);
			}
		);
	}

	//Once user results have come back, populate
	$scope.populateUserDropdown = function(result, event) {
		$scope.userResults = result;
		$scope.$apply();
	}

	//Select a user
	$scope.selectUser = function(item) {                
		$scope.viewModel.owner.userId = item.id;
		$scope.viewModel.owner.firstName = item.firstName;
		$scope.viewModel.owner.lastName = item.lastName;
		$scope.viewModel.owner.name = item.name;
	}

	//Search for countries
	$scope.searchForCountries = function() {
		ifsaCaseController.searchForRecord(
			'Country__c',
			$scope.searchedCountry,
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
		$scope.viewModel.country.countryId = item.id;
		$scope.viewModel.country.Name = item.name;
	}
	//Add country to to list of affected countries
	$scope.addCountry = function(saveCase) {
		if($scope.viewModel.country.countryId != null || saveCase)
		{
			var country = {countryId: $scope.viewModel.country.countryId, Name: $scope.viewModel.country.Name};
			$scope.viewModel.affectedCountries.push(country);
			$scope.searchedCountry = null;
			if(saveCase)
			{
				$scope.saveUpdateCase();
			}
		}
	}

	//Search for programs
	$scope.searchForPrograms = function() {
		ifsaCaseController.searchForRecord(
			'Program__c',
			$scope.searchedProgram,
			function(result, event) {
				$scope.populateProgramDropdown(result, event);
			}
		);
	}

	//Once program results have come back, populate
	$scope.populateProgramDropdown = function(result, event) {
		$scope.programResults = result;
		$scope.$apply();
	}

	//Select a program
	$scope.selectProgram = function(item) {                	             
		$scope.viewModel.program.programId = item.id;
		item.name = item.name.replace(/&#39;/g, "'");
		$scope.viewModel.program.Name = item.name;
	}
	//Add program to to list of affected programs
	$scope.addProgram = function(saveCase) {		
		if($scope.viewModel.program.programId != null || saveCase)
		{
			var program = {programId: $scope.viewModel.program.programId, Name: $scope.viewModel.program.Name};
			$scope.viewModel.affectedPrograms.push(program);
			$scope.searchedProgram = null;
			if(saveCase)
			{
				$scope.saveUpdateCase();
			}
		}
	}

	//Search for cities
	$scope.searchForCities = function() {
		ifsaCaseController.searchForRecordWithRecordType(
			'Locality__c',
			$scope.searchedCity,
			$scope.selectedCountryForCity.Name,
			function(result, event) {
				$scope.populateCityDropdown(result, event);
			}
		);
	}

	//Once country results have come back, populate
	$scope.populateCityDropdown = function(result, event) {
		$scope.cityResults = result;
		$scope.$apply();
	}

	//Select a country
	$scope.selectCity = function(item) {                
		$scope.viewModel.incidentCity.localityId = item.id;
		$scope.viewModel.incidentCity.Name = item.name;
	}
	//Add country to to list of affected countries
	$scope.addCity = function(saveCase) {
		if($scope.viewModel.incidentCity.localityId != null || saveCase)
		{
			var city = {localityId: $scope.viewModel.incidentCity.localityId, Name: $scope.viewModel.incidentCity.Name};
			$scope.viewModel.affectedCities.push(city);
			$scope.searchedCity = null;
			if(saveCase)
			{
				$scope.saveUpdateCase();
			}
		}
	}

	//Search for host instituiton
	$scope.searchForHostInstitutions = function() {
		ifsaCaseController.searchForRecord(
			'Host_Institution__c',
			$scope.searchedHostInstitution,
			function(result, event) {
				$scope.populateHostInstitutionDropdown(result, event);
			}
		);
	}

	//Once host institution results have come back, populate
	$scope.populateHostInstitutionDropdown = function(result, event) {
		$scope.hostInstitutionResults = result;
		$scope.$apply();
	}

	//Select a host institution
	$scope.selectHostInstitution = function(item) {                
		$scope.viewModel.hostInstitution.hostInstitutionId = item.id;
		item.name = item.name.replace(/&#39;/g, "'");
		$scope.viewModel.hostInstitution.Name = item.name;
	}

	//Add host institution to to list of affected host institutions
	$scope.addHost = function(saveCase) {
		if($scope.viewModel.hostInstitution.hostInstitutionId != null || saveCase)
		{
			var host = {hostInstitutionId: $scope.viewModel.hostInstitution.hostInstitutionId, Name: $scope.viewModel.hostInstitution.Name};
			$scope.viewModel.affectedHostInstitutions.push(host);
			$scope.searchedHost = null;
			if(saveCase)
			{
				$scope.saveUpdateCase();
			}
		}
	}

	//Searches for dependent picklist values
	$scope.getDependentPickList = function(parent, child)
	{
		var value;
		switch(parent) {
		    case "Incident_Category__c":
				value = $scope.viewModel.incidentCategory;
				$scope.viewModel.subCategories = null;
				$scope.viewModel.subSubCategories = null;
				break;
		    case "Incident_Sub_Category__c":
				$scope.viewModel.subSubCategories = null;
				value = $scope.viewModel.incidentSubCategory;
		        break;				
		    default:
		        value = null;
		}
		if(value)
		{
			ifsaCaseController.getDependentPicklist(
				'Case',
				parent,
				child,
				value,
				function(result, event) {
				if(result)
				{
					$scope.loadPickList(child, result);
				}
			}
			);
		}   	
	}
	//If result.length > 0 then fill the dependent picklist with values
	$scope.loadPickList = function(child, result)
	{            	
		switch(child) 
		{
			case "Incident_Sub_Category__c":	        			
				$scope.viewModel.subCategories = result;	        			
				break;
			case "Incident_Sub_Subcategory__c":
				$scope.viewModel.subSubCategories = result;
				break;
		}
		$scope.hideOther(child);
		$scope.$apply();
	}

	//Saves a new case
	$scope.saveNewCase = function(redirectToRecord)
	{
		var readyToSave = true;
		$scope.saving = true;
		var errorMessage = '';
		switch($scope.viewModel.recordType.developerName)
		{
			case "Incident_City":
				if($scope.viewModel.affectedCities.length < 1)
					{
						readyToSave = false;
						errorMessage = 'You need to add a city to continue.'
					}
				break;
			case "Incident_Country":
				if($scope.viewModel.affectedCountries.length < 1)
					{
						readyToSave = false;
						errorMessage = 'You need to add a country to continue.'
					}
				break;
			case "Incident_Host_Institution":
				if($scope.viewModel.affectedHostInstitutions.length < 1)
				{
					readyToSave = false;
					errorMessage = 'You need to add a host institution to continue.'
				}
				break;
			case "Incident_Program":
				if($scope.viewModel.affectedPrograms.length < 1)
				{
					readyToSave = false;
					errorMessage = 'You need to add a program to continue.'
				}
				break;
			case "Incident_Student":
				//This will be needed for multiple student cases
				break;
			case "Incident_Global":
				//Not sure this will be needed but stubbing anyway
				break;
			case "Pre_Departure":
				//Not sure this will be needed but stubbing anyway
				break;
		}
		if(readyToSave)
		{
			ifsaCaseController.saveCase(
				angular.toJson($scope.viewModel),
				function(result, event) {
					if(result) {
						var str = result.replace(/&quot;/g, '"');
						result = angular.fromJson(str);
						$scope.addAlert('success', 'Case has been saved')
						$scope.$apply();
						if(redirectToRecord) {
							$scope.caseId = result.caseId;
							$scope.caseTeamJobId = result.caseTeamJobId;
							$scope.isNew = false;
							$scope.edit = false;
							//location.assign(location.protocol + "//" + location.hostname + "/" + result);
							$scope.refreshViewModel($scope.caseId);
						}
						else {
							$scope.caseId = '';
							location.reload();
						}
					}        				
					else {
						$scope.addAlert('danger', 'The case was not saved');
						$scope.saving = false;
					}
					$scope.$apply();
				}
			);
		}
		else
		{
			$scope.addAlert('danger', errorMessage);
		}
		if($scope.caseTeamJobId)
		{
			$scope.checkJob();
		}
	}

	$scope.checkJob = function()
	{
		window.setTimeout(function(){
			ifsaCaseController.checkJob(
				$scope.caseTeamJobId,
				function(result, event){
					if(result)
					{
						$scope.processCaseTeam();
					}
					else
					{
						$scope.checkJob();
					}
				}
			)
		}, 2000);
	}

	$scope.processCaseTeam = function()
	{
		ifsaCaseController.getCaseTeam(
			$scope.caseId,
			function(result, event)
			{
				var str = result.replace(/&quot;/g, '"');
				result = angular.fromJson(str);
				if(result)
				{
					$scope.viewModel.caseTeam = result;
				}
			}
		);
		$scope.$apply();
	}

	$scope.saveUpdateCase = function() 
	{
		$scope.saving = true;
		updateVM = $scope.viewModel;
		updateVM.createdDate = null;
		updateVM.caseComments = [];
		updateVM.caseHistory = [];
		updateVM.affectedStudents = [];
		updateVM.contactSupportPersonnel = [];
		updateVM.homeInstitutionEmergencyContacts = [];
		updateVM.files = [];
		updateVM.relatedCases = [];
		updateVM.caseTeam = [];
		updateVM.openActivities = [];
		updateVM.activityHistory = [];
		var jsonVM = angular.toJson(updateVM);
		ifsaCaseController.saveCase(
			jsonVM,
			function(result, event) {
				var str = result.replace(/&quot;/g, '"');
				result = angular.fromJson(str);
				if(result) {
					$scope.addAlert('success', 'Case has been saved')
					$scope.$apply();            				
					$scope.caseId = result.caseId;
					$scope.caseTeamJobId = result.caseTeamJobId;
					$scope.isNew = false;
					$scope.edit = false;
					$scope.showCloseCase = false;
					$scope.refreshViewModel($scope.caseId);
					$scope.viewModel.isClosed = $scope.viewModel.status == 'Closed' ? true: false;
				}
				else {
					$scope.addAlert('danger', 'The case was not saved');
					$scope.saving = false;
				}
				$scope.$apply();
				if($scope.caseTeamJobId)
				{
					$scope.checkJob();
				}
			}
		);
	}

	$scope.refreshViewModel = function(caseId) {
		ifsaCaseController.refreshViewModel(caseId,
			function (result, event) {
			if(result) {
				var str = result.replace(/&quot;/g, '"');
				$scope.viewModel = angular.fromJson(str);
				processViewModel();
				}
			}
		);
		$scope.saving = false;
	}

	$scope.cancelComment = function()
	{
		$scope.createNewComment = false;
		$scope.viewModel.newComment.commentText = '';
		$scope.viewModel.newComment.isPublic = false;
		$scope.$apply();
	}

	$scope.saveComment = function()
	{
		$scope.viewModel.newComment.caseId = $scope.viewModel.caseId;
		var multiline = $scope.viewModel.newComment.commentText.con
		ifsaCaseController.saveCaseComment(
			$scope.viewModel.newComment.commentText,
			$scope.viewModel.newComment.caseId,
			$scope.viewModel.newComment.isPublic,
			function(result, event) {
				if(result)
				{
					$scope.viewModel.caseComments = result;

					$scope.createNewComment = false;
					$scope.viewModel.newComment.commentText = '';
					$scope.viewModel.newComment.isPublic = false;
					$scope.$apply();
				}
				else
				{
					$scope.addAlert('danger', 'The case comment was not saved');
				}
			}
		);
	}

	$scope.editMode = function()
	{
		$scope.edit = true;
	}

	$scope.closeCase = function()
	{
		$scope.showCloseCase = true;
		for (var i = 0; i < $scope.viewModel.statuses.length; i++) 
		{
		    if ($scope.viewModel.statuses[i] == 'Closed') 
			{
		        $scope.viewModel.status = $scope.viewModel.statuses[i];
				//$scope.$apply();
		        break;
	    	}
		}
	}
	$scope.reopenCase = function()
	{
		$scope.viewModel.status = 'Escalated';		
		$scope.saveUpdateCase();
		$scope.viewModel.isClosed = false;
		$scope.$apply();
	}

	$scope.cancelEdit = function()
	{
		$scope.edit = false;
		$scope.showCloseCase = false;
		$scope.refreshViewModel($scope.viewModel.caseId);
	}

	$scope.hideOther = function(child)
	{
		if(child == 'Incident_Sub_Category__c')
		{
			$scope.viewModel.incidentSubCategory = '';
		}
		$scope.viewModel.incidentSubSubCategory = '';
		$scope.$apply();
	}

	$scope.sendHomeEmails = function()
	{
		var emailAddresses = [];
		for (var i = 0; i < $scope.viewModel.homeInstitutionEmergencyContacts.length; i++) 
		{
			if($scope.viewModel.homeInstitutionEmergencyContacts[i].sendEmail && $scope.viewModel.homeInstitutionEmergencyContacts[i].supportPersonnelEmail)
			{
			emailAddresses.push($scope.viewModel.homeInstitutionEmergencyContacts[i].supportPersonnelEmail);
			}
		}
		$scope.sendEmail(emailAddresses);
	}

	$scope.sendParentEmails = function()
	{
		var emailAddresses = [];
		for (var i = 0; i < $scope.viewModel.contactSupportPersonnel.length; i++) 
		{
			if($scope.viewModel.contactSupportPersonnel[i].sendEmail && $scope.viewModel.contactSupportPersonnel[i].supportPersonnelEmail)
			{
				emailAddresses.push($scope.viewModel.contactSupportPersonnel[i].supportPersonnelEmail);
			}
		}
		$scope.sendEmail(emailAddresses);
	}

	$scope.sendStudentEmail = function()
	{
		var emailAddresses = [];
		for (var i = 0; i < $scope.viewModel.affectedStudents.length; i++) 
		{
			if($scope.viewModel.affectedStudents[i].sendEmail && $scope.viewModel.affectedStudents[i].contactRecord.Email)
			{
				emailAddresses.push($scope.viewModel.affectedStudents[i].contactRecord.Email);
			}
		}
		$scope.sendEmail(emailAddresses);
	}

	$scope.sendTeamEmails = function()
	{
		var emailAddresses = [];
		for (var i = 0; i < $scope.viewModel.caseTeam.length; i++) 
		{
			if($scope.viewModel.caseTeam[i].sendEmail)
			{
				emailAddresses.push($scope.viewModel.caseTeam[i].member.email);
			}
		}
		if(emailAddresses.length > 0)
		{
			//window.alert('Sending email to ' + emailAddresses.length + ' contacts');
			var url = location.protocol + "//" + location.hostname + "/_ui/core/email/author/EmailAuthor?p24=" + 
			$scope.viewModel.currentUserEmail + "&p3_lkid=" + $scope.viewModel.caseId + "&p5=" + emailAddresses + "&retURL=" + 
			$scope.viewModel.caseId + "&p6=[Case %23" + $scope.viewModel.caseNumber + "]";
			window.location.assign(url);
		}
	}

	$scope.sendEmail = function(emailAddresses)
	{
		if(emailAddresses.length > 0)
		{
			//window.alert('Sending email to ' + emailAddresses.length + ' contacts');
			var url = location.protocol + "//" + location.hostname + "/_ui/core/email/author/EmailAuthor?p24=" + 
			$scope.viewModel.currentUserEmail + "&p3_lkid=" + $scope.viewModel.caseId + "&p5=" + emailAddresses + "&retURL=" + 
			$scope.viewModel.caseId + "&p6=[Case %23" + $scope.viewModel.caseNumber + "]";
			window.location.assign(url);
		}
	}

	$scope.selectAll = function(selected, boolValue)
	{
		angular.forEach(selected, function(value, key){
			value.sendEmail = boolValue
		});	
	}

	$scope.unselectAll = function(selectAll)
	{
		switch(selectAll)
		{
			case "HIEcontacts":
				$scope.selectAllHIEcontacts = $scope.selectAllHIEcontacts == true ? false : false;
				break;
			case "Econtacts":
				$scope.selectAllEcontacts = $scope.selectAllEcontacts == true ? false : false;
				break;
			case "Students":
				$scope.selectAllStudents = $scope.selectAllStudents == true ? false : false;
				break;
		}
		$scope.$apply();
	}

	$scope.jumpToAnchor = function(anchorName)
	{
		switch(anchorName)
		{
			case "AffectedStudents":
				$scope.showAffectedArea = true;
				$scope.showAffectedStudents = true;
				break;
			case "EmergencyContacts":
				$scope.showAffectedArea = true;
				$scope.showEcontacts = true;
				break;
			case "AffectedHostInstitutionEmergencyContacts":
				$scope.showAffectedArea = true;
				$scope.showHIEcontacts = true;
				break;
			case "CaseComments":
				$scope.showComments = true;
				break;
			case "Files":
				$scope.showFiles = true;
				break;
			case "RelatedCaes":
				$scope.showRelatedCases = true;
				break;
			case "CaseTeam":
				$scope.showCaseTeam = true;
				break;
			case "CaseHistory":
				$scope.showCaseHistory = true;
				break;
			case "OpenActivities":
				$scope.showOpenActivities = true;
				break;
			case "ActivityHistory":
				$scope.showActivityHistory = true;
				break;
		}
		$scope.$apply();
		window.location.hash = anchorName;
	}
});