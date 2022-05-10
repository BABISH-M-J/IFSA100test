/*!
 * 
 * AngularJS Santize Service
 * Used for sanitizing text.
 * 
 */

angular.module('htmlSafe', ['ngSanitize'])
	.service('sanitizer', function ($sce) {
        return {
            sanitize: function (item) {
                return item == null || item == undefined ? null : item
					.replace(new RegExp('&' + 'lt;', 'g'), '<')
					.replace(new RegExp('&' + 'gt;', 'g'), '>')
					.replace(new RegExp('&' + 'amp;', 'g'), '&')
					.replace(new RegExp('&' + '#39;', 'g'), '\'')
					.replace(new RegExp('&' + 'lt;', 'g'), '<')
					.replace(new RegExp('&' + 'gt;', 'g'), '>')
					.replace(new RegExp('&' + 'quot;', 'g'), '"');
            },
            trustHtml: function(item) {
                return item == null ||  item == undefined ? null : $sce.trustAsHtml(this.sanitize(item));
            },
			untrustHtml: function(item) {
				return item == null ||  item == undefined ? null : item.$$unwrapTrustedValue();
			}
        };
    });