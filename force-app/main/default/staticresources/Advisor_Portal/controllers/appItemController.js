angular.module('app.controllers')
.controller('appItemController', function ($scope, $modalInstance, data, Upload, $timeout, $sce, apostrapheFilter, ampersandFilter, quoteFilter, $filter, urlService) {
    $scope.data = data;
    if($scope.data.recordType == "Learning_Plan")
    {
        $scope.data.status = "Complete"; 
        $scope.data.academicGoalsA = $filter('apostraphe')($scope.data.academicGoalsA);
        $scope.data.academicGoalsB = $filter('apostraphe')($scope.data.academicGoalsB);
        $scope.data.academicGoalsC = $filter('apostraphe')($scope.data.academicGoalsC);
        $scope.data.personalGoalsA = $filter('apostraphe')($scope.data.personalGoalsA);
        $scope.data.personalGoalsB = $filter('apostraphe')($scope.data.personalGoalsB);
        $scope.data.personalGoalsC = $filter('apostraphe')($scope.data.personalGoalsC);
        $scope.data.professionalGoalsA = $filter('apostraphe')($scope.data.professionalGoalsA);
        $scope.data.professionalGoalsB = $filter('apostraphe')($scope.data.professionalGoalsB);
        $scope.data.professionalGoalsC = $filter('apostraphe')($scope.data.professionalGoalsC);
        $scope.data.specificActions1 = $filter('apostraphe')($scope.data.specificActions1);
        $scope.data.specificActions2 = $filter('apostraphe')($scope.data.specificActions2);
        $scope.data.specificActions3 = $filter('apostraphe')($scope.data.specificActions3);
        $scope.data.specificActions4 = $filter('apostraphe')($scope.data.specificActions4);
        $scope.data.specificActions5 = $filter('apostraphe')($scope.data.specificActions5);
        $scope.data.otherInformation = $filter('apostraphe')($scope.data.otherInformation);
        $scope.data.academicGoalsA = $filter('quote')($scope.data.academicGoalsA);
        $scope.data.academicGoalsB = $filter('quote')($scope.data.academicGoalsB);
        $scope.data.academicGoalsC = $filter('quote')($scope.data.academicGoalsC);
        $scope.data.personalGoalsA = $filter('quote')($scope.data.personalGoalsA);
        $scope.data.personalGoalsB = $filter('quote')($scope.data.personalGoalsB);
        $scope.data.personalGoalsC = $filter('quote')($scope.data.personalGoalsC);
        $scope.data.professionalGoalsA = $filter('quote')($scope.data.professionalGoalsA);
        $scope.data.professionalGoalsB = $filter('quote')($scope.data.professionalGoalsB);
        $scope.data.professionalGoalsC = $filter('quote')($scope.data.professionalGoalsC);
        $scope.data.specificActions1 = $filter('quote')($scope.data.specificActions1);
        $scope.data.specificActions2 = $filter('quote')($scope.data.specificActions2);
        $scope.data.specificActions3 = $filter('quote')($scope.data.specificActions3);
        $scope.data.specificActions4 = $filter('quote')($scope.data.specificActions4);
        $scope.data.specificActions5 = $filter('quote')($scope.data.specificActions5);
        $scope.data.otherInformation = $filter('quote')($scope.data.otherInformation);
        $scope.data.academicGoalsA = $filter('ampersand')($scope.data.academicGoalsA);
        $scope.data.academicGoalsB = $filter('ampersand')($scope.data.academicGoalsB);
        $scope.data.academicGoalsC = $filter('ampersand')($scope.data.academicGoalsC);
        $scope.data.personalGoalsA = $filter('ampersand')($scope.data.personalGoalsA);
        $scope.data.personalGoalsB = $filter('ampersand')($scope.data.personalGoalsB);
        $scope.data.personalGoalsC = $filter('ampersand')($scope.data.personalGoalsC);
        $scope.data.professionalGoalsA = $filter('ampersand')($scope.data.professionalGoalsA);
        $scope.data.professionalGoalsB = $filter('ampersand')($scope.data.professionalGoalsB);
        $scope.data.professionalGoalsC = $filter('ampersand')($scope.data.professionalGoalsC);
        $scope.data.specificActions1 = $filter('ampersand')($scope.data.specificActions1);
        $scope.data.specificActions2 = $filter('ampersand')($scope.data.specificActions2);
        $scope.data.specificActions3 = $filter('ampersand')($scope.data.specificActions3);
        $scope.data.specificActions4 = $filter('ampersand')($scope.data.specificActions4);
        $scope.data.specificActions5 = $filter('ampersand')($scope.data.specificActions5);
        $scope.data.otherInformation = $filter('ampersand')($scope.data.otherInformation);

    }
    $scope.appItemTitle = data.name + ' - ' + data.status;
    $scope.isAdvisor = true;
    $scope.portal = 'advisorportal';
    if($scope.isComplete == null) {
        $scope.isComplete = $scope.data.Status == 'Complete';
    }
    $scope.loadingGif = urlService.getLoadingGifURL();
    $scope.submittingData = false;
    $scope.displayText = $sce.trustAsHtml($scope.data.TextToSign);
    $scope.errorMessage = '';
    $scope.file = null;
    $scope.submit = function() {
        $scope.loading = true;
        $scope.submittingData = true;
        $scope.errorMessage = '';
        advisorPortalController.submitApplicationItem(
            angular.toJson($scope.data),
            '',
            '',
            '',
            function(result, event) {
                $scope.changeData(result);
                $scope.submittingData = false;
                $modalInstance.dismiss('complete');
                $scope.isComplete = true;
                $scope.$apply();
            }
        );
        
    }
    $scope.changeData = function(result) {
        if(result == 'Complete') {
            $scope.data.isComplete = true;
            $modalInstance.close($scope.data.isComplete);
        }
        else if(result == 'ERROR: Your session has been corrupted, please log out and log back in to try again.') {
            alert(result);
            // Users will be logged out of the student portal because they somehow where running as the guest site user;
            window.location.href = '/advisorportal/secur/logout.jsp';
        }
        else {
            alert(result);
            return;
        }
        
    }
    $scope.closeModal = function() {
        $modalInstance.dismiss('complete');
    }
});