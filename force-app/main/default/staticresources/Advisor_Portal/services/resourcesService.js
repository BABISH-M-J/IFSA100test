angular.module('app.services')
.service('resourcesService', function($q) {
    let self = this;

    this.getResourceFiles = function(){
        let deferred = $q.defer();

        advisorPortalController.getResourceFiles(
            function(result, event){
                if(event.status){
                    let categories = [];
                    for (const key in result) {
                        if (result.hasOwnProperty(key)) {
                            const files = result[key];
                            let category = {
                                name: key,
                                visible: false,
                                files: files
                            }
                            categories.push(category);
                        }
                    }
                    deferred.resolve(categories);
                }
                else{
                    deferred.reject(event);
                }
            }
        )

        return deferred.promise;
    }
})