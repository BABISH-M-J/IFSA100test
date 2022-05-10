//Faculy Search
//Created By: Brock Barlow
var facultySearchApp = angular.module('facultySearchApp', ['ngAnimate','ui.bootstrap','textAngular','ngSanitize','ngCsv']);

facultySearchApp.filter('ampersand', function(){
    return function(input){
        return input ? input.replace(/&amp;/g, '&') : '';
    }
});
facultySearchApp.filter('apostrophe', function(){
	return function(input){
		return input ? input.replace(/&#39;/g, "'") : '';
	}
})
facultySearchApp.filter('sumOfValue', function () {
	return function (data, key) {        
		if (angular.isUndefined(data) || angular.isUndefined(key))
	    	return 0;        
        var sum = 0;        
        angular.forEach(data,function(value){
        	sum = sum + parseFloat(value[key]);
        });        
        return sum.toFixed(2);
	}
});
facultySearchApp.filter('sumOfValueNotDropped', function () {
	return function (data, key) {        
		if (angular.isUndefined(data) || angular.isUndefined(key))
	    	return 0;        
        var sum = 0;        
        angular.forEach(data,function(value){
        	if(!value.isDropped && value.qualityPoints)
            	sum = sum + parseFloat(value[key]);
        });        
        return sum.toFixed(2);
	}
});

facultySearchApp.controller('facultySearchController', function($scope, viewModel, $filter, ampersandFilter, apostropheFilter)
{
	//Initialize Angular Controller
	$scope.viewModel = viewModel.getViewModel();
	resetSections(true);
	$scope.showEmailPanel = false;
	$scope.filteringOrSearching = false;
	$scope.searched = false;
	$scope.loadingStudents = false;
	$scope.displayGroup = "Advisor";
	$scope.filters = ['Advisor', 'Other'];
	$scope.sortCol = 'contactLastName';
	
	//Non-scoped methods
	function resetSections(showTerms) 
	{
		$scope.showTerms = showTerms;
		$scope.showCountries = false;
		$scope.showCities = false;
		$scope.showPrograms = false;
		$scope.showHostInstitutions = false;
		$scope.selectedSection = 'terms';
		$scope.searched = false;
		$scope.showEmailPanel = false;
	}

	$scope.filterByType = function(spRecord)
	{
		return ($scope.filters.indexOf(spRecord.supportRoleType) !== -1);
	}

	$scope.displayGroupChanged = function ()
	{
		if($scope.displayGroup == 'Advisor')
		{
			$scope.filters = ['Parent/Guardian'];
			$scope.sortCol = 'contactLastName';
		}
		else if($scope.displayGroup == 'Parent/Guardian')
		{
			$scope.filters = ['Advisor', 'Other'];
		}

		$scope.viewModel.selectedFaculty = null;
	}

	//Scoped Methods
	$scope.showSection = function(filterGroup)
	{
		resetSections(false);

		switch(filterGroup)
		{
			case 'terms':
				$scope.originalValues = angular.copy($scope.viewModel.terms);
				$scope.showTerms = true;
				$scope.selectedSection = 'terms';
				break;
			case 'countries':
				$scope.originalValues = angular.copy($scope.viewModel.countries);
				$scope.showCountries = true;
				$scope.selectedSection = 'countries';
				break;
			case 'cities':
				$scope.originalValues = angular.copy($scope.viewModel.cities);
				$scope.showCities = true;
				$scope.selectedSection = 'cities';
				break;
			case 'programs':
				$scope.originalValues = angular.copy($scope.viewModel.programs);
				$scope.showPrograms = true;
				$scope.selectedSection = 'programs';
				break;
			case 'hostInstitutions':
				$scope.originalValues = angular.copy($scope.viewModel.hostInstitution);
				$scope.showHostInstitutions = true;
				$scope.selectedSection = 'hostInstitutions';
				break;
			default:
				break;
		}
		//$scope.$apply();
		
	}
	$scope.cancel = function(filterGroup)
	{
		resetSections(true);

		switch(filterGroup)
		{
			case 'terms':
				$scope.viewModel.terms = angular.copy($scope.originalValues);
				break;
			case 'countries':
				$scope.viewModel.countries = angular.copy($scope.originalValues);
				break;
			case 'cities':
				$scope.viewModel.cities = angular.copy($scope.originalValues);
				break;
			case 'programs':
				$scope.viewModel.programs = angular.copy($scope.originalValues);
				break;
			case 'hostInstitutions':
				$scope.viewModel.hostInstitutions = angular.copy($scope.originalValues);
				break;
			default:
				break;
		}
	}
	$scope.updateFilters = function(filterGroup)
	{
		$scope.filteringOrSearching = true;
		facultySearchController.updateFilters(
			angular.toJson($scope.viewModel),
			function(result, event)
			{
				if(result)
				{
					updateViewModel(result);
					$scope.originalValues = angular.copy(null);
				}
				else
				{

				}
				$scope.filteringOrSearching = false;
				$scope.$apply();
			}
		);
	}
	$scope.resetFilters = function()
	{
		$scope.searched = false;
		facultySearchController.resetFilters(
			angular.toJson($scope.viewModel),
			function(result, event)
			{
				if(result)
				{
					updateViewModel(result);
					$scope.originalValues = angular.copy(null);
				}
				else
				{

				}
				resetSections(true);
				$scope.$apply();
			}
		);
	}
	$scope.search = function()
	{
		$scope.filteringOrSearching = true;
		var termsSelected = false;
		for (var i = $scope.viewModel.terms.length - 1; i >= 0; i--) {
			if($scope.viewModel.terms[i].selectedInSearch)
			{
				termsSelected = true;
			}
		};
		if(!termsSelected)
		{
			alert('You must selected at least one term to search');
			return;
		}
		
		facultySearchController.search(
			angular.toJson($scope.viewModel),
			function(result, event)
			{
				if(result)
				{
					updateViewModel(result);
					createCSVArray();
				}
				else
				{

				}
				resetSections(false);
				$scope.filteringOrSearching = false;
				$scope.searched = true;
				$scope.$apply();
			}
		);
	}
	$scope.getStudents = function(spRecord)
	{
		$scope.loadingStudents = true;
		$scope.viewModel.selectedFaculty = spRecord;
		facultySearchController.getStudents(
			angular.toJson($scope.viewModel),
			function(result, event)
			{
				if(result)
				{
					updateViewModel(result);
					//$scope.originalValues = angular.copy(null);
				}
				else
				{

				}
				$scope.loadingStudents = false;
				window.scrollTo(0, 0);
				$scope.$apply();
			}
		);
	}
	$scope.showEmailComposer = function(spRecord)
	{
		if($scope.viewModel.selectedFaculty != spRecord)
		{
			$scope.getStudents(spRecord);
		}
		facultySearchController.getFacultyContact(
			angular.toJson($scope.viewModel),
			function(result, event)
			{
				if(result)
				{
					updateViewModel(result);
					$scope.showEmailPanel = true;
					//$scope.originalValues = angular.copy(null);
				}
				else
				{

				}
				$scope.$apply();
			}
		);
	}

	$scope.sendEmail = function()
	{
		facultySearchController.sendEmailMessage(
			$scope.emailBody,
			$scope.subject,
			$scope.viewModel.selectedFacultyContact.recordId,
			$scope.cc,
			$scope.bcc,
			function(result, event)
			{
				if(result)
				{
					$scope.showEmailPanel = false;
					$scope.emailBody = "";
					$scope.subject = "";
					alert("Email sent");
					//$scope.originalValues = angular.copy(null);
				}
				else
				{
					alert("Email not sent");
				}
				$scope.$apply();
			}
		);
	}

	function updateViewModel(result)
	{
		result = result.replace(/&quot;/g, '"');
		$scope.viewModel = angular.fromJson(result);
	}

	function createCSVArray()
	{
		$scope.advisorCsvData = [];
		$scope.ecCsvData = [];
		for (var i = $scope.viewModel.facultyContacts.length - 1; i >= 0; i--) {
			var spRecord = $scope.viewModel.facultyContacts[i];
			if(spRecord.recordTypeName != 'Contact')
			{
				$scope.advisorCsvData.push({
					Name: spRecord.contactName, 
					EmergencyContact: spRecord.isEmergencyContact, 
					Type: spRecord.supportRoleType, 
					HomeInstitution: spRecord.accountName, 
					Email: spRecord.emailAddress, 
					Phone: spRecord.phoneNumber,
					Traveling: spRecord.numberOfTraveling,
					OnSite: spRecord.numberOfOnSite,
					ProgramCompleted: spRecord.numberOfProgramCompleted
				});
			}
			else
			{
				$scope.ecCsvData.push({
					Name: spRecord.contactName, 
					EmergencyContact: spRecord.isEmergencyContact, 
					Type: spRecord.supportRoleType, 
					HomeInstitution: spRecord.accountName, 
					Email: spRecord.emailAddress, 
					Phone: spRecord.phoneNumber,
					Traveling: spRecord.numberOfTraveling,
					OnSite: spRecord.numberOfOnSite,
					ProgramCompleted: spRecord.numberOfProgramCompleted
				});
			}
		}
	}
});