angular.module('app.controllers')
.controller('resourcesController', function($scope, viewModel, resourcesService, urlService, $routeParams) 
{
    $scope.loading = true;
    $scope.templateURL = urlService.getBaseResourceURL() + '/views/';
    $scope.selectedCategory = undefined;
    $scope.selectedFile = undefined;
    $scope.resourceParam = $routeParams.option;

    $scope.selectCategory = function(category){
        if($scope.selectedCategory){
            $scope.selectedCategory.visible = false;
        }
        category.visible = true;
        $scope.selectedCategory = category;
        $scope.selectedFile = undefined;
    }

    $scope.selectFile = function(file){
        $scope.selectedFile = file;
    }

    $scope.unselect = function(type){
        switch (type) {
            case 'file':
                $scope.selectedFile = undefined;                
                break;
            case 'category':
                $scope.selectedCategory.visible = false;
                $scope.selectedCategory = undefined;
                $scope.selectedFile = undefined;
                break;
            default:
                break;
        }
    }

    $scope.categoriesCSS = function(){
        if($scope.selectedCategory && !$scope.selectedFile){
            return 'mobile hiddenIFSA column';
        }
        else if($scope.selectedFile && $scope.selectedCategory){
            return 'tablet or lower hiddenIFSA column';
        }
        else{
            return 'column';
        }
    }
    $scope.filesCSS = function(){
        if($scope.selectedFile && $scope.selectedCategory){
            return 'mobile hiddenIFSA column';
        }
        else {
            return 'column';
        }
    }

    $scope.init = function(){
        resourcesService.getResourceFiles().then(function(result){
            $scope.resourceFiles = result;
            let i = 0;
            while (!$scope.selectedFile && i < $scope.resourceFiles.length) {
                let file;
                try {
                    file = $scope.resourceFiles[i].files.find(f => f.Id == $scope.resourceParam);    
                } catch (error) {
                    
                }
                
                if(!file){
                    i = ++i;
                }
                else{
                    $scope.selectCategory($scope.resourceFiles[i]);
                    $scope.selectFile(file);
                }
            }
            
            $scope.loading = false;
        }, function(error){
            $scope.error = error;
            $scope.loading = false;
        });
    }

    $scope.getFileType = function(type){
        switch (type.toLowerCase()) {
            case 'pdf':
                return 'red pdf';
            case 'doc':
            case 'docx':
                return 'blue word';
            case 'xls':
            case 'xlsx':
            case 'csv':
                return 'green excel';
            case 'jpg':
            case 'gif':
            case 'png':
                return 'image';
            case 'ppt':
            case 'pptx':
                return 'orange powerpoint';
            case 'zip':
                return 'archive';
            default:
                return '';
        }
    }

    $scope.init();
});