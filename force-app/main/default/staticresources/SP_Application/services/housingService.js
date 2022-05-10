/**
 * Student Portal Housing Service
 * @file Student Portal Housing Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('housingService', function($q, $sce, $timeout, viewModel) {
    var self = this;

    this.getHousingInfoOld = function(appId) {
        let housingInfo = {
            displayName: '',
            street1: '',
            street2: null,
            locality: '',
            dependentLocality: '',
            country: '',
            landLine: '',
            cellPhone: '',
            email: '',
            applicationStatus: '',
            description: '',
            mapUrl: ''
        }
        let address = housingInfo.street1;
        if(housingInfo.street2 != null)
        {
            address += ' ' + housingInfo.street2;
        }
        if(housingInfo.locality != null)
        {
            address += ' ' + housingInfo.locality;    
        }
        if(housingInfo.dependentLocality != null)
        {
            address += ' ' +  housingInfo.dependentLocality;    
        }    	    	
        if(housingInfo.zipCode != null)
        {
            address += ' ' + housingInfo.zipCode;    
        }        
        if(housingInfo.country != null)
        {
            address += ' ' + housingInfo.country + ' ';    
        }
        housingInfo.mapUrl = $sce.trustAsResourceUrl('https://www.google.com/maps/embed/v1/place?q=' + encodeURI(address) +  '&zoom=16&key=AIzaSyAsZq3xzdJHfB2UNfCkxAbZgsnRWQGpMdU');
        housingInfo.slides = [];

        return housingInfo;
    }

    this.getHousingInfo = function(appId){
        var deferred = $q.defer();
        
        portalOnSiteRemotingMethods.getHousingInfo(
            appId,
            function(result, event)
            {
                if(result)
                {
                    let address = result.street1;
                    if(result.street2 != null)
                    {
                        address += ' ' + result.street2;
                    }
                    if(result.locality != null)
                    {
                        address += ' ' + result.locality;    
                    }
                    if(result.dependentLocality != null)
                    {
                        address += ' ' +  result.dependentLocality;    
                    }    	    	
                    if(result.zipCode != null)
                    {
                        address += ' ' + result.zipCode;    
                    }        
                    if(result.country != null)
                    {
                        address += ' ' + result.country + ' ';    
                    }
                    result.mapUrl = $sce.trustAsResourceUrl('https://www.google.com/maps/embed/v1/place?q=' + encodeURI(address) +  '&zoom=16&key=AIzaSyAsZq3xzdJHfB2UNfCkxAbZgsnRWQGpMdU');
                    deferred.resolve(result);
                }
                else
                {
                    deferred.reject(null);
                }
            }
        )
        return deferred.promise;
    }
    
});