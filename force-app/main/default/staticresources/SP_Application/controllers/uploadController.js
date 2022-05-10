/**
 * Student Portal Upload Page Controller
 * @file Student Portal Upload Page Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('uploadController', function($scope,  $routeParams, fileUploadService, errorModalService)
{
    $scope.appItemId = $routeParams.parentId;
    $scope.isImage = false;
    $scope.isProcessing = false;
    $scope.save = function() {
        $scope.isProcessing = true;
        if($scope.isImage)
        {
            $scope.compressImage();
        }
        else
        {
            $scope.uploadFile();
        }
    }

    $scope.compressImage = function() {
        const fileName = $scope.fileToUpload.name;
        const reader = new FileReader();
        reader.readAsDataURL($scope.fileToUpload);
        reader.onload = event => {
            const img = new Image();
            img.src = event.target.result;
            img.onload = () => {
                    const elem = document.createElement('canvas');
                    const width = 1000;
                    const scaleFactor = width / img.width;
                    elem.width = width;
                    elem.height = img.height * scaleFactor;
                    const ctx = elem.getContext('2d');
                    // img.width and img.height will contain the original dimensions
                    ctx.drawImage(img, 0, 0, elem.width, elem.height);
                    ctx.canvas.toBlob((blob) => {
                        const file = new File([blob], fileName + '.jpg', {
                            type: 'image/jpeg',
                            lastModified: Date.now()
                        });
                        $scope.fileToUpload = file;
                        $scope.uploadFile();
                    }, 'image/jpeg', 1);
                },
                reader.onerror = error => console.log(error);
        };
    }

    $scope.uploadFile = function() {
        var promise = fileUploadService.uploadFileToSalesforce($scope.appItemId, $scope.fileToUpload);
        promise.then(function(result){
            // File uploaded
            //$scope.loadSuccessModal({message: 'File Upload Successful!'});
            window.location.assign('#/');
        },function(result){
            // Upload failed
            //$scope.loadErrorModal(result);
            errorModalService.openErrorModal('An error has occured uploading your file', 'There was an error has occured uploading your file. Please try again. If you continue to have problems, contact IFSA.');
            $scope.isProcessing = false;
        });
    }

    $scope.checkFileType = function(files){
        let file = files[0];
        $scope.isImage = file.type.indexOf('image/') !== -1;
    }
});