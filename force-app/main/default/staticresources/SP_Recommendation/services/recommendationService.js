/**
 * Student Portal Recommendation Service
 * @file Student Portal Recommendation Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('recommendationService', function($q, $timeout, $http, $filter, fixHTMLTagsFilter, richTextParseService, sanitizer, urlService) {
    var self = this;
    var deferred;

    imageDictionary = {};
    toDataURL(urlService.getIFSALetterheadURL(), function(dataUrl) {
        imageDictionary['letterhead'] = dataUrl;
    });
    toDataURL(urlService.getIFSAFooterURL(), function(dataUrl) {
        imageDictionary['footer'] = dataUrl;
    });

    this.submitRecommendation = function(viewModel, doc)
    {
        deferred = $q.defer();
        var canvas = document.getElementById("signature");
        canvas.toBlob(function(blob) {
            var reader = new FileReader();
            reader.readAsDataURL(blob);
            reader.onloadend = function() {
                self.createPdf(viewModel, reader.result, doc);
            }            
        });
        
        return deferred.promise;
    }

    this.createPdf = function(viewModel, signature, doc){
        var docDefinition = {
            content: [],
            header: function(page, pages){
                if(page == 1){
                    return {
                        width: 600,
                        image: imageDictionary['letterhead'],
                        margin: [0, -28, 0, 0]
                    }
                }
            },
            footer: function(page, pages){
                if(page == pages){
                    return {
                        headlineLevel: 'footer',
                        width: 600,
                        image: imageDictionary['footer'],
                        margin: [0, -20, 0, 0]
                    }
                }
            },
            styles: {
                h1: {
                    fontSize: 18,
                    bold: true
                },
                h3: {
                    fontSize: 14,
                    bold: true
                },
                label:{
                    bold:true
                },
                recommendation:{
                    margin: [10,10,10,10]
                },
                response:{
                    bold:false,
                    margin: [0,0,0,10]
                },
                signature:{
                    margin: [0,0,0,10],
                    font: 'HomemadeApple',
                    fontSize: 18
                }
            },
            pageBreakBefore: function(currentNode, followingNodesOnPage, nodesOnNextPage, previousNodesOnPage) {
              return currentNode.headlineLevel === 'signatureHeading' && followingNodesOnPage[0].headlineLevel !== 'footer';
            }
        };
        // title
        docDefinition.content.push({text: ['ONLINE RECOMMENDATION FOR ', viewModel.studentFirstName, ' ', viewModel.studentLastName, ' - ', viewModel.programTerm], margin: [0, 80, 0, 0]});
        docDefinition.content.push({text: ['\nDate: ', new Date().toLocaleDateString(), '\n\n']});
        // response
        var content = angular.copy(viewModel.content);

        content = $filter('nbsp')(content);
        content = $filter('apostraphe')(content);
        content = $filter('ampersand')(content);
        content = $filter('quote')(content);

        docDefinition.content.push(richTextParseService.parseHTML(fixHTMLTagsFilter(content)));
        //docDefinition.content.push('\n');
        // signature
        docDefinition.content.push([{text: '', style: 'label', headlineLevel: 'signatureHeading'}, {image: signature, width: 200}]);
        // Contact Info
        //docDefinition.content.push({text: '\n'});
        docDefinition.content.push(viewModel.recommendationRecommenderName);
        docDefinition.content.push(viewModel.recommendationTitle);
        docDefinition.content.push(viewModel.university);
        docDefinition.content.push(viewModel.recommendationEmail);
        docDefinition.content.push(viewModel.phone);
        
        pdfMake.fonts = {
            HomemadeApple: {
                normal: 'HomemadeApple-Regular.ttf'
            },
            Roboto: {
                normal: 'Roboto-Regular.ttf',
                bold: 'Roboto-Bold.ttf',
                italics: 'Roboto-Italic.ttf'
            }
        }
        //var pdf = pdfMake.createPdf(docDefinition).open(); // Commented out for production, Uncomment for testing so the document is not submitted to Salesforce
        var pdf = pdfMake.createPdf(docDefinition);
        pdf.getBase64((data) => {
            viewModel.fileData = data;
            viewModel.fileType = 'application/pdf';
            viewModel.fileName = 'Recommendation ' + viewModel.recommendationName + '.pdf';
            var jsonData = angular.toJson(viewModel);
            studentRecommendationController.submitRecommendation(
                jsonData,
                function(result, event){
                    if(result && result == '/studentportal/SP_RecommendationSuccess'){
                        deferred.resolve(result);
                    }
                    else{
                        deferred.reject(result);
                    }
            });
        });
        //deferred.reject('Testing');
    }

    function toDataURL(url, callback){
        var xhr = new XMLHttpRequest();
        xhr.onload = function() {
            var reader = new FileReader();
            reader.onloadend = function() {
            callback(reader.result);
            }
            reader.readAsDataURL(xhr.response);
        };
        xhr.open('GET', url);
        xhr.responseType = 'blob';
        xhr.send();
    }
});