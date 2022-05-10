/**
 * Chart File Upload Service
 * @file Chart File Upload Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('fileUploadService', function($q) {
    this.uploadFileToSalesforce = function(id, file){
        var deferred = $q.defer();
        var reader = new FileReader();
        reader.onloadend = function() {
            console.log('file is ' );
            console.dir(file);
            var f = reader.result;

            portalRemotingMethods.uploadFile(
                f.split(',')[1],
                file.type,
                file.name,
                id,
                function(result, event){
                    if(result){
                        deferred.resolve(true);
                    }
                    else{
                        deferred.reject(result);
                    }
                }
            )

        }
        reader.readAsDataURL(file);

        return deferred.promise;
    }
});