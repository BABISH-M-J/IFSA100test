angular.module('app.filters')
.filter('newStudents', function($filter){
    return function(input, filterName, filterStatus, filterCountry, filterTerm, filterYear, filterOtherOptions){
        let filteredStudents = [];
        if(input == undefined || input == null)
        {
            return null;
        }
        for (let index = 0; index < input.length; index++) {
            const student = input[index];
            let match = true;
            
            if(filterName && student.Name.toLowerCase().indexOf(filterName.toLowerCase()) === -1){
                match = false;
                continue;
            }
            if(filterOtherOptions == 'leads' && student.applications.length){
                match = false;
                continue;
            }
            else if(filterOtherOptions == 'pending'){
                let appMatch = false;
                for (let appIndex = 0; appIndex < student.applications.length; appIndex++) {
                    const application = student.applications[appIndex];
                    if(application.programApprovalStatus == 'Incomplete' || application.programApprovalStatus == null)
                    {
                        appMatch = true;
                        break;
                    }
                }
                if(!appMatch){
                    match = false;
                }
            }
            else if(filterOtherOptions == 'searches'){
                if(!student.savedSearches || !student.savedSearches.length){
                    match = false;
                }
            }
            else if(filterOtherOptions == 'notes'){
                if(!student.toolBoxNotes || !student.toolBoxNotes.length){
                    match = false;
                }
            }
            else if(filterOtherOptions == 'favorites'){
                if(!student.favoritePrograms || !student.favoritePrograms.length){
                    match = false;
                }
                
            }
            student.filteredApplications = $filter('newApplication')(student.applications, filterStatus, filterCountry, filterTerm, filterYear);
            if(student.filteredApplications && !student.filteredApplications.length && (filterStatus != "" || filterCountry != "" || filterTerm != "" || filterYear != "")){
                match = false;
            }
            else{
                if(!student.filteredApplications.length && filterOtherOptions == 'pending')
                {
                    match = false;
                }
            }
            
            if(match)
            {
                filteredStudents.push(student);
            }
        }
        
        return filteredStudents;
    }
})
.filter('newApplication', function(){
    return function(input, filterStatus, filterCountry, filterTerm, filterYear){
        let filteredApps = [];
        if(input == undefined || input == null)
        {
            return null;
        }
        for (let index = 0; index < input.length; index++) {
            const app = input[index];
            let match = true;
            if(filterStatus != "" && app.Status != filterStatus){
                match = false;
            }
            if(match && (filterCountry != "" && app.Program_Country != filterCountry)){
                match = false;
            }
            if(match && (filterTerm != "" && app.Program_Term_Section != filterTerm)){
                match = false;
            }
            if(match && (filterYear != "" && app.Program_Term_Year != filterYear)){
                match = false;
            }
            /* if(match && app.Is_Custom){
                match = false;
            } */

            if(match){
                filteredApps.push(app);
            }
        }

        return filteredApps;
    }
})