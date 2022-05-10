/**
 * Student Portal Account Service
 * @file Student Portal Account Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('accountService', function($q, viewModel) {
    var self = this;

    this.getAccount = function()
    {
        deferred = $q.defer();
        portalRemotingMethods.getAccountInfo(
            function(result, event) {
                if(result) {
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }
        });
        return deferred.promise;
    }

    this.makePayment = function(paymentAmount)
    {
        deferred = $q.defer();
        portalRemotingMethods.payAccount(
            viewModel.getViewModel().contactId,
            paymentAmount,
            function(result, event) {
                if(result) {
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(result);
                }
        });
        return deferred.promise;
    }
})