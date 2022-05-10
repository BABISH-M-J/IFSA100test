angular.module('app.controllers')
.controller('advisingNotesController', function($scope, viewModel, advisingNotesService, $routeParams, fixHTMLTagsFilter) 
{
    $scope.loading = true;
    $scope.selectedStudentId = $routeParams.contactId;
    $scope.init = function(){
        advisingNotesService.getProspectiveStudents().then(function(result){
            $scope.advisingNotes = result;
            if($scope.selectedStudentId){
                student = $scope.advisingNotes.find(s => s.User__r.ContactId == $scope.selectedStudentId);
                if(student){
                    $scope.selectStudentNote(student);
                }
            }
            $scope.filterYears = [{value: 'any', text: 'any'}];
            let today = new Date();
            let maxGradYear = today.getFullYear();
            for (let index = 0; index < result.length; index++) {
                const student = result[index];
                maxGradYear = student.Contact.Graduation_Year__c > maxGradYear ? student.Contact.Graduation_Year__c : maxGradYear;                
            }
            if(maxGradYear > today.getFullYear()){
                for (let index = today.getFullYear(); index <= maxGradYear; index++) {
                    $scope.filterYears.push({value: index, text: index.toString()});
                }    
            }            
            $scope.studentFilterGradYear = $scope.filterYears[0];
            $scope.loading = false;
        }, function(error){
            $scope.error = error;
            $scope.loading = false;
        });
    }

    $scope.selectStudent = function(student){
        $scope.noteLoading = true;
        $scope.selectedStudent = student;
        advisingNotesService.getAdvisingNotes(student.Id).then(function(result){
            $scope.selectedStudent.notes = result;
            $scope.changeTab($scope.selectedStudent.notes[0]);
            $scope.noteLoading = false;
        }, function(error){
            $scope.error = error;
            $scope.selectNote = null;
            $scope.noteLoading = false;
        })
    }

    $scope.getLabel = function(tab){
        return tab.RecordType.Name.replace('My', '');
    }

    $scope.selectYear = function(item){
        $scope.studentFilterGradYear = item;
    }

    $scope.changeTab = function(tab){
        tab.My_Note__c = fixHTMLTagsFilter(tab.My_Note__c);
        $scope.activeTab = tab;
    }

    $scope.yearFilter = function(yearFilter){
        return function(student) {
            if(yearFilter != 'any'){
                return student.Contact.Graduation_Year__c == yearFilter
            }
            return true;
        }
    }

    $scope.studentsFilter = function(filterText){
        return function(student) {
            if(!filterText){
                return true;
            }
            return student.Contact.LastName.search(filterText) >= 0 || (student.Contact.Preferred_Name__c &&  student.Contact.Preferred_Name__c.search(filterText) >= 0) || student.Contact.LastName.search(filterText) >= 0;
        }
    }

    $scope.init();
});