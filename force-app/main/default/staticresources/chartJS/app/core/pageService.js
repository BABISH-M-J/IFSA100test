/**
 * Chart Page Service
 * @file Chart Page Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('pageService', function($window, settingsFactory) {
    return {
        setTitle: function (newTitle) {
            var title = newTitle != null && newTitle != '' ? settingsFactory.getTitle() + ' - ' + newTitle : settingsFactory.getTitle();
            $window.document.title = title;
        }
     };
});