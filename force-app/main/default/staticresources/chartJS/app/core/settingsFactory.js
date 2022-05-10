/**
 * Chart Settings Factory
 * @file Chart Settings Factory
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.factory('settingsFactory', function(viewModel) {
    var _chartTitle = '';
    var _chartRecordDisclaimer = '';
    var _chartSearchDisclaimer = '';
    var _chartDisclaimer = '';
    var _showProjects;
    var _showFavorites;
    var _chartSearchCMPMessage = '';
    var _cmpCEWelcome = '';
    var _cmpCIWelcome = '';
    var _ciceName = '';
    var _ciceEmail = '';
    var service = {};
    var _chartNoResultsMessage = '';
    var _disclaimerDismissed;
    var _enableCEToggle;
    var _ceUploadExplanation = '';
    var service = {}

    service.getTitle = function() {
        return _chartTitle;
    }
    service.getRecordDisclaimer = function() {
        return _chartRecordDisclaimer;
    }
    service.getSearchDisclaimer = function() {
        return _chartSearchDisclaimer;
    }
    service.getDisclaimer = function() {
        return _chartDisclaimer;
    }
    service.getShowFavorites = function() {
        return _showFavorites;
    }
    service.getShowProjects = function() {
        return _showProjects;
    }
    service.getSearchCMPMessage = function() {
        return _chartSearchCMPMessage;
    }
    service.getCMPWelcome = function(userType) {
        switch (userType) {
            case 'IFSA Advisor User':
            case 'IFSA CHART Advisor User':
                return _cmpCIWelcome;
                break;
            case 'IFSA Student User':
            case 'IFSA CHART Student User':
                return _cmpCEWelcome;
                break;
            default:
                return '';
                break;
        }
    }
    service.getCICEName = function() {
        return _ciceName;
    }
    service.getCICEEmail = function() {
        return _ciceEmail;
    }
    service.getNoResultsMessage = function() {
        return _chartNoResultsMessage;
    }
    service.getDisclaimerDismissed = function() {
        return _disclaimerDismissed;
    }
    service.setDisclaimerDismissed = function(value) {
        _disclaimerDismissed = value;
        console.log(_disclaimerDismissed);
        return _disclaimerDismissed;
    }
    service.getEnableCEToggle = function() {
        return _enableCEToggle;
    }
    service.getCeUploadExplanation = function() {
        return _ceUploadExplanation;
    }

    service.init = function(vm) {
        var settings = vm.settings
        _chartTitle = settings["CHART_Title"];
        _chartRecordDisclaimer = settings["CHART_Record_Disclaimer"];
        _chartSearchDisclaimer = settings["CHART_Search_Disclaimer"];
        _chartDisclaimer = settings["CHART_Disclaimer"];
        _showFavorites = settings["CHART_Show_Favorites"] == "true" ? true : false;
        _showProjects = settings["CHART_Show_Projects"] == "true" ? true : false;
        _chartSearchCMPMessage = settings["CHART_Search_CMP_Message"];
        _cmpCEWelcome = settings["CHART_CE_Welcome"];
        _cmpCIWelcome = settings["CHART_CI_Welcome"];
        _ciceName = settings["CHART_CICE_Name"];
        _ciceEmail = settings["CHART_CICE_Email"];
        _chartNoResultsMessage = settings["CHART_No_Results_Message"];
        _disclaimerDismissed = false;
        _enableCEToggle = settings["CHART_Enable_CE_Search_Toggle"] == "true" ? true : false;
        _ceUploadExplanation = settings["CHART_CE_Upload_Explaination_Text"];
    }

    service.init(viewModel.getViewModel())

    return service;
});