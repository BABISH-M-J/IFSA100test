/*!
 * View Model Service
 */

angular.module('ifsaViewmodel', [])
	.service('viewmodel', function() {
		var viewModelData = null;
		return {
	        getViewModel: function () {
	            return viewModelData;
	        },
	        setViewModel: function(value) {
	            viewModelData = angular.fromJson(value);
	        }
		};
	});