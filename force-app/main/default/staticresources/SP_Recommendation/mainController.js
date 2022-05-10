/**
 * Student Portal Recommendation Page Main Controller
 * @file Student Portal Recommendation Page Main Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('mainController', function($scope, viewModel, sanitizer, recommendationService)
{
    $scope.viewModel = viewModel.getViewModel();
    $scope.document = {
        title: 'IFSA Evaluation and Recommendation Forms',
        recommendationFor: 'Recommendation for ' + $scope.viewModel.applicationName,
        completedBy: 'To be completed by ' + $scope.viewModel.recommendationRecommenderName + ' (' + $scope.viewModel.recommendationEmail + ')',
        instructions1: 'You have received this form because ' + $scope.viewModel.studentFirstName + ' ' + $scope.viewModel.studentLastName +' has requested a letter of recommendation from you. ' + $scope.viewModel.studentFirstName + ' has applied to study abroad at ' + $scope.viewModel.programTerm + ' through the Institute for Study Abroad, Butler University (IFSA). IFSA is a nonprofit study abroad organization regularly serving students from accredited colleges and universities throughout the U.S. and Canada.',
        instructions2: 'To be accepted into the program, ' + $scope.viewModel.studentFirstName + ' must have a letter of recommendation submitted on his/her behalf from a faculty member. We seek your evaluation of the student\'s academic ability as well as his or her social maturity and emotional strengths in terms of undertaking a period of study abroad. We are particularly interested in your assessment of the student\'s academic motivation and any special attributes relevant to foreign study. Your noting any weaknesses that might impede the student\'s success abroad would also be of great help to us.',
        waiverText: ($scope.viewModel.recommendeeWaived ? 'The student has waived their right to view any recommendations submitted. IFSA will not share your recommendation with the student.' : 'The student did not waive their right to view submitted recommendations. The student may see anything submitted on this page.'),
        ulHeading: 'Please address the following questions in the space provided below:',
        ul: [
            'How long and in what capacity have you known this student?',
            'Please list any courses that this student has taken with you.',
            'What is your general estimate of this student\'s intellectual ability and academic motivation?',
            'Have you found this student to be a mature and stable person?',
            'Do you think this student would make the personal, social and academic adjustment to a program abroad?'
        ],
        additionalComments: 'Feel free to add any additional comments about this student.',
        textAreaInstructions: 'In the text area below, we recommend that you paste in text that you have authored in a text editor or word processor so that you have a backup copy for your records. Please not that if you choose to copy/paste from a word processor, font size and other styling may be altered and need to be changed manually using the formatting tools in this text box.',
        contactInfo: {
            heading: 'Please provide contact information for follow-up purposes.',
            name: 'Name',
            title: 'Title',
            university: 'University',
            phone: 'Phone Number'
        },
        signHere: 'Signature',
        thankYou: 'Thank you for taking the time to complete this form.'
    };
    $scope.alerts = [];
    $scope.saving = false;
    setTimeout(function(){resize();}, 500);

    $scope.submitRecommendation = function() {
        $scope.saving = true;
        // User clicked submit, try to submit recommendation to SF
        var promise = recommendationService.submitRecommendation($scope.viewModel, angular.copy($scope.document));
        promise.then(function(result){
            // Success, redirect user to success page!
            window.location.assign(result);
        },
        function(result){
            // An error occured, add message to alerts.
            $scope.alerts.push({message: result, type: 'warning'});
            $scope.saving = false;
        });
    }

    $scope.closeAlert = function(index) {
        $scope.alerts.splice(index, 1);
      };
});