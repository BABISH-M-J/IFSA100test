/**
 * Student Portal Application Item Service
 * @file Student Portal Application Item Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('applicationItemService', function($q, dynamicFormService, viewModel, $filter) {
    var self = this;
    var appItems = [];
    var applicationItemsPromise;
    var popAppItemsPromise;

    this.getApplicationItemDetails = function(appItemId)
    {
        var deferred = $q.defer();
        portalRemotingMethods.getApplicationItemDetails(
            appItemId, 
            function(result, event) {
                console.log('result => ' + result);
                if(result)
                {
                    if(result.recordType == "Learning_Plan")
                    {
                        result = self.decodeLearningPlan(result);
                    }
                    if(result.form)
                    {
                        dynamicFormService.processForm(result.form);
                        result.form = dynamicFormService.getForm();
                    }
                    deferred.resolve(result);
                }
                else
                {
                    deferred.reject(null);
                }
            }
        );
        return deferred.promise;
    }
    this.submitApplicationItem = function(jsonData, fileData, fileType, fileName)
    {
        var deferred = $q.defer();
        portalRemotingMethods.submitApplicationItem(
            jsonData,
            fileData,
            fileType,
            fileName,
            function(result, event) {
                if(result)
                {
                    deferred.resolve(result);
                }
                else
                {
                    deferred.reject(event);
                }
            }
        );
        return deferred.promise;
    }
    this.getApplicationItems = function(appId)
    {
        var deferred = $q.defer();
        applicationItemsPromise = deferred;
        portalRemotingMethods.getApplicationItems(
            appId,
            function(result, event) {
                if(result)
                {
                    for (let index = 0; index < result.length; index++) {
                        const appItem = result[index];
                        switch (appItem.status) {
                            case 'Incomplete':
                                appItem.isStarted = false;
                                appItem.isComplete = false;
                                break;
                            case 'Started':
                                appItem.isStarted = true;
                                appItem.isComplete = false;
                                break;
                            case 'Complete':
                                appItem.isStarted = false;
                                appItem.isComplete = true;
                                break;                        
                            default:
                                break;
                        }
                    }
                    appItems = result;
                    deferred.resolve(result);
                }
                else
                {
                    deferred.reject(event);
                }
            }
        );
        applicationItemsPromise = deferred;
        return deferred.promise;
    }
    this.getApplicationItemsPromise = function() {
        if(applicationItemsPromise != null)
        {
            return applicationItemsPromise.promise;    
        }
        return self.getApplicationItems(viewModel.getViewModel().applicationId);
    }

    this.submitIndependentTravel = function(travelPlanInfo, independentFlights, id){
        var deferred = $q.defer();
        portalRemotingMethods.submitIndependentTravel(
            travelPlanInfo = (travelPlanInfo ? travelPlanInfo : ""),
            independentFlights,
            id,
            function(result, event) {
                if(result)
                {
                    deferred.resolve(result);
                }
                else
                {
                    deferred.reject(event);
                }
        });
        return deferred.promise;
    }

    this.decodeLearningPlan = function(learningPlan)
    {
        learningPlan.academicGoalsA = $filter('apostraphe')(learningPlan.academicGoalsA);
        learningPlan.academicGoalsB = $filter('apostraphe')(learningPlan.academicGoalsB);
        learningPlan.academicGoalsC = $filter('apostraphe')(learningPlan.academicGoalsC);
        learningPlan.personalGoalsA = $filter('apostraphe')(learningPlan.personalGoalsA);
        learningPlan.personalGoalsB = $filter('apostraphe')(learningPlan.personalGoalsB);
        learningPlan.personalGoalsC = $filter('apostraphe')(learningPlan.personalGoalsC);
        learningPlan.professionalGoalsA = $filter('apostraphe')(learningPlan.professionalGoalsA);
        learningPlan.professionalGoalsB = $filter('apostraphe')(learningPlan.professionalGoalsB);
        learningPlan.professionalGoalsC = $filter('apostraphe')(learningPlan.professionalGoalsC);
        learningPlan.specificActions1 = $filter('apostraphe')(learningPlan.specificActions1);
        learningPlan.specificActions2 = $filter('apostraphe')(learningPlan.specificActions2);
        learningPlan.specificActions3 = $filter('apostraphe')(learningPlan.specificActions3);
        learningPlan.specificActions4 = $filter('apostraphe')(learningPlan.specificActions4);
        learningPlan.specificActions5 = $filter('apostraphe')(learningPlan.specificActions5);
        learningPlan.otherInformation = $filter('apostraphe')(learningPlan.otherInformation);
        learningPlan.academicOriginalA = $filter('apostraphe')(learningPlan.academicOriginalA);
        learningPlan.academicOriginalB = $filter('apostraphe')(learningPlan.academicOriginalB);
        learningPlan.academicOriginalC = $filter('apostraphe')(learningPlan.academicOriginalC);
        learningPlan.personalOriginalA = $filter('apostraphe')(learningPlan.personalOriginalA);
        learningPlan.personalOriginalB = $filter('apostraphe')(learningPlan.personalOriginalB);
        learningPlan.personalOriginalC = $filter('apostraphe')(learningPlan.personalOriginalC);
        learningPlan.professionalOriginalA = $filter('apostraphe')(learningPlan.professionalOriginalA);
        learningPlan.professionalOriginalB = $filter('apostraphe')(learningPlan.professionalOriginalB);
        learningPlan.professionalOriginalC = $filter('apostraphe')(learningPlan.professionalOriginalC);
        learningPlan.specificOriginal1 = $filter('apostraphe')(learningPlan.specificOriginal1);
        learningPlan.specificOriginal2 = $filter('apostraphe')(learningPlan.specificOriginal2);
        learningPlan.specificOriginal3 = $filter('apostraphe')(learningPlan.specificOriginal3);
        learningPlan.specificOriginal4 = $filter('apostraphe')(learningPlan.specificOriginal4);
        learningPlan.specificOriginal5 = $filter('apostraphe')(learningPlan.specificOriginal5);
        learningPlan.otherInformationOriginal = $filter('apostraphe')(learningPlan.otherInformationOriginal);
        learningPlan.academicGoalsA = $filter('quote')(learningPlan.academicGoalsA);
        learningPlan.academicGoalsB = $filter('quote')(learningPlan.academicGoalsB);
        learningPlan.academicGoalsC = $filter('quote')(learningPlan.academicGoalsC);
        learningPlan.personalGoalsA = $filter('quote')(learningPlan.personalGoalsA);
        learningPlan.personalGoalsB = $filter('quote')(learningPlan.personalGoalsB);
        learningPlan.personalGoalsC = $filter('quote')(learningPlan.personalGoalsC);
        learningPlan.professionalGoalsA = $filter('quote')(learningPlan.professionalGoalsA);
        learningPlan.professionalGoalsB = $filter('quote')(learningPlan.professionalGoalsB);
        learningPlan.professionalGoalsC = $filter('quote')(learningPlan.professionalGoalsC);
        learningPlan.specificActions1 = $filter('quote')(learningPlan.specificActions1);
        learningPlan.specificActions2 = $filter('quote')(learningPlan.specificActions2);
        learningPlan.specificActions3 = $filter('quote')(learningPlan.specificActions3);
        learningPlan.specificActions4 = $filter('quote')(learningPlan.specificActions4);
        learningPlan.specificActions5 = $filter('quote')(learningPlan.specificActions5);
        learningPlan.otherInformation = $filter('quote')(learningPlan.otherInformation);
        learningPlan.academicOriginalA = $filter('quote')(learningPlan.academicOriginalA);
        learningPlan.academicOriginalB = $filter('quote')(learningPlan.academicOriginalB);
        learningPlan.academicOriginalC = $filter('quote')(learningPlan.academicOriginalC);
        learningPlan.personalOriginalA = $filter('quote')(learningPlan.personalOriginalA);
        learningPlan.personalOriginalB = $filter('quote')(learningPlan.personalOriginalB);
        learningPlan.personalOriginalC = $filter('quote')(learningPlan.personalOriginalC);
        learningPlan.professionalOriginalA = $filter('quote')(learningPlan.professionalOriginalA);
        learningPlan.professionalOriginalB = $filter('quote')(learningPlan.professionalOriginalB);
        learningPlan.professionalOriginalC = $filter('quote')(learningPlan.professionalOriginalC);
        learningPlan.specificOriginal1 = $filter('quote')(learningPlan.specificOriginal1);
        learningPlan.specificOriginal2 = $filter('quote')(learningPlan.specificOriginal2);
        learningPlan.specificOriginal3 = $filter('quote')(learningPlan.specificOriginal3);
        learningPlan.specificOriginal4 = $filter('quote')(learningPlan.specificOriginal4);
        learningPlan.specificOriginal5 = $filter('quote')(learningPlan.specificOriginal5);
        learningPlan.otherInformationOriginal = $filter('quote')(learningPlan.otherInformationOriginal);
        learningPlan.academicGoalsA = $filter('ampersand')(learningPlan.academicGoalsA);
        learningPlan.academicGoalsB = $filter('ampersand')(learningPlan.academicGoalsB);
        learningPlan.academicGoalsC = $filter('ampersand')(learningPlan.academicGoalsC);
        learningPlan.personalGoalsA = $filter('ampersand')(learningPlan.personalGoalsA);
        learningPlan.personalGoalsB = $filter('ampersand')(learningPlan.personalGoalsB);
        learningPlan.personalGoalsC = $filter('ampersand')(learningPlan.personalGoalsC);
        learningPlan.professionalGoalsA = $filter('ampersand')(learningPlan.professionalGoalsA);
        learningPlan.professionalGoalsB = $filter('ampersand')(learningPlan.professionalGoalsB);
        learningPlan.professionalGoalsC = $filter('ampersand')(learningPlan.professionalGoalsC);
        learningPlan.specificActions1 = $filter('ampersand')(learningPlan.specificActions1);
        learningPlan.specificActions2 = $filter('ampersand')(learningPlan.specificActions2);
        learningPlan.specificActions3 = $filter('ampersand')(learningPlan.specificActions3);
        learningPlan.specificActions4 = $filter('ampersand')(learningPlan.specificActions4);
        learningPlan.specificActions5 = $filter('ampersand')(learningPlan.specificActions5);
        learningPlan.otherInformation = $filter('ampersand')(learningPlan.otherInformation);
        learningPlan.academicOriginalA = $filter('ampersand')(learningPlan.academicOriginalA);
        learningPlan.academicOriginalB = $filter('ampersand')(learningPlan.academicOriginalB);
        learningPlan.academicOriginalC = $filter('ampersand')(learningPlan.academicOriginalC);
        learningPlan.personalOriginalA = $filter('ampersand')(learningPlan.personalOriginalA);
        learningPlan.personalOriginalB = $filter('ampersand')(learningPlan.personalOriginalB);
        learningPlan.personalOriginalC = $filter('ampersand')(learningPlan.personalOriginalC);
        learningPlan.professionalOriginalA = $filter('ampersand')(learningPlan.professionalOriginalA);
        learningPlan.professionalOriginalB = $filter('ampersand')(learningPlan.professionalOriginalB);
        learningPlan.professionalOriginalC = $filter('ampersand')(learningPlan.professionalOriginalC);
        learningPlan.specificOriginal1 = $filter('ampersand')(learningPlan.specificOriginal1);
        learningPlan.specificOriginal2 = $filter('ampersand')(learningPlan.specificOriginal2);
        learningPlan.specificOriginal3 = $filter('ampersand')(learningPlan.specificOriginal3);
        learningPlan.specificOriginal4 = $filter('ampersand')(learningPlan.specificOriginal4);
        learningPlan.specificOriginal5 = $filter('ampersand')(learningPlan.specificOriginal5);
        learningPlan.otherInformationOriginal = $filter('ampersand')(learningPlan.otherInformationOriginal);

        return learningPlan;
    }

    this.populateApplicationItems = function(appId){
        var deferred = $q.defer();
        portalRemotingMethods.populateApplicationItems(
            appId,
            function(result, event) {
                if(event.status && result){
                    deferred.resolve(result)
                }
                else{
                    deferred.reject(event.message);
                }
            }
        )
        popAppItemsPromise = deferred.promise
        return popAppItemsPromise;
    }

    this.getPopAppItemsPromise = function(){
        return popAppItemsPromise;
    }

    this.hasLearningPlan = function(){
        var deferred = $q.defer();
        self.getApplicationItemsPromise().then(function(result){
            let index = result.findIndex(i => i.recordTypeName == "Learning Plan");
            deferred.resolve(index > -1 ? true : false);
        }, function(error){
            deferred.reject(error);
        });
        return deferred.promise;
    }

    this.checkForNewApplicationReqs = function(appId){
        var deferred = $q.defer();
        portalRemotingMethods.checkForNewApplicationReqs(
            appId,
            function(result, event) {
                if(event.status){
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(event.message);
                }
            }
        )
        return deferred.promise;
    }
});