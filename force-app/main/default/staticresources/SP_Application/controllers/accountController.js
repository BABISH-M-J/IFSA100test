/**
 * Student Portal Account Page Controller
 * @file Student Portal Account Page Controller
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.controllers')
.controller('accountController', function($scope, $modal, urlService, viewModel, accountService) 
{
    $scope.viewModel = {
        paymentProcessor: 'CashNET',
        showDepositMessage: true,
        accountTotal: 500,
        dueDate: new Date(2019, 4, 1),
        transactions: []
    }

    $scope.init = function() {
        $scope.loading = true;
        var promise = accountService.getAccount();
        promise.then(function(result){
            $scope.viewModel = result;
            $scope.loading = false;
        },
        function(result){
            console.log('could not load account info');
            $scope.loading = false;
        });
    }

    $scope.submit = function() {
        var promise = accountService.makePayment($scope.viewModel.paymentAmount);
        promise.then(function(result){
            window.location.assign(result);
        },
        function(result){
            console.log('could not make payment');
        });
    }

    $scope.init();

})