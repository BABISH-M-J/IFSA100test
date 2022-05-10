/**
 * Grade Report Service
 * @file Grade Report Service
 * @copyright 2021 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsa-butler.org> 
 * @version 1.0
 */
angular.module('ifsa.common')
.filter('ifsaGradedCoursesFilter', function() {
    return function(courseRegs) {
        return courseRegs.filter(function(courseReg) {
            switch (courseReg.courseStatus) {
                // Every status where a course would be displayed
                case 'Grade Verified':
                case 'Grade Submitted':
                case 'Ready for Butler':
                    return true;            
                default:
                    return false;
            }
        });
    };
})
.service('gradeReportService', function(commonURLService, dateService, $q, $filter) {
    var self = this;
    let imageDictionary = {};
    
    commonToDataURL(commonURLService.getLetterheadURL(), function(dataUrl) {
        imageDictionary['letterhead'] = dataUrl;
    });
    commonToDataURL(commonURLService.getSPResourceURL() + '/images/IFSALogo_withTagline.png', function(dataUrl) {
        imageDictionary['logo_with_tagline'] = dataUrl;
    });
    commonToDataURL(commonURLService.getSPResourceURL() + '/images/AA_Director_Signature.jpg', function(dataUrl) {
        imageDictionary['aa_signature'] = dataUrl;
    });

    this.getCourseRegistrations = function(applicationId){
        var deferred = $q.defer();
        
        portalOnSiteRemotingMethods.getCourseRegistrations(
            applicationId,
            function(result, event) {
                if(result){
                    deferred.resolve({
                        type: 'courseRegs',
                        data: result
                    });
                }
                else {
                    deferred.reject(event);
                }
        });

        return deferred.promise;
    }

    this.getApplicationFromSF = function(applicationId)
    {
        let deferred = $q.defer();

        portalRemotingMethods.getApplication(
            applicationId,
            function(result, event) {
                if(result) {
                    application = result;
                    deferred.resolve({
                        type: 'application',
                        data: result
                    });
                }
                else {
                    application = null;
                    deferred.reject(event);
                }
        });
        return deferred.promise;
    }

    this.cleanText = function(value){
        value = $filter('apostraphe')(value);
        value = $filter('ampersand')(value)
        return value;
    }

    this.generatePDF = function(applicationId)
    {
        let deferred = $q.defer();
        let courseRegistrations;
        let application;
        $q.all([self.getApplicationFromSF(applicationId), self.getCourseRegistrations(applicationId)]).then(function(results){
            for (let index = 0; index < results.length; index++) {
                const obj = results[index];
                switch (obj.type) {
                    case 'application':
                        application = obj.data;
                        break;
                    case 'courseRegs':
                        courseRegistrations = obj.data;
                    default:
                        break;
                }
            }
            
            var studentBirthday = dateService.convertDate(new Date(application.Birthday__c));
            var docDefinition = {
                pageMargins: [ 30, 130, 30, 115 ],
                styles: {
                    tableHeader: {
                        bold: true,
                        fontSize: 13,
                        color: 'black'
                    },
                },
                header: {
                    columns: [
                        {
                            image: imageDictionary['logo_with_tagline'],
                            margin: [10, 10]
                        },
                        {
                            alignment: 'right',
                            margin: [10, 10],
                            text: 'Institute for Study Abroad\n6201 Corporate Dr. Suite 200\nIndianapolis, IN, 46278\nPhone: 317-940-9336\nToll Free: 800-858-0229\n Fax: 317-940-9762\nwww.ifsa-butler.org'
                        }
                    ]
                },
                footer: [
                    {
                        text: 'An official transcript will be issued by Butler University’s Office of Registration and Records, 4600 Sunset Avenue, Indianapolis, IN 46208. In the interim, inquiries about this student’s participation in the program overseas can be directed to the Institute for Study Abroad (317-940-9336).', 
                        margin: [25, 0, 25, 5],
                        fontSize: 10
                    },
                    {
                        columns: [
                            {text: 'Downloaded Date: ' + new Date().toLocaleDateString(), margin: [25, 15, 25, 5], fontSize: 10, width: '*'},
                            {text: 'Signed:', fontSize: 10, margin: [25, 15, 5, 5], width: 'auto'},
                            {image: imageDictionary['aa_signature'], width: 180, margin: [0, 15, 5, 5]}    
                        ]
                    }
                ],
                content: [
                    {text: ['Name: ', application.Student_First_Name__c, ' ', application.Student_Last_Name__c, ' ID: ', application.Butler_ID__c, ' DOB: ', studentBirthday.toLocaleDateString(), ' \n']},
                    {text: ['US Academic Term: ', application.Program_Term_Section__c, ' ', application.Program_Term_Year__c, '\n']},
                    {text: ['Host Institution: ', self.cleanText(application.Host_Institution__c), '\n']},
                    {text: ['Home Institution: ', self.cleanText(application.Home_Institution__c), '\n\n']}
                ]
            };
            var classesTable = {
                table: {
                    headerRows: 2,
                    widths: ['*', 225, '*', '*', '*'],
                    body:[
                        [
                            {
                                border: [false, false, false, false],
                                fillColor: '#8C8E8F',
                                text: 'Report of Credits Earned for Study Abroad', 
                                style: 'tableHeader', 
                                colSpan: 5, 
                                alignment: 'center'
                                
                            },{},{},{},{}
                        ],
                        [
                            {text: 'Department', style: 'tableHeader', border: [false, false, false, false], fillColor: '#8C8E8F'},
                            {text: 'Course Information', style: 'tableHeader', border: [false, false, false, false], fillColor: '#8C8E8F'},
                            {text: 'Attempted', style: 'tableHeader', border: [false, false, false, false], fillColor: '#8C8E8F'},
                            {text: 'Earned', style: 'tableHeader', border: [false, false, false, false], fillColor: '#8C8E8F'},
                            {text: 'Grade', style: 'tableHeader', border: [false, false, false, false], fillColor: '#8C8E8F'},
                        ]
                    ]
                }
            }

            var gradedCourseRegistrations = $filter('ifsaGradedCoursesFilter')(courseRegistrations);
            
            for (let index = 0; index < gradedCourseRegistrations.length; index++) {
                const cr = gradedCourseRegistrations[index];
                classesTable.table.body.push(
                    [
                        {text: cr.departmentCodeString, border: [false, false, false, false]},
                        {text: self.cleanText(cr.courseTitle) + ' ' + self.cleanText(cr.hostInstitutionName) + ' ' +  cr.courseCode, border: [false, false, false, false]},
                        {text: cr.usCredits, border: [false, false, false, false]},
                        {text: cr.usCreditsEarned, border: [false, false, false, false]},
                        {text: cr.courseGrade, border: [false, false, false, false]},
                    ]
                );
            }
            docDefinition.content.push(classesTable);
            docDefinition.content.push('\n\n\n');
            var summaryTable = {
                table: {
                    headerRows: 1,
                    widths: ['*', 'auto', 75,],
                    body:[
                        [
                            {border: [false, false, false, false], text:''},{
                                fillColor: '#8C8E8F',
                                text: 'Transcript Summary', 
                                style: 'tableHeader', 
                                colSpan: 2, 
                                alignment: 'center'
                                
                            },{}
                        ],
                        [
                            {border: [false, false, false, false], text:''},
                            {text: 'GPA', alignment: 'right'},
                            {text: application.Program_GPA__c}
                        ],
                        [
                            {border: [false, false, false, false], text:''},
                            {text: 'Credits Attempted', alignment: 'right'},
                            {text: application.Credits_Attempted__c}
                        ],
                        [
                            {border: [false, false, false, false], text:''},
                            {text: 'Credits Earned', alignment: 'right'},
                            {text: application.Credits_Earned__c}
                        ]
                    ]
                }
            }
            docDefinition.content.push(summaryTable);
            pdfMake.fonts = {
                Roboto: {
                    normal: 'Roboto-Regular.ttf',
                    bold: 'Roboto-Bold.ttf',
                    italics: 'Roboto-Italic.ttf'
                }
            }
            pdfMake.createPdf(docDefinition).open();
            deferred.resolve(true);
            // var win = window.open('', '_blank');
            // $http.post('/someUrl', data).then( function (response) {
            //     pdfMake.createPdf(docDefinition).open(win);
            // });
        }, function(errors){
            deferred.reject(errors);
        })
        return deferred.promise;
    }
});

function commonToDataURL(url, callback) {
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