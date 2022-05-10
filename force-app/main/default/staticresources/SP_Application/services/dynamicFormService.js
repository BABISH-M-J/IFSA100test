/**
 * Student Portal Dynamic Form Service
 * @file Student Portal Dynamic Form Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('dynamicFormService', function ($q, $filter, fixHTMLTagsFilter, richTextParseService, sanitizer, urlService, classInterestService) {
    var self = this;
    var submitDynamicDeferred;
    var form;
    var imageDictionary;
    var appItemName;
    var tempRecords;
    var tempRecordsPromise;

    this.processForm = function (form) {
        for (let index = 0; index < form.formData.items.length; index++) {
            const formItem = form.formData.items[index];
            if (formItem.response == 'true') {
                formItem.response = true;
            }
            else if (formItem.response == 'false') {
                formItem.response = false;
            }
            else if (formItem.fieldType == 'Date_Time' || formItem.fieldType == 'Date') {
                formItem.response = new Date(formItem.response);
            }
            else if (formItem.fieldType == 'Number') {
                formItem.response = Number(formItem.response);
            }
            else if (formItem.fieldType == 'Picklist') {
                formItem.values = formItem.values.split(', ');
            }
            else if (formItem.fieldType == 'No_Response_Required') {
                formItem.noReponseText = sanitizer.trustHtml(formItem.noResText);
                formItem.noResText = formItem.noResText;
            }
        }
        self.setForm(form);
        for (let index = 0; index < form.formData.items.length; index++) {
            const formItem = form.formData.items[index];

            self.processRules(formItem);
        }
        imageDictionary = {};
        toDataURL(urlService.getIFSALetterheadURL(), function (dataUrl) {
            imageDictionary['letterhead'] = dataUrl;
        });
        toDataURL("https://img.icons8.com/material-outlined/24/000000/checked-2.png", function (dataUrl) {
            imageDictionary['checkedTrue'] = dataUrl;
        });
        toDataURL("https://img.icons8.com/material-outlined/24/000000/unchecked-checkbox.png", function (dataUrl) {
            imageDictionary['checkedFalse'] = dataUrl;
        });
    }

    this.getForm = function () {
        return form;
    }

    this.setForm = function (f) {
        form = f;
    }

    this.submitDynamicForm = function (form, name) {
        submitDynamicDeferred = $q.defer();
        appItemName = name;

        if (form.formData.recordType == 'CIF') {
            tempRecordsPromise = classInterestService.getCourseRegistrations();
            tempRecordsPromise.then(function (result) {
                tempRecords = result;
                self.processSubmission(form, name);
            }, function (error) {
                tempRecords = 'Error';
            })
        }
        else {
            self.processSubmission(form, name);
        }

        return submitDynamicDeferred.promise;
    }

    this.processSubmission = function (form, name) {
        form.formData.items = form.formData.items.sort(function (obj1, obj2) {
            return obj1.pos - obj2.pos;
        });
        var hasSignature = false;
        for (let index = 0; index < form.formData.items.length; index++) {
            const element = form.formData.items[index];
            if (element.fieldType == 'Signature') {
                var canvas = document.getElementById("signature");
                if (canvas != undefined) {
                    hasSignature = true;
                    canvas.toBlob(function (blob) {
                        var reader = new FileReader();

                        reader.readAsDataURL(blob);
                        reader.onloadend = function () {
                            self.createPdf(form.formData, reader.result);
                        }
                    });
                }
            }
        }
        if (!hasSignature) {
            self.createPdf(form.formData, null);
        }
    }

    this.createPdf = function (formData, signature) {
        var formItems = formData.items;
        var docDefinition = {
            content: [
                {
                    width: 600,
                    image: imageDictionary['letterhead']
                },
                {
                    text: formData.recordType == 'CIF' ? 'Class Interest Form' : formData.formName.replace(/&#39;/g, "'"),
                    style: 'header',
                    alignment: 'center'
                }
            ],
            styles: {
                header: {
                    fontSize: 18,
                    bold: true
                },
                label: {
                    bold: true
                },
                response: {
                    bold: false,
                    margin: [0, 0, 0, 2]
                },
                signature: {
                    margin: [0, 0, 0, 10],
                    font: 'HomemadeApple',
                    fontSize: 18
                },
                tableHeader: {
                    bold: true,
                    fontSize: 13,
                    color: 'black'
                },
                alternateRow: {
                    fillColor: '#CCCCCC'
                }
            },
            pageBreakBefore: function (currentNode, followingNodesOnPage, nodesOnNextPage, previousNodesOnPage) {
                return currentNode.headlineLevel === 1 && followingNodesOnPage.length === 0;
            }
        };
        // Iterate over the form
        for (let index = 0; index < formItems.length; index++) {
            const formItem = formItems[index];
            if (formItem.fieldType != 'Page_Break' && !formItem.hideOnPDF && formItem.showLabel) {
                docDefinition.content.push({ text: formItem.label, style: ['label'], headlineLevel: 1 });
            }
            if (formItem.fieldType != 'Signature' && formItem.fieldType != 'Signature_Typed' && formItem.fieldType != 'Initial' && formItem.fieldType != 'No_Response_Required' && formItem.fieldType != 'Date' && formItem.fieldType != 'Date_Time' && formItem.fieldType != 'Check_Box' && !formItem.hideOnPDF) {
                docDefinition.content.push({ text: formItem.response, style: ['response'] });
            }
            if (formItem.fieldType == 'Date' && !formItem.hideOnPDF) {
                var response = $filter('date')(formItem.response, 'shortDate');
                docDefinition.content.push({ text: response, style: ['response'] });
            }
            if (formItem.fieldType == 'Date_Time' && !formItem.hideOnPDF) {
                var response = $filter('date')(formItem.response, 'short');
                docDefinition.content.push({ text: response, style: ['response'] });
            }
            if (formItem.fieldType == 'Check_Box' && formItem.response && !formItem.hideOnPDF) {
                docDefinition.content.push({
                    image: imageDictionary['checkedTrue']
                });
                docDefinition.content.push('\n');
            }
            if (formItem.fieldType == 'Check_Box' && !formItem.response && !formItem.hideOnPDF) {
                docDefinition.content.push({
                    image: imageDictionary['checkedFalse']
                });
                docDefinition.content.push('\n');
            }
            if (formItem.fieldType == 'No_Response_Required' && !formItem.hideOnPDF) {
                var noResponse = formItem.noResText;

                noResponse = $filter('nbsp')(noResponse);
                noResponse = $filter('apostraphe')(noResponse);
                noResponse = $filter('ampersand')(noResponse);
                noResponse = $filter('quote')(noResponse);
                var noResponse = richTextParseService.parseHTML(fixHTMLTagsFilter(noResponse));

                docDefinition.content.push(noResponse);
                docDefinition.content.push('\n');
            }
            if (formItem.fieldType == 'Signature' && !formItem.hideOnPDF) {
                docDefinition.content.push({
                    image: signature,
                    width: 300,
                });
                docDefinition.content.push({
                    text: "_______________________________________________________________________________________________"
                });
            }
            if (formItem.fieldType == 'Signature_Typed' || formItem.fieldType == 'Initial' && !formItem.hideOnPDF) {
                docDefinition.content.push({ text: formItem.response, style: ['signature'] });
            }
            if (formItem.fieldType == 'Page_Break' && !formItem.hideOnPDF) {
                docDefinition.content.push({ text: null, pageBreak: 'before' });
            }
            if (formItem.fieldType == 'CIF_Class_Table' && !formItem.hideOnPDF) {
                let courseRegistrations = [];
                if (tempRecords != null && tempRecords.length) {
                    for (let index = 1; index < tempRecords.length + 1; index++) {
                        const cr = tempRecords.find(c => c.rank == index);
                        if (cr) {
                            courseRegistrations.push(cr);
                            alternateIndex = tempRecords.findIndex(ca => ca.alternateFor == cr.courseRegId);
                            if (alternateIndex > -1) {
                                courseRegistrations.push(tempRecords[alternateIndex]);
                            }
                        }
                    }
                }

                var crBody = {
                    table: {
                        headerRows: 1,
                        headlineLevel: 1,
                        body: [
                            [
                                { text: 'Choice', style: 'tableHeader' },
                                { text: 'Course Title', style: 'tableHeader' },
                                { text: 'Course Code', style: 'tableHeader' },
                                // {text: 'Term', style: 'tableHeader'},
                                //{text: 'Department', style: 'tableHeader'},
                                { text: 'Host Credits', style: 'tableHeader' },
                                { text: 'US Semester Credits', style: 'tableHeader' }
                            ]
                        ]
                    }
                }
                if (formData.departments && formData.departments.linkClassesDept) {
                    for (let index = 0; index < courseRegistrations.length; index++) {
                        const cr = courseRegistrations[index];
                        if (cr.selectedDepartment == undefined && cr.alternateFor == null && formData.departments.selectedDepartments.findIndex(d => d.Id == 'no department') === -1) {
                            cr.selectedDepartment = 'no department';
                            formData.departments.selectedDepartments.push({ Name: ' ', Id: 'no department' });
                        }
                        else if(cr.alternateFor != null)
                        {
                            cr.selectedDepartment = 'alt';
                        }
                    }
                    courseRegistrations.sort(function (a, b) {
                        var deptA = a.selectedDepartment.toLowerCase();
                        var deptB = b.selectedDepartment.toLowerCase();
                        if (deptA < deptB) {
                            return -1;
                        }
                        if (deptA > deptB) {
                            return 1;
                        }
                        return a.rank - b.rank;
                    })
                    let choiceCount = 0;
                    for (let di = 0; di < formData.departments.selectedDepartments.length; di++) {
                        const dept = formData.departments.selectedDepartments[di];
                        if (dept.designation) {
                            departmentText = self.fixText(dept.Name) + ' - ' + self.fixText(dept.designation);
                        }

                        crBody.table.body.push([
                            { text: departmentText, colSpan: 5, bold: true }
                        ]);
                        
                        for (let ci = 0; ci < courseRegistrations.length; ci++) {
                            const cr = courseRegistrations[ci];
                            if (cr.selectedDepartment == dept.Id && cr.alternateFor == null) {
                                choiceCount = choiceCount + 1;
                                let courseRow = self.generateCourseRow(cr, choiceCount, false);
                                crBody.table.body.push(courseRow);
                                let alternateIndex = courseRegistrations.findIndex(alt => alt.alternateFor == cr.courseRegId);
                                if(alternateIndex > -1)
                                {
                                    const altClass = courseRegistrations[alternateIndex];
                                    let altRow = self.generateCourseRow(altClass, choiceCount, true);
                                    crBody.table.body.push(altRow);
                                }
                                if (cr.selectedDepartment == 'no department') {
                                    delete cr.selectedDepartment;
                                }
                            }
                        }
                    }
                    let index = formData.departments.selectedDepartments.findIndex(d => d.Id == 'no department');
                    formData.departments.selectedDepartments.splice(index, 1);
                }
                else {
                    let choiceCount = 0
                    for (let ci = 0; ci < courseRegistrations.length; ci++) {
                        const cr = courseRegistrations[ci];
                        if (cr.alternateFor == null) {
                            choiceCount = choiceCount + 1;
                            let courseRow = self.generateCourseRow(cr, choiceCount, false);
                            crBody.table.body.push(courseRow);
                            let alternateIndex = courseRegistrations.findIndex(alt => alt.alternateFor == cr.courseRegId);
                            if(alternateIndex > -1)
                            {
                                const altClass = courseRegistrations[alternateIndex];
                                let altRow = self.generateCourseRow(altClass, choiceCount, true);
                                crBody.table.body.push(altRow);
                            }
                        }
                    }
                }
                docDefinition.content.push(crBody);
                docDefinition.content.push('\n');
            }
            if (formItem.fieldType == 'Departments' && !formData.departments.linkClassesDept) {
                var deparmentsSection = [
                    { text: formItem.departmentRule.departmentLabel, style: ['label'], headlineLevel: 1 },
                    {
                        ul: []
                    }
                ]
                for (let index = 0; index < formItem.departmentRule.selectedDepartments.length; index++) {
                    const element = formItem.departmentRule.selectedDepartments[index];

                    let t = self.fixText(element.Name);
                    if (element.Program_Option__c) {
                        t = t + ' ' + self.fixText(element.Program_Option__r.Name);
                    }
                    if (element.designation) {
                        t = t + ' - ' + self.fixText(element.designation);
                    }
                    deparmentsSection[1].ul.push(t);
                }

                docDefinition.content.push(deparmentsSection);
                docDefinition.content.push('\n');
            }

        }
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
        // Uncomment the line below to automatically download PDF - ONLY WORKS IN CHROMIUM BASED BROWSERS - DO NOT RELEASE TO PRODUCTION WITH THIS LINE UNCOMMENTED!!!! BBARLOW 4-10-2019
        /* pdfMake.createPdf(docDefinition).open();
        submitDynamicDeferred.reject(false); */
        var pdf = pdfMake.createPdf(docDefinition);

        pdf.getBlob((blob) => {

            var f = angular.copy(form);

            var reader = new FileReader();
            reader.readAsDataURL(blob);
            reader.onloadend = function () {
                var base64data = reader.result;
                var jsonData = angular.toJson(f);
                portalRemotingMethods.saveDynamicForm(
                    jsonData,
                    base64data.split(',')[1],
                    'PDF',
                    appItemName + '.pdf',
                    function (result, event) {
                        if (result) {
                            submitDynamicDeferred.resolve(result);
                        }
                        else {
                            submitDynamicDeferred.reject(result);
                        }
                    }
                );
            }
        });
    }

    this.processRules = function (controlFormItem) {
        var form = self.getForm();
        if ((form != null || form != undefined) && (form.formData.itemRules != null || form.formData.itemRules != undefined)) {
            var rule = form.formData.itemRules.find(r => r.contItemNum == controlFormItem.dataNum);
            if (rule) {
                var respondFormItem = items.find(i => i.dataNum == rule.depItemNum);
                if (respondFormItem && controlFormItem.response) {
                    respondFormItem.hidden = false;
                }
                else if (respondFormItem) {
                    respondFormItem.hidden = true;
                }
            }
        }
    }

    this.fixText = function (input) {
        input = $filter('nbsp')(input);
        input = $filter('apostraphe')(input);
        input = $filter('ampersand')(input);
        input = $filter('quote')(input);

        return input;
    }

    this.generateCourseRow = function(cr, choiceCount, isAlternate)
    {
        var choice = isAlternate ? 'Choice ' + choiceCount + ' Alternate' : 'Choice ' + choiceCount;
        var courseTitle = cr.courseTitle != null ? self.fixText(cr.courseTitle) : '';
        var courseCode = cr.courseCode != null ? self.fixText(cr.courseCode) : '';
        var credits = cr.credits != null ? cr.credits : '';
        var usCredits = cr.usCredits != null ? cr.usCredits : '';
        var rowStyle = isAlternate ? 'alternateRow' : '';
        let row = [
            { text: choice, style: rowStyle },
            { text: courseTitle, style: rowStyle },
            { text: courseCode, style: rowStyle },
            { text: credits, style: rowStyle },
            { text: usCredits, style: rowStyle }
        ]
        return row;
    }
});

function toDataURL(url, callback) {
    var xhr = new XMLHttpRequest();
    xhr.onload = function () {
        var reader = new FileReader();
        reader.onloadend = function () {
            callback(reader.result);
        }
        reader.readAsDataURL(xhr.response);
    };
    xhr.open('GET', url);
    xhr.responseType = 'blob';
    xhr.send();
}