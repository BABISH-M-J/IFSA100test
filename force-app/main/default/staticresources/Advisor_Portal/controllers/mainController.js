angular.module('app.controllers')
.controller('mainController', function($scope, viewModel) 
{
    $scope.init = function(){
        $scope.viewModel = viewModel.getViewModel();

        let now = new Date();

        if(now.getHours() >= 17 && now.getHours() < 24){
            $scope.greeting = 'Good evening, ';
        }
        if(now.getHours() >= 0 && now.getHours() < 4){
            $scope.greeting = 'Welcome, '
        }
        else if(now.getHours() >= 4 && now.getHours() < 12){
            $scope.greeting = 'Good morning, ';
        }
        else if(now.getHours() >= 12 && now.getHours() < 17){
            $scope.greeting = 'Good afternoon, ';
        }

        if(!$scope.viewModel.isLockDownActive){
            $scope.tiles = [];
            let institutionTileText = $scope.viewModel.institutionTileText.replace('${$scope.viewModel.InstitutionName}', $scope.viewModel.InstitutionName);
            let prospectiveStudentsTileText = $scope.viewModel.propectiveStudentsTileText.replace('${$scope.viewModel.InstitutionName}', $scope.viewModel.InstitutionName);
            $scope.tiles.push({
                heading: `${$scope.viewModel.InstitutionName} Information`,
                url: '#/institution',
                details: institutionTileText
            });

            if($scope.viewModel.approvedForAdvising){
                $scope.tiles.push({
                    heading: 'Student Information: Approve your Students',
                    url: '#/students_v2/all',
                    details: $scope.viewModel.studentsTileText
                });
            }

            $scope.tiles.push({
                heading: 'Your Profile',
                url: '#/profile',
                details: $scope.viewModel.profileTileText
            });
            
            if($scope.viewModel.showToolbox){
                $scope.tiles.push({
                    heading: 'Global Wayfinder leads',
                    url: '#/students_v2/leads',
                    details: prospectiveStudentsTileText
                });
            }

            $scope.tiles.push({
                heading: 'Resources',
                url: '#/resources',
                details: 'Downloadable resources to make your advising process easier'
            });

            $scope.tiles.push({
                heading: 'CHART',
                url: '/chart/',
                details: $scope.viewModel.chartTileText
            });
        }
        else{
            $scope.viewModel.introText = 'The IFSA Advisor Portal is not available at this time';
        }
    }

    $scope.init();
})