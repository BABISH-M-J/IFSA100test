angular.module('app.services')
.service('advisingNotesService', function($q, $filter) {
    let self = this;
    
    this.getProspectiveStudents = function(){
        let deferred = $q.defer();
        advisorPortalController.getProspectiveStudents(
            function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(event);
                }
        });
        return deferred.promise;
    }

    this.getAdvisingNotes = function(userId){
        let deferred = $q.defer();
        advisorPortalController.getAdvisingNotes(
            userId,
            function(result, event){
                if(event.status){
                    for (let index = 0; index < result.length; index++) {
                        const note = result[index];
                        note.My_Note__c = $filter('apostraphe')(note.My_Note__c);
                        note.My_Note__c = $filter('quote')(note.My_Note__c);
                        note.My_Note__c = $filter('ampersand')(note.My_Note__c);
                        note.My_Note__c = $filter('fixHTMLTags')(note.My_Note__c);
                    }
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(event);
                }
        });
        return deferred.promise;
    }
})