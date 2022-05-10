app.controller('termSelectorModalController', function ($scope, $modalInstance, programTerms, $filter) {
    $scope.programTermOptions = programTerms;
    $scope.selectedTerm = null;
    
    // Complete modal activity and save result back to page
    $scope.ok = function () {
        $scope.programTermOptions.forEach(item => {
            if(item.Program_Terms__r && item.Program_Terms__r.length){
                item.Program_Terms__r.forEach(po => {
                    delete po.active;
                });
            }
            delete item.active;
        });
        $scope.selectedTerm.Name = $filter('apostraphe')($scope.selectedTerm.Name);
        $modalInstance.close($scope.selectedTerm);
    }

    // Cancel modal activity
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    }

    $scope.select = function(item) {
        $scope.programTermOptions.forEach(pt => {
            if(item != pt){
                pt.active = false;
            }
            else if(item.Program_Terms__r && item.Program_Terms__r.length){
                $scope.selectedParentProgramTerm = item;
            }
            else{
                item.active = true;
                $scope.selectedTerm = item;
            }
        });
    }

    $scope.selectOption = function(item) {
        let parentPT = $scope.programTermOptions.find(pt => pt.Id == item.Parent_Program_Term__c);
        
        parentPT.Program_Terms__r.forEach(po => {
            if(item != po){
                po.active = false;
            }
        });
        
        item.active = true;
        $scope.selectedTerm = item;
    }

    $scope.goBack = function(){
        $scope.selectedParentProgramTerm = null;
    }

});