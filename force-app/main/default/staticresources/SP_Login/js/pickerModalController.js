app.controller('pickerModalController', function ($scope, $modalInstance, data) {
    $scope.pickerOptions = data.pickerOptions;
    $scope.title = data.title;
    $scope.labelField = data.labelField;
    $scope.pickerType = data.type;

    $scope.selectedOption = null;
    $scope.unlistedSelected = false;
    
    // Complete modal activity and save result back to page
    $scope.ok = function () {
        $scope.pickerOptions.forEach(item => {
            delete item.active;
        });
        $modalInstance.close($scope.selectedOption);
    }

    // Cancel modal activity
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    }

    $scope.select = function(item) {
        $scope.pickerOptions.forEach(pt => {
            if(item != pt){
                pt.active = false;
            }
            item.active = true;
            $scope.selectedOption = item;
        });        
    }

    $scope.selectUnlisted = function(name) {
        $scope.selectedOption = {};
        $scope.selectedOption[$scope.labelField] = name;
        $scope.unlistedSelected = true;
    }

    $scope.listFilter = function(search, labelField) {
        return function(item){
            if(!search){
                return true;
            }
            else{
                return item[labelField].toLowerCase().search(search.toLowerCase()) >= 0;
            }
        }
    }

});