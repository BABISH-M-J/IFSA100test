// Student Portal ViewModel Service
// Created by: Brock Barlow
angular.module('app.services')
.service('viewModel', function () {
    return {
        getViewModel: function () {
            return viewModelData;
        },
        setViewModel: function(value) {
            viewModelData = value;
        }
    };
});