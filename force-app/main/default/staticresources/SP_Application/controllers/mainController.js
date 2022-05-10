/**
 * Student Portal Main Page Controller
 * @file Student Portal Main Page Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('mainController', function($scope, $sce, $modal, urlService, viewModel, applicationService, applicationItemService, dateService, $timeout) 
{
    
    //datepicker
    var validViews = ['year', 'month', 'day', 'hour', 'minute'];
    var selectable = true;
    //datepicker
    $scope.departureOnSetTime = departureOnSetTime;
    $scope.arrivalOnSetTime = arrivalOnSetTime;
    $scope.viewModel = viewModel.getViewModel();
    $scope.loadingAppItems = true;
    if($scope.viewModel.isDropped)
    {
        window.location.assign('#/social');
    }
    else if(!$scope.viewModel.profileCompleted && !$scope.viewModel.isCustom)
    {
        window.location.assign('#/register');
    }
    else if(!$scope.viewModel.isProgramSelected)
    {
        window.location.assign('#/select');
    }
    $scope.init = function(){
        console.log('START init');
        console.log('init hasScholarship => ' + $scope.viewModel.hasScholarship);
        let appPromise = applicationService.getApplicationPromise();
        // Build viewModel from student's application result
        appPromise.then(function(result){
            let popAppItemPromise = applicationItemService.getPopAppItemsPromise();
            $scope.viewModel.programApprovalCompleted = result.Program_Approval_Completed_By__c != null ? true : false;
            $scope.appContractSigned = result.Status_Contract_Signed__c;
            if(popAppItemPromise){
                popAppItemPromise.then(function(result){
                    $scope.loadAppItems();
                }, function(err){
                    console.error(err);
                })
            }
            else{
                $scope.loadAppItems();
            }
        },
        function(result){});
        $scope.urlService = urlService;			
        $scope.addScholarship = function (appId) {
            console.log('START addScholarship');
            window.location.assign($scope.viewModel.scholarshipURL);
            portalRemotingMethods.addScholarshipItem(
                appId, 
                function(result, event) {
                    $scope.scholarshipItemAdded(result, event);
                }
            );				
        }
        console.log('END init');
    }
    
    
    
    $scope.loadAppItems = function(){
        console.log('START loadAppItems');
        let today = new Date();
        let fourteenDays = new Date($scope.appContractSigned);
        let onlyMedForm = false;            
        fourteenDays.setDate(fourteenDays.getDate() + 14);
        var appItemsPromise = applicationItemService.getApplicationItems($scope.viewModel.applicationId);
        appItemsPromise.then(function(result){
        for (let index = 0; index < result.length; index++) {
            const appItem = result[index];
            appItem.loading = false;
            if(appItem.recordTypeName == 'Medical Form' && appItem.status != 'Complete' && today > fourteenDays) {
                onlyMedForm = true;
                $scope.viewModel.fillOutMedicalForm = $scope.viewModel.portalSettings.find(s => s.DeveloperName == 'SP_Must_Fill_Out_Medical_Form')["Content__c"];
            }
            if(appItem.recordTypeName == 'Download-Upload' && appItem.name == 'Scholarship'){
                $scope.viewModel.hasScholarship = true;
            }
            /*if(appItem.recordTypeName == 'Download-Upload'){
                for(key in appItem){
                    console.log(key + ' => ' + appItem[key]);
                }
            } */           
        }
        let appItems = [];
        if(result.length){
            for(let index = 0; index < result.length; index++){
                const appItem = result[index];
                if(appItem.deadline){
                    appItem.deadline != null ? appItem.deadline = dateService.convertDate(appItem.deadline) : null;
                }
                if(((onlyMedForm && appItem.recordTypeName == 'Medical Form') || appItem.status == 'Complete') || !onlyMedForm){
                    appItems.push(appItem);
                }
            }
        }
        $scope.loadingAppItems = false;
        $scope.viewModel.appItems = appItems;
        console.log('END loadAppItems');
    },
    function(result){
        console.log(result);
    });
    }
    $scope.scholarshipItemAdded = function(result, event) {
        console.log('scholarship result => ' + result);
        if(result != null)
        {					
            console.log('scholarshipItemAdded');
            $scope.viewModel.appItems.push(result);
            $scope.viewModel.hasScholarship = true;
            console.log('hasScholarship => ' + $scope.viewModel.hasScholarship);
            $scope.$apply();
        }
    }

    $scope.viewAppItem = function (item) {
        item.loading = true;
        if(item.recordTypeName != 'Class Interest Form')
        {
            location.assign('#/ApplicationItem/' + item.id);
        }
        else
        {
            location.assign('#/ClassInterestForm/' + item.id);
        }
    }
    
    $scope.loadPAIntroVideoModal = function() {
        var modalInstance = $modal.open({
            animation: true,
            size: 'lg',
            templateUrl: urlService.getBaseResourceURL() + '/views/shared/modals/paIntroVideoModal.html',
            resolve: {
                data: {
                    paName: $scope.viewModel.advisorFirstName + ' ' + $scope.viewModel.advisorLastName,
                    paIntroVideo: $scope.viewModel.paIntroVideo
                }
            },
            controller: 'paIntroVideoModalController'
        });
    }

    $scope.init();
});